#Requires AutoHotkey v2.0
#Include ../../utils/Tools.ahk
#Include ../../utils/multi_player_core/MultiPlayerCoreProcess.ahk
#Include ../../utils/PrepareWindow.ahk

; https://github.com/iseahound/ImagePut/blob/master/README.md

; 全局坐标映射表
global activity_multi_game_coords := Map()

; 截图区域坐标
activity_multi_game_coords["reward_entrance_page"] := {x1: 300, y1: 590, x2: 430, y2: 630}
activity_multi_game_coords["reward_room_list"] := {x1: 300, y1: 180, x2: 430, y2: 220}

; 创建图像缓冲区map
global activity_multi_game_image_map := Map()

; 遍历activity_multi_game_coords的所有key并加载对应图像
for key in activity_multi_game_coords {
    ; 构建图像文件名（假设是PNG格式）
    imageFile := A_LineFile "\..\" key ".png"
    
    ; 加载参考图像到内存缓冲区并存入map
    try {
        activity_multi_game_image_map[key] := ImagePutBuffer(imageFile)
    } catch Error as e {
        ; 处理加载失败的情况
        MsgBox "无法加载图像: " imageFile "`n错误: " e.Message
    }
}

; 点击位置坐标
activity_multi_game_coords["reward_entrance"] := {x: 400, y: 615}
activity_multi_game_coords["first_room"] := {x: 375, y: 330}

; 获取窗口句柄
hWnd := PrepareWindow()

Loop 1000
{
    Sleep 1000
    
     if IsImageMatch(hWnd, activity_multi_game_coords, activity_multi_game_image_map, "reward_room_list")  {
    
        MouseMove activity_multi_game_coords["first_room"].x, activity_multi_game_coords["first_room"].y
        Sleep 800
        Click
        Sleep 800

        MouseMove 500, 380
        Sleep 800
        Click
        Sleep 1000
        
        MultiPlayerCoreProcess(true, hWnd)
    } if IsImageMatch(hWnd, activity_multi_game_coords, activity_multi_game_image_map, "reward_entrance_page")  {

        MouseMove activity_multi_game_coords["reward_entrance"].x, activity_multi_game_coords["reward_entrance"].y
        Sleep 800
        Click
        Sleep 800

    } else {
        Sleep 2000
     }

}

ExitApp
