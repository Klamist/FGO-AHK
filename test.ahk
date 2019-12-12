#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input ; Recommended for new scripts due to its superior speed and reliability.
SetMouseDelay, 0

;——————狂兰绿卡冲浪——————
;窗口要求：1600x900分辨率的MUMU模拟器初始大窗口
;队伍配置：满破宝石，双CBA，2004服。打手站左侧，中间、右侧站CBA。请提前编队设置好
;伤害要求：不用垫刀，前两面补刀要求低（会挑狂兰卡，但最惨双CBA白字补刀1~2W，只能解决剩一丝血皮）
;头像要求：请在个人空间、游戏设置，去掉助战再临状态展示。打手和CBA指令卡面均用3破。

;——————可调节参数——————
cycle:= 50 ;总共刷几次本
secdd:= 0 ;第二面单CBA降防，0=不开，1=开

usuit:= 3 ;助战CBA礼装，0=任意，1=迦勒底的午餐，2=蒙娜丽莎，3=活动礼装
obreak:= 1 ;礼装满破情况，0=随意，1=必须满破
passby:= 0 ;助战来源，0=仅好友，1=好友路人都行(选路人过本后自动申请好友)
tskill:= 2 ;CBA技能，0=随意，1=全满10级，2=绿魔放+充能满级，3=仅充能满级

capple:= 0 ;铜苹果，0=禁用，1=可用
sapple:= 0 ;银苹果，0=禁用，1=可用
gapple:= 1 ;金苹果，0=禁用，1=可用
stone:= 1 ;彩苹果，0=禁用，1=可用

;——————自动刷本循环——————
;1. free本选择界面，选择列表第一行的副本（打本结束后，此本仍位于第一行）
;2. 进本时如果需要吃苹果，则按“铜-银-金-彩”的顺序尝试吃苹果
;3. 助战从术阶，选取符合要求的CBA。没找到自动刷新再找，最多尝试5次
;4. 第一回合：双绿魔放，礼装黄金律，开宝具
;5. 第二回合：充50，狂兰黄金律，CBA可选降防，开宝具
;6. 第三回合：各种BUFF全开，开宝具
;7. 若没打死，进4T补刀。过本结算后，回到free本选择界面

;口口口口口口口口口口口口口口口口口口口
;不建议修改之后的代码，除非你感觉自己懂
;口口口口口口口口口口口口口口口口口口口

; Ctrl + \ 退出脚本
$~^\::ExitApp

; \ 键重置
$~\::Reload

; ] 键暂停
$~]::Pause

