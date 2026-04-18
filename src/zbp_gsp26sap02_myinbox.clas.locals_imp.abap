
CLASS lhc_MyInbox DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PUBLIC SECTION.
  PRIVATE SECTION.
    CONSTANTS:
      BEGIN OF lc_tech_status,
        selected  TYPE string VALUE 'SELECTED',
        started   TYPE string VALUE 'STARTED',
        committed TYPE string VALUE 'COMMITTED',
        ready     TYPE string VALUE 'READY',
        waiting   TYPE string VALUE 'WAITING',
      END OF lc_tech_status,
      BEGIN OF lc_task_id,
        user_decision TYPE string VALUE 'TS00008267',
      END OF lc_task_id,
      BEGIN OF lc_msg_type,
        error   TYPE symsgty VALUE 'E',
        abort   TYPE symsgty VALUE 'A',
        warning TYPE symsgty VALUE 'W',
        success TYPE symsgty VALUE 'S',
        info    TYPE symsgty VALUE 'I',
      END OF lc_msg_type,
      BEGIN OF lc_container,
        decision      TYPE string VALUE 'Decision' ##NO_TEXT,
        decision_note TYPE string VALUE 'DECISION_NOTE' ##NO_TEXT,
      END OF lc_container,
      lc_role_admin   TYPE string VALUE 'Admin' ##NO_TEXT,
      lc_objtype_sofm TYPE swo_objtyp VALUE 'SOFM' ##NO_TEXT.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR MyInbox RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR MyInbox RESULT result.
    METHODS read FOR READ
      IMPORTING keys FOR READ MyInbox RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK MyInbox.

    METHODS claim FOR MODIFY
      IMPORTING keys FOR ACTION MyInbox~claim RESULT result.

    METHODS executionDecision FOR MODIFY
      IMPORTING keys FOR ACTION MyInbox~executionDecision RESULT result.

    METHODS forward FOR MODIFY
      IMPORTING keys FOR ACTION MyInbox~forward RESULT result.

    METHODS release FOR MODIFY
      IMPORTING keys FOR ACTION MyInbox~release RESULT result.

    METHODS suspend FOR MODIFY
      IMPORTING keys FOR ACTION MyInbox~suspend RESULT result.

    METHODS approve FOR MODIFY
      IMPORTING keys FOR ACTION MyInbox~approve RESULT result.

    METHODS reject FOR MODIFY
      IMPORTING keys FOR ACTION MyInbox~reject RESULT result.

    METHODS reSubmission FOR MODIFY
      IMPORTING keys FOR ACTION MyInbox~reSubmission RESULT result.

    METHODS setPriority FOR MODIFY
      IMPORTING keys FOR ACTION MyInbox~setPriority RESULT result.

    METHODS rba_Attachments FOR READ
      IMPORTING keys_rba FOR READ MyInbox\_Attachments FULL result_requested RESULT result LINK association_links.

    METHODS cba_Attachments FOR MODIFY
      IMPORTING entities_cba FOR CREATE MyInbox\_Attachments.

    METHODS rba_Comments FOR READ
      IMPORTING keys_rba FOR READ MyInbox\_Comments FULL result_requested RESULT result LINK association_links.

    METHODS cba_Comments FOR MODIFY
      IMPORTING entities_cba FOR CREATE MyInbox\_Comments.

    METHODS bulkDelegation FOR MODIFY
      IMPORTING keys FOR ACTION MyInbox~bulkDelegation RESULT result.

    TYPES: tt_failed     TYPE TABLE FOR FAILED EARLY zr_gsp26sap02_myinbox,
           tt_reported   TYPE TABLE FOR REPORTED EARLY zr_gsp26sap02_myinbox,
           tt_swr_mstruc TYPE TABLE OF swr_mstruc.

    METHODS map_messages
      IMPORTING
        cid          TYPE abp_behv_cid OPTIONAL
        workitem_id  TYPE sww_wiid OPTIONAL
        message      TYPE  tt_swr_mstruc
      EXPORTING
        failed_added TYPE abap_boolean
      CHANGING
        failed       TYPE tt_failed
        reported     TYPE tt_reported
      .
    TYPES: tt_attachment_failed   TYPE TABLE FOR FAILED EARLY ZI_GSP26SAP02_WF_Attachment,
           tt_attachment_resulted TYPE TABLE FOR REPORTED EARLY ZI_GSP26SAP02_WF_Attachment.
    METHODS map_messages_assoc_to_attach
      IMPORTING
        cid          TYPE string
        is_dependend TYPE abap_bool DEFAULT abap_false
        message      TYPE  tt_swr_mstruc
      EXPORTING
        failed_added TYPE abap_bool
      CHANGING
        failed       TYPE tt_attachment_failed
        reported     TYPE tt_attachment_resulted
      .
    TYPES: tt_comment_failed   TYPE TABLE FOR FAILED ZI_GSP26SAP02_WF_Comment,
           tt_comment_resulted TYPE TABLE FOR REPORTED EARLY ZI_GSP26SAP02_WF_Comment.
    METHODS map_messages_assoc_to_comment
      IMPORTING
        cid          TYPE string
        is_dependend TYPE abap_bool DEFAULT abap_false
        message      TYPE  tt_swr_mstruc
      EXPORTING
        failed_added TYPE abap_bool
      CHANGING
        failed       TYPE tt_comment_failed
        reported     TYPE tt_comment_resulted
      .

ENDCLASS.

