@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption View for WF Substitution'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
//@Search.searchable: true

define root view entity ZC_GSP26SAP02_USER_SUBST
  as projection on ZI_GSP26SAP02_USER_SUBST as Subst
{
  key Subst.UserSubstitutedBy,
  key Subst.UserSubstitutedFor,
  key Subst.BeginDate,
      Subst.EndDate,

      @Consumption.valueHelpDefinition: [{
      entity: {
          name:    'ZCE_GSP26SAP02_SubstProfile',
          element: 'ProfileId'
      },
      label: 'Select Profile',
      distinctValues: true
      }]
      @EndUserText.label: 'Substitution Profile'
      Subst.SubstitutionProfile,
      Subst.Active,
      Subst.SubstitutionType,

      Subst.Direction,
      Subst.RuleStatus,

      Subst.DaysToStart,

      SubstituteFullName,
      OwnerFullName
}
where
  (
       Subst.UserSubstitutedBy  = $session.user
    or Subst.UserSubstitutedFor = $session.user
  )
  and(
       Subst.SubstitutionType   = 'U'
    or Subst.SubstitutionType   = 'P'
  )
  and  Subst.EndDate            >= $session.system_date
