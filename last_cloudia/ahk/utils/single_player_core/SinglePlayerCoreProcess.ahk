#Requires AutoHotkey v2.0
#Include ../tools.ahk
#Include ../CommonActions.ahk


; 全局坐标映射表
global single_player_core_coords := Map()

; 截图区域坐标
single_player_core_coords["battle_again_area"] := {x1: 130, y1: 600, x2: 600, y2: 670}
single_player_core_coords["battle_evaluate_reward"] := {x1: 335, y1: 690, x2: 390, y2: 710}

; 创建图像缓冲区map
global single_player_core_image_map := Map()

; 遍历single_player_core_coords的所有key并加载对应图像
for key in single_player_core_coords {
    ; 构建图像文件名（假设是PNG格式）
    imageFile := A_LineFile "\..\" key ".png"
    
    ; 加载参考图像到内存缓冲区并存入map
    try {
        single_player_core_image_map[key] := ImagePutBuffer(imageFile)
    } catch Error as e {
        ; 处理加载失败的情况
        MsgBox "无法加载图像: " imageFile "`n错误: " e.Message
    }
}


; 点击位置坐标
single_player_core_coords["no_support"] := {x: 620, y: 945}
single_player_core_coords["ready_btn"] := {x: 373, y: 864}
single_player_core_coords["safe_place_for_click"] := {x: 708, y: 500}
single_player_core_coords["battle_again_yes"] := {x: 490, y: 640}
single_player_core_coords["battle_again_no"] := {x: 235, y: 635}
single_player_core_coords["first_clear_reward_ok"] := {x: 340, y: 525}
single_player_core_coords["battle_evaluate_reward_ok"] := {x: 370, y: 695}

MoveToSafePlaceForClick() {

    Sleep 1000
    MouseMove single_player_core_coords["safe_place_for_click"].x, single_player_core_coords["safe_place_for_click"].y ;移动到安全位置

}

; lastStep：最后一个界面是啥？用于控制该在哪一步跳出循环。1.再战弹框; 2.最后的RESULT界面。
SinglePlayerCoreProcess(hWnd, again, lastStep) {

    Loop 1000 {

        if IsSingleTeamPrepare(hWnd) {

            ClickReady
            Sleep 2000
    
        } else if IsStaminaRecover(hWnd) {

            ClickAddStamina
                
            Sleep 1000
            
            ClickRecoverStamina

        } else if IsBattleEnd(hWnd) {
            ; 战斗结算      

            sleep 800
            MultiClick ; 战斗结算跳过点击

        } else if IsImageMatch(hWnd, single_player_core_coords, single_player_core_image_map, "battle_again_area") {

            if again {
                MouseMove single_player_core_coords["battle_again_yes"].x, single_player_core_coords["battle_again_yes"].y ;再次
                sleep 800
                Click
            } else {
                MouseMove single_player_core_coords["battle_again_no"].x, single_player_core_coords["battle_again_no"].y ;不再次
                sleep 800
                Click
            }
            if (lastStep == 1) {
                Break ; 结束循环
            }

        } else if IsFirstClearReward(hWnd) {
            ; 初次奖励
            MouseMove single_player_core_coords["first_clear_reward_ok"].x, single_player_core_coords["first_clear_reward_ok"].y ; ok
            sleep 800
            Click

        } else if IsImageMatch(hWnd, single_player_core_coords, single_player_core_image_map, "battle_evaluate_reward") {

            ; 战斗评价奖励
            MouseMove single_player_core_coords["battle_evaluate_reward_ok"].x, single_player_core_coords["battle_evaluate_reward_ok"].y ; ok
            sleep 800
            Click
            
        } else if IsBattleLastResult(hWnd) {

            MultiClick
            Sleep 2000
            MultiClick ; 有时候玩家经验提示会耽误事儿，需要再点下
            if (lastStep == 2) {
                Break ; 结束循环
            }
            
        } else {
            MoveToSafePlaceForClick
            MultiClick(1) ; 可用于 RESULT界面跳过点击
            sleep 2000
        }
    }
}