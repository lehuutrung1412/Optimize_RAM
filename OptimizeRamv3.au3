#NoTrayIcon
#Region
   #AutoIt3Wrapper_Icon=..\Pictures\ram_mQl_icon.ico
   #AutoIt3Wrapper_Res_Comment=Optimize RAM for Windows with just one click
   #AutoIt3Wrapper_Res_Description=Optimize RAM for Windows with just one click
   #AutoIt3Wrapper_Res_Fileversion=3.0
   #AutoIt3Wrapper_Res_LegalCopyright=Copyright (C) 2018 Jan
   #AutoIt3Wrapper_Res_Language=1066
#EndRegion

#Region include
   #include <Array.au3>
   #include <TrayConstants.au3>
   #include <MsgBoxConstants.au3>
   #include <StringConstants.au3>
   #include <MemoryConstants.au3>
   #include <GUIConstantsEx.au3>
   #include <ComboConstants.au3>
   #include "_Startup.au3"
   #include "CoProc.au3"
#EndRegion

systray()
#Region System Tray
   Func systray()
	  Opt("TrayMenuMode", 3)
	  Opt("TrayOnEventMode", 1)
	  TraySetClick(16)
	  TrayCreateItem("Cài đặt")
	  TrayItemSetOnEvent(-1, "settings")
	  TrayCreateItem("")
	  Global $startup = TrayCreateItem("Khởi động cùng Windows")
	  TrayItemSetOnEvent(-1, "startup")
	  TrayCreateItem("")
	  TrayCreateItem("Thông tin")
	  TrayItemSetOnEvent(-1, "about")
	  TrayCreateItem("")
	  TrayCreateItem("Hướng dẫn sử dụng")
	  TrayItemSetOnEvent(-1, "howto")
	  TrayCreateItem("")
	  TrayCreateItem("Kết thúc")
	  TrayItemSetOnEvent(-1, "esc")
	  TraySetState($TRAY_ICONSTATE_SHOW)
	  TraySetOnEvent($TRAY_EVENT_MOUSEOVER, "showram")
	  TraySetOnEvent($TRAY_EVENT_PRIMARYDOWN, "otm")
	  TrayTip("Optimize RAM", "Chào bạn! Chúc bạn sử dụng máy tính hiệu quả!", 10, 1)
	  #Region config
		 Global Const $filepath = "C:\OptimizeRAM\config.ini"
		 If NOT FileExists("C:\OptimizeRAM") Then
			   DirCreate("C:\OptimizeRAM")
			   FileSetAttrib("C:\OptimizeRAM", "+H")
		 EndIf
		 If FileExists($filepath) Then
			   If IniRead($filepath, "OR", "Startup", "0") = 1 Then
				  TrayItemSetState($startup, $TRAY_CHECKED)
			   Else
				  TrayItemSetState($startup, $TRAY_UNCHECKED)
			   EndIf
			   If IniRead($filepath, "OR", "Timer", "0") <> 0 Then _coproc("timer", IniRead($filepath, "OR", "Timer", "0"))
		 EndIf
	  #EndRegion
	  While 1
		 Sleep(100)
	  WEnd
   EndFunc

#EndRegion System Tray

Func startup()
   Local $check_startup = TrayItemGetState($startup)
   If $check_startup = 68 Then
	  _startupfolder_install()
	  TrayItemSetState($startup, $TRAY_CHECKED)
	  IniWrite($filepath, "OR", "Startup", "1")
	  TrayTip("Optimize RAM", "Chương trình sẽ được khởi động cùng Windows!", 10, 1)
   Else
	  _startupfolder_uninstall()
	  TrayItemSetState($startup, $TRAY_UNCHECKED)
	  IniWrite($filepath, "OR", "Startup", "0")
	  TrayTip("Optimize RAM", "Chương trình sẽ không được khởi động cùng Windows!", 10, 1)
   EndIf
EndFunc

Func howto()
   TrayTip("Optimize RAM", "Cảm ơn bạn đã sử dụng!", 10, 1)
   MsgBox(64, "Hướng dẫn", "Bạn chỉ cần nhấn chuột vào icon dưới thanh taskbar, chương trình sẽ tự động tối ưu RAM cho máy tính của bạn. Phần trăm chiếm RAM sẽ được hiển thị khi bạn rê chuột vào icon.")
   Local $down_ram = MsgBox(36, "Download RAM", "Ngoài ra, bạn có thể tối ưu RAM bằng cách tải thêm RAM về máy của bạn. Bạn có muốn tải ngay?", 5)
   If $down_ram = 6 Then
	  ShellExecute("https://downloadmoreram.com")
   EndIf
EndFunc

