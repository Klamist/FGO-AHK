#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input ; Recommended for new scripts due to its superior speed and reliability.
SetMouseDelay, 0 ; Removed mouse delay (as fast as possible).
SetBatchLines, -1 ; Make AHK run as fast as possible

/*
使用方法：
1. 根据要刷的副本，自行配置编队，并在后文中设置好相应的参数、战斗流程。
2. 提前设置好助战职阶、FGO自带筛选功能。
	（请点击副本，在助战界面设置职阶、礼装筛选，然后退回）
	（若要使用MIX阶，请设置比较苛刻的FGO内置礼装筛选，不然自动翻页检测时可能会错过）
3. 转到副本选择界面，将要刷的副本调整到位于列表首位，点击运行即可。

FGO客户端设置要求：
1. 在个人空间、游戏设置，关闭助战再临状态展示，关闭有利职阶自动选择。
2. 自己的CBA/孔明，指令卡面均用“再临3”样式。
3. 技能使用无需确认。
4. 若你开了插件APP，请隐藏它们的小图标，否则可能会挡住脚本识别像素点。

注：请确保MUMU模拟器的显示设置符合要求。详见《使用方法.txt》

日志记录：
刷本与吃苹果的情况，会记录在同目录下的fgo-ahk.log当中。
*/

;——————可调节参数——————
;刷本次数
cycle:= 10	;总共刷几次本，填正整数

;体力恢复(吃苹果按铜银金彩顺序尝试)
capple:= 0	;铜苹果，0=禁用，1=可用
sapple:= 0	;银苹果，0=禁用，1=可用
gapple:= 0	;金苹果，0=禁用，1=可用
kstone:= 0	;彩苹果，0=禁用，1=可用

;助战选择
passby:= 0	;助战来源，0=不限，1=仅好友 ———— 若选路人助战，过本后自动申请好友
supser:= 0	;从者选择，0=任意，1=CBA，2=孔明 ———— 设0不检测技能等级
tskill:= 0	;英灵技能，0=随意，1=全满级，2=一三技满，3=仅三技满
scraft:= 0	;概念礼装，0=任意，1=下午茶，2=蒙娜丽莎 ———— 活动礼装请设0并用FGO自带筛选
obreak:= 0	;礼装满破，0=随意，1=必须满破 ———— 礼装种类scraft=0时，不检测满破情况

;调试模式
global debug:= 0	;0=关闭，1=在fgo-ahk.log中记载详细运行过程（会导致脚本运行较慢）
;像素误差
global wucha:= 0	;0=精准运行，正整数=允许的像素误差范围。此项不影响脚本运行速度。
                  	;如果脚本有时会卡住，排除FGO内部问题、MUMU窗口问题后，可以加入像素误差，一般5-10即可，不能过大。

					
;——————战斗流程——————
order()
{
gosub,wstart ;检测可以开始

;可参照《战斗流程》文件夹内教程修改。若为空，则无限平砍
;战斗流程可修定部分：
{






}
;自定义部分结束。

xjbd(0) ;补刀+结算。若流程最后需要xjbd补刀，可以省略，用这句就行。
}
return


;下面为脚本的快捷键。可修改热键为F1~12，a~z，0~9等，修改“$~”与“::”之间的部分
;若想前置Ctrl需前置加“^”，Shift前置加“+”，Alt前置加“!”

; Ctrl + \ 退出脚本(任何时候都可以一键结束进程)
$~^\::ExitApp

; \ 键重置(相当于退出脚本再打开)
$~\::Reload

; ] 键暂停(从当前操作暂停，再按一次从暂停处继续)
$~]::Pause

; Ctrl + 0 键取消吃苹果(打到没AP就结束)
$~^0::
capple:= 0
sapple:= 0
gapple:= 0
kstone:= 0
return

