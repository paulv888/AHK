;#Persistent
#Include %A_ScriptDir%\Config.ahk
#Include %A_ScriptDir%\Url.ahk

SetTitleMatchMode, 2
SetTimer, Reminders, 60000
;SetTimer, SaveAsMsgbox, 500    ; Mozilla Save As
;SetKeyDelay, 200, 10, Play 
;file=videos


^!n::
	IfWinExist ahkClass Notepad++
	{
		WinActivate
	}
	else
	{
		Run Notepad++
		WinWait ahk_class Notepad++,,3
		WinActivate
	}
return

^!t::
	IfWinExist ahk_exe eu4.exe
	{
		WinActivate
		loop
		{
			If Stop ; test to see if we must brek the loop
			{
				Stop := !Stop ; reinit the brek key
				Break ; brek the loop
			} Else {
				Click, 340, 234
				sleep 800			; 1000 ms = 1 sec, change to sleep 60000 for 1 minute delay
			}
		}
	}
return

^!c::
	newStr := GetActiveWindowTicker()
	IfWinExist ahk_exe ActiveTraderPro.exe
	{
		WinActivate
		clipboard := newStr
		Click, 318, 65
		Send, {CTRLDOWN}av{CTRLUP}{ENTER}
	}
return

^!b::
	newStr := GetActiveWindowTicker()
	if WinExist("StreetAHK")
	{
		WinActivate
		Click, 550, 123
		clipboard := newStr
		Send, {CTRLDOWN}av{CTRLUP}{ENTER}
	} 
return

^!s::
	newStr := GetActiveWindowTicker()
	if WinExist("StreetAHK")
	{
		WinActivate
		Click, 700, 123
		clipboard := newStr
		Send, {CTRLDOWN}av{CTRLUP}{ENTER}
	} 
return