Func settings()
   #Region ### START Koda GUI section ### Form=
	  Local $timer = GUICreate("Optimize RAM for Windows with just one click", 450, 210, -1, -1)
	  GUISetFont(12, 400, 0, "Segoe UI")
	  GUICtrlCreateGroup("  Timer  ", 8, 8, 433, 193)
	  GUICtrlCreateLabel("Tự động tối ưu RAM sau : ", 24, 48, 176, 25)
	  Local $combo1 = GUICtrlCreateCombo("Never", 208, 48, 145, 25, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL))
	  GUICtrlCreateGroup("", -99, -99, 1, 1)
	  Local $ok = GUICtrlCreateButton("OK", 208, 120, 145, 30)
	  GUISetState(@SW_SHOW)
   #EndRegion ### END Koda GUI section ###
   Local $check_timer = IniRead($filepath, "OR", "Timer", "0")
   If $check_timer <> 0 Then
	  GUICtrlSetData($combo1, "15 phút|30 phút|60 phút|90 phút", $check_timer & " phút")
   Else
	  GUICtrlSetData($combo1, "15 phút|30 phút|60 phút|90 phút", "Never")
   EndIf
   While 1
	  $nmsg = GUIGetMsg()
	  Switch $nmsg
		 Case $gui_event_close
			GUIDelete($timer)
			ExitLoop
		 Case $ok
			If GUICtrlRead($combo1) = "Never" Then
			   If IsDeclared("iPid") Then
				  If ProcessExists($ipid) Then
					 ProcessClose($ipid)
				  EndIf
			   EndIf
			   IniWrite($filepath, "OR", "Timer", "0")
			   GUIDelete($timer)
			   ExitLoop
			ElseIf GUICtrlRead($combo1) = "15 phút" Then
			   If IsDeclared("iPid") Then
				  If ProcessExists($ipid) Then
					 ProcessClose($ipid)
				  EndIf
			   EndIf
			   IniWrite($filepath, "OR", "Timer", "15")
			   GUIDelete($timer)
			   _coproc("timer", 15)
			   ExitLoop
			ElseIf GUICtrlRead($combo1) = "30 phút" Then
			   If IsDeclared("iPid") Then
				  If ProcessExists($ipid) Then
					 ProcessClose($ipid)
				  EndIf
			   EndIf
			   IniWrite($filepath, "OR", "Timer", "30")
			   GUIDelete($timer)
			   _coproc("timer", 30)
			   ExitLoop
			ElseIf GUICtrlRead($combo1) = "60 phút" Then
			   If IsDeclared("iPid") Then
				  If ProcessExists($ipid) Then
					 ProcessClose($ipid)
				  EndIf
			   EndIf
			   IniWrite($filepath, "OR", "Timer", "60")
			   GUIDelete($timer)
			   _coproc("timer", 60)
			   ExitLoop
			ElseIf GUICtrlRead($combo1) = "90 phút" Then
			   If IsDeclared("iPid") Then
				  If ProcessExists($ipid) Then
					 ProcessClose($ipid)
				  EndIf
			   EndIf
			   IniWrite($filepath, "OR", "Timer", "90")
			   GUIDelete($timer)
			   _coproc("timer", 90)
			   ExitLoop
			EndIf
	  EndSwitch
   WEnd
EndFunc

Func showram()
   TraySetToolTip("Optimize RAM - " & MemGetStats()[$MEM_LOAD] & "%")
EndFunc

Func about()
   MsgBox(64, "Thông tin", "Phần mềm : Optimize RAM for Windows with just one click." & @CRLF & "Tác giả: Jan ( Hữu Trung )" & @CRLF & "Phiên bản: ver 3.0 (Stable)" & @CRLF & "Cảm ơn Duy Nguyễn (wy3) đã hỗ trợ thuật toán tối ưu RAM.")
   Local $quest_about = MsgBox(36, "Tìm hiểu thêm", "Bạn có muốn tìm hiểu thêm về tác giả?", 3)
   If $quest_about = 6 Then
	  ShellExecute("https://huutrungit.blogspot.com")
   EndIf
EndFunc

Func esc()
   If IsDeclared("iPid") Then
	  If ProcessExists($ipid) Then
		 ProcessClose($ipid)
	  EndIf
   EndIf
   Exit
EndFunc

Func otm()
   For $i = 1 To 32768
	  Local $handle = DllCall("kernel32.dll", "handle", "OpenProcess", "dword", 2035711, "bool", 0, "dword", $i)
	  If NOT @error Then
		 $handle = $handle[0]
		 DllCall("kernel32.dll", "bool", "SetProcessWorkingSetSizeEx", "handle", $handle, "int", -1, "int", -1, "dword", 1)
		 DllCall("psapi.dll", "bool", "EmptyWorkingSet", "handle", $handle)
		 DllCall("kernel32.dll", "bool", "CloseHandle", "handle", $handle)
	  EndIf
   Next
EndFunc

Func timer($minutes)
   #NoTrayIcon
   For $i = $minutes * 60 To 0 Step -1
	  Sleep(1000)
	  If $i = 0 Then
		 MsgBox(64 + 262144, "Optimize RAM", "Đã đến giờ! Phần mềm sẽ tự động tối ưu RAM!", 3)
		 otm()
		 timer($minutes)
	  EndIf
   Next
EndFunc