@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Base Interface for SAP Office Object Definition'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_GSP26SAP02_SOFM
  as select from    sood
    left outer join sofm                           on  sood.objtp = sofm.doctp
                                                   and sood.objyr = sofm.docyr
                                                   and sood.objno = sofm.docno
    left outer join zgsp26_attachmen as Attachment on Attachment.objectid = concat(
      sofm.foltp, concat(
        sofm.folyr, concat(
          sofm.folno, concat(
            sood.objtp, concat(
              sood.objyr, sood.objno
            )
          )
        )
      )
    )
{
  key sood.objtp         as DocumentClass,
  key sood.objyr         as ObjectYear,
  key sood.objno         as ObjectNumber,
      sood.objnam        as DocumentName,
      sood.objdes        as DocumentTitle,
      sood.owntp         as OwnerType,
      sood.ownyr         as OwnerYear,
      sood.ownno         as OwnerNumber,
      sood.ownnam        as OwnerName,
      sood.cronam        as CreatedBy,
      sood.crdat         as DateCreated,
      sood.crtim         as CreatedAt,
      sood.chdat         as ChangedOn,
      sood.chtim         as ChangedAt,
      sood.objlen        as DocumentSize,
      sofm.doctp         as ObjectType,
      sofm.foltp         as FolderType,
      sofm.folyr         as FolderYear,
      sofm.folno         as FolderNumber,
      abap.rawstring'00' as NewFileContent,
      //abap.string'' as NewFileContent,
      
        case when Attachment.file_extension is not null 
        then Attachment.file_extension 
        else sood.file_ext end as FileExtension,
      concat( sofm.foltp,
          concat( sofm.folyr,
              concat( sofm.folno,
                  concat( sood.objtp,
                      concat( sood.objyr, sood.objno )
                  )
              )
          )
      )                  as ObjectID

}
