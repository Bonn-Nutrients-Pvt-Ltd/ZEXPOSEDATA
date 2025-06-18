@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Dealer Master Data Definitiom'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zdd_dealer_master_new as select from zdealer_tab_new1
{
    key dealerbctag as Dealerbctag,
    key businesspartner as Businesspartner,
    key comp_code as CompCode,
    dealer_device_id as DealerDeviceId,
    dlradvpymttag as Dlradvpymttag,
    dealerift as Dealerift,
    dealerstation as Dealerstation,
    creditdays as Creditdays,
    dealersmdtag as Dealersmdtag,
    sshqcode as Sshqcode,
    min_bal as MinBal,
    min_bal_date as MinBalDate,
    created_by as CreatedBy,
    created_at as CreatedAt,
    last_changed_by as LastChangedBy,
    last_changed_at as LastChangedAt
}
