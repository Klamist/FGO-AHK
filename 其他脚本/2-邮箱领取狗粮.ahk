#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input ; Recommended for new scripts due to its superior speed and reliability.
SetMouseDelay,0
SetBatchLines, -1 ; Make AHK run as fast as possible

/*
注意！
1. 请在MUMU模拟器里的键盘设置里：
	加入鼠标向上划动3个狗粮栏位宽度的操作，并将触发键设为“=”键。
	加入鼠标点击狗粮区域的操作，并将触发键设为主键盘“-”键。
	（若要用其他键，请到后文中droll代码段落修改Send{}的内容）
2. 请在礼物盒筛选功能中，去掉狗粮以外的所有内容，防止误领。

用法：
处于邮箱领取界面时，启动脚本即可。

功能：
勾选所有银狗粮、数量不足的金狗粮，并自动领取，直到邮箱翻完或爆仓。
*/

;可调参数：
sax:= 4 ;保留大于等于此数值堆叠的金狗粮。

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
pixc(1286,314,0x0AD096,1)
tot:=0
loop
{
	gosub,selexp
	sleep 100
	gosub,droll
	if(tot>95)
	{
		sleep 300
		click,1380,500
		pixc(1272,312,0x0AE2A8,1)
		tot:=0
	}
	if(pixc(1170,927,0xFCFCFC))
		break
}
click,1380,500
return

;========可调用子程序========
;向下翻页
droll:
	send {=} ;mumu划动翻页热键
	sleep 500
	if(tot=0)
		sleep 400
	else
		send {-} ;mumu区域单击热键
	sleep 100
return


;勾选当前页面狗粮
selexp:
	y:=200
	loop
	{
		y:=y+10
		bingo:=0
		PixelSearch, x,y,436,y,436,935,0xFDFDFD,5,Fast RGB
		if(y and y<935)
		{
			PixelSearch, x,,258,y+24,258,y+24,0xAB990C,20,Fast RGB
			if(!x) ;不是金狗粮必选
				;msgbox %y%,sil
				bingo:=1
			PixelSearch, x,,459,y+4,459,y+4,0xFFFFFF,20,Fast RGB
			if(x and sax>1) ;x1 436,711,0xFEFEFE 459,714,0xFFFFFF
				;msgbox %y%,x1
				bingo:=1
			PixelSearch, x,,450,y+12,450,y+12,0x383A3C,30,Fast RGB
			if(x and sax>2) ;x2 436,591,0xFDFDFD 450,603,0x383A3C
				;msgbox %y%,x2
				bingo:=1
			PixelSearch, x,,455,y-1,455,y-1,0x353637,30,Fast RGB
			if(x and sax>3) ;x3 436,556,0xFEFEFE 455,555,0x353637
				;msgbox %y%,x3
				bingo:=1
			PixelSearch, x,,451,y+2,451,y+2,0x333333,20,Fast RGB
			if(x and sax>4) ;x4 436,736,0xFEFEFE 450,807,0x333333
				;msgbox %y%,x4
				bingo:=1
			PixelSearch, x,,450,y-9,450,y-9,0x4E5153,20,Fast RGB
			if(x and sax>5) ;x5 436,295,0xFFFFFF 450,286,0x4E5153
				;msgbox %y%,x5
				bingo:=1
			PixelSearch, x,,479,y,479,y,0xFFFFFF,20,Fast RGB
			if(x) ;x5 436,295,0xFFFFFF 479,295,0xFFFFFF
				;msgbox %y%,xN0
				bingo:=0
			;如果要勾选 436,420,0xFEFEFE 
			if(bingo)
			{
				PixelSearch, x,yn,1040,y+55,1040,y+55,0xCCDCEB,20,Fast RGB
				if(x) ;是否可勾选 436,295 1040,350,0xCCDCEB
				{
					click,1040,%yn%
					sleep 50
					tot:=tot+1
				}
			}
		}
		else
			break
	}
return

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