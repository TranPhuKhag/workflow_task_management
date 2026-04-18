@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View for ZI_GSP26SAP02_WF_ROLE'
@ObjectModel.semanticKey: [ 'RoleID' ]
define root view entity ZC_GSP26SAP02_WF_ROLE
  provider contract transactional_query
  as projection on ZI_GSP26SAP02_WF_ROLE
{
  key RoleID,
  RoleName,
  RoleLevel,
  CreatedBy,
  CreatedAt,
  LastChangedBy,
  LastChangedAt,
  
  _UserMapping : redirected to composition child ZC_GSP26SAP02_WF_USER
}
