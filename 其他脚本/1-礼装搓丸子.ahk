SetMouseDelay, 0

;进入礼装强化界面，选择一个主礼装后，开启脚本。
;请提前锁定有用的礼装，设置素材的排序方式(推荐按稀有度倒序)
;自动点击、拖选礼装，然后强化，直到没有礼装可选


; Ctrl + \ 退出脚本
$~^\::ExitApp

; \ 键重置
$~\::Reload

; ] 键暂停
$~]::Pause

; [ 键启动:
$~[::
gosub,mumu
loop
{
	;检测处于喂礼装界面
	pixc(1218,609,0XF0F8F8,1)
	sleep 50
	click,652,330
	sleep 200
	
	;选择礼装
	pixc(104,64,0XF1F1F1,1)
	sleep 200
	Click,175,350,down
	sleep 600
	MouseMove,1000,700,10
	sleep 100
	Click,up
	sleep 100
	click,1400,880
	
	;确认喂
	pixc(1253,668,0XF1F9FE,1)
	sleep 50
	click,1361,881
	sleep 200
	click,1052,774
	
	;黑屏监测
	pixc(1099,767,0X000000,1)
	;连点直到出去。
	loop
	{
		click,323,697
		if(!pixc(1099,767,0X000000))
			break
		sleep 100
	}
	loop
	{
		click,814,687
		if(pixc(1293,668,0XF8F8FE))
			break
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
