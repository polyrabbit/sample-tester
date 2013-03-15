#NoEnv
#SingleInstance off
Gui, +resize +minsize
Gui, font, s10, Verdana
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Gui, add, checkbox, section vcbox glblcbox h26, RunSpecified ;cbox
Gui, add, edit, veFilePath w410 r1 ys disabled h26, % getfilepath() ;eFilePath
Gui, add, button, ys vbbrowse disabled , ä¯ÀÀ(&B)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Gui, add, text, section w235 vtin xm,Test In: ;tin
Gui, add, button,ys section vbpaste h26,paste ;bpaste
Gui, add, text,ys section w235 vtout,RunTest Result: ;tout
Gui, add, button,ys vbcopy h26,copy ;bcopy
Gui, Add, Edit, veinput section VScroll HScroll w300 r20 xm WantTab ;einput
Gui, Add, Edit, veoutput VScroll HScroll w300 r20 ys WantTab ;eoutput
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Gui, add, text,xm section vttl h26,TimeLimit(sec): ;ttl
Gui, add, edit, Number vetl ys w150, 3 ;etl
Gui, add, updown, range1-1000 vud, 3 ;ud
Gui, add, text, vtrinfo x+60 ys-6 w200 ;trinfo
Gui, add, text, vExitCode w200 y+0 ;ExitCode
Gui, add, button, ys default w70 vbrun, &run ;brun
Menu, Tray, NoStandard
Menu, tray, add, Run, buttonrun
Menu, tray, default, Run
Menu, Tray, add, About, about
Menu, Tray, add, Exit, Guiclose
pNewThread := RegisterCallback("NewThread")
/*
*/
Gui, show
;WinSet, Transparent, 150
return

buttonä¯ÀÀ(B):
Gui, +OwnDialogs
FileSelectFile, SelectedFile, 3, , ,*.exe
if(SelectedFile)
{
	GuiControl,, eFilePath, %SelectedFile%
}
return

lblcbox:
Gui, submit, nohide
Guicontrol, enable%cbox%, eFilePath
Guicontrol, enable%cbox%, bbrowse
if(!cbox)
{
	GuiControl,, eFilePath, % getfilepath()
}
return

buttonpaste:
GuiControl,, einput, %clipboard%
;controlsettext, edit1, %clipboard%
return

buttoncopy:
Guicontrolget, clipboard,,eoutput
return

~^r::
buttonrun:
Gui, +lastfound
WinActivate
;~ Thread, Interrupt
Gui, submit, nohide
Guicontrolget, filename,,eFilePath
GuiControl,, eoutput,
IfNotExist, % filename
	return
period := etl*1000
StartTime := A_TickCount
;~ SetTimer, processClose, -%period%
;~ done := false
;~ hThread := DllCall("CreateThread", UInt, 0, UInt, 0, UInt, pNewThread, UInt,0, UInt,0, UInt, 0)
fout := redirectedIO(filename, einput, ExitCode)
;~ DllCall("WaitForSingleObject", Uint, hThread, Uint, 0xFFFFFFFF)
;~ DllCall("CloseHandle", Uint, hThread)
if(errorlevel)
{
	process, close, %OutputVarPID%
	;fileappend, Error: Time Limit Exceeded`n, Temp.output
	fout := "Error: Time Limit Exceeded`n"
	done := false
}

ElapsedTime := (A_TickCount - StartTime)/1000
GuiControl,, eoutput, %fout%
GuiControl,, trinfo, Execution Time: %ElapsedTime% s
GuiControl,, ExitCode, ExitCode:         %ExitCode%
return

getfilepath()
{
	lasttime =
	loop, *.exe
	{
		if(A_LoopFileTimeModified>lasttime && A_ScriptName!=A_LoopFileName)
		{
			lasttime := A_LoopFileTimeModified
			name := A_LoopFileLongPath
		}
	}
	return name
}

