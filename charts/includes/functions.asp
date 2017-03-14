<%
function e(byval str)
	e = Server.HTMLEncode(str&"")
end function

function lz_1(byval i)
	lz_1 = right("0" & i,2)
end function

function dateTimeAsTime(byval dateTime)
	dateTimeAsTime = lz_1(hour(dateTime)) &":"& lz_1(minute(dateTime)) &":"& lz_1(second(dateTime))
end function

function secondsAsTime(byval seconds)
	secs = lz_1(seconds mod 60)
	mins = lz_1(int(seconds/60))
	secondsAsTime = mins &":"& secs
end function

function dashIfNull(byval str)
	if str&""="" then
		dashIfNull = "-"
	else
		dashIfNull = str
	end if
end function

function getRoastsSQL(byval roastId, byval minimumLogCount)
	if roastId > -1 then
		roastId = int(roastId)
		strWhereSQL  = " AND (Roast.Id = "&roastId&")"
	end if
	if minimumLogCount = -1 then
		minimumLogCount = 10
	else
		minimumLogCount = int(minimumLogCount)
	end if
	strSQL = "SELECT Roast.Id, Roast.StartTime, Roast.EndTime, Profile.Name AS ProfileName, Roast.ManualControlStartTime,"&_
				" COUNT(DISTINCT RoastLog.Id) AS LogCount, DATEDIFF(ss, Roast.StartTime, Roast.EndTime) AS Duration, Bean.Name AS BeanName, Bean.Id AS BeanId,"&_
				" RoastIntent.Id AS RoastIntentId, RoastIntent.RoastIntent, Roast.pictureName, Roast.RawBeanWeight, Roast.FinancialOwnerId"&_
				" FROM Roast INNER JOIN"&_
				" RoastLog ON Roast.Id = RoastLog.RoastId LEFT OUTER JOIN"&_
				" RoastIntent ON Roast.RoastIntentId = RoastIntent.Id LEFT OUTER JOIN"&_
				" Bean ON Roast.BeanId = Bean.Id LEFT OUTER JOIN"&_
				" Profile ON Roast.ProfileId = Profile.Id"&_
				" GROUP BY Roast.Id, Roast.Active, Roast.StartTime, Profile.Name, Roast.ManualControlStartTime, RoastLog.RoastId, Roast.EndTime, Bean.Name, Bean.Id, RoastIntent.Id, RoastIntent.RoastIntent, Roast.pictureName, Roast.RawBeanWeight, Roast.FinancialOwnerId"&_
				" HAVING (Roast.Active = 1) AND (COUNT(DISTINCT RoastLog.Id) > "&minimumLogCount&")"& strWhereSQL &_
				" ORDER BY Roast.Id DESC"
	getRoastsSQL = strSQL
end function

function getRoastLogSQL(byval roastIds)
	roastIds = replace(roastIds,"'","")
	strSQL = "SELECT RoastLog.RoastId, RoastLog.Temperature, CONVERT(VARCHAR(40), RoastLog.LogTime - Roast.StartTime, 126) AS ElapsedDate"&_
				" FROM RoastLog LEFT OUTER JOIN"&_
				" Roast ON RoastLog.RoastId = Roast.Id"&_
				" WHERE (RoastLog.RoastId IN ("&roastIds&"))"&_
				" ORDER BY RoastLog.RoastId, RoastLog.Id"
	getRoastLogSQL = strSQL
end function

function deactivateBean(byval beanId)
	beanId = int(beanId)
	strSQL = "UPDATE Bean SET Active = 0 WHERE Id = " & beanId
	conn.execute(strSQL)
end function

function activateBean(byval beanId)
	beanId = int(beanId)
	strSQL = "UPDATE Bean SET Active = 1 WHERE Id = " & beanId
	conn.execute(strSQL)
end function

function getBeanStatus(byval beanId)
	beanId = int(beanId)
	returnVal = 0

	strSQL = "SELECT Active FROM Bean WHERE Id = " & beanId
	set rsActive = conn.execute(strSQL)
	if not rsActive.eof then
		if rsActive("Active") then
			returnVal = 1
		else
			returnVal = -1
		end if
	end if
	getBeanStatus = returnVal
end function

function handleBeanDelete(byval beanId)
	beanStatus = getBeanStatus(beanId)
	if beanStatus = 1 then
		deactivateBean(beanId)
	elseif beanStatus = -1 then
		activateBean(beanId)
	end if
end function

function deleteRoast(byval roastId)
	roastId = int(roastId)
	strSQL = "UPDATE Roast SET Active = 0 WHERE Id = " & roastId
	conn.execute(strSQL)
end function

