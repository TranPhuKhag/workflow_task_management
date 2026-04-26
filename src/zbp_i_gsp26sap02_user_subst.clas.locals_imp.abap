CLASS lcl_buffer DEFINITION.
  PUBLIC SECTION.
    CONSTANTS:
      gc_otype_user   TYPE otype                          VALUE 'US',
      gc_max_date     TYPE endda                          VALUE '99991231',
      gc_subst_type_p TYPE zuser_subst_ext-zzsubst_type   VALUE 'P',
      gc_subst_type_u TYPE zuser_subst_ext-zzsubst_type   VALUE 'U',
      gc_notif_obj    TYPE string                         VALUE 'ZWorkflow',
      gc_notif_act    TYPE string                         VALUE 'display&/substitution',
      gc_msg_lwr      TYPE symsgno                        VALUE '010',
      gc_msg_leave    TYPE symsgno                        VALUE '011',
      gc_msg_name     TYPE symsgid                        VALUE 'Z_GSP26_MSG'.

    TYPES: BEGIN OF ty_subst_buffer,
             us_name      TYPE hrus_d2-us_name,
             rep_name     TYPE hrus_d2-rep_name,
             begda        TYPE hrus_d2-begda,
             endda        TYPE hrus_d2-endda,
             zzsubst_type TYPE zuser_subst_ext-zzsubst_type,
           END OF ty_subst_buffer.

    CLASS-DATA: gt_update TYPE TABLE OF ty_subst_buffer,
                gt_delete TYPE TABLE OF ty_subst_buffer.
ENDCLASS.

CLASS lhc_Subst DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Subst RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE Subst.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE Subst.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE Subst.

    METHODS read FOR READ
      IMPORTING keys FOR READ Subst RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK Subst.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Subst RESULT result.

    METHODS toggleActive FOR MODIFY
      IMPORTING keys FOR ACTION Subst~toggleActive RESULT result.

ENDCLASS.

CLASS lhc_Subst IMPLEMENTATION.
* Phi 19/2: fix authorize for update, delete action
  METHOD get_instance_authorizations.
    DATA: lv_update_requested TYPE abap_bool,
          lv_delete_requested TYPE abap_bool,
          lv_action_requested TYPE abap_bool.

    " figure out action
    IF requested_authorizations-%update = if_abap_behv=>mk-on.
      lv_update_requested = abap_true.
    ENDIF.

    IF requested_authorizations-%delete = if_abap_behv=>mk-on.
      lv_delete_requested = abap_true.
    ENDIF.

    IF requested_authorizations-%action-toggleActive = if_abap_behv=>mk-on.
      lv_action_requested = abap_true.
    ENDIF.

    " get current user
    DATA(lv_current_user) = cl_abap_context_info=>get_user_technical_name( ).

    LOOP AT keys INTO DATA(ls_key).

      DATA(lv_auth_update) = COND #(
          WHEN ls_key-UserSubstitutedFor = lv_current_user OR ls_key-UserSubstitutedBy = lv_current_user
          THEN if_abap_behv=>auth-allowed
          ELSE if_abap_behv=>auth-unauthorized ).

      DATA(lv_auth_delete) = COND #(
          WHEN ls_key-UserSubstitutedFor = lv_current_user
          THEN if_abap_behv=>auth-allowed
          ELSE if_abap_behv=>auth-unauthorized ).

      DATA(lv_auth_toggle) = COND #(
          WHEN ls_key-UserSubstitutedBy = lv_current_user
          THEN if_abap_behv=>auth-allowed
          ELSE if_abap_behv=>auth-unauthorized ).

      APPEND VALUE #(
        %tky = ls_key-%tky

        %update = COND #( WHEN lv_update_requested = abap_true
                          THEN lv_auth_update ELSE if_abap_behv=>auth-unauthorized )

        %delete = COND #( WHEN lv_delete_requested = abap_true
                          THEN lv_auth_delete ELSE if_abap_behv=>auth-unauthorized )

        %action-toggleActive = COND #( WHEN lv_action_requested = abap_true
                                       THEN lv_auth_toggle ELSE if_abap_behv=>auth-unauthorized )
      ) TO result.

    ENDLOOP.
  ENDMETHOD.

  METHOD create.
    DATA: ls_owner      TYPE swragent,
          ls_subst      TYPE swragent,
          lv_return     TYPE sysubrc,
          lt_message    TYPE TABLE OF swr_messag,
          lt_msg_struct TYPE TABLE OF swr_mstruc,
          lv_begin_date TYPE swr_substbegin,
          lv_end_date   TYPE swr_substend.

