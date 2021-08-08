﻿#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input ; Recommended for new scripts due to its superior speed and reliability.
SetMouseDelay, 0

/*
功能：
自动抽取友情池到爆仓或没友情点。

用法：
进入友情池抽取界面，启动脚本即可。

注意：
每日首次免费请先自己抽掉。
*/

;偏量设置
cpx:= 0
cpy:= 0
;mumu模拟器为0和36
;雷电模拟器为1和34（4K屏请用1和51）
;其他模拟器请看《FGO-AHK参数说明》


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
pixc(835,54,0xA2E447,1)
sleep 50
sclick(1030,694)
sleep 300
sclick(1030,694)
sleep 200

;循环抽卡
loop
{
	;寻找黑屏
	pixc(970,667,0X000000,1)
	
	loop
	{
		sclick(950,844)
		if(pixc(1040,674,0xF9F9F9))
		{
			loop,5
			{
				sleep 100
				sclick(950,704)
			}
		}
		if(pixc(470,744,0x317090))
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
	;加入偏量
	x:=x+cpx
	y:=y+cpy
	
	loop
	{
		PixelSearch,xtmp,,x,y,x,y,color,wucha,Fast RGB
		if(xtmp)
		{
			if(lc)
				click,%x%,%y%
			return 1
		}
		if(!pl)
			return 0
		sleep 100
	}
}

;带偏移量的click，输入FGO区域相对坐标，点击加偏量后的
sclick(x,y)
{
	x:=x+cpx
	y:=y+cpy
	click,%x%,%y%
	return
}
