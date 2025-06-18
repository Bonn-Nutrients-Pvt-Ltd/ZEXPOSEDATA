CLASS zcl_savestockvalue DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

  INTERFACES if_apj_dt_exec_object .
    INTERFACES if_apj_rt_exec_object .

    INTERFACES if_oo_adt_classrun .
CLASS-METHODS getCID RETURNING VALUE(cid) TYPE abp_behv_cid.
    METHODS runJob.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_savestockvalue IMPLEMENTATION.

METHOD runJob.
  SELECT
    Stock~Plant,
    Stock~StorageLocation,
    Stock~Batch,
    Stock~Product,
    Stock~ProductType,
    _Text~ProductName,
    Stock~MaterialBaseUnit,
    SUM( Stock~MatlWrhsStkQtyInMatlBaseUnit ) AS StockQty
    FROM I_StockQuantityCurrentValue_2( P_DisplayCurrency = 'INR' ) AS Stock
    INNER JOIN I_ProductText AS _Text
      ON _Text~Product = Stock~Product
    WHERE Stock~ValuationAreaType = '1'
    GROUP BY Stock~Product,
             Stock~ProductGroup,
             Stock~ProductType,
             Stock~Plant,
             Stock~StorageLocation,
             Stock~Batch,
             Stock~MaterialBaseUnit,
             _Text~ProductName
    INTO TABLE @DATA(result).

  SELECT SINGLE FROM zintegration_tab
        FIELDS intgpath
        WHERE intgmodule = 'FGSTORAGELOCATION'
        INTO @DATA(StLoc).

  LOOP AT result INTO DATA(fs_result).

    IF StLoc = fs_result-StorageLocation.

      SELECT SINGLE FROM zc_invoicedatatab1000 AS a
        INNER JOIN zc_invmst_unposted AS b ON b~CompCode = a~CompCode AND b~Plant = a~Plant
                      AND a~Idfyear = b~Imfyear AND a~Idtype = b~Imtype AND a~Idno = b~Imno
        FIELDS SUM( a~Idprdqty ) AS unpostedQty
          WHERE a~idprdbatch = @fs_result-Batch
            AND a~plant = @fs_result-Plant
            AND a~idprdcode = @fs_result-Product
        INTO @DATA(unposted_sales_qty).

      SELECT SINGLE FROM zc_usdatadata1 AS a
          INNER JOIN zc_unsold_unposted AS b ON a~CompCode = b~CompCode AND a~Plant = b~Plant
                      AND a~Idfyear = b~Imfyear AND a~Idtype = b~Imtype AND a~Idno = b~Imno
          FIELDS SUM( a~Idprdqty ) AS unpostedQty
          WHERE a~idprdbatch = @fs_result-Batch
            AND a~plant = @fs_result-Plant
            AND a~idprdcode = @fs_result-Product
          INTO @DATA(unposted_return_qty).

    ENDIF.

    " SUM OF Billed  orders from yesterday 7:00 AM to today 7:00 AM
    DATA(yesterday) = cl_abap_context_info=>get_system_date( ) - 1.
    DATA(today) = cl_abap_context_info=>get_system_date( ).
    SELECT SINGLE FROM  I_BillingDocumentItem
      FIELDS SUM( BillingQuantity )
      WHERE BillingDocumentDate >= @yesterday
        AND CreationTime >= '070000'
        AND BillingDocumentDate <= @today
        AND CreationTime < '070000'
        AND Product = @fs_result-Product
        AND Plant = @fs_result-Plant
        AND StorageLocation = @fs_result-StorageLocation
        AND Batch = @fs_result-Batch
        INTO @DATA(billed_qty).

    SELECT SINGLE FROM ZI_ProductionConfirmation
        FIELDS SUM( ConfirmationYieldQuantity ) AS prod_qty
        WHERE Material = @fs_result-Product
            AND Plant = @fs_result-Plant
            AND StorageLocation = @fs_result-StorageLocation
            AND Batch = @fs_result-Batch
            AND ConfirmationEntryTime >= '070000'
            AND ConfirmationEntryTime < '070000'
            AND ConfirmationEntryDate >= @yesterday
            AND ConfirmationEntryDate <= @today
        INTO @DATA(prod_qty).

    MODIFY ENTITIES OF zr_currentstock
    ENTITY ZrCurrentstock
    CREATE FIELDS (
      Plant
      StorageLocation
      Batch
      Product
      ProductType
      ProductName
      MaterialBaseUnit
      MatlWrhsStkQtyInMatlBaseUnit
      UnpostedInvStock
      UnpostedUnsoldStock
      PostedStock
      ProductionStock
      InsertedDate
      InsertedTime
    )
    WITH VALUE #(
      (
        %cid = getCID( )
        Plant = fs_result-Plant
        StorageLocation = fs_result-StorageLocation
        Batch = fs_result-Batch
        Product = fs_result-Product
        ProductType = fs_result-ProductType
        ProductName = fs_result-ProductName
        MaterialBaseUnit = fs_result-MaterialBaseUnit
        MatlWrhsStkQtyInMatlBaseUnit = fs_result-StockQty
        UnpostedInvStock = unposted_sales_qty
        UnpostedUnsoldStock = unposted_return_qty
        PostedStock = billed_qty
        ProductionStock = prod_qty
        InsertedDate = cl_abap_context_info=>get_system_date( )
        InsertedTime = cl_abap_context_info=>get_system_time( )
         ) )
    MAPPED DATA(fs_mapped)
    FAILED DATA(fs_failed)
    REPORTED DATA(fs_report).

    COMMIT ENTITIES BEGIN
       RESPONSE OF zr_oipayments
       FAILED DATA(ls_save_failed)
       REPORTED DATA(ls_save_reported).
    ...
    COMMIT ENTITIES END.
  ENDLOOP.


