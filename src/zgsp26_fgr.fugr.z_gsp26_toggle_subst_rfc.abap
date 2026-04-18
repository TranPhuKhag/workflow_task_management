FUNCTION Z_GSP26_TOGGLE_SUBST_RFC.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_USER_FOR) TYPE  XUBNAME
*"     VALUE(IV_USER_BY) TYPE  XUBNAME
*"     VALUE(IV_ACTIVE) TYPE  XFELD
*"  EXPORTING
*"     VALUE(EV_SUBRC) TYPE  SYSUBRC
*"     VALUE(EV_MESSAGE) TYPE  STRING
*"----------------------------------------------------------------------
DATA: ls_substituted_obj TYPE swragent,
        ls_substitute_obj  TYPE swragent,
        lt_substitutes        TYPE TABLE OF swragent,
        lt_message_struct     TYPE TABLE OF swr_mstruc,
        ls_message_struct     TYPE swr_mstruc.


  ls_substituted_obj-otype = 'US'.
  ls_substituted_obj-objid = iv_user_for.

  ls_substitute_obj-otype  = 'US'.
  ls_substitute_obj-objid  = iv_user_by.
  APPEND ls_substitute_obj TO lt_substitutes.

  IF iv_active = abap_true.

    CALL FUNCTION 'SAP_WAPI_SUBSTITUTE_ACTIVATE'
      EXPORTING
        substituted_object = ls_substituted_obj
      IMPORTING
        return_code        = ev_subrc
      TABLES
        substitutes        = lt_substitutes
        message_struct     = lt_message_struct.

  ELSE.

    CALL FUNCTION 'SAP_WAPI_SUBSTITUTE_DEACTIVATE'
      EXPORTING
        substituted_object = ls_substituted_obj
      IMPORTING
        return_code        = ev_subrc
      TABLES
        substitutes        = lt_substitutes
        message_struct     = lt_message_struct.

  ENDIF.

  IF ev_subrc <> 0.
    READ TABLE lt_message_struct INTO ls_message_struct INDEX 1.
    IF sy-subrc = 0.
      MESSAGE ID ls_message_struct-msgid
            TYPE ls_message_struct-msgty
          NUMBER ls_message_struct-msgno
            WITH ls_message_struct-msgv1
                 ls_message_struct-msgv2
                 ls_message_struct-msgv3
                 ls_message_struct-msgv4
            INTO ev_message.
    ELSE.
      ev_message = 'An unknown error occurred during substitution toggle.'.
    ENDIF.
  ELSE.
    IF iv_active = abap_true.
      ev_message = 'Substitution activated successfully.'.
    ELSE.
      ev_message = 'Substitution deactivated successfully.'.
    ENDIF.
  ENDIF.


ENDFUNCTION.
