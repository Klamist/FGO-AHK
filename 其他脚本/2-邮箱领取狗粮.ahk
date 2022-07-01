#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
SetMouseDelay, 1
SetKeyDelay, 1
SetBatchLines, -1 ; Make AHK run as fast as possible

/*
本脚本需配合《xN》文件夹一起使用，请确保目录内同时包含二者。

功能：
从上到下勾选堆叠不足N个的金狗粮，以及堆叠低于6的银狗粮，并自动领取，直到邮箱翻完或爆仓。

用法：
按后文注意事项设置好后，处于邮箱领取界面时，启动脚本即可。

注意：
1. 请在筛选功能中只留狗粮，防止误领。
2. 邮件顺序请从新到旧排列。
3. 五星狗粮全都保留。
*/

;可调参数：
SN:= 3	;金狗粮堆叠保留值，最高可设5（低于此值才领取）

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

; [ 键启动
$~[::
pixc(1276,626,0x940101,1)
tot:=0
loop
{
	;寻找本页狗粮
	gosub,selexp
	sleep 100
	;向上拖动
	gosub,droll
	
	;选中超过95个时领取
	if(tot>95)
	{
		sleep 300
		;点击领取
		sclick(1380,470)
		loop
		{
			;等待恢复初始邮箱界面
			if(pixc(1276,626,0x940101) && pixc(1281,276,0x0AD89E))
				break
			sleep 100
		}
		tot:=0
	}
	sleep 100
	
	;翻完了后领取退出
	if(pixc(1172,843,0xFEFEEE))
		break
}
sclick(1380,470)
return

;========可调用子程序========

;向下翻页
droll:
	tx:=666+cpx
	ty:=820+cpy
	MouseMove,tx,ty,0
	MouseClickDrag, left, tx,ty,tx,ty-500,30
	sleep 200
	
	if(tot=0)
		sleep 200
	else
		sclick(600,600)
return


;勾选当前页面狗粮
selexp:
	y:=164+cpy
	loop
	{
		y:=y+10
		bingo:=0
		PixelSearch, x,y,436+cpx,y,436+cpx,900+cpy,0xFDFDFD,5,Fast RGB
		if(y and y<900+cpy)
		{
			;银狗粮直接选取
			PixelSearch, x,,259+cpx,y+24,259+cpx,y+24,0xECECEC,20,Fast RGB
			if(x)
			{
				;msgbox, 银
				bingo:=1
			}
			
			;判断堆叠数
			loop
			{
				;判断五星狗粮
				PixelSearch, x,,190+cpx,y,190+cpx,y,0xFFFFFF,10,Fast RGB
				if(x)
				{
					;msgbox, 五星狗粮
					bingo:=0
					break
				}
				;判断堆叠x1
				ImageSearch, x,, 445+cpx,y-20,480+cpx,y+20, *100 %A_WorkingDir%\xN\1.png
				if(x)
				{
					;msgbox, x1
					if(SN>1)
						bingo:=1
					break
				}
				;判断堆叠x2
				ImageSearch, x,, 445+cpx,y-20,480+cpx,y+20, *100 %A_WorkingDir%\xN\2.png
				if(x)
				{
					;msgbox, x2
					if(SN>2)
						bingo:=1
					break
				}
				;判断堆叠x3
				ImageSearch, x,, 445+cpx,y-20,480+cpx,y+20, *100 %A_WorkingDir%\xN\3.png
				if(x)
				{
					;msgbox, x3
					if(SN>3)
						bingo:=1
					break
				}
				;判断堆叠x4
				ImageSearch, x,, 445+cpx,y-20,480+cpx,y+20, *100 %A_WorkingDir%\xN\4.png
				if(x)
				{
					;msgbox, x4
					if(SN>4)
						bingo:=1
					break
				}
				/*
				;判断堆叠x5
				ImageSearch, x,, 445+cpx,y-20,480+cpx,y+20, *100 %A_WorkingDir%\xN\5.png
				if(x)
				{
					;msgbox, x5
					if(SN>5)
						bingo:=1
					break
				}
				;判断堆叠x6
				ImageSearch, x,, 445+cpx,y-20,480+cpx,y+20, *100 %A_WorkingDir%\xN\6.png
				if(x)
				{
					;msgbox, x6
					if(SN>6)
						bingo:=1
					break
				}
				;判断堆叠x7
				ImageSearch, x,, 445+cpx,y-20,480+cpx,y+20, *100 %A_WorkingDir%\xN\7.png
				if(x)
				{
					;msgbox, x7
					if(SN>7)
						bingo:=1
					break
				}
				*/
				;堆叠数更多的留着
				bingo:=0
				break
			}
			
			;如果要勾选
			if(bingo)
			{
				PixelSearch, x,yn,1040+cpx,y+56,1040+cpx,y+56,0xCCDCEB,20,Fast RGB
				if(x) ;是否可勾选 436,456 1040,512,0xCEDEED
				{
					sclick(1040,yn-cpy)
					sleep 100
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
