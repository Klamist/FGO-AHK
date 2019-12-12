#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

;检测意外卡死。当鼠标60秒无操作，会打开MP3播放。
;请在同文件夹内，放一个MP3文件，改名alarm.mp3当闹钟。
;请确保你电脑打开MP3文件后，会自动播放。

;热键与自动刷本AHK相同，打开两份ahk，然后去刷图即可。

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
