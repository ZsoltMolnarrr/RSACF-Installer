#SingleInstance,Force
SetWorkingDir %A_ScriptDir%
#Include %A_ScriptDir%/Network.ahk
#Include %A_ScriptDir%/JSON.ahk
#Include %A_ScriptDir%/Zip.ahk

FileRead, token, RSACF-token.txt
RSACF := new Package("RSACF", "ZsoltMolnarrr", token)
Resolve(RSACF)

Resolve(package) {
	; Setup Github context
	github_api_basepath := "https://api.github.com/"
	repository :=  package.author . "/" . package.name
	api_repo_url := github_api_basepath . "repos/" . repository
	accessToken := package.accessToken

	; Setup output files
	zip_name := package.name . ".zip"
	zip_path := A_ScriptDir . "\" . zip_name
	dir_name := package.name
	dir_path := A_ScriptDir . "\" . dir_name

	DisplayProgress("Checking")

	; Fetch info about the latest release
	url := api_repo_url . "/releases/latest"
	response := Request("GET", url, accessToken)
	release := JSON.Load(response.body)
	asset_id := release.assets[1].id
	version := release.tag_name

	DisplayProgress("Downloading")

	; Retrieve the asset url
	url := api_repo_url . "/releases/assets/" . asset_id
	response := Request("GET", url, accessToken, "octet-stream", false)
	download_url := GetHeaderValue(response.headers, "Location")

	; Download the asset
	if response.status == 302 && download_url {
		UrlDownloadToFile, %download_url%, %zip_name%
	} else {
		DisplayError("Failed to redirect " . response.headers, response)
	}

	DisplayProgress("Installing")

	; Remove previous installation
	FileRemoveDir, %dir_name%
	sleep 200	; Safety frist :)

	; Unzip new version
	Unzip(zip_path, dir_path)

	; Cleanup zip
	FileDelete, %zip_name%

	DisplayCompletion("Installed " . version)
}

DisplayError(reason, response) {
	message := reason . "`n status: " . response.status . " body: " . response.body
	MsgBox, , Error!, %message%
}

DisplayProgress(message) {
	SplashTextOn , 150 , 50 , RSACF Installer, %message%
}

DisplayCompletion(message) {
	SplashTextOff
	MsgBox, , RSACF Installer, %message%
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
