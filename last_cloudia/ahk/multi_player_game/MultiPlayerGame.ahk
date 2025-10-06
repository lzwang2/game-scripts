#Requires AutoHotkey v2.0
#Include ../utils/Tools.ahk
#Include ../utils/multi_player_core/MultiPlayerCoreProcess.ahk

; https://github.com/iseahound/ImagePut/blob/master/README.md

; 对齐窗口位置和大小
window_x := 1174
window_y := 3
window_w := 750
window_h := 1040

; 全局坐标映射表
global multi_player_game_coords := Map()

; 截图区域坐标
multi_player_game_coords["no_room"] := {x1: 253, y1: 437, x2: 484, y2: 559}
multi_player_game_coords["welcome"] := {x1: 464, y1: 365, x2: 613, y2: 395}
multi_player_game_coords["network_error"] := {x1: 270, y1: 615, x2: 465, y2: 660}

; 创建图像缓冲区map
global multi_player_game_image_map := Map()

; 遍历multi_player_game_coords的所有key并加载对应图像
for key in multi_player_game_coords {
    ; 构建图像文件名（假设是PNG格式）
    imageFile := key . ".png"
    
    ; 加载参考图像到内存缓冲区并存入map
    try {
        multi_player_game_image_map[key] := ImagePutBuffer(imageFile)
    } catch Error as e {
        ; 处理加载失败的情况
        MsgBox "无法加载图像: " imageFile "`n错误: " e.Message
    }
}

; 现在可以通过multi_player_game_image_map[key]访问已加载的图像缓冲区
; 例如: multi_player_game_image_map["no_room"] 将返回对应的图像缓冲区

; 点击位置坐标
multi_player_game_coords["first_room"] := {x: 344, y: 329}
multi_player_game_coords["update_list"] := {x: 647, y: 955}
multi_player_game_coords["network_error_retry"] := {x: 360, y: 640}

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

sleep 1000

Loop 1000 ; 查找房间循环
{
    welcome := multi_player_game_coords["welcome"]
    nooRoom := multi_player_game_coords["no_room"]

    ; 找到了房间
    if IsImageMatch(hWnd, multi_player_game_coords, multi_player_game_image_map, "welcome") {
        ; 移动到第一个房间
        firstRoom := multi_player_game_coords["first_room"]
        MouseMove firstRoom.x, firstRoom.y
        Sleep 800
        Click
        Sleep 1000
        
        MultiPlayerCoreProcess(false, hWnd)

    ; 没有房间
    } else if IsImageMatch(hWnd, multi_player_game_coords, multi_player_game_image_map, "no_room") {
        ; 移动到"更新列表"
        updateList := multi_player_game_coords["update_list"]
        MouseMove updateList.x, updateList.y
        Sleep 800
        Click
        Sleep 6000
        
    } else if IsImageMatch(hWnd, multi_player_game_coords, multi_player_game_image_map, "network_error") {
        
        MouseMove multi_player_game_coords["network_error_retry"].x, multi_player_game_coords["network_error_retry"].y
        Sleep 800
        Click
        Sleep 3000
        
    } else {
        sleep 1000 ; 继续查找房间循环
    }
}

ExitApp
