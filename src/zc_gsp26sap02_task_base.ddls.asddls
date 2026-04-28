@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption- Technical Status'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZC_GSP26SAP02_TASK_BASE
  as select from ZR_GSP26SAP02_TASK_BASE
{
    key  readyCount,
    key  reservedCount,
    key  inProcessCount,
    key  waitingCount,
    key  executedCount,
    key  completedCount,
    key  deletedCount,
    key  errorCount,
    key  checkedCount
}
