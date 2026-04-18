@EndUserText.label: 'My Inbox Consumption View'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@VDM.viewType: #CONSUMPTION
define root view entity ZC_GSP26SAP02_MyInbox
  as projection on ZR_GSP26SAP02_MyInbox
{
  key WorkItemID,
      TaskID,
      WorkItemType,
      TopWorkItemID,
      @ObjectModel.text.element: ['TechnicalStatusText']
      TechnicalStatus,
      TechnicalStatusText,

      WorkItemText,
      TaskText,

      @ObjectModel.text.element: ['PriorityText']
      Priority,
      PriorityText,
      DeadlineCriticality,
      DeadlineStatus,
      DaysToDeadline,
      CreationDate,
      EndDate,
      ActualDeadlineDate,
      ObjectID,
      BusinessObjectType,
      FlexDeadlineStatus,

      // Phi 5/2/26
      TargetServicePath,
      TargetEntitySet,
      SubEntitySet,
      TargetExpandParams,
      TargetExpandParams2,
      SemanticObject,
      SemanticAction,
      AssignedUser,
      AssignedUserName,
      UserSubstitutedByName,
      UserSubstitutedBy, // Flag to Subtitubed By User
      // Khang 03/03/26
      IsOverdue,
      IsDueOn,
      /* Associations */
      _DecisionOptions,
      _TraceLogs,
      _Comments    : redirected to composition child ZC_GSP26SAP02_WF_Comment,
      _Attachments : redirected to composition child ZC_GSP26SAP02_WF_Attachment
}
