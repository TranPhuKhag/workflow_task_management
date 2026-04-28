@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface View for Substitution'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_GSP26SAP02_USER_SUBST
  as select from    hrus_d2         as Subst

    left outer join I_BusinessUser  as _SubstituteUser on Subst.rep_name = _SubstituteUser.UserID
    left outer join I_BusinessUser  as _OwnerUser      on Subst.us_name = _OwnerUser.UserID

    left outer join zuser_subst_ext as _Ext            on  Subst.us_name  = _Ext.us_name
                                                       and Subst.rep_name = _Ext.rep_name
                                                       and Subst.begda    = _Ext.begda

{
  key Subst.rep_name                 as UserSubstitutedBy,
  key Subst.us_name                  as UserSubstitutedFor,
  key Subst.begda                    as BeginDate,
      Subst.endda                    as EndDate,
      Subst.reppr                    as SubstitutionProfile,
      Subst.active                   as Active,
      //      Subst.zzsubst_type             as SubstitutionType,

      _Ext.zzsubst_type              as SubstitutionType,

      case
        when Subst.us_name = $session.user
          then 'OUTGOING'
        else 'INCOMING'
      end                            as Direction,

      case
        when Subst.endda <> '99991231' and Subst.begda > $session.system_date
          then 'Inactive'
        else 'Active'
      end                            as RuleStatus,

      case
        when _Ext.zzsubst_type = 'P' and Subst.begda > $session.system_date
          then dats_days_between( $session.system_date, Subst.begda )
        else 0
      end                            as DaysToStart,

      _SubstituteUser.PersonFullName as SubstituteFullName,
      _OwnerUser.PersonFullName      as OwnerFullName
}
