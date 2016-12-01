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
	end select
end if
%>
<!--#include virtual="/charts/includes/conn_close.asp"-->