WinIDs := {}
WinNames := {}
WindowName := TabWindowGui
CustomName := "null"
WinExes := {}
WinTitles := {}

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
		sectionName := A_LoopField
		;if section is already mapped then skip it
		if (WinExes.haskey(sectionName))
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
	for key, value in WinIDs
		IniWrite, %value%, mappings.ini, %key%, id

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

	TrayTip, Key set, %key% set to %name%, 2, 16
	return
}
