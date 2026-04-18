CLASS zcl_wrap_wf_myinbox DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE
  GLOBAL FRIENDS zcl_fact_wf_myinbox.

  PUBLIC SECTION.
    INTERFACES zif_wrap_wf_myinbox.
    ALIASES: tt_message_lines FOR zif_wrap_wf_myinbox~tt_message_lines,
             tt_message_struct FOR zif_wrap_wf_myinbox~tt_message_struct,
             tt_simple_container  FOR zif_wrap_wf_myinbox~tt_simple_container,
             tt_user_ids FOR zif_wrap_wf_myinbox~tt_user_ids
             .
  PROTECTED SECTION.
  PRIVATE SECTION.
    CONSTANTS:
      BEGIN OF lc_container,
        decision      TYPE string VALUE 'Decision' ##NO_TEXT,
        decision_note TYPE string VALUE 'DECISION_NOTE' ##NO_TEXT,
      END OF lc_container,
      BEGIN OF lc_decision,
        released TYPE string VALUE 'RELEASED' ##NO_TEXT,
        rejected TYPE string VALUE 'REJECTED' ##NO_TEXT,
      END OF lc_decision,
      lc_objtype_sofm TYPE swo_objtyp VALUE 'SOFM' ##NO_TEXT.

    METHODS sap_wapi_workitem_complete
      IMPORTING
        !workitem_id               TYPE sww_wiid
        !actual_agent              TYPE syuname DEFAULT sy-uname
        !language                  TYPE sylangu DEFAULT sy-langu
        !set_obsolet               TYPE xfeld DEFAULT space
        !do_commit                 TYPE xfeld DEFAULT 'X'
        !do_callback_in_background TYPE xfeld DEFAULT 'X'
        !ifs_xml_container         TYPE xstring OPTIONAL
        !check_inbox_restriction   TYPE xfeld DEFAULT space
      EXPORTING
        !new_status                TYPE sww_wistat
        !return_code               TYPE syst_subrc
      CHANGING
        !message_lines             TYPE tt_message_lines OPTIONAL
        !message_struct            TYPE tt_message_struct OPTIONAL
        !simple_container          TYPE tt_simple_container OPTIONAL
      .
    METHODS sap_wapi_decision_complete
      IMPORTING
        !check_inbox_restriction   TYPE xfeld DEFAULT space
        !decision_key              TYPE swr_decikey
        !decision_note             TYPE swrsobjid OPTIONAL
        !decision_reason           TYPE swf_flex_decision_reason_id OPTIONAL
        !do_callback_in_background TYPE xfeld DEFAULT 'X'
        !do_commit                 TYPE xfeld DEFAULT 'X'
        !language                  TYPE sww_lang DEFAULT sy-langu
        !user                      TYPE syuname DEFAULT sy-uname
        !workitem_id               TYPE sww_wiid
      EXPORTING
        !new_status                TYPE sww_wistat
        !return_code               TYPE syst_subrc
      CHANGING
        !message_lines             TYPE tt_message_lines OPTIONAL
        !message_struct            TYPE tt_message_struct OPTIONAL
      .

    METHODS sap_wapi_forward_workitem
      IMPORTING
        !workitem_id             TYPE sww_wiid
        !user_id                 TYPE syuname OPTIONAL
        !language                TYPE sy-langu DEFAULT sy-langu
        !do_commit               TYPE xfeld DEFAULT abap_false
        !current_user            TYPE syuname DEFAULT sy-uname
        !check_inbox_restriction TYPE xfeld DEFAULT space
      EXPORTING
        !return_code             TYPE syst_subrc
        !new_status              TYPE swr_wistat
      CHANGING
        !message_lines           TYPE tt_message_lines OPTIONAL
        !message_struct          TYPE tt_message_struct OPTIONAL
        !user_ids                TYPE tt_user_ids OPTIONAL
      .
    METHODS sap_wapi_attachment_add
      IMPORTING
        !workitem_id             TYPE sww_wiid
        !att_header              TYPE swr_att_header OPTIONAL
        !att_txt                 TYPE string OPTIONAL
        !att_bin                 TYPE xstring OPTIONAL
        !document_owner          TYPE syuname DEFAULT sy-uname
        !language                TYPE sylangu DEFAULT sy-langu
        !do_commit               TYPE xfeld DEFAULT space
        !comment_semantic        TYPE xfeld DEFAULT space
        !comment_method          TYPE swr_inbox_method OPTIONAL
        !check_inbox_restriction TYPE xfeld DEFAULT space
      EXPORTING
        !return_code             TYPE syst_subrc
        !att_id                  TYPE swr_att_id
        !doc_size                TYPE i
      CHANGING
        !message_lines           TYPE tt_message_lines OPTIONAL
        !message_struct          TYPE tt_message_struct OPTIONAL
      .
    METHODS sap_wapi_attachment_delete
      IMPORTING
        !workitem_id             TYPE sww_wiid
        !att_id                  TYPE swr_att_id
        !language                TYPE sylangu DEFAULT sy-langu
        !do_commit               TYPE xfeld DEFAULT 'X'
        !delete_document         TYPE xfeld DEFAULT space
        !check_inbox_restriction TYPE xfeld DEFAULT space
        !check_constraints       TYPE xfeld DEFAULT 'X'
      EXPORTING
        !return_code             TYPE syst_subrc
      CHANGING
        !message_lines           TYPE tt_message_lines OPTIONAL
        !message_struct          TYPE tt_message_struct OPTIONAL
      .

