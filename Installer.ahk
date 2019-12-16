
url := "https://api.github.com/repos/" . "ZsoltMolnarrr/RSACF" . "/releases/latest"
token := ""

Request(method, url, accessToken := 0) {
	request := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	request.Open(method, url, true)
	request.SetRequestHeader("Accept", "application/json")
	if accessToken {
		request.SetRequestHeader("Authorization", "token " . accessToken)
	}

	request.Send(Data)
	request.WaitForResponse()

	status := request.Status
	body := request.ResponseText

	return {status: status, body: body}
}

response := Request("GET", url, token)

message := "status: " . response.status . " body: " . response.body
MsgBox, %message%
