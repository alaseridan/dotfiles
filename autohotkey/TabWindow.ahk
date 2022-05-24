#Persistent
WinIDs := {}
WinNames := {}
WindowName := TabWindowGui
CustomName := "null"
WinExes := {}
WinTitles := {}
ListenList := {}

;listen for new windows, works but not useful right now
;Gui +LastFound
;hWnd := WinExist()
;DllCall("RegisterShellHookWindow", UInt,hWnd)
;OnMessage(DllCall("RegisterWindowMessage", Str,"SHELLHOOK"), "ShellMessage")
;return


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

!Pause::
	Input, PressedKey, L1 T5
	activeID := GetActiveWindow()
	activeName := GetActiveWindowName()
	activeProcess := GetActiveWindowExe()
	activeTitle := GetActiveWindowTitle()
	AddWindowTab(PressedKey, activeID, activeName, activeProcess, activeTitle)
return

Pause::OpenTabWindow()
	
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
					else ;add to list of processes to "listen" for
					{
						;AddToListenList(sectionName, process)
					}
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
		else
		{
			
			IniRead, mappedTitle, mappings.ini, %sectionName%, title
			;AddToListenList(sectionName, process)
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

	;RemoveFromListenList(title)

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

	if (oldTitle != newTitle and StrLen(newTitle) > 0)
	{
		;TrayTip, Titled Changed, %newTitle%, 1, 16
		WinTitles[key] := newTitle

		IniWrite, %newTitle%, mappings.ini, %key%, title
	}
}


;AddToListenList(key, process)
;{
;	global ListenList
;	;ListenObj := {}
;	;ListenObj.Key := key
;	;ListenObj.Process := process
;	if (ListenList.haskey(process))
;		return
;	ListenList[process] := key
;	TrayTip, Listen for , %process%, 1, 16
;	return
;}
;
;RemoveFromListenList(process)
;{
;	global ListenList
;	ListenList.Delete(process)
;	return
;}
;
;LoadListened(id, process, title)
;{
;	TrayTip, Checking for , %process%, 1, 16
;	global ListenList
;	if (ListenList.haskey(process))
;	{
;		TrayTip, Loading mapping for  , %process%, 1, 16
;		IniRead, name, mappings.ini, ListenList[process], name
;		AddWindowTab(ListenList[process], id, name, process, title)
;		ListenList.Delete(process)
;	}
;	return
;}
;
;ShellMessage(wP,lP)
;{
;	;TrayTip, Shell Message, wp = %wP%, 1, 16
;	if(wP = 1) ; window created, 4 window activated, 16 closed
;	{
;		newID := lP
;		WinGetTitle, Title, ahk_id %newID%
;		if(Title = "TabWindow.ahk")
;			return
;		;TrayTip, New Window , %Title% has entered the chat, 1, 16
;		WinGet, process, ProcessName, ahk_id %newID%
;		LoadListened(newID, process, Title)
;		return
;	}
;}