* 31/3/2026 - Phi: check user existance bef create
    DATA: lt_subst_users TYPE TABLE OF xubname.

    LOOP AT entities INTO DATA(ls_ent).
      APPEND ls_ent-UserSubstitutedBy TO lt_subst_users.
    ENDLOOP.
    SORT lt_subst_users.
    DELETE ADJACENT DUPLICATES FROM lt_subst_users.

    TYPES: BEGIN OF ty_usr02,
             bname TYPE xubname,
           END OF ty_usr02.
    DATA: lt_valid_users TYPE TABLE OF ty_usr02.

    IF lt_subst_users IS NOT INITIAL.
      SELECT bname FROM usr02
        FOR ALL ENTRIES IN @lt_subst_users
        WHERE bname = @lt_subst_users-table_line
        INTO TABLE @lt_valid_users.
    ENDIF.
**********************************************************************

    " create instance
    DATA(lo_wrapper) = zcl_fact_wf_subst=>create_instance( ).

    LOOP AT entities INTO DATA(ls_entity).
      DATA(lv_is_available) = abap_true.
      DATA(lv_avail_msg)    = VALUE string( ).

      DATA(lv_current_user) = cl_abap_context_info=>get_user_technical_name( ).
      ls_entity-UserSubstitutedFor = lv_current_user.

      ls_owner-otype = lcl_buffer=>gc_otype_user.
      ls_owner-objid = lv_current_user.

      ls_subst-otype = lcl_buffer=>gc_otype_user.
      ls_subst-objid = ls_entity-UserSubstitutedBy.

* check dupl user
      IF ls_entity-UserSubstitutedFor = ls_entity-UserSubstitutedBy.
        APPEND VALUE #(
          %cid = ls_entity-%cid
          UserSubstitutedFor = ls_entity-UserSubstitutedFor
          %fail-cause        = if_abap_behv=>cause-conflict
        ) TO failed-subst.

        APPEND VALUE #(
          %cid = ls_entity-%cid
          UserSubstitutedFor = ls_entity-UserSubstitutedFor
          %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-error
                   text     = CONV string( TEXT-e01 )
                 )
          %element-UserSubstitutedBy = if_abap_behv=>mk-on
        ) TO reported-subst.

        CONTINUE.
      ENDIF.

* 31/3/2026 - Phi: check user existance bef create
      IF NOT line_exists( lt_valid_users[ bname = ls_subst-objid ] ).
        APPEND VALUE #(
          %cid = ls_entity-%cid
          UserSubstitutedFor = ls_owner-objid
          %fail-cause        = if_abap_behv=>cause-not_found
        ) TO failed-subst.

        APPEND VALUE #(
          %cid = ls_entity-%cid
          UserSubstitutedFor = ls_owner-objid
          %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-error
                   text     = replace( val  = CONV string( TEXT-e02 )
                                       sub  = '&1'
                                       with = CONV string( ls_subst-objid ) )
                 )
          %element-UserSubstitutedBy = if_abap_behv=>mk-on
        ) TO reported-subst.
        CONTINUE.
      ENDIF.
