#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input ; Recommended for new scripts due to its superior speed and reliability.
SetMouseDelay,0

/*
目前适用于2020国服弓凛祭。

功能：
自动抽无限池、刷新，抽到爆仓或指定池数后停止。

用法：
在后文设置抽取的池数，进入无限池抽取界面，运行即可。

注意：
前10池最好别抽到没票，按整池抽，以防未抽完一池没票了但可以刷新。
*/

cycle:= 2 ;自动抽取池数，想抽光就设置高一点，20池足以爆邮箱。



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
	pixc(400,500,0xFFFF96,1)
	sleep 200
	
	;如果不能抽了，则停止
	if(!pixc(415,570,0x15A1E2))
		break
	
	;开始连抽，抽到光
	loop
	{
		if(!pixc(73,66,0xEDEDED))
			break
		click,415,570
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
	if(pixc(1331,341,0x8EB0E3,0,1))
	{
		pixc(950,740,0xD3D3D3,1,1)
		pixc(700,737,0xD7D7D7,1,1)
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
		msgbox 未发现mumu窗口
		exit
	}
}
return