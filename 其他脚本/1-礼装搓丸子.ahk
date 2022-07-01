#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
;SendMode Input ; Recommended for new scripts due to its superior speed and reliability.
SetMouseDelay, 1

/*
功能：
自动选择素材列表最前面的20个礼装，然后喂给某礼装，直到没有礼装可选。

用法：
进入礼装强化界面，选择一个要强化礼装后，开启脚本。

注意事项：
1. 请提前锁定有用的礼装。
2. 请设置强化素材界面的排序方式，让需要喂掉的礼装都在最前面。
	推荐开启智能筛选，按稀有度，升序排列。
*/

;偏量（必须精确设置）
global cpx:= 0
global cpy:= 0
;mumu模拟器为0和36
;雷电模拟器为1和34（4K屏请用1和51）
;夜神模拟器为2和32
;其他模拟器请看《FGO-AHK参数说明》



;像素容差
global wucha:= 5

; Ctrl + \ 退出脚本
$~^\::ExitApp

; \ 键重置
$~\::Reload

; ] 键暂停
$~]::Pause

; [ 键启动:
$~[::
loop
{
	;检测处于喂礼装界面
	pixc(745,871,0xF7DF19,1)
	sleep 50
	sclick(650,294)
	sleep 200
	
	;选择礼装
	pixc(40,300,0xFFEFDE,1)
	sleep 200
	tx:=175+cpx
	ty:=314+cpy
	Click,%tx%,%ty%,down
	sleep 600
	tx:=1000+cpx
	ty:=664+cpy
	MouseMove,%tx%,%ty%,10
	sleep 100
	Click,up
	sleep 300
	if(pixc(1360,840,0x6B6C6C))
	{
		Msgbox 喂光了！
		Exit
	}
	sclick(1360,840)
	
	;确认喂
	pixc(745,871,0xF7DF19,1)
	sleep 50
	sclick(1360,840)
	sleep 300
	sclick(1050,740)
	sleep 500
	
	;连点直到出去。
	loop
	{
		if(pixc(745,871,0xF7DF19))
			break
		sclick(800,564)
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
			{
				loop
				{
					PixelSearch,xtmp,,x,y,x,y,color,wucha,Fast RGB
					if(xtmp)
						click,%x%,%y%
					else
						break
					sleep 500
				}
			}
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
