@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Top Overdue Tasks List'
@Search.searchable: true 
define view entity ZC_GSP26SAP02_WF_TAG
  as select from ZI_GSP26SAP02_WF_Task
{
  @Search.defaultSearchElement: true
  key WorkItemID,
  
  BusinessObjectType,
  
  TaskID,
  Priority,
  
  @Search.defaultSearchElement: true
  CreatedByUser,
  
  CreationDate,
  
  @Search.defaultSearchElement: true
  ActualAgent,
  
  dats_days_between( CreationDate, $session.system_date ) as DaysOpen,
  
  case TechnicalStatus
    when 'READY'     then 'Open'
    when 'SELECTED'  then 'Open'
    when 'STARTED'   then 'In Process'
    else TechnicalStatus
  end as StatusCategory
}
where 
  TechnicalStatus = 'READY' or TechnicalStatus = 'SELECTED' or TechnicalStatus = 'STARTED'
