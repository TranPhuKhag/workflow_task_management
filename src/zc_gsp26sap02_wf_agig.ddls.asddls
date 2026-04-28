@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Workflow Aging & Bottleneck Query'
@Analytics.query: true
@OData.publish: true
define view entity ZC_GSP26SAP02_WF_Agig
  as select from ZR_GSP26SAP02_WF_Analytics
{
      // --- DIMENSIONS ---
      @AnalyticsDetails.query.axis: #ROWS
      @ObjectModel.text.element: ['BusinessObjectDesc']
      @UI.textArrangement: #TEXT_ONLY
  key BusinessObjectType,

      @AnalyticsDetails.query.axis: #ROWS
  key TaskID,

      @AnalyticsDetails.query.axis: #COLUMNS
  key AgingBucket,

      @AnalyticsDetails.query.axis: #ROWS
  key PriorityLevel,

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
      IsOpenCount,

      @Aggregation.default: #SUM
      IsOverdueCount
}
