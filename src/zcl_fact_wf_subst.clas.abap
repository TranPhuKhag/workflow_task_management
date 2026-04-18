CLASS zcl_fact_wf_subst DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE .

  PUBLIC SECTION.
    CLASS-METHODS create_instance
      RETURNING
        VALUE(ro_wrapper) TYPE REF TO zif_wrap_wf_subst.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_fact_wf_subst IMPLEMENTATION.
  METHOD create_instance.
    ro_wrapper = NEW zcl_wrap_wf_subst( ).
  ENDMETHOD.
ENDCLASS.
