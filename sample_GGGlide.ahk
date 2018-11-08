;
;GGGlide v1.97.1 by IOrot - Ergonomic & Productivity Pointer Momentum Enhancement
;
;	Notes:
; - Hardcoded physics.
; - Glide Activation Threshold was setup at 35.
; - Time Activation Threshold was setup at 1055.
;
#NoEnv	;Recommended for performance and compatibility with future AutoHotkey releases.
;#Warn	;Enable warnings to assist with detecting common errors.
#SingleInstance	Force
#Persistent
ListLines,	Off
Critical	1000000000000000
SetFormat, Floatfast,	0.11
SetFormat, IntegerFast,	d
ver:="1.97.1"
skipStartupDialog:=0	;1 - skip, 0 - show.
iniFile:="GGGlide.ini"
Gosub, GGGlideIcon
start:
Gosub, SettingsIni ;Create/read script ini file.
Gosub, OSPointerSettings	;Set default pointer settings.
Gosub, VarInit ;Initialise variables.
GGGlide:
OnExit("ExitFunc") ;Register a function to be called on exit.
OnMessage(0x8080,"Change_Ico")
If NOT(RI_RegisterDevices())	;RawInput register. Flag QS_RAWINPUT = 0x0400
MsgBox RegisterRawInputDevices failure.
DllCall("Winmm\timeBeginPeriod", "UInt", TimePeriod)	;Provide adequate resolution for Sleep.
VarSetCapacity(lpP, 12, 0)
lpP_addr := &lpP ;Pointer reference to XY pointer coordinates.
Menu, Tray, Icon, HICON:*%hICon%
TrayTip, GGGlide, Enabled, 0, 0
velocity_monitor:
Loop { ;Velocity Loop - pointer movement monitor.
Sleep, -1
DllCall("Sleep", "UInt", 19)
If !((DllCall("GetQueueStatus", "UInt", 0x0400) >> 16) & 0xFFFF) {
If (Array2+Array1+Array0<35) {	;Compare filtered average speed to Glide Activation Threshold.
i:=mod(A_Index,3), Array%i%:=0 ;Update speed reading.
Continue ;Below speed threshold, resume velocity monitoring.
}
Break ;Pointer has stopped moving. Exit velocity monitor loop and glide.
}
;Calculate: x/y axis pointer velocity vx/vy, pointer speed. Store speed and velocity components for each data point in moving average window.
DllCall("QueryPerformanceCounter", "Int64*", cT1), DllCall("GetCursorPos", "Ptr", lpP_addr), i:=mod(A_Index,3), ArrayX%i%:=vx:=2468105*((x1:= NumGet(lpP, 0, "Int"))-x0)/(cT1-cT0), ArrayY%i%:=vy:=2468105*((y1:= NumGet(lpP, 4, "Int"))-y0)/(cT1-cT0), Array%i%:=Round(Sqrt(vx**2+vy**2)), x0:=x1, y0:=y1, cT0:=cT1
}
;Get highest speed and equivalent velocity readings within moving average window.
Array0>Array1 ? (Array0>Array2 ? (vx:=Round(0.665*ArrayX0),vy:=Round(0.665*ArrayY0),v:=Sqrt(vx**2+vy**2)) : (vx:=Round(0.665*ArrayX2),vy:=Round(0.665*ArrayY2),v:=Sqrt(vx**2+vy**2))) : (Array1>Array2 ? (vx:=Round(0.665*ArrayX1),vy:=Round(0.665*ArrayY1),v:=Sqrt(vx**2+vy**2)) : (vx:=Round(0.665*ArrayX2),vy:=Round(0.665*ArrayY2),v:=Sqrt(vx**2+vy**2)))
;If pointer will travel below 200 pixels within approx. 1s
If ((1-Exp(1055*-0.71575335/1000))*v<200)
Goto, velocity_monitor
Array2:=Array1:=Array0:=0
Loop { ;Gliding Loop - pointer glide.
;Calculate elapsed time from Velocity Loop exit and simulate inertial pointer displacement.
DllCall("Sleep", "UInt", 1), DllCall("QueryPerformanceCounter", "Int64*", cT0), fff:= 1-Exp((cT0-cT1)*-0.290/1007500)
If (((DllCall("GetQueueStatus", "UInt", 0x0400) >> 16) & 0xFFFF) OR fff>0.978) { ;Halt on user input/thresh.
DllCall("GetCursorPos", "Ptr", lpP_addr), x0:=NumGet(lpP, 0, "Int"), y0:=NumGet(lpP, 4, "Int")
Goto, velocity_monitor
}
DllCall("SetCursorPos", "Int", vx*fff+x1, "Int", vy*fff+y1)
}
Return
VarInit:	;Initialise variables.
TimePeriod:=1
cT0:=cT1:=0	;Counters
x1:=y1:=x0:=y0:=0	;Coordinates
i:=0, vx:=vy:=0, fff:=0.0, v:=0.0
Array0:=Array1:=Array2:=0 ;Speeds
ArrayX0:=ArrayY0:=ArrayX1:=ArrayY1:=ArrayX2:=ArrayY2:=0.0	;Velocity components
Return
SettingsIni:
IniRead, resetDefaults, %iniFile%, OSsettings, resetDefaults
if (!FileExist(iniFile) OR resetDefaults=="ERROR")	{
MsgBox, 67,Welcome to GGGlide ver. %ver% by IOrot,It is highly recommended to use the default Windows settings for your pointing device.`nProceed changing to defaults at launch?`n(Revert anytime at 'Start>Mouse>Pointer Options>Motion').
IfMsgBox Yes
IniWrite, 1, %iniFile%, OSsettings, resetDefaults
IfMsgBox No
IniWrite, 0, %iniFile%, OSsettings, resetDefaults
IfMsgBox Cancel
ExitApp
}
IniRead, resetDefaults, %iniFile%, OSsettings, resetDefaults
Return
OSPointerSettings: ;Restore to default any OS pointer settings and confirm OS pointer settings values.
SPI_GETMOUSESPEED = 0x70
SPI_SETMOUSESPEED = 0x71
SPI_GETMOUSE = 0x0003
SPI_SETMOUSE = 0x0004
MouseSpeed:="", lpParams:=""
;Set mouse speed to default 10 and get value.
If (resetDefaults)
DllCall("SystemParametersInfo", UInt, SPI_SETMOUSESPEED, UInt, 0, Ptr, 10, UInt, 0)
DllCall("SystemParametersInfo", UInt, SPI_GETMOUSESPEED, UInt, 0, UIntP, MouseSpeed, UInt, 0)
;Set mouse acceleration to off and get values.
VarSetCapacity(vValue, 12, 0)
NumPut(0, lpParams, 0, "UInt"),	NumPut(0, lpParams, 4, "UInt"),	NumPut(0, lpParams, 8, "UInt")
If (resetDefaults)
DllCall("SystemParametersInfo", UInt, SPI_SETMOUSE, UInt, 0, UInt, &vValue, UInt, 1)
DllCall("SystemParametersInfo", UInt, SPI_GETMOUSE, UInt, 0, UInt, &vValue, UInt, 0)
acThr1:=NumGet(vValue, 0, "UInt"), acThr2:= NumGet(vValue, 4, "UInt"),acOn:= NumGet(vValue, 8, "UInt") ;"Enhance pointer precision" setting
VarSetCapacity(vValue, 0)
If (resetDefaults)
resetText:=	"`t OS settings modified !"
Else
resetText:=	"`t OS settings unchanged."
IniRead, st, %iniFile%, GlideParameters, speedThreshold
If NOT(skipStartupDialog) {
MsgBox, 3, GGGlide %ver% by IOrot, Speed Glide Threshold:`t%st%`n`n Windows Mouse Parameters`n`tSpeed:`t%MouseSpeed%`n`tAcceleration`n`t EnhPPr:`t%acOn%`n`t Thr1:`t%acThr1%`n`t Thr2:`t%acThr2%`n`n%resetText%`n`nRetain GGGlide launch options?, 7
IfMsgBox No
{
IniDelete, %iniFile%, OSsettings, resetDefaults
Goto, start	;Reload
}
IfMsgBox Cancel
ExitApp
}
Else
DllCall("Sleep", "UInt", 850)
Return
GGGlideIcon:
;Icons by IOrot.
;
global hIConOff, hICon
IconDataHex =0000010001001010000001002000810200001600000089504e470d0a1a0a0000000d49484452000000100000001008060000001ff3ff61000000097048597300000b1300000b1301009a9c180000023349444154388d8dd05f4853711407f0efbddbfdb3ed4e7130dd76d585fdd1c5b451442f15a340582ff5d45b504f3ed440422432881e427a280b25224744afa3049f82c010828494a1861581e0b4e9a8f6cfdddddd7b7f77bf1e82186b5c3d705e0edff3e170184a29ea6be8e6c8158e18af98aafa73f2f98376c0c4dfae01a0001800fe7f79a6117896984e5577cb9164f235646fdb72b8bb2b12bf10455bec329a15db38306b6c297af634823d07b0b0bc7aaca555bac40b5cd3e5a6805a5145629ab8188bc129b9f166eec38c5de09dfb0674a2398ac512048788c1f3e7a0d628ae3e4c14f60d504aed6a5545b15040c0df8193278e63fbd76feecef0f5f793f7c6b036376b0dd408950d9d40a96a50550da1de2338dcdb87d497ef51c92d0df3a2c31a30296175c380a6692084a0582a61a03f0c7f6710f38bab13026f3fb3d705122104ba6180520a9d1064b67710e892e1f67a917cf731610d50130621d0340d92e482e470229d4e63676b733728cbf1d60edfa025c0711c5c2e17ec2c0bd3acc1e76b8720f05015c53d323a3a55512a1b7bfc80229fcf81b20cba8341783c1ef082887ca1881713e3b7e2f11bd64f9c5f58bc9ddecafcd8cce6afe5ca4a5674883874b007a58a8a4f2b5fef36e6ff036c36769ce7b84ea7c0bf4cad7d4b28650591817e844247912b2be2d2db99687ddede08300c033b67c3d3e42c40e9f4a970df98a745822cfbe112789de5c4b4e5050c001bc3022c03d8d88da595cff73399ec7a500e4c3d7af25820c458afcfff015876e73759199f9a0000000049454e44ae426082
hICon:=Hex2Icon(IconDataHex)
IconDataHex =0000010001001010000001002000a70200001600000089504e470d0a1a0a0000000d49484452000000100000001008060000001ff3ff61000000097048597300000b1300000b1301009a9c180000025949444154388d75d25d4853611cc7f1ef993bdbcee6668a96db4437937c814a1114236c45174a17194a17451004d5ad7553187823bddc4620641408dd0c52a2842ea482228444b3f28d42d406e994f6d2ceced9dc3c5d38edb4d973f73ccffff7795e85f1c646f4ed61abef8298da18145465ede2c4c45efe6d66a014b001ab40c8905540435df5b52aaf8789af3325f7dcce4fba2907d001f40383c055a03007486f1aa2bed6a354547a189bfa72f85ddb890ec00e7401778036a001380338730025ae5852e934a7dbdbb1e6db1979fd7e384fb29c037a800a40c894ae03b11c20994a48914814b364e194ef1875a934e1e4463f50a90b2f014f809fc66c40d334a3a22ac48241ea3792949944ecaaba1d1480efc06de01590c8d9c1664a73a77fcb98e7e6f1cccce24824fede8f288681bbc03320029003084925cf343d8d6b7212aba280a68120103599795b54b4a7e8567700886ed76703f6d21f015be1d8181659de19942d16166aaa59f17a199e5dbaaf0fe8efc00e74d5cccf222acacea06ab3f1c16e27a06dc63ce5e5370b8a8b5fec0638804ea047d285e3361be1e626165783c8aa9a7fdcef7f907d6443267c16e865eba9b6569624422d2d189a9bc06a23148e3075bef3c66e800fb84ee69368a0c52529b5ec2878bce87405cd050eaaf657128d2b7cfc3cd7fb3fc09be96b022c5b15e5ca81d595eef16f0b03724ca6fed0416a6bebf815932df4f5f8b28118a0002a300ff4017e20ea1f191d08ac04595b5fc3ed76e27695250da265590fe45d76b95420044c018f809719944b5663e4b9d1244a46b1ccb5afe4e9c9a1a123dae89b901ef8030acdd4325779f2940000000049454e44ae426082
hIConOff:=Hex2Icon(IconDataHex)
IconDataHex:=""
Menu, Tray, Icon, HICON:*%hIConOff%
Menu, Tray, Tip, GGGlide
Return
Hex2Icon(IconDataHex) {
;Code by SKAN: https://autohotkey.com/board/topic/31044-crazy-scripting-include-an-icon-in-your-script/
VarSetCapacity( IconData,( nSize:=StrLen(IconDataHex)//2) )
Loop %nSize% ; MCode by Laszlo Hars: http://www.autohotkey.com/forum/viewtopic.php?t=21172
NumPut( "0x" . SubStr(IconDataHex,2*A_Index-1,2), IconData, A_Index-1, "Char" )
IconDataHex := ""
hIConf := DllCall( "CreateIconFromResourceEx", UInt,&IconData+22, UInt,NumGet(IconData,14)
, Int,1, UInt,0x30000, Int,16, Int,16, UInt,0 )
VarSetCapacity(IconData, 0)	;IOrot: added freeing up of memory.
Return hIConf
}
;Code by https://github.com/AHK-just-me/RawInput/blob/master/Sources/RI.ahk
RI_RegisterDevices(Page := 1, Usage := 2, Flags := 0x0100, HGUI := "") {
Flags &= 0x3731 ; valid flags
If Flags Is Not Integer
Return False
If (Flags & 0x01) ; for RIDEV_REMOVE you must call RI_UnRegisterDevices()
Return False
StructSize := 8 + A_PtrSize ; size of a RAWINPUTDEVICE structure
; Usage has to be zero in case of RIDEV_PAGEONLY, flags must include RIDEV_PAGEONLY if Usage is zero.
If ((Flags & 0x30) = 0x20)
Usage := 0
Else If (Usage = 0)
Flags |= 0x20
; HWND needs to be zero in case of RIDEV_EXCLUDE
If ((Flags & 0x30) = 0x10)
HGUI := 0
Else If (HGUI = "")
HGUI := A_ScriptHwnd
VarSetCapacity(RID, StructSize, 0) ; RAWINPUTDEVICE structure
NumPut(Page, RID, 0, "UShort")
NumPut(Usage, RID, 2, "UShort")
NumPut(Flags, RID, 4, "UInt")
NumPut(HGUI, RID, 8, "Ptr")
Return DllCall("RegisterRawInputDevices", "Ptr", &RID, "UInt", 1, "UInt", StructSize, "UInt")
}
ExitFunc(ExitReason, ExitCode) {
global TimePeriod, lpP, hIConOff
Menu, Tray, Icon, HICON:*%hIConOff%
TrayTip, GGGlide, Terminating, 0, 0
DllCall("Sleep", "UInt", 1500)
DllCall("Winmm\timeEndPeriod", UInt, TimePeriod) ; Should be called to restore system to normal.
VarSetCapacity(lpP, 0)	;Free memory.
Return
}
Change_Ico(wP) {
global change_ico_tog
If (wP==0)
change_ico_tog := !change_ico_tog
Else If (wP==1) ;Force resume
 change_ico_tog := 0
Else ;Force pause
change_ico_tog := 1
If (change_ico_tog = 1)
toPause()
Else If (change_ico_tog = 0)
toResume()
}
toPause()
{
global hIConOff
TrayTip, GGGlide, Paused., 0, 0
Menu, Tray, Icon, HICON:*%hIConOff%
Menu, Tray, Icon,,, 1
Gosub, VarInit ;Initialise variables.
}
toResume()
{
global hICon
TrayTip, GGGlide, Resumed!, 0, 0
Menu, Tray, Icon, HICON:*%hICon%
}