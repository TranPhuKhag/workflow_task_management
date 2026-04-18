"! Factory class for workflow MyInbox wrapper creation.
"! Centralizes instantiation of the wrapper implementation
"! behind interface ZIF_WRAP_WF_MYINBOX.
CLASS zcl_fact_wf_myinbox DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE.

  PUBLIC SECTION.
    "! Creates and returns a wrapper instance for workflow MyInbox actions.
    "! @parameter ro_wrapper | Reference to the wrapper interface implementation.
    CLASS-METHODS create_instance
      RETURNING
        VALUE(ro_wrapper) TYPE REF TO zif_wrap_wf_myinbox
      .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_fact_wf_myinbox IMPLEMENTATION.
  METHOD create_instance.
    ro_wrapper = NEW zcl_wrap_wf_myinbox( ).
  ENDMETHOD.
ENDCLASS.