**********************************************************************

      " check role level
      DATA(lv_role_msg) = VALUE string( ).
      DATA(lv_is_role_valid) = zcl_gsp26_utils=>check_role_level_validity(
        EXPORTING
          iv_user_for = ls_owner-objid
          iv_user_by  = ls_subst-objid
        IMPORTING
          ev_message  = lv_role_msg
      ).

      IF lv_is_role_valid = abap_false.
        APPEND VALUE #(
          %cid = ls_entity-%cid
          UserSubstitutedFor = ls_owner-objid
          %fail-cause        = if_abap_behv=>cause-unauthorized
        ) TO failed-subst.

        APPEND VALUE #(
          %cid = ls_entity-%cid
          UserSubstitutedFor = ls_owner-objid
          %msg = new_message(
                   id       = lcl_buffer=>gc_msg_name
                   number   = lcl_buffer=>gc_msg_lwr
                   severity = if_abap_behv_message=>severity-error
                   v1       = ls_subst-objid
                   v2       = ls_owner-objid
                 )
          %element-UserSubstitutedBy = if_abap_behv=>mk-on
        ) TO reported-subst.

        CONTINUE.
      ENDIF.

      IF ls_entity-EndDate IS NOT INITIAL AND ls_entity-EndDate <> lcl_buffer=>gc_max_date.

* assign value
        lv_begin_date = ls_entity-BeginDate.
        lv_end_date   = ls_entity-EndDate.
        ls_entity-Active = abap_true.

* check availability
        lv_avail_msg = VALUE string( ).
        lv_is_available = zcl_gsp26_utils=>check_user_availability(
        EXPORTING
          iv_userid     = ls_entity-UserSubstitutedBy
          iv_begin_date = lv_begin_date
          iv_end_date   = lv_end_date
        IMPORTING
          ev_message    = lv_avail_msg
      ).

      ELSE.
        lv_end_date = lcl_buffer=>gc_max_date.
        lv_begin_date = sy-datum.
      ENDIF.

      IF lv_is_available = abap_false.
        APPEND VALUE #( %cid = ls_entity-%cid
                        UserSubstitutedFor = ls_owner-objid
                        %fail-cause = if_abap_behv=>cause-conflict
                      ) TO failed-subst.

        APPEND VALUE #(
            %cid = ls_entity-%cid
            UserSubstitutedFor = ls_owner-objid
            %msg = new_message(
                   id       = lcl_buffer=>gc_msg_name
                   number   = lcl_buffer=>gc_msg_leave
                   severity = if_abap_behv_message=>severity-error
                   v1       = ls_subst-objid
                   v2       = ls_owner-objid
                 )
        ) TO reported-subst.

        CONTINUE.
      ENDIF.

      " use wrapper
      lo_wrapper->maintain_substitute(
        EXPORTING
          substituted_object = ls_owner
          substitute         = ls_subst
          subst_begin        = lv_begin_date
          subst_end          = lv_end_date
          subst_profile      = ls_entity-SubstitutionProfile
          subst_active       = ls_entity-Active
        IMPORTING
          return_code        = lv_return
        CHANGING
          message_lines      = lt_message
          message_struct     = lt_msg_struct
      ).

      DATA(ls_message_text) = VALUE #( lt_message[ 1 ]-line OPTIONAL ).

      IF lv_return = 0.
        IF ls_message_text IS INITIAL.
          ls_message_text = TEXT-s01.
        ENDIF.

        DATA lv_type TYPE zuser_subst_ext-zzsubst_type.
        IF lv_end_date IS NOT INITIAL AND lv_end_date <> lcl_buffer=>gc_max_date.
          lv_type = lcl_buffer=>gc_subst_type_p.
        ELSE.
          lv_type = lcl_buffer=>gc_subst_type_u.
        ENDIF.

