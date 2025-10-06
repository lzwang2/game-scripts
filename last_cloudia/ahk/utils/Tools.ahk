#Requires AutoHotkey v2.0
#Include ImagePut.ahk

; 创建日志函数
LogMessage(message) {
    timestamp := FormatTime(, "yyyy-MM-dd HH:mm:ss")
    logEntry := timestamp " - " message "`n"
    FileAppend logEntry, "script_log.txt"
}

IsImageMatch(hWnd, coords, imageMap, imageKey) {
    try {
        ; 从坐标映射表中获取坐标
        if (!coords.Has(imageKey)) {
            LogMessage("错误: 未找到坐标配置 '" imageKey "'")
            return false
        }
        
        coord := coords[imageKey]
        x1 := coord.x1
        y1 := coord.y1
        x2 := coord.x2
        y2 := coord.y2
        
        ; 计算宽度和高度
        width := x2 - x1
        height := y2 - y1

        ; 直接从窗口截取指定区域到内存缓冲区
        screenshot := ImagePutBuffer({
            window: hWnd,
            crop: [x1, y1, width, height]  ; [x, y, width, height] 客户区相对坐标
        })

        ; 比较两个图像
        result := ImageEqual(screenshot, imageMap[imageKey])

        ; 添加匹配结果日志
        if (result) {
            LogMessage("图像匹配成功: " imageKey ".png")
        } else {
            LogMessage("图像匹配失败: " imageKey ".png")
            ; ; 保存实际截图用于调试（添加actual前缀）
            ; actualFilename := "actual_" . imageKey . ".png"
            ; ImagePutFile({
            ;     window: hWnd,
            ;     crop: [x1, y1, width, height]  ; [x, y, width, height]
            ; }, actualFilename)
            ; LogMessage("保存实际截图: " actualFilename)
        }

        ; 清理资源
        try ImagePut.Destroy(screenshot)

        return result
    } catch Error as e {
        LogMessage("图像比较出错: " e.Message)
        return false
    }
}

MultiClick(times := 3, interval := 300) {
    Loop times
    {
        Click
        Sleep interval
    }
}