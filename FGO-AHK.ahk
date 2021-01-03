#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input ; Recommended for new scripts due to its superior speed and reliability.
SetMouseDelay, 0 ; Removed mouse delay (as fast as possible).
SetBatchLines, -1 ; Make AHK run as fast as possible


;——————可调节参数——————
;刷本次数
cycle:= 10	;总共刷几次本，填正整数。
overap:= 1	;是否清完AP，0=刷本次数达标就停，1=继续清完剩余AP。

;体力恢复(吃苹果按铜银金彩顺序尝试)
capple:= 0	;铜苹果，0=禁用，1=可用
sapple:= 0	;银苹果，0=禁用，1=可用
gapple:= 0	;金苹果，0=禁用，1=可用
kstone:= 0	;彩苹果，0=禁用，1=可用

;助战选择
passby:= 0	;助战来源，0=不限，1=仅好友 ———— 若选路人助战，过本后自动申请好友
supser:= 0	;从者选择，0=任意，1=CBA，2=孔明，3=梅林，4=花嫁，5=狐狸，6=仇凛 ———— 设0不检测技能等级
tskill:= [ 0,0,0 ]	;英灵技能，0=任意，1=必须满级，三个技能位可分别设置。
scraft:= 0	;概念礼装，0=任意，1=下午茶，2=贝拉丽莎 ———— 活动礼装请设0并用FGO自带筛选
obreak:= 0	;礼装满破，0=随意，1=必须满破 ———— 礼装种类scraft=0时，不检测满破情况

;调试模式
global debug:= 0	;0=关闭，1=在fgo-ahk.log中记录像素不匹配的情况（会导致脚本运行较慢）
;像素容差
global wucha:= 2	;0=精准运行，正整数=允许的像素误差范围。此项不影响脚本运行速度。2.6版本推荐留2防止智障。
                  	;如果脚本有时会卡住，排除FGO内部问题、MUMU窗口问题后，可以增加像素误差，一般到5-10即可，不能过大。


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


;下面为脚本的快捷键。可修改热键为F1~12，a~z，0~9等，请修改“$~”与“::”之间的部分
;若想前置Ctrl需前置加“^”，Shift前置加“+”，Alt前置加“!”

; Ctrl + \ 退出脚本(任何时候都可以一键结束进程)
$~^\::ExitApp

; \ 键重置(相当于关闭脚本再打开)
$~\::Reload

; Ctrl + 0 键 取消吃苹果
$~^0::
capple:= 0
sapple:= 0
gapple:= 0
kstone:= 0
return

; ] 键暂停(从当前操作暂停，再按一次从暂停处继续)
$~]::Pause

