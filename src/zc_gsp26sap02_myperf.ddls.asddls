@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'My Productivity Query'
@Analytics.query: true
@OData.publish: true
define view entity ZC_GSP26SAP02_MyPerf
  as select from ZR_GSP26SAP02_MyPerfCube
{
      // --- DIMENSIONS ---
      @AnalyticsDetails.query.axis: #ROWS
  key CompletionDate,

      @AnalyticsDetails.query.axis: #ROWS
  key BusinessObjectType,

      BusinessObjectDesc,

      // --- MEASURES ---
      @Aggregation.default: #SUM
      CompletedCount,

      @Aggregation.default: #SUM
      TotalProcessingDays,

      @Aggregation.default: #SUM
      CompletedOnTimeCount
}
