@Metadata.allowExtensions: true
@EndUserText.label: '###GENERATED Core Data Service Entity'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity ZC_CURRENTSTOCK
  as select from  ZR_CURRENTSTOCK
{
  key Plant,
  key StorageLocation,
  key Batch,
  key Product,
  ProductType,
  ProductName,
  MaterialBaseUnit,
  MatlWrhsStkQtyInMatlBaseUnit,
  UnpostedInvStock,
  UnpostedUnsoldStock,
  PostedStock,
  ProductionStock  
}
where 
    (
        InsertedDate = $session.system_date and 
        InsertedTime >= cast('01:00:00' as abap.tims)
    )
    or 
    (
        InsertedDate = dats_add_days($session.system_date, 1, 'INITIAL') and 
        InsertedTime < cast('01:00:00' as abap.tims)
    )
