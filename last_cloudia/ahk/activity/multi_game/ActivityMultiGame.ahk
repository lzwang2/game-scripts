#Requires AutoHotkey v2.0
#Include ../../utils/Tools.ahk
#Include ../../utils/multi_player_core/MultiPlayerCoreProcess.ahk
#Include ../../utils/PrepareWindow.ahk

; https://github.com/iseahound/ImagePut/blob/master/README.md

; 该脚本用于执行活动中的多人游戏
; 截图需要针对活动更新

; 全局坐标映射表
global activity_multi_game_coords := Map()

; 截图区域坐标
activity_multi_game_coords["reward_entrance_page"] := {x1: 320, y1: 150, x2: 420, y2: 220}
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
activity_multi_game_coords["reward_entrance"] := {x: 375, y: 745}

; 使用数组存储多个房间坐标，方便扩展
activity_multi_game_coords["rooms"] := []
activity_multi_game_coords["rooms"].Push({x: 375, y: 655})  ; first_room (index 1)
activity_multi_game_coords["rooms"].Push({x: 375, y: 755})  ; second_room (index 2)

; 获取窗口句柄
hWnd := PrepareWindow()

; 记录当前应该点击哪个房间的索引
currentRoomIndex := 1
totalRooms := activity_multi_game_coords["rooms"].Length

Loop 1000
{
    Sleep 1000
    
     if IsImageMatch(hWnd, activity_multi_game_coords, activity_multi_game_image_map, "reward_room_list")  {
    
         ; 获取当前要点击的房间坐标
        currentRoom := activity_multi_game_coords["rooms"][currentRoomIndex]

        MouseMove currentRoom.x, currentRoom.y
        Sleep 800
        Click
        Sleep 800

        MouseMove 500, 380
        Sleep 800
        Click
        Sleep 1000
        
        MultiPlayerCoreProcess(true, hWnd)

        ; 更新索引，循环到下一个房间
        currentRoomIndex := Mod(currentRoomIndex, totalRooms) + 1

    } if IsImageMatch(hWnd, activity_multi_game_coords, activity_multi_game_image_map, "reward_entrance_page")  {

        ; 拖到底部
        StepDrag(675, 615, 675, 70)

        MouseMove activity_multi_game_coords["reward_entrance"].x, activity_multi_game_coords["reward_entrance"].y
        Sleep 800
        Click
        Sleep 800

    } else {
        Sleep 2000
     }

}

ExitApp
