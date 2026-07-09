' =================================================================
'  PintarTransacciones.bas  -  VERSIÓN OPTIMIZADA Y ROBUSTA
'
'  Optimizaciones para archivos grandes:
'   1) oDoc.lockControllers() suprime redibujado de pantalla.
'   2) Los colores se aplican por RANGO CONTIGUO del mismo color,
'      no celda por celda.
'   3) Manejo defensivo de errores con MsgBox informativo si algo
'      se sale del rango, así podemos localizar el problema exacto.
' =================================================================

Option Explicit

' ---------- Colores ----------
Const COLOR_GOLD   As Long = 16776960   ' RGB(255, 215, 0)   - Dorado
Const COLOR_ORANGE As Long = 16744448   ' RGB(255, 140, 0)   - Naranja
Const COLOR_BLUE   As Long = 6591981    ' RGB(100, 149, 237) - Azul claro
Const COLOR_RED    As Long = 16711680   ' RGB(255, 0, 0)     - Rojo

' -----------------------------------------------------------------
'  Helper StatusBar
' -----------------------------------------------------------------
Sub SetStatusText(oDoc As Object, sText As String)
    On Error Resume Next
    Dim oFrame As Object, oLM As Object, oBar As Object
    oFrame = oDoc.getCurrentController().getFrame()
    If NOT IsNull(oFrame) Then
        oLM = oFrame.LayoutManager
        If NOT IsNull(oLM) Then
            oBar = oLM.getElement("private:resource/statusbar/statusbar")
            If NOT IsNull(oBar) Then oBar.setStatusText(sText)
        End If
    End If
    On Error Goto 0
End Sub

' -----------------------------------------------------------------
'  Parseo numérico seguro
' -----------------------------------------------------------------
Function ParseAmount(oCell As Object) As Double
    On Error Resume Next
    Dim v As Variant
    v = oCell.getValue()
    If IsNumeric(v) Then
        ParseAmount = CDbl(v)
    Else
        ParseAmount = 0
    End If
    On Error Goto 0
End Function

' -----------------------------------------------------------------
'  Extrae Apuesta #N  -> string con los dígitos (o "" si no hay)
' -----------------------------------------------------------------
Function ExtractBetId(desc As String) As String
    On Error Resume Next
    Dim p As Long, ep As Long, ch As String
    ExtractBetId = ""
    p = InStr(1, desc, "Apuesta #", 1)
    If p = 0 Then Exit Function
    p = p + 9   ' longitud de "Apuesta #"
    ep = p
    Do While ep <= Len(desc)
        ch = Mid(desc, ep, 1)
        If ch = "." Or ch = " " Then Exit Do
        ep = ep + 1
    Loop
    If ep > p Then ExtractBetId = Mid(desc, p, ep - p)
    On Error Goto 0
End Function

' -----------------------------------------------------------------
'  Extrae Referencia #N
' -----------------------------------------------------------------
Function ExtractRef(desc As String) As String
    On Error Resume Next
    Dim p As Long, ep As Long, ch As String
    ExtractRef = ""
    p = InStr(1, desc, "Referencia #", 1)
    If p = 0 Then Exit Function
    p = p + 12   ' longitud de "Referencia #"
    ep = p
    Do While ep <= Len(desc)
        ch = Mid(desc, ep, 1)
        If ch = "." Or ch = " " Then Exit Do
        ep = ep + 1
    Loop
    If ep > p Then ExtractRef = Mid(desc, p, ep - p)
    On Error Goto 0
End Function

