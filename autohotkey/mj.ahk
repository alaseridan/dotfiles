#NoEnv
#Persistent
SetTimer, WakeMe, 5000
Return

WakeMe:
	If A_TimeIdlePhysical > 240000
		MouseMove,0,0,0,R
Return