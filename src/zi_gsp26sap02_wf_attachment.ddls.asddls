@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Root View for Workflow Attachments'
@Metadata.ignorePropagatedAnnotations: true

define view entity ZI_GSP26SAP02_WF_Attachment
  as select from    sww_wi2obj         as wi2obj
    left outer join ZI_GSP26SAP02_SOFM as Attachment on wi2obj.instid = Attachment.ObjectID

    left outer join zgsp26_mime        as Mime       on Mime.file_ext = lower(
      Attachment.FileExtension
    )
  association to parent ZR_GSP26SAP02_MyInbox as _MyInbox on $projection.WorkItemID = _MyInbox.WorkItemID
{
  key   wi2obj.wi_id                                                         as WorkItemID,
  key   Attachment.ObjectID                                                  as ObjectID,
        Attachment.DocumentClass,
        Attachment.ObjectYear,
        Attachment.ObjectNumber,
        Attachment.DocumentName,
        Attachment.DocumentTitle,
        Attachment.OwnerType,
        Attachment.OwnerYear,
        Attachment.OwnerNumber,
        Attachment.OwnerName,
        Attachment.CreatedBy,
        Attachment.DateCreated,
        Attachment.CreatedAt,
        Attachment.ChangedOn,
        Attachment.ChangedAt,
        Attachment.FileExtension,
        Attachment.DocumentSize,
        Attachment.ObjectType,
        Attachment.NewFileContent,
        Mime.mime_type                                                       as MimeType,
        case when Attachment.OwnerName = $session.user then 'X' else ' ' end as IsDeletable,
        _MyInbox

}
where

      wi2obj.typeid           = 'SOFM'
  and wi2obj.wi_reltype       = '03'
  and Attachment.DocumentName = 'ATTACHMENT'
