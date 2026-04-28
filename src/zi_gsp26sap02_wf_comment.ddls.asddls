@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Root View for Workflow Comments'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_GSP26SAP02_WF_Comment
  as select from    sww_wi2obj         as wi2obj
    left outer join ZI_GSP26SAP02_SOFM as Comment on wi2obj.instid = Comment.ObjectID
  association to parent ZR_GSP26SAP02_MyInbox as _MyInbox on $projection.WorkItemID = _MyInbox.WorkItemID
{
  key  wi2obj.wi_id     as WorkItemID,
  key  Comment.ObjectID as ObjectID,
       Comment.DocumentClass,
       Comment.ObjectYear,
       Comment.ObjectNumber,
       Comment.DocumentName,
       Comment.DocumentTitle,
       Comment.OwnerType,
       Comment.OwnerYear,
       Comment.OwnerNumber,
       Comment.OwnerName,
       Comment.CreatedBy,
       Comment.DateCreated,
       Comment.CreatedAt,
       Comment.ChangedOn,
       Comment.ChangedAt,
       Comment.FileExtension,
       Comment.DocumentSize,
       Comment.ObjectType,
       abap.string'' as Note,
       _MyInbox
       
}
where
      wi2obj.typeid        = 'SOFM'
  and wi2obj.wi_reltype    = '09'
  and Comment.DocumentName = 'COMMENT'
