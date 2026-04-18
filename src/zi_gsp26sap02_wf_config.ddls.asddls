@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface View for Workflow Configuration'
define view entity ZI_GSP26SAP02_WF_CONFIG
  as select from zgsp26_wf_conf
{
  key wf_type     as WorkflowType,
      srv_path    as ServicePath,
      entity_set  as EntitySet,
      sub_ent_set as SubEntitySet,
      expand_nav  as ExpandNavigations,
      expand_nav2 as ExpandNavigations2,
      sem_obj     as SemanticObject,
      sem_act     as SemanticAction
}
