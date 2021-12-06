<%
function lefz(byval strNumber, byval digitCount)
	strDigits = ""
	for i = 1 to digitCount
		strDigits = strDigits & "0"
	next
	lefz = right(strDigits&strNumber,digitCount)
end function

function getRandom(byval low, byval high, byval withDecimal, byval decimalString)
	Randomize
	tmpRandom = low + ((high-low+1) * Rnd)
	
	if withDecimal then
		tmpRandom = round(tmpRandom,1)
		if instr(tmpRandom,",") = 0 then
			tmpRandom = tmpRandom & ",0"
		end if
	else
		tmpRandom = round(tmpRandom,0)
	end if

	tmpRandom = replace(tmpRandom&"",",",decimalString)

	getRandom = tmpRandom
end function

letters = Array("a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"," "," "," "," "," ") 
strName = ""
for i = 1 to getRandom(8,15,false,",")
	strName = strName & letters(getRandom(0,29,false,"."))
	if len(strName)=1 then
		strName = ucase(strName)
	end if
next

currentTemperature = getRandom(50,220,true,".")
targetTemperature = (getRandom(18,21,false,".")*10) + (getRandom(0,1,false,".")*5)
elapsedTime = getRandom(0,20,false,".") & ":" & lefz(getRandom(0,59,false,"."),2)
profileName = strName
stepNo = getRandom(1,10,false,".")
stepTargetTemperature = (getRandom(18,21,false,".")*10) + (getRandom(0,1,false,".")*5)
stepMoveTimeRemaining = getRandom(0,3,false,".") & ":" & lefz(getRandom(0,59,false,"."),2)
stepStayTimeRemaining = getRandom(0,3,false,".") & ":" & lefz(getRandom(0,59,false,"."),2)

%>
{
	"statusCode":"30",
	"currentTemperature":"<%=currentTemperature%>",
	"targetTemperature":"<%=targetTemperature%>",
	"elapsedTime":"<%=elapsedTime%>",
	"profileName":"<%=profileName%>",
	"step":
		{
			"number":"<%=stepNo%>",
			"targetTemperature":"<%=stepTargetTemperature%>",
			"moveTimeRemaining":"<%=stepMoveTimeRemaining%>",
			"stayTimeRemaining":"<%=stepStayTimeRemaining%>"
		}
}