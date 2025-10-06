#Requires AutoHotkey v2.0
#Include ..\utils\PrepareWindow.ahk
#Include ..\utils\single_player_core\SinglePlayerCoreProcess.ahk
#Include ..\utils\Tools.ahk


; 全局坐标映射表
global material_coords := Map()

; 截图区域坐标
material_coords["start_page"] := {x1: 182, y1: 164, x2: 547, y2: 210}

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

material_dungeon_coords := [
    {x: 350, y: 360},
    {x: 350, y: 510},
    {x: 350, y: 660},
    {x: 350, y: 820}
]

material_dungeon_sub_coord := {x: 370, y: 560}

room_create_coord := {x: 254, y: 382}

hWnd := PrepareWindow()

counter := 1  ; 初始化计数器

Loop 1000 {

    if IsImageMatch(hWnd, material_coords, material_image_map, "start_page") {

        ; 使用取模运算循环获取坐标，索引从1到4循环
        index := Mod(counter, material_dungeon_coords.Length) + 1
        coord := material_dungeon_coords[index]
        
        MouseMove material_dungeon_coords[index].x, material_dungeon_coords[index].y ;展开素材列表
        sleep 800
        Click

        MouseMove material_dungeon_sub_coord.x, material_dungeon_sub_coord.y ; 选择神级
        sleep 800
        Click

        sleep 1000
        MouseMove room_create_coord.x, room_create_coord.y ;单人挑战
        sleep 800
        Click

        sleep 2000

        SinglePlayerCoreProcess(hWnd)

        counter++  ; 只有在图像匹配成功时才递增计数器
    } else {
        sleep 2000
    }

}