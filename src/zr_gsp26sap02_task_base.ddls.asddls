@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Root - Technical Status'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZR_GSP26SAP02_TASK_BASE
  as select from ZR_GSP26SAP02_MyInbox as MyInbox
{
  key   sum( case when MyInbox.TechnicalStatus = 'READY'     then 1 else 0 end ) as readyCount,
  key   sum( case when MyInbox.TechnicalStatus = 'SELECTED'  then 1 else 0 end ) as reservedCount,
  key   sum( case when MyInbox.TechnicalStatus = 'STARTED'   then 1 else 0 end ) as inProcessCount,
  key   sum( case when MyInbox.TechnicalStatus = 'WAITING'   then 1 else 0 end ) as waitingCount,
  key   sum( case when MyInbox.TechnicalStatus = 'COMMITTED' then 1 else 0 end ) as executedCount,
  key   sum( case when MyInbox.TechnicalStatus = 'COMPLETED' then 1 else 0 end ) as completedCount,
  key   sum( case when MyInbox.TechnicalStatus = 'CANCELLED' then 1 else 0 end ) as deletedCount,
  key   sum( case when MyInbox.TechnicalStatus = 'ERROR'     then 1 else 0 end ) as errorCount,
  key   sum( case when MyInbox.TechnicalStatus = 'CHECKED'   then 1 else 0 end ) as checkedCount
}
