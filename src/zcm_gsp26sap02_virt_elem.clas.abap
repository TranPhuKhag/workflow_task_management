CLASS zcm_gsp26sap02_virt_elem DEFINITION
  PUBLIC
*  INHERITING FROM cx_static_check
INHERITING FROM cx_sadl_exit
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_t100_message .
    INTERFACES if_t100_dyn_msg .
    DATA: entity TYPE string READ-ONLY.
    CONSTANTS:
      BEGIN OF entity_not_known,
        msgid TYPE symsgid VALUE 'ZGSP26SAP02_VIRT_ELE',
        msgno TYPE symsgno VALUE '001',
        attr1 TYPE scx_attrname VALUE 'ENTITY',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF entity_not_known,
      BEGIN OF virtual_element_not_known,
        msgid TYPE symsgid VALUE 'ZGSP26SAP02_VIRT_ELE',
        msgno TYPE symsgno VALUE '002',
        attr1 TYPE scx_attrname VALUE 'ENTITY',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF virtual_element_not_known.
    METHODS constructor
      IMPORTING
        !im_textid   LIKE if_t100_message=>t100key OPTIONAL
        !im_previous LIKE previous OPTIONAL
        !im_entity   TYPE string OPTIONAL .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcm_gsp26sap02_virt_elem IMPLEMENTATION.


  METHOD constructor ##ADT_SUPPRESS_GENERATION.
    CALL METHOD super->constructor
      EXPORTING
        previous = im_previous.
    CLEAR me->textid.
    IF textid IS INITIAL.
      if_t100_message~t100key = if_t100_message=>default_textid.
    ELSE.
      if_t100_message~t100key = im_textid.
    ENDIF.
    IF im_entity IS NOT INITIAL.
      me->entity = im_entity.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
