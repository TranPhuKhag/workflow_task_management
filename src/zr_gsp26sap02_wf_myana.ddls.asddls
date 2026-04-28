@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Cube for My Action Center'
@Analytics.dataCategory: #CUBE
define view entity ZR_GSP26SAP02_Wf_MyAna
  as select from ZR_GSP26SAP02_MyInbox
{
  key WorkItemID,

      // --- DIMENSIONS ---
      BusinessObjectType,
      Priority,

      @EndUserText.label: 'Priority'
      cast( PriorityText as abap.char(20) )        as PriorityText,

      CreationDate,
      ActualDeadlineDate,

      TechnicalStatus,

      @EndUserText.label: 'Status'
      cast( TechnicalStatusText as abap.char(20) ) as TechnicalStatusText,

      // --- MEASURES ---
      @EndUserText.label: 'My Open Tasks'
      @Aggregation.default: #SUM
      cast( case
          when TechnicalStatus = 'READY'
            or TechnicalStatus = 'SELECTED'
            or TechnicalStatus = 'STARTED'
          then 1 else 0
      end as abap.int4 )                           as MyOpenTasksCount,

      @EndUserText.label: 'Due Today'
      @Aggregation.default: #SUM
      cast( case
          when ( TechnicalStatus = 'READY' or TechnicalStatus = 'SELECTED' or TechnicalStatus = 'STARTED' )
           and ActualDeadlineDate = $session.system_date
          then 1 else 0
      end as abap.int4 )                           as DueTodayCount,

      @EndUserText.label: 'My Overdue Tasks'
      @Aggregation.default: #SUM
      cast( case
          when ( TechnicalStatus = 'READY' or TechnicalStatus = 'SELECTED' or TechnicalStatus = 'STARTED' )
           and IsOverdue = 'X'
          then 1 else 0
      end as abap.int4 )                           as MyOverdueCount
}
