@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface View for Workflow Role'
define root view entity ZI_GSP26SAP02_WF_ROLE
  as select from zgsp26_wf_role as Role
  composition [0..*] of ZI_GSP26SAP02_WF_USER as _UserMapping
{
  key role_id as RoleID,
  role_name as RoleName,
  role_level as RoleLevel,
  
  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  
  @Semantics.systemDateTime.createdAt: true
  created_at as CreatedAt,
  
  @Semantics.user.localInstanceLastChangedBy: true
  last_changed_by as LastChangedBy,
  
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  last_changed_at as LastChangedAt,
  
  _UserMapping
}
//where Role.role_id = 'ZGSP26_WF_ADMIN'
