@EndUserText.label: 'Abstract Entity for Bulk Delegation Parameter'
 define root abstract entity ZD_WF_BULK_PARAM
 {
      USER_ID : syst_uname;
      _WorkItems  : composition [0..*] of ZD_WF_WI_ID; 
 }