; [ 键启动(开始循环刷本)
$~[::
{

;口口口口口口口口口口口口口口口口
;以后的代码，不建议修改，除非你懂
;口口口口口口口口口口口口口口口口


;确认mumu窗口
gosub,mumu
click,900,300

;生成日志记录
FormatTime,now,A_Now,yyyy-MM-dd HH:mm:ss
FileAppend,`n%now%`n%A_ScriptName%`n,fgo-ahk.log
;刷本次数记录
cyclist:=0


;连续出击主循环内容
loop
{
	;检测当前刷本次数
	if(cyclist=cycle)
	{
		;次数达标后禁用吃苹果
		capple:= 0
		sapple:= 0
		gapple:= 0
		kstone:= 0
		
		;若不清剩余AP，直接退出
		if(!overap)
			break
	}
	
	;检测吃苹果界面，或助战选择界面
	apok:=0
	loop
	{
		sleep 100
		if(pixc(1270,400,0xE5E5ED) and !apok)
		{
			gosub,eat
			apok:=1
		}
		if((pixc(1000,200,0x08B5F7) && pixc(1500,320,0xE9B712)) or pixc(978,590,0xFFFFFF))
			break
	}
	
	;挑选助战，进本等待开始
	gosub,support
	if(cyclist=0)
		pixc(1488,888,0xC4C8CC,1,1)
	sleep 3000
	
	;记录刷本次数
	cyclist:=cyclist+1
	FormatTime,now,A_Now,HH:mm:ss
	FileAppend,%cyclist%/%cycle% %now%`n,fgo-ahk.log
	
	;按照设定好的刷本流程执行
	order()
	
	;进入结算环节，连点直到出去。
	loop
	{
		click,1300,845
		pixc(870,740,0xD7D7D7,0,1)
		pixc(303,803,0xD6D6D6,0,1)
		if(pixc(1041,314,0xFFFFFF))
		{
			sleep 200
			click,950,750
			break
		}
		sleep 100
	}
}
MsgBox 打完了！
}
return

;================================以下均为可调用子程序/子段落================================

;循环探测指定像素点颜色，pl是否循环，lc=识别到后是否单击这个像素
pixc(x,y,color,pl:=0,lc:=0)
{
	mup()	
	;调试模式：记录要求的像素点
	if(debug)
	{
		dpix:=0x307521
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
			;记录不匹配的颜色
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
		sleep 100
	}
}

;================================================================================================

;按铜银金彩，依次尝试吃苹果
eat:
{
	if(pixc(750,745,0xF4ECDB) and capple)
	{
		click,750,745
		sleep 500
		click,1050,740
		FileAppend,吃了铜苹果`n,fgo-ahk.log
		return
	}
	else if(pixc(750,560,0xF4ECDB) and sapple)
	{
		click,750,560
		sleep 500
		click,1050,740
		FileAppend,吃了银苹果`n,fgo-ahk.log
		return
	}
	else if(pixc(750,375,0xF4ECDB) and gapple)
	{
		click,750,375
		sleep 500
		click,1050,740
		FileAppend,吃了金苹果`n,fgo-ahk.log
		return
	}
	else if(pixc(750,190,0xF4ECDB) and kstone)
	{
		click,750,190
		sleep 500
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
	;如果没有，刷新再找
	loop
	{
		click,1060,200
		sleep 500
		click,1000,740
		loop
		{
			if(pixc(1000,200,0x08B5F7) && pixc(1500,320,0xE9B712))
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
	if(pixc(978,590,0xFFFFFF))
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
		PixelSearch, x,y,1030,y,1030,920,0xDED5BB,13,Fast RGB
		if(!y)
			return 0
		;检测是否好友
		if(passby)
		{
			PixelSearch, x,,1450,y-52,1450,y-52,0xE0FEAA,10,Fast RGB
			if(!x) ;1020,501,0xE1C8A0 1450,450,0xDFFFAE
				continue
		}
		;匹配英灵
		if(supser)
		{
			if(supser=1)
			{
				PixelSearch, x,,255,y-80,255,y-80,0x02022B,10,Fast RGB
				if(!x) ;CBA 1020,455,0xF0CE9B 255,375,0x02022B
					continue
			}
			else if(supser=2)
			{
				PixelSearch, x,,255,y-70,255,y-70,0xF9E096,10,Fast RGB
				if(!x) ;孔明 1020,562,0xE5C99D 255,492,0xF9E096
					continue
			}
			else if(supser=3)
			{
				PixelSearch, x,,126,y-76,126,y-76,0xE4C4D4,10,Fast RGB
				if(!x) ;梅林 1030,648,0xE7D8B7 126,572,0xE4C4D4
					continue
			}
			else if(supser=4)
			{
				PixelSearch, x,,102,y-63,102,y-63,0xD5A384,10,Fast RGB
				if(!x) ;花嫁 1020,885,0xD3D4C4 102,822,0xD5A384
					continue
			}
			else if(supser=5)
			{
				PixelSearch, x,,255,y-66,255,y-66,0xB75444,10,Fast RGB
				if(!x) ;狐狸 1030,555,0xD3D4C5 255,489,0xB75444
					continue
			}
			else if(supser=6)
			{
				PixelSearch, x,,150,y-72,150,y-72,0xFF9C3F,10,Fast RGB
				if(!x) ;仇凛 1030,502,0xD6D4C3 150,430,0xFF9C3F
					continue
			}
			;检测技能等级
			if(tskill[1] or tskill[2] or tskill[3]) ;1020,489,0xEECC99
			{
				if(tskill[1])
				{
					PixelSearch, x,,1079,y-30,1079,y-30,0XFFFFFF,10,Fast RGB
					if(!x)	;一技能 1079,469,0xFFFFFF
						continue
				}
				if(tskill[2])
				{
					PixelSearch, x,,1176,y-30,1176,y-30,0XFFFFFF,10,Fast RGB
					if(!x)	;二技能 1176,469,0xFFFFFF
						continue
				}
				if(tskill[3])
				{
					PixelSearch, x,,1273,y-30,1273,y-30,0XFFFFFF,10,Fast RGB
					if(!x)	;三技能 1273,469,0XFFFFFF
						continue
				}
			}
		}
		;礼装种类与满破情况
		if(scraft)
		{
			;礼装种类
			if(scraft=1)
			{
				PixelSearch, x,,111,y-50,111,y-50,0xFAD5D5,10,Fast RGB
				if(!x)	;下午茶 1020,629,0xEECC98 111,319,0xF9D8D8
					continue
			}
			else if(scraft=2)
			{
				PixelSearch, x,,174,y-41,174,y-41,0xFDD8D0,10,Fast RGB
				if(!x)	;贝拉丽莎 1020,456,0xEECC99 174,461,0xFDD4D4
					continue
			}
			;是否满破
			if(obreak)
			{
				PixelSearch, x,,240,y-20,240,y-20,0xFFFF75,22,Fast RGB
				if(!x)	;满破星星 1020,629,0xEECC98 240,609,0xFCFC8A
					continue
			}
		}
		y:=y-30
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
		if(pixc(1400,735,0x02D9F1) && pixc(1450,290,0x1A2333))
			break
		sleep 100
	}
	sleep 300
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
	sleep 250
	;指向位置
	if(st)
	{
		temp:=skt[st]
		click,%temp%,600
	}
	sleep 500
	loop
	{
		if(pixc(1450,290,0x1A2333) && pixc(1514,292,0xFAFFFF))
			break
		sleep 100
	}
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
	sleep 400
	;技能位置
	temp:=skc[sk]
	click,%temp%,430
	sleep 300
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
		sleep 250
		temp:=change[sn]
		click,%temp%,500
		sleep 250
		click,800,820
	}
	sleep 500
	if(st=4)
	{
		loop
		{
			if(pixc(1400,735,0x02D9F1) && pixc(1450,290,0x1A2333))
				break
			sleep 100
		}
	}
	else
	{
		loop
		{
			if(pixc(1450,290,0x1A2333) && pixc(1514,292,0xFAFFFF))
				break
			sleep 100
		}
	}
	sleep 300
}
return

;切换目标
target(n)
{
	enemy:=[ 60,360,660 ]
	temp:=enemy[n]
	click,%temp%,90
	sleep 300
}
return

;================================================================================================

;平砍n回合，直到换下一面，或战斗结束。可用于监测战斗结束状态。
xjbd(n:=0)
{
	nn:=0
	loop
	{
		;检测战利品结算界面
		if(pixc(155,150,0xE5B419) && pixc(1430,150,0x05ACF4))
			return
		;检测黑屏换面
		if(pixc(500,870,0x000000) and n>0)
			break
		;检测战斗界面是否又出现
		if(pixc(1450,290,0x1A2333) && pixc(1514,292,0xFAFFFF))
		{
			nn:=nn+1
			attack()
			if(nn=n)
				break
		}
		click,1212,121
		sleep 100
	}
	;检测回到界面
	loop
	{
		if(pixc(1400,735,0x02D9F1) && pixc(1450,290,0x1A2333))
			break
		sleep 100
	}
	sleep 300
}
return

;出3卡平砍(尽量首红)
attack()
{
	;指令卡间隔 320,319,322,325
	ccoord:=[ 213,533,852,1174,1499 ]
	click,1400,800
	sleep 500
	
	;选1张红卡，如果没有就选最后一张 
	ci:=1
	loop,5
	{
		xard:=ccoord[ci] ;213,755,0xFA3F00
		PixelSearch,x,,xard,755,xard,755,0xFA3F00,10,Fast RGB
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
		click,1450,640
	}
	sleep 150
	
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
	sleep 150
	
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
	sleep 150
	
	sleep 2000
}
return

;================================================================================================

;宝具回合出卡
baoju(n1,n2:=0,n3:=0)
{
	;打开选卡界面
	click,1400,800
	sleep 1600
	
	;第一张选卡
	if(n1)
		npc(n1)
	else
		click,480,640
	sleep 150
	
	;第二张选卡
	if(n2)
		npc(n2)
	else
		click,800,640
	sleep 150
	
	;第三张选卡
	if(n3)
		npc(n3)
	else 
		click,1120,640
	sleep 150
	
	sleep 5000
	;等待可进行下一步操作
	loop
	{
		;检测战利品结算界面
		if(pixc(155,150,0xE5B419) && pixc(1430,150,0x05ACF4))
			break
		;检测战斗界面是否又出现
		if(pixc(1400,735,0x02D9F1) && pixc(1450,290,0x1A2333))
			break
		click,1212,121
		sleep 100
	}
	sleep 300
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

;================================================================================================

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

;置顶mumu窗口
mup()
{
	if(!WinActive(ahk_exe NemuPlayer.exe))
		WinActivate, ahk_class Qt5QWindowIcon
}
return
