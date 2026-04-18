CLASS zcl_myinbox_aux DEFINITION
  PUBLIC
  INHERITING FROM cl_abap_behv
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CLASS-METHODS: get_cause_from_message
      IMPORTING
        msgid             TYPE symsgid
        msgno             TYPE symsgno
        is_dependend      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(fail_cause) TYPE if_abap_behv=>t_fail_cause.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.




CLASS zcl_myinbox_aux IMPLEMENTATION.
  METHOD get_cause_from_message.
    IF msgid = 'ZGSP26SAP02_MYINBOX'.
      CASE msgno.
        WHEN '001'. " Work item &1 not found or already deleted.
          fail_cause = if_abap_behv=>cause-not_found.
        WHEN '002'. " Resubmission date is required (Missing)
          fail_cause = if_abap_behv=>cause-unspecific.
        WHEN '003'. " Resubmission date/time cannot be in the past (Invalid)
          fail_cause = if_abap_behv=>cause-unspecific.
        WHEN OTHERS.
          fail_cause = if_abap_behv=>cause-unspecific.
          IF is_dependend = abap_true.
            fail_cause = if_abap_behv=>cause-dependency.
          ELSE.
            fail_cause = if_abap_behv=>cause-not_found.
          ENDIF.

      ENDCASE.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
