<!--#include virtual="/charts/includes/conn_create.asp"-->
<!--#include virtual="/charts/includes/basic_inc.asp"-->
<%
function getFileNameFromPath(byval fileNameWithPath)
	getFileNameFromPath = mid(fileNameWithPath,instrrev(fileNameWithPath,"\")+1)
end function

function saveSize(byval path, byval name, byref imageObject, byval orgHeight, byval orgWidth, byval imageWidth)
	newHeight = round((orgHeight/orgWidth)*imageWidth)
	set tmpImageObj = imageObject.Clone()
	if orgWidth > imageWidth then
		call tmpImageObj.Stretch(imageWidth, newHeight,"super")
	end if
	call tmpImageObj.SaveImage(fileUploadPath & path & "\" & name, "JPG", 24, 90)
	set tmpImageObj = nothing
end function

'General setup
fileUploadPath = Server.MapPath("/charts/uploaded/")
origPath = "\original"
smallPath = "\small"
largePath = "\large"
megaPath = "\mega"

smallWidth 	= 300
largeWidth 	= 800
megaWidth 	= 1600

Set fileUpload = Server.CreateObject("SoftArtisans.FileUp")
fileUpload.CreateNewFile = true
fileUpload.Path = fileUploadPath & origPath

roastId = int(fileUpload.form("roast-id"))
if roastId > 0 then
	
	strCheckRoast = "SELECT TOP(1) Id FROM Roast WHERE (Id = "&roastId&")"
	roastValid = not conn.execute(strCheckRoast).eof
	if roastValid then
		if IsObject(fileUpload.form("file")) then
			if not fileUpload.form("file").IsEmpty then

				fileUpload.form("file").Save
				fileName = getFileNameFromPath(fileUpload.ServerName)
				if lcase(right(fileName,4)) = ".jpg" or lcase(right(fileName,5)) = ".jpeg" then

					set orgImageObject = Server.CreateObject("w3image.image")
					orgImageObject.LoadImage(fileUploadPath & origPath & "\" & fileName)
					rotateDeg = int(fileUpload.form("rotate"))
					if rotateDeg > 0 then
						orgWidth = orgImageObject.width
						orgHeight = orgImageObject.height
						call orgImageObject.RotateCenter(int(rotateDeg),"linear")
					end if

					orgWidth = orgImageObject.width
					orgHeight = orgImageObject.height

					call saveSize(smallPath, fileName, orgImageObject, orgHeight, orgWidth, smallWidth)
					call saveSize(largePath, fileName, orgImageObject, orgHeight, orgWidth, largeWidth)
					call saveSize(megaPath, fileName, orgImageObject, orgHeight, orgWidth, megaWidth)
				end if

				call fileUpload.Delete(fileUploadPath & origPath & "\" & fileName)

				conn.execute("UPDATE Roast SET pictureName = '"&replace(fileName,"'","''")&"' WHERE (Id = "&roastId&")")
			end if
		end if
		set orgImageObject = nothing
	end if
end if
set fileUpload = Nothing

%>
<!--#include virtual="/charts/includes/conn_close.asp"-->