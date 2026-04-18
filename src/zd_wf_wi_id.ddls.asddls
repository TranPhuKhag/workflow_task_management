@EndUserText.label: 'Abstract Entity for List WorkItemIds'
define abstract entity ZD_WF_WI_ID
{
    WorkItemID : sww_wiid;
    _BulkParam : association to parent ZD_WF_BULK_PARAM ; 
}
