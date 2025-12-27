#Requires AutoHotkey v2.0
#Include ..\utils\PrepareWindow.ahk
#Include ..\utils\single_player_core\SinglePlayerCoreProcess.ahk
#Include ..\utils\Tools.ahk


; 全局坐标映射表
global activity_kill_coords := Map()

; 截图区域坐标
activity_kill_coords["start_page"] := {x1: 108, y1: 107, x2: 610, y2: 152}

; 创建图像缓冲区map
global activity_kill_image_map := Map()

; 遍历activity_kill_coords的所有key并加载对应图像
for key in activity_kill_coords {
    ; 构建图像文件名（假设是PNG格式）
    imageFile := A_LineFile "\..\" key ".png"
    
    ; 加载参考图像到内存缓冲区并存入map
    try {
        activity_kill_image_map[key] := ImagePutBuffer(imageFile)
    } catch Error as e {
        ; 处理加载失败的情况
        MsgBox "无法加载图像: " imageFile "`n错误: " e.Message
    }
}

activity_kill_dungeon_coords := [
    {x: 350, y: 370},
    {x: 350, y: 530},
    {x: 350, y: 600}
]

room_create_coord := {x: 254, y: 382}

hWnd := PrepareWindow()

counter := 1  ; 初始化计数器

Loop 1000 {

    if IsImageMatch(hWnd, activity_kill_coords, activity_kill_image_map, "start_page") {

        ; 使用取模运算循环获取坐标，索引从1到4循环
        index := Mod(counter, activity_kill_dungeon_coords.Length) + 1
        coord := activity_kill_dungeon_coords[index]
        
        MouseMove activity_kill_dungeon_coords[index].x, activity_kill_dungeon_coords[index].y
        sleep 800
        Click

        sleep 1000
        MouseMove room_create_coord.x, room_create_coord.y
        sleep 800
        Click

        sleep 2000

        SinglePlayerCoreProcess(hWnd)

        counter++  ; 只有在图像匹配成功时才递增计数器
    } else {
        sleep 2000
    }

}