//%attributes = {"shared":true}
  //================================================================================
  //@xdoc-start : en
  //@name :  
  //@scope : public
  //@deprecated : no
  //@description : This method method will handle a web connection from an ACME / CA server (and return the predefined challenge response)
  //@parameter[0-OUT-match-BOOLEAN] : TRUE if the url looks like "/.well-known/acme-challenge/@", FALSE otherwise
  //@parameter[1-IN-url-TEXT] : url
  //@notes : the expected connexion is on plain http connexion (not https)
  //@example : 
  //
  //  C_TEXT($1;$vt_url)
  //  C_TEXT($2;$vt_request)
  //  C_TEXT($3;$vt_clientIp)
  //  C_TEXT($4;$vt_serverIp)
  //  C_TEXT($5;$vt_username)
  //  C_TEXT($6;$vt_password)
  //
  //  ASSERT(Count parameters>5;"requires 6 parameters")
  //
  //  $vt_url:=$1
  //  $vt_request:=$2
  //  $vt_clientIp:=$3
  //  $vt_serverIp:=$4
  //  $vt_username:=$5
  //  $vt_password:=$6
  //
  //  Case of 
  //    : (acme_onWebConnection ($vt_url))
  //
  //  Else 
  //
  //  End case 
  //
  //@see : acme_httpChallengePrepare
  //@version : 1.00.00
  //@author : 
  //@history : 
  //  CREATION : Bruno LEGAY (BLE) - 23/06/2018, 18:17:41 - 1.00.00
  //@xdoc-end
  //================================================================================

C_BOOLEAN:C305($0;$vb_match)
C_TEXT:C284($1;$vt_url)

ASSERT:C1129(Count parameters:C259>0;"requires 1 parameters")

$vb_match:=False:C215
$vt_url:=$1

  //<Modif> Bruno LEGAY (BLE) (14/02/2019)
  // the letsencrypt challenge is on a plain http (not https) connexion
