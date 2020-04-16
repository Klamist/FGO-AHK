#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input ; Recommended for new scripts due to its superior speed and reliability.
SetMouseDelay, 0
SetBatchLines, -1 ; Make AHK run as fast as possible

;进入友情池界面，开始运行即可，抽到爆仓/没友情点为止。
;在圣晶石池子界面，本脚本无法运行。

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

;检测处于友情池界面
pixc(900,700,0x0B8ED6,1)
sleep 50
click,1030,730
sleep 300
click,1030,730
sleep 200

;循环抽卡
loop
{
	;寻找黑屏
	pixc(970,703,0X000000,1)
	
	loop
	{
		click,950,880
		if(pixc(950,740,0xD2D2D2))
		{
			sleep 150
			click,950,740
			break
		}
		if(pixc(894,633,0XD1D1D2))
		{
			msgbox 抽爆了
			exit
		}
		sleep 50
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