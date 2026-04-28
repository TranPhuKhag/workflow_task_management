@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Root - Admin Overview'
@VDM.viewType: #COMPOSITE
define root view entity ZR_GSP26SAP02_AdminInbox
  as select from    ZI_GSP26SAP02_WF_Task as Task
    left outer join swwuserwi             as UserAssignment      on UserAssignment.wi_id = Task.WorkItemID
    left outer join I_BusinessUser        as ResponsibleUserInfo on ResponsibleUserInfo.UserID = UserAssignment.user_id

    left outer join I_BusinessUser        as ClaimedUserInfo     on ClaimedUserInfo.UserID = Task.ActualAgent

{
  key Task.WorkItemID,
  key UserAssignment.user_id                                       as SampleResponsibleUser,

      Task.TopWorkItemID,

      Task.WorkItemText,
      Task.TechnicalStatus,
      Task.Priority,
      Task.CreationDate,
      Task.ObjectID,
      Task.BusinessObjectType,

      // claim
      Task.ActualAgent                                             as ClaimedByUser,
      max(ClaimedUserInfo.PersonFullName)                          as ClaimedByUserName,

      // responsible
      //      max(UserAssignment.user_id)                                  as SampleResponsibleUser,
      max(ResponsibleUserInfo.PersonFullName)                      as SampleResponsibleUserName,

      case Task.TechnicalStatus
           when 'SELECTED'  then 'Reserved'
           when 'STARTED'   then 'In Process'
           when 'WAITING'   then 'Waiting'
           when 'ERROR'     then 'Error'
           else Task.TechnicalStatus
      end                                                          as TechnicalStatusText,

      dats_days_between( $session.system_date, Task.CreationDate ) as DaysSinceCreation,

      /* Associations */
      Task._TraceLogs
}
where
     Task.TechnicalStatus = 'SELECTED'
  or Task.TechnicalStatus = 'STARTED'
  or Task.TechnicalStatus = 'WAITING'
  or Task.TechnicalStatus = 'ERROR'

group by
  Task.WorkItemID,
  UserAssignment.user_id,
  Task.TopWorkItemID,
  Task.WorkItemText,
  Task.TechnicalStatus,
  Task.Priority,
  Task.CreationDate,
  Task.ObjectID,
  Task.BusinessObjectType,
  Task.ActualAgent
