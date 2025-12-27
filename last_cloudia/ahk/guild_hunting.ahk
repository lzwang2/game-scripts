#Requires AutoHotkey v2.0
#Include utils\Tools.ahk
#Include utils\PrepareWindow.ahk
#Include utils\CommonActions.ahk

; 全局坐标映射表
global guild_hunting_coords := Map()

;guild_hunting_coords["guild_chat"] := {x1: 170, y1: 700, x2: 320, y2: 760}

; 创建图像缓冲区map
global guild_hunting_image_map := Map()

LoadCommonImagesToMap(guild_hunting_image_map, "connection_fail_area")

; 遍历guild_hunting_coords的所有key并加载对应图像
for key in guild_hunting_coords {
    ; 构建图像文件名（假设是PNG格式）
    imageFile := A_LineFile "\..\" key ".png"

    ; 加载参考图像到内存缓冲区并存入map
    try {
        guild_hunting_image_map[key] := ImagePutBuffer(imageFile)
    } catch Error as e {
        ; 处理加载失败的情况
        MsgBox "无法加载图像: " imageFile "`n错误: " e.Message
    }
}

guild_hunting_guild_entrance_coord := {x: 370, y: 560}

;guild_hunting_hunting_entrance_coord := {x: 240, y: 840}


Loop 1000 {

    if IsImageMatch(hWnd, material_coords, material_image_map, "main_page") {

        MouseMove guild_hunting_guild_entrance_coord.x, guild_hunting_guild_entrance_coord.y
        Sleep 800
        Click

        sleep 3000

;    } if IsImageMatch(hWnd, material_coords, material_image_map, "guild_chat") {

        MouseMove guild_hunting_hunting_entrance_coord.x, guild_hunting_hunting_entrance_coord.y
        Sleep 800
        Click

        Sleep 2000
        Click

        SinglePlayerCoreProcess(hWnd)


    } else {
        Sleep 2000
    }
}
