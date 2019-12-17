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

GetHeaderValue(headers, key) {
    headers := StrSplit(headers, "`n")
    value := ""
    for index, header in headers {
        found := InStr(header, key)
        if found {
            fullKey := key . ": "
            value := StrReplace(header, fullKey)
            break
        }
    }
    return value
}
