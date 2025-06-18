@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Cds For Production Confirmation Qty'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_ProductionConfirmation as 
select from I_MfgOrderConfirmation as PP

join I_ManufacturingOrder           as _MfgOrder  on PP.ManufacturingOrder = _MfgOrder.ManufacturingOrder

join I_MaterialDocumentItem_2 as _MfgOrderDocdItem on PP.MaterialDocument = _MfgOrderDocdItem.MaterialDocument and PP.MaterialDocumentYear = _MfgOrderDocdItem.MaterialDocumentYear
                and ( _MfgOrderDocdItem.GoodsMovementType = '101' or _MfgOrderDocdItem.GoodsMovementType = '102' )

join I_MfgOrderDocdGoodsMovement as _MfgOrderDocdGoodsMovement on PP.ManufacturingOrder = _MfgOrderDocdGoodsMovement.ManufacturingOrder
                    and PP.MaterialDocument = _MfgOrderDocdGoodsMovement.GoodsMovement
                    and PP.MaterialDocumentYear = _MfgOrderDocdGoodsMovement.GoodsMovementYear    
                    and _MfgOrderDocdItem.GoodsMovementType = _MfgOrderDocdGoodsMovement.GoodsMovementType 
join I_ProductDescription as Product on Product.Product = _MfgOrder.Material
{

    key PP.MfgOrderConfirmationGroup             as ConfirmationGroup,
    key PP.MfgOrderConfirmation                  as ConfirmationCount,
    PP.CompanyCode                               as CompanyCode,          
    PP.Plant,
    _MfgOrderDocdGoodsMovement.StorageLocation,
    _MfgOrderDocdGoodsMovement.Batch,
    _MfgOrder.Material,
    Product._Product.ProductType,
    Product.ProductDescription,
    PP.MfgOrderConfirmationEntryDate             as ConfirmationEntryDate,
    PP.MfgOrderConfirmationEntryTime             as ConfirmationEntryTime,
    PP.PostingDate,
    @Semantics.quantity.unitOfMeasure: 'ConfirmationUnit'
    case when _MfgOrderDocdItem.GoodsMovementType = '102' 
            then -PP.ConfirmationYieldQuantity 
         else PP.ConfirmationYieldQuantity end 
         as ConfirmationYieldQuantity,
//    PP.ConfirmationYieldQuantity,
    PP.ConfirmationUnit,
    case when _MfgOrderDocdItem.GoodsMovementIsCancelled = 'X' then 'X'
         when _MfgOrderDocdItem.GoodsMovementType = '102' then 'X'
         else '' end as IsCancelled,
    _MfgOrderDocdItem.GoodsMovementType
    
}
//where 
//    (
//        PP.MfgOrderConfirmationEntryDate = $session.system_date and 
//        PP.MfgOrderConfirmationEntryTime >= cast('07:00:00' as abap.tims)
//    )
//    or 
//    (
//        PP.MfgOrderConfirmationEntryDate = dats_add_days($session.system_date, 1, 'INITIAL') and 
//        PP.MfgOrderConfirmationEntryTime < cast('07:00:00' as abap.tims)
//    ) 
