@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Basic Interface for Workflow Task'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #L,
    dataClass: #MIXED
}
@VDM.viewType: #BASIC
define root view entity ZI_GSP26SAP02_WF_Task
  as select from            swwwihead  as wi
    left outer to one join  sww_wi2obj as wi2obj on  wi2obj.wi_id      = wi.wi_id
                                                 and wi2obj.wi_reltype = '01'

    left outer to many join swwflexdl  as flexdl on flexdl.wi_id = wi.wi_id
  // Associations
  association [0..*] to ZI_WF_DECISION_UQ            as _DecisionOptions on $projection.WorkItemID = _DecisionOptions.WorkItemID
  association [0..*] to ZI_GSP26SAP02_WF_TraceLog    as _TraceLogs       on $projection.TopWorkItemID = _TraceLogs.ParentWorkItemID
{
  key wi.wi_id                                                              as WorkItemID,
      wi.wi_rh_task                                                         as TaskID,
      wi.wi_type                                                            as WorkItemType,
      wi.top_wi_id                                                          as TopWorkItemID,
      wi.wi_stat                                                            as TechnicalStatus,
      wi.wi_text                                                            as WorkItemText,
      wi.wi_rhtext                                                          as TaskText,
      wi.wi_cd                                                              as CreationDate,
      wi.wi_ct                                                              as CreationTime,
      wi.wi_aed                                                             as EndDate,
      tstmp_to_dats(flexdl.deadline_tmstmp, 'UTC', $session.client, 'FAIL') as FlexDeadlineDate,
      tstmp_to_tims(flexdl.deadline_tmstmp, 'UTC', $session.client, 'FAIL') as FlexDeadlineTime,
      
      wi.wi_dh_stat                                                         as DeadlineStatus,
      wi.wi_prio                                                            as Priority,
      wi2obj.instid                                                         as ObjectID,
      wi2obj.typeid                                                         as BusinessObjectType,
      wi.wi_cruser                                                          as CreatedByUser,
      wi.wi_aagent                                                          as ActualAgent,
      flexdl.status                                                         as FlexDeadlineStatus,
      _DecisionOptions,
      _TraceLogs
}
where
  wi.wi_stat <> 'CANCELLED'
