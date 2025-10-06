#Requires AutoHotkey v2.0
#Include utils/ImagePut.ahk

; 对齐窗口位置和大小
window_x := 1174
window_y := 3
window_w := 750
window_h := 1040

; 定义所有坐标的 Map
coords := Map()
; coords["no_room"] := {x1: 253, y1: 437, x2: 484, y2: 559}
; coords["welcome"] := {x1: 464, y1: 365, x2: 613, y2: 395}
; coords["prepare_page"] := {x1: 108, y1: 107, x2: 610, y2: 152}
; coords["unable_to_join"] := {x1: 185, y1: 704, x2: 543, y2: 733}
; coords["go"] := {x1: 374, y1: 614, x2: 638, y2: 663}
; coords["emoji"] := {x1: 481, y1: 849, x2: 606, y2: 956}
; coords["battle_end"] := {x1: 169, y1: 205, x2: 292, y2: 270}
; coords["start_page"] := {x1: 182, y1: 164, x2: 547, y2: 210}
; coords["multi_clear_reward"] := {x1: 254, y1: 910, x2: 465, y2: 965}
; coords["battle_last_result"] := {x1: 175, y1: 810, x2: 530, y2: 860}

; coords["exchange_room"] := {x1: 31, y1: 111, x2: 144, y2: 131}

coords["connection_fail"] := {x1: 220, y1: 370, x2: 520, y2: 420}

; coords["network_error"] := {x1: 270, y1: 615, x2: 465, y2: 660}

; 获取窗口句柄
gameTitle := "Last Cloudia ahk_class UnityWndClass"
SetTitleMatchMode 2
hWnd := WinExist(gameTitle)

if !hWnd {
    MsgBox "游戏窗口未找到！"
    ExitApp
}

WinActivate gameTitle

sleep 1000

WinMove window_x, window_y, window_w, window_h, hWnd

sleep 500

; 批量截图所有有效区域
for regionName, region in coords {
    ; 检查坐标是否有效（x2 > x1 且 y2 > y1）
    if (region.x2 > region.x1 && region.y2 > region.y1) {
        width := region.x2 - region.x1
        height := region.y2 - region.y1
        
        ImagePutFile({
            window: hWnd,
            crop: [region.x1, region.y1, width, height]
        }, regionName ".png")
        
        MsgBox regionName "区域截图已保存为 " regionName ".png"
    } else {
        MsgBox regionName "区域坐标无效，跳过截图"
    }
}