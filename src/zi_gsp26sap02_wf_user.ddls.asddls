@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface View for Workflow User Mapping'
define view entity ZI_GSP26SAP02_WF_USER
  as select from zgsp26_wf_user_r as UserMap
  association to parent ZI_GSP26SAP02_WF_ROLE as _Role on $projection.RoleID = _Role.RoleID
{
  key uname as UserName,
  key role_id as RoleID,
  key valid_from as ValidFrom,
  
  valid_to as ValidTo,
  is_active as IsActive,

  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  created_at as CreatedAt,
  @Semantics.user.localInstanceLastChangedBy: true
  last_changed_by as LastChangedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  last_changed_at as LastChangedAt,

  /* Public Association */
  _Role
}
