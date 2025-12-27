#Requires AutoHotkey v2.0
#Include ImagePut.ahk

; 创建日志函数
LogMessage(message) {
    timestamp := FormatTime(, "yyyy-MM-dd HH:mm:ss")
    logEntry := timestamp " - " message "`n"
    FileAppend logEntry, "script_log.txt"
}

IsImageMatch(hWnd, coords, imageMap, imageKey, tolerance := 20, matchThreshold := 0.90) {
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
        ; result := SimpleGrayCompare(screenshot, imageMap[imageKey], tolerance, matchThreshold)

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

; SimpleGrayCompare(img1, img2, tolerance, matchThreshold) {
;     try {
;         ; 使用 ImagePut 的方法获取图像尺寸
;         width1 := ImageWidth(img1)
;         height1 := ImageHeight(img1)
;         width2 := ImageWidth(img2)
;         height2 := ImageHeight(img2)
;         LogMessage(width1 " " height1)
        
;         if (width1 != width2 || height1 != height2) {
;             LogMessage("图像尺寸不匹配: " width1 "x" height1 " vs " width2 "x" height2)
;             return false
;         }
        
;         ; 初始化计数器
;         matchCount := 0
;         totalPixels := width1 * height1
        
;         ; 遍历每个像素进行比较
;         Loop height1 {
;             y := A_Index - 1
;             Loop width1 {
;                 x := A_Index - 1
                
;                 ; 获取两个图像在相同位置的像素颜色
;                 color1 := ImagePutPixel(img1, x, y)
;                 color2 := ImagePutPixel(img2, x, y)
                
;                 ; 将RGB颜色转换为灰度值
;                 gray1 := RGBToGray(color1)
;                 gray2 := RGBToGray(color2)
                
;                 ; 使用tolerance判断两个灰度值是否"相似"
;                 if (Abs(gray1 - gray2) <= tolerance) {
;                     matchCount++  ; 相似像素计数+1
;                 }
;             }
;         }
        
;         ; 计算相似度比例
;         similarity := matchCount / totalPixels
;         LogMessage("图像相似度: " Round(similarity * 100, 2) "%")
        
;         ; 使用matchThreshold判断是否匹配成功
;         return similarity >= matchThreshold
;     } catch Error as e {
;         LogMessage("图像比较过程出错: " e.Message)
;         return false
;     }
; }

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