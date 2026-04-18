CLASS zcl_gsp26_utils DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CONSTANTS:
      gc_subty_0001  TYPE subty           VALUE '0001',
      gc_infty_2001  TYPE prelp-infty     VALUE '2001', " Absences
      gc_default_lvl TYPE zde_wf_role_lvl VALUE 99.

    CLASS-METHODS check_user_availability
      IMPORTING
        iv_userid       TYPE xubname
        iv_begin_date   TYPE datum
        iv_end_date     TYPE datum
      EXPORTING
        ev_message      TYPE string
      RETURNING
        VALUE(rv_avail) TYPE abap_bool.

    CLASS-METHODS check_role_level_validity
      IMPORTING
        iv_user_for     TYPE xubname
        iv_user_by      TYPE xubname
      EXPORTING
        ev_message      TYPE string
      RETURNING
        VALUE(rv_valid) TYPE abap_bool.

ENDCLASS.

CLASS zcl_gsp26_utils IMPLEMENTATION.

  METHOD check_user_availability.
    DATA: lv_pernr TYPE pernr_d,
          lt_pernr TYPE TABLE OF pernr_d.
    DATA: lt_p2001 TYPE TABLE OF pa2001.

    rv_avail = abap_true.

    SELECT  pernr FROM pa0105 " SINGLE
          INTO TABLE @lt_pernr
                  UP TO 1 ROWS
             WHERE usrid = @iv_userid
            AND subty = @gc_subty_0001
            AND endda >= @iv_begin_date
            AND begda <= @iv_end_date
             ORDER BY endda DESCENDING, begda DESCENDING
            .
    IF sy-subrc <> 0 OR lt_pernr[ 1 ]  IS INITIAL.
      RETURN.
    ENDIF.

    CALL FUNCTION 'HR_READ_INFOTYPE'
      EXPORTING
        pernr     = lv_pernr
        infty     = gc_infty_2001      " absences
        begda     = iv_begin_date
        endda     = iv_end_date
      TABLES
        infty_tab = lt_p2001
      EXCEPTIONS
        OTHERS    = 1.
IF sy-subrc <> 0.
  RETURN.
ENDIF.
    IF lines( lt_p2001 ) > 0.
      rv_avail = abap_false. " not avail

      ev_message = replace( val  = CONV string( TEXT-e01 )
                            sub  = '&1'
                            with = CONV string( iv_userid ) ).

      ev_message = replace( val  = ev_message
                            sub  = '&2'
                            with = CONV string( lv_pernr ) ).
    ENDIF.

  ENDMETHOD.

  METHOD check_role_level_validity.
    DATA: lv_level_for TYPE zde_wf_role_lvl,
          lv_level_by  TYPE zde_wf_role_lvl.

    rv_valid = abap_true.

    SELECT MIN( r~RoleLevel )
      FROM zi_gsp26sap02_wf_user AS u
      INNER JOIN zi_gsp26sap02_wf_role AS r ON u~RoleID = r~RoleID
      WHERE u~UserName   = @iv_user_for
        AND u~IsActive   = @abap_true
        AND u~ValidFrom <= @sy-datum
        AND u~ValidTo   >= @sy-datum
      INTO @lv_level_for.


    SELECT MIN( r~RoleLevel )
      FROM zi_gsp26sap02_wf_user AS u
      INNER JOIN zi_gsp26sap02_wf_role AS r ON u~RoleID = r~RoleID
      WHERE u~UserName   = @iv_user_by
        AND u~IsActive   = @abap_true
        AND u~ValidFrom <= @sy-datum
        AND u~ValidTo   >= @sy-datum
      INTO @lv_level_by.

    IF lv_level_for IS INITIAL. lv_level_for = gc_default_lvl. ENDIF.
    IF lv_level_by IS INITIAL.  lv_level_by  = gc_default_lvl. ENDIF.

    IF lv_level_by > lv_level_for.
      rv_valid = abap_false.

      ev_message = replace( val  = CONV string( TEXT-e02 )
                            sub  = '&1'
                            with = CONV string( iv_user_by ) ).

      ev_message = replace( val  = ev_message
                            sub  = '&2'
                            with = CONV string( iv_user_for ) ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.
