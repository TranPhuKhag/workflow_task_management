CLASS lsc_ZR_GSP26SAP02_MYINBOX DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZR_GSP26SAP02_MYINBOX IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.
    IF zbp_gsp26sap02_myinbox=>gt_attachments_create IS NOT INITIAL.
      INSERT zgsp26_attachmen FROM TABLE @zbp_gsp26sap02_myinbox=>gt_attachments_create.
    ENDIF.
    IF zbp_gsp26sap02_attachment=>gt_attachments_delete IS NOT INITIAL.
      DELETE zgsp26_attachmen FROM TABLE @zbp_gsp26sap02_attachment=>gt_attachments_delete.
    ENDIF.
    IF zbp_gsp26sap02_myinbox=>gt_wiids IS NOT INITIAL.
      DATA(lt_wiids) = zbp_gsp26sap02_myinbox=>gt_wiids.
      SORT lt_wiids.
      DELETE ADJACENT DUPLICATES FROM lt_wiids.
      LOOP AT lt_wiids INTO DATA(lv_wiid) .
        CALL FUNCTION 'SWW_WI_LOG_FLUSH'
          EXPORTING
            im_wiid   = lv_wiid
            do_commit = space.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD cleanup.
    CLEAR:
        zbp_gsp26sap02_myinbox=>gt_wiids,
    zbp_gsp26sap02_myinbox=>gt_attachments_create,
    zbp_gsp26sap02_attachment=>gt_attachments_delete.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
