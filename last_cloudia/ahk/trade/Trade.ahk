#Requires AutoHotkey v2.0
#Include ../utils/Tools.ahk
#Include ../utils/PrepareWindow.ahk

 ; 全局坐标映射表
global trade_coords := Map()

; 截图区域坐标
trade_coords["first_trade_enable_area"] := {x1: 530, y1: 460, x2: 590, y2: 490}
trade_coords["second_trade_enable_area"] := {x1: 530, y1: 600, x2: 590, y2: 630}
trade_coords["item_exchange_complete_area"] := {x1: 300, y1: 690, x2: 430, y2: 720}
trade_coords["item_update_area"] := {x1: 275, y1: 620, x2: 460, y2: 660}
; 有些活动交换所（比如跨年活动）和日常的活动的交换所样式有差别
trade_coords["other_trade_enable_area"] := {x1: 530, y1: 490, x2: 590, y2: 520}
; 创建图像缓冲区map
global trade_image_map := Map()

; 遍历trade_coords的所有key并加载对应图像
for key in trade_coords {
    ; 构建图像文件名（假设是PNG格式）
    imageFile := A_LineFile "\..\" key ".png"
    
    ; 加载参考图像到内存缓冲区并存入map
    try {
        trade_image_map[key] := ImagePutBuffer(imageFile)
    } catch Error as e {
        ; 处理加载失败的情况
        MsgBox "无法加载图像: " imageFile "`n错误: " e.Message
    }
}

trade_coords["first_item_button"] := {x: 330, y: 465}
trade_coords["second_item_button"] := {x: 330, y: 600}

trade_coords["scroll_bar_head"] := {x: 215, y: 463}
trade_coords["scroll_bar_tail"] := {x: 516, y: 467}
trade_coords["trade_button"] := {x: 490, y: 755}
trade_coords["close_button"] := {x: 370, y: 720}
trade_coords["update_yes_button"] := {x: 370, y: 640}

hWnd := PrepareWindow()

Loop {
    
    enabled_item_coord := {}
    if IsImageMatch(hWnd, trade_coords, trade_image_map, "first_trade_enable_area") {
        
        TradeItem(trade_coords["first_item_button"])

    } else if IsImageMatch(hWnd, trade_coords, trade_image_map, "second_trade_enable_area") {
        
        TradeItem(trade_coords["second_item_button"])

    } else if IsImageMatch(hWnd, trade_coords, trade_image_map, "other_trade_enable_area") {
        
        TradeItem(trade_coords["first_item_button"])

    } else if IsImageMatch(hWnd, trade_coords, trade_image_map, "item_exchange_complete_area") {
        
        ; 确认交换结果
        Sleep 800
        MouseMove trade_coords["close_button"].x, trade_coords["close_button"].y
        Sleep 800
        Click

    } else if IsImageMatch(hWnd, trade_coords, trade_image_map, "item_update_area") {
        
        MouseMove trade_coords["update_yes_button"].x, trade_coords["update_yes_button"].y
        Sleep 800
        Click

    } else {
        Sleep 2000
    }

}

TradeItem(enabled_item_coord) {

    ; 移动至可兑换物品
    MouseMove enabled_item_coord.x, enabled_item_coord.y
    Sleep 800
    Click
    Sleep 2000

    ; 拖动滚动条
    MouseMove trade_coords["scroll_bar_head"].x, trade_coords["scroll_bar_head"].y
    Sleep 800
    MouseClick("Left", , , , , "Down")
    Sleep 1000
    MouseMove trade_coords["scroll_bar_tail"].x, trade_coords["scroll_bar_tail"].y
    Sleep 800
    MouseClick("Left", , , , , "Up")
    Sleep 800

    ; 点击交换
    MouseMove trade_coords["trade_button"].x, trade_coords["trade_button"].y
    Sleep 800
    Click

    Sleep 3000
}