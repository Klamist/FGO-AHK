#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input ; Recommended for new scripts due to its superior speed and reliability.
SetMouseDelay,0
SetBatchLines, -1 ; Make AHK run as fast as possible

/*
目前适用于国服弓凛祭。

功能：
从上到下勾选堆叠不足SN个的金狗粮(SN可设置)，以及堆叠1~4的银狗粮，并自动领取，直到邮箱翻完或爆仓。

用法：
按后文注意事项设置好后，处于邮箱领取界面时，启动脚本即可。

注意：
1. 请在模拟器的键位设置(工具栏里找键位盘)：
	①鼠标在邮件区域向上拖动3个栏位宽度，设置为“=”键。
	②鼠标点击狗粮区域，设为主键盘“-”键。
	（xN文件夹内有“键位设置.png”可以参考。若要用其他键，请到后文中droll代码段落修改Send{}的内容）
2. 请在礼物盒筛选功能中，去掉狗粮以外的所有内容，防止误领。
3. 邮件顺序请从新到旧排列。
4. 注意，目前四星、五星金狗粮无法区分，但五星堆叠超过指定值也会留着。
*/

;可调参数：
SN:= 3	;保留堆叠数大于等于此值的狗粮。
		;最高可设为7（即领取所有x1~6的狗粮）

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

; [ 键启动
$~[::
pixc(1286,278,0x0DCC99,1)
tot:=0
loop
{
	gosub,selexp
	sleep 100
	gosub,droll
	if(tot>95)
	{
		sleep 300
		sclick(1380,464)
		pixc(1286,278,0x0DCC99,1)
		tot:=0
	}
	if(pixc(1170,890,0xFFFFFF))
		break
}
sclick(1380,464)
return

;========可调用子程序========

;向下翻页
droll:
	send {=} ;mumu划动翻页热键
	sleep 400
	if(tot=0)
		sleep 500
	else
		send {-} ;mumu区域单击热键
	sleep 100
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
			loop
			{
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
				;堆叠数大于6留着
				;msgbox, x7+
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