!Esc::
    Stop := !Stop ; set the break var to true (it's false when you run the script)
Return

^!r::
		run calc
		WinWait ahk_class ApplicationFrameWindow,,3
		WinActivate
return

^!i::
	IfWinExist ahk_class IrfanView
	{
		WinActivate
	}
	else
	{
		Run C:\Program Files\IrfanView\i_view64
		WinWait ahk_class IrfanView,,3
		WinActivate
	}
return

^!q::
	;
	; select artist and search in find window
	;                  v
	; copy file name from window title
	;
	findDB()
	return


^!d::
;
; select artist and create new folder
;
	WinWait, ahk_class CabinetWClass,
	IfWinNotActive, ahk_class CabinetWClass, , WinActivate, ahk_class CabinetWClass, 
	WinWaitActive, ahk_class CabinetWClass, 
	Sleep, 100
	Send, {F2}{CTRLDOWN}c{CTRLUP}{ESC}
	;clipboard := GetArtist(clipboard)
	SendInput, {ALT}2{CTRLDOWN}v{CTRLUP}
return

#IfWinExist
^!f::
;
; select artist and search in find window
;                  v
; copy file name from window title
;
	newStr := GetActiveWindowTicker()
;	MySearch:=UriEncode(newStr)
;	Run, firefox.exe %schwab%%newStr%/
	Run, firefox.exe %yahoo%%newStr%/
	Run, firefox.exe %twits%%newStr%/
;	MyTitle:= GetActiveWindowSong()
;	MySearch:= GetArtist(MyTitle)
;	;MySearch:= CleanName(MyTitle)
;	ShowInExplorer(MySearch)
return

^!g::
;
; read now playing and search google with it
;
	NewStr:=GetActiveWindowSong()
	sArtist:= GetArtist(NewStr)
	sTitle :=GetTitle(NewStr,sArtist)
	MySearch=%sArtist%%A_Space%%sTitle%
	clipboard := MySearch
	
	StringReplace, MySearch, MySearch,%A_Space%,+ ,All
	MySearch:=UriEncode(newStr)
	Run, firefox.exe  %youtube%%MySearch%

  ;JumpToSearch(MyPlaying)
return

^!l:: ; Clean Favorites
	msgbox , 4,,"Do you want to Clean Favorites?"
	IfMsgBox, No
	{
	  return
	}
	CleanFav("Paul Favorites")
	CleanFav("Paul Favorites Dance")
	CleanFav("Paul Favorites Party")
	CleanFav("Paul Favorites Popular")
	CleanFav("Raki")
	CleanFav("Summerhits")
	CleanFav("Turkish Dance")
	CleanFav("Turkish Slow")

	Msgbox Done
return

#IfWinActive , Spotify
{
!s:: ; Select artist
	linkArtist(true)
	return
}

#if, WinActive("ahk_class Chrome_WidgetWin_1") || WinActive("ahk_class MozillaWindowClass")
{


	^RButton Up:: ; Open in new tab and switch to, queue and close tab
		;
		Send {RButton Up}       ; Cursor down enter
		Sleep, 400
		Send {Down}{Enter}       ; Cursor down enter
		Sleep, 500
		Send ^{Tab}       ; Next Tab
		Sleep, 800
		QueueVideo(false)
		Send ^w       ; Close Tab
		return


	^LButton:: ; Download
	!d:: ; Download
		QueueVideo(true)
		return
		
	!w::
	;
	; next on playlist
	;
		WinActivate,  , Youtube
		SendInput, +n
		return
		
	!p:: ; Download Playlist
		;
		; Read URL and post to vlohome
		;
		global vlohome

		url := ""
		url :=GetActiveBrowserURL()
		;msgbox, >%url%<
		;newStr := GetActiveWindowSong()
		whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
		whr.Open("POST", vlohome, true)
		whr.SetRequestHeader("User-Agent", "User-Agent")
		whr.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
		p1:=UriEncode(url)
		p2:=UriEncode("Playlist")
		p3 =%p2%|%p1%
		params=messagetypeID=MESS_TYPE_SCHEME&callerID=350&schemeID=320&commandvalue=%p1%|%p2%
		whr.Send(params)
		whr.WaitForResponse()
		status:=whr.Status
		response:=whr.ResponseText
		Needle:="OK"
		found:=InStr(response, Needle)
		;msgbox, %status%-%response%-%found%-%Needle%
		If (InStr(response, Needle)) && (status=200)
		{
			TrayTip addToQueue, %status% - %response%, ,0
			WinActivate,  , Youtube
			SendInput, +n
			Sleep 3000   ; Let it display for 3 seconds.
		}
		Else
		{
			TrayTip addToQueue, %status% - %response%, ,3
			Sleep 5000   ; Let it display for 3 seconds.
		}
		HideTrayTip()
		return


!q::
	;
	; select artist and search in find window
	;                  v
	; copy file name from window title
	;
	findDB()
	return

	queueVideo(gotoNext){	
		;
		;  When video on page playing
		;
		global vlohome

		url :=GetActiveBrowserURL()
		;msgbox, >%url%<
		newStr := GetActiveWindowSong()
		whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
		whr.Open("POST", vlohome, true)
		whr.SetRequestHeader("User-Agent", "User-Agent")
		whr.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
		p1:=UriEncode(url)
		p2:=UriEncode(newStr)
		p3 =%p2%|%p1%
		params=messagetypeID=MESS_TYPE_SCHEME&callerID=350&schemeID=320&commandvalue=%p1%|%p2%
		whr.Send(params)
		whr.WaitForResponse()
		status:=whr.Status
		response:=whr.ResponseText
		Needle:="OK"
		found:=InStr(response, Needle)
		;msgbox, %status%-%response%-%found%-%Needle%
		If (InStr(response, Needle)) && (status=200)
		{
			TrayTip addToQueue, %status% - %response%, ,0
			WinActivate,  , YouTube
			if (gotoNext) {
			   SendInput, +n
			}
			Sleep 2000   ; Let it display for 3 seconds.
		}
		Else
		{
			TrayTip addToQueue, %status% - %response%, ,3
			if (gotoNext) {
				SendInput, +n
			}
			Sleep 5000   ; Let it display for 3 seconds.
		}
		HideTrayTip()
		return
	}
}

#IfWinActive , 123Warhammer
{
+g:: ; drop granade
	SendInput g
    Sleep 1000
	Send {LButton}
	return


+d:: ; have shift down parry push slay
	Send {d down}{space}{d up}
    Sleep 500
	Send {LButton Down}
    Sleep 500
	Send {LButton Up}
	return

+a:: ; have shift down parry push slay
	Send {a down}{space}{a up}
    Sleep 500
	Send {LButton Down}
    Sleep 500
	Send {LButton Up}
	return

+s:: ; have shift down parry push slay
	Send {s down}{space}{s up}
    Sleep 500
    Send {LButton Down}
    Sleep 500
	Send {LButton Up}
	return
}


findDB()
{
	global vlosearch

	WinGet, ActiveId, ID, A
	rawStr := UriEncode(GetActiveWindowSong())

	ifWinNotExist,Music Videos - Vlo Home
	{
		Run, firefox.exe %vlosearch%%rawStr%
		return
	}
	else   
	{
		IfWinNotActive,  Music Videos - Vlo Home, , WinActivate, Music Videos - Vlo Home, 
		WinWaitActive,  Music Videos - Vlo Home, 
		Sleep, 100
	}
	SendInput, ^l
	sleep 100
	SendInput %vlosearch%%rawStr%{Enter}
	sleep 3000

	;WinWaitNotActive, ahk_id %ActiveId%
	WinActivate, ahk_id %ActiveId%
	return
}

;
;  Jump to Search 
;
ShowInExplorer(newStr)
{
	global MyPlayLists

	IfInString, newStr, %A_Space%ft%A_Space%
		StringLeft, newStr, newStr, InStr(newStr," ft ")-1
	IfInString, newStr, %A_Space%&%A_Space%
		StringLeft, newStr, newStr, InStr(newStr," & ")-1

	ifWinNotExist,Search Results in My Music Videos
	{
		mpara=/N,"\\SRVMEDIA\media\My Music Videos"
		Run, explorer %mpara%
		sleep 3000
	}
	else   
	{
		IfWinNotActive,  Search Results, , WinActivate, Search Results, 
		WinWaitActive,  Search Results, 
		Sleep, 100
	}
	SendInput, {F3}
	sleep 100
	SendInput %newStr%
	return
}

;
;
;
GetActiveWindowSong()
{
	global HTPCLogDir
	WinGetClass ActWinClass,A
	if ActWinClass in ExploreWClass,OMain,CabinetWClass,
	{
		Send, {F2}{CTRLDOWN}c{CTRLUP}{ESC}
		newStr := clipboard
	} else if ActWinClass=Chrome_WidgetWin_1 
		{
			WinGetActiveTitle, TheTitle
			newStr := TheTitle
		} else if ActWinClass=MozillaWindowClass 
			{
				WinGetActiveTitle, TheTitle
				newStr := TheTitle
			} else if ActWinClass=Qt5QWindowIcon
				{
					WinGetActiveTitle, newStr
				} else 
				{
					SendInput, ^c
					newStr := clipboard
				}
	ifInString newStr,Mozilla Firefox
	{
		newStr:=SubStr(newStr, 1, StrLen(newStr) - 18)
	}
	StringReplace, newStr, newStr,%A_Space%-%A_Space%Google%A_Space%Chrome,,All
	StringReplace, newStr, newStr,%A_Space%-%A_Space%YouTube,,All
	ifInString newStr,Spotify
	{
		newStr:=SubStr(newStr, 10)
	}
	return newStr
}

CleanFav(Favs)
{
;
;
;  Check Favorites if still existing or can find same diff place, extension
;
;
	global MyPlayLists
 
	m3uFav = %MyPlayLists%\%Favs%,
   
	loop, Parse, m3uFav,`,
	{
   
		m3u = %A_LoopField%.m3u
		filecopy, %m3u%, %A_LoopField%.bak, 1

		FileRead, filelist, %m3u%
		if not ErrorLevel  ; Successfully loaded.
		{
			filedelete, %m3u%
			loop, Parse, filelist,`r`n
			{
				StringReplace, atemp, A_LoopField,smb:,,All
				StringReplace, atemp, atemp,/,\,All
				splitpath, atemp, fname , fdir , fext, fnamenoext
				;msgbox %atemp% fname:%fname% fdir:%fdir% fext:%fext% fnoext:%fnamenoext%
				if fext contains avi,wmv,asf,flv,mp4,mkv
				{
					IfExist, %atemp%
					{
						fileappend, %A_LoopField%`n, %m3u%
					}
					else 
					{				
						fs=%fnamenoext%.*
						AddToFav(m3u, fs)
						if (ErrorLevel>0) 
						{
							Msgbox Could not find: %fs%
						}
					}
				}
			}

			FileRead, filelist, %m3u%
			if not ErrorLevel  ; Successfully loaded.
			{
				filedelete, %m3u%
				fileappend, #EXTM3U`n, %m3u%
				Sort, filelist, CL U
				fileappend, %filelist%, %m3u%
				filelist =  ; Free the memory.
			}
		}
	}
}	
;

