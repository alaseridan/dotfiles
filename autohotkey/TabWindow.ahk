;#Persistent
WinIDs := {}
WinNames := {}
WindowName := TabWindowGui
CustomName := "null"
WinExes := {}
WinTitles := {}
WinLastPosList := {}

;listen for new windows, works but not useful right now
;Gui +LastFound
;hWnd := WinExist()
;DllCall("RegisterShellHookWindow", UInt,hWnd)
;OnMessage(DllCall("RegisterWindowMessage", Str,"SHELLHOOK"), "ShellMessage")
;return

;win+c to center a window, use the built in win+down to move it back
#c::
global WinLastPosList
WinExist("A")
activeID := GetActiveWindow()
WinGetPos, posX, posY, sizeX, sizeY
WinLastPosList[activeID] := [posX, posY]
WinMove, (A_ScreenWidth/2)-(sizeX/2), 0 ;(A_ScreenHeight/2)-(sizeY/2)
Return

;win+shift+c to restore to last known pos
#+c::
global WinLastPosList
WinExist("A")
activeID := GetActiveWindow()
lastPos := WinLastPosList[activeID]
WinMove, lastPos.1, lastPos.2
Return

~RControl Up::  
If (A_PriorHotkey=A_ThisHotkey && A_TimeSincePriorHotkey<400)

  If WinActive("ahk_class TscShellContainerClass") {
    ; minimize RDP, activate desktop
    WinMinimize, ahk_class TscShellContainerClass
    WinActivate, ahk_class Shell_TrayWnd
  } else if WinExist("ahk_class TscShellContainerClass") {
    ; activate RDP
    WinActivate, ahk_class TscShellContainerClass
  } 
Return

$F13::
$Pause::
if !Ta
  SetTimer, Ta, -200
Ta++
Return
Ta:
if Ta = 1
  OpenTabWindow()
else if Ta = 2
  AssignTabWindow()
Ta = 
Return

!F13::AssignTabWindow()


AssignTabWindow()
{
	Input, PressedKey, L1 T5
	activeID := GetActiveWindow()
	activeName := GetActiveWindowName()
	activeProcess := GetActiveWindowExe()
	activeTitle := GetActiveWindowTitle()
	AddWindowTab(PressedKey, activeID, activeName, activeProcess, activeTitle)
  return
}

;F13::OpenTabWindow()
	
SwitchToWindow()
{
	global WinIDs
	Input, PressedKey, L1 T5
	;for key, value in WinIDs
	;{
	;	tList.=key value "`n"
	;}
	WinID := WinIDs[PressedKey]
	WinActivate, ahk_id %WinID%
	CheckIfTitleChanged(PressedKey)
	Gui, Destroy
	Return
}

OpenTabWindow()
{
	global WinNames
	;Gui, Add, ListBox, , %WinIDs%
	for key, value in WinNames
		Gui, Add, Text,, %key% %value%
	Gui, Add, Button, gLoadIni, Load
	Gui, Add, Button, gSaveIni, Save
	Gui, Show, , %WindowName%
	SwitchToWindow()
	return
}

GetActiveWindow()
{
	WinGet, hWnd, ID, A
	WinGetClass, vWinClass, ahk_id %hWnd%
	return %hWnd%
}

GetActiveWindowName()
{
	global CustomName
	;get class and name, use which ever is shorter, or if too long allow the user to give a custom name?
	WinGetClass, Class, A
	WinGetTitle, Title, A
	classV := Class
	titleV := Title
	classLen := StrLen(classV)
	titleLen := StrLen(titleV)
	if (classLen > 15 and titleLen > 15)
	{
		GetCustomWindowName()
		return CustomName
	}
	if (classLen < titleLen)
	{
		return %Class%
	}
	else
	{
		return %Title%
	}
}

GetActiveWindowTitle()
{
	WinGetTitle, Title, A
	return %Title%
}

GetCustomWindowName()
{
	Gui, Add, Edit, vCustomName
	Gui, Add, Button, default, OK
	Gui, Show,, InputWindow
	WinWaitClose, InputWindow
	return
}

