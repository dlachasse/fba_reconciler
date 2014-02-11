for /f %%i in ("%0") do set curpath=%%~dpi 
cd /d %curpath%
@call rake update_fba_status["_GET_FBA_MYI_UNSUPPRESSED_INVENTORY_DATA_"]
