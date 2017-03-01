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
			call writeRoastsTable("")
		case "writeRoastsPicker"
			strRoastIds = request.querystring("graphedRoasts[]")&""
			call writeRoastsTable(strRoastIds)
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
			rawBeanWeight = int(request.querystring("rawBeanWeight"))
			call saveRoast(roastId, beanId, roastIntentId, rawBeanWeight)
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
			beanPrice = int(request.querystring("beanPrice"))
			beanIntentId = int(request.querystring("beanIntentId"))
			beanNote = request.querystring("beanNote")
			beanOwnerId = int(request.querystring("beanOwnerId"))
			beanSupplierId = int(request.querystring("beanSupplierId"))
			beanLocationId = int(request.querystring("beanLocationId"))
			beanAmountPurchased = int(request.querystring("beanAmountPurchased"))
			beanAmountAdjustment = int(request.querystring("beanAmountAdjustment"))
			beanPurchaseDate = request.querystring("beanPurchaseDate")
			call saveBean(beanId, beanName, beanPrice, beanIntentId, beanNote, beanOwnerId, beanSupplierId, beanLocationId, beanAmountPurchased, beanAmountAdjustment, beanPurchaseDate)
		case "deletePicture"
			roastId = int(request.querystring("roastId"))
			call deletePicture(roastId)
		case "writeBeanOwnersTable"
			call writeBeanOwnersTable()
		case "writeBeanOwner"
			beanOwnerId = int(request.querystring("beanOwnerId"))
			call writeBeanOwner(beanOwnerId)
		case "deleteBeanOwner"
			beanOwnerId = int(request.querystring("beanOwnerId"))
			call deleteBeanOwner(beanOwnerId)
		case "saveBeanOwner"
			beanOwnerId = int(request.querystring("beanOwnerId"))
			beanOwnerName = request.querystring("beanOwnerName")
			call saveBeanOwner(beanOwnerId, beanOwnerName)
		case "writeLocationsTable"
			call writeLocationsTable()
		case "writeLocation"
			locationId = int(request.querystring("locationId"))
			call writeLocation(locationId)
		case "deleteLocation"
			locationId = int(request.querystring("locationId"))
			call deleteLocation(locationId)
		case "saveLocation"
			locationId = int(request.querystring("locationId"))
			locationName = request.querystring("locationName")
			call saveLocation(locationId, locationName)
		case "writeSuppliersTable"
			call writeSuppliersTable()
		case "writeSupplier"
			supplierId = int(request.querystring("supplierId"))
			call writeSupplier(supplierId)
		case "deleteSupplier"
			supplierId = int(request.querystring("supplierId"))
			call deleteSupplier(supplierId)
		case "saveSupplier"
			supplierId = int(request.querystring("supplierId"))
			supplierName = request.querystring("supplierName")
			call saveSupplier(supplierId, supplierName)
	end select
end if
%>
<!--#include virtual="/charts/includes/conn_close.asp"-->