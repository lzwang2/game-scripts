#Requires AutoHotkey v2.0
#Include ImagePut.ahk

; 创建日志函数
LogMessage(message) {
    timestamp := FormatTime(, "yyyy-MM-dd HH:mm:ss")
    logEntry := timestamp " - " message "`n"
    FileAppend logEntry, "script_log.txt"
}

IsImageMatch(hWnd, coords, imageMap, imageKey, tolerance := 20, matchThreshold := 0.90, maxOffset := 1) {
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

        ; 先做精确匹配，失败后再退化到容差匹配，兼容细小色差和 1-2 像素抖动
        result := ImageEqual(screenshot, imageMap[imageKey])
        bestScore := result ? 1.0 : GetBestImageMatchScore(screenshot, imageMap[imageKey], tolerance, maxOffset)
        if (!result) {
            result := (bestScore >= matchThreshold)
        }

        ; 添加匹配结果日志
        if (result) {
            LogMessage("图像匹配成功: " imageKey ".png, score=" Round(bestScore, 4))
        } else {
            LogMessage("图像匹配失败: " imageKey ".png, score=" Round(bestScore, 4))
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

GetBestImageMatchScore(image1, image2, tolerance := 20, maxOffset := 1) {
    if (image1.width != image2.width || image1.height != image2.height) {
        return 0.0
    }

    bestScore := 0.0
    Loop 2 * maxOffset + 1 {
        offsetY := A_Index - maxOffset - 1
        Loop 2 * maxOffset + 1 {
            offsetX := A_Index - maxOffset - 1
            score := CompareImagesWithOffset(image1, image2, tolerance, offsetX, offsetY)
            if (score > bestScore) {
                bestScore := score
            }
        }
    }

    return bestScore
}

CompareImagesWithOffset(image1, image2, tolerance := 20, offsetX := 0, offsetY := 0) {
    width := image1.width
    height := image1.height
    compareWidth := width - Abs(offsetX)
    compareHeight := height - Abs(offsetY)

    if (compareWidth <= 0 || compareHeight <= 0) {
        return 0.0
    }

    startX1 := offsetX > 0 ? offsetX : 0
    startY1 := offsetY > 0 ? offsetY : 0
    startX2 := offsetX < 0 ? -offsetX : 0
    startY2 := offsetY < 0 ? -offsetY : 0

    matchedPixels := 0
    totalPixels := compareWidth * compareHeight
    ptr1 := image1.ptr
    ptr2 := image2.ptr

    Loop compareHeight {
        y := A_Index - 1
        rowOffset1 := 4 * ((startY1 + y) * width + startX1)
        rowOffset2 := 4 * ((startY2 + y) * width + startX2)

        Loop compareWidth {
            xOffset := 4 * (A_Index - 1)
            color1 := NumGet(ptr1 + rowOffset1 + xOffset, "uint")
            color2 := NumGet(ptr2 + rowOffset2 + xOffset, "uint")

            if (Abs(RGBToGray(color1) - RGBToGray(color2)) <= tolerance) {
                matchedPixels += 1
            }
        }
    }

    return matchedPixels / totalPixels
}


; 将RGB颜色转换为灰度值的函数
RGBToGray(color) {
    r := (color >> 16) & 0xFF  ; 提取红色分量 (0-255)
    g := (color >> 8) & 0xFF   ; 提取绿色分量 (0-255)
    b := color & 0xFF          ; 提取蓝色分量 (0-255)
    
    ; 使用人眼感知权重计算灰度值
    ; 人眼对绿色最敏感(58.7%)，红色次之(29.9%)，蓝色最不敏感(11.4%)
    return Floor(r * 0.299 + g * 0.587 + b * 0.114)
}

MultiClick(times := 5, interval := 300) {
    Loop times
    {
        Click
        Sleep interval
    }
}


; 分步拖拽函数
StepDrag(startX, startY, endX, endY, steps := 5) {
    ; 先移动到起始位置
    MouseMove startX, startY
    Sleep 300
    
    ; 按下左键
    Click "Down"
    Sleep 300
    
    ; 计算每一步的增量
    stepX := (endX - startX) / steps
    stepY := (endY - startY) / steps
    
    ; 分步移动
    Loop steps {
        ; 计算当前步的目标位置
        currentStep := A_Index
        targetX := startX + stepX * currentStep
        targetY := startY + stepY * currentStep
        
        ; 移动到当前步的目标位置
        MouseMove targetX, targetY, 30  ; 30是移动速度，数值越小越慢
        Sleep 100  ; 每步之间的短暂停顿
    }
    
    ; 确保最终到达精确的目标位置
    MouseMove endX, endY, 20
    Sleep 200
    
    ; 释放左键
    Click "Up"
    Sleep 300
}