GetActiveWindowExe()
{
	WinGet, hWnd, ProcessName, A
	WinGetClass, vWinClass, ahk_exe %hWnd%
	return %hWnd%
}

ButtonOK()
{
	Gui, Submit
	Gui, Destroy
	return
}

LoadIni()
{
	IniRead, Sections, mappings.ini
	Loop Parse, Sections, `n
	{
		global WinExes
		global WinIDs
		sectionName := A_LoopField
		;if section is already mapped then skip it
		if (WinExes.haskey(sectionName) and WinExist("ahk_id" WinIDs[sectionName]))
		{
			continue
		}
		;get process of section
		IniRead, process, mappings.ini, %sectionName%, process
		if (process = "ERROR")
			continue
		;check if process is open
		if (process != "process" and CheckIfProcessExist(process))
		{
			;if more than one process instance is open, check the title
			WinGet, windowIds, List, % "ahk_exe" process

			wids := ""

			Loop, %windowIds%
			{
				wids.= windowIds%A_Index% "`n"
			}
			;MsgBox, count of %windowIds% Window IDs found for %process% `n%wids%

			if (windowIds > 1) ;don't use Length, the value of windowIds is the length
			{
				;if title not found, continue to next section
				Loop, %windowIds%
				{
					id := windowIds%A_Index%
					WinGetTitle, title, ahk_id %id%
					IniRead, mappedTitle, mappings.ini, %sectionName%, title
					if (title = mappedTitle)
					{
						;get the window id, read the key and map it
						IniRead, mappedName, mappings.ini, %sectionName%, name
						AddWindowTab(sectionName, id, mappedName, process, title)
					}
					;else
					;{
					;	MsgBox, %title% `nnot found in %process% `nLooking for `n%mappedTitle%
					;}
				}
			}
			else if (windowIds = 1)
			{
				;else get the window id, read the key and name and map it
				id := windowIds1 ;Each ID number is stored in a variable whose name begins with OutputVar's own name;
				WinGetTitle, title, ahk_id %id%

				IniRead, mappedName, mappings.ini, %sectionName%, name
				AddWindowTab(sectionName, id, mappedName, process, title)
			}
		}
	}
	Gui, Destroy
	Return
}

SaveIni()
{
	global WinExes
	global WinTitles
	global WinNames
	global WinIDs
	for key, value in WinExes
		IniWrite, %value%, mappings.ini, %key%, process
	for key, value in WinTitles
		IniWrite, %value%, mappings.ini, %key%, title
	for key, value in WinNames
		IniWrite, %value%, mappings.ini, %key%, name

	Gui, Destroy
	Return
}

CheckIfProcessExist(processName)
{
	Process, Exist, %processName%
	if ErrorLevel = 0
	{
		return false
	}
	return true
}

AddWindowTab(key, id, name, process, title)
{
	global WinExes
	global WinTitles
	global WinNames
	global WinIDs
	WinIDs[key] := id
	WinNames[key] := name
	WinExes[key] := process
	WinTitles[key] := title

	TrayTip, Key set, %key% set to %name%, 0.5, 16
	return
}

CheckIfTitleChanged(key)
{
	global WinTitles
	global WinIDs
	winID := WinIDs[key]
	oldTitle := WinTitles[key]
	WinGetTitle, newTitle, ahk_id %winID%

	if (oldTitle != newTitle)
	{
		;TrayTip, Titled Changed, %newTitle%, 1, 16
		WinTitles[key] := newTitle

		IniWrite, %newTitle%, mappings.ini, %key%, title
	}
}

;ShellMessage(wP,lP)
;{
;	TrayTip, Shell Message, wp = %wP%, 1, 16
;	if(wP = 1) ; window created, 4 window activated, 16 closed
;	{
;		newID := lP
;		WinGetTitle, Title, ahk_id %newID%
;		if(Title = "TabWindow.ahk")
;			return
;		;TrayTip, New Window , %Title% has entered the chat, 1, 16
;		return
;	}
;	if(wP = 16)
;	{
;		
;	}
;}
