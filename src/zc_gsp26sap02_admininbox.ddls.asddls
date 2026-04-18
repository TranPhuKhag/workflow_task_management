@EndUserText.label: 'Admin Inbox Consumption View'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@VDM.viewType: #CONSUMPTION
define root view entity ZC_GSP26SAP02_AdminInbox
  as projection on ZR_GSP26SAP02_AdminInbox
{
  key WorkItemID,
  key SampleResponsibleUser,
      TopWorkItemID, 

      @ObjectModel.text.element: ['TechnicalStatusText']
      TechnicalStatus,
      TechnicalStatusText,

      WorkItemText,
      Priority,
      CreationDate,
      DaysSinceCreation,
      ObjectID,
      BusinessObjectType,

      ClaimedByUser,
      ClaimedByUserName,
//      SampleResponsibleUser,
      SampleResponsibleUserName,

      /* Associations */
      _TraceLogs
}
