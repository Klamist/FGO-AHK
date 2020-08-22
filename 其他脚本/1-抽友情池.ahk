#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input ; Recommended for new scripts due to its superior speed and reliability.
SetMouseDelay, 0


/*
使用方法：
进入友情池抽取界面，启动脚本，会自动抽到爆仓。

注意事项：
每日首次免费请先自己抽掉。
*/


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
pixc(835,90,0xA2E447,1)
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
		if(pixc(1040,710,0xF9F9F9))
		{
			sleep 100
			click,950,740
			sleep 100
			click,950,740
			sleep 100
			click,950,740
		}
		if(pixc(470,780,0x317090))
		{
			msgbox 抽爆了
			exit
		}
		sleep 100
	}
}
return

;========可调用子程序========

;循环探测指定像素点颜色，pl是否循环，lc=识别到后是否单击这个像素
pixc(x,y,color,pl:=0,lc:=0)
{
	loop
	{
		PixelSearch,xtmp,,x,y,x,y,color,3,Fast RGB
		if(xtmp)
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