* Phi 17/2/26 data -> buffer table
        APPEND VALUE #(
            us_name      = ls_owner-objid
            rep_name     = ls_subst-objid
            begda        = lv_begin_date
            endda        = lv_end_date
            zzsubst_type = lv_type
        ) TO lcl_buffer=>gt_update.

        APPEND VALUE #(
          %cid = ls_entity-%cid
          UserSubstitutedFor = ls_owner-objid
          UserSubstitutedBy  = ls_subst-objid
          BeginDate          = lv_begin_date
        ) TO mapped-subst.

        APPEND VALUE #(
            %cid = ls_entity-%cid
            %msg = new_message_with_text(
                     severity = if_abap_behv_message=>severity-success
                     text     = ls_message_text )
        ) TO reported-subst.

      ELSE.
        IF ls_message_text IS INITIAL.
          ls_message_text = SWITCH string( lv_return
             WHEN 1 THEN TEXT-e03
             WHEN 4 THEN TEXT-e04
             WHEN 5 THEN TEXT-e05
             ELSE TEXT-e06 ).
        ENDIF.

        APPEND VALUE #(
          %cid = ls_entity-%cid
          %fail-cause = if_abap_behv=>cause-not_found
        ) TO failed-subst.

        APPEND VALUE #(
            %cid = ls_entity-%cid
            %msg = new_message_with_text(
                     severity = if_abap_behv_message=>severity-error
                     text     = ls_message_text )
        ) TO reported-subst.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.

  METHOD update.
    DATA: ls_owner       TYPE swragent,
          ls_subst       TYPE swragent,
          lt_substitutes TYPE TABLE OF swragent,
          lv_return      TYPE sysubrc,
          lt_message     TYPE TABLE OF swr_messag,
          lv_begin_date  TYPE swr_substbegin,
          lv_end_date    TYPE swr_substend,
          lv_profile     TYPE swr_substprof,
          lv_active      TYPE swr_substactive.

    DATA(lo_wrapper) = zcl_fact_wf_subst=>create_instance( ).

    READ ENTITIES OF zi_gsp26sap02_user_subst IN LOCAL MODE
      ENTITY Subst
      ALL FIELDS WITH CORRESPONDING #( entities )
      RESULT DATA(lt_db_data).

    LOOP AT entities INTO DATA(ls_update).
      READ TABLE lt_db_data INTO DATA(ls_db) WITH KEY %tky = ls_update-%tky ##PRIMKEY[ID].
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      ls_owner-otype = lcl_buffer=>gc_otype_user.
      ls_owner-objid = ls_db-UserSubstitutedFor.

      ls_subst-otype = lcl_buffer=>gc_otype_user.
      ls_subst-objid = ls_db-UserSubstitutedBy.

      lv_begin_date  = ls_db-BeginDate.

      IF ls_update-%control-EndDate = if_abap_behv=>mk-on.
        lv_end_date = ls_update-EndDate.
      ELSE.
        lv_end_date = ls_db-EndDate.
      ENDIF.

      IF ls_update-%control-SubstitutionProfile = if_abap_behv=>mk-on.
        lv_profile = ls_update-SubstitutionProfile.
      ELSE.
        lv_profile = ls_db-SubstitutionProfile.
      ENDIF.

      IF ls_update-%control-Active = if_abap_behv=>mk-on.
        lv_active = ls_update-Active.
      ELSE.
        lv_active = ls_db-Active.
      ENDIF.

      IF ls_update-%control-EndDate = if_abap_behv=>mk-on AND lv_end_date <> ls_db-EndDate.
        CLEAR lt_substitutes.
        APPEND ls_subst TO lt_substitutes.

        lo_wrapper->delete_substitute(
          EXPORTING
            substituted_object = ls_owner
            start_date         = ls_db-BeginDate
            end_date           = ls_db-EndDate
          IMPORTING
            return_code        = lv_return
          CHANGING
            substitutes        = lt_substitutes
        ).

      ENDIF.

      CLEAR: lt_message, lv_return.

      lo_wrapper->maintain_substitute(
      EXPORTING
        substituted_object = ls_owner
        substitute         = ls_subst
        subst_begin        = lv_begin_date
        subst_end          = lv_end_date
        subst_profile      = lv_profile
        subst_active       = lv_active
      IMPORTING
        return_code        = lv_return
      CHANGING
        message_lines      = lt_message
    ).

      IF lv_return = 0.
        DATA lv_upd_type TYPE zuser_subst_ext-zzsubst_type.

        IF lv_end_date IS NOT INITIAL AND lv_end_date <> lcl_buffer=>gc_max_date.
          lv_upd_type = lcl_buffer=>gc_subst_type_p.
        ELSE.
          lv_upd_type = lcl_buffer=>gc_subst_type_u.
        ENDIF.

        APPEND VALUE #(
            us_name      = ls_owner-objid
            rep_name     = ls_subst-objid
            begda        = lv_begin_date
            endda        = lv_end_date
            zzsubst_type = lv_upd_type
        ) TO lcl_buffer=>gt_update.

        APPEND VALUE #( %tky = ls_update-%tky
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-success
                                 text     = CONV string( TEXT-s02 ) )
                      ) TO reported-subst.
      ELSE.
        DATA(ls_message_text) = VALUE #( lt_message[ 1 ]-line OPTIONAL ).

        IF ls_message_text IS INITIAL.
          ls_message_text = SWITCH string( lv_return
            WHEN 1 THEN TEXT-e03
            WHEN 4 THEN TEXT-e04
            WHEN 5 THEN TEXT-e05
            ELSE TEXT-e07 ).
        ENDIF.

        APPEND VALUE #( %tky = ls_update-%tky
                        %fail-cause = if_abap_behv=>cause-unspecific
                      ) TO failed-subst.

        APPEND VALUE #( %tky = ls_update-%tky
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text     = ls_message_text )
                      ) TO reported-subst.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.

  METHOD delete.
    DATA: ls_owner       TYPE swragent,
          ls_subst       TYPE swragent,
          lt_substitutes TYPE TABLE OF swragent,
          lv_return      TYPE sysubrc,
          lt_message     TYPE TABLE OF swr_messag.

    DATA(lo_wrapper) = zcl_fact_wf_subst=>create_instance( ).

    READ ENTITIES OF zi_gsp26sap02_user_subst IN LOCAL MODE
      ENTITY Subst
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_entities).

    LOOP AT lt_entities INTO DATA(ls_entity).
      CLEAR: lt_substitutes, ls_owner, ls_subst, lv_return.

      ls_owner-otype = lcl_buffer=>gc_otype_user.
      ls_owner-objid = ls_entity-UserSubstitutedFor.

      ls_subst-otype = lcl_buffer=>gc_otype_user.
      ls_subst-objid = ls_entity-UserSubstitutedBy.
      APPEND ls_subst TO lt_substitutes.

      "use wrap
      lo_wrapper->delete_substitute(
        EXPORTING
          substituted_object = ls_owner
          start_date         = ls_entity-BeginDate
          end_date           = ls_entity-EndDate
        IMPORTING
          return_code        = lv_return
        CHANGING
          substitutes        = lt_substitutes
          message_lines      = lt_message
      ).

      IF lv_return = 0.
        " data -> buffer
        APPEND VALUE #(
            us_name  = ls_owner-objid
            rep_name = ls_subst-objid
            begda    = ls_entity-BeginDate
            endda    = ls_entity-EndDate
        ) TO lcl_buffer=>gt_delete.
      ELSE.
        DATA(ls_msg_text) = VALUE #( lt_message[ 1 ]-line OPTIONAL ).
        IF ls_msg_text IS INITIAL.
          ls_msg_text = TEXT-e08.
        ENDIF.

        APPEND VALUE #(
            %tky = ls_entity-%tky
            UserSubstitutedFor = ls_entity-UserSubstitutedFor
            UserSubstitutedBy  = ls_entity-UserSubstitutedBy
            BeginDate          = ls_entity-BeginDate
            %fail-cause        = if_abap_behv=>cause-unspecific
        ) TO failed-subst.

        APPEND VALUE #(
            UserSubstitutedFor = ls_entity-UserSubstitutedFor
            UserSubstitutedBy  = ls_entity-UserSubstitutedBy
            BeginDate          = ls_entity-BeginDate
            %msg = new_message_with_text(
                     severity = if_abap_behv_message=>severity-error
                     text     = ls_msg_text )
        ) TO reported-subst.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD read.
    IF keys IS INITIAL.
      RETURN.
    ENDIF.

    SELECT * FROM zi_gsp26sap02_user_subst
        FOR ALL ENTRIES IN @keys
        WHERE UserSubstitutedFor = @keys-UserSubstitutedFor
          AND UserSubstitutedBy  = @keys-UserSubstitutedBy
          AND BeginDate          = @keys-BeginDate
        INTO CORRESPONDING FIELDS OF TABLE @result.
  ENDMETHOD.

  METHOD lock.
    DATA: lv_user_for TYPE hrus_d2-us_name,
          lv_user_by  TYPE hrus_d2-rep_name,
          lv_begda    TYPE hrus_d2-begda,
          lv_subrc    TYPE sysubrc,
          lv_err_txt  TYPE string.

    " create instance
    DATA(lo_wrapper) = zcl_fact_wf_subst=>create_instance( ).

    LOOP AT keys INTO DATA(ls_key).
      lv_user_for = ls_key-UserSubstitutedFor.
      lv_user_by  = ls_key-UserSubstitutedBy.
      lv_begda    = ls_key-BeginDate.

      " use wrap
      lo_wrapper->lock_substitute(
        EXPORTING
          us_name     = lv_user_for
          rep_name    = lv_user_by
          begda       = lv_begda
        IMPORTING
          return_code = lv_subrc
          error_text  = lv_err_txt
      ).

      IF lv_subrc <> 0.
        APPEND VALUE #(
            %fail-cause = if_abap_behv=>cause-locked
        ) TO failed-subst.

        APPEND VALUE #(
            %msg = new_message_with_text(
                     severity = if_abap_behv_message=>severity-error
                     text     = lv_err_txt )
        ) TO reported-subst.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.



  METHOD get_instance_features.
    READ ENTITIES OF zi_gsp26sap02_user_subst IN LOCAL MODE
      ENTITY Subst
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_subst).

    LOOP AT lt_subst INTO DATA(ls_subst).
      APPEND VALUE #(
          %tky = ls_subst-%tky
          %action-toggleActive = if_abap_behv=>fc-o-enabled
      ) TO result.
    ENDLOOP.
  ENDMETHOD.

  METHOD toggleActive.
    DATA: lv_activate TYPE xfeld,
          lv_subrc    TYPE sysubrc,
          lv_user_for TYPE xubname,
          lv_user_by  TYPE xubname,
          lv_rfc_msg  TYPE string.

    DATA(lo_wrapper) = zcl_fact_wf_subst=>create_instance( ).

    READ ENTITIES OF zi_gsp26sap02_user_subst IN LOCAL MODE
      ENTITY Subst
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_subst_data).

    LOOP AT lt_subst_data INTO DATA(ls_data).
      TRY.
          lv_activate = keys[ KEY entity %tky = ls_data-%tky ]-%param-IsEnabled.
        CATCH cx_sy_itab_line_not_found.
          lv_activate = abap_false.
      ENDTRY.

      lv_user_for = ls_data-UserSubstitutedFor.
      lv_user_by  = ls_data-UserSubstitutedBy.

      lo_wrapper->toggle_substitute(
          EXPORTING
            iv_user_for = lv_user_for
            iv_user_by  = lv_user_by
            iv_active   = lv_activate
          IMPORTING
            ev_subrc    = lv_subrc
            ev_message  = lv_rfc_msg
        ).

      IF lv_subrc = 0.
        APPEND VALUE #( %tky   = ls_data-%tky
                        %param = ls_data ) TO result.

        APPEND VALUE #( %tky = ls_data-%tky
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-success
                                 text     = lv_rfc_msg )
                      ) TO reported-subst.
      ELSE.
        IF lv_rfc_msg IS INITIAL.
          lv_rfc_msg = TEXT-e09.
        ENDIF.

        APPEND VALUE #( %tky = ls_data-%tky
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text     = lv_rfc_msg )
                      ) TO reported-subst.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.
