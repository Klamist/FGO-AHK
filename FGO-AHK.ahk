#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input ; Recommended for new scripts due to its superior speed and reliability.
SetMouseDelay, 0 ; Removed mouse delay (as fast as possible).
SetBatchLines, -1 ; Make AHK run as fast as possible

;各项的详细讲解请看《FGO-AHK参数说明》
;模拟器部分的cpx和cpy参数必须精确设置

;刷本参数
cycle:= 10 ;刷几次本
overap:= 1 ;是否清完剩余AP

;0=不吃，1=可以吃苹果
capple:= 0 ;铜
qapple:= 0 ;青
sapple:= 0 ;银
gapple:= 0 ;金
kstone:= 0 ;彩

;助战
global passby:= 0 ;0随意1必须好友
global supser:= 0 ;1奥伯龙2杀狐3术呆4自定义
global tskill:= [ 0,0,0 ] ;三个技能0随意1必须满级
global noblel:= 0 ;最低宝具等级
global scraft:= 0 ;0随意1午茶2贝拉3秉持4私人5宝石6黑杯

;选普通卡时优先颜色，1红2绿3蓝
global xcol:= 1 ;xjbd时
global bcol:= 1 ;baoju时

;模拟器
global mnq:= 0 ;自动置顶窗口，0无1mumu2雷电
global cpx:= 0 ;窗口x偏量
global cpy:= 0 ;窗口y偏量

;调试
global debug:= 0 ;输出详细日志
global wucha:= 5 ;误差



;——————战斗流程——————
order()
{
;自定义区域：






;自定义结束。

xjbd() ;补刀+结算。若最后需要补刀，可以省略，用这句就行。
}
return


;——————脚本快捷键——————
;可修改热键为F1~F12，a~z，0~9等，请修改“$~”与“::”之间的部分
;若想前置Ctrl需前置加“^”，Shift前置加“+”，Alt前置加“!”

; Ctrl + \ 退出脚本(任何时候都可以一键结束)
$~^\::ExitApp

; \ 键重置(相当于关闭脚本再打开)
$~\::Reload

; Ctrl + 0 禁用吃一切苹果 (字母P上面的数字0)
$^0::
capple:= 0
qapple:= 0
sapple:= 0
gapple:= 0
kstone:= 0
return

; ] 键暂停(从当前操作暂停，再按一次从暂停处继续)
$~]::Pause

; Alt+T键测试（请勿使用）
$!t::
{
	;global cpx:= 1
	;global cpy:= 51
	;global debug:= 1
	;what
}
return

; [ 键启动(开始循环刷本)
$~[::
{


;口口口口口口口口口口口口口口口口
;以后的代码，不建议修改，除非你懂
;口口口口口口口口口口口口口口口口


;确认模拟器窗口
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
		qapple:= 0
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
		if(pixc(1269,479,0xF1F7FA) && !apok)
		{
			sleep 200
			gosub,eat
			apok:=1
			sleep 500
		}
		if((pixc(1000,161,0x07B8F8) && pixc(1063,271,0x646464)) || pixc(878,541,0xFFFFFF))
			break
	}
	
	;挑选助战，进本等待开始
	gosub,support
	
	;记录刷本次数
	cyclist:=cyclist+1
	FormatTime,now,A_Now,HH:mm:ss
	FileAppend,%cyclist%/%cycle% %now%`n,fgo-ahk.log
	
	;按照设定好的刷本流程执行
	wstart(1)
	order()
	
	;进入结算环节，连点直到出去。
	loop
	{
		sclick(1300,780)
		sleep 200
		
		;加好友提示已满点确认
		pixc(870,704,0xD6D6D6,0,1)
		pixc(303,767,0xD5D5D5,0,1)
		
		;连续出击判定
		;imgc(985,691,1109,763,"wconti",0,2)
		if(pixc(1040,280,0xFFFFFF) && pixc(881,320,0xFFFFFF))
		{
			pixc(930,730,0xD2D2D3,1,1)
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

;图片识别，在指定区域内寻找是否存在对应图片。
;pimg文件名为H文件夹内的png图片名（不含后缀）
;pl是否循环检测，lc=1识别到后点击，lc=2循环点击直到识别不到
imgc(x1,y1,x2,y2,pimg,pl:=0,lc:=0,dv:=50)
{
	mup()
	;加入偏量
	x1:=x1+cpx
	y1:=y1+cpy
	x2:=x2+cpx
	y2:=y2+cpy
	debug_m:=1
	
	;图片文件路径完善
	pimg := A_ScriptDir . "\H\" . pimg . ".png"
	debu := Format("{1:d},{2:d},{3:d},{4:d},{5:s}",x1,y1,x2,y2,pimg)
	
	loop
	{
		ImageSearch, xtmp,, x1,y1,x2,y2, *%dv% %pimg%
		if(xtmp)
		{
			; 识别到后是否点击图片正中心位置
			if(lc)
			{
				sleep 200
				sclick( (x1+x2)//2 , (y1+y2)//2 )
				if(lc=2)
				{
					loop
					{
						sleep 600
						ImageSearch, xtmp,, x1,y1,x2,y2, *%dv% %pimg%
						if(xtmp)
							sclick( (x1+x2)//2 , (y1+y2)//2 )
						else
							break
					}
					if(debug)
						FileAppend, 点击 %debu%`n,fgo-ahk.log
					return 2
				}
			}
			if(debug)
				FileAppend, 找到 %debu%`n,fgo-ahk.log
			return 1
		}
		else if(debug && debug_m)
		{
			FileAppend, 丢了 %debu%`n,fgo-ahk.log
			debug_m:=0
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