CLASS lhc_MyInbox IMPLEMENTATION.

  METHOD get_instance_features.
    READ ENTITIES OF zr_gsp26sap02_myinbox IN LOCAL MODE
    ENTITY MyInbox
    FIELDS ( WorkItemID TechnicalStatus  TaskID )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_wftasks).

    result = VALUE #( FOR ls_wftask IN lt_wftasks
                    (  %tky = ls_wftask-%tky
                   %features-%action-executionDecision = COND #(
                      WHEN (     ls_wftask-TechnicalStatus = lc_tech_status-selected
                             AND ls_wftask-TaskID          = lc_task_id-user_decision )
                        OR (     ls_wftask-TechnicalStatus = lc_tech_status-started
                             AND ls_wftask-TaskID          = lc_task_id-user_decision )
                        OR (     ls_wftask-TechnicalStatus = lc_tech_status-committed
                             AND ls_wftask-TaskID          = lc_task_id-user_decision )
                      THEN if_abap_behv=>fc-o-enabled
                      ELSE if_abap_behv=>fc-o-disabled
                    )

                    %features-%action-approve = COND #(
                      WHEN (     ls_wftask-TechnicalStatus = lc_tech_status-selected
                             AND ls_wftask-TaskID          <> lc_task_id-user_decision )
                        OR (     ls_wftask-TechnicalStatus = lc_tech_status-started
                             AND ls_wftask-TaskID          <> lc_task_id-user_decision )
                      THEN if_abap_behv=>fc-o-enabled
                      ELSE if_abap_behv=>fc-o-disabled
                    )

                    %features-%action-reject = COND #(
                      WHEN (     ls_wftask-TechnicalStatus = lc_tech_status-selected
                             AND ls_wftask-TaskID          <> lc_task_id-user_decision )
                        OR (     ls_wftask-TechnicalStatus = lc_tech_status-started
                             AND ls_wftask-TaskID          <> lc_task_id-user_decision )
                      THEN if_abap_behv=>fc-o-enabled
                      ELSE if_abap_behv=>fc-o-disabled
                    )

                    %features-%action-claim = COND #(
                      WHEN ls_wftask-TechnicalStatus = lc_tech_status-ready
                      THEN if_abap_behv=>fc-o-enabled
                      ELSE if_abap_behv=>fc-o-disabled
                    )

                    %features-%action-release = COND #(
                      WHEN ls_wftask-TechnicalStatus = lc_tech_status-selected
                        OR ls_wftask-TechnicalStatus = lc_tech_status-started
                        OR ls_wftask-TechnicalStatus = lc_tech_status-committed
                      THEN if_abap_behv=>fc-o-enabled
                      ELSE if_abap_behv=>fc-o-disabled
                    )

                    %features-%action-suspend = COND #(
                      WHEN ls_wftask-TechnicalStatus = lc_tech_status-selected
                      THEN if_abap_behv=>fc-o-enabled
                      ELSE if_abap_behv=>fc-o-disabled
                    )

                    %features-%action-forward = COND #(
                      WHEN ls_wftask-TechnicalStatus = lc_tech_status-selected
                      THEN if_abap_behv=>fc-o-enabled
                      ELSE if_abap_behv=>fc-o-disabled
                    )

                    %features-%action-reSubmission = COND #(
                      WHEN ls_wftask-TechnicalStatus = lc_tech_status-waiting
                      THEN if_abap_behv=>fc-o-enabled
                      ELSE if_abap_behv=>fc-o-disabled
                    )

                    %features-%action-setPriority = COND #(
                      WHEN ls_wftask-TechnicalStatus = lc_tech_status-selected
                      THEN if_abap_behv=>fc-o-enabled
                      ELSE if_abap_behv=>fc-o-disabled
                    )

                  ) ).
  ENDMETHOD.

  METHOD get_instance_authorizations.
    DATA: setPriority_requested TYPE abap_bool.

    SELECT SINGLE @abap_true
      FROM ZI_GSP26SAP02_Current_Role
      WHERE RoleName = @lc_role_admin
        AND UserName = @sy-uname
      INTO @DATA(lv_is_admin).
    result = VALUE #( FOR key IN keys (
          %tky = key-%tky
          %action-setPriority = COND #( WHEN  lv_is_admin = abap_true
                                        THEN if_abap_behv=>auth-allowed
                                        ELSE if_abap_behv=>auth-unauthorized ) ) ).

  ENDMETHOD.
  METHOD read.
    IF keys IS INITIAL.
      RETURN.
    ENDIF.
    SELECT * FROM zr_gsp26sap02_myinbox
    FOR ALL ENTRIES IN @keys
    WHERE WorkItemID = @keys-WorkItemID
    INTO CORRESPONDING FIELDS OF TABLE @result.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD claim.
    DATA : lv_return_code    TYPE sysubrc,
           lt_message_struct TYPE TABLE OF swr_mstruc,
           lt_message_lines  TYPE TABLE OF swr_messag,
           lv_new_status     TYPE swr_wistat
           .
    DATA(lo_wapi_wrapper) = zcl_fact_wf_myinbox=>create_instance( ).
    LOOP AT keys ASSIGNING FIELD-SYMBOL(<lfs_key>).
      CLEAR: lv_return_code, lt_message_struct, lt_message_lines, lv_new_status.
      lo_wapi_wrapper->reserve(
        EXPORTING
          workitem_id             = <lfs_key>-WorkItemID
          actual_agent            = sy-uname
          language                = sy-langu
          do_commit               = abap_false
          check_inbox_restriction = abap_true
        IMPORTING
          return_code             = lv_return_code
          new_status              = lv_new_status
        CHANGING
          message_lines           = lt_message_lines
          message_struct          = lt_message_struct
      ).
      map_messages(
        EXPORTING
          cid          = <lfs_key>-%cid_ref
          workitem_id  = <lfs_key>-WorkItemID
          message      = lt_message_struct
        IMPORTING
          failed_added = DATA(lv_failed_added)
        CHANGING
          failed       = failed-myinbox
          reported     = reported-myinbox
      ).
      IF lv_failed_added = abap_false.
        APPEND  <lfs_key>-WorkItemID TO zbp_gsp26sap02_myinbox=>gt_wiids.
        APPEND VALUE #( %tky = <lfs_key>-%tky %param = CORRESPONDING #( <lfs_key> ) ) TO result.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD executionDecision.
    DATA: lv_return_code    TYPE sysubrc,
          lt_message_struct TYPE TABLE OF swr_mstruc,
          lt_message_lines  TYPE TABLE OF swr_messag,
          lv_decision_note  TYPE swrsobjid,
          lv_new_status     TYPE sww_wistat,
          lv_att_txt        TYPE string.
    DATA(lo_wapi_wrapper) = zcl_fact_wf_myinbox=>create_instance( ).

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<lfs_key>).
      CLEAR: lv_return_code, lt_message_struct, lt_message_lines, lv_new_status.

      DATA(lv_workitem_id) = <lfs_key>-WorkItemID.
      DATA(lv_decision_key) = COND swr_decikey( WHEN <lfs_key>-%param-element IS INITIAL THEN '0002' ELSE <lfs_key>-%param-element ).

      lv_att_txt = <lfs_key>-%param-reason.
      lo_wapi_wrapper->complete_decision(
        EXPORTING
          workitem_id               = lv_workitem_id
          check_inbox_restriction   = abap_true
          decision_key              = lv_decision_key
          do_callback_in_background = abap_true
          do_commit                 = abap_false
          language                  = sy-langu
          user                      = sy-uname
*         att_header                =
          att_txt                   = lv_att_txt
*               att_bin
          document_owner            = sy-uname
          comment_semantic          = 'X'
          comment_method            = '01'
        IMPORTING
          new_status                = lv_new_status
          return_code               = lv_return_code
        CHANGING
          decision_note             = lv_decision_note
          message_lines             = lt_message_lines
          message_struct            = lt_message_struct
      ).
      map_messages(
        EXPORTING
          cid          = <lfs_key>-%cid_ref
          workitem_id  = <lfs_key>-WorkItemID
          message      = lt_message_struct
        IMPORTING
          failed_added = DATA(lv_failed_added)
        CHANGING
          failed       = failed-myinbox
          reported     = reported-myinbox
      ).
      IF lv_failed_added = abap_false.
        APPEND <lfs_key>-WorkItemID TO zbp_gsp26sap02_myinbox=>gt_wiids.
        APPEND VALUE #( %tky = <lfs_key>-%tky %param = CORRESPONDING #( <lfs_key> ) ) TO result.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
  METHOD forward.
    DATA : lv_return_code    TYPE sysubrc,
           lv_new_status     TYPE swr_wistat,
           lt_message_struct TYPE TABLE OF swr_mstruc,
           lt_message_lines  TYPE TABLE OF swr_messag,
           lt_user_ids       TYPE TABLE OF swragent,
           lv_att_txt        TYPE string,
           lv_comment_method TYPE swr_inbox_method
           .
    DATA: lt_recipients TYPE /iwngw/if_notif_provider=>ty_t_notification_recipient,
          lt_parameters TYPE /iwngw/if_notif_provider=>ty_t_notification_parameter.
    READ ENTITIES OF ZR_GSP26SAP02_MyInbox IN LOCAL MODE
      ENTITY MyInbox
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_db_data).
    DATA(lo_wapi_wrapper) = zcl_fact_wf_myinbox=>create_instance( ).

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<lfs_key>).
      CLEAR: lv_return_code, lt_message_struct, lt_message_lines, lt_user_ids,lv_att_txt.
      READ TABLE lt_db_data INTO DATA(ls_db) WITH KEY id COMPONENTS %tky = <lfs_key>-%tky.

      IF ls_db-TaskID EQ lc_task_id-user_decision.
        lv_comment_method = '01'.
      ENDIF.
      IF <lfs_key>-%param-reason IS NOT INITIAL.
        lv_att_txt = <lfs_key>-%param-reason.
      ENDIF.
      lo_wapi_wrapper->forward(
        EXPORTING
          workitem_id             = <lfs_key>-WorkItemID
          user_id                 = <lfs_key>-%param-user_id
          language                = sy-langu
          do_commit               = abap_false
          current_user            = sy-uname
          check_inbox_restriction = abap_true
          att_txt                 = lv_att_txt
          document_owner          = sy-uname
          comment_semantic        = abap_true
          comment_method          = lv_comment_method
        IMPORTING
          return_code             = lv_return_code
          new_status              = lv_new_status
        CHANGING
          message_lines           = lt_message_lines
          message_struct          = lt_message_struct
          user_ids                = lt_user_ids
      ).

      CLEAR: lt_recipients, lt_parameters.

      zcl_gsp26_noti_after_action=>build_forward_data(
        EXPORTING
          iv_workitem_id = <lfs_key>-WorkItemID
          iv_sender      = sy-uname
          iv_receiver    = <lfs_key>-%param-user_id
        IMPORTING
          et_recipients  = lt_recipients
          et_parameters  = lt_parameters
      ).

      DATA(lv_wiid_str) = |{ <lfs_key>-WorkItemID ALPHA = OUT }|.
      CONDENSE lv_wiid_str NO-GAPS.
      DATA(lv_target_action) = |display&/tasks/{ lv_wiid_str }/TwoColumnsMidExpanded|.

      zcl_gsp26_noti_after_action=>push_notification_generic(
        iv_notif_type = zcl_gsp26_noti_after_action=>gc_notif_forward
        it_recipients = lt_recipients
        it_parameters = lt_parameters
        iv_target_obj = 'ZWorkflow'
        iv_target_act = lv_target_action
      ).
      map_messages(
        EXPORTING
          cid          = <lfs_key>-%cid_ref
          workitem_id  = <lfs_key>-WorkItemID
          message      = lt_message_struct
        IMPORTING
          failed_added = DATA(lv_failed_added)
        CHANGING
          failed       = failed-myinbox
          reported     = reported-myinbox
      ).
      IF lv_failed_added = abap_false.
        APPEND <lfs_key>-WorkItemID TO zbp_gsp26sap02_myinbox=>gt_wiids.
        APPEND VALUE #( %tky = <lfs_key>-%tky %param = CORRESPONDING #( <lfs_key> ) ) TO result.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD release.
    DATA : lv_return_code    TYPE sysubrc,
           lv_new_status     TYPE swr_wistat,
           lt_message_struct TYPE TABLE OF swr_mstruc,
           lt_message_lines  TYPE TABLE OF swr_messag.

    DATA(lo_wapi_wrapper) = zcl_fact_wf_myinbox=>create_instance( ).
    LOOP AT keys ASSIGNING FIELD-SYMBOL(<lfs_key>).
      CLEAR: lv_return_code, lt_message_struct, lt_message_lines, lv_new_status.
      lo_wapi_wrapper->release(
        EXPORTING
          workitem_id             = <lfs_key>-WorkItemID
          user_id                 = sy-uname
          language                = sy-langu
          do_commit               = abap_false
          check_inbox_restriction = abap_true
        IMPORTING
          return_code             = lv_return_code
          new_status              = lv_new_status
        CHANGING
          message_lines           = lt_message_lines
          message_struct          = lt_message_struct
      ).
      map_messages(
        EXPORTING
          cid          = <lfs_key>-%cid_ref
          workitem_id  = <lfs_key>-WorkItemID
          message      = lt_message_struct
        IMPORTING
          failed_added = DATA(lv_failed_added)
        CHANGING
          failed       = failed-myinbox
          reported     = reported-myinbox
      ).
      IF lv_failed_added = abap_false.
        APPEND <lfs_key>-WorkItemID TO zbp_gsp26sap02_myinbox=>gt_wiids.
        APPEND VALUE #( %tky = <lfs_key>-%tky %param = CORRESPONDING #( <lfs_key> ) ) TO result.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD suspend.
    DATA : lv_return_code    TYPE sysubrc,
           lv_new_status     TYPE swr_wistat,
           lt_message_struct TYPE TABLE OF swr_mstruc,
           lt_message_lines  TYPE TABLE OF swr_messag
           .

    DATA(lo_wapi_wrapper) = zcl_fact_wf_myinbox=>create_instance( ).
    LOOP AT keys ASSIGNING FIELD-SYMBOL(<lfs_key>).
      CLEAR: lv_return_code, lt_message_struct, lt_message_lines, lv_new_status.

      IF <lfs_key>-%param-resubmission_date IS INITIAL OR <lfs_key>-%param-resubmission_time IS INITIAL .
        APPEND VALUE #(
            msgty = 'E'
            msgid = 'ZGSP26SAP02_MYINBOX'
            msgno = '002' "  Resubmission date is required.
        ) TO lt_message_struct.
      ELSE.
        lo_wapi_wrapper->suspend(
          EXPORTING
            workitem_id             = <lfs_key>-WorkItemID
            user_id                 = sy-uname
            language                = sy-langu
            resubmission_date       = <lfs_key>-%param-resubmission_date
            resubmission_time       = <lfs_key>-%param-resubmission_time
            resubmission_zonlo      = sy-zonlo
            do_commit               = abap_false
            check_inbox_restriction = abap_true
          IMPORTING
            return_code             = lv_return_code
            new_status              = lv_new_status
          CHANGING
            message_lines           = lt_message_lines
            message_struct          = lt_message_struct
        ).
      ENDIF.
      map_messages(
        EXPORTING
          cid          = <lfs_key>-%cid_ref
          workitem_id  = <lfs_key>-WorkItemID
          message      = lt_message_struct
        IMPORTING
          failed_added = DATA(lv_failed_added)
        CHANGING
          failed       = failed-myinbox
          reported     = reported-myinbox
      ).
      IF lv_failed_added = abap_false.
        APPEND <lfs_key>-WorkItemID TO zbp_gsp26sap02_myinbox=>gt_wiids.
        APPEND VALUE #( %tky = <lfs_key>-%tky %param = CORRESPONDING #( <lfs_key> ) ) TO result.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD approve.
    DATA : lv_return_code      TYPE sysubrc,
           lv_new_status       TYPE sww_wistat,
           lt_message_struct   TYPE TABLE OF swr_mstruc,
           lt_message_lines    TYPE TABLE OF swr_messag,
           lt_simple_container TYPE TABLE OF swr_cont,
           ls_att_header       TYPE swr_att_header,
           lv_att_id           TYPE swr_att_id,
           lv_doc_size         TYPE i,
           lv_att_txt          TYPE string
           .
    DATA(lo_wapi_wrapper) = zcl_fact_wf_myinbox=>create_instance( ).
    LOOP AT keys ASSIGNING FIELD-SYMBOL(<lfs_key>).

      CLEAR: lv_return_code, lt_message_struct, lt_message_lines, lv_new_status,lv_att_txt.
      IF <lfs_key>-%param-reason IS NOT INITIAL.
        lv_att_txt = <lfs_key>-%param-reason.
      ENDIF.
      ls_att_header = TEXT-001.
      lo_wapi_wrapper->complete_workitem(
        EXPORTING
          is_approval               = abap_true
          workitem_id               = <lfs_key>-WorkItemID
          att_header                = ls_att_header
          att_txt                   = lv_att_txt
*         att_bin                   =
          document_owner            = sy-uname
          actual_agent              = sy-uname
          language                  = sy-langu
          set_obsolet               = space
          do_commit                 = abap_false
          do_callback_in_background = abap_false
*         ifs_xml_container         =
          comment_semantic          = abap_true
          check_inbox_restriction   = abap_true
        IMPORTING
          return_code               = lv_return_code
          new_status                = lv_new_status
          att_id                    = lv_att_id
          doc_size                  = lv_doc_size
        CHANGING
          simple_container          = lt_simple_container
          message_lines             = lt_message_lines
          message_struct            = lt_message_struct
      ).
      map_messages(
        EXPORTING
          cid          = <lfs_key>-%cid_ref
          workitem_id  = <lfs_key>-WorkItemID
          message      = lt_message_struct
        IMPORTING
          failed_added = DATA(lv_failed_added)
        CHANGING
          failed       = failed-myinbox
          reported     = reported-myinbox
      ).
      IF lv_failed_added = abap_false.
        APPEND  <lfs_key>-WorkItemID TO zbp_gsp26sap02_myinbox=>gt_wiids.
        APPEND VALUE #( %tky = <lfs_key>-%tky %param = CORRESPONDING #( <lfs_key> ) ) TO result.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD reject.
    DATA : lv_return_code      TYPE sysubrc,
           lv_new_status       TYPE sww_wistat,
           lt_message_struct   TYPE TABLE OF swr_mstruc,
           lt_message_lines    TYPE TABLE OF swr_messag,
           lt_simple_container TYPE TABLE OF swr_cont,
           ls_att_header       TYPE swr_att_header,
           lv_att_id           TYPE swr_att_id,
           lv_doc_size         TYPE i,
           lv_att_txt          TYPE string
           .
    DATA(lo_wapi_wrapper) = zcl_fact_wf_myinbox=>create_instance( ).

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<lfs_key>).
      CLEAR: lv_return_code, lt_message_struct, lt_message_lines, lv_new_status,lv_att_txt.
      IF <lfs_key>-%param-reason IS NOT INITIAL.
        lv_att_txt = <lfs_key>-%param-reason.
      ENDIF.
      ls_att_header = TEXT-001.
      lo_wapi_wrapper->complete_workitem(
        EXPORTING
          is_approval               = abap_false
          workitem_id               = <lfs_key>-WorkItemID
          att_header                = ls_att_header
          att_txt                   = lv_att_txt
*         att_bin                   =
          document_owner            = sy-uname
          actual_agent              = sy-uname
          language                  = sy-langu
          set_obsolet               = space
          do_commit                 = abap_false
          do_callback_in_background = abap_false
*         ifs_xml_container         =
          comment_semantic          = abap_true
          check_inbox_restriction   = abap_true
        IMPORTING
          return_code               = lv_return_code
          new_status                = lv_new_status
          att_id                    = lv_att_id
          doc_size                  = lv_doc_size
        CHANGING
          simple_container          = lt_simple_container
          message_lines             = lt_message_lines
          message_struct            = lt_message_struct
      ).
      map_messages(
        EXPORTING
          cid          = <lfs_key>-%cid_ref
          workitem_id  = <lfs_key>-WorkItemID
          message      = lt_message_struct
        IMPORTING
          failed_added = DATA(lv_failed_added)
        CHANGING
          failed       = failed-myinbox
          reported     = reported-myinbox
      ).
      IF lv_failed_added = abap_false.
        APPEND  <lfs_key>-WorkItemID TO zbp_gsp26sap02_myinbox=>gt_wiids.
        APPEND VALUE #( %tky = <lfs_key>-%tky %param = CORRESPONDING #( <lfs_key> ) ) TO result.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
