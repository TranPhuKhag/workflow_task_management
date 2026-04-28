@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Cube for My Productivity'
@Analytics.dataCategory: #CUBE
define view entity ZR_GSP26SAP02_MyPerfCube
  as select from ZI_GSP26SAP02_WF_Task
{
  key WorkItemID,

      // --- DIMENSIONS ---
      coalesce( BusinessObjectType, 'Unknown') as BusinessObjectType,

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
      end                                      as BusinessObjectDesc,

      @EndUserText.label: 'Completion Date'
      EndDate                                  as CompletionDate,

      // --- MEASURES ---

      @EndUserText.label: 'Completed Tasks'
      @Aggregation.default: #SUM
      cast( case
          when TechnicalStatus = 'COMPLETED'
           and ActualAgent = $session.user
           and EndDate is not null
           and EndDate <> '00000000'
           and EndDate <> '99991231'
          then 1 else 0
      end as abap.int4 )                       as CompletedCount,

      @EndUserText.label: 'Total Processing Days'
      @Aggregation.default: #SUM
      cast( case
          when TechnicalStatus = 'COMPLETED'
           and ActualAgent = $session.user
           and EndDate is not null and EndDate <> '00000000'
           and CreationDate is not null and CreationDate <> '00000000'
          then dats_days_between( CreationDate, EndDate )
          else 0
      end as abap.int4 )                       as TotalProcessingDays,

      @EndUserText.label: 'Completed On Time'
      @Aggregation.default: #SUM
      cast( case
          when TechnicalStatus = 'COMPLETED'
           and ActualAgent = $session.user
           and ( DeadlineStatus <> '8998' )
          then 1 else 0
      end as abap.int4 )                       as CompletedOnTimeCount
}
where
  ActualAgent = $session.user