; [ 键启动(开始循环刷本)
$~[::

;口口口口口口口口口口口口口口口口
;以后的代码，不建议修改，除非你懂
;口口口口口口口口口口口口口口口口

gosub,mumu
	;生成日志记录
	FormatTime,now,A_Now,yyyy-MM-dd HH:mm:ss
	FileAppend,`n%now%`n%A_ScriptName%`n,fgo-ahk.log
	cyclist:=0
loop ,%cycle%
{
	;等待检测处于free本选择界面
	pixc(206,903,0xFDFDFC,1)
	
	;点击副本
	click,900,300
	
	;检测吃苹果界面，或助战选择界面
	apok:=1
	loop
	{
		sleep 100
		if(pixc(1270,430,0xDFDFE7) and apok)
		{
			gosub,eat
			apok:=0
		}
		if(pixc(800,300,0xECF4FC) or pixc(1234,567,0x2C363A))
			break
	}
	
	;挑选助战
	gosub,support
	
	;选到助战，点击进本，等待开始战斗
	pixc(1500,850,0xF7F7F7,1,1)
		;记录刷本次数
		cyclist:=cyclist+1
		FormatTime,now,A_Now,HH:mm:ss
		FileAppend,%cyclist%/%cycle% %now%`n,fgo-ahk.log
	sleep 5000
	
	;按照设定好的刷本流程执行
	order()
	
	;进入结算环节，连点直到出去。
	loop
	{
		click,1300,845
		pixc(870,740,0XD6D6D6,0,1)
		if(pixc(800,200,0x000000))
			break
		sleep 100
	}
}
return

;================================以下均为可调用子程序/子段落================================

;循环探测指定像素点颜色，pl是否循环，lc=识别到后是否单击这个像素
pixc(x,y,color,pl:=0,lc:=0)
{
	dpix:=0x307521
	if(debug)
	{
		dpn:=Format("{1:4d},{2:4d},0x{3:06X}",x,y,color)
		FileAppend,%dpn%`n,fgo-ahk.log
	}
	loop
	{
		PixelSearch,xtmp,,x,y,x,y,color,wucha,Fast RGB
		if(xtmp)
		{
			if(lc)
				click,%x%,%y%
			return 1
		}
		else if(debug)
		{
			PixelGetColor,pix,x,y,RGB
			if(dpix!=pix)
			{
				dpix:=pix
				dpn:=Format("----,----,0x{3:06X}",x,y,dpix)
				FileAppend,%dpn%`n,fgo-ahk.log
			}
			sleep 450
		}
		if(!pl)
			return 0
		sleep 50
	}
}

;================================================================================================

;按铜银金彩，依次尝试吃苹果
eat:
{
	if(pixc(750,745,0xF4ECDB) and capple)
	{
		click,750,745
		sleep 400
		click,1050,740
		FileAppend,吃了铜苹果`n,fgo-ahk.log
		return
	}
	if(pixc(750,560,0xF4ECDB) and sapple)
	{
		click,750,560
		sleep 400
		click,1050,740
		FileAppend,吃了银苹果`n,fgo-ahk.log
		return
	}
	if(pixc(750,375,0xF4ECDB) and gapple)
	{
		click,750,375
		sleep 400
		click,1050,740
		FileAppend,吃了金苹果`n,fgo-ahk.log
		return
	}
	if(pixc(750,190,0xF4ECDB) and kstone)
	{
		click,750,190
		sleep 400
		click,1050,740
		FileAppend,吃了彩苹果`n,fgo-ahk.log
		return
	}
	MsgBox 你没AP了！
	Exit
}
return

;================================================================================================

;选择助战
support:
{
	if(supcheck(passby,supser,scraft,obreak,tskill))
		return
	;如果没有，刷新再找，重复50次
	loop,50
	{
		click,1060,200
		sleep 500
		click,1000,740
		loop
		{
			if(pixc(800,300,0xECF4FC) or pixc(1234,567,0x2C363A))
				break
			sleep 100
		}
		if(supcheck(passby,supser,scraft,obreak,tskill))
			return
		sleep 10000
	}
	MsgBox 助战丢了！
	Exit
}
return

;助战列表自动翻页检测
supcheck(passby,supser,scraft,obreak,tskill)
{
	if(pixc(1234,567,0x2C363A))
		return 0
	if(ncheck(passby,supser,scraft,obreak,tskill))
		return 1
	spy:=280
	loop,6
	{
		spy:=spy+100
		click,1550,%spy%
		sleep 200
		if(ncheck(passby,supser,scraft,obreak,tskill))
			return 1
	}
	return 0
}

