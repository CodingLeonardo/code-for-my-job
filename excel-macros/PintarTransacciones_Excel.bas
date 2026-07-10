Attribute VB_Name = "PintarTransacciones"
Option Explicit

Private Const COLOR_GOLD   As Long = 55295
Private Const COLOR_ORANGE As Long = 36095
Private Const COLOR_BLUE   As Long = 15570276
Private Const COLOR_RED    As Long = 255
Private Const FIRST_ROW    As Long = 2

Public Sub PintarTransacciones()
    Dim ws As Worksheet
    Dim lastRow As Long
    Dim i As Long, colored As Long
    
    On Error Resume Next
    
    If ActiveWorkbook Is Nothing Then
        MsgBox "No hay documento activo.", vbExclamation: Exit Sub
    End If
    Set ws = ActiveWorkbook.Sheets("Data")
    If ws Is Nothing Then
        MsgBox "La hoja 'Data' no existe.", vbExclamation: Exit Sub
    End If
    
    lastRow = ws.UsedRange.Rows.Count + ws.UsedRange.Row - 1
    If lastRow < FIRST_ROW Then
        MsgBox "No hay filas para pintar.", vbExclamation: Exit Sub
    End If
    
    Dim screenState As Boolean
    screenState = Application.ScreenUpdating
    Application.ScreenUpdating = False
    
    For i = FIRST_ROW To lastRow
        Dim desc As String
        desc = LCase(Trim(CStr(ws.Cells(i, 4).Value)))
        If Len(desc) = 0 Then GoTo NextRow
        
        Dim c As Long: c = -1
        
        If InStr(desc, "retirada") > 0 Or InStr(desc, "rollback de apuesta") > 0 Or InStr(desc, "apuesta rollback") > 0 Then
            c = COLOR_RED
        ElseIf Left(desc, 3) = "dep" Or InStr(desc, "deposito") > 0 Or InStr(desc, "depósito") > 0 Then
            c = COLOR_GOLD
        ElseIf InStr(desc, "giros gratis") > 0 Or InStr(desc, "giro gratis") > 0 _
            Or InStr(desc, "ganada por giros") > 0 Or InStr(desc, "ganado por giros") > 0 Then
            c = COLOR_GOLD
        ElseIf InStr(desc, "bono") > 0 Then
            c = COLOR_BLUE
        ElseIf InStr(desc, "retiro") > 0 Then
            c = COLOR_ORANGE
        End If
        
        If c >= 0 Then
            ws.Range("A" & i & ":G" & i).Interior.Color = c
            colored = colored + 1
        End If
NextRow:
    Next i
    
    Application.ScreenUpdating = screenState
    Application.StatusBar = ""
    ActiveWorkbook.Save
    MsgBox "OK. Filas pintadas: " & colored, vbInformation, "PintarTransacciones"
End Sub

Public Sub QuitarColores()
    Dim ws As Worksheet
    On Error Resume Next
    Set ws = ActiveWorkbook.Sheets("Data")
    If ws Is Nothing Then Exit Sub
    
    Dim lastRow As Long
    lastRow = ws.UsedRange.Rows.Count + ws.UsedRange.Row - 1
    If lastRow >= 1 Then
        ws.Range("A1:G" & lastRow).Interior.ColorIndex = xlColorIndexNone
    End If
    ActiveWorkbook.Save
    MsgBox "Colores eliminados.", vbInformation, "PintarTransacciones"
End Sub
