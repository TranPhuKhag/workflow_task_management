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
    IF msgid = 'Z_GSP26_MSG'.
      CASE msgno.
        WHEN '003'. " Work item &1 not found or already deleted.
          fail_cause = if_abap_behv=>cause-not_found.
        WHEN '004'. " Resubmission date/time is required (Missing)
          fail_cause = if_abap_behv=>cause-unspecific.
        WHEN '005'. " Resubmission date/time cannot be in the past (Invalid)
          fail_cause = if_abap_behv=>cause-unspecific.
        WHEN '006'. "Cannot forward to yourself
          fail_cause = if_abap_behv=>cause-conflict.
        WHEN '007'." Work Item &1: Only 'Selected' or 'Started' status allowed for Delegation .
          fail_cause = if_abap_behv=>cause-conflict.
        WHEN '008'. "Cannot delegation to yourself
          fail_cause = if_abap_behv=>cause-conflict.
        WHEN '009'. " Comment cannot be empty
          fail_cause = if_abap_behv=>cause-not_found.

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
