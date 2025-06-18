@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS Entity For Product'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZC_Product
  as select from I_Product              as Product
    join         I_ProductDescription   as _Description         on _Description.Product = Product.Product

    join         I_ProductPlantIntlTrd  as _PlantProduct        on _PlantProduct.Product = Product.Product
    join         I_Plant                as _Plant               on _PlantProduct.Plant = _Plant.Plant
    join         I_ProductSalesDelivery as _SalesDelivery       on  Product.Product                = _SalesDelivery.Product
                                                                and _SalesDelivery.ProductSalesOrg = _Plant.SalesOrganization
    join         I_DistributionChannel  as _DistributionChannel on _SalesDelivery.ProductDistributionChnl = _DistributionChannel.DistributionChannel

    join         I_SalesOrganization    as _SalesOrganization   on _SalesDelivery.ProductSalesOrg = _SalesOrganization.SalesOrganization

{
  key Product.Product,
      //Product.ProductType,
      //_SalesDelivery.ProductSalesOrg,
      //_SalesOrganization.CompanyCode,
      //_DistributionChannel.DistributionChannel,
      Product.BaseUnit,
      Product.ProductOldID,
      _Description.ProductDescription,
      _PlantProduct.Plant,
      _PlantProduct.ConsumptionTaxCtrlCode,
      Product.LastChangeDate,
      Product.LastChangedByUser,
      Product.LastChangeTime
}
where
   _SalesOrganization.CompanyCode = 'BNPL' or _SalesOrganization.CompanyCode = 'CAPL'  or _SalesOrganization.CompanyCode = 'BIPL' 
group by Product.Product, 
         Product.BaseUnit, 
         Product.ProductOldID, 
         _Description.ProductDescription, 
         _PlantProduct.Plant, 
         _PlantProduct.ConsumptionTaxCtrlCode, 
         Product.LastChangeDate, 
         Product.LastChangedByUser, 
         Product.LastChangeTime   
    ;
