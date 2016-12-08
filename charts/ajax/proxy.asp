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
		case "saveRoast"
			roastId = int(request.querystring("roastId"))
			beanId = int(request.querystring("beanId"))
			roastIntentId = int(request.querystring("roastIntentId"))
			call saveRoast(roastId, beanId, roastIntentId)
		case "writeBeansTable"
			call writeBeansTable()
		case "writeBean"
			beanId = int(request.querystring("beanId"))
			call writeBeanData(beanId)
		case "deleteBean"
			beanId = int(request.querystring("beanId"))
			call deleteBean(beanId)
		case "deleteRoast"
			roastId = int(request.querystring("roastId"))
			call deleteRoast(roastId)	
		case "saveBean"
			beanId = int(request.querystring("beanId"))
			beanName = request.querystring("beanName")
			beanIntentId = int(request.querystring("beanIntentId"))
			call saveBean(beanId, beanName, beanIntentId)
	end select
end if
%>
<!--#include virtual="/charts/includes/conn_close.asp"-->