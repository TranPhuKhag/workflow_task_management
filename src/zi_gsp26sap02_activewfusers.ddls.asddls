@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface - ActiveUser'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #L,
    dataClass: #MIXED
}
@VDM.viewType: #COMPOSITE
define view entity ZI_GSP26SAP02_ActiveWFUsers
  as select from    swwuserwi             as UserAssignment
    inner join      ZI_GSP26SAP02_WF_Task as Task     on UserAssignment.wi_id = Task.WorkItemID
    left outer join I_BusinessUserBasic   as UserInfo on UserAssignment.user_id = UserInfo.UserID
    
    left outer join I_WorkplaceAddress    as WPAddress on UserInfo.BusinessPartnerUUID = WPAddress.BusinessPartnerUUID
{
  key UserAssignment.user_id               as UserID,

      max(UserInfo.PersonFullName)         as PersonFullName,
      
      max(WPAddress.Department)            as Department,
      max(WPAddress.DefaultEmailAddress)   as Email, 

      count(distinct Task.WorkItemID)      as TotalActiveWorkItems
}
where
     Task.TechnicalStatus = 'SELECTED'
  or Task.TechnicalStatus = 'STARTED'
  or Task.TechnicalStatus = 'WAITING'
  or Task.TechnicalStatus = 'ERROR'
group by
  UserAssignment.user_id