ENDMETHOD.

 METHOD getCID.
        TRY.
            cid = to_upper( cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( ) ).
          CATCH cx_uuid_error.
            ASSERT 1 = 0.
        ENDTRY.
      ENDMETHOD.


 METHOD if_apj_dt_exec_object~get_parameters.
    " Return the supported selection parameters here
    et_parameter_def = VALUE #(
      ( selname = 'S_ID'    kind = if_apj_dt_exec_object=>select_option datatype = 'C' length = 10 param_text = 'My ID'                                      changeable_ind = abap_true )
      ( selname = 'P_DESCR' kind = if_apj_dt_exec_object=>parameter     datatype = 'C' length = 80 param_text = 'My Description'   lowercase_ind = abap_true changeable_ind = abap_true )
      ( selname = 'P_COUNT' kind = if_apj_dt_exec_object=>parameter     datatype = 'I' length = 10 param_text = 'My Count'                                   changeable_ind = abap_true )
      ( selname = 'P_SIMUL' kind = if_apj_dt_exec_object=>parameter     datatype = 'C' length =  1 param_text = 'Full Processing' checkbox_ind = abap_true  changeable_ind = abap_true )
    ).

    " Return the default parameters values here
    et_parameter_val = VALUE #(
      ( selname = 'S_ID'    kind = if_apj_dt_exec_object=>select_option sign = 'I' option = 'EQ' low = '4711' )
      ( selname = 'P_DESCR' kind = if_apj_dt_exec_object=>parameter     sign = 'I' option = 'EQ' low = 'My Default Description' )
      ( selname = 'P_COUNT' kind = if_apj_dt_exec_object=>parameter     sign = 'I' option = 'EQ' low = '200' )
      ( selname = 'P_SIMUL' kind = if_apj_dt_exec_object=>parameter     sign = 'I' option = 'EQ' low = abap_false )
    ).
  ENDMETHOD.


  METHOD if_apj_rt_exec_object~execute.
    runJob(  ).
  ENDMETHOD.

  METHOD if_oo_adt_classrun~main.
    runJob( ).
  ENDMETHOD.
ENDCLASS.
