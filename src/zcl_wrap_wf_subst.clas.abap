CLASS zcl_wrap_wf_subst DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zif_wrap_wf_subst .

    CONSTANTS:
      gc_otype_user  TYPE otype   VALUE 'US',
      gc_dest_none   TYPE string VALUE 'NONE',
      gc_enq_mode_e  TYPE enqmode VALUE 'E',
      gc_enq_scope_2 TYPE c  VALUE '2'.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_wrap_wf_subst IMPLEMENTATION.


  METHOD zif_wrap_wf_subst~delete_substitute.
    CALL FUNCTION 'SAP_WAPI_SUBSTITUTE_DELETE' DESTINATION gc_dest_none
      EXPORTING
        substituted_object = substituted_object
        start_date         = start_date
        end_date           = end_date
      IMPORTING
        return_code        = return_code
      TABLES
        substitutes        = substitutes
        message_lines      = message_lines.
  ENDMETHOD.


  METHOD zif_wrap_wf_subst~lock_substitute.
    CALL FUNCTION 'ENQUEUE_EZ_HRUS_D2'
      EXPORTING
        mode_hrus_d2   = gc_enq_mode_e
        mandt          = sy-mandt
        us_name        = us_name
        rep_name       = rep_name
        begda          = begda
        _scope         = gc_enq_scope_2
        _wait          = abap_false
      EXCEPTIONS
        foreign_lock   = 1
        system_failure = 2
        OTHERS         = 3.

    return_code = sy-subrc.
    IF return_code <> 0.
      error_text = CONV #( TEXT-e01 ). " Data currently locked by someone
    ENDIF.
  ENDMETHOD.


  METHOD zif_wrap_wf_subst~maintain_substitute.
    CALL FUNCTION 'SAP_WAPI_SUBSTITUTE_MAINTAIN' DESTINATION gc_dest_none
      EXPORTING
        substituted_object = substituted_object
        substitute         = substitute
        subst_begin        = subst_begin
        subst_end          = subst_end
        subst_profile      = subst_profile
        subst_active       = subst_active
      IMPORTING
        return_code        = return_code
      TABLES
        message_lines      = message_lines
        message_struct     = message_struct.
  ENDMETHOD.

  METHOD zif_wrap_wf_subst~toggle_substitute.
    DATA: ls_substituted_obj TYPE swragent,
          ls_substitute_obj  TYPE swragent,
          lt_substitutes     TYPE TABLE OF swragent,
          lt_message_struct  TYPE TABLE OF swr_mstruc,
          ls_message_struct  TYPE swr_mstruc.

    ls_substituted_obj-otype = gc_otype_user.
    ls_substituted_obj-objid = iv_user_for.

    ls_substitute_obj-otype  = gc_otype_user.
    ls_substitute_obj-objid  = iv_user_by.
    APPEND ls_substitute_obj TO lt_substitutes.

    IF iv_active = abap_true.
      CALL FUNCTION 'SAP_WAPI_SUBSTITUTE_ACTIVATE' DESTINATION gc_dest_none
        EXPORTING
          substituted_object = ls_substituted_obj
        IMPORTING
          return_code        = ev_subrc
        TABLES
          substitutes        = lt_substitutes
          message_struct     = lt_message_struct.
    ELSE.
      CALL FUNCTION 'SAP_WAPI_SUBSTITUTE_DEACTIVATE' DESTINATION gc_dest_none
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
        ev_message = CONV #( TEXT-e02 ). " An unknown error occurred during substitution toggle.
      ENDIF.
    ELSE.
      IF iv_active = abap_true.
        ev_message = CONV #( TEXT-s01 ). " Substitution activated successfully.
      ELSE.
        ev_message = CONV #( TEXT-s02 ). " Substitution deactivated successfully.
      ENDIF.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
