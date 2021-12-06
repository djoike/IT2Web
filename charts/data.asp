<!--#include file="connstring.asp"-->
<%
Session.LCID = 1033
Session.CodePage = 65001
Response.CharSet = "UTF-8"
Response.ContentType = "application/json"

function lefz(byval strNumber, byval digitCount)
	strDigits = ""
	for i = 1 to digitCount
		strDigits = strDigits & "0"
	next
	lefz = right(strDigits&strNumber,digitCount)
end function
%>
{
	"cols":[
		{"id": "A","label":null,"type":"datetime"},
		{"id": "B","label":"Temperature","type":"number"}
	],
	"rows":[
		<%

		set conn = Server.CreateObject("ADODB.Connection")
		conn.Open strConn

		roastId = int(request.querystring("roastid"))

		strSql = "SELECT LogTime, ElapsedTime, Temperature, DebugData FROM RoastLog WHERE (RoastId = "&roastId&") ORDER BY Id"
		set rsRoast = conn.execute(strSql)
		if not rsRoast.eof then
			first = true
			do while not rsRoast.eof
				roastLogTime = cdate(rsRoast("LogTime"))
				roastElapsedSeconds = int(rsRoast("ElapsedTime"))
				roastTemperature = round(cdbl(rsRoast("Temperature")),5)
				%>
				<%if not first then%>,<%end if%>
				{"c":
					[
						{"v":"Date(<%=year(roastLogTime)%>,<%=month(roastLogTime)-1%>,<%=day(roastLogTime)%>,<%=hour(roastLogTime)%>,<%=minute(roastLogTime)%>,<%=second(roastLogTime)%>)"},
						{"v":<%=roastTemperature%>,"f":"<%=round(roastTemperature,2)%>"}
					]
				}
				<%
				first = false
				rsRoast.MoveNext
			loop
		end if

		conn.Close
		set conn=nothing
		%>
	]
}