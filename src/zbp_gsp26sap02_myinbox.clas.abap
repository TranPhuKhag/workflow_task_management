CLASS zbp_gsp26sap02_myinbox DEFINITION PUBLIC ABSTRACT FINAL FOR BEHAVIOR OF zr_gsp26sap02_myinbox.
  PUBLIC SECTION.
    TYPES: tt_wiids TYPE SORTED TABLE OF sww_wiid WITH UNIQUE KEY table_line.
    CLASS-DATA: gt_wiids TYPE tt_wiids.
    TYPES: tt_attachments TYPE TABLE OF zgsp26_attachmen.
    CLASS-DATA: gt_attachments_create TYPE tt_attachments.
    TYPES: tt_swr_cont   TYPE STANDARD TABLE OF swr_cont WITH EMPTY KEY.


  PRIVATE SECTION.
ENDCLASS.

CLASS zbp_gsp26sap02_myinbox IMPLEMENTATION.
ENDCLASS.
