#Requires AutoHotkey v2.0

global AutoClickEnabled := false
global ClickTimer := 0

F4::
{
    global AutoClickEnabled
    global ClickTimer
    
    AutoClickEnabled := !AutoClickEnabled
    
    if AutoClickEnabled {
        PerformClick()
        ClickTimer := SetTimer(PerformClick, 2000)
    } else {
        SetTimer(PerformClick, 0)
        ClickTimer := 0
    }
}

PerformClick() {
    Click
}