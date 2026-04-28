CLASS zcl_gsp26_noti_after_action DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES /iwngw/if_notif_provider .

    CONSTANTS gc_provider_id      TYPE /iwngw/notif_provider_id  VALUE 'ZZ_SUBSTI_PROVIDER'.
    CONSTANTS gc_notif_subst      TYPE /iwngw/notif_type_text_key VALUE 'SUBST_ASSIGNED'.
    CONSTANTS gc_notif_forward    TYPE /iwngw/notif_type_text_key VALUE 'TASK_FORWARD'.
    CONSTANTS gc_notif_deadline   TYPE /iwngw/notif_type_text_key VALUE 'TASK_DEADLINE'.

    CONSTANTS:
      gc_type_version     TYPE string VALUE '01',
      gc_max_date         TYPE endda  VALUE '99991231',
      gc_subst_type_p     TYPE zuser_subst_ext-zzsubst_type VALUE 'P',
      gc_type_edm_string  TYPE string VALUE 'Edm.String',
      gc_param_user_for   TYPE string VALUE 'USER_FOR',
      gc_param_subst_type TYPE string VALUE 'SUBST_TYPE',
      gc_param_begda      TYPE string VALUE 'BEGDA',
      gc_param_endda      TYPE string VALUE 'ENDDA',
      gc_param_workitem   TYPE string VALUE 'WORKITEM',
      gc_param_sender     TYPE string VALUE 'SENDER',
      gc_param_deadline   TYPE string VALUE 'DEADLINE'.

    CLASS-METHODS build_deadline_data
      IMPORTING
        !iv_workitem_id TYPE sww_wiid
        !iv_deadline    TYPE dats
        !iv_receiver    TYPE xubname
      EXPORTING
        !et_recipients  TYPE /iwngw/if_notif_provider=>ty_t_notification_recipient
        !et_parameters  TYPE /iwngw/if_notif_provider=>ty_t_notification_parameter .

    CLASS-METHODS build_forward_data
      IMPORTING
        !iv_workitem_id TYPE sww_wiid
        !iv_sender      TYPE xubname
        !iv_receiver    TYPE xubname
      EXPORTING
        !et_recipients  TYPE /iwngw/if_notif_provider=>ty_t_notification_recipient
        !et_parameters  TYPE /iwngw/if_notif_provider=>ty_t_notification_parameter .

    CLASS-METHODS push_notification_generic
      IMPORTING
        !iv_notif_type TYPE /iwngw/notif_type_text_key
        !it_recipients TYPE /iwngw/if_notif_provider=>ty_t_notification_recipient
        !it_parameters TYPE /iwngw/if_notif_provider=>ty_t_notification_parameter
        !iv_target_obj TYPE /iwngw/notif_nav_obj OPTIONAL
        !iv_target_act TYPE /iwngw/notif_nav_action OPTIONAL
        !iv_priority   TYPE /iwngw/notif_priority DEFAULT /iwngw/if_notif_provider=>gcs_priorities-neutral .

    CLASS-METHODS build_subst_data
      IMPORTING
        !iv_user_for   TYPE xubname
        !iv_user_by    TYPE xubname
        !iv_type       TYPE zuser_subst_ext-zzsubst_type
        !iv_begda      TYPE begda
        !iv_endda      TYPE endda
      EXPORTING
        !et_recipients TYPE /iwngw/if_notif_provider=>ty_t_notification_recipient
        !et_parameters TYPE /iwngw/if_notif_provider=>ty_t_notification_parameter .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_gsp26_noti_after_action IMPLEMENTATION.
  METHOD /iwngw/if_notif_provider~get_notification_parameters.
  ENDMETHOD.


  METHOD /iwngw/if_notif_provider~handle_action.
  ENDMETHOD.


  METHOD /iwngw/if_notif_provider~handle_bulk_action.
  ENDMETHOD.


  METHOD /iwngw/if_notif_provider~get_notification_type.
    CASE iv_type_key.
      WHEN gc_notif_subst OR gc_notif_forward OR gc_notif_deadline.
        es_notification_type-type_key       = iv_type_key.
        es_notification_type-version        = iv_type_version.
        es_notification_type-is_groupable   = abap_false.
        CLEAR et_notification_action[].

      WHEN OTHERS.
        RAISE EXCEPTION TYPE /iwngw/cx_notif_provider
          EXPORTING
            provider_id = gc_provider_id.
    ENDCASE.
  ENDMETHOD.


  METHOD /iwngw/if_notif_provider~get_notification_type_text.
    DATA lv_lang TYPE spras.
    CLEAR: es_type_text, et_action_text.

    lv_lang = sy-langu.
    SET LANGUAGE iv_language.

    CASE iv_type_key.
      WHEN gc_notif_subst.
        es_type_text-description = TEXT-001. " Substitution Assignment
        MESSAGE s000(z_gsp26_msg) INTO es_type_text-template_sensitive.
        es_type_text-template_public = TEXT-002. " You have a new substitution assignment

      WHEN gc_notif_forward.
        es_type_text-description        = TEXT-003. " Workitem Forwarded
        es_type_text-template_sensitive = TEXT-004. " Task {WORKITEM} has been forwarded to you by {SENDER}
        es_type_text-template_public    = TEXT-005. " You received a forwarded task

      WHEN gc_notif_deadline.
        es_type_text-description        = TEXT-006. " Task Deadline Reminder
        es_type_text-template_sensitive = TEXT-007. " Urgent: Task {WORKITEM} is due on {DEADLINE}
        es_type_text-template_public    = TEXT-008. " You have a task approaching its deadline

      WHEN OTHERS.
        CLEAR es_type_text.

    ENDCASE.

    SET LANGUAGE lv_lang.
  ENDMETHOD.

  METHOD push_notification_generic.
    DATA: lt_notifications TYPE /iwngw/if_notif_provider=>ty_t_notification,
          ls_notification  TYPE /iwngw/if_notif_provider=>ty_s_notification,
          lt_param_bundle  TYPE /iwngw/if_notif_provider=>ty_t_notification_param_bundle,
          ls_param_bundle  TYPE /iwngw/if_notif_provider=>ty_s_notification_param_bundle.

    IF it_parameters IS NOT INITIAL.
      ls_param_bundle-language   = sy-langu.
      ls_param_bundle-parameters = it_parameters.
      APPEND ls_param_bundle TO lt_param_bundle.
    ENDIF.

    TRY.
        ls_notification-id = cl_system_uuid=>create_uuid_x16_static( ).
      CATCH cx_uuid_error.
        RETURN.
    ENDTRY.

    ls_notification-actor_id     = gc_provider_id.
    ls_notification-type_key     = iv_notif_type.
    ls_notification-type_version = gc_type_version.
    ls_notification-priority     = iv_priority.
    ls_notification-recipients   = it_recipients.

    IF lt_param_bundle IS NOT INITIAL.
      ls_notification-parameters = lt_param_bundle.
    ENDIF.

    IF iv_target_obj IS NOT INITIAL AND iv_target_act IS NOT INITIAL.
      ls_notification-navigation_target_object = iv_target_obj.
      ls_notification-navigation_target_action = iv_target_act.
    ENDIF.

    APPEND ls_notification TO lt_notifications.

    TRY.
        /iwngw/cl_notification_api=>create_notifications(
          EXPORTING
            iv_provider_id  = gc_provider_id
            it_notification = lt_notifications
        ).
      CATCH /iwngw/cx_notification_api.
    ENDTRY.
  ENDMETHOD.

  METHOD build_subst_data.
    CLEAR: et_recipients, et_parameters.

    DATA(lv_type_text) = COND string( WHEN iv_type = gc_subst_type_p THEN CONV #( TEXT-009 ) ELSE CONV #( TEXT-010 ) ).

    DATA(lv_begda_str) = |{ iv_begda+6(2) }.{ iv_begda+4(2) }.{ iv_begda(4) }|.
    DATA(lv_endda_str) = COND string( WHEN iv_endda = gc_max_date THEN CONV #( TEXT-011 )
                                      ELSE |{ iv_endda+6(2) }.{ iv_endda+4(2) }.{ iv_endda(4) }| ).

    APPEND VALUE #( id = iv_user_by ) TO et_recipients.

    APPEND VALUE #( name = gc_param_user_for   value = iv_user_for  type = gc_type_edm_string ) TO et_parameters.
    APPEND VALUE #( name = gc_param_subst_type value = lv_type_text type = gc_type_edm_string ) TO et_parameters.
    APPEND VALUE #( name = gc_param_begda      value = lv_begda_str type = gc_type_edm_string ) TO et_parameters.
    APPEND VALUE #( name = gc_param_endda      value = lv_endda_str type = gc_type_edm_string ) TO et_parameters.
  ENDMETHOD.

  METHOD build_forward_data.
    CLEAR: et_recipients, et_parameters.
    APPEND VALUE #( id = iv_receiver ) TO et_recipients.
    APPEND VALUE #( name = gc_param_workitem value = CONV #( iv_workitem_id ) type = gc_type_edm_string ) TO et_parameters.
    APPEND VALUE #( name = gc_param_sender   value = iv_sender                type = gc_type_edm_string ) TO et_parameters.
  ENDMETHOD.

  METHOD build_deadline_data.
    CLEAR: et_recipients, et_parameters.

    APPEND VALUE #( id = iv_receiver ) TO et_recipients.

    DATA(lv_date_str) = |{ iv_deadline+6(2) }.{ iv_deadline+4(2) }.{ iv_deadline(4) }|.

    APPEND VALUE #( name = gc_param_workitem value = CONV #( iv_workitem_id ) type = gc_type_edm_string ) TO et_parameters.
    APPEND VALUE #( name = gc_param_deadline value = lv_date_str              type = gc_type_edm_string ) TO et_parameters.
  ENDMETHOD.

ENDCLASS.
