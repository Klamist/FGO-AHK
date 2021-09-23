#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input ; Recommended for new scripts due to its superior speed and reliability.
SetMouseDelay,0

/*
目前适用于2021国服斯卡祭。

功能：
自动抽无限池、刷新，抽到爆仓或指定池数后停止。

用法：
在后文设置抽取的池数，设置模拟器偏量，进入无限池抽取界面，运行即可。

注意：
前10池最好别抽到没票，按整池抽，以防未抽完一池没票了但可以刷新。
*/

cycle:= 2 ;自动抽取池数，想抽光就设置高一点，20池足以爆邮箱。

;偏量设置
global cpx:= 0
global cpy:= 0
;mumu模拟器为0和36
;雷电模拟器为1和34（4K屏请用1和51）
;夜神模拟器为2和32
;其他模拟器请看《FGO-AHK参数说明》



;像素容差
global wucha:= 2

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
loop,%cycle%
{
	;等待检测处于无限池界面
	pixc(1087,168,0x5FA9F9,1)
	sleep 200
	
	;如果不能抽了，则停止
	if(!pixc(409,554,0x0BB6F1))
		break
	
	;开始连抽，抽到光
	loop
	{
		if(!pixc(1087,168,0x5FA9F9))
			break
		sclick(428,540)
		sleep 70
	}
	loop
	{
		;服务器断开010101
		pixc(900,720,0xD9DADB,0,1)
		;抽光这池了
		if(pixc(1087,168,0x5FA9F9))
			break
		;爆仓了
		if(pixc(1220,720,0xD9DADC))
			break 2
		sclick(428,540)
		sleep 70
	}
	sleep 200
	
	;检测是否可以刷新下一池
	if(pixc(1320,304,0x8DB0E2,0,1))
	{
		pixc(940,703,0xD2D3D3,1,1)
		pixc(690,703,0xD2D2D3,1,1)
		pixc(1037,315,0xFFFFFF,1)
	}
}
msgbox 抽爆了！
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