function getRoastData(byval roastIds)
	roastIds = replace(roastIds,"'","")
	response.write("{""data"":[")
	
	first = true
	for each roastId in split(roastIds,",")
		roastId = trim(roastId)
		if not first then
			first = true
			response.write(",")
		end if

		strData = "["
		set rsData = conn.execute(getRoastLogSQL(roastId))
		'response.write(getRoastLogSQL(roastId))
		do while not rsData.eof
			temp = rsData("Temperature")
			if temp < 0 then
				temp = 0
			end if
			strData = strData & "{""x"":""" & rsData("ElapsedDate") & """,""y"":"""&replace(round(temp,2),",",".") & """},"
			rsData.MoveNext
		loop
		rsData.close
		set rsData = nothing

		if len(strData) > 1 then
			strData = left(strData, len(strData)-1) & "]"
		else
			strData = strData & "]"
		end if
		
		response.write("{""roastId"": """&roastId&""",""data"":"&strData&"}")
		
		
		first = false
	next


	response.write("]}")
end function

function getBeansSQL(byval beanId)
	if beanId > -1 then
		beanId = int(beanId)
		strWhereSQL = " AND (Bean.Id = "& beanId &")"
	end if
	getBeansSQL = "SELECT Bean.Id, Bean.Name, BeanIntent.Id AS BeanIntentId, BeanIntent.Name AS BeanIntentName,"&_
					" Bean.Note, BeanSupplier.Id AS BeanSupplierId, BeanSupplier.Name AS BeanSupplierName,"&_ 
					" BeanOwner.Id AS BeanOwnerId, BeanOwner.Name AS BeanOwnerName, BeanLocation.Id AS BeanLocationId,"&_
					" BeanLocation.Name AS BeanLocationName, Bean.Price, Bean.AmountPurchased, Bean.AmountAdjustment,"&_
					" Bean.PurchaseDate, Bean.Active,"&_
					" ((Bean.AmountPurchased + Bean.AmountAdjustment) - "&_
						" (SELECT SUM(RawBeanWeight) AS AmountRoasted"&_
						" FROM Roast"&_
						" WHERE (BeanId = Bean.Id)))"&_
					" AS AmountRemaining"&_
					" FROM Bean LEFT OUTER JOIN"&_
					" BeanLocation ON Bean.BeanLocationId = BeanLocation.Id AND BeanLocation.Active = 1 LEFT OUTER JOIN"&_
					" BeanOwner ON Bean.BeanOwnerId = BeanOwner.Id AND BeanOwner.Active = 1 LEFT OUTER JOIN"&_
					" BeanSupplier ON Bean.BeanSupplierId = BeanSupplier.Id AND BeanSupplier.Active = 1 LEFT OUTER JOIN"&_
					" BeanIntent ON Bean.BeanIntentId = BeanIntent.Id"&_
					" WHERE (1 = 1)" & strWhereSQL &_
					" ORDER BY Bean.Name"
end function

function getRoastIntentsSQL(byval intentId)
	if intentId >-1 then
		intentId = int(intentId)
		strWhereSQL = " WHERE (Id = "& intentId &")"
	end if
	getRoastIntentsSQL = "SELECT Id, RoastIntent FROM RoastIntent" & strWhereSQL & " ORDER BY RoastIntent"
end function

function getBeanIntentsSQL(byval intentId)
	if intentId >-1 then
		intentId = int(intentId)
		strWhereSQL = " WHERE (Id = "& intentId &")"
	end if
	getBeanIntentsSQL = "SELECT Id, Name FROM BeanIntent" & strWhereSQL & " ORDER BY Name"
end function

function saveRoast(byval roastId, byval beanId, byval roastIntentId, byval rawBeanWeight, byval financialOwnerId)
	roastId = int(roastId)
	beanId = int(beanId)
	if beanId = 0 then
		beanId = "NULL"
	end if
	roastIntentId = int(roastIntentId)
	if roastIntentId = 0 then
		roastIntentId = "NULL"
	end if
	financialOwnerId = int(financialOwnerId)
	if financialOwnerId = 0 then
		financialOwnerId = "NULL"
	end if
	rawBeanWeight = int(rawBeanWeight)

	strSQL = "UPDATE Roast SET BeanId = " & beanId & ", RoastIntentId = " & roastIntentId & ", RawBeanWeight = "&rawBeanWeight&", FinancialOwnerId = "&financialOwnerId&" WHERE Id = " & roastId
	conn.execute(strSQL)
end function

function saveBean(byval beanId, byval beanName, byval beanPrice, byval beanIntentId, byval beanNote, byval beanOwnerId, byval beanSupplierId, byval beanLocationId, byval beanAmountPurchased, byval beanAmountAdjustment, byval beanPurchaseDate)
	beanId = int(beanId)
	beanPrice = int(beanPrice)
	beanName = replace(beanName&"","'","''")
	beanNote = replace(beanNote&"","'","''")
	beanOwnerId = int(beanOwnerId)
	beanSupplierId = int(beanSupplierId)
	beanLocationId = int(beanLocationId)
	beanAmountPurchased = int(beanAmountPurchased)
	beanAmountAdjustment = int(beanAmountAdjustment)
	beanPurchaseDate = replace(beanPurchaseDate&"","'","''")

	if isDate(beanPurchaseDate) then
		beanPurchaseDate = "'"&beanPurchaseDate&"'"
	else
		beanPurchaseDate = "NULL"
	end if

	if beanIntentId = 0 then
		beanIntentId = "NULL"
	end if
	if beanOwnerId = 0 then
		beanOwnerId = "NULL"
	end if
	if beanSupplierId = 0 then
		beanSupplierId = "NULL"
	end if
	if beanLocationId = 0 then
		beanLocationId = "NULL"
	end if

	if beanId > 0 then
		strSQL = "UPDATE Bean SET Name = '" & beanName & "', Price = "&beanPrice&", BeanIntentId = " & beanIntentId & ", Note = '" & beanNote & "', BeanOwnerId = "&beanOwnerId&" , BeanSupplierId = "&beanSupplierId&" , BeanLocationId = "&beanLocationId&","&_
			" AmountPurchased = "&beanAmountPurchased&", AmountAdjustment = "&beanAmountAdjustment&", PurchaseDate = "&beanPurchaseDate&" WHERE Id = " & beanId
	else
		strSQL = "INSERT INTO Bean (Name, Price, BeanIntentId, Note, BeanOwnerId, BeanSupplierId, BeanLocationId,beanAmountPurchased, beanAmountAdjustment, beanPurchaseDate) VALUES ('"&beanName&"',"&beanPrice&","&beanIntentId&",'"&beanNote&"',"&beanOwnerId&","&beanSupplierId&","&beanLocationId&","&beanAmountPurchased&","&beanAmountAdjustment&","&beanPurchaseDate&")"
	end if
	conn.execute(strSQL)
end function

function deleteFile(byval fileNameWithPath)
	Set fs=Server.CreateObject("Scripting.FileSystemObject")

	if fs.FileExists(fileNameWithPath) then
		fs.DeleteFile(fileNameWithPath)
	end if

	set fs = nothing
end function

function deletePicture(byval roastId)
	set rsRoast = conn.execute(getRoastsSQL(roastId,0))
	if not rsRoast.eof then
		fileName = rsRoast("pictureName")
		if fileName&""<>"" then
			
			fileUploadPath = Server.MapPath("/charts/uploaded/")
			smallPath = "\small"
			largePath = "\large"
			megaPath = "\mega"

			call deleteFile(fileUploadPath & smallPath & "\" & fileName)
			call deleteFile(fileUploadPath & largePath & "\" & fileName)
			call deleteFile(fileUploadPath & megaPath & "\" & fileName)

			conn.execute("UPDATE Roast SET pictureName = NULL WHERE (Id = "&roastId&")")
		end if
	end if
	set rsRoast = nothing
end function

sub writeRoastsTable(byval strRoastIds)
	writePicker =  strRoastIds&""<>""
	if writePicker then
		for each str in split(strRoastIds,",")
			strRoastIds = strRoastIds & "," & trim(str)
		next
	end if
	%>
	<table class="table table-hover roast-list-table">
		<thead>
			<tr>
				<th>ID</th>
				<th>Date</th>
				<th>Profile</th>
				<th class="hidden-xs">Start time</th>
				<th class="hidden-xs">Duration</th>
				<th class="hidden-xs">Manual</th>
				<th class="">Bean</th>
				<th class="hidden-xs">Intent</th>
				<th class="hidden-xs">Amount</th>
				<th><%if writePicker then%>Add<%else%>View<%end if%></th>
				<%if not writePicker then%><th><span class="glyphicon glyphicon-remove"></span></th><%end if%>
			</tr>
		</thead>
		<tbody>
			<%
			set rsRoasts = conn.execute(getRoastsSQL(-1,-1))
			do while not rsRoasts.eof
				roastID = rsRoasts("Id")
				roastStartTime = rsRoasts("StartTime")
				
				roastDate = ""
				if isDate(roastStartTime) then
					roastStartTime = cdate(roastStartTime)
					roastDate = lz_1(day(roastStartTime)) &"-"& lz_1(month(roastStartTime)) &"<span class='hidden-xs'>-"& year(roastStartTime) &"</span>"
					roastStartTime = dateTimeAsTime(roastStartTime)
				else
					roastDate = "-"
					roastStartTime = "-"
				end if

				roastEndTime = dashIfNull(rsRoasts("EndTime"))
				if isDate(roastEndTime) then
					roastEndTime = cdate(roastEndTime)
					roastEndTime = dateTimeAsTime(roastEndTime)
				end if

				roastDuration = dashIfNull(rsRoasts("Duration"))
				if roastDuration&""<>"-" then
					roastDuration = secondsAsTime(roastDuration)
				end if

				roastProfileName = dashIfNull(rsRoasts("ProfileName"))
				
				roastManualControlStartTime = rsRoasts("ManualControlStartTime")
				if isDate(roastManualControlStartTime) then
					roastManualControlStarted = "<span class=""glyphicon glyphicon-ok""></span>"
				else
					roastManualControlStarted = "<span class=""glyphicon glyphicon-remove""></span>"
				end if
				
				roastLogCount = rsRoasts("LogCount")

				roastBean = dashIfNull(rsRoasts("BeanName"))

				roastIntent = dashIfNull(rsRoasts("RoastIntent"))

				rawBeanWeight = int(rsRoasts("RawBeanWeight"))

				alreadyPicked = writePicker AND instr(","&strRoastIds&",",","&roastID&",")>0
				%>
				<tr data-roast-id="<%=roastID%>">
					<td><%=e(roastID)%></td>
					<td><%=roastDate%></td>
					<td><%=e(roastProfileName)%></td>
					<td class="hidden-xs"><%=e(roastStartTime)%></td>
					<td class="hidden-xs"><%=e(roastDuration)%></td>
					<td class="hidden-xs"><%=roastManualControlStarted%></td>
					<td class=""><%=e(roastBean)%></td>
					<td class="hidden-xs"><%=e(roastIntent)%></td>
					<td class="hidden-xs"><%=e(rawBeanWeight)%> g</td>
					<td class="view-column <%if alreadyPicked then%>picked<%end if%>">
						<span>Added</span>
						<a href="<%if writePicker then%>javascript:void(0);<%else%>/charts/pages/roast.asp?roastid=<%=e(roastID)%><%end if%>"><%if writePicker then%>Add<%else%>View<%end if%></a>
					</td>
					<%if not writePicker then%><td class="remove-column"><span class="glyphicon glyphicon-remove"></span></td><%end if%>
				</tr>
				<%
				rsRoasts.MoveNext
			loop
			rsRoasts.close
			set rsRoasts = nothing
			%>
		</tbody>
	</table>
	<%if writePicker then%>
	<div class="col-xs-12">
		<div class="form-group pull-right">
			<button class="btn btn-primary btn-save">Save</button>
		</div>
	</div>
	<%end if%>
	<%
end sub


sub writeRoastData(byval roastId)
	roastId = int(roastId)
	%>
	<div class="roast-data-list clearfix">
		<%
		set rsRoasts = conn.execute(getRoastsSQL(roastId,0))
		if not rsRoasts.eof then
			roastID = rsRoasts("Id")
			roastStartTime = rsRoasts("StartTime")
			roastDate = ""
			if isDate(roastStartTime) then
				roastStartTime = cdate(roastStartTime)
				roastDate = lz_1(day(roastStartTime)) &"-"& lz_1(month(roastStartTime)) & "-" & year(roastStartTime)
				roastStartTime = dateTimeAsTime(roastStartTime)
			else
				roastDate = "-"
				roastStartTime = "-"
			end if
			roastEndTime = rsRoasts("EndTime")
			if isDate(roastEndTime) then
				roastEndTime = cdate(roastEndTime)
				roastEndTime = dateTimeAsTime(roastEndTime)
			else
				roastEndTime = "-"
			end if

			roastDuration = dashIfNull(rsRoasts("Duration"))
			if roastDuration&""<>"-" then
				roastDuration = secondsAsTime(roastDuration)
			end if

			roastProfileName = rsRoasts("ProfileName")
			if roastProfileName&"" = "" then
				roastProfileName = "-"
			end if
			roastManualControlStartTime = rsRoasts("ManualControlStartTime")
			if isDate(roastManualControlStartTime) then
				roastManualControlStartTime = cdate(roastManualControlStartTime)
				roastManualControlStartTime = dateTimeAsTime(roastManualControlStartTime)
			else
				roastManualControlStartTime = "-"
			end if
			roastLogCount = rsRoasts("LogCount")

			roastPictureName = rsRoasts("pictureName")

			roastBeanId = rsRoasts("BeanId")
			roastIntentId = rsRoasts("RoastIntentId")
			financialOwnerId = rsRoasts("FinancialOwnerId")

			rawBeanWeight = int(rsRoasts("RawBeanWeight"))
			%>
			<div class="col-xs-12">
				<div class="form-group">
					<label>Id</label>
					<p class="form-control-static"><%=e(roastID)%></p>
				</div>
			</div>
			<div class="col-xs-12">
				<div class="form-group">
					<label>Date</label>
					<p class="form-control-static"><%=roastDate%></p>
				</div>
			</div>
			<div class="col-xs-12">
				<div class="form-group">
					<label>Profile</label>
					<p class="form-control-static"><%=e(roastProfileName)%></p>
				</div>
			</div>
			<div class="col-xs-12">
				<div class="form-group">
					<label>Bean</label>
					<select class="form-control" data-for="beanId">
						<option value="0">-</option>
						<%
						set rsBeans = conn.execute(getBeansSQL(-1))
						do while not rsBeans.eof
							beanId = rsBeans("Id")
							beanName = rsBeans("Name")
							%><option value="<%=int(beanId)%>"<%if beanId = roastBeanId then%> selected<%end if%>><%=e(beanName)%></option><%
							rsBeans.MoveNext
						loop
						rsBeans.close
						set rsBeans = nothing
						%>
					</select>
				</div>
			</div>
			<div class="col-xs-12">
				<div class="form-group">
					<label>Intent</label>
					<select class="form-control" data-for="roastIntentId">
						<option value="0">-</option>
						<%
						set rsIntents = conn.execute(getRoastIntentsSQL(-1))
						do while not rsIntents.eof
							intentId = rsIntents("Id")
							intentName = rsIntents("RoastIntent")
							%><option value="<%=int(intentId)%>"<%if intentId = roastIntentId then%> selected<%end if%>><%=e(intentName)%></option><%
							rsIntents.MoveNext
						loop
						rsIntents.close
						set rsIntents = nothing
						%>
					</select>
				</div>
			</div>
			<div class="col-xs-12">
				<div class="form-group">
					<label>Beneficiary</label>
					<select class="form-control" data-for="financialOwnerId">
						<option value="0">-</option>
						<%
						set rsOwners = conn.execute(getBeanOwnersSQL(-1))
						do while not rsOwners.eof
							ownerId = rsOwners("Id")
							ownerName = rsOwners("Name")
							%><option value="<%=int(ownerId)%>"<%if ownerId = financialOwnerId then%> selected<%end if%>><%=e(ownerName)%></option><%
							rsOwners.MoveNext
						loop
						rsOwners.close
						set rsOwners = nothing
						%>
					</select>
				</div>
			</div>
			<div class="col-xs-12">
				<div class="form-group">
					<label>Raw bean weight (gram)</label>
					<input type="text" class="form-control" data-for="rawBeanWeight" value="<%=e(rawBeanWeight)%>" pattern="\d*" />
				</div>
			</div>
			<div class="col-xs-12">
				<div class="form-group">
					<label>Start time</label>
					<p class="form-control-static"><%=e(roastStartTime)%></p>
				</div>
			</div>
			<div class="col-xs-12">
				<div class="form-group">
					<label>Duration</label>
					<p class="form-control-static"><%=e(roastDuration)%></p>
				</div>
			</div>
			<div class="col-xs-12">
				<div class="form-group">
					<label>Manual control start time</label>
					<p class="form-control-static"><%=e(roastManualControlStartTime)%></p>
				</div>
			</div>
			<div class="col-xs-12">
				<div class="form-group">
					<label>Log count</label>
					<p class="form-control-static"><%=e(roastLogCount)%></p>
				</div>
			</div>
			<div class="col-xs-12">
				<div class="form-group">
					<label>Photo</label>
					<%
					if roastPictureName&""<>"" then
						%>
						<div class="existing-photo clearfix">
							<img class="img-responsive thumbnail" src="/charts/uploaded/small/<%=e(roastPictureName)%>"
							srcset="/charts/uploaded/small/<%=e(roastPictureName)%> 300w, /charts/uploaded/large/<%=e(roastPictureName)%> 800w, /charts/uploaded/mega/<%=e(roastPictureName)%> 1600w" border="0" />
							<button class="btn btn-small btn-default btn-delete col-xs-12">Delete&nbsp;&nbsp;&nbsp;<span class="glyphicon glyphicon-remove"></span></button>
						</div>
						<%
					else
						%>
						<input type="file" id="file" name="roastImage">
						<div class="live-photo clearfix">
							<img class="img-responsive live-thumb thumbnail">
							<button class="btn btn-default btn-rotate">Rotér&nbsp;&nbsp;&nbsp;<span class="glyphicon glyphicon-retweet"></span></button><div class="pull-right"><span class="rotate-degs lead">(0&deg;)</span></div>
							<button class="btn btn-primary btn-upload col-xs-12">Upload</button>
						</div>
						<%
					end if
					%>
				</div>
			</div>
			<div class="col-xs-12">
				<div class="form-group pull-right">
					<button class="btn btn-primary btn-save">Save</button>
					<button class="btn btn-default btn-back">Back</button>
				</div>
			</div>
			<%
		end if
		rsRoasts.close
		set rsRoasts = nothing
		%>
	</div>
	<%
end sub

sub writeBeansTable()
	set rsBeans = conn.execute(getBeansSQL(-1))
	if not rsBeans.eof then
		%>
		<table class="table table-hover">
			<thead>
				<tr>
					<th class="hidden-xs">ID</th>
					<th>Name</th>
					<th class="hidden-xs">Intent</th>
					<th>Rem.</th>
					<th class="hidden-xs">Note</th>
					<th class="hidden-xs">Active</th>
					<th>Edit</th>
					<th><span class="glyphicon glyphicon-remove"></span></th>
				</tr>
			</thead>
			<tbody>
				<%
				do while not rsBeans.eof
					beanId = rsBeans("Id")
					beanName = dashIfNull(rsBeans("Name"))
					beanIntent = dashIfNull(rsBeans("BeanIntentName"))
					beanAmount = int(rsBeans("AmountRemaining"))
					beanNote = dashIfNull(rsBeans("Note"))
					beanActive = rsBeans("Active")
					%>
					<tr data-bean-id="<%=beanId%>" class="<%if not beanActive then%>inactive<%end if%>">
						<td class="hidden-xs"><%=e(beanId)%></td>
						<td><%=e(beanName)%></td>
						<td class="hidden-xs"><%=e(beanIntent)%></td>
						<td><%=e(beanAmount)%> g</td>
						<td class="hidden-xs"><%=e(beanNote)%></td>
						<td class="hidden-xs">
							<%if beanActive then%>
								<span class="glyphicon glyphicon-ok"></span></td>
							<%else%>
								<span class="glyphicon glyphicon-remove"></span>
							<%end if%>
						<td><a href="/charts/pages/bean.asp?beanid=<%=e(beanId)%>">Edit</a></td>
						<td class="remove-column"><span class="glyphicon glyphicon-remove"></span></td>
					</tr>
					<%
					rsBeans.Movenext
				loop
				%>
			</tbody>
		</table>
		<%
	end if
	rsBeans.close
	set rsBeans = nothing
end sub

sub writeBeanData(byval beanId)
	beanId = int(beanId)
	%>
	<div class="bean-data-list clearfix">
		<%
		if beanId > 0 then
			set rsBean = conn.execute(getBeansSQL(beanId))
			if not rsBean.eof then
				beanIntentId = rsBean("BeanIntentId")
				beanName = rsBean("Name")
				beanPurchaseDate = rsBean("PurchaseDate")
				beanNote = rsBean("Note")
				beanOwnerId = rsBean("BeanOwnerId")
				beanLocationId = rsBean("BeanLocationId")
				beanSupplierId = rsBean("BeanSupplierId")
				beanAmountPurchased = rsBean("AmountPurchased")
				beanAmountAdjustment = rsBean("AmountAdjustment")
				beanPrice = rsBean("Price")
				if beanPrice&""<>"" then
					beanPrice = int(beanPrice)
				else
					beanPrice = 0
				end if
			end if
			rsBean.close
			set rsBean = nothing
		else
			beanId = "-"
			beanIntentId = -1
			beanName = ""
			beanPurchaseDate = now()
			beanNote = ""
			beanOwnerId = -1
			beanLocationId = -1
			beanSupplierId = -1
			beanAmountPurchased = 0
			beanAmountAdjustment = 0
			beanPrice = 0
		end if	
		%>
		<div class="col-xs-12">
			<div class="form-group">
				<label>Id</label>
				<p class="form-control-static"><%=e(beanId)%></p>
			</div>
		</div>
		<div class="col-xs-12">
			<div class="form-group">
				<label>Name</label>
				<input type="text" class="form-control" data-for="beanName" value="<%=e(beanName)%>" />
			</div>
		</div>
		<div class="col-xs-12">
			<div class="form-group">
				<label>Purchase date</label>
				<input type="text" class="form-control" data-for="beanPurchaseDate" value="<%=e(beanPurchaseDate)%>" />
			</div>
		</div>
		<div class="col-xs-12">
			<div class="form-group">
				<label>Price (per 1kg)</label>
				<input type="text" class="form-control" data-for="beanPrice" value="<%=e(beanPrice)%>" pattern="\d*" />
			</div>
		</div>
		<div class="col-xs-12">
			<div class="form-group">
				<label>Purchased amount (gram)</label>
				<input type="text" class="form-control" data-for="beanAmountPurchased" value="<%=e(beanAmountPurchased)%>" pattern="\d*" />
			</div>
		</div>
		<div class="col-xs-12">
			<div class="form-group">
				<label>Amount adjustment (gram)</label>
				<input type="text" class="form-control" data-for="beanAmountAdjustment" value="<%=e(beanAmountAdjustment)%>" />
			</div>
		</div>
		<div class="col-xs-12">
			<div class="form-group">
				<label>Intent</label>
				<select class="form-control" data-for="beanIntentId">
					<option value="0">-</option>
					<%
					set rsIntents = conn.execute(getBeanIntentsSQL(-1))
					do while not rsIntents.eof
						intentId = rsIntents("Id")
						intentName = rsIntents("Name")
						%><option value="<%=int(intentId)%>"<%if intentId = beanIntentId then%> selected<%end if%>><%=e(intentName)%></option><%
						rsIntents.MoveNext
					loop
					rsIntents.close
					set rsIntents = nothing
					%>
				</select>
			</div>
		</div>
		<div class="col-xs-12">
			<div class="form-group">
				<label>Owner</label>
				<select class="form-control" data-for="beanOwnerId">
					<option value="0">-</option>
					<%
					set rsOwners = conn.execute(getBeanOwnersSQL(-1))
					do while not rsOwners.eof
						ownerId = rsOwners("Id")
						ownerName = rsOwners("Name")
						%><option value="<%=int(ownerId)%>"<%if ownerId = beanOwnerId then%> selected<%end if%>><%=e(ownerName)%></option><%
						rsOwners.MoveNext
					loop
					rsOwners.close
					set rsOwners = nothing
					%>
				</select>
			</div>
		</div>
		<div class="col-xs-12">
			<div class="form-group">
				<label>Supplier</label>
				<select class="form-control" data-for="beanSupplierId">
					<option value="0">-</option>
					<%
					set rsSuppliers = conn.execute(getSuppliersSQL(-1))
					do while not rsSuppliers.eof
						supplierId = rsSuppliers("Id")
						supplierName = rsSuppliers("Name")
						%><option value="<%=int(supplierId)%>"<%if supplierId = beanSupplierId then%> selected<%end if%>><%=e(supplierName)%></option><%
						rsSuppliers.MoveNext
					loop
					rsSuppliers.close
					set rsSuppliers = nothing
					%>
				</select>
			</div>
		</div>
		<div class="col-xs-12">
			<div class="form-group">
				<label>Location</label>
				<select class="form-control" data-for="beanLocationId">
					<option value="0">-</option>
					<%
					set rsLocations = conn.execute(getLocationsSQL(-1))
					do while not rsLocations.eof
						locationId = rsLocations("Id")
						locationName = rsLocations("Name")
						%><option value="<%=int(locationId)%>"<%if locationId = beanLocationId then%> selected<%end if%>><%=e(locationName)%></option><%
						rsLocations.MoveNext
					loop
					rsLocations.close
					set rsLocations = nothing
					%>
				</select>
			</div>
		</div>
		<div class="col-xs-12">
			<div class="form-group">
				<label>Note</label>
				<input class="form-control" type="text" data-for="beanNote" value="<%=e(beanNote)%>" />
			</div>
		</div>
		<div class="col-xs-12">
			<div class="form-group pull-right">
				<button class="btn btn-primary btn-save">Save</button>
				<button class="btn btn-default btn-back">Back</button>
			</div>
		</div>
	</div>
	<%
end sub


'/////////////////////////////////////////////////////////////////////////////////////
'// Bean Owners //////////////////////////////////////////////////////////////////////
'/////////////////////////////////////////////////////////////////////////////////////
function getBeanOwnersSQL(byval beanOwnerId)
	if beanOwnerId > -1 then
		beanOwnerId = int(beanOwnerId)
		strWhereSQL = " AND (Id = "& beanOwnerId &")"
	end if
	getBeanOwnersSQL = "SELECT Id, Name FROM BeanOwner WHERE (Active = 1)" & strWhereSQL & " ORDER BY Name"
end function

sub writeBeanOwnersTable()
	set rsBeanOwners = conn.execute(getBeanOwnersSQL(-1))
	if not rsBeanOwners.eof then
		%>
		<table class="table table-hover">
			<thead>
				<tr>
					<th>ID</th>
					<th>Name</th>
					<th>Edit</th>
					<th><span class="glyphicon glyphicon-remove"></span></th>
				</tr>
			</thead>
			<tbody>
				<%
				do while not rsBeanOwners.eof
					beanOwnerId = rsBeanOwners("Id")
					beanOwnerName = dashIfNull(rsBeanOwners("Name"))
					%>
					<tr data-bean-owner-id="<%=beanOwnerId%>">
						<td><%=e(beanOwnerId)%></td>
						<td><%=e(beanOwnerName)%></td>
						<td><a href="/charts/pages/beanowner.asp?beanOwnerid=<%=e(beanOwnerId)%>">Edit</a></td>
						<td class="remove-column"><span class="glyphicon glyphicon-remove"></span></td>
					</tr>
					<%
					rsBeanOwners.Movenext
				loop
				%>
			</tbody>
		</table>
		<%
	end if
	rsBeanOwners.close
	set rsBeanOwners = nothing
end sub

sub writeBeanOwner(byval beanOwnerId)
	beanOwnerId = int(beanOwnerId)
	%>
	<div class="bean-owner-data-list clearfix">
		<%
		if beanOwnerId > 0 then
			set rsBeanOwner = conn.execute(getBeanOwnersSQL(beanOwnerId))
			if not rsBeanOwner.eof then
				beanOwnerName = rsBeanOwner("Name")
			end if
			rsBeanOwner.close
			set rsBeanOwner = nothing
		else
			beanOwnerId = "-"
			beanOwnerName = ""
		end if	
		%>
		<div class="col-xs-12">
			<div class="form-group">
				<label>Id</label>
				<p class="form-control-static"><%=e(beanOwnerId)%></p>
			</div>
		</div>
		<div class="col-xs-12">
			<div class="form-group">
				<label>Name</label>
				<input type="text" class="form-control" data-for="beanOwnerName" value="<%=e(beanOwnerName)%>" />
			</div>
		</div>
		<div class="col-xs-12">
			<div class="form-group pull-right">
				<button class="btn btn-primary btn-save">Save</button>
				<button class="btn btn-default btn-back">Back</button>
			</div>
		</div>
	</div>
	<%
end sub

function deleteBeanOwner(byval beanOwnerId)
	beanOwnerId = int(beanOwnerId)
	strSQL = "UPDATE BeanOwner SET Active = 0 WHERE Id = " & beanOwnerId
	conn.execute(strSQL)
end function

function saveBeanOwner(byval beanOwnerId, byval beanOwnerName)
	beanOwnerId = int(beanOwnerId)
	beanOwnerName = replace(beanOwnerName&"","'","''")

	if beanOwnerId > 0 then
		strSQL = "UPDATE BeanOwner SET Name = '" & beanOwnerName & "' WHERE Id = " & beanOwnerId
	else
		strSQL = "INSERT INTO BeanOwner (Name) VALUES ('"&beanOwnerName&"')"
	end if
	conn.execute(strSQL)
end function
'/////////////////////////////////////////////////////////////////////////////////////
'/////////////////////////////////////////////////////////////////////////////////////
'/////////////////////////////////////////////////////////////////////////////////////

'/////////////////////////////////////////////////////////////////////////////////////
'// Locations ////////////////////////////////////////////////////////////////////////
'/////////////////////////////////////////////////////////////////////////////////////
function getLocationsSQL(byval locationId)
	if locationId > -1 then
		locationId = int(locationId)
		strWhereSQL = " AND (Id = "& locationId &")"
	end if
	getLocationsSQL = "SELECT Id, Name FROM BeanLocation WHERE (Active = 1)" & strWhereSQL & " ORDER BY Name"
end function

sub writeLocationsTable()
	set rsLocations = conn.execute(getLocationsSQL(-1))
	if not rsLocations.eof then
		%>
		<table class="table table-hover">
			<thead>
				<tr>
					<th>ID</th>
					<th>Name</th>
					<th>Edit</th>
					<th><span class="glyphicon glyphicon-remove"></span></th>
				</tr>
			</thead>
			<tbody>
				<%
				do while not rsLocations.eof
					locationId = rsLocations("Id")
					locationName = dashIfNull(rsLocations("Name"))
					%>
					<tr data-location-id="<%=locationId%>">
						<td><%=e(locationId)%></td>
						<td><%=e(locationName)%></td>
						<td><a href="/charts/pages/location.asp?locationid=<%=e(locationId)%>">Edit</a></td>
						<td class="remove-column"><span class="glyphicon glyphicon-remove"></span></td>
					</tr>
					<%
					rsLocations.Movenext
				loop
				%>
			</tbody>
		</table>
		<%
	end if
	rsLocations.close
	set rsLocations = nothing
end sub

sub writeLocation(byval locationId)
	locationId = int(locationId)
	%>
	<div class="location-data-list clearfix">
		<%
		if locationId > 0 then
			set rsLocation = conn.execute(getLocationsSQL(locationId))
			if not rsLocation.eof then
				locationName = rsLocation("Name")
			end if
			rsLocation.close
			set rsLocation = nothing
		else
			locationId = "-"
			locationName = ""
		end if	
		%>
		<div class="col-xs-12">
			<div class="form-group">
				<label>Id</label>
				<p class="form-control-static"><%=e(locationId)%></p>
			</div>
		</div>
		<div class="col-xs-12">
			<div class="form-group">
				<label>Name</label>
				<input type="text" class="form-control" data-for="locationName" value="<%=e(locationName)%>" />
			</div>
		</div>
		<div class="col-xs-12">
			<div class="form-group pull-right">
				<button class="btn btn-primary btn-save">Save</button>
				<button class="btn btn-default btn-back">Back</button>
			</div>
		</div>
	</div>
	<%
end sub

function deleteLocation(byval locationId)
	locationId = int(locationId)
	strSQL = "UPDATE BeanLocation SET Active = 0 WHERE Id = " & locationId
	conn.execute(strSQL)
end function

function saveLocation(byval locationId, byval locationName)
	locationId = int(locationId)
	locationName = replace(locationName&"","'","''")

	if locationId > 0 then
		strSQL = "UPDATE BeanLocation SET Name = '" & locationName & "' WHERE Id = " & locationId
	else
		strSQL = "INSERT INTO BeanLocation (Name) VALUES ('"&locationName&"')"
	end if
	conn.execute(strSQL)
end function
'/////////////////////////////////////////////////////////////////////////////////////
'/////////////////////////////////////////////////////////////////////////////////////
'/////////////////////////////////////////////////////////////////////////////////////

'/////////////////////////////////////////////////////////////////////////////////////
'// Suppliers ////////////////////////////////////////////////////////////////////////
'/////////////////////////////////////////////////////////////////////////////////////
function getSuppliersSQL(byval supplierId)
	if supplierId > -1 then
		supplierId = int(supplierId)
		strWhereSQL = " AND (Id = "& supplierId &")"
	end if
	getSuppliersSQL = "SELECT Id, Name FROM BeanSupplier WHERE (Active = 1)" & strWhereSQL & " ORDER BY Name"
end function

sub writeSuppliersTable()
	set rsSuppliers = conn.execute(getSuppliersSQL(-1))
	if not rsSuppliers.eof then
		%>
		<table class="table table-hover">
			<thead>
				<tr>
					<th>ID</th>
					<th>Name</th>
					<th>Edit</th>
					<th><span class="glyphicon glyphicon-remove"></span></th>
				</tr>
			</thead>
			<tbody>
				<%
				do while not rsSuppliers.eof
					supplierId = rsSuppliers("Id")
					supplierName = dashIfNull(rsSuppliers("Name"))
					%>
					<tr data-supplier-id="<%=supplierId%>">
						<td><%=e(supplierId)%></td>
						<td><%=e(supplierName)%></td>
						<td><a href="/charts/pages/supplier.asp?supplierid=<%=e(supplierId)%>">Edit</a></td>
						<td class="remove-column"><span class="glyphicon glyphicon-remove"></span></td>
					</tr>
					<%
					rsSuppliers.Movenext
				loop
				%>
			</tbody>
		</table>
		<%
	end if
	rsSuppliers.close
	set rsSuppliers = nothing
end sub

sub writeSupplier(byval supplierId)
	supplierId = int(supplierId)
	%>
	<div class="supplier-data-list clearfix">
		<%
		if supplierId > 0 then
			set rsSupplier = conn.execute(getSuppliersSQL(supplierId))
			if not rsSupplier.eof then
				supplierName = rsSupplier("Name")
			end if
			rsSupplier.close
			set rsSupplier = nothing
		else
			supplierId = "-"
			supplierName = ""
		end if	
		%>
		<div class="col-xs-12">
			<div class="form-group">
				<label>Id</label>
				<p class="form-control-static"><%=e(supplierId)%></p>
			</div>
		</div>
		<div class="col-xs-12">
			<div class="form-group">
				<label>Name</label>
				<input type="text" class="form-control" data-for="supplierName" value="<%=e(supplierName)%>" />
			</div>
		</div>
		<div class="col-xs-12">
			<div class="form-group pull-right">
				<button class="btn btn-primary btn-save">Save</button>
				<button class="btn btn-default btn-back">Back</button>
			</div>
		</div>
	</div>
	<%
end sub

function deleteSupplier(byval supplierId)
	supplierId = int(supplierId)
	strSQL = "UPDATE BeanSupplier SET Active = 0 WHERE Id = " & supplierId
	conn.execute(strSQL)
end function

function saveSupplier(byval supplierId, byval supplierName)
	supplierId = int(supplierId)
	supplierName = replace(supplierName&"","'","''")

	if supplierId > 0 then
		strSQL = "UPDATE BeanSupplier SET Name = '" & supplierName & "' WHERE Id = " & supplierId
	else
		strSQL = "INSERT INTO BeanSupplier (Name) VALUES ('"&supplierName&"')"
	end if
	conn.execute(strSQL)
end function
'/////////////////////////////////////////////////////////////////////////////////////
'/////////////////////////////////////////////////////////////////////////////////////
'/////////////////////////////////////////////////////////////////////////////////////

sub writeStock()
	%>
	<div class="flexWrapper">
		<%
		pixelsPerKg = 200

		strGetStock = "SELECT Id, Name, AmountPurchased, AmountPurchased + AmountAdjustment - "&_
						" (SELECT SUM(RawBeanWeight) AS AmountRoasted"&_
						" FROM Roast"&_
						" WHERE (BeanId = Bean.Id)) AS AmountRemaining"&_
						" FROM Bean"&_
						" WHERE (Active = 1)"&_
						" ORDER BY Name"
		set rsStock = conn.execute(strGetStock)
		beanCount = 0
		do while not rsStock.eof
			beanCount = beanCount + 1
			rsStock.MoveNext
		loop
		rsStock.MoveFirst
		do while not rsStock.eof
			beanId = rsStock("Id")
			beanName = rsStock("Name")
			AmountPurchased = rsStock("AmountPurchased")
			AmountRemaining = rsStock("AmountRemaining")

			originalHeight = (pixelsPerKg * AmountPurchased) / 1000
			remainingHeight = 0
			if AmountRemaining > 0 then
				remainingHeight = (pixelsPerKg * AmountRemaining) / 1000
			else
				remainingHeight = 0
			end if
			width = int(100 / beanCount) - 4
			%>
			<div class="stock" style="width:<%=width%>%;height:<%=originalHeight%>px;">
				<div class="original" style="height:<%=originalHeight%>px;"><%=AmountPurchased%>g</div>
				<div class="remaining" style="height:<%=remainingHeight%>px;<%if remainingHeight = 0 then%>padding:0;<%end if%>"><%=AmountRemaining%>g<span><%=beanName%></span></div>
			</div>
			<%
			rsStock.Movenext
		loop
		rsStock.close
		set rsStock = nothing
		%>
		<div class="clearfix"></div>
	</div>
	<%
end sub

sub writeBalanceTable()
	strSQL = "SELECT CASE WHEN StartTime IS NULL THEN CreatedDate ELSE StartTime END AS LogDate, Roast.Id AS RoastId, CASE WHEN BeanOwner.Id IS NULL"&_
				" THEN FinancialAdjustment.FinancialOwnerId ELSE BeanOwner.Id END AS BenefactorId,"&_
				" CASE WHEN BeanOwner.Name IS NULL THEN BeanOwner_2.Name ELSE BeanOwner.Name END AS BenefactorName,"&_
				" BeanOwner_1.Id AS OwnerId, BeanOwner_1.Name AS OwnerName, Roast.RawBeanWeight,"&_
				" Bean.Price, FinancialAdjustment.Adjustment, Bean.Name AS BeanName, Bean.Id AS BeanId, FinancialAdjustment.Note AS AdjustmentNote"&_
				" FROM FinancialAdjustment INNER JOIN"&_
				" BeanOwner AS BeanOwner_2 ON FinancialAdjustment.FinancialOwnerId = BeanOwner_2.Id FULL OUTER JOIN"&_
				" Roast INNER JOIN"&_
				" BeanOwner ON Roast.FinancialOwnerId = BeanOwner.Id INNER JOIN"&_
				" Bean ON Roast.BeanId = Bean.Id INNER JOIN"&_
				" BeanOwner AS BeanOwner_1 ON Bean.BeanOwnerId = BeanOwner_1.Id"&_
				" AND BeanOwner.Id <> BeanOwner_1.Id ON FinancialAdjustment.CreatedDate = Roast.StartTime AND FinancialAdjustment.Active = 1"&_
				" ORDER BY LogDate"
	set rsBalance = conn.execute(strSQL)

	dim balanceArr(3)
	balanceArr(0) = 0 'Not in use
	balanceArr(1) = 0 'Shared
	balanceArr(2) = 0 'LBE
	balanceArr(2) = 0 'MOV

	dim nameArr(3)
	nameArr(0) = "" 'Not in use
	nameArr(1) = "Shared"
	nameArr(2) = "Lasse"
	nameArr(3) = "Morten"

	do while not rsBalance.eof
		RoastId = rsBalance("roastId")
		if RoastId&""<>"" then
			' Basic premise here is that the SQL will only return records where the roaster is not the owner of the bean

			roastDate = rsBalance("LogDate")
			if isDate(roastDate) then
				roastDate = cdate(roastDate)
				roastDate = lz_1(day(roastDate)) &"-"& lz_1(month(roastDate)) & "-" & year(roastDate)
			end if

			roasterId = rsBalance("BenefactorId")
			roasterName = rsBalance("BenefactorName")
			ownerId = rsBalance("OwnerId")
			ownerName = rsBalance("OwnerName")
			beanId = rsBalance("BeanId")
			beanName = rsBalance("BeanName")
			rawBeanWeight = rsBalance("RawBeanWeight")
			beanPrice = rsBalance("Price")
			beanCostRaw = (rawBeanWeight * beanPrice) / 1000
			beanCost = round(beanCostRaw,1)

			beanAdjustmentRaw = 0
			if roasterId = 1 then
				'Shared is roasting someone else's coffee!!
				beanAdjustmentRaw = beanCostRaw / 2

				balanceArr(ownerId) = balanceArr(ownerId) + beanAdjustmentRaw
				
			elseif ownerId = 1 then
				'Someone is roasting Shared's coffee!!
				beanAdjustmentRaw = beanCostRaw / 2

				balanceArr(roasterId) = balanceArr(roasterId) - beanAdjustmentRaw
			else
				'2 or 3 is roasting coffee from 2 or 3
				beanAdjustmentRaw = beanCostRaw
				
				balanceArr(roasterId) = balanceArr(roasterId) - beanAdjustmentRaw
			end if
			beanAdjustment = round(beanAdjustmentRaw,1)
			%>
			<div class="balance-row">
				<%=roastDate%> &mdash; <a href="beanowner.asp?beanownerid=<%=roasterId%>"><%=e(roasterName)%></a> roasted <%=rawBeanWeight%>g of <a href="beanowner.asp?beanownerid=<%=ownerId%>"><%=ownerName%></a>'s <a href="/charts/pages/bean.asp?beanid=<%=beanId%>"><%=beanName%></a> to the price of <b>DKK <%=formatNumber(beanCost)%></b> which results in an adjustment of <b>DKK -<%=formatNumber(beanAdjustment)%></b>
			</div>
			<%
		else
			
			roastDate = rsBalance("LogDate")
			if isDate(roastDate) then
				roastDate = cdate(roastDate)
				roastDate = lz_1(day(roastDate)) &"-"& lz_1(month(roastDate)) & "-" & year(roastDate)
			end if

			roasterId = rsBalance("BenefactorId")
			roasterName = rsBalance("BenefactorName")
			adjustmentValue = rsBalance("Adjustment")
			adjustmentNote = rsBalance("AdjustmentNote")
			
			balanceArr(roasterId) = balanceArr(roasterId) + adjustmentValue
			%>
			<div class="balance-row">
				<%=roastDate%> &mdash; An adjustment was made to <a href="beanowner.asp?beanownerid=<%=roasterId%>"><%=e(roasterName)%></a>'s balance in the amount of <b>DKK <%=formatNumber(adjustmentValue)%></b> with the following note: <i><%=adjustmentNote%></i>
			</div>
			<%
		end if
		
		rsBalance.MoveNext
	loop
	rsBalance.close
	set rsBalance = nothing
	
	if balanceArr(2) > balanceArr(3) then

		resultBalance = balanceArr(3) - balanceArr(2)
		
		resultId = 3
		resultName = nameArr(3)
		
		resultInFavorId = 2
		resultInFavor = nameArr(2)

	elseif balanceArr(2) < balanceArr(3) then

		resultBalance = balanceArr(2) - balanceArr(3)
		
		resultId = 2
		resultName = nameArr(2)

		resultInFavorId = 3
		resultInFavor = nameArr(3)

	else

		resultBalance = 0
		resultName = nameArr(0)
		resultInFavor = nameArr(3)

	end if
	%>
	<div class="balance-row">
		<h3><a href="beanowner.asp?beanownerid=<%=resultId%>"><%=resultName%></a> owes DKK <%=formatNumber(abs(resultBalance))%> to <a href="beanowner.asp?beanownerid=<%=resultInFavorId%>"><%=resultInFavor%></a></h3>
		<div class="small"><%=nameArr(2)%>: DKK <%=formatNumber(balanceArr(2))%></div>
		<div class="small"><%=nameArr(3)%>: DKK <%=formatNumber(balanceArr(3))%></div>
	</div>
	<%
end sub
%>


































