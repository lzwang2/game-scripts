#Requires AutoHotkey v2.0
#Include Tools.ahk

; 通用坐标
global common_coords := Map()

; 截图区域
; common_coords["main_page_area"] := {x1: 95, y1: 910, x2: 180, y2: 1000}

common_coords["connection_fail_area"] := {x1: 220, y1: 370, x2: 520, y2: 420}
common_coords["team_prepare_area"] := {x1: 125, y1: 750, x2: 230, y2: 770}
common_coords["battle_end_area"] := {x1: 169, y1: 205, x2: 292, y2: 270}
common_coords["stamina_recover_area"] := {x1: 265, y1: 200, x2: 465, y2: 235}
common_coords["first_clear_reward_area"] := {x1: 340, y1: 525, x2: 390, y2: 545}
common_coords["battle_last_result"] := {x1: 100, y1: 25, x2: 610, y2: 110}

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


common_coords["ready_button"] := {x: 375, y: 865} ; 队伍准备

common_coords["back_button"] := {x: 80, y: 960}

common_coords["connection_fail_button"] := {x: 370, y: 660}


common_coords["add_stamina"] := {x: 520, y: 470}
common_coords["recover_stamina"] := {x: 365, y: 820}


ClickReady() {
    ClickTargetButton("ready_button")
}

ClickBack() {
    ClickTargetButton("back_button")
}

ClickConnectionFail() {
    ClickTargetButton("connection_fail_button")
}

ClickTargetButton(target, delay := 1000) {
    MouseMove common_coords[target].x, common_coords[target].y
    Sleep delay
    Click
}

ClickAddStamina(count := 4) {
    Loop count {
        ClickTargetButton("add_stamina", 800)
    }
}

ClickRecoverStamina() {
    ClickTargetButton("recover_stamina", 500)
}


IsConnectionFail(hWnd) {

    return IsImageMatch(hWnd, common_coords, common_image_map, "connection_fail_area")

}

; 是否是队伍界面
IsSingleTeamPrepare(hWnd) {
    return IsImageMatch(hWnd, common_coords, common_image_map, "team_prepare_area")
}

; 是否战斗宝箱奖励结算画面
IsBattleEnd(hWnd) {
    return IsImageMatch(hWnd, common_coords, common_image_map, "battle_end_area")
}

; 是否橙宝玉手动恢复界面
IsStaminaRecover(hWnd) {
    return IsImageMatch(hWnd, common_coords, common_image_map, "stamina_recover_area")
}

; 初次通关奖励
IsFirstClearReward(hWnd) {
    return IsImageMatch(hWnd, common_coords, common_image_map, "first_clear_reward_area")
}

; 战斗最后的结算界面
IsBattleLastResult(hWnd) {
    return IsImageMatch(hWnd, common_coords, common_image_map, "battle_last_result")
}