FindOnDisk(ByRef MyFullPath,MySearchName, silent = False)
{
   global MyMusic

   SetBatchLines, -1  ; Make the operation run at maximum speed.
   cnt=
   MyFullPath=
   MyMess=%MyMusic%\%MySearchName%`n`nSearching...

   Loop, %MyMusic%\%MySearchName%, , 1
   {
		if A_LoopFileAttrib contains H,R,S  ; Skip any file that is either H (Hidden), R (Read-only), or S (System). Note: No spaces in "H,R,S".
			continue  ; Skip this file and move on to the next one.
		if A_LoopFileSizeKB < 20   ; Skip tbn/nfo
			continue  ; Skip this file and move on to the next one.
         cnt+= 1
         MyFullPath=%MyFullPath%%A_LoopFileFullPath%`n
   }
   ErrorLevel:=cnt-1 ; Found 1 is ok, More than 1 not so good; -1 = not found

return
}

AddToFav(m3u,fname)
{
   global MyMusic

   ifNotExist %m3u%
      fileappend, #EXTM3U`n, %m3u%

   FindOnDisk(MyFullPath, fname)

   if (ErrorLevel<0) ; Not Found
   {
      MyMess=%MyMusic%\*\%fname%`n`nFile not found
      if not silent
		Msgbox %MyMess%
        ErrorLevel:=1
		Return
   }
   if (ErrorLevel>0) ; Multiple Found
   {
      MyMess=%MyFullPath%`n`nMultiple matches found please add manually
	  if not silent
		Msgbox %MyMess%
        ErrorLevel:=1
		Return
   }
	StringReplace, MyFullPath, MyFullPath,\,/,All
	MyFullPath=smb:%MyFullPath%
   fileappend, %MyFullPath%, %m3u%
}

UriEncode(Uri, Enc = "UTF-8")
{
	StrPutVar(Uri, Var, Enc)
	f := A_FormatInteger
	SetFormat, IntegerFast, H
	Res:=
	Loop
	{
		Code := NumGet(Var, A_Index - 1, "UChar")
		If (!Code)
		Break
		If (Code >= 0x30 && Code <= 0x39 ; 0-9
			|| Code >= 0x41 && Code <= 0x5A ; A-Z
			|| Code >= 0x61 && Code <= 0x7A) ; a-z
			Res .= Chr(Code)
		Else
			Res .= "%" . SubStr(Code + 0x100, -1)
	}
	SetFormat, IntegerFast, %f%
	Return, Res
}

UriDecode(Uri, Enc = "UTF-8")
{
	Pos := 1
	Loop
	{
		Pos := RegExMatch(Uri, "i)(?:%[\da-f]{2})+", Code, Pos++)
		If (Pos = 0)
			Break
			VarSetCapacity(Var, StrLen(Code) // 3, 0)
			StringTrimLeft, Code, Code, 1
			Loop, Parse, Code, `%
				NumPut("0x" . A_LoopField, Var, A_Index - 1, "UChar")
				StringReplace, Uri, Uri, `%%Code%, % StrGet(&Var, Enc), All
	}
	Return, Uri
}

StrPutVar(Str, ByRef Var, Enc = "")
{
	Len := StrPut(Str, Enc) * (Enc = "UTF-16" || Enc = "CP1200" ? 2 : 1)
	VarSetCapacity(Var, Len, 0)
	Return, StrPut(Str, &Var, Enc)
}

; Copy this function into your script to use it.
HideTrayTip() {
    TrayTip  ; Attempt to hide it the normal way.
    if SubStr(A_OSVersion,1,3) = "10." {
        Menu Tray, NoIcon
        Sleep 200  ; It may be necessary to adjust this sleep.
        Menu Tray, Icon
    }
}

GetElementByName(AccObj, name)
{

	if (AccObj.accName(0) = name)
		return AccObj

	for k, v in Acc_Children(AccObj) 
		if IsObject(obj := GetElementByName(v, name))
	
	return obj
}

GetArtist(MyTitle)
{

	MyStart:=1
	IfInString MyTitle,%A_Space%-%A_Space%                       ; " - "
		StringGetPos MyEnd, MyTitle, %A_Space%-%A_Space%, L1
	else
	    dot:=Chr(183)
		IfInString MyTitle,%A_Space%%dot%%A_Space% 								; " ·" Spotify Reverse
		{
			StringGetPos MyStart, MyTitle,%A_Space%%dot%%A_Space%, L1
			MyStart+=3
			MyEnd:=0
		} 
		else
		IfInString MyTitle,%A_Space%-								; "- "
			StringGetPos MyEnd, MyTitle, %A_Space%-, L1
		 else
			IfInString MyTitle,-									; "-"
			   StringGetPos MyEnd, MyTitle, -, L1
			else
				IfInString MyTitle,%A_Space%(						; " ("
				{
					StringGetPos MyStart, MyTitle,%A_Space%(, L1
					MyStart:=MyStart+3
					StringGetPos MyEnd, MyTitle,), L1
					if (MyEnd = -1)
						MyEnd := StrLen(MyTitle)
					else
						MyEnd := MyEnd - MyStart + 1
				}
				else
					ifInString MyTitle,:%A_Space%					; ": "
						StringGetPos MyEnd, MyTitle, :%A_Space%, L1
					else
						StringGetPos MyEnd, MyTitle,%A_Space%, L1   ; " " 

   if (MyEnd = 0)
      MyEnd := StrLen(MyTitle)
	  
	
   StringMid ,NewStr,MyTitle,MyStart, MyEnd
   Return NewStr
}

Reminders:
IfWinExist, ahk_class #32770 ahk_exe OUTLOOK.EXE
{
    WinActivate  ; Automatically uses the window found above.
	;SoundBeep ,1000
    return
}
return

GetTitle(MyTitle, sArtist)
{
	StringReplace, sTitle, MyTitle,%sArtist%
	return CleanName(sTitle)
}

CleanName(fname)
{
   StringLower, fname, fname
   fname:=MyToAscii(fname)
   StringReplace, fname, fname,",%A_Space%,All 
   StringReplace, fname, fname,",%A_Space%,All 
   StringReplace, fname, fname, -%A_Space%PlanetaHD.Page,%A_Space%,All 
   StringReplace, fname, fname,music_video_vevo,%A_Space%,All 
   StringReplace, fname, fname,full1080p,%A_Space%,All 
   StringReplace, fname, fname,-%A_Space%planeata,%A_Space%,All 
   StringReplace, fname, fname,-%A_Space%planeta,%A_Space%,All 
   StringReplace, fname, fname,2011,%A_Space%,All 
   StringReplace, fname, fname,rip,%A_Space%,All 
   StringReplace, fname, fname,_,%A_Space%,All 
   StringReplace, fname, fname,%A_Space%amp%A_Space%,%A_Space%&%A_Space%,All 
   StringReplace, fname, fname,%A_Space%quot%A_Space%, %A_Space%-%A_Space% ,All 
   StringReplace, fname, fname,official music,,All 
   StringReplace, fname, fname,new video,,All 
   StringReplace, fname, fname,gull original song,,All 
   StringReplace, fname, fname,yeni orijinal video klip,,All 
   StringReplace, fname, fname,super kalite,,All 
   StringReplace, fname, fname,super kalite,,All 
   StringReplace, fname, fname,netteki en iyi alite,,All 
   StringReplace, fname, fname,klip,,All 
   StringReplace, fname, fname,clip,,All 
   StringReplace, fname, fname,orijinal,,All 
   StringReplace, fname, fname,full original,,All 
   fname := RegExReplace(fname, "i)full$", "")  										; Trim Last Space
   StringReplace, fname, fname,official,,All 
   StringReplace, fname, fname,lyrics,,All 
   StringReplace, fname, fname,video,,All 
   StringReplace, fname, fname,dvd,,All 
   StringReplace, fname, fname,720p,,All 
   StringReplace, fname, fname,%A_Space%clip,%A_Space%,All 
   StringReplace, fname, fname,`,,%A_Space%,All 
   StringReplace, fname, fname, %A_Space%hd%A_Space% ,,All 
   StringReplace, fname, fname, %A_Space%featuring%A_Space%,%A_Space%Ft%A_Space%,All 
   StringReplace, fname, fname, %A_Space%feat.%A_Space%,%A_Space%Ft%A_Space%,All 
   StringReplace, fname, fname, %A_Space%feat%A_Space%,%A_Space%Ft%A_Space%,All 
   StringReplace, fname, fname, %A_Space%ft.%A_Space%,%A_Space%Ft%A_Space%,All 

   StringReplace, fname, fname,digh definition,,All 
   fname := RegExReplace(fname, "i)hd$", "")  										; Trim Last Space
   StringReplace, fname, fname,hq,,All 
   StringReplace, fname, fname,high quality,,All 
   StringReplace, fname, fname,quality,,All 
   StringReplace, fname, fname,(hd),,All 
   StringReplace, fname, fname,(hd,,All 
   StringReplace, fname, fname,hd),,All 
   StringReplace, fname, fname,-, %A_Space%-%A_Space% ,All 
   StringUpper, fname, fname, T 
 
   StringReplace, fname, fname,%A_Space%%A_Space%%A_Space%,%A_Space%,All 
   StringReplace, fname, fname,%A_Space%%A_Space%%A_Space%,%A_Space%,All 
   StringReplace, fname, fname,%A_Space%%A_Space%,%A_Space%,All 
   StringReplace, fname, fname,%A_Space%%A_Space%,%A_Space%,All 
   StringReplace, fname, fname,%A_Space%%A_Space%,%A_Space%,All 
   StringReplace, fname, fname,( ),,All 
   StringReplace, fname, fname,(),,All 
   fname := RegExReplace(fname, "- -", "-")  	
   StringReplace, fname, fname,%A_Space%%A_Space%,%A_Space%,All 
   fname := RegExReplace(fname, "^([A-Z]) - ", "$1-")
   fname := RegExReplace(fname, "[0-9]\)$", "")  
   fname := RegExReplace(fname, "[ (\-\d\.]$", "")  
   fname := RegExReplace(fname, "[ (\-\d\.]$", "")  
   fname := RegExReplace(fname, "[ (\-\d\.]$", "")  
   fname := RegExReplace(fname, "[ (\-\d\.]$", "")  
   fname := RegExReplace(fname, "[ (\-\d\.]$", "")  
   fname := RegExReplace(fname, "[ (\-\d\.]$", "")  
   fname := RegExReplace(fname, "^[ \-\.]", "")  
   fname := RegExReplace(fname, "^[ \-\.]", "")  
   fname := RegExReplace(fname, "^[ \-\.]", "")  
; specials
   StringReplace, fname, fname,Ne - Yo,Ne-Yo,All 
   StringReplace, fname, fname,Don T,Don't,All 
   StringReplace, fname, fname,%A_Space%S%A_Space%,'s%A_Space%
   StringReplace, fname, fname,%A_Space%i%A_Space%m%A_Space%,%A_Space%I'm%A_Space%
   return fname
}

MyToAscii(InpStr)
{
	While StrLen(InpStr)>0
	{
		ascCode:=Asc(InpStr)
;		msgbox %ascCode%
		StringLeft,LastStr,InpStr,1
		StringRight,InpStr,InpStr,StrLen(InpStr)-1
;		msgbox %InpStr%

		if (ascCode>127 && ascCode<10000)
		{
			caselabel = case%ascCode%
			if IsLabel(caselabel)
			   goto case%ascCode%
			else
			   goto casedefault
casedefault:
			Msgbox "Need a conversion for %LastStr%, ASCII: %ascCode%"
			goto caseend

			
case180:
			ascCode:=Asc("'")
			goto caseend

case183:
			ascCode:=Asc("")
			goto caseend
			
case225:
case228:
			ascCode:=Asc("a")
			goto caseend
case231:
			ascCode:=Asc("c")
			goto caseend
case232:
case233:
case234:
			ascCode:=Asc("e")
			goto caseend
case241:
			ascCode:=Asc("n")
			goto caseend
case287:
			ascCode:=Asc("g")
			goto caseend
case237:
case304:
case305:
			ascCode:=Asc("i")
			goto caseend
case243:
case246:
			ascCode:=Asc("o")
			goto caseend
case351:
case353:
			ascCode:=Asc("s")
			goto caseend
case250:
case252:
case776:
			ascCode:=Asc("u")
			goto caseend
case174:
case9654:
			ascCode:=0
			goto caseend
caseend:
		}

		OutStr.=Chr(ascCode)
		
	}
;	msgbox "OutStr:%OutStr%"
	return OutStr
}
StringToHex(String)
	{
	local Old_A_FormatInteger, CharHex, HexString
	
	;Return '0' if the string was blank
	If !String
		Return 0
	
	;Save the current Integer format
	Old_A_FormatInteger := A_FormatInteger
	
	;Set the format of integers to their Hex value
	SetFormat, INTEGER, H
	
	;Parse the String
	Loop, Parse, String 
		{
		;Get the ASCII value of the Character (will be converted to the Hex value by the SetFormat Line above)
		CharHex := Asc(A_LoopField)
	
		;Comment out the following line to leave the '0x' intact
		StringTrimLeft, CharHex, CharHex, 2
		
		;Build the return string
		HexString .= CharHex . " "
		}
	;Set the integer format to what is was prior to the call
	SetFormat, INTEGER, %Old_A_FormatInteger%
	
	;Return the string to the caller
	Return HexString
	}

linkArtist(gotoNext){	
	;
	;  When video on page playing
	;
	global vlohome

	url := GetActiveBrowserURL()
	;msgbox, >%url%<
	newStr := GetActiveWindowSong()
	whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	whr.Open("POST", vlohome, true)
	whr.SetRequestHeader("User-Agent", "User-Agent")
	whr.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
	p1:=UriEncode(url)
	p2:=UriEncode(newStr)
	p3 =%p2%|%p1%
	params=messagetypeID=MESS_TYPE_COMMAND&commandID=488&callerID=350&commandvalue=%p1%|%p2%
	whr.Send(params)
	whr.WaitForResponse()
	status:=whr.Status
	response:=whr.ResponseText
	Needle:="OK"
	found:=InStr(response, Needle)
	;msgbox, %status%-%response%-%found%-%Needle%
	If (InStr(response, Needle)) && (status=200)
	{
		TrayTip addToQueue, %status% - %response%, ,0
		WinActivate,  , Spotify
		Sleep 2000   ; Let it display for 3 seconds.
	}
	Else
	{
		TrayTip addToQueue, %status% - %response%, ,3
		Sleep 5000   ; Let it display for 3 seconds.
	}
	HideTrayTip()
	return
}

GetActiveWindowTicker()
{

	if WinActive("StreetSmart Edge")
	{
		Click, 550 100
		Send, {CTRLDOWN}ac{CTRLUP}
		newStr := clipboard
	} 
	if WinActive("ahk_exe ActiveTraderPro.exe")
	{
		Send, {CTRLDOWN}ac{CTRLUP}
		newStr := clipboard
	} 
	if WinActive("ahk_class MozillaWindowClass") or WinActive("ahk_class Chrome_WidgetWin_1")
	{
		WinGetActiveTitle, TheTitle
		newStr := TheTitle
	}
	parts := StrSplit(newStr, [A_Tab, A_Space])
    return parts[1]
}

Save123123()
{

	if WinExist("StreetAHK")
	{
		WinActivate
		Click, 40, 185
		Send, {CTRLDOWN}ac{CTRLUP}
		newStr := clipboard
	} 
}
