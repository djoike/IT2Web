<%
function e(byval str)
	e = Server.HTMLEncode(str&"")
end function

function lz_1(byval i)
	lz_1 = right("0" & i,2)
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
	strSQL = "SELECT Roast.Id, Roast.StartTime, Roast.EndTime, Profile.Name AS ProfileName, Roast.ManualControlStartTime, COUNT(DISTINCT RoastLog.Id) AS LogCount"&_
				" FROM Roast INNER JOIN"&_
				" RoastLog ON Roast.Id = RoastLog.RoastId LEFT OUTER JOIN"&_
				" Profile ON Roast.ProfileId = Profile.Id"&_
				" GROUP BY Roast.Id, Roast.StartTime, Profile.Name, Roast.ManualControlStartTime, RoastLog.RoastId, Roast.EndTime"&_
				" HAVING (COUNT(DISTINCT RoastLog.Id) > "&minimumLogCount&")" & strWhereSQL &_
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
sub writeRoastsTable()
	%>
	<table class="table table-hover">
		<thead>
			<tr>
				<th>ID</th>
				<th>Date</th>
				<th>Profile name</th>
				<th class="hidden-xs">Start time</th>
				<th class="hidden-xs">End time</th>
				<th class="hidden-xs">Manual time</th>
				<th class="hidden-xs">Logs</th>
				<th>View</th>
				<th><span class="glyphicon glyphicon-remove"></span></th>
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
					roastDate = day(roastStartTime) &"-"& month(roastStartTime) &"<span class='hidden-xs'>-"& year(roastStartTime) &"</span>"
					roastStartTime = lz_1(hour(roastStartTime)) &":"& lz_1(minute(roastStartTime)) &":"& lz_1(second(roastStartTime))
				else
					roastDate = "-"
					roastStartTime = "-"
				end if
				roastEndTime = rsRoasts("EndTime")
				if isDate(roastEndTime) then
					roastEndTime = cdate(roastEndTime)
					roastEndTime = lz_1(hour(roastEndTime)) &":"& lz_1(minute(roastEndTime)) &":"& lz_1(second(roastEndTime))
				else
					roastEndTime = "-"
				end if
				roastProfileName = rsRoasts("ProfileName")
				if roastProfileName&"" = "" then
					roastProfileName = "-"
				end if
				roastManualControlStartTime = rsRoasts("ManualControlStartTime")
				if isDate(roastManualControlStartTime) then
					roastManualControlStartTime = cdate(roastManualControlStartTime)
					roastManualControlStartTime = lz_1(hour(roastManualControlStartTime)) &":"& lz_1(minute(roastManualControlStartTime)) &":"& lz_1(second(roastManualControlStartTime))
				else
					roastManualControlStartTime = "-"
				end if
				roastLogCount = rsRoasts("LogCount")
				%>
				<tr>
					<td><%=e(roastID)%></td>
					<td><%=roastDate%></td>
					<td><%=e(roastProfileName)%></td>
					<td class="hidden-xs"><%=e(roastStartTime)%></td>
					<td class="hidden-xs"><%=e(roastEndTime)%></td>
					<td class="hidden-xs"><%=e(roastManualControlStartTime)%></td>
					<td class="hidden-xs"><%=e(roastLogCount)%></td>
					<td><a href="/charts/pages/roast.asp?roastid=<%=e(roastID)%>">View</a></td>
					<td><span class="glyphicon glyphicon-remove"></span></td>
				</tr>
				<%
				rsRoasts.MoveNext
			loop
			rsRoasts.close
			set rsRoasts = nothing
			%>
		</tbody>
	</table>
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
				roastDate = day(roastStartTime) &"-"& month(roastStartTime) &"<span class='hidden-xs'>-"& year(roastStartTime) &"</span>"
				roastStartTime = lz_1(hour(roastStartTime)) &":"& lz_1(minute(roastStartTime)) &":"& lz_1(second(roastStartTime))
			else
				roastDate = "-"
				roastStartTime = "-"
			end if
			roastEndTime = rsRoasts("EndTime")
			if isDate(roastEndTime) then
				roastEndTime = cdate(roastEndTime)
				roastEndTime = lz_1(hour(roastEndTime)) &":"& lz_1(minute(roastEndTime)) &":"& lz_1(second(roastEndTime))
			else
				roastEndTime = "-"
			end if
			roastProfileName = rsRoasts("ProfileName")
			if roastProfileName&"" = "" then
				roastProfileName = "-"
			end if
			roastManualControlStartTime = rsRoasts("ManualControlStartTime")
			if isDate(roastManualControlStartTime) then
				roastManualControlStartTime = cdate(roastManualControlStartTime)
				roastManualControlStartTime = lz_1(hour(roastManualControlStartTime)) &":"& lz_1(minute(roastManualControlStartTime)) &":"& lz_1(second(roastManualControlStartTime))
			else
				roastManualControlStartTime = "-"
			end if
			roastLogCount = rsRoasts("LogCount")
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
					<label>Start time</label>
					<p class="form-control-static"><%=e(roastStartTime)%></p>
				</div>
			</div>
			<div class="col-xs-12">
				<div class="form-group">
					<label>End time</label>
					<p class="form-control-static"><%=e(roastEndTime)%></p>
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
			<%
		end if
		rsRoasts.close
		set rsRoasts = nothing
		%>
	</div>
	<%
end sub
%>