;检测本页助战
ncheck(passby,supser,scraft,obreak,tskill)
{
	y:=200
	loop
	{
		y:=y+100
		;扫描从者栏位
		PixelSearch, x,y,1020,y,1020,935,0xEACA9A,10,Fast RGB
		if(!y)
			return 0
		;检测是否好友
		if(passby)
		{
			PixelSearch, x,,1450,y-53,1450,y-53,0xE4FEA5,10,Fast RGB
			if(!x) ;1020,501,0xE1C8A0 1450,448,0xE4FEA5
				continue
		}
		;匹配英灵
		if(supser)
		{
			PixelSearch, x,,200,y-95,200,y-95,0x5C295C,10,Fast RGB
			if(!x and supser=1) ;1020,367,0xE1CB98 CBA 200,272,0x5C295C
				continue
			PixelSearch, x,,255,y-70,255,y-70,0xFBDF93,10,Fast RGB
			if(!x and supser=2)	;孔明 1020,481,0xEDCB98 255,411,0xFBDF93
				continue
			;检测技能等级
			if(tskill) ;1020,489,0xEECC99
			{
				PixelSearch, x,,1079,y-30,1079,y-30,0XFFFFFF,10,Fast RGB
				if(!x and tskill<3)	;一技能 1079,469,0xFFFFFF
					continue
				PixelSearch, x,,1176,y-30,1176,y-30,0XFFFFFF,10,Fast RGB
				if(!x and tskill=1)	;二技能 1176,469,0xFFFFFF
					continue
				PixelSearch, x,,1273,y-30,1273,y-30,0XFFFFFF,10,Fast RGB
				if(!x and tskill>0)	;三技能 1273,469,0XFFFFFF
					continue
			}
		}
		;礼装种类与满破情况
		if(scraft)
		{
			PixelSearch, x,,111,y-50,111,y-50,0xF4CBD3,10,Fast RGB
			if(!x and scraft=1)	;下午茶 1020,378,0xEECC98 111,328,0xF4CBD3
				continue
			PixelSearch, x,,240,y-37,240,y-37,0x425B94,10,Fast RGB
			if(!x and scraft=2)	;蒙娜丽莎 1020,489,0xEECC99 240,452,0x425B94
				continue
			PixelSearch, x,,240,y-20,240,y-20,0xFFFF70,30,Fast RGB
			if(!x and obreak)	;是否满破 1020,489,0xEECC99 240,469,0xFFFF7B
				continue
		}
		click,1000,%y%
		return 1
	}
}

;================================================================================================

;检测可以开始行动
wstart:
{
	sleep 500
	loop
	{
		PixelSearch, xws,,1400,700,1400,700,0x0EBEDD,2,Fast RGB
		if(xws)
			break
		sleep 100
	}
	sleep 50
}
return

;从者放技能
ssk(si,st:=0)
{
	skc:=[ 80,200,320, 480,600,720, 880,1000,1120 ]
	skt:=[ 400,800,1200 ]
	;技能位置
	temp:=skc[si]
	click,%temp%,750
	sleep 200
	;指向位置
	if(st)
	{
		temp:=skt[st]
		click,%temp%,600
	}
	sleep 500
	pixc(1560,190,0xFED71E,1)
	sleep 100
}
return

;御主放技能
msk(sk,st:=0,sm:=0,sn:=0)
{
	skc:=[ 1130,1240,1350 ]
	skt:=[ 400,800,1200 ]
	change:=[ 170,420,670, 920,1170,1420 ]
	;御主面板
	click,1500,430
	sleep 300
	;技能位置
	temp:=skc[sk]
	click,%temp%,430
	sleep 200
	;指向位置
	if(st and st<4)
	{
		temp:=skt[st]
		click,%temp%,600
	}
	else if(st=4)
	{
		sleep 100
		temp:=change[sm]
		click,%temp%,500
		sleep 200
		temp:=change[sn]
		click,%temp%,500
		sleep 200
		click,800,820
	}
	sleep 500
	if(st=4)
		pixc(1400,700,0x0DBFDD,1)
	else
		pixc(1560,190,0xFED71E,1)
	sleep 100
}
return

