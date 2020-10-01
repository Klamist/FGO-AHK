#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

/*
功能：
每3秒置顶mumu窗口，用于长时间挂机时，防止杂碎软件弹窗干扰。

用法：
将此脚本与其他脚本一起加载到后台，然后一起按快捷键即可。
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
