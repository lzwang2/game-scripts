#Requires AutoHotkey v2.0
#Include utils/Tools.ahk
#Include utils/PrepareWindow.ahk

; https://github.com/iseahound/ImagePut/blob/master/README.md

; 获取窗口句柄
hWnd := PrepareWindow()


MouseMove 362, 771 ; 确定
Sleep 800
Click
Sleep 1000

MouseMove 362, 771 ; 确定
Sleep 800
Click
Sleep 2000

MouseMove 362, 941 ; 下一步
Sleep 800
Click
Sleep 1000

MouseMove 492, 941 ; 下一步
Sleep 800
Click
Sleep 1000

MouseMove 500, 800 ; 获得
Sleep 800
Click
Sleep 3000

MouseMove 676, 39 ; 跳过
Sleep 800
Click
Sleep 2000

MouseMove 374, 773 ; 确定
Sleep 800
Click
Sleep 1000

MouseMove 224, 959 ; 编队
Sleep 800
Click
Sleep 1000

MouseMove 371, 778 ; 确定
Sleep 800
Click
Sleep 1000

MouseMove 524, 394 ; 部署角色
Sleep 800
Click
Sleep 1000

MouseMove 192, 431
Sleep 800
Click
Sleep 1000


MouseMove 223, 523 ; 装备圣物
Sleep 800
Click
Sleep 1000

MouseMove 180, 446
Sleep 800
Click
Sleep 1000

MouseMove 353, 775 ; 确定
Sleep 800
Click
Sleep 3000


MouseMove 120,950 ; 主页
Sleep 800
Click
Sleep 1000

MouseMove 367,764 ; 确定
Sleep 800
Click
Sleep 6000

Click

MouseMove 367,850 ; ok
Sleep 1500
Click
Sleep 2000

Send "{Esc}"
Sleep 1000
Send "{Esc}"
Sleep 1000
Send "{Esc}"
Sleep 3000

Send "{Esc}"
Sleep 800
Send "{Esc}"
Sleep 800


MouseMove 682,134 ; 礼物图标
Sleep 800
Click
Sleep 1000

MouseMove 545,132 ; 一键领取
Sleep 800
Click
Sleep 2000

MouseMove 364,784 ; 一键领取关闭
Sleep 800
Click
Sleep 1000

MouseMove 120,950 ; 主页
Sleep 800
Click
Sleep 1000

MouseMove 682,201 ; 持有物
Sleep 800
Click
Sleep 1000

MouseMove 585,420 ; 角色兑换券
Sleep 800
Click
Sleep 1000

MouseMove 485,800 ; 使用
Sleep 800
Click
Sleep 6000

MouseMove 370,738 ; 扭蛋
Sleep 800
Click
Sleep 1000

MouseMove 555,349 ; 扭蛋
Sleep 800
Click
Sleep 1000

MouseMove 373,627 ; 确定
Sleep 800
Click
Sleep 2000

; MouseMove 507,985 ; 扭蛋
; Sleep 800
; Click
; Sleep 2000

; MouseMove 371,722 ; 抽
; Sleep 800
; Click
; Sleep 10000

MouseMove 676, 57 ; 跳过
Sleep 800
Click
Sleep 2000

ExitApp
