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
				" RoastIntent.Id AS RoastIntentId, RoastIntent.RoastIntent, Roast.pictureName"&_
				" FROM Roast INNER JOIN"&_
				" RoastLog ON Roast.Id = RoastLog.RoastId LEFT OUTER JOIN"&_
				" RoastIntent ON Roast.RoastIntentId = RoastIntent.Id LEFT OUTER JOIN"&_
				" Bean ON Roast.BeanId = Bean.Id AND Bean.Active = 1 LEFT OUTER JOIN"&_
				" Profile ON Roast.ProfileId = Profile.Id"&_
				" GROUP BY Roast.Id, Roast.Active, Roast.StartTime, Profile.Name, Roast.ManualControlStartTime, RoastLog.RoastId, Roast.EndTime, Bean.Name, Bean.Id, RoastIntent.Id, RoastIntent.RoastIntent, Roast.pictureName"&_
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

function deleteBean(byval beanId)
	beanId = int(beanId)
	strSQL = "UPDATE Bean SET Active = 0 WHERE Id = " & beanId
	conn.execute(strSQL)
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
	getBeansSQL = "SELECT Bean.Id, Bean.Name, BeanIntent.Id AS BeanIntentId, BeanIntent.Name AS BeanIntentName, Bean.Note"&_
					" FROM Bean LEFT OUTER JOIN"&_
					" BeanIntent ON Bean.BeanIntentId = BeanIntent.Id"&_
					" WHERE (Bean.Active = 1)" & strWhereSQL &_
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

function saveRoast(byval roastId, byval beanId, byval roastIntentId)
	roastId = int(roastId)
	beanId = int(beanId)
	if beanId = 0 then
		beanId = "NULL"
	end if
	roastIntentId = int(roastIntentId)
	if roastIntentId = 0 then
		roastIntentId = "NULL"
	end if

	strSQL = "UPDATE Roast SET BeanId = " & beanId & ", RoastIntentId = " & roastIntentId & " WHERE Id = " & roastId
	conn.execute(strSQL)
end function

function saveBean(byval beanId, byval beanName, byval beanIntentId, byval beanNote)
	beanId = int(beanId)
	beanName = replace(beanName&"","'","''")
	beanNote = replace(beanNote&"","'","''")

	if beanIntentId = 0 then
		beanIntentId = "NULL"
	end if

	if beanId > 0 then
		strSQL = "UPDATE Bean SET Name = '" & beanName & "', BeanIntentId = " & beanIntentId & ", Note = '" & beanNote & "' WHERE Id = " & beanId
	else
		strSQL = "INSERT INTO Bean (Name, BeanIntentId, Note) VALUES ('"&beanName&"',"&beanIntentId&",'"&beanNote&"')"
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
					<th>ID</th>
					<th>Name</th>
					<th>Intent</th>
					<th class="hidden-xs">Note</th>
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
					beanNote = dashIfNull(rsBeans("Note"))
					%>
					<tr data-bean-id="<%=beanId%>">
						<td><%=e(beanId)%></td>
						<td><%=e(beanName)%></td>
						<td><%=e(beanIntent)%></td>
						<td class="hidden-xs"><%=e(beanNote)%></td>
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
				beanNote = rsBean("Note")
			end if
			rsBean.close
			set rsBean = nothing
		else
			beanId = "-"
			beanIntentId = -1
			beanName = ""
			beanNote = ""
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
%>