@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption - Comment'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@ObjectModel.usageType:{ serviceQuality: #X, sizeCategory: #S, dataClass: #MIXED }

define view entity ZC_GSP26SAP02_WF_Comment
  as projection on ZI_GSP26SAP02_WF_Comment
{
  key WorkItemID,
  key ObjectID,
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
      DocumentSize,
      ObjectType,
      @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_GSP26SAP02_CALC_COMMENT'
  virtual  CommentText : abap.string(0),
      Note,
      _MyInbox.AssignedUserName,
      /* Associations */
      _MyInbox : redirected to parent ZC_GSP26SAP02_MyInbox
}   
        
