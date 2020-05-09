//%attributes = {"invisible":true,"preemptive":"capable","shared":false}
  //================================================================================
  //@xdoc-start : en
  //@name : ENV_onWindows
  //@scope : private
  //@deprecated : no
  //@description : This function returns TRUE if running on Windows, FALSE otherwise
  //@parameter[0-OUT-onWindows-BOOLEAN] : TRUE if running on Windows, FALSE otherwise
  //@notes : 
  //@example : ENV_onWindows
  //@see : 
  //@version : 1.00.00
  //@author : 
  //@history : 
  // CREATION : Bruno LEGAY (BLE) - 23/06/2018, 18:34:03 - 1.00.00
  //@xdoc-end
  //================================================================================

C_BOOLEAN:C305($0;$vb_onWindows)

$vb_onWindows:=Is Windows:C1573  // 4D v17

  //C_LONGINT($vl_plateform)
  //PLATFORM PROPERTIES($vl_plateform)
  //$vb_onWindows:=($vl_plateform=Windows)

$0:=$vb_onWindows