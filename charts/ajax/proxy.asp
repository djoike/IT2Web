<!--#include virtual="/charts/includes/conn_create.asp"-->
<!--#include virtual="/charts/includes/basic_inc.asp"-->
<%
f = request.querystring("function")
if f&""="" then
	f = request.form("function")
end if

if f&""<>"" then
	select case f
		case "writeRoastsTable"
			call writeRoastsTable()
		case "writeRoast"
			roastId = int(request.querystring("roastId"))
			call writeRoastData(roastId)
		case "getRoastData"
			response.ContentType = "application/json"
			strRoastIds = request.form("roastIds[]")&""
			call getRoastData(strRoastIds)			
	end select
end if
%>
<!--#include virtual="/charts/includes/conn_close.asp"-->