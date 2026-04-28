CLASS zcl_gsp26sap02_calc_comment DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_sadl_exit .
    INTERFACES if_sadl_exit_calc_element_read .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_gsp26sap02_calc_comment IMPLEMENTATION.

  METHOD if_sadl_exit_calc_element_read~calculate.
    DATA: lt_data TYPE STANDARD TABLE OF zc_gsp26sap02_wf_comment WITH DEFAULT KEY.
    lt_data = CORRESPONDING #( it_original_data ).
    DATA: ls_document_id    TYPE so_entryid,
          ls_filter         TYPE sofilteri1 VALUE 'X ',
          lt_document_data  TYPE sofolenti1,
          lt_object_header  TYPE TABLE OF solisti1,
          lt_object_content TYPE TABLE OF solisti1,
          lv_full_text      TYPE string.
    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<fs_data>).
      CLEAR: ls_document_id, lt_document_data, lt_object_header, lt_object_content, lv_full_text.

      IF <fs_data>-objectid IS INITIAL.
        CONTINUE.
      ENDIF.

      ls_document_id = <fs_data>-objectid.
      CALL FUNCTION 'SO_DOCUMENT_READ_API1'
        EXPORTING
          document_id                = ls_document_id
          filter                     = ls_filter
        IMPORTING
          document_data              = lt_document_data
        TABLES
          object_header              = lt_object_header
          object_content             = lt_object_content
*         OBJECT_PARA                =
*         OBJECT_PARB                =
*         ATTACHMENT_LIST            =
*         RECEIVER_LIST              =
*         CONTENTS_HEX               =
        EXCEPTIONS
          document_id_not_exist      = 1
          operation_no_authorization = 2
          x_error                    = 3
          OTHERS                     = 4.
      IF sy-subrc <> 0.
* Implement suitable error handling here
        CONTINUE.
      ENDIF.
      IF lt_object_content IS NOT INITIAL.
        CONCATENATE LINES OF lt_object_content INTO lv_full_text.
        <fs_data>-CommentText = lv_full_text.
      ENDIF.
      CLEAR: ls_document_id, lt_document_data, lt_object_header, lt_object_content.
    ENDLOOP.
    ct_calculated_data = CORRESPONDING #( lt_data ).
  ENDMETHOD.

  METHOD if_sadl_exit_calc_element_read~get_calculation_info.
    IF iv_entity <> 'ZC_GSP26SAP02_WF_COMMENT'.
      RAISE EXCEPTION TYPE zcm_gsp26sap02_virt_elem
        EXPORTING
          im_textid = zcm_gsp26sap02_virt_elem=>entity_not_known
          IM_entity = iv_entity.
    ENDIF.
    LOOP AT it_requested_calc_elements ASSIGNING FIELD-SYMBOL(<fs_calc_element>).
      CASE <fs_calc_element>.
        WHEN 'COMMENTTEXT'.
          APPEND 'OBJECTID' TO et_requested_orig_elements.
        WHEN OTHERS.
          RAISE EXCEPTION TYPE zcm_gsp26sap02_virt_elem
            EXPORTING
              im_textid = zcm_gsp26sap02_virt_elem=>virtual_element_not_known
              IM_entity = iv_entity.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
