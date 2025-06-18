@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS Entity For Business Partner'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZC_BUSPART as select from I_Customer as Customer
join I_CustomerCompany as CompanyCode on CompanyCode.Customer = Customer.Customer
join I_RegionText as Region on Region.Region = Customer.Region and Region.Country = Customer.Country
join I_BusinessPartner as BPCustomer on BPCustomer.BusinessPartner = Customer.Customer
{
    key Customer.Customer,
    BPCustomer.BusinessPartnerIDByExtSystem as ExternalBPNumber,
    Customer.CustomerName,
    Customer.TaxNumber3 as GSTIN,
    CompanyCode.CompanyCode,
    Customer.Region,
    Region.RegionName,
    Customer.TelephoneNumber1,
    Customer.BPAddrStreetName,
    Customer.BPAddrCityName,
    BPCustomer.LastChangeDate,
    BPCustomer.LastChangedByUser,
    BPCustomer.LastChangeTime
} 