; [ 键启动:
$~[::
gosub,mumu
	FormatTime,now,A_Now,yyyy-MM-dd HH:mm:ss
	FileAppend,`n%now%`n%A_ScriptName%`n,quick.log
	cyclist:=0
loop ,%cycle%
{
	;等待检测处于free本选择界面
	pixc(100,60,0XF6F6F6,1)
	
	;点击副本
	click,900,300
	
	;检测吃苹果界面，或助战选择界面
	loop
	{
		sleep 100
		if(pixc(1270,400,0xE4E4ED))
		{
			gosub,eat
			pixc(800,300,0xECF4FC,1)
			break
		}
		if(pixc(800,300,0xECF4FC))
			break
	}
	
	;从助战列表挑选CBA
	loop
	{
		click,540,200 ;切术阶
		sleep 200
		if(support(usuit,obreak,passby,tskill))
			break
		;如果没有，刷新再找，重复50次
		loop,50
		{
			click,1050,200
			sleep 500
			click,1050,740
			pixc(800,300,0xECF4FC,1)
			if(support(usuit,obreak,passby,tskill))
				break 2
			sleep 10000
		}
		MsgBox 你CBA没了！
		exit
	}
	
	;选到CBA进本，等待开始战斗
	pixc(1500,850,0xF7F7F7,1,1)
	cyclist:=cyclist+1
	FormatTime,now,A_Now,HH:mm:ss
	FileAppend,%cyclist%/%cycle% %now%`n,quick.log
	sleep 5000
	
	;第一回合
	gosub,wstart
	;绿魔放
	click,480,750
	sleep 200
	click,400,600
	gosub,wskill
	;绿魔放
	click,880,750
	sleep 200
	click,400,600
	gosub,wskill
	;礼装P
	click,1500,430
	sleep 300
	click,1350,430
	sleep 200
	click,400,600
	gosub,wskill
	;选卡出击
	click,1400,800
	sleep 1400
	click,480,300
	sleep 140
	gosub,blcard
	sleep 15000

	;第二回合
	gosub,wskill
	;狂兰黄金律
	click,320,750
	gosub,wskill
	;CBA充能
	click,720,750
	sleep 200
	click,400,600
	gosub,wskill
	;CBA降防
	if(secdd=1)
	{
		click,600,750
		gosub,wskill
	}
	;选卡出击
	click,1400,800
	sleep 1400
	click,480,300
	sleep 140
	gosub,blcard
	sleep 15000

	;第三回合
	gosub,wskill
	;CBA充能
	click,1120,750
	sleep 200
	click,400,600
	gosub,wskill
	;礼装P
	click,1500,430
	sleep 300
	click,1130,430
	sleep 200
	click,400,600
	gosub,wskill
	;CBA降防
	if(secdd=0)
	{
		click,600,750
		gosub,wskill
	}
	;CBA降防
	click,1000,750
	gosub,wskill
	;选卡出击
	click,1400,800
	sleep 1400
	click,480,300
	sleep 140
	gosub,blcard
	sleep 15000
	
	;检测是否需要补刀，战斗结束则进入结算环节。
	loop
	{
		;检测羁绊结算界面
		if(pixc(130,270,0xE5BB1F))
			break
		;检测战斗界面御主栏位是否又出现
		if(pixc(1560,190,0xFED71E))
			gosub,tadd
		sleep 100
	}
	
	;进入结算环节，连点直到出去。
	loop
	{
		click,1300,845
		pixc(870,740,0XD6D6D6,0,1)
		if(pixc(800,50,0x000000))
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

;等待御主栏出现，可以继续行动
wskill:
	sleep 500
	pixc(1560,190,0xFED71E,1)
	sleep 50
return

;等待attack按钮出现，仅开场时使用
wstart:
	sleep 500
	pixc(1400,700,0x0DBFDD,1)
	sleep 50
return

;选CBA+狂兰卡
blcard:
{
	;选1张狂兰卡，如果找不到狂兰卡就选最后一张
	xard:=110
	loop,5
	{
		if(pixc(xard,590,0X4A4A73,0,1))
			break
		xard:=xard+320
	}
	if(xard=1710)
		click 1430,640
	sleep 140
	;选1张CBA卡，如果找不到CBA卡就选最后一张
	xard:=149
	loop,5
	{
		if(pixc(xard,640,0XFFF7E3,0,1))
			break
		xard:=xard+320
	}
	if(xard=1749)
		click 1430,640
}
return

;助战列表自动翻页检测，检测内容：CBA
support(us,ob,pb,ts)
{
	if(cba(us,ob,ts))
		return 1
	spy:=280
	pb:=pb*3+3
	loop,%pb%
	{
		spy:=spy+100
		click 1550,%spy%
		sleep 200
		if(cba(us,ob,ts))
			return 1
	}
	return 0
}

;检测本页CBA
cba(us,ob,ts)
{
	y:=200
	loop
	{
		y:=y+10
		PixelSearch, x,y,131,y,131,920,0xB77DD3,5,Fast RGB
		if(!y)		;CBA 131,681,0XB57BD1
			return 0
		if(us)
		{
			PixelSearch, x,,127,y+20,127,y+20,0xF9D8D8,10,Fast RGB
			if(!x and us=1)	;下午茶 127,701,0xF9D8D8
				continue
			PixelSearch, x,,240,y+30,240,y+30,0X405090,20,Fast RGB
			if(!x and us=2)	;QP 240,461,0x355294
				continue
			PixelSearch, x,,200,y+40,200,y+40,0XE29787,20,Fast RGB
			if(!x and us=3)	;BIN 131,289,0XB77DD3  200,329,0XE29787
				continue
			PixelSearch, x,,240,y+50,240,y+50,0xFFFF60,30,Fast RGB
			if(!x and ob)	;满破 240,481,0XFFFF51
				continue
		}
		if(ts)
		{
			PixelSearch, x,,1079,y+45,1079,y+45,0XFFFFFF,10,Fast RGB
			if(!x and ts<3)	;一技能 1079,726,0XFFFFFF
				continue
			PixelSearch, x,,1176,y+45,1176,y+45,0XFFFFFF,10,Fast RGB
			if(!x and ts=1)	;二技能 1176,726,0XFFFFFF
				continue
			PixelSearch, x,,1273,y+45,1273,y+45,0XFFFFFF,10,Fast RGB
			if(!x)	;三技能 1273,726,0XFFFFFF
				continue
		}
		click,900,%y%
		return 1
	}
}

;按铜银金彩，依次尝试吃苹果
eat:
{
	if(pixc(750,745,0xF4ECDB) and capple)
	{
		click,750,745
		sleep 400
		click,1050,740
		FileAppend,吃了铜苹果`n,quick.log
		return
	}
	if(pixc(750,560,0xF4ECDB) and sapple)
	{
		click,750,560
		sleep 400
		click,1050,740
		FileAppend,吃了银苹果`n,quick.log
		return
	}
	if(pixc(750,375,0xF4ECDB) and gapple)
	{
		click,750,375
		sleep 400
		click,1050,740
		FileAppend,吃了金苹果`n,quick.log
		return
	}
	if(pixc(750,190,0xF4ECDB) and stone)
	{
		click,750,190
		sleep 400
		click,1050,740
		FileAppend,吃了彩苹果`n,quick.log
		return
	}
	MsgBox 你没AP了！
	exit
}

;3T之后的残余补刀发卡
tadd:
{
	click,1400,800
	sleep 500
	click,480,650
	sleep 140
	click,800,650
	sleep 140
	click,1120,650
	sleep 1000
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
