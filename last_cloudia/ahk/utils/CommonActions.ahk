#Requires AutoHotkey v2.0
#Include Tools.ahk

; 通用坐标
global common_coords := Map()

; 截图区域
; common_coords["main_page_area"] := {x1: 95, y1: 910, x2: 180, y2: 1000}

common_coords["connection_fail_area"] := {x1: 220, y1: 370, x2: 520, y2: 420}

; 创建图像缓冲区map
global common_image_map := Map()

; 加载图像
for key in common_coords {
    ; 构建图像文件名（假设是PNG格式）
    imageFile := A_LineFile "\..\" key ".png"
    
    ; 加载参考图像到内存缓冲区并存入map
    try {
        common_image_map[key] := ImagePutBuffer(imageFile)
    } catch Error as e {
        ; 处理加载失败的情况
        MsgBox "无法加载图像: " imageFile "`n错误: " e.Message
    }
}

; 点击按钮
common_coords["ready_button"] := {x: 375, y: 865}

common_coords["back_button"] := {x: 80, y: 960}

common_coords["connection_fail_button"] := {x: 370, y: 660}

ClickReady() {
    ClickTargetButton("ready_button")
}

ClickBack() {
    ClickTargetButton("back_button")
}

ClickConnectionFail() {
    ClickTargetButton("connection_fail_button")
}

ClickTargetButton(target) {
    MouseMove common_coords[target].x, common_coords[target].y
    Sleep 1000
    Click
}


IsConnectionFail(hWnd) {

    return IsImageMatch(hWnd, common_coords, common_image_map, "connection_fail_area")

}