#Include %A_ScriptDir%/JSON.ahk

SetWorkingDir %A_ScriptDir%

url := "https://api.github.com/repos/" . "ZsoltMolnarrr/RSACF" . "/releases/latest"
FileRead, token, token.txt

Request(method, url, accessToken := 0, format := "json", allowRedirect := true) {
	request := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	request.Open(method, url, true)
	request.SetRequestHeader("Accept", "application/" . format)
	if accessToken {
		request.SetRequestHeader("Authorization", "token " . accessToken)
	}
	request.Option(6) := allowRedirect

	request.Send(Data)
	request.WaitForResponse()

	status := request.Status
	body := request.ResponseText
	headers := request.GetAllResponseHeaders()

	return {status: status, body: body, headers: headers}
}

DisplayError(reason, response) {
	message := reason . "`n status: " . response.status . " body: " . response.body
	;"response headers: " . response.headers
	MsgBox, , Error!, %message%
}

response := Request("GET", url, token)
parsed := JSON.Load(response.body)

zip_url := parsed.zipball_url
asset_id := parsed.assets[1].id

asset_url := "https://api.github.com/repos/" . "ZsoltMolnarrr/RSACF" . "/releases/assets/" . asset_id
response := Request("GET", asset_url, token, "octet-stream", false)
headers := StrSplit(response.headers, "`n")
locationHeader := ""
for index, header in headers {
	found := InStr(header, "Location")
	if found {
		locationHeader := StrReplace(header, "Location: ")
		break
	}
}

if response.status == 302 && locationHeader {
	UrlDownloadToFile, %locationHeader%, RSACF.zip
} else {
	DisplayError("Failed to redirect", response)
}

FileRemoveDir, RSACF.zip

;UnZip(RSACF.zip, RSACF)


;MsgBox, %download_url%
;message := "token: " . token . "status: " . response.status . " body: " . response.body . " response headers: " . response.headers
;MsgBox, %message%
;MsgBox, %zip_url%

;Gui, add, edit, h100 , %asset_url%
;Gui, Show
;Return
