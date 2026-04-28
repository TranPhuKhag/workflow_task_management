CLASS zcl_gsp26sap02_calc_attachment DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_sadl_exit .
    INTERFACES if_sadl_exit_calc_element_read .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_gsp26sap02_calc_attachment IMPLEMENTATION.

  METHOD if_sadl_exit_calc_element_read~calculate.
    DATA lt_data TYPE STANDARD TABLE OF ZC_GSP26SAP02_WF_Attachment WITH DEFAULT KEY.
    lt_data = CORRESPONDING #( it_original_data ).
    DATA: ls_document_data  TYPE sofolenti1,
          lt_object_header  TYPE TABLE OF solisti1,
          lt_object_content TYPE TABLE OF solisti1,
          lt_content_hex    TYPE TABLE OF solix,
          ls_document_id    TYPE so_entryid,
          ls_filter         TYPE sofilteri1 VALUE 'X '.
    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<fs_data>).
      CLEAR: ls_document_id, ls_document_data, lt_content_hex.

      IF <fs_data>-ObjectID IS NOT INITIAL.
        .
        ls_document_id = <fs_data>-ObjectID.
        CALL FUNCTION 'SO_DOCUMENT_READ_API1'
          EXPORTING
            document_id                = ls_document_id
            filter                     = ls_filter
          IMPORTING
            document_data              = ls_document_data
          TABLES
            object_header              = lt_object_header
            object_content             = lt_object_content
*           OBJECT_PARA                =
*           OBJECT_PARB                =
*           ATTACHMENT_LIST            =
*           RECEIVER_LIST              =
            contents_hex               = lt_content_hex
          EXCEPTIONS
            document_id_not_exist      = 1
            operation_no_authorization = 2
            x_error                    = 3
            OTHERS                     = 4.
" Nếu lỗi đọc file -> bỏ qua file này
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
        DATA: lv_content_xstring TYPE xstring,
              lv_size            TYPE i.
        lv_size = ls_document_data-doc_size.

        CALL FUNCTION 'SCMS_BINARY_TO_XSTRING'
          EXPORTING
            input_length = lv_size
*           FIRST_LINE   = 0
*           LAST_LINE    = 0
          IMPORTING
            buffer       = lv_content_xstring
          TABLES
            binary_tab   = lt_content_hex
          EXCEPTIONS
            failed       = 1
            OTHERS       = 2.
" Nếu lỗi convert -> bỏ qua file này
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
        <fs_data>-Content = lv_content_xstring.
        CLEAR: lt_object_header, lt_object_content, lt_content_hex,ls_document_id, lv_content_xstring.
      ELSE. " <FS_DATA>-ObjectID IS NOT INITIAL.

      ENDIF.
    ENDLOOP.
    ct_calculated_data = CORRESPONDING #( lt_data ).
  ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~get_calculation_info.
    IF iv_entity <> 'ZC_GSP26SAP02_WF_ATTACHMENT'.
      RAISE EXCEPTION TYPE zcm_gsp26sap02_virt_elem
        EXPORTING
          im_textid = zcm_gsp26sap02_virt_elem=>entity_not_known
          IM_entity = iv_entity.
    ENDIF.
    LOOP AT it_requested_calc_elements ASSIGNING FIELD-SYMBOL(<fs_calc_element>).
      CASE <fs_calc_element>.
        WHEN 'CONTENT'.
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