ENDCLASS.

CLASS zcl_wrap_wf_myinbox IMPLEMENTATION.
  METHOD zif_wrap_wf_myinbox~complete_workitem.
    APPEND VALUE #( element = lc_container-decision   value = COND #( WHEN is_approval EQ abap_true THEN lc_decision-released ELSE lc_decision-rejected ) ) TO simple_container.
    IF att_txt IS NOT INITIAL.
      me->sap_wapi_attachment_add(
        EXPORTING
          workitem_id             = workitem_id
          att_header              = att_header
          att_txt                 = att_txt
          att_bin                 = att_bin
          document_owner          = document_owner
          language                = language
          do_commit               = do_commit
          comment_semantic        = comment_semantic
          comment_method          = comment_method
          check_inbox_restriction = check_inbox_restriction
        IMPORTING
          return_code             = return_code
          att_id                  = att_id
          doc_size                = doc_size
        CHANGING
          message_lines           = message_lines
          message_struct          = message_struct
      ).
      IF return_code <> 0.
        RETURN.
      ENDIF.
      DATA ls_attachment_objects TYPE swotobjid.
      DATA ls_decision_note TYPE swc_value.

      ls_attachment_objects-objkey = att_id-doc_id. " 'RELEASED'
      ls_attachment_objects-objtype = lc_objtype_sofm .
      ls_decision_note = CONV swc_value( Ls_attachment_objects ).
      APPEND VALUE #( element = lc_container-decision_note value = ls_decision_note ) TO simple_container.
    ENDIF.
    me->sap_wapi_workitem_complete(
      EXPORTING
        workitem_id               = workitem_id
        actual_agent              = actual_agent
        language                  = language
        set_obsolet               = set_obsolet
        do_commit                 = do_commit
        do_callback_in_background = do_callback_in_background
        ifs_xml_container         = ifs_xml_container
        check_inbox_restriction   = check_inbox_restriction
      IMPORTING
        new_status                = new_status
        return_code               = return_code
      CHANGING
        message_lines             = message_lines
        message_struct            = message_struct
        simple_container          = simple_container
    ).
  ENDMETHOD.
  METHOD zif_wrap_wf_myinbox~complete_decision.
    IF att_txt IS NOT INITIAL.
      me->sap_wapi_attachment_add(
        EXPORTING
          workitem_id             = workitem_id
          att_header              = att_header
          att_txt                 = att_txt
          att_bin                 = att_bin
          document_owner          = document_owner
          language                = language
          do_commit               = do_commit
          comment_semantic        = comment_semantic
          comment_method          = comment_method
          check_inbox_restriction = check_inbox_restriction
        IMPORTING
          return_code             = return_code
          att_id                  = att_id
          doc_size                = doc_size
        CHANGING
          message_lines           = message_lines
          message_struct          = message_struct
      ).
      IF return_code <> 0.
        RETURN.
      ENDIF.
      decision_note = att_id-doc_id .
    ENDIF.

    me->sap_wapi_decision_complete(
      EXPORTING
        check_inbox_restriction   = check_inbox_restriction
        decision_key              = decision_key
        decision_note             = decision_note
        decision_reason           = decision_reason
        do_callback_in_background = do_callback_in_background
        do_commit                 = do_commit
        language                  = language
        user                      = user
        workitem_id               = workitem_id
      IMPORTING
        new_status                = new_status
        return_code               = return_code
      CHANGING
        message_lines             = message_lines
        message_struct            = message_struct
    ).
  ENDMETHOD.
  METHOD zif_wrap_wf_myinbox~reserve.
    CALL FUNCTION 'SAP_WAPI_RESERVE_WORKITEM'
      EXPORTING
        workitem_id             = workitem_id
        actual_agent            = actual_agent
        language                = language
        do_commit               = do_commit
        check_inbox_restriction = check_inbox_restriction
      IMPORTING
        return_code             = return_code
        new_status              = new_status
      TABLES
        message_lines           = message_lines
        message_struct          = message_struct.
  ENDMETHOD.
  METHOD zif_wrap_wf_myinbox~release.
    CALL FUNCTION 'SAP_WAPI_PUT_BACK_WORKITEM'
      EXPORTING
        workitem_id             = workitem_id
        user                    = user_id
        language                = language
        do_commit               = do_commit
        check_inbox_restriction = check_inbox_restriction
      IMPORTING
        return_code             = return_code
        new_status              = new_status
      TABLES
        message_lines           = message_lines
        message_struct          = message_struct.
    .
  ENDMETHOD.
  METHOD zif_wrap_wf_myinbox~suspend.
    CALL FUNCTION 'SAP_WAPI_RESUBMIT_WORKITEM'
      EXPORTING
        workitem_id             = workitem_id
        user                    = user_id
        language                = language
        resubmission_date       = resubmission_date
        resubmission_time       = resubmission_time
        resubmission_zonlo      = resubmission_zonlo
        do_commit               = do_commit
        check_inbox_restriction = check_inbox_restriction
      IMPORTING
        return_code             = return_code
        new_status              = new_status
      TABLES
        message_lines           = message_lines
        message_struct          = message_struct.
  ENDMETHOD.
  METHOD zif_wrap_wf_myinbox~resubmission.
  CALL FUNCTION 'SAP_WAPI_END_RESUBMISSION'
    EXPORTING
      workitem_id    = workitem_id
      user           = user
      language       = language
      do_commit      = do_commit
    IMPORTING
      return_code    = return_code
      new_status     = new_status
    TABLES
      message_lines  = message_lines
      message_struct = message_struct
    .
  ENDMETHOD.
  METHOD zif_wrap_wf_myinbox~forward.
    IF att_txt IS NOT INITIAL.
      me->sap_wapi_attachment_add(
        EXPORTING
          workitem_id             = workitem_id
          att_header              = att_header
          att_txt                 = att_txt
          att_bin                 = att_bin
          document_owner          = document_owner
          language                = language
          do_commit               = do_commit
          comment_semantic        = comment_semantic
          comment_method          = comment_method
          check_inbox_restriction = check_inbox_restriction
        IMPORTING
          return_code             = return_code
          att_id                  = att_id
          doc_size                = doc_size
        CHANGING
          message_lines           = message_lines
          message_struct          = message_struct
      ).
      IF return_code <> 0.
        RETURN.
      ENDIF.
    ENDIF.
    me->sap_wapi_forward_workitem(
      EXPORTING
        workitem_id             = workitem_id
        user_id                 = user_id
        language                = language
        do_commit               = do_commit
        current_user            = current_user
        check_inbox_restriction = check_inbox_restriction
      IMPORTING
        return_code             = return_code
        new_status              = new_status
      CHANGING
        message_lines           = message_lines
        message_struct          = message_struct
        user_ids                = user_ids
    ).
  ENDMETHOD.
  METHOD zif_wrap_wf_myinbox~priority_change.
  CALL FUNCTION 'SAP_WAPI_CHANGE_WORKITEM_PRIO'
    EXPORTING
      workitem_id             = workitem_id
      priority                = priority
      language                = language
      do_commit               = do_commit
      check_inbox_restriction = check_inbox_restriction
    IMPORTING
      return_code             = return_code
    TABLES
      message_lines           = message_lines
      message_struct          = message_struct
    .
  ENDMETHOD.
  METHOD zif_wrap_wf_myinbox~add_attachment.
    me->sap_wapi_attachment_add(
      EXPORTING
        workitem_id             = workitem_id
        att_header              = att_header
        att_txt                 = att_txt
        att_bin                 = att_bin
        document_owner          = document_owner
        language                = language
        do_commit               = do_commit
        comment_semantic        = comment_semantic
        comment_method          = comment_method
        check_inbox_restriction = check_inbox_restriction
      IMPORTING
        return_code             = return_code
        att_id                  = att_id
        doc_size                = doc_size
      CHANGING
        message_lines           = message_lines
        message_struct          = message_struct
    ).
  ENDMETHOD.
  METHOD zif_wrap_wf_myinbox~delete_attachment.
    me->sap_wapi_attachment_delete(
      EXPORTING
        workitem_id             = workitem_id
        att_id                  = att_id
        language                = language
        do_commit               = do_commit
        delete_document         = delete_document
        check_inbox_restriction = check_inbox_restriction
        check_constraints       = check_constraints
      IMPORTING
        return_code             = return_code
      CHANGING
        message_lines           = message_lines
        message_struct          = message_struct
    ).
  ENDMETHOD.
  METHOD zif_wrap_wf_myinbox~add_note.
    me->sap_wapi_attachment_add(
      EXPORTING
        workitem_id             = workitem_id
        att_header              = att_header
        att_txt                 = att_txt
        att_bin                 = att_bin
        document_owner          = document_owner
        language                = language
        do_commit               = do_commit
        comment_semantic        = comment_semantic
        comment_method          = comment_method
        check_inbox_restriction = check_inbox_restriction
      IMPORTING
        return_code             = return_code
        att_id                  = att_id
        doc_size                = doc_size
      CHANGING
        message_lines           = message_lines
        message_struct          = message_struct
    ).
  ENDMETHOD.
  METHOD sap_wapi_workitem_complete.
    CALL FUNCTION 'SAP_WAPI_WORKITEM_COMPLETE' DESTINATION 'NONE'
      EXPORTING
        workitem_id               = workitem_id
        actual_agent              = actual_agent
        language                  = language
        set_obsolet               = set_obsolet
        do_commit                 = do_commit
        do_callback_in_background = do_callback_in_background
        ifs_xml_container         = ifs_xml_container
        check_inbox_restriction   = check_inbox_restriction
      IMPORTING
        return_code               = return_code
        new_status                = new_status
      TABLES
        simple_container          = simple_container
        message_lines             = message_lines
        message_struct            = message_struct.
  ENDMETHOD.
  METHOD sap_wapi_forward_workitem.
    CALL FUNCTION 'SAP_WAPI_FORWARD_WORKITEM'
      EXPORTING
        workitem_id             = workitem_id
        user_id                 = user_id
        language                = language
        do_commit               = do_commit
        current_user            = current_user
        check_inbox_restriction = check_inbox_restriction
      IMPORTING
        return_code             = return_code
        new_status              = new_status
      TABLES
        message_lines           = message_lines
        message_struct          = message_struct
        user_ids                = user_ids.
  ENDMETHOD.
  METHOD sap_wapi_attachment_add.
    CALL FUNCTION 'SAP_WAPI_ATTACHMENT_ADD'
      EXPORTING
        workitem_id             = workitem_id
        att_header              = att_header
        att_txt                 = att_txt
        att_bin                 = att_bin
        document_owner          = document_owner
        language                = language
        do_commit               = space
        comment_semantic        = comment_semantic
        comment_method          = comment_method
        check_inbox_restriction = check_inbox_restriction
      IMPORTING
        return_code             = return_code
        att_id                  = att_id
        doc_size                = doc_size
      TABLES
        message_lines           = message_lines
        message_struct          = message_struct.
  ENDMETHOD.

  METHOD sap_wapi_decision_complete.
    CALL FUNCTION 'SAP_WAPI_DECISION_COMPLETE'
      EXPORTING
        check_inbox_restriction   = check_inbox_restriction
        decision_key              = decision_key
        decision_note             = decision_note
        decision_reason           = decision_reason
        do_callback_in_background = do_callback_in_background
        do_commit                 = do_commit
        language                  = language
        user                      = user
        workitem_id               = workitem_id
      IMPORTING
        new_status                = new_status
        return_code               = return_code
      TABLES
        message_lines             = message_lines
        message_struct            = message_struct.
  ENDMETHOD.

  METHOD sap_wapi_attachment_delete.
    CALL FUNCTION 'SAP_WAPI_ATTACHMENT_DELETE' DESTINATION 'NONE'
      EXPORTING
        workitem_id             = workitem_id
        att_id                  = att_id
        language                = language
        do_commit               = do_commit
        delete_document         = delete_document
        check_inbox_restriction = check_inbox_restriction
        check_constraints       = check_constraints
      IMPORTING
        return_code             = return_code
      TABLES
        message_lines           = message_lines
        message_struct          = message_struct.
  ENDMETHOD.
ENDCLASS.
