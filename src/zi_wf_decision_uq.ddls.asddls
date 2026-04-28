@EndUserText.label: 'Custom Entity for Unmanaged Workflow Decision Query'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_WF_QUERY_DECISIONS'
define custom entity ZI_WF_DECISION_UQ
{
  key WorkItemID   : sww_wiid;
  key DecisionKey  : swr_decikey;
      DecisionText : swr_decitext;
      Nature       : swr_nature;
      
}
