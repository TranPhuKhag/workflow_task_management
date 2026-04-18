@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Workflow Performance Query'
@Analytics.query: true
@OData.publish: true
define view entity ZC_GSP26SAP02_WF_Perf
  as select from ZR_GSP26SAP02_WF_Analytics
{
      // --- DIMENSIONS ---
      @AnalyticsDetails.query.axis: #ROWS
      @ObjectModel.text.element: ['BusinessObjectDesc']
      @UI.textArrangement: #TEXT_ONLY
  key BusinessObjectType,

      @AnalyticsDetails.query.axis: #ROWS
  key TaskID,

      @AnalyticsDetails.query.axis: #ROWS
  key StatusCategory,

      @AnalyticsDetails.query.axis: #COLUMNS
  key CreationYearMonth,

      BusinessObjectDesc,

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
      IsCompletedCount,

      @Aggregation.default: #SUM
      CycleTimeDays

      // Avg Cycle Time = CycleTimeDays / IsCompletedCount
}
