@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Workflow Agent Workload Query'
@Analytics.query: true
@OData.publish: true
define view entity ZC_GSP26SAP02_WF_AGT
  as select from ZR_GSP26SAP02_WF_Analytics
{
      // --- DIMENSIONS ---
      @AnalyticsDetails.query.axis: #ROWS
  key ActualAgent,

      @AnalyticsDetails.query.axis: #ROWS
  key BusinessObjectType,

      @AnalyticsDetails.query.axis: #COLUMNS
  key StatusCategory,

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
      IsOpenCount,

      @Aggregation.default: #SUM
      IsCompletedCount,

      @Aggregation.default: #SUM
      CycleTimeDays,

      @Aggregation.default: #SUM
      IsOverdueCount
}
