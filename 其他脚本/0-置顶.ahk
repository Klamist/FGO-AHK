#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

/*
自动置顶mumu窗口，用于长时间挂机防止杂碎软件弹窗干扰。
热键与刷本AHK相同，刷图时启用即可。
*/

; Ctrl + \ 退出脚本
$~^\::ExitApp

; \ 键重置
$~\::Reload

; ] 键暂停
$~]::Pause

; [ 键启动:
$~[::
loop
{
	if(!WinActive(ahk_exe NemuPlayer.exe))
		WinActivate, ahk_class Qt5QWindowIcon
	sleep 3000
}
return