about:
Gui, +OwnDialogs
msgbox, 64,, Questions, comments and suggestions are always welcome to`nmcx_221@foxmail.com
return

GuiSize:
Anchor("tout", "x0.5", 1)
Anchor("bpaste", "x0.5", 1)
Anchor("bcopy", "x", 1)
Anchor("einput", "w0.5h", 1)
Anchor("eoutput", "x0.5w0.5h", 1)
Anchor("ttl", "y", 1)
Anchor("etl", "yw0.5", 1)
Anchor("ud", "x0.5y", 1)
Anchor("brun", "xy", 1)
Anchor("trinfo", "x0.5y", 1)
Anchor("ExitCode", "x0.5y", 1)
return

GuiDropFiles:
if(cbox)
	GuiControl,, eFilePath, % A_GuiEvent
return

GuiEscape:
Gui, Minimize
return
 
Guiclose:
DllCall("GlobalFree", UInt, pNewThread)
exitapp
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/*
	Function: Anchor
		Defines how controls should be automatically positioned relative to the new dimensions of a window when resized.

	Parameters:
		cl - a control HWND, associated variable name or ClassNN to operate on
		a - (optional) one or more of the anchors: 'x', 'y', 'w' (width) and 'h' (height),
			optionally followed by a relative factor, e.g. "x h0.5"
		r - (optional) true to redraw controls, recommended for GroupBox and Button types

	Examples:
> "xy" ; bounds a control to the bottom-left edge of the window
> "w0.5" ; any change in the width of the window will resize the width of the control on a 2:1 ratio
> "h" ; similar to above but directrly proportional to height

	Remarks:
		To assume the current window size for the new bounds of a control (i.e. resetting) simply omit the second and third parameters.
		However if the control had been created with DllCall() and has its own parent window,
			the container AutoHotkey created Gui must be made default with the +LastFound option prior to the call.
		For a complete example see anchor-example.ahk.

	License:
		- Version 4.60a <http://www.autohotkey.net/~polyethene/#anchor>
		- Dedicated to the public domain <http://creativecommons.org/licenses/publicdomain/>
*/
Anchor(i, a = "", r = false) {
	static c, cs = 12, cx = 255, cl = 0, g, gs = 8, gl = 0, gpi, gw, gh, z = 0, k = 0xffff
	If z = 0
		VarSetCapacity(g, gs * 99, 0), VarSetCapacity(c, cs * cx, 0), z := true
	If (!WinExist("ahk_id" . i)) {
		GuiControlGet, t, Hwnd, %i%
		If ErrorLevel = 0
			i := t
		Else ControlGet, i, Hwnd, , %i%
	}
	VarSetCapacity(gi, 68, 0), DllCall("GetWindowInfo", "UInt", gp := DllCall("GetParent", "UInt", i), "UInt", &gi)
		, giw := NumGet(gi, 28, "Int") - NumGet(gi, 20, "Int"), gih := NumGet(gi, 32, "Int") - NumGet(gi, 24, "Int")
	If (gp != gpi) {
		gpi := gp
		Loop, %gl%
			If (NumGet(g, cb := gs * (A_Index - 1)) == gp) {
				gw := NumGet(g, cb + 4, "Short"), gh := NumGet(g, cb + 6, "Short"), gf := 1
				Break
			}
		If (!gf)
			NumPut(gp, g, gl), NumPut(gw := giw, g, gl + 4, "Short"), NumPut(gh := gih, g, gl + 6, "Short"), gl += gs
	}
	ControlGetPos, dx, dy, dw, dh, , ahk_id %i%
	Loop, %cl%
		If (NumGet(c, cb := cs * (A_Index - 1)) == i) {
			If a =
			{
				cf = 1
				Break
			}
			giw -= gw, gih -= gh, as := 1, dx := NumGet(c, cb + 4, "Short"), dy := NumGet(c, cb + 6, "Short")
				, cw := dw, dw := NumGet(c, cb + 8, "Short"), ch := dh, dh := NumGet(c, cb + 10, "Short")
			Loop, Parse, a, xywh
				If A_Index > 1
					av := SubStr(a, as, 1), as += 1 + StrLen(A_LoopField)
						, d%av% += (InStr("yh", av) ? gih : giw) * (A_LoopField + 0 ? A_LoopField : 1)
			DllCall("SetWindowPos", "UInt", i, "Int", 0, "Int", dx, "Int", dy
				, "Int", InStr(a, "w") ? dw : cw, "Int", InStr(a, "h") ? dh : ch, "Int", 4)
			If r != 0
				DllCall("RedrawWindow", "UInt", i, "UInt", 0, "UInt", 0, "UInt", 0x0101) ; RDW_UPDATENOW | RDW_INVALIDATE
			Return
		}
	If cf != 1
		cb := cl, cl += cs
	bx := NumGet(gi, 48), by := NumGet(gi, 16, "Int") - NumGet(gi, 8, "Int") - gih - NumGet(gi, 52)
	If cf = 1
		dw -= giw - gw, dh -= gih - gh
	NumPut(i, c, cb), NumPut(dx - bx, c, cb + 4, "Short"), NumPut(dy - by, c, cb + 6, "Short")
		, NumPut(dw, c, cb + 8, "Short"), NumPut(dh, c, cb + 10, "Short")
	Return, true
}
;//////////////////////////////////////////////////////////////////////////////////////////////
redirectedIO(sApplicationName, sInput = "", ByRef ExitCode=0)
{
;~ msgbox, % sApplicationName
	DllCall("CreatePipe", UintP, hStdInRd , UintP, hStdInWr , Uint, 0, Uint, 0)
	DllCall("CreatePipe", UintP, hStdOutRd , UintP, hStdOutWr , Uint, 0, Uint, 0)
	DllCall("SetHandleInformation", "Uint", hStdInRd , "Uint", 1, "Uint", 1)
	DllCall("SetHandleInformation", "Uint", hStdOutWr, "Uint", 1, "Uint", 1)
	NumPut(VarSetCapacity(startupInfo, 68, 0), startupInfo)
	NumPut(0x100	, startupInfo, 44)		; STARTF_USESTDHANDLES
	NumPut(hStdInRd	, startupInfo, 56)		; hStdInput
	NumPut(hStdOutWr, startupInfo, 60)		; hStdOutput
	NumPut(hStdOutWr, startupInfo, 64)		; hStdError
	global processInfo
	VarSetCapacity(processInfo, 16, 0)
	if not DllCall("CreateProcess", Str, sApplicationName, Uint, 0, Uint, 0, Uint, 0, int, True, Uint, 0x08000000, Uint, 0, Uint, 0, Uint, &startupInfo, Uint, &processInfo)	; bInheritHandles and CREATE_NO_WINDOW
	{
		MsgBox, 0x10, Error,´íÎó´úÂë %A_LastError%
		return
	}
	DllCall("CloseHandle", Uint, hStdOutWr)
	DllCall("CloseHandle", Uint, hStdInRd)
	If(sInput)
		;~ DllCall("WriteFile", Uint, hStdInWr, Str, sInput, Uint, StrLen(sInput) * (A_isUnicode ? 2:1), UintP, nSize, Uint, 0)
		FileOpen(hStdInWr, "h", "CP0").Write(sInput)
	DllCall("CloseHandle", Uint, hStdInWr)
	VarSetCapacity(sTemp, 4096, 0)
	nTemp:=4090
	while DllCall("ReadFile", Uint, hStdOutRd, Str, sTemp, Uint, nTemp, UintP, nSize:=0, Uint, 0)&&nSize
	{
		sRet .= A_isUnicode ? StrGet(&sTemp, nSize, "cp0") : sTemp
	}
	;~ msgbox, % sApplicationName
	DllCall("GetExitCodeProcess", Uint, NumGet(processInfo,0), UintP, ExitCode)
	DllCall("CloseHandle", Uint, hStdOutRd)
	DllCall("CloseHandle", Uint, NumGet(processInfo,0))
	DllCall("CloseHandle", Uint, NumGet(processInfo,4))
	;~ SetTimer, processClose, off
	;~ msgbox, % sRet
	return sRet
}
;///////////////////////////////////////////////////////////////////////////////////////////////
processClose:
	Dllcall("TerminateThread", Uint, pThread, int 4)
	return
	pid := NumGet(processInfo, 8)
	SendMessage, 0x10,,,, ahk_id %pid%
	return
	;~ Dllcall("TerminateProcess", Uint, NumGet(processInfo,0), int, 4)
	handle := Dllcall("OpenProcess", Uint, 1, int, false, Uint, NumGet(processInfo, 8))
 	Dllcall("TerminateProcess", Uint, NumGet(processInfo,0), int, 4)
	clipboard := dllcall("GetLastError")
	return 