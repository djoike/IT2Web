<!--#include file="connstring.asp"-->
<%
set conn = Server.CreateObject("ADODB.Connection")
conn.Open strConn
%>