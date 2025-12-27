#Requires AutoHotkey v2.0
#Include utils/PrepareWindow.ahk
#Include utils/single_player_core/SinglePlayerCoreProcess.ahk

; 全局坐标映射表
global repeat_first_player_game_coords := Map()

; 点击位置坐标
repeat_first_player_game_coords["first_dungeon"] := {x: 350, y: 395}
repeat_first_player_game_coords["no_ally"] := {x: 625, y: 950}


; 获取窗口句柄
hWnd := PrepareWindow()

Loop {
    MouseMove repeat_first_player_game_coords["first_dungeon"].x, repeat_first_player_game_coords["first_dungeon"].y
    Sleep 300
    Click

    Sleep 800
    MouseMove repeat_first_player_game_coords["no_ally"].x, repeat_first_player_game_coords["no_ally"].y
    Sleep 300
    Click

    SinglePlayerCoreProcess(hWnd, false, 2)

    Sleep 2000
}