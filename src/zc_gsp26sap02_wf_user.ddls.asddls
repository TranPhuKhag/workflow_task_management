@EndUserText.label: 'Projection View for Workflow User'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity ZC_GSP26SAP02_WF_USER
  as projection on ZI_GSP26SAP02_WF_USER
{
  key UserName,
  key RoleID,
  key ValidFrom,
  ValidTo,
  IsActive,
  CreatedBy,
  CreatedAt,
  LastChangedBy,
  LastChangedAt,
  
  /* Associations */
  _Role : redirected to parent ZC_GSP26SAP02_WF_ROLE
}