* 17/02/2026 - GSP26SAP02 - ABAP Behavior Implementation for Re-submission of workflow task
  METHOD reSubmission.
    DATA: lv_return_code     TYPE sysubrc,
          lv_new_status      TYPE swr_wistat,
          lv_deadlines_exist TYPE sww_deadfl,
          lt_message_struct  TYPE TABLE OF swr_mstruc,
          lt_message_lines   TYPE TABLE OF swr_messag.
    DATA(lo_wapi_wrapper) = zcl_fact_wf_myinbox=>create_instance( ).
    LOOP AT keys ASSIGNING FIELD-SYMBOL(<lfs_key>).
      CLEAR: lv_return_code, lv_new_status,lv_deadlines_exist,lt_message_struct.
      lo_wapi_wrapper->resubmission(
        EXPORTING
          workitem_id    = <lfs_key>-WorkItemID
          do_commit      = abap_false
          user           = sy-uname
          language       = sy-langu
        IMPORTING
          new_status     = lv_new_status
          return_code    = lv_return_code
        CHANGING
          message_lines  = lt_message_lines
          message_struct = lt_message_struct
      ).
      map_messages(
        EXPORTING
          cid          = <lfs_key>-%cid_ref
          workitem_id  = <lfs_key>-WorkItemID
          message      = lt_message_struct
        IMPORTING
          failed_added = DATA(lv_failed_added)
        CHANGING
          failed       = failed-myinbox
          reported     = reported-myinbox
      ).
      IF lv_failed_added = abap_false.
        APPEND  <lfs_key>-WorkItemID TO zbp_gsp26sap02_myinbox=>gt_wiids.
        APPEND VALUE #( %tky = <lfs_key>-%tky %param = CORRESPONDING #( <lfs_key> ) ) TO result.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD setPriority.
    DATA: lv_return_code    TYPE sysubrc,
          lt_message_struct TYPE TABLE OF swr_mstruc,
          lt_message_lines  TYPE TABLE OF swr_messag.
    LOOP AT keys ASSIGNING FIELD-SYMBOL(<lfs_key>).
      CLEAR: lv_return_code,lt_message_struct.
      DATA(lo_wapi_wrapper) = zcl_fact_wf_myinbox=>create_instance( ).
      lo_wapi_wrapper->priority_change(
        EXPORTING
          workitem_id             = <lfs_key>-WorkItemID
          priority                = <lfs_key>-%param-priority
          language                = sy-langu
          do_commit               = abap_false
          check_inbox_restriction = abap_true
        IMPORTING
          return_code             = lv_return_code
        CHANGING
          message_lines           = lt_message_lines
          message_struct          = lt_message_struct
      ).
      map_messages(
        EXPORTING
          cid          = <lfs_key>-%cid_ref
          workitem_id  = <lfs_key>-WorkItemID
          message      = lt_message_struct
        IMPORTING
          failed_added = DATA(lv_failed_added)
        CHANGING
          failed       = failed-myinbox
          reported     = reported-myinbox
      ).
      IF lv_failed_added = abap_false.
        APPEND <lfs_key>-WorkItemID TO zbp_gsp26sap02_myinbox=>gt_wiids.
        APPEND VALUE #( %tky = <lfs_key>-%tky %param = CORRESPONDING #( <lfs_key> ) ) TO result.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD rba_Attachments.
  ENDMETHOD.


  METHOD cba_Attachments.
    DATA: lv_return_code     TYPE sy-subrc,
          lt_att_header      TYPE  swr_att_header,
          ls_att_id          TYPE swr_att_id,
          ls_doc_size        TYPE i,
          lv_content_xstring TYPE xstring,
          lt_message_struct  TYPE TABLE OF swr_mstruc,
          lt_message_lines   TYPE TABLE OF swr_messag.
    DATA(lo_wapi_wrapper) = zcl_fact_wf_myinbox=>create_instance( ).
    READ ENTITIES OF ZR_GSP26SAP02_MyInbox IN LOCAL MODE
         ENTITY MyInbox
         ALL FIELDS WITH CORRESPONDING #( entities_cba )
         RESULT DATA(lt_parent_data).

    LOOP AT entities_cba ASSIGNING FIELD-SYMBOL(<lfs_parent>).
      CLEAR lt_message_struct.
      DATA(lv_workitem_id) = <lfs_parent>-%key-WorkItemID.
      READ TABLE lt_parent_data INTO DATA(ls_db) WITH KEY id COMPONENTS %tky = <lfs_parent>-%tky.
      IF sy-subrc <> 0.
        APPEND VALUE #( msgty = 'E'
                        msgid = 'ZGSP26SAP02_MYINBOX'
                        msgno = '001'
                        msgv1 = lv_workitem_id ) TO lt_message_struct.
      ENDIF.
      map_messages(
        EXPORTING
          cid          = <lfs_parent>-%cid_ref
          workitem_id  = lv_workitem_id
          message      = lt_message_struct
        IMPORTING
          failed_added = DATA(lv_failed_added)
        CHANGING
          failed       = failed-myinbox
          reported     = reported-myinbox
      ).
      IF lv_failed_added = abap_true.
        LOOP AT <lfs_parent>-%target ASSIGNING FIELD-SYMBOL(<lfs_child>).
          map_messages_assoc_to_attach(
            EXPORTING
              cid          = <lfs_child>-%cid
              is_dependend = abap_true
              message      = lt_message_struct
            CHANGING
              failed       = failed-attachments
              reported     = reported-attachments
          ).
        ENDLOOP.
      ELSE.
        LOOP AT <lfs_parent>-%target ASSIGNING FIELD-SYMBOL(<lfs_child_create>).
          CLEAR: lv_return_code, ls_att_id, ls_doc_size, lt_message_struct, lt_message_lines, lv_content_xstring, lt_att_header.
          lv_content_xstring = <lfs_child_create>-%data-NewFileContent.
          " Prepare attachment header
          lt_att_header-file_type = 'B'.
          lt_att_header-file_name = <lfs_child_create>-%data-DocumentTitle.
          lt_att_header-file_extension = to_lower( <lfs_child_create>-%data-FileExtension ).
          lt_att_header-language = sy-langu.

          lo_wapi_wrapper->add_attachment(
            EXPORTING
              workitem_id             = lv_workitem_id
              att_header              = lt_att_header
              att_bin                 = lv_content_xstring
              document_owner          = sy-uname
              language                = sy-langu
              do_commit               = abap_false
              comment_semantic        = abap_false
              check_inbox_restriction = abap_true
            IMPORTING
              return_code             = lv_return_code
              att_id                  = ls_att_id
              doc_size                = ls_doc_size
            CHANGING
              message_lines           = lt_message_lines
              message_struct          = lt_message_struct
          ).
          map_messages_assoc_to_attach(
            EXPORTING
              cid          = <lfs_child_create>-%cid
              message      = lt_message_struct
            IMPORTING
              failed_added = lv_failed_added
            CHANGING
              failed       = failed-attachments
              reported     = reported-attachments
          ).
          IF lv_failed_added = abap_false.
            APPEND VALUE #( %cid = <lfs_child_create>-%cid
            workitemid = lv_workitem_id
            objectid = ls_att_id-doc_id
            ) TO mapped-attachments.
            APPEND VALUE #(
            wi_id = lv_workitem_id
            objectid = ls_att_id-doc_id
            file_extension = lt_att_header-file_extension
             ) TO zbp_gsp26sap02_myinbox=>gt_attachments_create.
            APPEND lv_workitem_id TO zbp_gsp26sap02_myinbox=>gt_wiids.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
  METHOD rba_Comments.
  ENDMETHOD.

  METHOD cba_Comments.
    DATA: lv_return_code    TYPE sy-subrc,
          lt_message_struct TYPE TABLE OF swr_mstruc,
          lt_message_lines  TYPE TABLE OF swr_messag,
          ls_att_id         TYPE swr_att_id,
          ls_doc_size       TYPE i,
          lv_comment_method TYPE swr_inbox_method
          .
    DATA(lo_wapi_wrapper) = zcl_fact_wf_myinbox=>create_instance( ).
    READ ENTITIES OF ZR_GSP26SAP02_MyInbox IN LOCAL MODE
          ENTITY MyInbox
          ALL FIELDS WITH CORRESPONDING #( entities_cba )
          RESULT DATA(lt_parent_data).

    LOOP AT entities_cba ASSIGNING FIELD-SYMBOL(<lfs_parent>).
      CLEAR lt_message_struct.
      DATA(lv_workitem_id) = <lfs_parent>-%key-WorkItemID.
      READ TABLE lt_parent_data INTO DATA(ls_db) WITH KEY id COMPONENTS %tky = <lfs_parent>-%tky.
      IF sy-subrc <> 0.
        APPEND VALUE #( msgty = 'E'
                        msgid = 'ZGSP26SAP02_MYINBOX'
                        msgno = '001'
                        msgv1 = lv_workitem_id ) TO lt_message_struct.
      ENDIF.
      map_messages(
        EXPORTING
          cid          = <lfs_parent>-%cid_ref
          workitem_id  = lv_workitem_id
          message      = lt_message_struct
        IMPORTING
          failed_added = DATA(lv_failed_added)
        CHANGING
          failed       = failed-myinbox
          reported     = reported-myinbox
      ).
      IF lv_failed_added = abap_true.
        LOOP AT <lfs_parent>-%target ASSIGNING FIELD-SYMBOL(<lfs_child>).
          map_messages_assoc_to_comment(
            EXPORTING
              cid          = <lfs_child>-%cid
              is_dependend = abap_true
              message      = lt_message_struct
            CHANGING
              failed       = failed-comments
              reported     = reported-comments
          ).
        ENDLOOP.
      ELSE.

        LOOP AT <lfs_parent>-%target ASSIGNING FIELD-SYMBOL(<lfs_child_create>).

          DATA(lv_note) = <lfs_child_create>-%data-Note.
          CLEAR: lv_return_code, ls_att_id, ls_doc_size, lt_message_struct, lt_message_lines.
          IF lv_note IS INITIAL.
            APPEND VALUE #( msgty = 'E'
                            msgid = 'ZGSP26SAP02_MYINBOX'
                            msgno = '007'
                            msgv1 = lv_workitem_id ) TO lt_message_struct.
          ELSE.
            IF ls_db-TaskID EQ lc_task_id-user_decision.
              lv_comment_method = '01'. " Default comment method
            ENDIF.
            lo_wapi_wrapper->add_note(
              EXPORTING
                workitem_id             = lv_workitem_id
                att_txt                 = lv_note
                document_owner          = sy-uname
                language                = sy-langu
                do_commit               = abap_false
                comment_semantic        = abap_true
                comment_method          = lv_comment_method
                check_inbox_restriction = abap_true
              IMPORTING
                return_code             = lv_return_code
                att_id                  = ls_att_id
                doc_size                = ls_doc_size
              CHANGING
                message_lines           = lt_message_lines
                message_struct          = lt_message_struct
            ).
            map_messages_assoc_to_comment(
              EXPORTING
                cid          = <lfs_child_create>-%cid
                message      = lt_message_struct
              IMPORTING
                failed_added = lv_failed_added
              CHANGING
                failed       = failed-comments
                reported     = reported-comments
            ).
            IF lv_failed_added = abap_false.
              APPEND lv_workitem_id TO zbp_gsp26sap02_myinbox=>gt_wiids.
              APPEND VALUE #( %cid = <lfs_child_create>-%cid
              workitemid = lv_workitem_id
              objectid = ls_att_id-doc_id
              ) TO mapped-comments.
            ENDIF.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD bulkDelegation.
    DATA: lv_return_code    TYPE sysubrc,
          lv_new_status     TYPE swr_wistat,
          lt_message_struct TYPE TABLE OF swr_mstruc,
          lt_message_lines  TYPE TABLE OF swr_messag
          .
    DATA: lt_recipients TYPE /iwngw/if_notif_provider=>ty_t_notification_recipient,
          lt_parameters TYPE /iwngw/if_notif_provider=>ty_t_notification_parameter.

    DATA(lo_wapi_wrapper) = zcl_fact_wf_myinbox=>create_instance( ).

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<lfs_key>).
      CLEAR: lv_return_code, lt_message_struct, lt_message_lines.

      DATA(lv_user_id) = <lfs_key>-%param-user_id.
      DATA(lt_workitems) = <lfs_key>-%param-_workitems.
      LOOP AT lt_workitems INTO DATA(ls_workitem).
        lo_wapi_wrapper->forward(
          EXPORTING
            workitem_id             = ls_workitem-WorkItemID
            user_id                 = lv_user_id
            language                = sy-langu
            do_commit               = abap_false
            current_user            = sy-uname
            check_inbox_restriction = abap_true
          IMPORTING
            return_code             = lv_return_code
            new_status              = lv_new_status
          CHANGING
            message_lines           = lt_message_lines
            message_struct          = lt_message_struct
        ).
        map_messages(
          EXPORTING
            cid          = <lfs_key>-%cid_ref
            workitem_id  = <lfs_key>-WorkItemID
            message      = lt_message_struct
          IMPORTING
            failed_added = DATA(lv_failed_added)
          CHANGING
            failed       = failed-myinbox
            reported     = reported-myinbox
        ).
        IF lv_failed_added = abap_false.
          APPEND VALUE #( %tky = <lfs_key>-%tky %param = CORRESPONDING #( <lfs_key> ) ) TO result.
          APPEND ls_workitem-WorkItemID TO zbp_gsp26sap02_myinbox=>gt_wiids.
          CLEAR: lt_recipients, lt_parameters.

          zcl_gsp26_noti_after_action=>build_forward_data(
            EXPORTING
              iv_workitem_id = ls_workitem-WorkItemID
              iv_sender      = sy-uname
              iv_receiver    = lv_user_id
            IMPORTING
              et_recipients  = lt_recipients
              et_parameters  = lt_parameters
          ).

          DATA(lv_wiid_str) = |{ ls_workitem-WorkItemID ALPHA = OUT }|.
          CONDENSE lv_wiid_str NO-GAPS.
          DATA(lv_target_action) = |display&/tasks/{ lv_wiid_str }/TwoColumnsMidExpanded|.

          zcl_gsp26_noti_after_action=>push_notification_generic(
            iv_notif_type = zcl_gsp26_noti_after_action=>gc_notif_forward
            it_recipients = lt_recipients
            it_parameters = lt_parameters
            iv_target_obj = 'ZWorkflow'
            iv_target_act = lv_target_action
          ).
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD map_messages.
    failed_added = abap_false.
    LOOP AT message INTO DATA(ls_message).
      IF    ls_message-msgty = lc_msg_type-error OR ls_message-msgty = lc_msg_type-abort.
        APPEND VALUE #(
          %cid        = cid
          workitemid  = workitem_id
          %fail-cause = zcl_myinbox_aux=>get_cause_from_message(
                          msgid = ls_message-msgid
                          msgno = ls_message-msgno
*                        is_dependend = abap_false
                           ) ) TO failed.
        failed_added = abap_true.
      ENDIF.
      APPEND VALUE #(
        %cid = cid
        %msg = new_message(
                 id       = ls_message-msgid
                 number   = ls_message-msgno
                 v1       = ls_message-msgv1
                 v2       = ls_message-msgv2
                 v3       = ls_message-msgv3
                 v4       = ls_message-msgv4
                 severity = COND #(
                   WHEN ls_message-msgty = lc_msg_type-error   THEN if_abap_behv_message=>severity-error
                   WHEN ls_message-msgty = lc_msg_type-abort   THEN if_abap_behv_message=>severity-error
                   WHEN ls_message-msgty = lc_msg_type-warning THEN if_abap_behv_message=>severity-warning
                   WHEN ls_message-msgty = lc_msg_type-success THEN if_abap_behv_message=>severity-success
                   WHEN ls_message-msgty = lc_msg_type-info    THEN if_abap_behv_message=>severity-information
                   ELSE if_abap_behv_message=>severity-information ) ) ) TO reported.
    ENDLOOP.
  ENDMETHOD.
  METHOD map_messages_assoc_to_attach.
    ASSERT cid IS NOT INITIAL. " In a create case, the %cid has to be present
    failed_added = abap_false.
    LOOP AT message INTO DATA(ls_message).
      IF    ls_message-msgty = lc_msg_type-error OR ls_message-msgty = lc_msg_type-abort.
        APPEND VALUE #(
          %cid        = cid
          %fail-cause = zcl_myinbox_aux=>get_cause_from_message(
                          msgid        = ls_message-msgid
                          msgno        = ls_message-msgno
                          is_dependend = is_dependend ) ) TO failed.
        failed_added = abap_true.
      ENDIF.
      APPEND VALUE #(
        %cid = cid
        %msg = new_message(
                 id       = ls_message-msgid
                 number   = ls_message-msgno
                 v1       = ls_message-msgv1
                 v2       = ls_message-msgv2
                 v3       = ls_message-msgv3
                 v4       = ls_message-msgv4
                 severity = COND #(
                   WHEN ls_message-msgty = lc_msg_type-error   THEN if_abap_behv_message=>severity-error
                   WHEN ls_message-msgty = lc_msg_type-abort   THEN if_abap_behv_message=>severity-error
                   WHEN ls_message-msgty = lc_msg_type-warning THEN if_abap_behv_message=>severity-warning
                   ELSE if_abap_behv_message=>severity-information ) ) ) TO reported.
    ENDLOOP.
  ENDMETHOD.

  METHOD map_messages_assoc_to_comment.
    ASSERT cid IS NOT INITIAL. " In a create case, the %cid has to be present
    failed_added = abap_false.
    LOOP AT message INTO DATA(ls_message).
      IF    ls_message-msgty = lc_msg_type-error OR ls_message-msgty = lc_msg_type-abort.
        APPEND VALUE #(
          %cid        = cid
          %fail-cause = zcl_myinbox_aux=>get_cause_from_message(
                          msgid        = ls_message-msgid
                          msgno        = ls_message-msgno
                          is_dependend = is_dependend ) ) TO failed.
        failed_added = abap_true.
      ENDIF.
      APPEND VALUE #(
        %cid = cid
        %msg = new_message(
                 id       = ls_message-msgid
                 number   = ls_message-msgno
                 v1       = ls_message-msgv1
                 v2       = ls_message-msgv2
                 v3       = ls_message-msgv3
                 v4       = ls_message-msgv4
                 severity = COND #(
                   WHEN ls_message-msgty = lc_msg_type-error   THEN if_abap_behv_message=>severity-error
                   WHEN ls_message-msgty = lc_msg_type-abort   THEN if_abap_behv_message=>severity-error
                   WHEN ls_message-msgty = lc_msg_type-warning THEN if_abap_behv_message=>severity-warning
                   ELSE if_abap_behv_message=>severity-information ) ) ) TO reported.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
