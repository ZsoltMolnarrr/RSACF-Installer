#SingleInstance,Force
SetWorkingDir %A_ScriptDir%
#Include %A_ScriptDir%/Network.ahk
#Include %A_ScriptDir%/JSON.ahk
#Include %A_ScriptDir%/Zip.ahk

url := "https://api.github.com/repos/" . "ZsoltMolnarrr/RSACF" . "/releases/latest"
FileRead, token, token.txt

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

FileRemoveDir, RSACF
sleep 200

zip := A_ScriptDir . "\RSACF.zip"
dir := A_ScriptDir . "\RSACF"
Unzip(zip, dir)

FileDelete, RSACF.zip

DisplayError(reason, response) {
	message := reason . "`n status: " . response.status . " body: " . response.body
	;"response headers: " . response.headers
	MsgBox, , Error!, %message%
}

class Package {
	name := ""
	author := ""
	accessToken := ""

	__New(name, author, accessToken) {
		this.name := name
		this.author := author
		this.accessToken := accessToken
	}
}

class Release {
	version := ""
	changelog := ""
}

;MsgBox, %download_url%
;message := "token: " . token . "status: " . response.status . " body: " . response.body . " response headers: " . response.headers
;MsgBox, %message%
;MsgBox, %zip_url%

;Gui, add, edit, h100 , %asset_url%
;Gui, Show
;Return
