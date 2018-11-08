
;
;SSStumble v0.01 by IOrot - GGGlide Add-On
;
;	Notes:
; - This is meant to disable GGGlide (v1.97.1 and above) on user selected pointing devices.
; - GGGlide is an Ergonomic & Productivity Pointer Momentum Enhancement.
;
;
#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance	Force
SendMode Input ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir% ; Ensures a consistent starting directory.
glideahk:="GGGlide.ahk"
glideini:="GGGlide.ini"
SSStumble:
global detected_handles, disabled_devices
disabled_devices:=[]
detected_handles:=[]
Menu, Tray, Icon, Shell32.dll, 126, 1
OnExit("ExitFunc")
IniRead, disabled_devices_t, %glideini%, SSStumble, disabledOnDevices
If (disabled_devices_t=="ERROR")
disabled_devices:=[]
Else
disabled_devices:=StrSplit(disabled_devices_t, ",")
If NOT(RI_RegisterDevices())
MsgBox RegisterRawInputDevices failure.
OnMessage(0x00FF, "OnRawInput") ; WM_INPUT
Sleep, 250
MsgBox , 3, SSStumble, Would you like to disable GGGlide on a pointing device?`n (Move your pointer after clicking "Yes" with the said device to select it)., 10
IfMsgBox Yes
Gosub, add_device
IfMsgBox Cancel
ExitApp
disabled_handles:=[]
DevArr := RI_GetDeviceList()
For Index, Dev In DevArr.Lst {
DevName := RI_GetDeviceName(Dev.Handle)
DevInfo := RI_GetDeviceInfo(Dev.Handle)
If (DevInfo.Page==1 AND DevInfo.Usage==2) {
for k, v in disabled_devices
If (DevName==v)
disabled_handles.Push(Dev.Handle)
}
}
monitor_input:
If (disabled_devices.Length()==0) {
MsgBox, , SSStumble, No devices stored. Terminating., 5
ExitApp
}
If (disabled_handles.Length()==0) {
MsgBox, ,SSStumble, No disabled devices detected., 5
;Run %glideahk%	;Launch GGGlide
;ExitApp
}
Run %glideahk%	;Launch GGGlide
running := 1
Sleep, 1000
detected_handles:=[]
Loop {
If (detected_handles.Length()!=0) {
same_state:=1
active_handle:=GetMax(detected_handles), detected_handles:=[]
for k, v in disabled_handles
If (active_handle==v){
same_state:=0
If (running) {
;running := 0
TogglePause()
Break
}
}
If (same_state AND NOT(running)) {
TogglePause()
;running := 1
}
}
Sleep, 100
}
Return
add_device:
global detected_handles, disabled_devices
detected_handles:=[]
Loop 100 {
ToolTip, % A_Index "/100`n" ExploreObj(detected_handles), 0, 0
Sleep, 50
}
ToolTip, ,0 ,0
If (detected_handles.Length()==0) {
MsgBox , 3, SSStumble - No Mouse Input, No input was detected.`nMove the pointer with the mouse you want to add to the disabled devices list.`nTry again?,
IfMsgBox Yes
Gosub, add_device
IfMsgBox Cancel
ExitApp
IfMsgBox No
Goto, monitor_input
}
selected_handle:=GetMax(detected_handles)
detected_handles:=[]
handle:=Format("0x{:X}", selected_handle)
selected_device_name:=RI_GetDeviceName(handle)
for k, v in disabled_devices {
If (selected_device_name==v){
MsgBox , 3, SSStumble - Duplicate Device, The selected device is already saved. Try again?,
IfMsgBox Yes
Gosub, add_device
IfMsgBox Cancel
ExitApp
IfMsgBox No
Goto, monitor_input
}
}
MsgBox, 3, SSStumble - Save Device,% "Device found !`nWhen this device receives input GGGlide will be paused automatically and resumed again when using any other pointing device.`nAdd device: " selected_device_name "`n?",
IfMsgBox Cancel
ExitApp
IfMsgBox No
Goto, monitor_input
disabled_devices.Push(selected_device_name)
strDH:=Join(",", disabled_devices)
ToolTip, % strDH
IniWrite, % RTrim(strDH, ","), %glideini%, SSStumble, disabledOnDevices
ToolTip, ,0 ,0
MsgBox, 0, SSStumble - Success!,% "Device added!`nWhen this device receives input GGGlide will be paused.`n(If you change the USB port of the device you need to add it again).",
Return
TogglePause(){
global running
running := ! running
ToggleGGGlidePause()
}
ToggleGGGlidePause()
{
global glideahk
DetectHiddenWindows On	; Allows a script's hidden main window to be detected.
SetTitleMatchMode 2 ; Avoids the need to specify the full path of the file below.
SendMessage, 0x8080, 0,,, %glideahk% - AutoHotkey	; Change Tray Icon.
PostMessage, 0x111, 65306,,, %glideahk% - AutoHotkey	; Pause.
;PostMessage, 0x111, 65306, 1,, %glideahk% - AutoHotkey	; Pause On
;PostMessage, 0x111, 65306, 2,, %glideahk% - AutoHotkey	; Pause Off
}
ExitFunc()
{
global glideahk
DetectHiddenWindows On ; Allows a script's hidden main window to be detected.
SetTitleMatchMode 2 ; Avoids the need to specify the full path of the file below.
WinClose %glideahk% - AutoHotkey
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
;Code by https://github.com/AHK-just-me/RawInput/blob/master/Sources/RI.ahk
; ================================================================================================================================
; Raw input message handlers
; ================================================================================================================================
OnRawInput(Type, RawInput, Msg, HWND) { ; WM_INPUT
;Gui, Main: Default
;Gui, ListView, RawInput
global detected_handles
If (InputObj := RI_GetData(RawInput)) {
;InputStr := ""
;For Each, Key In InputObj["*Keys"]
; InputStr .= (InputStr ? ", " : "") . Key . ": " . InputObj[Key]
;LV_Add("", InputStr)
;ToolTip, % InputStr, 0, 0
;ToolTip, % InputObj["Handle"], 0, 0
;detected_handles.Push(InputObj["Handle"])
If (detected_handles[InputObj["Handle"]]=="")
detected_handles[InputObj["Handle"]]:=0
detected_handles[InputObj["Handle"]]+=1
;Array[Key] := Value
}
Return DllCall("DefWindowProc", "Ptr", HWND, "UInt", Msg, "Ptr", Type, "Ptr", RawInput, "Ptr")
}
; ================================================================================================================================
; GetRawInputData() -> msdn.microsoft.com/en-us/library/windows/desktop/ms645596(v=vs.85).aspx
; You must pass the lParam of the WM_INPUT message as the data handle.
; On success, the function returns an object containing the following key-value pairs:
; All devices:
; *Keys - A simple array containing the valid keys for this object.
; DevType - The type of device: 0 = TYPEMOUSE, 1 = TYPEKEYBOARD, 2 = TYPEHID
; Handle - The handle to the device generating the raw input data.
; Param - The value passed in the wParam parameter of the WM_INPUT message.
; Mouse devices (DevType = 0) -> msdn.microsoft.com/en-us/library/windows/desktop/ms645578(v=vs.85).aspx:
; State - The mouse state.
; BtnFlags - The transition state of the mouse buttons.
; BtnData - If BtnFlags is RI_MOUSE_WHEEL, this member is a signed value that specifies the wheel delta.
; RawBtns - The raw state of the mouse buttons.
; LastX - The motion in the X direction, signed relative or absolute motion, depending on the value of State.
; LastY - The motion in the Y direction, signed relative or absolute motion, depending on the value of State.
; Extra - The device-specific additional information for the event.
; Keyboard devices (DevType = 1) -> msdn.microsoft.com/en-us/library/windows/desktop/ms645575(v=vs.85).aspx:
; SC - The scan code from the key depression.
; Flags - Flags for scan code information.
; VK - Windows message compatible virtual-key code.
; Msg - The corresponding window message, for example WM_KEYDOWN, WM_SYSKEYDOWN, and so forth
; Extra - The device-specific additional information for the event.
; HID devices (DevType = 2) -> msdn.microsoft.com/en-us/library/windows/desktop/ms645549(v=vs.85).aspx:
; Size - The size, in bytes, of each HID input in Data.
; Count - The number of HID inputs in Data.
; Data - The raw input data, as hexadecial strings separated by one space.
; ================================================================================================================================
;Code by https://github.com/AHK-just-me/RawInput/blob/master/Sources/RI.ahk
RI_GetData(Handle) {
; RID_INPUT = 0x10000003
Static Keys := {0: ["DevType", "Handle", "Param", "State", "BtnFlags", "BtnData", "RawBtns", "LastX", "LastY", "Extra"]
, 1: ["DevType", "Handle", "Param", "SC", "Flags", "VK", "Msg", "Extra"]
, 2: ["DevType", "Handle", "Param", "Size", "Count", "Data"]}
HdrSize := 8 + (A_PtrSize * 2)
Size := 0
DllCall("GetRawInputData", "Ptr", Handle, "UInt", 0x10000003, "Ptr", 0, "UIntP", Size, "UInt", HdrSize)
If (Size) {
VarSetCapacity(Data, Size, 0)
If (DllCall("GetRawInputData", "Ptr", Handle, "UInt", 0x10000003, "Ptr", &Data, "UIntP", Size, "UInt", HdrSize) = Size) {
DevType := NumGet(Data, 0, "UInt")
DataObj := {}
DataObj["*Keys"] := Keys[DevType]
DataObj["DevType"] := DevType
DataObj["Handle"] := NumGet(Data, 8, "UPtr")
DataObj["Param"] := NumGet(Data, 8 + A_PtrSize, "UPtr")
DataAddr := &Data + HdrSize
If (DevType = 0) { ; RIM_TYPEMOUSE
DataObj["State"] := Format("0x{:04X}", NumGet(DataAddr + 0, "UShort"))
DataObj["BtnFlags"] := Format("0x{:04X}", NumGet(DataAddr + 4, "UShort"))
DataObj["BtnData"] := Format("0x{:04X}", NumGet(DataAddr + 6, "UShort"))
DataObj["RawBtns"] := Format("0x{:08X}", NumGet(DataAddr + 8, "UInt"))
DataObj["LastX"] := NumGet(DataAddr + 12, "Int")
DataObj["LastY"] := NumGet(DataAddr + 16, "Int")
DataObj["Extra"] := Format("0x{:08X}", NumGet(DataAddr + 20, "UInt"))
Return DataObj
}
If (DevType = 1) { ; RIM_TYPEKEYBOARD
DataObj["SC"] := Format("{:03X}", NumGet(DataAddr + 0, "UShort"))
DataObj["Flags"] := NumGet(DataAddr + 2, "UShort")
DataObj["VK"] := Format("{:02X}", NumGet(DataAddr + 6, "UShort"))
DataObj["Msg"] := Format("0x{:04X}", NumGet(DataAddr + 8, "UInt"))
DataObj["Extra"] := Format("0x{:08X}", NumGet(DataAddr + 12, "UInt"))
Return DataObj
}
If (DevType = 2) { ; RIM_TYPEHID
SizeHID := NumGet(DataAddr + 0, "UInt")
CountHID := NumGet(DataAddr + 4, "UInt")
RawData := ""
DataAddr += 8
Loop, %CountHID% {
Loop, %SizeHID%
RawData .= Format("{:02X}", NumGet(DataAddr++, "UChar"))
RawData .= " "
}
DataObj["Size"] := SizeHID
DataObj["Count"] := CountHID
DataObj["Data"] := RTrim(RawData)
Return DataObj
}
}
}
Return False
}
;Code by https://github.com/AHK-just-me/RawInput/blob/master/Sources/RI.ahk
; ================================================================================================================================
; GetRawInputDeviceList() -> msdn.microsoft.com/en-us/library/windows/desktop/ms645598(v=vs.85).aspx
; On success, the function returns a simple array of objects containing the following key-value pairs:
; Handle - The handle to the raw input device.
; Type - The type of device: 0 = TYPEMOUSE, 1 = TYPEKEYBOARD, 2 = TYPEHID
; Page - The top-level collection Usage Page for the device (always 1 for type 0 and 1).
; Usage - The top-level collection Usage for the device (always 2 for type 0 and 6 for type 1).
; Name - The name of the device.
; ================================================================================================================================
RI_GetDeviceList() {
Static RIM := {0: "M", 1: "K", 2: "H"} ; RIM_TYPE...
StructSize := A_PtrSize * 2 ; size of a RAWINPUTDEVICELIST structure
DevCount := 0
DllCall("GetRawInputDeviceList", "Ptr", 0, "UIntP", DevCount, "UInt", StructSize)
If (DevCount) {
VarSetCapacity(ListArr, StructSize * DevCount, 0) ; array of RAWINPUTDEVICELIST structures
If (DllCall("GetRawInputDeviceList", "Ptr", &ListArr, "UIntP", DevCount, "UInt", StructSize, "Int") = DevCount) {
DevObj := {Cnt: {H: 0, K: 0, M: 0, T: DevCount}, Lst: {}} ; Cnt = counters, Lst = device list
Addr := &ListArr
Loop, %DevCount% {
DevType := NumGet(Addr + A_PtrSize, "UInt")
DevHandle := Format("0x{:X}", NumGet(Addr + 0, "UPtr"))
DevObj.Cnt[RIM[DevType]]++
DevObj.Lst.Push({Handle: DevHandle, Type: DevType})
Addr += StructSize
}
Return DevObj
}
}
Return False
}
;Code by https://github.com/AHK-just-me/RawInput/blob/master/Sources/RI.ahk
; ================================================================================================================================
; GetRawInputDeviceInfo() -> msdn.microsoft.com/en-us/library/windows/desktop/ms645597(v=vs.85).aspx
; On success, the dunction returns the name of the device.
; ================================================================================================================================
RI_GetDeviceName(DevHandle) {
; RIDI_DEVICENAME = 0x20000007
DevName := ""
Length := 0
DllCall("GetRawInputDeviceInfo", "Ptr", DevHandle, "UInt", 0x20000007, "Ptr", 0, "UIntP", Length)
If (Length) {
VarSetCapacity(DevName, Length << !!A_IsUnicode, 0)
DllCall("GetRawInputDeviceInfo", "Ptr", DevHandle, "UInt", 0x20000007, "Str", DevName, "UIntP", Length)
}
Return DevName
}
;Code by https://github.com/AHK-just-me/RawInput/blob/master/Sources/RI.ahk
; ================================================================================================================================
; GetRegisteredRawInputDevices() -> msdn.microsoft.com/en-us/library/windows/desktop/ms645599(v=vs.85).aspx
; On success, the function returns a simple array of objects containing the following key-value pairs:
; Page - The top-level collection Usage Page for the device (always 1 for type 0 and 1).
; Usage - The top-level collection Usage for the device (always 2 for type 0 and 6 for type 1).
; Flags - The mode flag that specifies how to interpret the information provided by Page and Usage.
; HWND - The handle to the target window. If NULL it follows the keyboard focus.
; ================================================================================================================================
RI_GetRegisteredDevices() {
StructSize := 8 + A_PtrSize ; size of a RAWINPUTDEVICE structure
DevCount := 0
DllCall("GetRegisteredRawInputDevices", "Ptr", 0, "UIntP", DevCount, "UInt", StructSize)
If (DevCount) {
VarSetCapacity(DevArr, StructSize * DevCount, 0) ; array of RAWINPUTDEVICE structures
If (DllCall("GetRegisteredRawInputDevices", "Ptr", &DevArr, "UIntP", DevCount, "UInt", StructSize, "Int") = DevCount) {
Registered := []
Addr := &DevArr
Loop, %DevCount% {
Page := NumGet(Addr + 0, "UShort")
Usage := NumGet(Addr + 2, "UShort")
Flags := Format("0x{:04X}", NumGet(Addr + 4, "UInt"))
HWND := NumGet(Addr + 8, "UPtr")
Registered.Push({Flags: Flags, HWND: (HWND = 0 ? HWND : Format("0x{:X}", HWND)), Page: Page, Usage: Usage})
Addr += StructSize
}
Return Registered
}
}
Return False
}
;Code by https://github.com/AHK-just-me/RawInput/blob/master/Sources/RI.ahk
; ================================================================================================================================
; GetRawInputDeviceInfo() -> msdn.microsoft.com/en-us/library/windows/desktop/ms645597(v=vs.85).aspx
; On success, the function returns an object containing the following key-value pairs:
; All devices:
; DevType - The type of device: 0 = TYPEMOUSE, 1 = TYPEKEYBOARD, 2 = TYPEHID
; Page - The top-level collection Usage Page for the device (always 1 for type 0 and 1).
; Usage - The top-level collection Usage for the device (always 2 for type 0 and 6 for type 1).
; Mouse devices (DevType = 0):
; ID - The identifier of the mouse device.
; Buttons - The number of buttons for the mouse.
; Rate - The number of data points per second. This information may not be applicable for every mouse device.
; HWheel - True if the mouse has a wheel for horizontal scrolling; otherwise, False (Win Vista+).
; Keyboard devices (DevType = 1):
; Type - The type of the keyboard.
; SubType - The subtype of the keyboard.
; ScanMode - The scan code mode.
; FnKeys - The number of function keys on the keyboard.
; Indicators - The number of LED indicators on the keyboard.
; TotalKeys - The total number of keys on the keyboard.
; HID devices (DevType = 2:
; VendorID - The vendor identifier for the HID.
; ProductID - The product identifier for the HID.
; Version - The version number for the HID.
; ================================================================================================================================
RI_GetDeviceInfo(DevHandle) {
; RIDI_DEVICEINFO = 0x2000000B
Static OSV := DllCall("GetVersion", "UChar")
DevInfo := ""
Length := 0
DllCall("GetRawInputDeviceInfo", "Ptr", DevHandle, "UInt", 0x2000000B, "Ptr", 0, "UIntP", Length)
If (Length) {
VarSetCapacity(DevInfoBuffer, Length, 0)
If (DllCall("GetRawInputDeviceInfo", "Ptr", DevHandle, "UInt", 0x2000000B, "Ptr", &DevInfoBuffer, "UIntP", Length) > 0) {
DevType := NumGet(DevInfoBuffer, 4, "UInt")
If (DevType = 0) { ; RIM_TYPEMOUSE - for the mouse, the Usage Page is 1 and the Usage is 2.
DevInfo := {DevType: DevType}
DevInfo.ID := NumGet(DevInfoBuffer, 8, "UInt")
DevInfo.Buttons := NumGet(DevInfoBuffer, 12, "UInt")
DevInfo.Rate := NumGet(DevInfoBuffer, 16, "UInt")
DevInfo.HWheel := OSV > 5 ? NumGet(DevInfoBuffer, 20, "UInt") : 0
DevInfo.Page := 1
DevInfo.Usage := 2
}
Else If (DevType = 1) { ; RIM_TYPEKEYBOARD - for the keyboard, the Usage Page is 1 and the Usage is 6. ;
DevInfo := {DevType: DevType}
DevInfo.Type := NumGet(DevInfoBuffer, 8, "UInt")
DevInfo.SubType := NumGet(DevInfoBuffer, 12, "UInt")
DevInfo.ScanMode := NumGet(DevInfoBuffer, 16, "UInt")
DevInfo.FnKeys := NumGet(DevInfoBuffer, 20, "UInt")
DevInfo.Indicators := NumGet(DevInfoBuffer, 24, "UInt")
DevInfo.TotalKeys := NumGet(DevInfoBuffer, 28, "UInt")
DevInfo.Page := 1
DevInfo.Usage := 6
}
Else If (DevType = 2) { ; RIM_TYPEHID
DevInfo := {DevType: DevType}
DevInfo.VendorID := NumGet(DevInfoBuffer, 8, "UInt")
DevInfo.ProductID := NumGet(DevInfoBuffer, 12, "UInt")
DevInfo.Version := NumGet(DevInfoBuffer, 16, "UInt")
DevInfo.Page := NumGet(DevInfoBuffer, 20, "UShort")
DevInfo.Usage := NumGet(DevInfoBuffer, 22, "UShort")
}
}
}
Return DevInfo
}
GetMax(arr){
for k,v in arr
{
if (v>max)
{
keymax:=k
max:=v
}
}
return keymax
}
;Code by Lexikos:
;autohotkey.com/board/topic/70490-print-array/?p=492728
ExploreObj(Obj, NewRow="`n", Equal=" = ", Indent="`t", Depth=12, CurIndent="") {
for k,v in Obj
ToReturn .= CurIndent . k . (IsObject(v) && depth>1 ? NewRow . ExploreObj(v, NewRow, Equal, Indent, Depth-1, CurIndent . Indent) : Equal . v) . NewRow
return RTrim(ToReturn, NewRow)
}
Join(sep, params) {
for index,param in params
str .= sep . param
return SubStr(str, StrLen(sep)+1)
}
