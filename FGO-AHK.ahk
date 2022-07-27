#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input ; Recommended for new scripts due to its superior speed and reliability.
SetMouseDelay, 0 ; Removed mouse delay (as fast as possible).
SetBatchLines, -1 ; Make AHK run as fast as possible

;各项的详细讲解请看《FGO-AHK参数说明》
;模拟器部分的cpx和cpy参数必须精确设置

;刷本参数
cycle:= 10 ;刷几次本
overap:= 1 ;是否清完剩余AP

;允许吃苹果
capple:= 0 ;铜
sapple:= 0 ;银
gapple:= 0 ;金
kstone:= 0 ;彩

;助战
global passby:= 0 ;好友
global supser:= 0 ;1斯卡蒂2杀狐3术呆4自定义
global tskill:= [ 0,0,0 ] ;技能
global noblel:= 0 ;宝具
global scraft:= 0 ;1午茶2贝拉3秉持4私人5宝石6黑杯

;附加功能
global debug:= 0 ;调试
global wucha:= 5 ;误差

;模拟器
global mnq:= 0 ;置顶0无1mumu2雷电
global cpx:= 0 ;窗口x偏量
global cpy:= 0 ;窗口y偏量


;——————战斗流程——————
order()
{
;自定义区域：






;自定义结束。
;不要修改自定义以外的部分！

xjbd() ;补刀+结算。若最后需要补刀，可以省略，用这句就行。
}
return


;——————脚本快捷键——————
;可修改热键为F1~12，a~z，0~9等，请修改“$~”与“::”之间的部分
;若想前置Ctrl需前置加“^”，Shift前置加“+”，Alt前置加“!”

; Ctrl + \ 退出脚本(任何时候都可以一键结束进程)
$~^\::ExitApp

; \ 键重置(相当于关闭脚本再打开)
$~\::Reload

; Ctrl + 0 键 禁用吃苹果
$^0::
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
mup()
sleep 300
gosub,checkmnq
gosub,himg

;生成日志记录
FormatTime,now,A_Now,yyyy-MM-dd HH:mm:ss
FileAppend,`n%now%`n%A_ScriptName%`n,fgo-ahk.log
;刷本次数记录
global cyclist:=0

;如果在副本选择界面，点击第一位的副本
if(pixc(1560,817,0xD2D3D4))
	sclick(900,260)

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
		;服务器断开010101自动重连
		if(pixc(955,704,0xD1D1D2) && pixc(1204,500,0xFFFFFF))
			sclick(955,704)
		if(pixc(1269,480,0xECEDF5) && !apok)
		{
			sleep 200
			gosub,eat
			apok:=1
			sleep 500
		}
		if((pixc(1000,161,0x02B7F1) && pixc(1063,271,0x626262)) || pixc(878,541,0xFFFFFF))
			break
	}
	
	;挑选助战，进本等待开始
	gosub,support
	
	;记录刷本次数
	cyclist:=cyclist+1
	FormatTime,now,A_Now,HH:mm:ss
	FileAppend,%cyclist%/%cycle% %now%`n,fgo-ahk.log
	
	;按照设定好的刷本流程执行
	wstart()
	order()
	
	;进入结算环节，连点直到出去。
	loop
	{
		sclick(1300,780)
		sleep 200
		
		;加好友提示已满点确认
		pixc(870,704,0xD3D4D4,0,1)
		pixc(303,767,0xD4D4D4,0,1)
		
		;服务器断开010101自动重连
		if(pixc(955,704,0xD1D1D2) && pixc(1204,500,0xFFFFFF))
			sclick(955,704)
		
		;连续出击判定
		if(pixc(1040,290,0xFFFFFF))
		{
			pixc(930,708,0xD1D1D2,1,1)
			break
		}
	}
}
MsgBox 打完了！
}
return

;================================================================================================

