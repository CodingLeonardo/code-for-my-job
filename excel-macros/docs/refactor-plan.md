Plan de Refactorización: PintarTransacciones.bas → Excel VBA
=========================================================
Fecha: 2026-07-09
Autor: Leonardo Rivero

1. Objetivo
-----------
Traducir el macro PintarTransacciones.bas (LibreOffice Calc Basic)
a Excel VBA respetando la misma lógica de negocio y estructura,
corrigiendo únicamente las diferencias de API y el formato de color.


2. Archivos
-----------
- Original (intacto):    excel-macros/PintarTransacciones.bas
- Nuevo (Excel VBA):     excel-macros/PintarTransacciones_Excel.bas
- Plan:                  excel-macros/docs


3. Diferencias LibreOffice → Excel VBA
---------------------------------------
  LibreOffice Calc              Excel VBA
  ────────────────────────      ──────────────────────────────
  ThisComponent                 ThisWorkbook
  Sheets.getByName("Data")      Worksheets("Data")
  getCellByPosition(c, r)       .Cells(r + 1, c + 1)
  createCursor().               Cells(Rows.Count,1).End(xlUp).Row
    gotoEndOfUsedArea().EndRow
  CellBackColor = n             .Interior.Color = RGB(...)
  lockControllers()             Application.ScreenUpdating = False
  unlockControllers()           Application.ScreenUpdating = True
  store()                       ThisWorkbook.Save
  Timer → Double                Timer → Single (misma semántica)
  LayoutManager.StatusBar       Application.StatusBar
  MsgBox "...", 16, "..."       MsgBox "...", vbCritical, "..."


4. Cambio crítico: Formato de color
-------------------------------------
LibreOffice Calc usa CellBackColor en formato 0x00RRGGBB.
Excel VBA usa Interior.Color en formato 0x00BBGGRR.

  Constante original (LO)      Equivale a          Problema en Excel
  ─────────────────────────    ────────────────     ────────────────
  COLOR_GOLD   = 16776960      RGB(255,215,0)      Se vería como cian
  COLOR_ORANGE = 16744448      RGB(255,140,0)      Se vería como azul claro
  COLOR_BLUE   = 6591981       RGB(100,149,237)    Se vería como salmón
  COLOR_RED    = 16711680      RGB(255,0,0)        Se vería como rojo (coincide)

Solución: Reemplazar todas las constantes numéricas por la función RGB()
directamente, que produce el formato correcto en cada entorno.


5. Refactorizaciones aplicadas (traducción directa)
----------------------------------------------------
- Se eliminan los On Error Resume Next alrededor de cada getCellByPosition
  (innecesarios con la sintaxis directa .Cells).
- SetStatusText se simplifica a Application.StatusBar.
- Se eliminan comentarios inline extensos que no aportan valor.
- Las variables conservan sus nombres originales para mantener coherencia.
- La estructura de las 3 pasadas (pre-pair 1, pre-pair 2, clasificación)
  y la aplicación por rangos contiguos se mantiene idéntica.


6. Lo que NO se modifica
-------------------------
- Lógica de clasificación de transacciones.
- Algoritmos de emparejamiento (Retiro+Deposito y Referencia#).
- Optimización de rangos contiguos.
- Subrutina QuitarColores.
- Option Explicit.


7. Uso en Excel
---------------
1. Abrir Excel → Alt+F11 → Menú File → Import File
2. Seleccionar PintarTransacciones_Excel.bas
3. Cerrar editor → Alt+F8 → ejecutar PintarTransacciones

Requisitos: La hoja activa debe llamarse "Data" con datos en columnas A-G.
