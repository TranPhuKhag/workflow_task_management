@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Current Logged-in User Role'
define root view entity ZI_GSP26SAP02_Current_Role
  as select from zgsp26_wf_user_r as UserMap
    inner join   zgsp26_wf_role   as Role on UserMap.role_id = Role.role_id
{
  key UserMap.uname       as UserName,
  key Role.role_id        as RoleID,
      Role.role_name      as RoleName,
      Role.role_level     as RoleLevel,
      UserMap.valid_from  as ValidFrom,
      UserMap.valid_to    as ValidTo
}
where UserMap.uname      = $session.user
  and UserMap.is_active  = 'X'
  and UserMap.valid_from <= $session.system_date
  and ( UserMap.valid_to >= $session.system_date 
     or UserMap.valid_to is initial 
     or UserMap.valid_to = '00000000' )