;循环探测指定像素点颜色，pl是否循环，lc=识别到后是否单击这个像素
pixc(x,y,kolor,pl:=0,lc:=0)
{
	mup()
	;加入偏量
	x:=x+cpx
	y:=y+cpy
	;调试模式：记录要求的像素点
	if(debug)
	{
		dpix:=0x307521
		dpn:=Format("{1:4d},{2:4d},0x{3:06X}",x-cpx,y-cpy,kolor)
		FileAppend,%dpn%`n,fgo-ahk.log
	}
	loop
	{
		PixelSearch,xtmp,,x,y,x,y,kolor,wucha,Fast RGB
		if(xtmp)
		{
			if(debug)
			{
				PixelGetColor,pix,x,y,RGB
				;记录匹配到的颜色
				dpn:=Format("oooo,oooo,0x{3:06X}",x,y,pix)
				FileAppend,%dpn%`n,fgo-ahk.log
			}
			if(lc)
			{
				sleep 300
				click,%x%,%y%
				if(pl)
				{
					loop
					{
						sleep 700
						PixelSearch,xtmp,,x,y,x,y,kolor,wucha,Fast RGB
						if(xtmp)
							click,%x%,%y%
						else
							break
					}
				}
			}
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
			sleep 400
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

;================================================================================================

;按铜银金彩，依次尝试吃苹果
eat:
{
	if(pixc(750,711,0xF4ECDB) && capple)
	{
		sclick(750,711)
		pixc(950,700,0xD4D5D5,1,1)
		FileAppend,吃了铜苹果`n,fgo-ahk.log
		return
	}
	else if(pixc(750,526,0xF4ECDB) && sapple)
	{
		sclick(750,526)
		pixc(950,700,0xD4D5D5,1,1)
		FileAppend,吃了银苹果`n,fgo-ahk.log
		return
	}
	else if(pixc(750,342,0xF4ECDB) && gapple)
	{
		sclick(750,342)
		pixc(950,700,0xD4D5D5,1,1)
		FileAppend,吃了金苹果`n,fgo-ahk.log
		return
	}
	else if(pixc(750,158,0xF4ECDB) && kstone)
	{
		sclick(750,158)
		pixc(950,700,0xD4D5D5,1,1)
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
	if(supcheck())
		return
	;如果没有，刷新再找
	loop
	{
		sclick(1160,170)
		sleep 700
		sclick(1047,709)
		loop
		{
			;服务器断开010101自动重连
			if(pixc(955,704,0xD1D1D2) && pixc(1204,500,0xFFFFFF))
				sclick(955,704)
			
			if((pixc(1000,161,0x02B7F1) && pixc(1063,271,0x626262)) || pixc(878,541,0xFFFFFF))
				break
			sleep 100
		}
		if(supcheck())
			return
		sleep 10000
	}
	MsgBox 助战丢了！
	Exit
}
return

;助战列表自动翻页检测
supcheck()
{
	if(pixc(878,541,0xFFFFFF))
		return 0
	if(ncheck())
		return 1
	spy:=239
	loop,6
	{
		spy:=spy+101
		sclick(1570,spy)
		sleep 200
		if(ncheck())
			return 1
	}
	return 0
}

;检测本页助战
ncheck()
{
	y:=cpy+100
	loop
	{
		y:=y+200
		;扫描从者栏位
		ImageSearch, ,y,1025+cpx,y,1035+cpx,940, *50 %A_WorkingDir%\H\0.png
		if(!y)
			return 0
		;检测是否好友
		if(passby)
		{
			PixelSearch, x,,1434+cpx,y-55,1434+cpx,y-55,0xE0F9A6,20,Fast RGB
			if(!x) ;515, 1433,471,0xBCEE72
				continue
		}
		;匹配英灵
		if(supser)
		{
			if(supser=1)
			{
				ImageSearch, x,, 450+cpx,y-113,900+cpx,y-63, *100 %A_WorkingDir%\H\s1.png
				if(!x) ;CBA
					continue
			}
			else if(supser=2)
			{
				ImageSearch, x,, 450+cpx,y-113,900+cpx,y-63, *100 %A_WorkingDir%\H\s2.png
				if(!x) ;杀狐
					continue
			}
			else if(supser=3)
			{
				ImageSearch, x,, 450+cpx,y-113,900+cpx,y-63, *100 %A_WorkingDir%\H\s3.png
				if(!x) ;术呆
					continue
			}
			else if(supser=4)
			{
				ImageSearch, x,, 450+cpx,y-113,900+cpx,y-63, *100 %A_WorkingDir%\H\s4.png
				if(!x) ;自定义英灵，请将某人.png挪到H文件夹并改名s4.png
					continue
			}
			;检测技能等级
			if(tskill[1] || tskill[2] || tskill[3]) ;1020,489,0xEECC99
			{
				if(tskill[1])
				{
					PixelSearch, x,,1073+cpx,y-20,1073+cpx,y-20,0XFFFFFF,10,Fast RGB
					if(!x)	;一技能 108,469,0xFFFFFF
						continue
				}
				if(tskill[2])
				{
					PixelSearch, x,,1129+cpx,y-20,1129+cpx,y-20,0XFFFFFF,10,Fast RGB
					if(!x)	;二技能 1176,469,0xFFFFFF
						continue
				}
				if(tskill[3])
				{
					PixelSearch, x,,1185+cpx,y-20,1185+cpx,y-20,0XFFFFFF,10,Fast RGB
					if(!x)	;三技能 1273,469,0XFFFFFF
						continue
				}
			}
			;检测宝具等级
			if(noblel && passby)
			{
				ImageSearch, x,, 450+cpx,y-68,900+cpx,y-18, *100 %A_WorkingDir%\H\n1.png
				if(x && noblel>1)
					continue
				ImageSearch, x,, 450+cpx,y-68,900+cpx,y-18, *100 %A_WorkingDir%\H\n2.png
				if(x && noblel>2)
					continue
				ImageSearch, x,, 450+cpx,y-68,900+cpx,y-18, *100 %A_WorkingDir%\H\n3.png
				if(x && noblel>3)
					continue
				ImageSearch, x,, 450+cpx,y-68,900+cpx,y-18, *100 %A_WorkingDir%\H\n4.png
				if(x && noblel>4)
					continue
				ImageSearch, x,, 450+cpx,y-68,900+cpx,y-18, *100 %A_WorkingDir%\H\n5.png
				if(x && noblel>5)
					continue
			}
		}
		;查找礼装（只找满破的）
		if(scraft)
		{
			if(scraft=1)
			{
				ImageSearch, x,, 200+cpx,y-40,280+cpx,y-5, *100 %A_WorkingDir%\H\c1.png
				if(!x) ;下午茶
					continue
			}
			else if(scraft=2)
			{
				ImageSearch, x,, 200+cpx,y-40,280+cpx,y-5, *100 %A_WorkingDir%\H\c2.png
				if(!x) ;贝拉丽莎
					continue
			}
			else if(scraft=3)
			{
				ImageSearch, x,, 200+cpx,y-40,280+cpx,y-5, *100 %A_WorkingDir%\H\c3.png
				if(!x) ;秉持风雅
					continue
			}
			else if(scraft=4)
			{
				ImageSearch, x,, 200+cpx,y-40,280+cpx,y-5, *100 %A_WorkingDir%\H\c4.png
				if(!x) ;私人指导
					continue
			}
			else if(scraft=5)
			{
				ImageSearch, x,, 150+cpx,y-50,250+cpx,y-10, *100 %A_WorkingDir%\H\c5.png
				if(!x) ;万华镜
					continue
			}
			else if(scraft=6)
			{
				ImageSearch, x,, 150+cpx,y-50,250+cpx,y-10, *100 %A_WorkingDir%\H\c6.png
				if(!x) ;黑杯
					continue
			}
		}
		y:=y-30-cpy
		sclick(1000,y)
		if(cyclist)
		{
			loop,4
			{
				sleep 500
				sclick(1000,y)
			}
		}
		return 1
	}
}

;================================================================================================

;检测可以开始行动，clc是否自动连点
wstart(clc:=0)
{
	res:=0 ;重启标记
	loop
	{
		;点击一下
		if(clc)
			sclick(1111,66)
		sleep 200
		;如果在编队界面，点击进本
		if(pixc(1460,812,0xF0F0F0))
			sclick(1460,812)
		;检测出击按钮
		if(pixc(1400,681,0x02E9F9) && pixc(1450,257,0x1A2333))
		{
			if(res)
				return 1
			else
				return 0
		}
		;检测战利品结算界面
		if(pixc(151,62,0xEEC529) && pixc(1433,66,0x02B7F9))
			return 0
		;雷电模拟器防闪退专用
		if(pixc(800,50,0x212121) && pixc(430,160,0xF4C51F) && mnq=2)
		{
			ldres()
			res:=1
		}
		;服务器断开010101自动重连
		if(pixc(955,704,0xD1D1D2) && pixc(1204,500,0xFFFFFF))
			sclick(955,704)
	}
}

;雷电模拟器闪退后重启
ldres()
{
	sleep 500
	ImageSearch, x,y,130,110,1440,450, *50 %A_WorkingDir%\H\fgo.png
	click,%x%,%y%
	sleep 1000
	loop
	{
		sclick(1111,66)
		sleep 300
		if(pixc(619,469,0xFF0000) && pixc(1019,469,0xFF0000))
		{
			sleep 300
			sclick(1100,690)
			break
		}
	}
}
return

;================================================================================================

;从者放技能
ssk(si,st:=0)
{
loop
{
	if(si>9 || si<0)
		MsgBox 从者技能参数异常,请检查ssk(%si%...)
	skc:=[ 80,200,320, 480,600,720, 880,1000,1120 ]
	skt:=[ 400,800,1200 ]
	;技能位置
	temp:=skc[si]
	sclick(temp,720)
	sleep 250
	;指向位置
	if(st)
	{
		temp:=skt[st]
		sclick(temp,560)
	}
	sleep 100
	;等待回到操作界面
	if(wstart(1)=0)
		break
}
sleep 100
}
return

;御主放技能
msk(sk,st:=0,sm:=0,sn:=0)
{
loop
{
	if(sk>4 || sk<0)
		MsgBox 御主技能参数异常,请检查msk(%sk%...)
	skc:=[ 1130,1240,1350 ]
	skt:=[ 400,800,1200 ]
	change:=[ 170,420,670, 920,1170,1420 ]
	;御主面板
	sclick(1500,394)
	sleep 400
	;技能位置
	temp:=skc[sk]
	sclick(temp,394)
	sleep 300
	;指向位置
	if(st && st<4)
	{
		temp:=skt[st]
		sclick(temp,600)
	}
	else if(st=4)
	{
		sleep 200
		temp:=change[sm]
		sclick(temp,464)
		sleep 300
		temp:=change[sn]
		sclick(temp,464)
		sleep 300
		sclick(800,784)
	}
	sleep 100
	;等待回到操作界面
	if(wstart(1)=0)
		break
}
sleep 100
}
return

;切换目标
target(n)
{
	enemy:=[ 60,370,680 ]
	temp:=enemy[n]
	sclick(temp,50)
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
		sleep 200
		;检测战利品结算界面
		if(pixc(151,62,0xEEC529) && pixc(1433,66,0x02B7F9))
			return
		;检测黑屏换面
		if(pixc(500,834,0x000000) && n>0)
			break
		;检测战斗界面是否又出现
		if(pixc(1450,257,0x1A2333) && pixc(1514,251,0xD6EFF2))
		{
			nn:=nn+1
			attack()
			if(nn=n)
				break
		}
		;雷电模拟器防闪退专用
		if(pixc(800,50,0x212121) && pixc(430,160,0xF4C51F) && mnq=2)
		{
			ldres()
			nn:=nn-1
		}
		;点击一下
		sclick(1111,66)
	}
	;等待回到操作界面
	loop
	{
		if(wstart(1))
			attack()
		else
			break
	}
	sleep 600
}
return

;出3卡平砍(尽量首红)
attack()
{
	;指令卡间隔 320,319,322,325
	ccoord:=[ 213,533,852,1174,1499 ]
	sclick(1400,760)
	sleep 500
	
	;选1张红卡，如果没有就选最后一张 
	ci:=1
	loop,5
	{
		xard:=ccoord[ci] ;1174,720,0xFA3F00
		PixelSearch,x,,xard+cpx,720+cpy,xard+cpx,720+cpy,0xFA3F00,10,Fast RGB
		if(x)
		{
			sclick(xard,630)
			break
		}
		ci:=ci+1
	}
	if(ci=6)
	{
		ci:=5
		sclick(1450,630)
	}
	sleep 200
	
	;补选其他两张卡
	cj:=1
	loop,5
	{
		if(cj!=ci)
		{
			temp:=ccoord[cj]
			sclick(temp,630)
			break
		}
		cj:=cj+1
	}
	sleep 200
	
	ck:=cj+1
	loop,4
	{
		if(ck!=ci)
		{
			temp:=ccoord[ck]
			sclick(temp,630)
			break
		}
		ck:=ck+1
	}
	sleep 200
	
	;防止没点到某张卡，再点一次
	sleep 500
	cr:=ck+1
	loop,3
	{
		if(cr!=ci)
		{
			temp:=ccoord[cr]
			sclick(temp,630)
			break
		}
		cr:=cr+1
	}
	sleep 2000
}
return

;================================================================================================

;宝具回合出卡
baoju(n1,n2:=0,n3:=0)
{
loop
{
	;打开选卡界面
	sclick(1400,760)
	sleep 800
	if(mnq=1)
		sleep 200
	
	;第一张选卡
	if(n1)
		npc(n1)
	else
		sclick(480,630)
	sleep 200
	
	;第二张选卡
	if(n2)
		npc(n2)
	else
		sclick(800,630)
	sleep 200
	
	;第三张选卡
	if(n3)
		npc(n3)
	else 
		sclick(1120,630)
	sleep 200
	
	;防止没点到某张卡，再点一次
	sleep 500
	sclick(1440,630)
	
	;等待回到操作界面
	if(wstart(1)=0)
		break
}
sleep 100
}
return

;选一个宝具卡
npc(n)
{
	npcard:=[ 480,800,1120 ]
	temp:=npcard[n]
	sclick(temp,270)
}
return

;================================================================================================

;检测模拟器窗口
checkmnq:
{
	if(mnq=1)
	{
		if(!WinActive("ahk_exe NemuPlayer.exe"))
		{
			msgbox 未发现mumu窗口
			exit
		}
	}
	else if(mnq=2)
	{
		if(!WinActive("ahk_exe dnplayer.exe"))
		{
			msgbox 未发现雷电窗口
			exit
		}
	}
}
return

;检测《H》文件夹是否存在
himg:
{
	if !FileExist("H\0.png")
	{
		msgbox 无法识别《H》的文件
		exit
	}
}
return

;置顶mumu窗口
mup()
{
	if(mnq=1)
	{
		if(!WinActive("ahk_exe NemuPlayer.exe"))
		WinActivate, ahk_class Qt5QWindowIcon
	}
	else if(mnq=2)
	{
		if(!WinActive("ahk_exe dnplayer.exe"))
		WinActivate, ahk_class LDPlayerMainFrame
	}
}
return