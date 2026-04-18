CLASS lhc_Comments DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS read FOR READ
      IMPORTING keys FOR READ Comments RESULT result.

    METHODS rba_Myinbox FOR READ
      IMPORTING keys_rba FOR READ Comments\_Myinbox FULL result_requested RESULT result LINK association_links.

ENDCLASS.

CLASS lhc_Comments IMPLEMENTATION.

  METHOD read.
  ENDMETHOD.

  METHOD rba_Myinbox.
  ENDMETHOD.

ENDCLASS.
