@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Workflow Volume & Status Query'
@Analytics.query: true
@OData.publish: true
/*+[hideWarning] { "IDS" : [ "KEY_CHECK" ]  } */
define view entity ZC_GSP26SAP02_WF_Analytics
  as select from ZR_GSP26SAP02_WF_Analytics
{ 
  // --- DIMENSIONS ---
  @AnalyticsDetails.query.axis: #ROWS
  key BusinessObjectType,
  
  @AnalyticsDetails.query.axis: #ROWS
  key StatusCategory,
  
  @AnalyticsDetails.query.axis: #ROWS
  key PriorityLevel,
  
  @AnalyticsDetails.query.axis: #COLUMNS
  key CreationYearMonth,
  
  // --------filter date--------
  @Consumption.filter: { selectionType: #INTERVAL, multipleSelections: true, mandatory: false }
  @AnalyticsDetails.query.axis: #FREE
  CreationDate,

  @Consumption.filter: { selectionType: #INTERVAL, multipleSelections: true, mandatory: false }
  @AnalyticsDetails.query.axis: #FREE
  EndDate,
  // ---------------------------

  // --- MEASURES ---
  @Aggregation.default: #SUM
  TaskCounter,
  
  @Aggregation.default: #SUM
  IsOpenCount,
  
  @Aggregation.default: #SUM
  IsCompletedCount,

  @Aggregation.default: #SUM
  IsCompletedThisMonth,

  @Aggregation.default: #SUM
  IsOverdueCount
}
