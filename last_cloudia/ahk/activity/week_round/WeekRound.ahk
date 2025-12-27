#Requires AutoHotkey v2.0
#Include ..\..\utils\PrepareWindow.ahk
#Include ..\..\utils\single_player_core\SinglePlayerCoreProcess.ahk
#Include ..\..\utils\Tools.ahk


; 全局坐标映射表
global material_coords := Map()

; 截图区域坐标
; material_coords["start_page"] := {x1: 182, y1: 164, x2: 547, y2: 210}

; 创建图像缓冲区map
global material_image_map := Map()

; 遍历material_coords的所有key并加载对应图像
for key in material_coords {
    ; 构建图像文件名（假设是PNG格式）
    imageFile := A_LineFile "\..\" key ".png"
    
    ; 加载参考图像到内存缓冲区并存入map
    try {
        material_image_map[key] := ImagePutBuffer(imageFile)
    } catch Error as e {
        ; 处理加载失败的情况
        MsgBox "无法加载图像: " imageFile "`n错误: " e.Message
    }
}

hWnd := PrepareWindow()

Loop 24 {

    SinglePlayerCoreProcess(hWnd, true, 1)
}
