@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity ZR_CURRENTSTOCK
  as select from zcurrentstock
{
  key plant as Plant,
  key storage_location as StorageLocation,
  key batch as Batch,
  key product as Product,
  key inserted_date as InsertedDate,
  key inserted_time as InsertedTime,
  product_type as ProductType,
  product_name as ProductName,
  @Consumption.valueHelpDefinition: [ {
    entity.name: 'I_UnitOfMeasureStdVH', 
    entity.element: 'UnitOfMeasure', 
    useForValidation: true
  } ]
  material_base_unit as MaterialBaseUnit,
  @Semantics.quantity.unitOfMeasure: 'MaterialBaseUnit'
  matlwrhsstkqtyinmatlbaseunit as MatlWrhsStkQtyInMatlBaseUnit,
  @Semantics.quantity.unitOfMeasure: 'MaterialBaseUnit'
  unposted_stock_inv_value as UnpostedInvStock,
  @Semantics.quantity.unitOfMeasure: 'MaterialBaseUnit'
  unposted_stock_unsold_value as UnpostedUnsoldStock,
  @Semantics.quantity.unitOfMeasure: 'MaterialBaseUnit'
  posted_stock_value as PostedStock,
  @Semantics.quantity.unitOfMeasure: 'MaterialBaseUnit'
  production_stock_value as ProductionStock,  
  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  created_at as CreatedAt,
  @Semantics.user.localInstanceLastChangedBy: true
  local_last_changed_by as LocalLastChangedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed_at as LocalLastChangedAt,
  @Semantics.systemDateTime.lastChangedAt: true
  last_changed_at as LastChangedAt
  
}