' -----------------------------------------------------------------
'  Sub principal
' -----------------------------------------------------------------
Sub PintarTransacciones
    Dim oDoc    As Object
    Dim oSheet  As Object
    Dim oCursor As Object
    Dim i       As Long
    Dim j       As Long
    Dim k       As Long
    Dim lastRow As Long
    Dim firstDataRow As Long
    Dim t0       As Double   ' tiempo inicial (segundos)
    Dim t1       As Double   ' tiempo final   (segundos)
    Dim elapsed  As Double   ' duración total
    firstDataRow = 1   ' índice 1 = fila 2 de la hoja

    t0 = Timer         ' arranca cronómetro

    On Error Goto Handler

    oDoc = ThisComponent
    If IsNull(oDoc) Then
        MsgBox "No hay documento activo."
        Exit Sub
    End If
    If NOT oDoc.supportsService("com.sun.star.sheet.SpreadsheetDocument") Then
        MsgBox "Abre el archivo en LibreOffice Calc." : Exit Sub
    End If
    If NOT oDoc.Sheets.hasByName("Data") Then
        MsgBox "No se encontró la hoja 'Data'." : Exit Sub
    End If

    oSheet = oDoc.Sheets.getByName("Data")
    oCursor = oSheet.createCursor()
    oCursor.gotoEndOfUsedArea(False)
    lastRow = oCursor.getRangeAddress().EndRow

    If lastRow < firstDataRow Then
        MsgBox "La hoja 'Data' no tiene filas para pintar." : Exit Sub
    End If

    ' ---------- Arrays con margen de seguridad ----------
    ' Usamos (lastRow + 1) para tener un elemento extra por seguridad.
    Dim descs()  As String
    Dim colors() As Long
    ReDim descs(lastRow + 1)
    ReDim colors(lastRow + 1)

    ' ---------- Cargar descripciones a memoria (UNA pasada) ----------
    For i = firstDataRow To lastRow
        On Error Resume Next
        descs(i) = oSheet.getCellByPosition(3, i).getString()
        If Err <> 0 Then
            descs(i) = ""
            Err.Clear
        End If
        On Error Goto 0
    Next i

    ' ============================================================
    '  PRE-PASADA 1: pares Retiro + Deposito del mismo proveedor
    ' ============================================================
    Dim paired() As Boolean
    Dim pairCount As Long
    ReDim paired(lastRow + 1)

    For i = firstDataRow To lastRow - 1
        If paired(i) Then GoTo NextPair1

        Dim descA As String, descB As String
        Dim platA As String, platB As String
        Dim da As String, db As String
        Dim eg1 As Double, ig1 As Double

        On Error Resume Next
        platA = oSheet.getCellByPosition(2, i).getString()
        platB = oSheet.getCellByPosition(2, i + 1).getString()
        eg1   = ParseAmount(oSheet.getCellByPosition(4, i))
        ig1   = ParseAmount(oSheet.getCellByPosition(5, i + 1))
        On Error Goto 0

        da = LCase(descs(i))
        db = LCase(descs(i + 1))

        If eg1 > 0 And ig1 > 0 _
           And Abs(eg1 - ig1) < 0.01 _
           And platA = platB _
           And Len(platA) > 0 _
           And InStr(da, "retiro") > 0 _
           And (InStr(db, "deposito") > 0 Or InStr(db, "depósito") > 0) _
           And Not paired(i + 1) Then
            paired(i)     = True
            paired(i + 1) = True
            pairCount = pairCount + 1
        End If
NextPair1:
    Next i

    ' ============================================================
    '  PRE-PASADA 2: egreso ligado a una retirada por referencia
    ' ============================================================
    Dim redPaired() As Boolean
    Dim redPairCount As Long
    ReDim redPaired(lastRow + 1)

    ' Arrays paralelos para los índices encontrados
    Dim egresoRefs()  As String
    Dim egresoRows()  As Long
    Dim egresoCount   As Long
    Dim retirBets()   As String
    Dim retirRows()   As Long
    Dim retirCount    As Long
    ReDim egresoRefs(lastRow + 1)
    ReDim egresoRows(lastRow + 1)
    ReDim retirBets(lastRow + 1)
    ReDim retirRows(lastRow + 1)

    For i = firstDataRow To lastRow
        Dim d As String
        d = descs(i)
        If Len(d) = 0 Then GoTo NextIndex
        If InStr(d, "Apuesta #") = 0 Then GoTo NextIndex
        If InStr(d, "Referencia #") = 0 Then GoTo NextIndex

        Dim betIdStr As String, refStr As String
        betIdStr = ExtractBetId(d)
        refStr   = ExtractRef(d)
        If Len(betIdStr) = 0 Or Len(refStr) = 0 Then GoTo NextIndex

        ' Validar que retirCount / egresoCount no excedan el array
        If InStr(LCase(d), "retirada") > 0 Then
            If retirCount <= lastRow Then
                retirBets(retirCount) = betIdStr
                retirRows(retirCount) = i
                retirCount = retirCount + 1
            End If
        Else
            If egresoCount <= lastRow Then
                egresoRefs(egresoCount) = refStr
                egresoRows(egresoCount) = i
                egresoCount = egresoCount + 1
            End If
        End If
NextIndex:
    Next i

    ' Emparejar
    Dim egRow As Long, rtRow As Long
    Dim targetBet As String
    For k = 0 To retirCount - 1
        targetBet = retirBets(k)
        If Len(targetBet) = 0 Then GoTo NextMatch
        For j = 0 To egresoCount - 1
            If egresoRefs(j) = targetBet Then
                egRow = egresoRows(j)
                rtRow = retirRows(k)
                If egRow >= firstDataRow And egRow <= lastRow Then
                    If Not redPaired(egRow) Then
                        redPaired(egRow) = True
                        redPairCount = redPairCount + 1
                    End If
                End If
                If rtRow >= firstDataRow And rtRow <= lastRow Then
                    If Not redPaired(rtRow) Then
                        redPaired(rtRow) = True
                        redPairCount = redPairCount + 1
                    End If
                End If
                Exit For
            End If
        Next j
