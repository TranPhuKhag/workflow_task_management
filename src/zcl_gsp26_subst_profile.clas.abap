CLASS zcl_gsp26_subst_profile DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_gsp26_subst_profile IMPLEMENTATION.
  METHOD if_rap_query_provider~select.
    DATA: lt_profiles    TYPE TABLE OF swr_substprofile,
          lv_return_code TYPE sysubrc,
          lt_result      TYPE TABLE OF ZCE_GSP26SAP02_SubstProfile,
          lt_result_page TYPE TABLE OF ZCE_GSP26SAP02_SubstProfile.

    DATA(lv_top)     = io_request->get_paging( )->get_page_size( ).
    DATA(lv_skip)    = io_request->get_paging( )->get_offset( ).
    DATA(lv_max_rows) = COND int8( WHEN lv_top = if_rap_query_paging=>page_size_unlimited THEN 0 ELSE lv_top ).

    IF io_request->is_data_requested( ).

      CALL FUNCTION 'SAP_WAPI_SUBSTITUTE_PROF_GET'
        EXPORTING
          language    = sy-langu
        IMPORTING
          return_code = lv_return_code
        TABLES
          profiles    = lt_profiles.

      IF lv_return_code = 0.
        lt_result = VALUE #( FOR ls_prof IN lt_profiles (
                               ProfileId   = ls_prof-profile
                               ProfileText = ls_prof-text
                             ) ).
      ENDIF.

      DATA(lv_total_lines) = lines( lt_result ).

      IF lv_skip < lv_total_lines.
        IF lv_max_rows > 0.
          DATA(lv_upto) = lv_skip + lv_max_rows.
          IF lv_upto > lv_total_lines.
            lv_upto = lv_total_lines.
          ENDIF.

          LOOP AT lt_result INTO DATA(ls_row) FROM ( lv_skip + 1 ) TO lv_upto.
            APPEND ls_row TO lt_result_page.
          ENDLOOP.
        ELSE.
          lt_result_page = lt_result.
        ENDIF.
      ENDIF.

      io_response->set_data( lt_result_page ).

    ENDIF.

    IF io_request->is_total_numb_of_rec_requested( ).
      io_response->set_total_number_of_records( lines( lt_result ) ).
    ENDIF.

  ENDMETHOD.
ENDCLASS.
