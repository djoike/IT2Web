<!--#include virtual="connstring.asp"-->
<%
Session.LCID = 1030
Session.CodePage = 65001
Response.CharSet = "UTF-8"

set conn = Server.CreateObject("ADODB.Connection")
conn.Open strConn
%>
<!DOCTYPE html>
<html>
    <head>
        <title>IT2 roast charts</title>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
        <!--link rel="stylesheet" href='styles.css' type="text/css"-->
    </head>
	<body>
		<script src="https://code.jquery.com/jquery-1.12.4.min.js" integrity="sha256-ZosEbRLbNQzLpnKIkEdrPv7lOy9C27hHQ+Xp8a4MxAQ=" crossorigin="anonymous"></script>
		<script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
		<script type="text/javascript">
			google.charts.load('current', {packages: ['line', 'corechart'], language: 'da'});
			function getData(roastId)
			{
				$.ajax({
					url: "data.asp",
					data:{"roastid":roastId},
					success: drawChart
				});
			}
			function drawChart(data)
			{
				var data = new google.visualization.DataTable(data);
				var options = {
			        hAxis: {
			          title: 'Time'
			        },
			        vAxis: {
			          title: 'Temperature'
			        },
			        width:800,
			        height:400
			      };
				var chart = new google.charts.Line(document.getElementById('chart_div'));
      			chart.draw(data, options);
			}
			$(document).ready(function(){
				$('select').on('change',function(){
					var roastId = $(this).val();
					if(roastId && roastId > -1)
					{
						getData(roastId);
					}
				});
			});
		</script>
		<select>
			<option value="-1">Pick roast</option>
			<%
			strSQL = "SELECT Roast.Id, Roast.StartTime, Profile.Name, Roast.ManualControlStartTime"&_
						" FROM Roast LEFT OUTER JOIN"&_
						" Profile ON Roast.ProfileId = Profile.Id"&_
						" WHERE ((SELECT COUNT(Id)"&_
						" FROM RoastLog"&_
						" WHERE (RoastId = Roast.Id)) > 10)"&_
						" ORDER BY Roast.StartTime DESC"
			set rsRoasts = conn.Execute(strSQL)
			do while not rsRoasts.eof
				roastId = int(rsRoasts("Id"))
				roastStartTime = rsRoasts("StartTime")
				profileName = rsRoasts("Name")
				if profileName&""="" then
					profileName = "None"
				end if
				hasManualControl = rsRoasts("ManualControlStartTime")&""<>""
				%>
				<option value="<%=roastId%>">
					T: <%=Server.HTMLEncode(roastStartTime&"")%>
					&nbsp;ID: <%=roastId%>
					&nbsp;M: <%=hasManualControl%>
					&nbsp;P: <%=profileName%>
				</option>
				<%
				rsRoasts.MoveNext
			loop
			%>
		</select>
		<div id="chart_div"></div>
	</body>
</html>
<%
conn.Close
set conn=nothing
%>