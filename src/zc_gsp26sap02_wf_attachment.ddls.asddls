@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption - Attachment'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@ObjectModel.usageType:{ serviceQuality: #X, sizeCategory: #S, dataClass: #MIXED }

define view entity ZC_GSP26SAP02_WF_Attachment
  as projection on ZI_GSP26SAP02_WF_Attachment
{
  key      WorkItemID,
  key      ObjectID,
           DocumentClass,
           ObjectYear,
           ObjectNumber,
           DocumentName,
           DocumentTitle,
           OwnerType,
           OwnerYear,
           OwnerNumber,
           OwnerName,
           CreatedBy,
           DateCreated,
           CreatedAt,
           ChangedOn,
           ChangedAt,
           FileExtension,
           @Semantics.mimeType: true
           MimeType,
           DocumentSize,
           ObjectType,
           @EndUserText.label: 'File Content'
           @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_GSP26SAP02_CALC_ATTACHMENT'
           @Semantics.largeObject: {
           mimeType: 'MimeType',
           fileName: 'DocumentTitle',
           contentDispositionPreference: #ATTACHMENT
           }
  virtual  Content : abap.rawstring(0),
           @Semantics.largeObject: {
                   mimeType: 'MimeType',
                   fileName: 'DocumentTitle',
                     contentDispositionPreference: #INLINE
                   }

           NewFileContent,
           IsDeletable,

           /* Associations */
           _MyInbox : redirected to parent ZC_GSP26SAP02_MyInbox
}
