#Requires AutoHotkey v2.0
#Include ../tools.ahk


; 全局坐标映射表
global single_player_core_coords := Map()

; 截图区域坐标
single_player_core_coords["battle_end"] := {x1: 169, y1: 205, x2: 292, y2: 270}

; 创建图像缓冲区map
global single_player_core_image_map := Map()

; 遍历single_player_core_coords的所有key并加载对应图像
for key in single_player_core_coords {
    ; 构建图像文件名（假设是PNG格式）
    imageFile := A_LineFile "\..\" key ".png"
    
    ; 加载参考图像到内存缓冲区并存入map
    try {
        single_player_core_image_map[key] := ImagePutBuffer(imageFile)
    } catch Error as e {
        ; 处理加载失败的情况
        MsgBox "无法加载图像: " imageFile "`n错误: " e.Message
    }
}


; 点击位置坐标
single_player_core_coords["no_support"] := {x: 620, y: 945}
single_player_core_coords["ready_btn"] := {x: 373, y: 864}
single_player_core_coords["safe_place_for_click"] := {x: 708, y: 500}
single_player_core_coords["not_again"] := {x: 235, y: 635}


SinglePlayerCoreProcess(hWnd) {

    ; 不使用援军
    MouseMove single_player_core_coords["no_support"].x, single_player_core_coords["no_support"].y
    sleep 800
    Click

    sleep 1000

    ; 出发
    MouseMove single_player_core_coords["ready_btn"].x, single_player_core_coords["ready_btn"].y
    sleep 800
    Click
    sleep 800

    MouseMove single_player_core_coords["safe_place_for_click"].x, single_player_core_coords["safe_place_for_click"].y ;移动到安全位置
    
    Loop 1000 {

        ; 战斗结算
        if IsImageMatch(hWnd, single_player_core_coords, single_player_core_image_map, "battle_end") {
            
            sleep 800
            MultiClick ; 战斗结算跳过点击
            
            sleep 1000
            MultiClick ; RESULT界面跳过点击

            sleep 2000 ; 
            
            MouseMove single_player_core_coords["not_again"].x, single_player_core_coords["not_again"].y ;不再次
            sleep 800
            Click

            sleep 2000
            Break ; 结束循环

        } else {
            MultiClick 4, 500 ; 点一点加快战斗
        }
    }
}