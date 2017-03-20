#SingleInstance Force
#Persistent
#Include lib/JSON.ahk
#Include lib/Gdip_All.ahk

poststring=http://poe.ninja/api/Data/GetCurrencyOverview?league=Legacy
URLDownloadToFile,%poststring%, response.htm
fileread, response_string, response.htm

global parsed := JSON.Load(response_string)

global currencyArray := {}

for index, element in parsed.lines ; Recommended approach in most cases.
{
    ; Using "Loop", indices must be consecutive numbers from 1 to the number
    ; of elements in the array (or they must be calculated within the loop).
    ; MsgBox % "Element number " . A_Index . " is " . Array[A_Index]

    ; Using "for", both the index (or "key") and its associated value
    ; are provided, and the index can be *any* value of your choosing.
	test := RegExReplace(element.currencyTypeName,"[^\w]","_")
	currencyArray[test] := element.chaosEquivalent
}

; Start gdi+
If !pToken := Gdip_Startup()
{
MsgBox, 48, gdiplus error!, Gdiplus failed to start. Please ensure you have gdiplus on your system
ExitApp
}
OnExit, Exit

global Width := A_ScreenWidth
global Height := A_ScreenHeight

Gui, 1: -Caption +E0x80000 +LastFound +OwnDialogs +Owner +AlwaysOnTop
Gui, 1: Show, NA

global hwnd1 := WinExist()
global hbm := CreateDIBSection(Width, Height)
global hdc := CreateCompatibleDC()
global obm := SelectObject(hdc, hbm)
global G := Gdip_GraphicsFromHDC(hdc)
Gdip_SetSmoothingMode(G, 4)

pBrush := Gdip_BrushCreateSolid(0xaa000000)
Gdip_DeleteBrush(pBrush)

global Font = "Arial"
If !hFamily := Gdip_FontFamilyCreate(Font)
{
MsgBox, 48, Font error!, The font you have specified does not exist on the system
ExitApp
}
Gdip_DeleteFontFamily(hFamily)

^!s::GetClipboardValue()
^!c::ProcessCurrencyTab()
^!n::ProcessNormalTab()
^!q::ProcessQuadTab()
^!a::ClearScreen()
^!y::GetMousePos()
^!v::ProcessSlotSingle()

