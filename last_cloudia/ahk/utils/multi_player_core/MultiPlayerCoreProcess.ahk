#Requires AutoHotkey v2.0
#Include ../tools.ahk
#Include ../CommonActions.ahk

; 全局坐标映射表
global multi_player_core_coords := Map()

; 截图区域坐标
multi_player_core_coords["prepare_page"] := {x1: 300, y1: 850, x2: 430, y2: 880}
multi_player_core_coords["unable_to_join"] := {x1: 285, y1: 320, x2: 440, y2: 340}
multi_player_core_coords["go"] := {x1: 374, y1: 614, x2: 638, y2: 663}
multi_player_core_coords["emoji"] := {x1: 481, y1: 849, x2: 606, y2: 956}
multi_player_core_coords["first_meeting"] := {x1: 215, y1: 720, x2: 515, y2: 775}
multi_player_core_coords["first_clear_reward"] := {x1: 182, y1: 207, x2: 283, y2: 232}
multi_player_core_coords["multi_clear_reward"] := {x1: 254, y1: 910, x2: 465, y2: 965}
multi_player_core_coords["multi_game_refight"] := {x1: 100, y1: 540, x2: 210, y2: 565}
multi_player_core_coords["refight_denied"] := {x1: 315, y1: 320, x2: 415, y2: 345}
multi_player_core_coords["not_prepared"] := {x1: 265, y1: 755, x2: 450, y2: 800}

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
multi_player_core_coords["multi_game_refight_yes"] := {x: 470, y: 295}
multi_player_core_coords["refight_denied_yes"] := {x: 355, y: 650}

multi_player_core_coords["safe_place_for_click"] := {x: 708, y: 500}

multi_player_core_emoji_coords := [
    {x: 180, y: 669},
    {x: 290, y: 669},
    {x: 400, y: 669},
    {x: 510, y: 669}
]


global emoji_sent := false ; 控制表情包发送一次
global in_room_count := 0 ;  控制房间内等待时间

; 定义重置函数
ResetMultiPlayerState() {
    global emoji_sent := false
    global in_room_count := 0
}

MultiPlayerCoreProcess(is_room_owner, hWnd) {

    global emoji_sent
    global in_room_count

    emojiArea := multi_player_core_coords["emoji"]

    ; 队伍准备页面
    if IsImageMatch(hWnd, multi_player_core_coords, multi_player_core_image_map, "prepare_page")  {
        ; 移动到"准备完毕"按钮
        
        ClickReady()
        

    } else if IsImageMatch(hWnd, multi_player_core_coords, multi_player_core_image_map, "unable_to_join") {
        ; 无法创建或是加入房间
                    
        ; 点击"确定"按钮
        unableYes := multi_player_core_coords["unable_yes"]
        MouseMove unableYes.x, unableYes.y
        Sleep 1000
        Click

    } else if IsImageMatch(hWnd, multi_player_core_coords, multi_player_core_image_map, "go") {
        ; 房间内，且人数已经足够出发
        
        ; 从prepare_page到进入房间的时间不稳定 ，可能导致prepare_page的点击，在进入房间后再次触发，导致准备状态被取消
        ; 因此在这里兼容一下    
        if IsImageMatch(hWnd, multi_player_core_coords, multi_player_core_image_map, "not_prepared") {
            ClickReady()
        }

        ; 如果是房主，需要点击出发，出发按钮坐标和准备完毕是一样的
        if is_room_owner {
            Sleep 10000 ; 等会儿，看能不能等到更多人
            ClickReady()
        
        ; 不是房主，如果等了太久就撤
        } else {
            in_room_count += 1
            Sleep 2000
            ; 等了2min还没出发，撤
            if (in_room_count = 40) {
                ClickReady()
                Sleep 2000
                ClickBack()
                ResetMultiPlayerState()
            }
        }

    } else if IsImageMatch(hWnd, multi_player_core_coords, multi_player_core_image_map, "multi_game_refight") {
        ; 再战确认
        
        MouseMove multi_player_core_coords["multi_game_refight_yes"].x, multi_player_core_coords["multi_game_refight_yes"].y
        Sleep 1000
        Click
        Sleep 1000

    } else if IsImageMatch(hWnd, multi_player_core_coords, multi_player_core_image_map, "emoji") {
        ; 表情包界面

        ; 移动到表情包
        if !emoji_sent {
            randIndex := Random(1, multi_player_core_emoji_coords.Length)
            MouseMove multi_player_core_emoji_coords[randIndex].x, multi_player_core_emoji_coords[randIndex].y
            Sleep 1000
            Click
            emoji_sent := true
        }

    } else if IsBattleEnd(hWnd) {
        ; 战斗结算
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
        
        ; 确认多人奖励
        rewardYes := multi_player_core_coords["multi_clear_reward_yes"]
        MouseMove rewardYes.x, rewardYes.y
        sleep 800
        Click

    }  else if IsBattleLastResult(hWnd) {
        ; 最后结算页面
        MultiClick
        Sleep 2000
        MultiClick ; 有时候玩家经验提示会耽误事儿，需要再点下

        ResetMultiPlayerState()

    } else if IsAbandonTask(hWnd) {
        ; 放弃任务
        ClickAbandonTask
        ResetMultiPlayerState()
    
    } else if IsConnectionFail(hWnd) {
        ; 无法连接到伺服器
        ClickConnectionFail()
        ResetMultiPlayerState()

    } else if IsConnectionFail2(hWnd) {
        ; 无法连接到伺服器-类型2
        ClickConnectionFail2()
        ResetMultiPlayerState()
        
    } else if IsMultiConnectionFail(hWnd) {
        ; 无法连接到多人游戏伺服器
        ClickMultiConnectionFail()
        ResetMultiPlayerState()

    } else if IsNetworkError(hWnd) {
        ; 发生了网络错误
        ClickNetworkError()
        ResetMultiPlayerState()
        
    } else if IsImageMatch(hWnd, multi_player_core_coords, multi_player_core_image_map, "refight_denied") {
        
        MouseMove multi_player_core_coords["refight_denied_yes"].x, multi_player_core_coords["refight_denied_yes"].y
        sleep 800
        Click
        
    } else {
        Sleep 1500 ; 继续循环
    }
}