If (Not:C34(WEB Is secured connection:C698))
	  //<Modif>
	
	  // "/.well-known/acme-challenge/Loq...X0"
	
	
	  //<Modif> Bruno LEGAY (BLE) (06/09/2019) - v0.90.10
	C_TEXT:C284($vt_token)
	$vb_match:=acme__challengeReqUrlMatch ($vt_url;->$vt_token)
	
	  //C_TEXTE($vt_urlStartTag)
	  //$vt_urlStartTag:="/.well-known/acme-challenge/"
	
	  //C_TEXTE($vt_regex)
	  //$vt_regex:="^/\\.well-known/acme-challenge/(.*)$"
	
	  //C_TEXTE($vt_token)
	  //$vb_match:=TXT_regexGetMatchingGroup ($vt_regex;$vt_url;1;->$vt_token)
	
	  //<Modif>
	
	  //$vb_match:=TXT_isEqualStrict (Sous chaîne($vt_url;1;Longueur($vt_urlStartTag));$vt_urlStartTag)
	  //$vb_match:=($vt_url=$vt_urlStartTag+"@")
	If ($vb_match)
		
		C_OBJECT:C1216($vo_httpServerHeaderObject)
		$vo_httpServerHeaderObject:=acme__httpServerRequestToObject 
		acme__moduleDebugDateTimeLine (4;Current method name:C684;"http request :\r"+JSON Stringify:C1217($vo_httpServerHeaderObject;*))
		
		  //ASSERT(acme__httpServerRequestHdrGet ($vo_httpServerHeaderObject;"accept")="*/*")
		  //ASSERT(acme__httpServerRequestHdrGet ($vo_httpServerHeaderObject;"Host")="www.example.com")
		  //ASSERT(acme__httpServerRequestIsSsl ($vo_httpServerHeaderObject)=Faux)
		  //ASSERT(acme__httpServerRequestMethod ($vo_httpServerHeaderObject)="GET")
		  //ASSERT(acme__httpServerRequestVersion ($vo_httpServerHeaderObject)="HTTP/1.1")
		
		C_TEXT:C284($vt_httpMethod)
		$vt_httpMethod:=acme__httpServerRequestMethod ($vo_httpServerHeaderObject)
		If (($vt_httpMethod="GET") | ($vt_httpMethod="HEAD"))
			
			  //<Modif> Bruno LEGAY (BLE) (06/09/2019) - v0.90.10
			  //C_TEXTE($vt_token)
			  //$vt_token:=Sous chaîne($vt_url;Longueur($vt_urlStartTag)+1)
			  //<Modif>
			
			C_TEXT:C284($vt_challengeDirPath)
			$vt_challengeDirPath:=Get 4D folder:C485(HTML Root folder:K5:20)+".well-known"+Folder separator:K24:12+"acme-challenge"+Folder separator:K24:12
			
			C_TEXT:C284($vt_challengeFilename)
			$vt_challengeFilename:=acme__tokenToFilenameSafe ($vt_token)
			
			C_TEXT:C284($vt_challengeFilePath)
			$vt_challengeFilePath:=$vt_challengeDirPath+$vt_challengeFilename  //$vt_token+".txt"
			
			  // send the challenge with the signature (file generated in acme_httpChallengePrepare)
			If (Test path name:C476($vt_challengeFilePath)=Is a document:K24:1)
				
				C_TEXT:C284($vt_contentType)
				$vt_contentType:="application/octet-stream"
				
				  // set the response http headers
				ARRAY TEXT:C222($tt_headerKey;0)
				ARRAY TEXT:C222($tt_headerValue;0)
				  //acme__httpRequestHeaderCommon (->$tt_headerKey;->$tt_headerValue;$vt_contentType)
				
				APPEND TO ARRAY:C911($tt_headerKey;"Server")
				APPEND TO ARRAY:C911($tt_headerValue;acme__httpHeaderSignature )
				
				APPEND TO ARRAY:C911($tt_headerKey;"Content-Type")
				APPEND TO ARRAY:C911($tt_headerValue;$vt_contentType)
				
				C_BLOB:C604($vx_responseBodyBlob)
				SET BLOB SIZE:C606($vx_responseBodyBlob;0)
				
				DOCUMENT TO BLOB:C525($vt_challengeFilePath;$vx_responseBodyBlob)
				
				  //<Modif> Bruno LEGAY (BLE) (14/02/2019)
				C_BOOLEAN:C305($vb_challengeFileRead)
				$vb_challengeFileRead:=(ok=1)
				ASSERT:C1129($vb_challengeFileRead;"error reading file \""+$vt_challengeFilePath+"\"")
				acme__moduleDebugDateTimeLine (Choose:C955($vb_challengeFileRead;4;2);Current method name:C684;"reading file \""+$vt_challengeFilePath+"\". "+Choose:C955($vb_challengeFileRead;"[OK]";"[KO]"))
				  //<Modif>
				
				If (($vt_httpMethod="HEAD"))  // if "HEAD", send an empty blob but with the right "Content-Length"
					APPEND TO ARRAY:C911($tt_headerKey;"Content-Length")
					APPEND TO ARRAY:C911($tt_headerValue;String:C10(BLOB size:C605($vx_responseBodyBlob)))
					SET BLOB SIZE:C606($vx_responseBodyBlob;0)
				End if 
				
				WEB SET HTTP HEADER:C660($tt_headerKey;$tt_headerValue)
				
				  // send the blob data
				WEB SEND BLOB:C654($vx_responseBodyBlob;$vt_contentType)
				acme__moduleDebugDateTimeLine (4;Current method name:C684;"sending challenge \""+$vt_challengeFilename+"\" : "+String:C10(BLOB size:C605($vx_responseBodyBlob))+" bytes")
				
				  //<Modif> Bruno LEGAY (BLE) (14/02/2019)
				If (True:C214)  // only delete old files (it looks like we need to keep the challenge files for some time, no idea how long just empirical)
					acme__challengeDirCleanup ($vt_challengeDirPath)
				Else   // delete the challege file as soon as it has been requested
					DELETE DOCUMENT:C159($vt_challengeFilePath)
					C_BOOLEAN:C305($vb_challengeFileDeleteOk)
					$vb_challengeFileDeleteOk:=(ok=1)
					ASSERT:C1129($vb_challengeFileDeleteOk;"error deleting file \""+$vt_challengeFilePath+"\"")
					acme__moduleDebugDateTimeLine (Choose:C955($vb_challengeFileDeleteOk;4;2);Current method name:C684;"deleting file \""+$vt_challengeFilePath+"\". "+Choose:C955($vb_challengeFileDeleteOk;"[OK]";"[KO]"))
				End if 
				  //<Modif>
				
				  // clear the blob and header arrays
				SET BLOB SIZE:C606($vx_responseBodyBlob;0)
				
				ARRAY TEXT:C222($tt_headerKey;0)
				ARRAY TEXT:C222($tt_headerValue;0)
				
				  // HTTP/1.1 200 OK
				  // Accept-Ranges: bytes
				  // Connection: keep-alive
				  // Content-Length: 12
				  // Content-Type: application/octet-stream
				  // Date: Mon, 25 Jun 2018 18:19:18 GMT
				  // Expires: Mon, 25 Jun 2018 18:19:16 GMT
				  // Server: 4D/15.0.2
				
				  //SUPPRIMER DOCUMENT($vt_challengeFilePath)
				
				acme__moduleDebugDateTimeLine (4;Current method name:C684;$vt_httpMethod+" url : \""+$vt_url+"\""+", host \""+acme__httpServerRequestHdrGet ($vo_httpServerHeaderObject;"Host")+"\""+", ssl : "+Choose:C955(WEB Is secured connection:C698;"true";"false")+""+", token \""+$vt_token+"\""+", http request "+JSON Stringify:C1217($vo_httpServerHeaderObject;*)+", file \""+$vt_challengeFilePath+"\" sent. [OK]")
				
			Else 
				acme__moduleDebugDateTimeLine (2;Current method name:C684;$vt_httpMethod+" url : \""+$vt_url+"\""+", token \""+$vt_token+"\""+", file \""+$vt_challengeFilePath+"\" not found. [KO]")
			End if 
			
		Else 
			acme__moduleDebugDateTimeLine (4;Current method name:C684;$vt_httpMethod+" url : \""+$vt_url+"\""+", unexpected http method. [OK]")
		End if 
		
		CLEAR VARIABLE:C89($vo_httpServerHeaderObject)
	End if 
	
	  //<Modif> Bruno LEGAY (BLE) (14/02/2019)
End if 
  //<Modif>

$0:=$vb_match