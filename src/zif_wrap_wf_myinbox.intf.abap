INTERFACE zif_wrap_wf_myinbox
  PUBLIC .
  TYPES: tt_message_lines    TYPE STANDARD TABLE OF swr_messag WITH DEFAULT KEY,
         tt_message_struct   TYPE STANDARD TABLE OF swr_mstruc WITH DEFAULT KEY,
         tt_simple_container TYPE STANDARD TABLE OF swr_cont,
         tt_wi_ids           TYPE TABLE FOR HIERARCHY zd_wf_wi_id,
         tt_user_ids         TYPE STANDARD TABLE OF swragent.
  "! Approve/Reject a work item Task
  METHODS complete_workitem
    IMPORTING
      !is_approval               TYPE xfeld DEFAULT 'X'
      !workitem_id               TYPE sww_wiid
      !att_header                TYPE swr_att_header OPTIONAL
      !att_txt                   TYPE string OPTIONAL
      !att_bin                   TYPE xstring OPTIONAL
      !document_owner            TYPE syuname DEFAULT sy-uname
      !actual_agent              TYPE syuname DEFAULT sy-uname
      !language                  TYPE sy-langu DEFAULT sy-langu
      !set_obsolet               TYPE xfeld DEFAULT space
      !do_commit                 TYPE xfeld DEFAULT 'X'
      !do_callback_in_background TYPE xfeld DEFAULT 'X'
      !ifs_xml_container         TYPE xstring OPTIONAL
      !comment_semantic          TYPE xfeld DEFAULT space
      !comment_method            TYPE swr_inbox_method OPTIONAL
      !check_inbox_restriction   TYPE xfeld  DEFAULT ' '
    EXPORTING
      !return_code               TYPE sysubrc
      !new_status                TYPE sww_wistat
      !att_id                    TYPE swr_att_id
      !doc_size                  TYPE i
    CHANGING
      !simple_container          TYPE tt_simple_container OPTIONAL
      !message_lines             TYPE tt_message_lines OPTIONAL
      !message_struct            TYPE tt_message_struct OPTIONAL
    .
  "! Decision Complete a work item (User Decision)
  METHODS complete_decision
    IMPORTING
      !check_inbox_restriction   TYPE xfeld DEFAULT space
      !decision_key              TYPE swr_decikey
      !decision_reason           TYPE swf_flex_decision_reason_id OPTIONAL
      !do_callback_in_background TYPE xfeld DEFAULT 'X'
      !do_commit                 TYPE xfeld DEFAULT 'X'
      !language                  TYPE sww_lang DEFAULT sy-langu
      !user                      TYPE syuname DEFAULT sy-uname
      !workitem_id               TYPE sww_wiid
      !att_header                TYPE swr_att_header OPTIONAL
      !att_txt                   TYPE string OPTIONAL
      !att_bin                   TYPE xstring OPTIONAL
      !document_owner            TYPE syuname DEFAULT sy-uname
      !comment_semantic          TYPE xfeld DEFAULT space
      !comment_method            TYPE swr_inbox_method OPTIONAL
    EXPORTING
      !new_status                TYPE sww_wistat
      !return_code               TYPE syst_subrc
      !att_id                    TYPE swr_att_id
      !doc_size                  TYPE i
    CHANGING
      !decision_note             TYPE swrsobjid OPTIONAL
      !message_lines             TYPE tt_message_lines OPTIONAL
      !message_struct            TYPE tt_message_struct OPTIONAL
    .
  "! Claim a work item
  METHODS reserve
    IMPORTING
      !workitem_id             TYPE sww_wiid
      !actual_agent            TYPE syuname DEFAULT sy-uname
      !language                TYPE sy-langu DEFAULT sy-langu
      !do_commit               TYPE abap_bool DEFAULT abap_false
      !check_inbox_restriction TYPE abap_bool DEFAULT abap_true
    EXPORTING
      !return_code             TYPE sysubrc
      !new_status              TYPE swr_wistat
    CHANGING
      !message_lines           TYPE tt_message_lines OPTIONAL
      !message_struct          TYPE tt_message_struct OPTIONAL
    .
  "! Release a work item
  METHODS release
    IMPORTING
      !workitem_id             TYPE sww_wiid
      !user_id                 TYPE syuname OPTIONAL
      !language                TYPE sy-langu DEFAULT sy-langu
      !do_commit               TYPE abap_bool DEFAULT abap_false
      !check_inbox_restriction TYPE abap_bool DEFAULT abap_true
    EXPORTING
      !return_code             TYPE sysubrc
      !new_status              TYPE swr_wistat
    CHANGING
      !message_lines           TYPE tt_message_lines OPTIONAL
      !message_struct          TYPE tt_message_struct OPTIONAL
    .
  "!Suspend a work item
  METHODS suspend
    IMPORTING
      !workitem_id             TYPE sww_wiid
      !user_id                 TYPE syuname OPTIONAL
      !language                TYPE sy-langu DEFAULT sy-langu
      !resubmission_date       TYPE sy-datum
      !resubmission_time       TYPE sy-uzeit
      !resubmission_zonlo      TYPE tznzone DEFAULT sy-zonlo
      !do_commit               TYPE abap_bool DEFAULT abap_false
      !check_inbox_restriction TYPE abap_bool DEFAULT abap_true
    EXPORTING
      !return_code             TYPE sysubrc
      !new_status              TYPE swr_wistat
    CHANGING
      !message_lines           TYPE tt_message_lines OPTIONAL
      !message_struct          TYPE tt_message_struct OPTIONAL
    .
  "! End Resubmission of Work Item
  METHODS reSubmission
    IMPORTING
      !workitem_id    TYPE sww_wiid
      !do_commit      TYPE xfeld DEFAULT 'X'
      !user           TYPE syuname DEFAULT sy-uname
      !language       TYPE sy-langu DEFAULT sy-langu
    EXPORTING
      !new_status     type swr_wistat
      !return_code    TYPE sysubrc
    CHANGING
      !message_lines  TYPE tt_message_lines OPTIONAL
      !message_struct TYPE tt_message_struct OPTIONAL.

  "! Forward a work item to another user
  METHODS forward
    IMPORTING
      !workitem_id             TYPE sww_wiid
      !user_id                 TYPE syuname OPTIONAL
      !language                TYPE sy-langu DEFAULT sy-langu
      !do_commit               TYPE xfeld DEFAULT abap_false
      !current_user            TYPE syuname DEFAULT sy-uname
      !check_inbox_restriction TYPE xfeld DEFAULT space
      !att_header              TYPE swr_att_header OPTIONAL
      !att_txt                 TYPE string OPTIONAL
      !att_bin                 TYPE xstring OPTIONAL
      !document_owner          TYPE syuname DEFAULT sy-uname
      !comment_semantic        TYPE xfeld DEFAULT space
      !comment_method          TYPE swr_inbox_method OPTIONAL
    EXPORTING
      !return_code             TYPE syst_subrc
      !new_status              TYPE swr_wistat
      !att_id                  TYPE swr_att_id
      !doc_size                TYPE i
    CHANGING
      !message_lines           TYPE tt_message_lines OPTIONAL
      !message_struct          TYPE tt_message_struct OPTIONAL
      !user_ids                TYPE tt_user_ids OPTIONAL
    .

  METHODS priority_change
    IMPORTING
      !workitem_id             TYPE sww_wiid
      !priority                TYPE sww_prio
      !language                TYPE sy-langu DEFAULT sy-langu
      !do_commit               TYPE xfeld DEFAULT 'X'
      !check_inbox_restriction TYPE abap_bool DEFAULT abap_true
    EXPORTING
      !return_code             TYPE sysubrc
    CHANGING
      !message_lines           TYPE tt_message_lines OPTIONAL
      !message_struct          TYPE tt_message_struct OPTIONAL
    .
  METHODS add_attachment
    IMPORTING
      !workitem_id             TYPE sww_wiid
      !att_header              TYPE swr_att_header OPTIONAL
      !att_txt                 TYPE string OPTIONAL
      !att_bin                 TYPE xstring OPTIONAL
      !document_owner          TYPE syuname DEFAULT sy-uname
      !language                TYPE sylangu DEFAULT sy-langu
      !do_commit               TYPE xfeld DEFAULT 'X'
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
  METHODS delete_attachment
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
  METHODS add_note
    IMPORTING
      !workitem_id             TYPE sww_wiid
      !att_header              TYPE swr_att_header OPTIONAL
      !att_txt                 TYPE string OPTIONAL
      !att_bin                 TYPE xstring OPTIONAL
      !document_owner          TYPE syuname DEFAULT sy-uname
      !language                TYPE sylangu DEFAULT sy-langu
      !do_commit               TYPE xfeld DEFAULT 'X'
      !comment_semantic        TYPE xfeld DEFAULT 'X'
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
ENDINTERFACE.
