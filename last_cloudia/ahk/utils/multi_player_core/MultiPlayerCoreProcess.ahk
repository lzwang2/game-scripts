#Requires AutoHotkey v2.0
#Include ../tools.ahk
#Include ../CommonActions.ahk

; 全局坐标映射表
global multi_player_core_coords := Map()

; 截图区域坐标
multi_player_core_coords["prepare_page"] := {x1: 365, y1: 180, x2: 645, y2: 210}
multi_player_core_coords["unable_to_join"] := {x1: 365, y1: 180, x2: 645, y2: 210}
multi_player_core_coords["go"] := {x1: 374, y1: 614, x2: 638, y2: 663}
multi_player_core_coords["abandan_task_area"] := {x1: 270, y1: 615, x2: 465, y2: 660}
multi_player_core_coords["emoji"] := {x1: 481, y1: 849, x2: 606, y2: 956}
multi_player_core_coords["first_meeting"] := {x1: 215, y1: 720, x2: 515, y2: 775}
multi_player_core_coords["first_clear_reward"] := {x1: 182, y1: 207, x2: 283, y2: 232}
multi_player_core_coords["multi_clear_reward"] := {x1: 254, y1: 910, x2: 465, y2: 965}

; 创建图像缓冲区map
global multi_player_core_image_map := Map()

; 遍历multi_player_core_coords的所有key并加载对应图像
for key in multi_player_core_coords {
    ; 构建图像文件名（假设是PNG格式）
    imageFile := A_LineFile "\..\" key ".png"
    
    ; 加载参考图像到内存缓冲区并存入map
    try {
        multi_player_core_image_map[key] := ImagePutBuffer(imageFile)
    } catch Error as e {
        ; 处理加载失败的情况
        MsgBox "无法加载图像: " imageFile "`n错误: " e.Message
    }
}

; 点击位置坐标
multi_player_core_coords["unable_yes"] := {x: 368, y: 645}
multi_player_core_coords["first_clear_reward_yes"] := {x: 370, y: 535}
multi_player_core_coords["multi_clear_reward_yes"] := {x: 381, y: 940}
multi_player_core_coords["first_meeting_close"] := {x: 370, y: 750}

multi_player_core_coords["safe_place_for_click"] := {x: 708, y: 500}

multi_player_core_emoji_coords := [
    {x: 180, y: 669},
    {x: 290, y: 669},
    {x: 400, y: 669},
    {x: 510, y: 669}
]

MultiPlayerCoreProcess(is_room_owner, hWnd) {


    ready_run_flag := 0 ; 控制只点击一次"准备完毕"
                        ; 有时候会卡在队伍准备的页面，如果一直卡到无法加入房间倒没什么问题
                        ; 如果卡了一会儿反而进入房间了，此时因时间差反而在执行prepare_page的点击，会导致进入房间后的ready状态被取消
    
    in_room_count := 0

    Loop
    {
        emojiArea := multi_player_core_coords["emoji"]

        ; 队伍准备页面
        if (ready_run_flag = 0) and IsImageMatch(hWnd, multi_player_core_coords, multi_player_core_image_map, "prepare_page")  {
            ; 移动到"准备完毕"按钮
            
            ClickReady()
            Sleep 2000 ; 等待进入房间
            ready_run_flag := 1

        ; 无法创建或是加入房间
        } else if IsImageMatch(hWnd, multi_player_core_coords, multi_player_core_image_map, "unable_to_join") {
                
            ; 点击"确定"按钮
            unableYes := multi_player_core_coords["unable_yes"]
            MouseMove unableYes.x, unableYes.y
            Sleep 1000
            Click

            Break ; 结束循环

        ; 放弃任务
        } else if IsImageMatch(hWnd, multi_player_core_coords, multi_player_core_image_map, "abandan_task_area") {
                
            ; 点击"确定"按钮，复用unable_yes坐标位置
            unableYes := multi_player_core_coords["unable_yes"]
            MouseMove unableYes.x, unableYes.y
            Sleep 1000
            Click

            Break ; 结束循环

        ; 进入房间后，且人数已经足够出发
        } else if IsImageMatch(hWnd, multi_player_core_coords, multi_player_core_image_map, "go") {

            ; 如果是房主，需要点击出发，出发按钮坐标和准备完毕是一样的
            if is_room_owner {
                ClickReady()
            
            ; 不是房主，如果等了太久就撤
            } else {
                in_room_count += 1
                Sleep 2000
                ; 等了2min还没出发，撤
                if (in_room_count = 40) {
                    ClickReady()
                    Sleep 1000
                    ClickBack()
                    break ; 退出循环
                }
            }

        ; 表情包界面
        } else if IsImageMatch(hWnd, multi_player_core_coords, multi_player_core_image_map, "emoji") {
                    
            ; 移动到表情包
            randIndex := Random(1, multi_player_core_emoji_coords.Length)
            MouseMove multi_player_core_emoji_coords[randIndex].x, multi_player_core_emoji_coords[randIndex].y
            Sleep 2000
            Click
            Sleep Random(1000, 4000)

        ; 战斗结算
        } else if IsBattleEnd(hWnd) {
            
            MouseMove multi_player_core_coords["safe_place_for_click"].x, multi_player_core_coords["safe_place_for_click"].y ;移动到安全位置
            
            sleep 800
            MultiClick ; 战斗结算跳过点击

        
        } else if IsImageMatch(hWnd, multi_player_core_coords, multi_player_core_image_map, "first_clear_reward") {
            ; 初次通关奖励
            MouseMove multi_player_core_coords["first_clear_reward_yes"].x, multi_player_core_coords["first_clear_reward_yes"].y
            sleep 800
            Click

        } else if IsImageMatch(hWnd, multi_player_core_coords, multi_player_core_image_map, "first_meeting") {
            ; 初次见面奖励
            MouseMove multi_player_core_coords["first_meeting_close"].x, multi_player_core_coords["first_meeting_close"].y
            sleep 800
            Click

        }  else if IsImageMatch(hWnd, multi_player_core_coords, multi_player_core_image_map, "multi_clear_reward") {
            ; 多人通关奖励
            MouseMove multi_player_core_coords["safe_place_for_click"].x, multi_player_core_coords["safe_place_for_click"].y ;移动到安全位置
            
            sleep 800
            MultiClick ; 多人结算界面点击跳过
            
            ; 确认多人奖励
            rewardYes := multi_player_core_coords["multi_clear_reward_yes"]
            MouseMove rewardYes.x, rewardYes.y
            sleep 800
            Click

        ; 最后结算页面
        }  else if IsBattleLastResult(hWnd) {

            MultiClick
            Sleep 2000
            MultiClick ; 有时候玩家经验提示会耽误事儿，需要再点下
            Break ; 结束循环

        ; 无法连接到伺服器
        } else if IsConnectionFail(hWnd) {

            ClickConnectionFail()
            Break ; 结束循环

        } else {
            Sleep 2000 ; 继续循环
        }
    }
}