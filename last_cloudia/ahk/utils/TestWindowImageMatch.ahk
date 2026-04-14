#Requires AutoHotkey v2.0
#Include Tools.ahk

referenceImage := A_ScriptDir "\battle_end_area.png"
testImage := A_ScriptDir "\battle_end_area_1.png"
imageKey := "battle_end_area"

if !FileExist(referenceImage) {
    MsgBox "找不到参考图片:`n" referenceImage
    ExitApp
}

if !FileExist(testImage) {
    MsgBox "找不到测试图片:`n" testImage
    ExitApp
}

referenceBuffer := ImagePutBuffer(referenceImage)

try {
    width := referenceBuffer.width
    height := referenceBuffer.height

    coords := Map()
    coords[imageKey] := {x1: 0, y1: 0, x2: width, y2: height}

    imageMap := Map()
    imageMap[imageKey] := referenceBuffer

    testGui := Gui("+AlwaysOnTop +ToolWindow", "IsImageMatch Test")
    testGui.BackColor := "Black"
    testGui.MarginX := 0
    testGui.MarginY := 0
    testGui.AddPicture("x0 y0 w" width " h" height, testImage)
    testGui.Show("AutoSize")

    ; 等待窗口完成绘制，确保截图拿到的是最终内容
    Sleep 300

    tolerance := 20
    matchThreshold := 0.90
    maxOffset := 1

    result := IsImageMatch(testGui.Hwnd, coords, imageMap, imageKey, tolerance, matchThreshold, maxOffset)
    screenshot := ImagePutBuffer({
        window: testGui.Hwnd,
        crop: [0, 0, width, height]
    })
    directScore := GetBestImageMatchScore(screenshot, imageMap[imageKey], tolerance, maxOffset)

    report := ""
    report .= "直接调用 IsImageMatch 测试`n`n"
    report .= "参考图:`n" referenceImage "`n`n"
    report .= "被测图:`n" testImage "`n`n"
    report .= "区域: " imageKey "`n"
    report .= "尺寸: " width " x " height "`n`n"
    report .= "参数:`n"
    report .= "tolerance = " tolerance "`n"
    report .= "matchThreshold = " matchThreshold "`n"
    report .= "maxOffset = " maxOffset "`n`n"
    report .= "结果:`n"
    report .= "IsImageMatch = " (result ? "true" : "false") "`n"
    report .= "GetBestImageMatchScore = " Round(directScore, 4) "`n`n"
    report .= "详细日志可查看 script_log.txt"

    MsgBox report, "IsImageMatch 测试结果"
} finally {
    try ImagePut.Destroy(screenshot)
    try testGui.Destroy()
    try ImagePut.Destroy(referenceBuffer)
}
