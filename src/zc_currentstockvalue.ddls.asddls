@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS for Stock value'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZC_CurrentSTOCKVALUE
 as select from I_StockQuantityCurrentValue_2 ( P_DisplayCurrency : 'INR' ) as Stock
 join I_ProductText as _Text on _Text.Product = Stock.Product
{
    key Stock.Plant,
    key Stock.StorageLocation,
    key Stock.Batch,
    key Stock.Product,
    Stock.ProductType,
    _Text.ProductName,
    Stock.MaterialBaseUnit,
    @Semantics.quantity.unitOfMeasure: 'MaterialBaseUnit'
    sum(Stock.MatlWrhsStkQtyInMatlBaseUnit) as StockQty
    
}
where Stock.ValuationAreaType = '1'
group by Stock.Product,Stock.ProductGroup,Stock.ProductType ,Stock.Plant,Stock.StorageLocation,Stock.Batch,Stock.MaterialBaseUnit,_Text.ProductName
