#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input ; Recommended for new scripts due to its superior speed and reliability.
SetMouseDelay,0
SetBatchLines, -1

/*
圣诞4-无限池适用脚本。
进入无限池抽取界面，按键开始运行即可。

功能：自动抽+刷新下一池，循环操作。
停止：没票，或邮箱爆仓，或抽完预设池数后

注意！
前十池如果抽到大奖后没票了，即便没抽完也会自动刷新！
如果池子里正好剩1个，请手动抽换下一池！
*/

cycle:= 10 ;自动抽取池数，想抽光就设置高一点，20池足以爆邮箱。

;口口口口口口口口口口口口口口口口口口口
;不建议修改之后的代码，除非你感觉自己懂
;口口口口口口口口口口口口口口口口口口口

; Ctrl + \ 退出脚本
$~^\::ExitApp

; \ 键重置
$~\::Reload

; ] 键暂停
$~]::Pause

; [ 键启动
$~[::
gosub,mumu
loop,%cycle%
{
	;等待检测处于无限池界面
	pixc(810,210,0x6994F2,1)
	sleep 200
	
	;如果不能抽了，则停止
	if(!pixc(415,575,0x11A9E4))
		break
	
	;开始连抽，抽到光
	loop
	{
		if(!pixc(73,66,0xEDEDED))
			break
		click,415,575
		sleep 70
	}
	loop
	{
		if(pixc(73,66,0xEDEDED))
			break
		if(pixc(598,737,0xD1D1D1))
			break 2
		click,415,575
		sleep 70
	}
	sleep 200
	
	;检测是否可以刷新下一池
	if(pixc(1331,341,0x8AB3E5,0,1))
	{
		pixc(950,740,0xD3D3D3,1,1)
		pixc(700,740,0xD5D5D6,1,1)
		pixc(1037,351,0xFFFFFF,1)
	}
}
msgbox 抽爆了！
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
			if(lc=1)
				click,%x%,%y%
			return 1
		}
		else if(pl=0)
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
		msgbox 未发现mumu窗口
		exit
	}
}
return