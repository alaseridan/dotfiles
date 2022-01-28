WinIDs := {}
WinNames := {}
WindowName := TabWindowGui
CustomName := "null"

!Pause::
	Input, PressedKey, L1 T5
	activeWindow := GetActiveWindow()
	WinIDs[PressedKey] := activeWindow
	activeTitle := GetActiveWindowName()
	WinNames[PressedKey] := activeTitle
	MsgBox, %PressedKey% set to %activeTitle%
return

Pause::OpenTabWindow()
	
SwitchToWindow()
{
	global WinIDs
	Input, PressedKey, L1 T5
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
	Gui, Show, , %WindowName%
	SwitchToWindow()
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
GetCustomWindowName()
{
	Gui, Add, Edit, vCustomName
	Gui, Add, Button, default, OK
	Gui, Show,, InputWindow
	WinWaitClose, InputWindow
	return
}

ButtonOK:
{
	Gui, Submit
	Gui, Destroy
}
