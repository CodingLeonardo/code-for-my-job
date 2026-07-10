# PintarTransacciones — Macro para Excel

Macro en VBA que colorea automáticamente las transacciones de un libro de Excel según su tipo (depósitos, retiros, bonos, apuestas retiradas, giros gratis, etc.).

## Archivos

| Archivo                         | Descripción                                                   |
| ------------------------------- | ------------------------------------------------------------- |
| `PintarTransacciones_Excel.bas` | Código fuente del macro para Excel VBA.                       |
| `PintarTransacciones.bas`       | Versión original para LibreOffice Calc (no usar en Excel).    |
| `PERSONAL_MACROS.xlsm`          | Libro de macros personal de Excel con el módulo ya importado. |

## Cómo usar

### Opción 1 — Desde PERSONAL_MACROS (recomendado)

1. Abre Excel.
2. Abre el archivo `.xlsx` o `.xlsm` que quieras procesar.
3. Ve a la pestaña **Desarrollador** → **Macros**.
4. Selecciona `PintarTransacciones` y haz clic en **Ejecutar**.

> Si no ves la pestaña Desarrollador, actívala en:  
> `Archivo → Opciones → Personalizar cinta → Activar "Desarrollador"`

### Opción 2 — Importar el módulo a cualquier libro

1. Abre el libro destino en Excel.
2. `Alt + F11` para abrir el editor de VBA.
3. `Menú → Archivo → Importar archivo` y selecciona `PintarTransacciones_Excel.bas`.
4. Cierra el editor y ejecuta el macro desde `Desarrollador → Macros → PintarTransacciones`.

## Requisitos del libro

- Debe tener una hoja llamada **`Data`** (exactamente, con mayúscula inicial).
- Las columnas deben estar en este orden:

| Columna | Contenido   |
| ------- | ----------- |
| A       | Fecha       |
| B       | Id          |
| C       | Plataforma  |
| D       | Descripción |
| E       | Egreso      |
| F       | Ingreso     |
| G       | Balance     |

- La fila 1 se considera encabezados. Los datos empiezan en la fila 2.

## Colores

| Color   | Categoría                      | Criterio en descripción                                                     |
| ------- | ------------------------------ | --------------------------------------------------------------------------- |
| Dorado  | Depósitos / Giros gratis       | Empieza con "dep" o contiene "depósito", "giros gratis", "ganada por giros" |
| Naranja | Retiros                        | Contiene "retiro" (sin ser "retirada")                                      |
| Azul    | Bonos                          | Contiene "bono"                                                             |
| Rojo    | Apuestas retiradas / Rollbacks | Contiene "retirada", "rollback de apuesta" o "apuesta rollback"             |

## Solución de problemas

- **"La hoja 'Data' no existe"**: El libro activo no tiene una hoja con ese nombre. Renombra la hoja o selecciona el libro correcto.
- **No se aplican colores**: Verifica que las descripciones estén en la columna D y que contengan palabras clave como "Depósito", "Retiro", "Bono", etc.
- **Error de seguridad**: Ve a `Archivo → Opciones → Centro de confianza → Configuración del Centro de confianza → Configuración de macros` y habilita "Habilitar todas las macros" o "Habilitar macros digitalmente firmadas".

## Macro: QuitarColores

También está disponible el sub `QuitarColores` que elimina todos los colores de fondo del rango A1:G de la hoja Data, dejándola limpia para volver a ejecutar `PintarTransacciones`.
