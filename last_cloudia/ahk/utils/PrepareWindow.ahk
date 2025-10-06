#Requires AutoHotkey v2.0


PrepareWindow() {
    ; 对齐窗口位置和大小
    window_x := 1174
    window_y := 3
    window_w := 750
    window_h := 1040


    ; 获取窗口句柄
    gameTitle := "Last Cloudia ahk_class UnityWndClass"
    SetTitleMatchMode 2
    hWnd := WinExist(gameTitle)

    if !hWnd {
        MsgBox "游戏窗口未找到！"
        ExitApp
    }

    WinActivate gameTitle

    sleep 1000

    WinMove window_x, window_y, window_w, window_h, hWnd

    sleep 1000
    
    return hWnd
}