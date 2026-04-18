CLASS zbp_gsp26sap02_myinbox DEFINITION PUBLIC ABSTRACT FINAL FOR BEHAVIOR OF zr_gsp26sap02_myinbox.
  PUBLIC SECTION.
    TYPES: tt_wiids TYPE STANDARD TABLE OF sww_wiid WITH NON-UNIQUE DEFAULT KEY.
    CLASS-DATA: gt_wiids TYPE tt_wiids.
    TYPES: tt_attachments TYPE TABLE OF zgsp26_attachmen.
    CLASS-DATA: gt_attachments_create TYPE tt_attachments.
    TYPES: tt_swr_cont   TYPE STANDARD TABLE OF swr_cont WITH EMPTY KEY.
    TYPES: BEGIN OF ty_action_buffer,
             workitem_id             TYPE sww_wiid,
             actual_agent            TYPE syuname,
             language                TYPE sylangu,
             do_commit               TYPE xfeld,
             check_inbox_restriction TYPE xfeld,
             simple_container        TYPE swrtcont,
             is_approval               TYPE xfeld,
           END OF ty_action_buffer.
    CLASS-DATA: gt_action_complete TYPE TABLE OF ty_action_buffer WITH EMPTY KEY.

  PRIVATE SECTION.
ENDCLASS.

CLASS zbp_gsp26sap02_myinbox IMPLEMENTATION.
ENDCLASS.
