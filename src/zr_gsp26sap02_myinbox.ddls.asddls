@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Root View for My Inbox App'
@VDM.viewType: #COMPOSITE
define root view entity ZR_GSP26SAP02_MyInbox
  as select from    ZI_GSP26SAP02_WF_Task    as Task
    inner join      swwuserwi                as UserAssignment on UserAssignment.wi_id = Task.WorkItemID

    left outer join I_BusinessUser           as UserInfo       on UserInfo.UserID = UserAssignment.user_id

  // Phi 10/2/26
    left outer join ZI_GSP26SAP02_USER_SUBST as Subst          on  Subst.UserSubstitutedFor = UserAssignment.user_id //$session.user
                                                               and Subst.UserSubstitutedBy  = $session.user //UserAssignment.user_id
                                                               and Subst.BeginDate          <= $session.system_date
                                                               and Subst.EndDate            >= $session.system_date
                                                               and Subst.Active             = 'X'
  // Khang 21/03/26
    left outer join I_BusinessUser           as SubstUserInfo  on SubstUserInfo.UserID = Subst.UserSubstitutedBy
  // Phi 5/2/26
    left outer join ZI_GSP26SAP02_WF_CONFIG  as WfConfig       on WfConfig.WorkflowType = Task.BusinessObjectType
  // Khang 26/02/26
  composition [0..*] of ZI_GSP26SAP02_WF_Attachment as _Attachments
  composition [0..*] of ZI_GSP26SAP02_WF_Comment    as _Comments

{

  key Task.WorkItemID,
      Task.TaskID,
      Task.TopWorkItemID,
      Task.WorkItemType,
      Task.TechnicalStatus,
      Task.WorkItemText,
      Task.TaskText,
      Task.Priority,
      Task.DeadlineStatus,
      Task.CreationDate,
      Task.CreationTime,
      Task.EndDate,
      Task.ObjectID,
      Task.BusinessObjectType,
      Task.FlexDeadlineStatus,
      //      Task.Deadline,

      WfConfig.ServicePath                                                as TargetServicePath,
      WfConfig.EntitySet                                                  as TargetEntitySet,
      WfConfig.SubEntitySet                                               as SubEntitySet,
      WfConfig.ExpandNavigations                                          as TargetExpandParams,
      WfConfig.ExpandNavigations2                                         as TargetExpandParams2,
      WfConfig.SemanticObject                                             as SemanticObject,
      WfConfig.SemanticAction                                             as SemanticAction,
      tstmp_to_tims( tstmp_current_utctimestamp(),
                       abap_system_timezone( $session.client, 'FAIL' ),
                       $session.client,
                       'FAIL' )                                           as CurrentTime,
      max(UserAssignment.user_id)                                         as AssignedUser,
      max(UserInfo.PersonFullName)                                        as AssignedUserName,
      max(Subst.UserSubstitutedBy)                                        as UserSubstitutedBy,
      max(SubstUserInfo.PersonFullName)                                   as UserSubstitutedByName,
      case Task.TechnicalStatus
               when 'READY'     then 'Ready'
               when 'SELECTED'  then 'Reserved'
               when 'STARTED'   then 'In process'
               when 'WAITING'   then 'Waiting'
               when 'COMMITTED' then 'Executed'
               when 'COMPLETED' then 'Completed'
               when 'CANCELLED' then 'Logically deleted'
               when 'ERROR'     then 'Error'
               when 'CHECKED'   then 'In preparation'
               else Task.TechnicalStatus
            end                                                           as TechnicalStatusText,
      case Task.Priority
           when '1' then 'Highest'
           when '2' then 'Very High'
           when '3' then 'Higher'
           when '4' then 'High'
           when '5' then 'Medium'
           when '6' then 'Low'
           when '7' then 'Lower'
           when '8' then 'Very Low'
           when '9' then 'Lowest'
           else 'Medium'
      end                                                                 as PriorityText,
      case
         when Task.TechnicalStatus = 'COMPLETED' then 3
         when Task.DeadlineStatus  = '8998'      then 1
         when Task.DeadlineStatus  = '8996'
           or Task.DeadlineStatus  = '8997'      then 2
         else 0
      end                                                                 as DeadlineCriticality,

      dats_days_between( $session.system_date, Task.CreationDate )        as DaysSinceCreation,
      max(Task.FlexDeadlineDate)                                          as ActualDeadlineDate,

      case
        when max(Task.FlexDeadlineDate) > '00000000' and max(Task.FlexDeadlineDate) < '99991231'
          then dats_days_between( $session.system_date, max(Task.FlexDeadlineDate) )
          when max(Task.FlexDeadlineDate) is null
         then 9999
         when Task.EndDate is null
         then 9999
              when Task.EndDate > '00000000' and Task.EndDate < '99991231'
                then dats_days_between( $session.system_date, Task.EndDate )
        else 0000
      end                                                                 as DaysToDeadline,

      case when max(Task.FlexDeadlineDate) < $session.system_date and max(Task.FlexDeadlineDate) <> '00000000'
         then 'X'
               when max(Task.FlexDeadlineDate) = $session.system_date and max(Task.FlexDeadlineTime) < $projection.CurrentTime

          then 'X'
         else ' '
      end                                                                 as IsOverdue,

      case when max(Task.FlexDeadlineDate) > $session.system_date
         and max(Task.FlexDeadlineDate) <= dats_add_days( $session.system_date, 7,'FAIL')
             then 'X'
       when max(Task.FlexDeadlineDate) = $session.system_date and max(Task.FlexDeadlineTime) > $projection.CurrentTime
       then 'X'
      else ' '
      end                                                                 as IsDueOn,

      /* Associations */
      Task._DecisionOptions,
      Task._TraceLogs,
      _Attachments,
      _Comments
}
where
  // Phi 10/2/26
  (
       UserAssignment.user_id  = $session.user
    or Subst.UserSubstitutedBy is not null
  )
  and  UserAssignment.no_sel   <> 'X'
  and(
       Task.TechnicalStatus    =  'READY'
    or Task.ActualAgent        =  UserAssignment.user_id
    //    or Task.ActualAgent        =  $session.user
  )
group by
  Task.WorkItemID,
  Task.TaskID,
  Task.TopWorkItemID,
  Task.WorkItemType,
  Task.TechnicalStatus,
  Task.WorkItemText,
  Task.TaskText,
  Task.Priority,
  Task.DeadlineStatus,
  Task.CreationDate,
  Task.CreationTime,
  Task.EndDate,
  Task.ObjectID,
  Task.BusinessObjectType,
  Task.FlexDeadlineStatus,
  //  Task.Deadline,
  WfConfig.ServicePath,
  WfConfig.EntitySet,
  WfConfig.SubEntitySet,
  WfConfig.ExpandNavigations,
  WfConfig.ExpandNavigations2,
  WfConfig.SemanticObject,
  WfConfig.SemanticAction
