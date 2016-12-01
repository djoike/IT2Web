<%
function e(byval str)
	e = Server.HTMLEncode(str&"")
end function

function lz_1(byval i)
	lz_1 = right("0" & i,2)
end function

function getRoastsSQL(byval minimumLogCount)
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
				" HAVING (COUNT(DISTINCT RoastLog.Id) > "&minimumLogCount&")"&_
				" ORDER BY Roast.Id DESC"
	getRoastsSQL = strSQL
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
			set rsRoasts = conn.execute(getRoastsSQL(-1))
			do while not rsRoasts.eof
				roastID = 						rsRoasts("Id")
				roastStartTime = 				rsRoasts("StartTime")
				roastDate =						""
				if isDate(roastStartTime) then
					roastStartTime = cdate(roastStartTime)
					roastDate = day(roastStartTime) &"-"& month(roastStartTime) &"<span class='hidden-xs'>-"& year(roastStartTime) &"</span>"
					roastStartTime = lz_1(hour(roastStartTime)) &":"& lz_1(minute(roastStartTime)) &":"& lz_1(second(roastStartTime))
				else
					roastDate = "-"
					roastStartTime = "-"
				end if
				roastEndTime = 					rsRoasts("EndTime")
				if isDate(roastEndTime) then
					roastEndTime = cdate(roastEndTime)
					roastEndTime = lz_1(hour(roastEndTime)) &":"& lz_1(minute(roastEndTime)) &":"& lz_1(second(roastEndTime))
				else
					roastEndTime = "-"
				end if
				roastProfileName = 				rsRoasts("ProfileName")
				if roastProfileName&"" = "" then
					roastProfileName = "-"
				end if
				roastManualControlStartTime = 	rsRoasts("ManualControlStartTime")
				if isDate(roastManualControlStartTime) then
					roastManualControlStartTime = cdate(roastManualControlStartTime)
					roastManualControlStartTime = lz_1(hour(roastManualControlStartTime)) &":"& lz_1(minute(roastManualControlStartTime)) &":"& lz_1(second(roastManualControlStartTime))
				else
					roastManualControlStartTime = "-"
				end if
				roastLogCount = 				rsRoasts("LogCount")
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
%>