;按青铜银金彩，依次尝试吃苹果
eat:
{
	;往下翻页
	sclick(1270,630)
	sleep 300
	;铜青银顺序检测
	if(pixc(750,570,0xF3EDDD) && capple)
	{
		sclick(750,570)
		pixc(950,720,0xDADADA,1,1)
		FileAppend,吃了铜苹果`n,fgo-ahk.log
		return
	}
	if(pixc(750,380,0xF3EDDD) && qapple)
	{
		sclick(750,380)
		pixc(950,720,0xDADADA,1,1)
		FileAppend,吃了青苹果`n,fgo-ahk.log
		return
	}
	if(pixc(750,200,0xF3EDDD) && sapple)
	{
		sclick(750,200)
		pixc(950,720,0xDADADA,1,1)
		FileAppend,吃了银苹果`n,fgo-ahk.log
		return
	}
	
	;往上翻页
	sclick(1270,220)
	sleep 300
	;金彩顺序检测
	if(pixc(750,350,0xF3EDDD) && gapple)
	{
		sclick(750,350)
		pixc(950,700,0xD5D5D5,1,1)
		FileAppend,吃了金苹果`n,fgo-ahk.log
		return
	}
	if(pixc(750,170,0xF3EDDD) && kstone)
	{
		sclick(750,170)
		pixc(950,700,0xD5D5D5,1,1)
		FileAppend,吃了彩苹果`n,fgo-ahk.log
		return
	}
	
	MsgBox 你没AP了
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
			if((pixc(1000,161,0x07B8F8) && pixc(1063,271,0x646464)) || pixc(878,541,0xFFFFFF))
				break
			sleep 100
		}
		if(supcheck())
			return
		sleep 8000
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
		ImageSearch, ,y,1025+cpx,y,1035+cpx,940, *50 %A_ScriptDir%\H\0.png
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
				ImageSearch, x,, 450+cpx,y-113,900+cpx,y-63, *60 %A_ScriptDir%\H\s1.png
				if(!x) ;奥伯龙
					continue
			}
			else if(supser=2)
			{
				ImageSearch, x,, 450+cpx,y-113,900+cpx,y-63, *60 %A_ScriptDir%\H\s2.png
				if(!x) ;杀狐
					continue
			}
			else if(supser=3)
			{
				ImageSearch, x,, 450+cpx,y-113,900+cpx,y-63, *60 %A_ScriptDir%\H\s3.png
				if(!x) ;术呆
					continue
			}
			else if(supser=4)
			{
				ImageSearch, x,, 450+cpx,y-113,900+cpx,y-63, *60 %A_ScriptDir%\H\s4.png
				if(!x) ;自定义英灵，请将某人.png挪到H文件夹并改名s4.png
					continue
			}
			;检测技能等级
			if(tskill[1] || tskill[2] || tskill[3]) ;1020,489,0xEECC99
			{
				if(tskill[1])
				{
					PixelSearch, x,,1064+cpx,y-20,1064+cpx,y-20,0XFFFFFF,10,Fast RGB
					if(!x)	;一技能 1064,444,0xFFFFFF
						continue
				}
				if(tskill[2])
				{
					PixelSearch, x,,1121+cpx,y-20,1121+cpx,y-20,0XFFFFFF,10,Fast RGB
					if(!x)	;二技能 1121,444,0xFFFFFF
						continue
				}
				if(tskill[3])
				{
					PixelSearch, x,,1177+cpx,y-20,1177+cpx,y-20,0XFFFFFF,10,Fast RGB
					if(!x)	;三技能 1177,444,0xFFFFFF
						continue
				}
			}
			;检测宝具等级
			if(noblel)
			{
				ImageSearch, x,, 450+cpx,y-68,900+cpx,y-18, *100 %A_ScriptDir%\H\n1.png
				if(x && noblel>1)
					continue
				ImageSearch, x,, 450+cpx,y-68,900+cpx,y-18, *100 %A_ScriptDir%\H\n2.png
				if(x && noblel>2)
					continue
				ImageSearch, x,, 450+cpx,y-68,900+cpx,y-18, *100 %A_ScriptDir%\H\n3.png
				if(x && noblel>3)
					continue
				ImageSearch, x,, 450+cpx,y-68,900+cpx,y-18, *100 %A_ScriptDir%\H\n4.png
				if(x && noblel>4)
					continue
				ImageSearch, x,, 450+cpx,y-68,900+cpx,y-18, *100 %A_ScriptDir%\H\n5.png
				if(x && noblel>5)
					continue
			}
		}
		;查找礼装（只找满破的）
		if(scraft)
		{
			if(scraft=1)
			{
				ImageSearch, x,, 200+cpx,y-40,280+cpx,y-5, *60 %A_ScriptDir%\H\c1.png
				if(!x) ;下午茶
					continue
			}
			else if(scraft=2)
			{
				ImageSearch, x,, 200+cpx,y-40,280+cpx,y-5, *60 %A_ScriptDir%\H\c2.png
				if(!x) ;贝拉丽莎
					continue
			}
			else if(scraft=3)
			{
				ImageSearch, x,, 200+cpx,y-40,280+cpx,y-5, *60 %A_ScriptDir%\H\c3.png
				if(!x) ;秉持风雅
					continue
			}
			else if(scraft=4)
			{
				ImageSearch, x,, 200+cpx,y-40,280+cpx,y-5, *60 %A_ScriptDir%\H\c4.png
				if(!x) ;私人指导
					continue
			}
			else if(scraft=5)
			{
				ImageSearch, x,, 150+cpx,y-50,250+cpx,y-10, *60 %A_ScriptDir%\H\c5.png
				if(!x) ;万华镜
					continue
			}
			else if(scraft=6)
			{
				ImageSearch, x,, 150+cpx,y-50,250+cpx,y-10, *60 %A_ScriptDir%\H\c6.png
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
	loop
	{
		;点击一下
		if(clc)
			sclick(1111,66)
		sleep 200
		;如果在编队界面，点击进本
		if(pixc(1460,810,0xF4F4F3) && pixc(1570,837,0x06DFFC) && cyclist=1)
			sclick(1460,812)
		;检测出击按钮
		if(pixc(1400,681,0x00E9FA) && pixc(1450,257,0x1B2234) && pixc(1513,255,0xE3FFFF))
			return
		;检测战利品结算界面
		if(pixc(151,62,0xECBD2A) && pixc(1433,66,0x08B4F5))
			return
	}
}


;================================================================================================

;从者放技能
ssk(si,st:=0)
{
	if(si>9 || si<0)
	{
		MsgBox 从者技能参数异常,请检查ssk(%si%...)
		Exit
	}
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
	wstart(1)
sleep 100
}
return

;御主放技能
msk(sk,st:=0,sm:=0,sn:=0)
{
	if(sk>4 || sk<0)
	{
		MsgBox 御主技能参数异常,请检查msk(%sk%...)
		Exit
	}
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
		sleep 300
		temp:=change[sm]
		sclick(temp,464)
		sleep 400
		temp:=change[sn]
		sclick(temp,464)
		sleep 400
		sclick(800,784)
	}
	sleep 100
	
	;等待回到操作界面
	wstart(1)
sleep 100
}
return

;切换目标
target(n)
{
	enemy:=[ 170,430,680, 170,430,680 ]
	temp:=enemy[n]
	if(n<4)
		sclick(temp,50)
	if(n>3)
		sclick(temp,160)
	sleep 300
}
return

;================================================================================================

;平砍n回合，直到换下一面，或战斗结束。可用于监测战斗结束状态。
;col，优先选什么色卡
xjbd(n:=0,col:=1)
{
	nn:=0
	loop
	{
		sleep 200
		;检测战利品结算界面
		if(pixc(151,62,0xEEC62D) && pixc(1433,66,0x08B7F1))
			return
		;检测黑屏换面
		if(pixc(500,834,0x000000) && pixc(1500,80,0x000000) && n>0)
			break
		;检测战斗界面是否又出现
		if(pixc(1400,681,0x00E9FA) && pixc(1450,257,0x1B2234) && pixc(1513,255,0xE3FFFF))
		{
			;点击攻击按钮
			sclick(1400,760)
			sleep 600
			if(pixc(1400,681,0x00E9FA) && pixc(1450,257,0x1B2234) && pixc(1513,255,0xE3FFFF))
			{
				sclick(1400,760)
				sleep 600
			}
			attack(xcol,3,1)
			sleep 2000
			
			nn:=nn+1
			if(nn=n)
				break
		}
		;点击一下
		sclick(1111,66)
	}
	;等待回到操作界面
	wstart(1)
	sleep 600
}
return

;出cn张卡平砍(优先卡色，1=红，2=绿，3=蓝)
attack(col,cn:=1,rep:=0)
{
	;尽量选对应颜色卡
	scard:=[ 0,0,0,0,0 ]
	ccoord:=[ 200,500,800,1100,1400 ]
	selnum:=0
	loop
	{
		ctmp:= acard(col,1)
		if(ctmp)
		{
			selnum:= selnum + 1
			scard[ctmp]:= 1
		}
		else
		{
			col:=col+1
			if(col>3)
				col:=1
		}
		if(selnum=cn)
			break
	}

	;以防漏选，补一张
	if(rep)
	{
		ci:=1
		loop
		{
			if(scard[ci])
			{
				sclick(ccoord[ci],700)
				break
			}
		}
	}

	return
}

;查找普攻色卡，1红2绿3蓝。找到该色卡返回位置(1~5)，没选到返回0。clc是否点击
acard(col:=1,clc:=0)
{
	;指令卡间隔 320,319,322,325
	ccoord:=[]
	ccoord[1]:=[ 213,533,852,1174,1499 ] ;红
	ccoord[2]:=[ 216,536,855,1177,1502 ] ;绿
	ccoord[3]:=[ 215,535,854,1176,1501 ] ;蓝
	cardcolor:=[ 0xF4420B,0x9AE11A,0x27A1D9 ]
	
	ci:=1
	loop,5
	{
		xard:=ccoord[col][ci]
		PixelSearch,x,,xard+cpx,722+cpy,xard+cpx,722+cpy,cardcolor[col],20,Fast RGB
		if(x)
		{
			if(clc)
			{
				sclick(xard,700)
				sleep 200
			}
			return ci
		}
		ci:=ci+1
	}
	return 0
}

;================================================================================================

;宝具回合出卡
baoju(n1,n2:=0,n3:=0)
{
	npcard:=[ 480,800,1120 ]

	;打开选卡界面
	sclick(1400,760)
	sleep 1000
	
	;第一张选卡
	if(n1)
	{
		sclick(npcard[n1],250)
		sleep 200
	}
	else
		attack(bcol,1)
	
	;第二张选卡
	if(n2)
	{
		sclick(npcard[n2],250)
		sleep 200
	}
	else
		attack(bcol,1)
	
	;第三张选卡
	if(n3)
	{
		sclick(npcard[n3],250)
		sleep 200
	}
	else 
		attack(bcol,1)
	
	;等待回到操作界面
	wstart(1)
	sleep 100
	return
}

;================================================================================================

;检测模拟器窗口
checkmnq:
{
	if(mnq=1)
	{
		if(!WinActive("ahk_exe NemuPlayer.exe") and !WinActive("ahk_exe MuMuPlayer.exe"))
		{
			msgbox 未发现mumu窗口，若不需要自动置顶窗口请将mnq:=0
			exit
		}
	}
	else if(mnq=2)
	{
		if(!WinActive("ahk_exe dnplayer.exe"))
		{
			msgbox 未发现雷电窗口，若不需要自动置顶窗口请将mnq:=0
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
		else if(!WinActive("ahk_exe MuMuPlayer.exe"))
		WinActivate, ahk_class Qt5156QWindowIcon
	}
	else if(mnq=2)
	{
		if(!WinActive("ahk_exe dnplayer.exe"))
		WinActivate, ahk_class LDPlayerMainFrame
	}
}
return