NextMatch:
    Next k

    ' ============================================================
    '  CLASIFICACIÓN en memoria -> colors()
    ' ============================================================
    Dim colored As Long
    For i = firstDataRow To lastRow
        Dim ldesc As String
        ldesc = LCase(descs(i))
        If Len(Trim(ldesc)) = 0 Then
            colors(i) = -1
            GoTo NextClassify
        End If

        colors(i) = -1

        ' 1) Apuesta retirada / rollback -> ROJO
        If InStr(ldesc, "retirada") > 0 _
           Or InStr(ldesc, "rollback de apuesta") > 0 _
           Or InStr(ldesc, "apuesta rollback") > 0 Then
            colors(i) = COLOR_RED
        ' 2) Depósitos / giros gratis -> DORADO
        ElseIf InStr(ldesc, "dep") = 1 _
            Or InStr(ldesc, "deposito") > 0 _
            Or InStr(ldesc, "depósito") > 0 Then
            colors(i) = COLOR_GOLD
        ElseIf InStr(ldesc, "giros gratis") > 0 _
            Or InStr(ldesc, "giro gratis") > 0 _
            Or InStr(ldesc, "ganada por giros") > 0 _
            Or InStr(ldesc, "ganado por giros") > 0 Then
            colors(i) = COLOR_GOLD
        ' 3) Bonos -> AZUL
        ElseIf InStr(ldesc, "bono") > 0 Then
            colors(i) = COLOR_BLUE
        ' 4) Retiros -> NARANJA
        ElseIf InStr(ldesc, "retiro") > 0 Then
            colors(i) = COLOR_ORANGE
        End If

        ' 5) Par Retiro+Deposito -> NARANJA (no aplasta ROJO)
        If paired(i) And colors(i) <> COLOR_RED Then
            colors(i) = COLOR_ORANGE
        End If

        ' 6) Egreso ligado a retirada por referencia -> ROJO
        If redPaired(i) Then
            colors(i) = COLOR_RED
        End If

        If colors(i) >= 0 Then colored = colored + 1
NextClassify:
    Next i

    ' ============================================================
    '  APLICACIÓN POR RANGOS CONTIGUOS
    ' ============================================================
    On Error Resume Next
    oDoc.lockControllers()
    On Error Goto 0

    SetStatusText(oDoc, "Aplicando colores...")

    Dim runStart As Long, runColor As Long, runEnd As Long
    Dim addr As String, oRange As Object
    i = firstDataRow
    Do While i <= lastRow
        If colors(i) < 0 Then
            i = i + 1
        Else
            runStart = i
            runColor = colors(i)
            ' extender mientras sea del mismo color y dentro del rango
            Do While i <= lastRow And colors(i) = runColor
                i = i + 1
            Loop
            runEnd = i - 1
            addr = "A" & (runStart + 1) & ":G" & (runEnd + 1)

            On Error Resume Next
            oRange = oSheet.getCellRangeByName(addr)
            If Err = 0 And NOT IsNull(oRange) Then
                oRange.CellBackColor = runColor
            Else
                Err.Clear
            End If
            On Error Goto 0
        End If
    Loop

    On Error Resume Next
    oDoc.unlockControllers()
    On Error Goto 0

    SetStatusText(oDoc, "Guardando...")
    oDoc.store()
    SetStatusText(oDoc, "")

    t1 = Timer
    elapsed = t1 - t0
    If elapsed < 0 Then elapsed = elapsed + 86400   '跨界 al día siguiente

    MsgBox "OK. Filas pintadas: " & colored & Chr(10) _
         & "Pares Retiro+Deposito: " & pairCount & Chr(10) _
         & "Filas ROJO ligadas a retirada: " & redPairCount & Chr(10) _
         & "Recorrido: de arriba (fila 2) hacia abajo (fila " & (lastRow + 1) & ")." & Chr(10) _
         & "Tiempo total: " & Format(elapsed, "0.00") & " segundos"
    Exit Sub

' ----------------------------------------------------------------
'  Manejo de errores
' ----------------------------------------------------------------
Handler:
    On Error Resume Next
    oDoc.unlockControllers()
    On Error Goto 0
    t1 = Timer
    elapsed = t1 - t0
    If elapsed < 0 Then elapsed = elapsed + 86400
    MsgBox "Error en el macro:" & Chr(10) _
         & "  Código: " & Err & Chr(10) _
         & "  Mensaje: " & Error$ & Chr(10) _
         & "  Línea ~" & Erl & Chr(10) _
         & "  Última fila leída: " & lastRow & Chr(10) _
         & "  Iteración: " & i & Chr(10) _
         & "  Tiempo transcurrido antes del error: " & Format(elapsed, "0.00") & " s", _
         16, "PintarTransacciones - Error"
End Sub

' -----------------------------------------------------------------
'  Quitar colores (top-down, optimizado)
' -----------------------------------------------------------------
Sub QuitarColores
    Dim oDoc    As Object
    Dim oSheet  As Object
    Dim oCursor As Object
    Dim lastRow As Long

    oDoc = ThisComponent
    If IsNull(oDoc) Then Exit Sub
    oSheet = oDoc.Sheets.getByName("Data")
    oCursor = oSheet.createCursor()
    oCursor.gotoEndOfUsedArea(False)
    lastRow = oCursor.getRangeAddress().EndRow

    On Error Resume Next
    oDoc.lockControllers()
    If lastRow >= 0 Then
        oSheet.getCellRangeByName("A1:G" & (lastRow + 1)).CellBackColor = -1
    End If
    oDoc.unlockControllers()
    On Error Goto 0

    oDoc.store()
    MsgBox "Colores eliminados."
End Sub
