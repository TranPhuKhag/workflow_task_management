CLASS lhc_Attachments DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Attachments RESULT result.

    "! Deletes workflow attachments from a work item.
    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE Attachments.

    METHODS read FOR READ
      IMPORTING keys FOR READ Attachments RESULT result.

    METHODS rba_Myinbox FOR READ
      IMPORTING keys_rba FOR READ Attachments\_Myinbox FULL result_requested RESULT result LINK association_links.
    TYPES: tt_failed     TYPE TABLE FOR FAILED EARLY zr_gsp26sap02_myinbox\\attachments,
           tt_reported   TYPE TABLE FOR REPORTED EARLY zr_gsp26sap02_myinbox\\attachments,
           tt_swr_mstruc TYPE TABLE OF swr_mstruc.

    METHODS map_messages
      IMPORTING
        cid          TYPE abp_behv_cid OPTIONAL
        workitem_id  TYPE sww_wiid OPTIONAL
        object_id    TYPE zi_gsp26sap02_wf_attachment-objectid OPTIONAL
        messages     TYPE tt_swr_mstruc
      EXPORTING
        failed_added TYPE abap_boolean
      CHANGING
        failed       TYPE tt_failed
        reported     TYPE tt_reported.

ENDCLASS.

CLASS lhc_Attachments IMPLEMENTATION.

  METHOD get_instance_features.
    READ ENTITIES OF ZR_GSP26SAP02_MyInbox IN LOCAL MODE
    ENTITY Attachments
    FIELDS ( WorkItemID OwnerName )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_attachments)
    FAILED failed.

    result = VALUE #( FOR ls_attachment IN lt_attachments
    ( %tky = ls_attachment-%tky
      %features-%delete = COND #( WHEN    ls_attachment-ownername = sy-uname
                                          THEN if_abap_behv=>fc-o-enabled
                                          ELSE if_abap_behv=>fc-o-disabled ) ) )
    .
  ENDMETHOD.

  METHOD delete.
    DATA: lv_workitem_id    TYPE sww_wiid,
          lv_att_id         TYPE swr_att_id,
          lv_return_code    TYPE sysubrc,
          lt_message_struct TYPE TABLE OF swr_mstruc,
          lt_message_lines  TYPE TABLE OF swr_messag
          .
    DATA(lo_wapi_wrapper) = zcl_fact_wf_myinbox=>create_instance( ).
    LOOP AT keys INTO DATA(ls_key).
      CLEAR: lv_return_code, lt_message_struct, lt_message_lines.
      lv_workitem_id = ls_key-WorkItemID.
      lv_att_id-doc_cat = 'SO'.
      lv_att_id-doc_id = ls_key-ObjectID.
      lo_wapi_wrapper->delete_attachment(
        EXPORTING
          workitem_id             = lv_workitem_id
          att_id                  = lv_att_id
          language                = sy-langu
          do_commit               = abap_false
          delete_document         = abap_true
          check_inbox_restriction = abap_true
          check_constraints       = abap_true
        IMPORTING
          return_code             = lv_return_code
        CHANGING
          message_lines           = lt_message_lines
          message_struct          = lt_message_struct
      ).

      map_messages(
        EXPORTING
          cid          = ls_key-%cid_ref
          workitem_id  = lv_workitem_id
          object_id    = ls_key-ObjectID
          messages     = lt_message_struct
        IMPORTING
          failed_added = DATA(failed_added)
        CHANGING
          failed       = failed-attachments
          reported     = reported-attachments
      ).
      IF failed_added = abap_false.
        APPEND lv_workitem_id TO zbp_gsp26sap02_myinbox=>gt_wiids.
        APPEND VALUE #(
    wi_id    = lv_workitem_id
    objectid = ls_key-objectid
) TO zbp_gsp26sap02_attachment=>gt_attachments_delete.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD read.
    IF keys IS INITIAL.
      RETURN.
    ENDIF.
    SELECT
        FROM ZI_GSP26SAP02_WF_Attachment
        FIELDS WorkItemID, ObjectID, OwnerName
        FOR ALL ENTRIES IN @keys
        WHERE WorkItemID = @keys-WorkItemID
        INTO CORRESPONDING FIELDS OF TABLE @result.
  ENDMETHOD.

  METHOD rba_Myinbox.
  ENDMETHOD.


  METHOD map_messages.
    failed_added = abap_false.
    LOOP AT messages INTO DATA(ls_message).
      IF ls_message-msgty = 'E' OR ls_message-msgty = 'A'.
        APPEND VALUE #( %cid = cid
        WorkItemID = workitem_id
        ObjectID = object_id
%fail-cause = zcl_myinbox_aux=>get_cause_from_message(
                                                    msgid        = ls_message-msgid
                                                    msgno        = ls_message-msgno
*                                                is_dependent = abap_false
                                                  ) ) TO failed.

        failed_added = abap_true.
      ENDIF.
      APPEND VALUE #(    %cid = cid  %msg = new_message(
                                                  id = ls_message-msgid
                                                  number = ls_message-msgno
                                                  severity = if_abap_behv_message=>severity-error
                                                  v1 = ls_message-msgv1
                                                  v2 = ls_message-msgv2
                                                  v3 = ls_message-msgv3
                                                  v4 = ls_message-msgv4
                                                   ) ) TO reported.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
