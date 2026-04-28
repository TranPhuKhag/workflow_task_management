@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Workflow Analytics Cube'
@Analytics.dataCategory: #CUBE
define view entity ZR_GSP26SAP02_WF_Analytics
  as select from ZI_GSP26SAP02_WF_Task
{
  key WorkItemID,

      // --- DIMENSIONS ---
      @ObjectModel.text.element: ['BusinessObjectDesc']
      coalesce( BusinessObjectType, 'Unknown' ) as BusinessObjectType,
      
      @EndUserText.label: 'Business Object Name'
      case BusinessObjectType
        when 'BUS1022'                 then 'Customer'
        when 'BUS2009'                 then 'Purchase Requisition'
        when 'BUS2009001'              then 'Purchase Requisition (Overall)'
        when 'BUS2012'                 then 'Purchase Order'
        when 'BUS2032'                 then 'Sales Order'
        when 'CL_EAM_WFL_OBJECT_ORDER' then 'Maintenance Order'
        when 'CL_MM_PUR_WF_OBJECT_PO'  then 'Purchase Order (Flexible)'
        when 'CL_MM_PUR_WF_OBJECT_QTN' then 'Quotation'
        when 'CL_MM_PUR_WF_OBJECT_RFQ' then 'Request for Quotation'
        when 'CL_SD_CMR_WORKFLOW'      then 'Credit Memo Request'
        when 'CR'                      then 'Change Request'
        when 'FORMABSENC'              then 'Leave Request'

        when 'CL_SWF_RUN_MESSAGE'        then 'System Task'
        when 'CL_SWF_UTL_EVT_IDENTIFIER' then 'System Task'
        when 'FLOWITEM'                  then 'System Task'
        when 'SELFITEM'                  then 'System Task'
        when 'SOFM'                      then 'System Task'
        when 'WORKINGWI'                 then 'System Task'

        when 'ZCL_CRP_WF_LEAD_OBJ'           then 'Lead Approval'
        when 'ZCL_WF_CUSTOMER_REG'           then 'Customer Registration'
        when 'ZCL_WF_TEST001'                then 'Workflow Test 001'
        when 'ZCL_WL_APPR_FLEX'              then 'Flexible Approval Worklist'
        when 'ZCPEWS_REQ'                    then 'CPEWS Request'
        when 'ZF24G04_CL_SD_CMR_WORKFLOW_01' then 'Credit Memo Request (Custom)'
        when 'ZZ_CUST_WORKFLOW_CRP'          then 'CRP Workflow'

        else coalesce( BusinessObjectType, 'Unknown' )
      end as BusinessObjectDesc,
      
      coalesce( TaskID, 'Unknown' )             as TaskID,
      CreationDate,
      
      @EndUserText.label: 'Agent (Processor)'
      coalesce( ActualAgent, 'Unassigned' ) as ActualAgent,

      case
        when CreationDate is null then '000000'
        else substring( cast(CreationDate as abap.char(8)), 1, 6 )
      end                                       as CreationYearMonth,

      coalesce( TechnicalStatus, 'Unknown' )    as TechnicalStatus,

      DeadlineStatus,

      case TechnicalStatus
        when 'READY'     then 'Open'
        when 'SELECTED'  then 'Open'
        when 'STARTED'   then 'In Process'
        when 'COMPLETED' then 'Completed'
        when 'CANCELLED' then 'Cancelled'
        when 'ERROR'     then 'Error'
        else 'Others'
      end                                       as StatusCategory,

      case Priority
        when '1' then 'High'
        when '2' then 'High'
        when '3' then 'High'
        when '4' then 'Medium'
        when '5' then 'Medium'
        when '6' then 'Low'
        else 'Low'
      end                                       as PriorityLevel,
      
      
      @EndUserText.label: 'Days Open (Aging)'
      case
        when TechnicalStatus = 'COMPLETED' or TechnicalStatus = 'CANCELLED' 
          or CreationDate is null or CreationDate = '00000000' 
        then 0
        else dats_days_between( CreationDate, $session.system_date )
      end                                       as DaysOpen,

      // aging buckets
      @EndUserText.label: 'Aging Bucket'
      case
        when TechnicalStatus = 'COMPLETED' or TechnicalStatus = 'CANCELLED' then '0. N/A'
        
        when dats_days_between( CreationDate, $session.system_date ) <= 2 
        then '1. 0-2 Days (Normal)'
        
        when dats_days_between( CreationDate, $session.system_date ) between 3 and 7 
        then '2. 3-7 Days (Warning)'
        
        when dats_days_between( CreationDate, $session.system_date ) > 7 
        then '3. >7 Days (Critical)'
        
        else '0. N/A'
      end                                       as AgingBucket,
      
      EndDate,

      // --- MEASURES ---
      @EndUserText.label: 'Total Tasks'
      @Aggregation.default: #SUM
      cast( 1 as abap.int4 )                    as TaskCounter,

      @EndUserText.label: 'Open Tasks'
      @Aggregation.default: #SUM
      cast( case
          when TechnicalStatus = 'READY'
            or TechnicalStatus = 'SELECTED'
            or TechnicalStatus = 'STARTED'
          then 1 else 0
      end as abap.int4 )                        as IsOpenCount,

      @EndUserText.label: 'Completed Tasks'
      @Aggregation.default: #SUM
      cast( case
          when TechnicalStatus = 'COMPLETED'
          then 1 else 0
      end as abap.int4 )                        as IsCompletedCount,

      // completed this month
      @EndUserText.label: 'Completed This Month'
      @Aggregation.default: #SUM
      cast( case
          when TechnicalStatus = 'COMPLETED'
           and substring( cast(CreationDate as abap.char(8)), 1, 6 ) = substring( cast($session.system_date as abap.char(8)), 1, 6 )
          then 1 else 0
      end as abap.int4 )                        as IsCompletedThisMonth,

      // overdue task
      @EndUserText.label: 'Overdue Tasks'
      @Aggregation.default: #SUM
      cast( case
          when ( TechnicalStatus = 'READY' or TechnicalStatus = 'SELECTED' or TechnicalStatus = 'STARTED' )
           and DeadlineStatus = '8998'
          then 1 else 0
      end as abap.int4 )                        as IsOverdueCount,

      @EndUserText.label: 'Cycle Time (Days)'
      @Aggregation.default: #SUM
      cast(
        case
          when TechnicalStatus = 'COMPLETED'
           and EndDate is not null
           and EndDate <> '00000000'
          then dats_days_between( CreationDate, EndDate )
          else 0
        end
      as abap.int4 )                            as CycleTimeDays
}
