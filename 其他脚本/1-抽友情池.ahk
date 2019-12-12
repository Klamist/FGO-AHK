#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input ; Recommended for new scripts due to its superior speed and reliability.
SetMouseDelay, 0

;进入友情池界面，开始运行即可，抽到爆仓/没友情点为止。
;抽几次十连？
shoot:=200

;口口口口口口口口口口口口口口口口口口口
;不建议修改之后的代码，除非你感觉自己懂
;口口口口口口口口口口口口口口口口口口口

; Ctrl + \ 退出脚本
$~^\::ExitApp

; \ 键重置
$~\::Reload

; ] 键暂停
$~]::Pause

; [ 键启动:
$~[::
gosub,mumu
loop,%shoot%
{
	;检测处于友情池界面
	pixc(900,700,0x0E8ED4,1)
	sleep 50
	click,1030,730
	sleep 200
	click,1030,730
	sleep 200
	
	if(pixc(894,633,0XD1D1D2))
	{
		msgbox 爆仓了！
		exit
	}
	
	pixc(970,703,0X000000,1)
	
	;连点直到出去。
	loop
	{
		click,950,870
		if(pixc(900,700,0x0E8ED4))
			break
		sleep 40
	}
}
return

;========可调用子程序========

;循环探测指定像素点颜色，pl是否循环，lc=识别到后是否单击这个像素
pixc(x,y,color,pl:=0,lc:=0)
{
	loop
	{
		PixelGetColor,pix,x,y,RGB
		if(pix=color)
		{
			if(lc)
				click,%x%,%y%
			return 1
		}
		else if(!pl)
			return 0
		sleep 100
	}
}
return

;检测MUMU模拟器窗口
mumu:
{
	if WinActive("ahk_exe NemuPlayer.exe")=0
	{
		MsgBox 未发现mumu窗口
		exit
	}
}
return
