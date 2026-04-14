#Requires AutoHotkey v2.0
#Include Tools.ahk

imageA := A_ScriptDir "\battle_end_area.png"
imageB := A_ScriptDir "\battle_end_area_1.png"

if !FileExist(imageA) {
    MsgBox "找不到测试图片:`n" imageA
    ExitApp
}

if !FileExist(imageB) {
    MsgBox "找不到测试图片:`n" imageB
    ExitApp
}

tolerance := 20
matchThreshold := 0.90
maxOffset := 1

img1 := ImagePutBuffer(imageA)
img2 := ImagePutBuffer(imageB)

try {
    exactMatch := ImageEqual(img1, img2)
    bestScore := exactMatch ? 1.0 : GetBestImageMatchScore(img1, img2, tolerance, maxOffset)
    tolerantMatch := (bestScore >= matchThreshold)
    offsetReport := ""
    bestOffsetX := 0
    bestOffsetY := 0
    bestOffsetScore := -1.0

    Loop 2 * maxOffset + 1 {
        offsetY := A_Index - maxOffset - 1
        Loop 2 * maxOffset + 1 {
            offsetX := A_Index - maxOffset - 1
            score := CompareImagesWithOffset(img1, img2, tolerance, offsetX, offsetY)
            offsetReport .= Format("offset=({1},{2}), score={3}`n", offsetX, offsetY, Round(score, 4))
            if (score > bestOffsetScore) {
                bestOffsetScore := score
                bestOffsetX := offsetX
                bestOffsetY := offsetY
            }
        }
    }

    report := ""
    report .= "测试图片 1:`n" imageA "`n`n"
    report .= "测试图片 2:`n" imageB "`n`n"
    report .= "图片尺寸:`n"
    report .= "img1 = " img1.width " x " img1.height "`n"
    report .= "img2 = " img2.width " x " img2.height "`n`n"
    report .= "参数:`n"
    report .= "tolerance = " tolerance "`n"
    report .= "matchThreshold = " matchThreshold "`n"
    report .= "maxOffset = " maxOffset "`n`n"
    report .= "结果:`n"
    report .= "ImageEqual(精确匹配) = " (exactMatch ? "true" : "false") "`n"
    report .= "GetBestImageMatchScore = " Round(bestScore, 4) "`n"
    report .= "容差匹配结果 = " (tolerantMatch ? "true" : "false") "`n`n"
    report .= "最佳偏移:`n"
    report .= "bestOffset = (" bestOffsetX ", " bestOffsetY "), score = " Round(bestOffsetScore, 4) "`n`n"
    report .= "各偏移得分:`n"
    report .= offsetReport

    LogMessage("=== TestImageMatch ===")
    LogMessage(StrReplace(report, "`n", " | "))
    MsgBox report, "ImageMatch 测试结果"
} finally {
    try ImagePut.Destroy(img1)
    try ImagePut.Destroy(img2)
}
