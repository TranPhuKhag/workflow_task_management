CLASS zcm_gsp26sap02_myinbox DEFINITION
  PUBLIC
  INHERITING FROM cx_static_check
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_abap_behv_message .
    INTERFACES if_t100_message .
    INTERFACES if_t100_dyn_msg .

    DATA: workitem_id TYPE sww_wiid READ-ONLY,
          message  TYPE string READ-ONLY.
    METHODS constructor
      IMPORTING
        !im_textid      LIKE if_t100_message=>t100key OPTIONAL
        !im_serverity   TYPE if_abap_behv_message=>t_severity OPTIONAL
        !im_previous    LIKE previous OPTIONAL
        !im_workitem_id TYPE sww_wiid OPTIONAL
        !im_message  TYPE string OPTIONAL
      .
    CONSTANTS:
      BEGIN OF c_action_failed,
        msgid TYPE symsgid VALUE 'ZGSP26SAP02_MYINBOX',
        msgno TYPE symsgno VALUE '001',
        attr1 TYPE scx_attrname VALUE 'WORKITEM_ID',
        attr2 TYPE scx_attrname VALUE 'MESSAGE',
        attr3 TYPE scx_attrname VALUE 'attr3',
        attr4 TYPE scx_attrname VALUE 'attr4',
      END OF c_action_failed,

      BEGIN OF c_infeasible_state,
        msgid TYPE symsgid VALUE 'ZGSP26SAP02_MYINBOX',
        msgno TYPE symsgno VALUE '002',
        attr1 TYPE scx_attrname VALUE 'WORKITEM_ID',
        attr2 TYPE scx_attrname VALUE 'MESSAGE',
        attr3 TYPE scx_attrname VALUE 'attr3',
        attr4 TYPE scx_attrname VALUE 'attr4',
      END OF c_infeasible_state,

      BEGIN OF c_invalid_type,
        msgid TYPE symsgid VALUE 'ZGSP26SAP02_MYINBOX',
        msgno TYPE symsgno VALUE '003',
        attr1 TYPE scx_attrname VALUE 'WORKITEM_ID',
        attr2 TYPE scx_attrname VALUE 'MESSAGE',
        attr3 TYPE scx_attrname VALUE 'attr3',
        attr4 TYPE scx_attrname VALUE 'attr4',
      END OF c_invalid_type,

      BEGIN OF c_no_auth,
        msgid TYPE symsgid VALUE 'ZGSP26SAP02_MYINBOX',
        msgno TYPE symsgno VALUE '004',
        attr1 TYPE scx_attrname VALUE 'WORKITEM_ID',
        attr2 TYPE scx_attrname VALUE 'MESSAGE',
        attr3 TYPE scx_attrname VALUE 'attr3',
        attr4 TYPE scx_attrname VALUE 'attr4',
      END OF c_no_auth,

      BEGIN OF c_update_failed,
        msgid TYPE symsgid VALUE 'ZGSP26SAP02_MYINBOX',
        msgno TYPE symsgno VALUE '005',
        attr1 TYPE scx_attrname VALUE 'WORKITEM_ID',
        attr2 TYPE scx_attrname VALUE 'MESSAGE',
        attr3 TYPE scx_attrname VALUE 'attr3',
        attr4 TYPE scx_attrname VALUE 'attr4',
      END OF c_update_failed,
      BEGIN OF c_invalid_status,
        msgid TYPE symsgid VALUE 'ZGSP26SAP02_MYINBOX',
        msgno TYPE symsgno VALUE '006',
        attr1 TYPE scx_attrname VALUE 'WORKITEM_ID',
        attr2 TYPE scx_attrname VALUE 'MESSAGE',
        attr3 TYPE scx_attrname VALUE 'attr3',
        attr4 TYPE scx_attrname VALUE 'attr4',
      END OF c_invalid_status.
      .

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcm_gsp26sap02_myinbox IMPLEMENTATION.


  METHOD constructor ##ADT_SUPPRESS_GENERATION.
    CALL METHOD super->constructor
      EXPORTING
        previous = im_previous.
    me->if_abap_behv_message~m_severity = im_serverity.

    CLEAR me->textid.
    IF im_textid IS INITIAL.
      if_t100_message~t100key = if_t100_message=>default_textid.
    ELSE.
      if_t100_message~t100key = im_textid.
    ENDIF.
    IF im_workitem_id IS NOT INITIAL.
      me->workitem_id = im_workitem_id.
    ENDIF.
    IF im_message IS NOT INITIAL.
      me->message = im_message.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
