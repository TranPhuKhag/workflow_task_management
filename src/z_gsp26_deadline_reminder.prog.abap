*&---------------------------------------------------------------------*
*& Report Z_GSP26_DEADLINE_REMINDER
*&---------------------------------------------------------------------*
REPORT z_gsp26_deadline_reminder.

*----------------------------------------------------------------------*
* CONSTANTS DEFINITION
*----------------------------------------------------------------------*
CONSTANTS:
  " Workflow Statuses
  gc_status_completed TYPE string VALUE 'COMPLETED',
  gc_status_cancelled TYPE string VALUE 'CANCELLED',
  gc_status_error     TYPE string VALUE 'ERROR',
  " Flex Deadline Statuses
  gc_flex_00          TYPE char2  VALUE '00',
  gc_flex_01          TYPE char2  VALUE '01',
  gc_flex_02          TYPE char2  VALUE '02',
  gc_flex_04          TYPE char2  VALUE '04',
  " Dates
  gc_min_date         TYPE d      VALUE '00000000',
  gc_max_date         TYPE d      VALUE '99991231',
  " Notification Targets
  gc_target_obj       TYPE  /iwngw/notif_nav_obj VALUE 'ZWorkflow',
  gc_action_prefix    TYPE string VALUE 'display&/tasks/',
  gc_action_suffix    TYPE string VALUE '/TwoColumnsMidExpanded'.

*----------------------------------------------------------------------*
* DATA DECLARATION
*----------------------------------------------------------------------*
DATA: lt_recipients TYPE /iwngw/if_notif_provider=>ty_t_notification_recipient,
      lt_parameters TYPE /iwngw/if_notif_provider=>ty_t_notification_parameter.

*----------------------------------------------------------------------*
* MAIN LOGIC
*----------------------------------------------------------------------*
SELECT task~WorkItemID,
       usr~user_id           AS AssignedUser,
       task~FlexDeadlineDate AS ActualDeadlineDate,
       task~ObjectID
  FROM ZI_GSP26SAP02_WF_Task AS task
  INNER JOIN swwuserwi       AS usr ON task~WorkItemID = usr~wi_id
  WHERE task~FlexDeadlineDate IS NOT INITIAL
    AND task~FlexDeadlineDate <> @gc_min_date
    AND task~FlexDeadlineDate <> @gc_max_date
    AND task~TechnicalStatus  NOT IN ( @gc_status_completed, @gc_status_cancelled, @gc_status_error )
    AND task~FlexDeadlineStatus   IN ( @gc_flex_00, @gc_flex_01, @gc_flex_02, @gc_flex_04 )
    AND usr~no_sel <> @abap_true
  INTO TABLE @DATA(lt_tasks).

IF sy-subrc = 0.
  LOOP AT lt_tasks INTO DATA(ls_task).
    CHECK ls_task-AssignedUser IS NOT INITIAL.
    DATA(lv_days_to_deadline) = ls_task-ActualDeadlineDate - sy-datum.

    CHECK lv_days_to_deadline BETWEEN -1 AND 3.

    CALL FUNCTION 'SWW_WI_PRIORITY_CHANGE' DESTINATION 'NONE'
      EXPORTING
        priority         = 2
        wi_id            = ls_task-WorkItemID
        do_commit        = abap_true
      EXCEPTIONS
        no_authorization = 1
        invalid_type     = 2
        update_failed    = 3
        invalid_status   = 4
        OTHERS           = 5.

    IF sy-subrc <> 0.
      WRITE: / TEXT-e01, ls_task-WorkItemID.
    ENDIF.

    CLEAR: lt_recipients, lt_parameters.

    zcl_gsp26_noti_after_action=>build_deadline_data(
      EXPORTING
        iv_workitem_id = ls_task-WorkItemID
        iv_deadline    = ls_task-ActualDeadlineDate
        iv_receiver    = ls_task-AssignedUser
      IMPORTING
        et_recipients  = lt_recipients
        et_parameters  = lt_parameters
    ).

    DATA(lv_wiid_str) = |{ ls_task-WorkItemID ALPHA = OUT }|.
    CONDENSE lv_wiid_str NO-GAPS.

    DATA(lv_target_action) = |{ gc_action_prefix }{ lv_wiid_str }{ gc_action_suffix }|.

    zcl_gsp26_noti_after_action=>push_notification_generic(
      iv_notif_type = zcl_gsp26_noti_after_action=>gc_notif_deadline
      it_recipients = lt_recipients
      it_parameters = lt_parameters
      iv_target_obj = gc_target_obj
      iv_target_act = lv_target_action
      iv_priority   = /iwngw/if_notif_provider=>gcs_priorities-medium
    ).
  ENDLOOP.
ENDIF.