ClearScreen() {
	Gdip_GraphicsClear(G)
	UpdateLayeredWindow(hwnd1, hdc, (A_ScreenWidth-Width)//2, (A_ScreenHeight-Height)//2, Width, Height)
}

GetMousePos() {
	string := "test"
	Options = x10p y30p cbbffffff
	Gdip_TextToGraphics(G, string, Options, Font, Width, Height)

	UpdateLayeredWindow(hwnd1, hdc, (A_ScreenWidth-Width)//2, (A_ScreenHeight-Height)//2, Width, Height)
}

CreateTextForValue(xv,yv,value) {
	;yv += 35
	;xv -= 35
	if value = 0.0
		value := 0
	SetFormat, float, 3.1
	Options = x%xv% y%yv% s15 r4 cbb999900

	Gdip_TextToGraphics(G, value, Options, Font, Width, Height)

	UpdateLayeredWindow(hwnd1, hdc, (A_ScreenWidth-Width)//2, (A_ScreenHeight-Height)//2, Width, Height)
}

DrawTotal(xv,yv,value) {
	yv += 35
	SetFormat, float, 0.1
	value = Total: %value%
	Options = x%xv% y%yv% cbbFF9900

	Gdip_TextToGraphics(G, value, Options, Font, Width, Height)

	UpdateLayeredWindow(hwnd1, hdc, (A_ScreenWidth-Width)//2, (A_ScreenHeight-Height)//2, Width, Height)
}

ProcessSlot(x,y, chaobs) {
	MouseMove, x, y, 0
	value := GetClipboardValue()
	CreateTextForValue(x, y, value)
	global chaos
	chaos += value
}

ProcessSlotSingle() {
	MouseGetPos, x, y
	value := GetClipboardValue()
	CreateTextForValue(x, y, value)
}

ProcessNormalTab() {
	Gdip_GraphicsClear(G)
	global chaos := 0

	offsetX = 42
	offsetY = 188

	spacing = 52

	Data := Object()

	Loop 12
	{
	   y := A_Index
	   Loop 12
			ProcessSlot(offsetX + (A_Index-1)*spacing, offsetY + (y-1)*spacing, chaos)
	}

	DrawTotal(540, 730, chaos)
	StatsFile = %A_ScriptDir%\StatsFile.txt

	FormatTime, TimeString, Time, dddd MMMM d, yyyy hh:mm:ss tt

	FileAppend,  ; The comma is required in this case.
	(
		%TimeString% - Total Normal Chaos: %chaos% `n
	), %StatsFile%

}

ProcessQuadTab() {
	Gdip_GraphicsClear(G)
	global chaos := 0

	offsetX = 29
	offsetY = 175

	spacing = 26

	Data := Object()

	Loop 24
	{
	   y := A_Index
	   Loop 24
			ProcessSlot(offsetX + (A_Index-1)*spacing, offsetY + (y-1)*spacing, chaos)
	}

	DrawTotal(540, 730, chaos)
	StatsFile = %A_ScriptDir%\StatsFile.txt

	FormatTime, TimeString, Time, dddd MMMM d, yyyy hh:mm:ss tt

	FileAppend,  ; The comma is required in this case.
	(
		%TimeString% - Total Quad Chaos: %chaos% `n
	), %StatsFile%

}

ProcessCurrencyTab() {
	Gdip_GraphicsClear(G)
	global chaos := 0
	ProcessSlot(70, 255, chaos)
	ProcessSlot(140, 255, chaos)
	ProcessSlot(210, 255, chaos)
	ProcessSlot(315, 255, chaos)
	ProcessSlot(380, 255, chaos)
	ProcessSlot(450, 255, chaos)
	ProcessSlot(520, 255, chaos)
	ProcessSlot(590, 255, chaos)

	ProcessSlot(70, 375, chaos)
	ProcessSlot(140, 375, chaos)
	ProcessSlot(210, 375, chaos)
	ProcessSlot(450, 375, chaos)
	ProcessSlot(520, 375, chaos)
	ProcessSlot(590, 375, chaos)

	ProcessSlot(70, 450, chaos)
	ProcessSlot(140, 450, chaos)
	ProcessSlot(210, 450, chaos)
	ProcessSlot(450, 450, chaos)
	ProcessSlot(520, 450, chaos)
	ProcessSlot(590, 450, chaos)

	ProcessSlot(295, 415, chaos)
	ProcessSlot(365, 415, chaos)

	ProcessSlot(70, 550, chaos)
	ProcessSlot(140, 550, chaos)
	ProcessSlot(210, 550, chaos)
	ProcessSlot(450, 550, chaos)
	ProcessSlot(520, 550, chaos)
	ProcessSlot(590, 550, chaos)

	ProcessSlot(210, 630, chaos)
	ProcessSlot(450, 630, chaos)
	ProcessSlot(520, 630, chaos)
	ProcessSlot(590, 630, chaos)

	ProcessSlot(195, 730, chaos)
	ProcessSlot(265, 730, chaos)
	ProcessSlot(335, 730, chaos)
	ProcessSlot(405, 730, chaos)
	ProcessSlot(475, 730, chaos)

	DrawTotal(540, 730, chaos)
	StatsFile = %A_ScriptDir%\StatsFile.txt

	FormatTime, TimeString, Time, dddd MMMM d, yyyy hh:mm:ss tt

	FileAppend,  ; The comma is required in this case.
	(
		%TimeString% - Total Chaos: %chaos% `n
	), %StatsFile%

}

GetClipboardValue() {
	totalChaos := 0.0
	clipboard := ""
	Send {Ctrl down}c{Ctrl up}
	clipboardText := clipboard ; not necessary but for clarity since I further process the variable
	clipboardArray := {}
	index := 0
	chaosValue := 0
	Loop, Parse, clipboard, `n, `r
	{
	   ;msgbox %A_LoopField%
	   if(index == 1) {
			name := RegExReplace(A_LoopField,"[^\w]","_")
			if(name == "Chaos_Orb") {
				chaosValue := 1.0
			}else if(!name){
				chaosValue := 0.0
			}else {
				chaosValue := currencyArray[name]
			}
		}
		if(index == 3) {
			stacksize := StringBetweenRE(A_LoopField,"Size: ", "/")
			stacksize := RegExReplace(stacksize,"\.","")

			totalChaos += chaosValue * stacksize
		}
	   index++
	}
	return totalChaos
}

; Regular expression
StringBetweenRE(_string, _before, _after)
{
	fp := RegExMatch(_string, "\Q" . _before . "\E(.*?)\Q" . _after . "\E", sb)
	Return sb1
}

^Esc::ExitApp

Exit:
Gdip_Shutdown(pToken)
ExitApp
return