;切换目标
target(n)
{
	enemy:=[ 60,360,660 ]
	temp:=enemy[n]
	click,%temp%,90
	sleep 200
}
return

;================================================================================================

;平砍直到换下一面，或战斗结束。可用于监测战斗结束状态。
xjbd(n:=0)
{
	nn:=0
	loop
	{
		;检测羁绊结算界面
		if(pixc(130,270,0xE5BB1F))
			return
		;检测黑屏换面
		if(pixc(480,880,0x000000) and n>0)
			break
		;检测战斗界面attack按钮是否又出现
		if(pixc(1560,190,0xFED71E))
		{
			nn:=nn+1
			attack()
			if(nn=n)
				break
		}
		sleep 100
	}
	pixc(1560,190,0xFED71E,1)
	sleep 100
}
return

;出3卡平砍(尽量首红)
attack()
{
	ccoord:=[ 247,567,886,1208,1533 ]
	click,1400,800
	sleep 500
	
	;选1张红卡，如果没有就选最后一张
	ci:=1
	loop,5
	{
		xard:=ccoord[ci]
		PixelSearch,x,,xard,775,xard,775,0xFF2D1C,10,Fast RGB
		if(x)
		{
			click,%xard%,640
			break
		}
		ci:=ci+1
	}
	if(ci=6)
	{
		ci:=5
		click,1373,640
	}
	sleep 130
	
	;补选其他两张卡
	cj:=1
	loop,5
	{
		if(cj!=ci)
		{
			temp:=ccoord[cj]
			click,%temp%,640
			break
		}
		cj:=cj+1
	}
	sleep 130
	
	ck:=cj+1
	loop,5
	{
		if(ck!=ci)
		{
			temp:=ccoord[ck]
			click,%temp%,640
			break
		}
		ck:=ck+1
	}
	sleep 130
	
	sleep 1000
}
return

;================================================================================================

;宝具回合出卡
baoju(n1,n2:=0,n3:=0)
{
	;打开选卡界面
	click,1400,800
	sleep 1500
	
	;第一张选卡
	if(n1)
		npc(n1)
	else
		nkc()
	sleep 130
	
	;第二张选卡
	if(n2)
		npc(n2)
	else if(n1)
		nkc()
	else
		kc()
	sleep 130
	
	;第三张选卡
	if(n3)
		npc(n3)
	else if(n1 and n2)
		nkc()
	else if(n1=0 and n2=0)
	{
		msgbox 宝具卡丢了！
		Exit
	}
	else 
		kc()
	sleep 130
	
	sleep 10000
	;等待可进行下一步操作
	loop
	{
		;检测羁绊结算界面
		if(pixc(130,270,0xE5BB1F))
			break
		;检测御主界面是否又出现
		if(pixc(1560,190,0xFED71E))
			break
		sleep 100
	}
}
return

;选一个宝具卡
npc(n)
{
	npcard:=[ 480,800,1120 ]
	temp:=npcard[n]
	click,%temp%,300
}
return

;选1张非CBA/孔明卡，如果没有就选最后一张
nkc()
{
	;指令卡间隔320,319,322,325
	ccoord:=[ 149,469,788,1110,1435 ]
	ci:=1
	loop,5
	{
		xard:=ccoord[ci]
		if(!pixc(xard,640,0XFFF7E3) and !pixc(xard,640,0xFBEFD7))
		{
			click,%xard%,640
			break
		}
		ci:=ci+1
	}
	if(ci=6)
		click,1435,640
}
return

;选1张CBA/孔明卡，如果没有就选最后一张
kc()
{
	;指令卡间隔320,319,322,325
	ccoord:=[ 149,469,788,1110,1435 ]
	ci:=1
	loop,5
	{
		xard:=ccoord[ci]
		if(pixc(xard,640,0XFFF7E3) or pixc(xard,640,0xFBEFD7))
		{
			click,%xard%,640
			break
		}
		ci:=ci+1
	}
	if(ci=6)
		click,1435,640
}
return

;================================================================================================

;检测MUMU模拟器窗口
mumu:
{
	if WinActive("ahk_exe NemuPlayer.exe")=0
	{
		MsgBox 未发现mumu窗口
		Exit
	}
return
}