ENDCLASS.

CLASS lsc_ZI_GSP26SAP02_USER_SUBST DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.
ENDCLASS.

CLASS lsc_ZI_GSP26SAP02_USER_SUBST IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.
    DATA: lt_recipients  TYPE /iwngw/if_notif_provider=>ty_t_notification_recipient,
          lt_parameters  TYPE /iwngw/if_notif_provider=>ty_t_notification_parameter,
          lt_zext_update TYPE TABLE OF zuser_subst_ext,
          lt_zext_delete TYPE TABLE OF zuser_subst_ext.

    IF lcl_buffer=>gt_delete IS NOT INITIAL.
      LOOP AT lcl_buffer=>gt_delete INTO DATA(ls_del_buffer).
        APPEND VALUE #(
          mandt    = sy-mandt
          us_name  = ls_del_buffer-us_name
          rep_name = ls_del_buffer-rep_name
          begda    = ls_del_buffer-begda
        ) TO lt_zext_delete.
      ENDLOOP.

      IF lt_zext_delete IS NOT INITIAL.
        DELETE zuser_subst_ext FROM TABLE @lt_zext_delete.
      ENDIF.

      CLEAR lcl_buffer=>gt_delete.
    ENDIF.

    IF lcl_buffer=>gt_update IS NOT INITIAL.

      SORT lcl_buffer=>gt_update BY us_name rep_name begda endda.
      DELETE ADJACENT DUPLICATES FROM lcl_buffer=>gt_update COMPARING us_name rep_name begda endda.

      LOOP AT lcl_buffer=>gt_update INTO DATA(ls_buffer).

        APPEND VALUE #(
          mandt        = sy-mandt
          us_name      = ls_buffer-us_name
          rep_name     = ls_buffer-rep_name
          begda        = ls_buffer-begda
          endda        = ls_buffer-endda
          zzsubst_type = ls_buffer-zzsubst_type
        ) TO lt_zext_update.

        IF ls_buffer-begda <= sy-datum.
          zcl_gsp26_noti_after_action=>build_subst_data(
                      EXPORTING
                        iv_user_for   = ls_buffer-us_name
                        iv_user_by    = ls_buffer-rep_name
                        iv_type       = ls_buffer-zzsubst_type
                        iv_begda      = ls_buffer-begda
                        iv_endda      = ls_buffer-endda
                      IMPORTING
                        et_recipients = lt_recipients
                        et_parameters = lt_parameters
                    ).

          zcl_gsp26_noti_after_action=>push_notification_generic(
            iv_notif_type = zcl_gsp26_noti_after_action=>gc_notif_subst
            it_recipients = lt_recipients
            it_parameters = lt_parameters
            iv_target_obj = lcl_buffer=>gc_notif_obj
            iv_target_act = lcl_buffer=>gc_notif_act
          ).
        ENDIF.
      ENDLOOP.

      IF lt_zext_update IS NOT INITIAL.
        MODIFY zuser_subst_ext FROM TABLE @lt_zext_update.
      ENDIF.

      CLEAR lcl_buffer=>gt_update.
    ENDIF.
  ENDMETHOD.

  METHOD cleanup.
    CLEAR: lcl_buffer=>gt_update,
           lcl_buffer=>gt_delete.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
