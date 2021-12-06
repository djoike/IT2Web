<!--#include file="connstring.asp"-->
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
        <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=1.0, minimum-scale=1.0, maximum-scale=1.0">
        <style type="text/css">
        	body
        	{
        		margin:0;
        		padding: 0;
        	}
        	div.top
        	{
        		width: 95vw;
        		margin:2.5vh 2.5vw 2.5vh 2.5vw;
        	}
        	select {
			   background: transparent;
			   width: 83vw;
			   margin:0vh 0vw 0vh 2vw;
			   height: 10vh;
			   padding: 1vh 2vw 1vh 2vw;
			   font-size: 1.8vh;
			   border: 1px solid #ccc;
			   -webkit-appearance: none;
			   -moz-appearance: none;
			   appearance: none;
			   float: left;
			}
			button
			{
				width: 10vw;
				margin:0vh 0vw 0vh 0vw;
				height: 10vh;
				/*padding: 1vh 2vw 1vh 2vw;*/
				font-size: 2vh;
				border: 1px solid #ccc;
				background: transparent;
				float: left;
				border-radius: 3px;
			}
			@media (orientation: landscape)
			{
				select
				{
					font-size: 3vh;
				}
				button
				{
					font-size: 3vh;
				}
			}
			#chart_div
			{
				width: 95vw;
				margin:0 2.5vw 0 2.5vw;
				height: 72.5vh;
				background-color: #efefef;
			}
			.info
			{
				font-family: helvetica;
				font-size: 3vw;
				margin: 1vh 2.5vw 2.5vh 2.5vw;
				display: none;
			}
			.cb{
				clear: both;
			}
			/*select:focus, select:hover {
				font-size: 5vw; /* Adding 16px on focus/hover will prevent page zoom */
			}*/
        </style>
        <style type="text/css" media="print">
        	select {
        		border:none;
        		margin-left: 0px;
        		padding-left: 0px;
        		height: 60px;
        	}
        	button {
        		display:none;
        	}
        </style>
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
				var text = $('select').find('option:selected').data('text');
				$('.info').html(text);
				var data = new google.visualization.DataTable(data);
				var options = {
			        legend: {
			        	position:'none'
			        },
			        hAxis: {gridlines: {count:20}},
			        vAxis: {
						gridlines: {count:30}
	                },
			      };
				var chart = new google.charts.Line(document.getElementById('chart_div'));
      			chart.draw(data, google.charts.Line.convertOptions(options));
			}
			$(document).ready(function(){
				$('select').on('change',getCurrentRoastData);
				$('button').on('click',handleButtonClick);
			});
			var timer;
			$(window).resize(function(){
				clearTimeout(timer);
				timer = setTimeout(getCurrentRoastData,250);
			});
			function getCurrentRoastData()
			{
				var roastId = $('select').val();
				if(roastId && roastId > -1)
				{
					getData(roastId);
				}
			}
			var timing = false;
			var interval;
			function handleButtonClick()
			{
				if(!timing)
				{
					var roastId = $('select').val();
					if(roastId && roastId > -1)
					{
						interval = setInterval('getData('+roastId+');',5000);
						timing = true;
					}
				}
				else
				{
					clearInterval(interval);
					timing = false;
				}
				var fontWeight = timing ? 'bold' : 'normal';
				{
					$('button').css({'font-weight':fontWeight});
				}
			}
		</script>
		<div class="top">
			<button>R</button>
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
					textualRepres = "T: " & Server.HTMLEncode(roastStartTime&"") & "&nbsp;ID: " & roastId & "&nbsp;M: " & (hasManualControl&"") & "&nbsp;P: " & Server.HTMLEncode(profileName)
					%>
					<option value="<%=roastId%>" data-text="<%=textualRepres%>">
						<%=textualRepres%>
					</option>
					<%
					rsRoasts.MoveNext
				loop
				%>
			</select>
			<div class="cb"></div>
		</div>
		<div class="info"></div>
		<div id="chart_div"></div>
	</body>
</html>
<%
conn.Close
set conn=nothing
%>