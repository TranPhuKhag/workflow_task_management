@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Workflow Trace Log Details'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #L,
    dataClass: #MIXED
}
define view entity ZI_GSP26SAP02_WF_TraceLog
  as select from    swpsteplog as StepLog

    left outer join swwwihead  as StepHeader on StepHeader.wi_id = StepLog.wi_id

  association [1..1] to ZI_GSP26SAP02_WF_Task as _WorkflowTask on $projection.ParentWorkItemID = _WorkflowTask.WorkItemID

{
      // key
  key StepLog.wf_id              as ParentWorkItemID, // 24820
  key StepLog.wi_id              as StepWorkItemID,   // 24821, 24822, ...
  key StepLog.log_count          as LogCounter,

      // node n task inf
      StepLog.node_id            as NodeID,
      StepLog.task_id            as TaskID, // TS00800576

      // text n status
      StepHeader.wi_text         as StepDescription,
      StepHeader.wi_stat         as StepStatus,
      StepHeader.wi_cd           as StepCreationDate,
      StepHeader.wi_ct           as StepCreationTime,

      // agent
      StepLog.wi_agent           as AgentID, // agent
      StepHeader.wi_aagent       as ActualAgent, // agent current holding task

      // time
      StepLog.log_date           as LogDate,
      StepLog.log_time           as LogTime,
      StepLog.wi_aed             as CompletedDate,
      StepLog.wi_aet             as CompletedTime,

      // deadline
      StepLog.wi_dh_stat         as DeadlineStatus,
      StepLog.returncode         as ReturnCode,
      StepLog.returnval          as ReturnValue,

      StepHeader.wi_chckwi       as ImmediateParentWI,

      StepHeader.wi_cruser       as CreatedByUser,
      StepHeader.wi_type         as WorkItemType,
      StepHeader.wi_prio         as Priority,

      StepLog.node_p_ind         as ParallelIndex,
      StepLog.pred_wi_id         as PredecessorWI,

      StepHeader.top_wi_id       as TopWorkItemID,
      StepHeader.parent_wi       as ParentWorkItem,
      StepHeader.wi_rhtext       as TaskShortText,

      StepLog.flex_return_nature as Nature, // pos/ nev
      StepLog.flex_return_value  as FlexReturnValue, // release, ...

      _WorkflowTask
}
