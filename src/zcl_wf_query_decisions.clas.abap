CLASS zcl_wf_query_decisions DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_rap_query_provider .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_wf_query_decisions IMPLEMENTATION.

  METHOD if_rap_query_provider~select.
    TRY.
        CASE io_request->get_entity_id(  ).
          WHEN 'ZI_WF_DECISION_UQ'.
            DATA: lv_workitem_id TYPE sww_wiid,
                  lt_decisions   TYPE TABLE OF swr_decialts,
                  lt_result      TYPE TABLE OF zi_wf_decision_uq.

            DATA(lv_top) = io_request->get_paging( )->get_page_size( ). "$top
            DATA(lv_skip) = io_request->get_paging( )->get_offset( ). "$skip
            DATA(lt_fields) = io_request->get_requested_elements( ). "$select
            DATA(lt_sort) = io_request->get_sort_elements( ). "$orderby
            " Process sorting
            IF lt_sort IS NOT INITIAL.
              DATA:lt_sort_criteria  TYPE abap_sortorder_tab,
                   ls_sort_criterion TYPE abap_sortorder.
              LOOP AT lt_sort INTO DATA(ls_sort).
                CLEAR: ls_sort_criterion.
                ls_sort_criterion-name = ls_sort-element_name.
                IF ls_sort-descending = abap_true.
                  ls_sort_criterion-descending = 'X'.
                ELSE.
                  ls_sort_criterion-descending = ' '.
                ENDIF.
                APPEND ls_sort_criterion TO lt_sort_criteria.
              ENDLOOP.
            ENDIF.
            TRY.
                DATA(lt_filter_ranges) = io_request->get_filter( )->get_as_ranges( ).
              CATCH cx_rap_query_filter_no_range.
                lt_filter_ranges = VALUE #( ).
            ENDTRY.
            READ TABLE lt_filter_ranges WITH KEY name = 'WORKITEMID' INTO DATA(ls_wi_filter).
            IF sy-subrc = 0.
                        lv_workitem_id = ls_wi_filter-range[ 1 ]-low.
            ENDIF.

            IF lv_workitem_id IS NOT INITIAL.
              " Get Work Item ID from the query context
              CALL FUNCTION 'SAP_WAPI_DECISION_READ'
                EXPORTING
                  workitem_id  = lv_workitem_id
                TABLES
                  alternatives = lt_decisions.
                   IF sy-subrc <> 0.
      CLEAR lt_decisions.
    ENDIF.
              " MAPPING DATA FROM WAPI TO CUSTOM ENTITY
              lt_result = VALUE #( FOR ls_decision IN lt_decisions
                                  (
                                    WorkItemID = lv_workitem_id
                                    DecisionKey = ls_decision-altkey
                                    DecisionText = ls_decision-alttext
                                    Nature = ls_decision-altnature
                                  )
              ).

              " EXECUTION SORT
              IF lt_sort_criteria IS NOT INITIAL.
                SORT lt_result BY (lt_sort_criteria).
              ELSE.
                SORT lt_result BY WorkItemID .
              ENDIF.
              "request data
              IF io_request->is_data_requested( ).

                io_response->set_data( lt_result ).
              ENDIF.
              "request count
              IF io_request->is_total_numb_of_rec_requested( ).
                "fill response
                io_response->set_total_number_of_records( lines( lt_result ) ).
              ENDIF.
            ENDIF.
        ENDCASE.
      CATCH cx_rap_query_provider.
    ENDTRY.

  ENDMETHOD.
ENDCLASS.
