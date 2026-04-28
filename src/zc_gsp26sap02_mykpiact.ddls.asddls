@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'My Action Center - KPI Query'
@Analytics.query: true
@OData.publish: true
define view entity ZC_GSP26SAP02_MyKPIAct
  as select from ZR_GSP26SAP02_Wf_MyAna
{
  // --- MEASURES ---
  @Aggregation.default: #SUM
  MyOpenTasksCount,

  @Aggregation.default: #SUM
  DueTodayCount,

  @Aggregation.default: #SUM
  MyOverdueCount
}
