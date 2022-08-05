//%attributes = {}
#DECLARE($method : Text; $url : Text; $content : Variant; $response : Variant; $headerNames_ptr : Pointer; $headerValues_ptr : Pointer)->$status : Integer

If (Count parameters:C259=4)
	EXECUTE METHOD:C1007("cUrl_HttpRequest"; $status; $method; $url; $content; $response)
Else 
	EXECUTE METHOD:C1007("cUrl_HttpRequest"; $status; $method; $url; $content; $response; $headerNames_ptr; $headerValues_ptr)
End if 