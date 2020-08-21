SetMouseDelay, 0
SetBatchLines, -1 ; Make AHK run as fast as possible
/*
进入礼装强化界面，选择一个主礼装后，开启脚本。
自动点击、拖选礼装，然后强化，直到没有礼装可选。

请提前锁定有用的礼装。
脚本只会选取前排的礼装，请设置强化素材界面的排序方式，推荐按稀有度倒序。
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
loop
{
	;检测处于喂礼装界面
	pixc(745,908,0xF7DF19,1)
	sleep 50
	click,650,330
	sleep 200
	
	;选择礼装
	pixc(100,60,0xF5F5F5,1)
	sleep 200
	Click,175,350,down
	sleep 600
	MouseMove,1000,700,10
	sleep 100
	Click,up
	sleep 100
	click,1400,880
	
	;确认喂
	pixc(745,908,0xF7DF19,1)
	sleep 50
	click,1380,880
	sleep 300
	click,1050,770
	sleep 500
	
	;连点直到出去。
	loop
	{
		if(pixc(745,908,0xF7DF19))
			break
		click,800,600
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