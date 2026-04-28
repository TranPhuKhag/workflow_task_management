INTERFACE zif_wrap_wf_subst
  PUBLIC .

  TYPES: tt_message_lines  TYPE TABLE OF swr_messag,
         tt_message_struct TYPE TABLE OF swr_mstruc,
         tt_substitutes    TYPE TABLE OF swragent.

  METHODS maintain_substitute
    IMPORTING
      !substituted_object TYPE swragent
      !substitute         TYPE swragent
      !subst_begin        TYPE swr_substbegin
      !subst_end          TYPE swr_substend
      !subst_profile      TYPE swr_substprof OPTIONAL
      !subst_active       TYPE swr_substactive DEFAULT abap_true
    EXPORTING
      !return_code        TYPE sysubrc
    CHANGING
      !message_lines      TYPE tt_message_lines OPTIONAL
      !message_struct     TYPE tt_message_struct OPTIONAL.

  METHODS delete_substitute
    IMPORTING
      !substituted_object TYPE swragent
      !start_date         TYPE swr_substbegin
      !end_date           TYPE swr_substend
    EXPORTING
      !return_code        TYPE sysubrc
    CHANGING
      !substitutes        TYPE tt_substitutes
      !message_lines      TYPE tt_message_lines OPTIONAL.

  METHODS lock_substitute
    IMPORTING
      !us_name     TYPE hrus_d2-us_name
      !rep_name    TYPE hrus_d2-rep_name
      !begda       TYPE hrus_d2-begda
    EXPORTING
      !return_code TYPE sysubrc
      !error_text  TYPE string.

  METHODS toggle_substitute
    IMPORTING
      !iv_user_for TYPE xubname
      !iv_user_by  TYPE xubname
      !iv_active   TYPE xfeld
    EXPORTING
      !ev_subrc    TYPE sysubrc
      !ev_message  TYPE string.

ENDINTERFACE.
