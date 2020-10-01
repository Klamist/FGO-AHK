#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

/*
功能：
检测意外卡死，或宣告结束。当鼠标60秒无操作，会打开MP3播放。

用法：
1. 在同文件夹内，放一个MP3文件，改名alarm.mp3当闹钟。
2. 确保你电脑打开MP3文件后，会自动播放。
3. 将此脚本与其他脚本一起加载到后台，然后一起按快捷键即可。
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
	ob:=0
	loop, 40
	{
		MouseGetPos,x1,y1
		sleep 1500
		MouseGetPos,x2,y2
		if(x1!=x2)
			break
		if(y1!=y2)
			break
		ob:=ob+1
	}
	if(ob=40)
	{
		Run,alarm.mp3
	}
}
return
