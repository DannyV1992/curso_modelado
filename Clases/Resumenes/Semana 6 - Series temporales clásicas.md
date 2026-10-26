# Semana 6: Series temporales clásicas

**Curso:** BCD5105 Modelado matemático, Lead University (III cuatrimestre 2026, virtual)

**Docente:** Jordy Alfaro Brenes

**Fecha:** jueves 15 de octubre de 2026

**PDF fuente:** `Clases/PDFs/Semana 6 - Series temporales clasicas 2.pdf`

**Cobertura del PDF:** Completo (diapositivas 1 a 36). La actividad en salas (diapositiva 34) no se realizó por falta de tiempo; quedó como tarea moral en el aula virtual. La diapositiva 12 es un espacio de trabajo (allí se resolvió el ejemplo 1) y los tres ejercicios de la diapositiva 13 quedan como tarea moral.

**Tramos solo del PDF:** la transcripción pierde unos 38 minutos de la demostración en R (de la diapositiva 17, el `tsibble`, hasta la 27, la comparación SARIMA contra SNAIVE). Las diapositivas 17 a 27 salen del PDF, salvo lo poco que se alcanza a oír al inicio (diapositivas 15 a 17) y al final de ese tramo (diapositiva 27). La validación con ventana expansiva (diapositiva 28) sí está en la transcripción y coincide con el PDF.

**Contexto:** la semana pasada terminó con `TimeSeriesSplit` y la advertencia de no barajar datos con reloj; esta semana ese reloj pasa a ser el protagonista. Es menos matemática a mano que en las semanas anteriores (la matemática de las series de tiempo es pesada de hacer a mano) y más conceptual y aplicada. Un curso completo de series de tiempo dura uno o dos semestres: aquí se condensa en una sesión. La clase tiene dos partes: las ideas y el flujo completo en **R** con `fpp3` (R es un lenguaje hecho para estadísticos y se presta muy bien a series; en Python, `statsmodels` tiene STL y SARIMAX con la misma lógica).

**Objetivos:** reconocer tendencia, estacionalidad, ciclo y ruido; explicar qué es una serie estacionaria y cómo la diferenciación la consigue; leer una ACF y traducir ARIMA y SARIMA a palabras; descomponer, modelar, diagnosticar y pronosticar una serie con `fpp3`; validar un pronóstico sin hacer trampa y compararlo con un modelo ingenuo.

| Bloque | Tema | Diapositivas |
|---|---|---|
| 1 | Qué es una serie y sus ingredientes | 4–6 |
| 2 | Estacionariedad y diferencias | 7–8 |
| 3 | ACF y ARIMA, en palabras (con ejemplos y ejercicios) | 9–13 |
| — | Receso | — |
| 4 | R: `tsibble`, exploración y STL | 14–21 |
| 5 | R: ARIMA, residuos y pronóstico | 22–26 |
| 6 | Validar contra el ingenuo | 27–28 |
| 7 | Datos para el proyecto, competencias M, modelos de fundación y síntesis | 29–32 |
| 8 | Proyecto, calendario y cierre | 33–36 |
| — | Actividad en salas (no realizada) | 34 |

---

# Parte 1: Las ideas (diapositivas 3–13)

## 1. ¿Qué es una serie de tiempo? (diapositiva 4)

- Una **observación por período** (mes, trimestre, año, día), **siempre en orden**. Ejemplo: llegadas mensuales de turistas entre 2010 y 2020.
- **Lo que cambia respecto al resto del curso:**
  - El dato de hoy se parece al de ayer: hay **memoria**.
  - No se pueden barajar los datos. Se puede tomar una muestra, pero siempre respetando el orden: no sirve entrenar con 2025 y probar con 2024.
  - Se rompe la **independencia** de la regresión.
- **Pronosticar es usar esa memoria.** La pregunta de la sesión: ¿cuántos turistas llegarán el mes que viene y con cuánta confianza?

## 2. La receta: cuatro ingredientes (diapositiva 5)

Toda serie mezcla **tendencia**, **estacionalidad**, **ciclo** y **ruido**.

| Ingrediente | Qué es |
|---|---|
| Tendencia | Dirección de largo plazo (aquí, creciente pero suave) |
| Estacionalidad | Patrón con **período fijo y conocido**: cada 12 meses, 7 días o 4 trimestres. Ejemplo: una juguetería vende más cada diciembre |
| Ciclo | Oscilación **sin período fijo**: una recesión puede durar 2 años o 7 |
| Ruido | Lo que la serie no explica |

> **Nota:** en `fpp3` el ciclo no se agrupa con la estacionalidad sino con la tendencia (componente tendencia-ciclo). Por eso la descomposición estándar solo muestra tendencia, estacionalidad y resto.

- **Modelar es separar la receta:** quitar lo predecible (tendencia y estacionalidad) y quedarse con el ruido. Si en el ruido todavía hay un patrón, el modelo dejó algo sin capturar: el ruido debe ser literalmente aleatorio.

## 3. ¿La oscilación es pareja o crece? (diapositiva 6)

| | Aditiva | Multiplicativa |
|---|---|---|
| Se ve como | Oscilación pareja: las "montañitas" miden lo mismo aunque la serie suba | La oscilación crece junto con la serie |
| Fórmula | serie = tendencia + estacionalidad + ruido | serie = tendencia × estacionalidad × ruido |
| Ejemplos | | Turismo, ventas, series económicas en general |

- Basta **graficar la serie** para decidir cuál usar.
- **Truco del logaritmo:** como $\ln(a\cdot b)=\ln a+\ln b$, aplicar $\ln$ convierte la serie multiplicativa en aditiva:
$$\ln(\text{serie})=\ln T+\ln E+\ln R$$
Es una técnica muy usada en la industria.

## 4. Estacionariedad: la prueba de la ventana (diapositiva 7)

> **Estacionalidad ≠ estacionariedad.** La primera es un patrón que se repite (la juguetería); la segunda es una propiedad de la serie completa.

- **Prueba de la ventana:** ¿la serie se ve igual sin importar en qué ventana (pedazo) se mire? Una serie es **estacionaria** si su **media y su variabilidad no dependen del momento**: cualquier ventana se parece a cualquier otra.
- En una serie no estacionaria (p. ej. con tendencia), la media y la varianza de una ventana son muy distintas a las de otra.
- **Por qué importa:** ARIMA **solo sabe modelar series estacionarias**. La tendencia y la estacionalidad hay que quitarlas primero.
- **Proceso:** convertir la serie en estacionaria y, solo entonces, modelarla con ARIMA.

## 5. Micro ejemplo: diferenciar (diapositiva 8)

**Diferenciar es restarle a la serie su memoria.** Ventas trimestrales (millones de dólares):

| Trimestre | $y$ | $y_t-y_{t-1}$ | $y_t-y_{t-4}$ |
|---|---|---|---|
| 2022 T1 | 10 | — | — |
| 2022 T2 | 14 | 4 | — |
| 2022 T3 | 8 | −6 | — |
| 2022 T4 | 12 | 4 | — |
| 2023 T1 | 14 | 2 | 4 |
| 2023 T2 | 18 | 4 | 4 |
| 2023 T3 | 12 | −6 | 4 |
| 2023 T4 | 16 | 4 | 4 |

- **Primera diferencia** $y_t-y_{t-1}$: elimina la **tendencia**, pero sigue un patrón (4, −6, 4, …) que se repite cada 4 trimestres: queda estacionalidad.
- **Diferencia estacional** $y_t-y_{t-m}$ (aquí $m=4$ porque un año tiene cuatro trimestres): elimina también la **estacionalidad**. Queda una constante (4).
- Los guiones aparecen porque no hay observación anterior con quién restar.
- En R, esto lo hace `difference()`: `difference(y)` para la ordinaria y `difference(y, 4)` para la estacional.

## 6. ACF y PACF: la serie comparada consigo misma (diapositiva 9)

- **ACF** (función de autocorrelación): correlación entre la serie y una copia suya **corrida $k$ pasos** (el rezago). Se grafica como barras por rezago.
- **Franja azul:** lo que el azar puede producir; las barras que la superan son memoria real.

| Forma de la ACF | Lectura |
|---|---|
| Todas las barras dentro de la franja | Ruido: nada que aprender |
| Barras altas que **decaen muy despacio** | **Tendencia** |
| Barras que **repuntan** cada 12 rezagos (12, 24, 36) | **Estacionalidad** anual |

- **PACF** (autocorrelación parcial): igual, pero descontando los rezagos intermedios, por lo que mide la relación **directa**.

## 7. ARIMA y SARIMA, en palabras (diapositiva 10)

| Letras | Significado |
|---|---|
| **AR** (autorregresivo) | Hoy depende de mis valores pasados |
| **I** (integrado) | Cuántas veces diferencié para aplanar la serie |
| **MA** (media móvil) | Hoy corrijo con mis errores pasados |
| **S** (estacional) | SARIMA es un ARIMA con componente estacional |

$$\text{SARIMA}(p,d,q)(P,D,Q)_m$$

- **Minúsculas = corto plazo** (mes a mes); **mayúsculas = ciclo anual** (el mismo mes del año pasado). Es la misma idea aplicada dos veces. $m$ es el período (12 en datos mensuales, 4 en trimestrales, 7 en diarios).
- **Cuándo conviene SARIMA:** cuando hay estacionalidad. Ejemplos: la juguetería (cada año) o un restaurante (los domingos se parecen entre sí, estacionalidad cada 7 días; un modelo así se hizo para una cadena grande).
- **Modelo de aerolínea:** $\text{ARIMA}(0,1,1)(0,1,1)_{12}$. Tiene una diferencia ordinaria, una estacional y un poco de memoria de errores en cada parte, sin componente autorregresivo. Es el clásico para series mensuales.
- **¿Cómo elegir los órdenes?**
  - En teoría, deducirlos de la ACF y la PACF (lo recomendado por los expertos, porque a veces el automático no da el mejor).
  - En la práctica, **auto-ARIMA** (`ARIMA()` en R): la computadora prueba varios modelos, mide cada uno con una métrica de error y se queda con el mejor. Es una buena opción para quien empieza y su experiencia es que suele coincidir con lo deducido a ojo.
  - Para el proyecto, usar auto-ARIMA es suficiente.

> **Nota:** en Python hay un equivalente, `auto_arima` de la librería `pmdarima`.

## 8. Ejemplos y ejercicios (diapositivas 11–13)

**Ejemplo 1.** Ventas trimestrales: 30, 42, 24, 36, 33, 45, 27, 39.
- a) **Primera diferencia:** 12, −18, 12, −3, 12, −18, 12. Se fue el crecimiento, pero el patrón sigue.
- b) **Diferencia estacional** ($m=4$): 3, 3, 3, 3.
- c) **Qué queda:** una constante. Cada trimestre vende 3 más que el mismo trimestre del año anterior (tendencia lineal suave), sobre un patrón trimestral fijo: alto en el trimestre 2 y bajo en el 3.
- **Con datos reales** la diferencia estacional no sale exactamente constante: salen valores como 3.1, 2.9 o 3.12, todos alrededor de un valor. Lo que sobra es el ruido real.

**Ejemplo 2.**
- a) Una ACF que **decae muy despacio** (firma de la tendencia) sugiere una diferencia ordinaria, $d=1$. Que además **repunte en 12 y 24** (firma de la estacionalidad anual) sugiere una diferencia estacional, $D=1$.
- b) $\text{ARIMA}(1,1,0)(0,1,1)_{12}$ en palabras:
  - $d=1$: se diferencia una vez mes a mes.
  - $D=1$: se diferencia una vez contra el mismo mes del año anterior.
  - $p=1$: después de diferenciar, el cambio de este mes depende del cambio del mes anterior.
  - $Q=1$: se corrige con el error cometido en el mismo mes del año pasado (memoria de errores anual).
  - $q=0$ y $P=0$: no hay media móvil ordinaria ni autorregresivo anual.
- c) La llegada de turistas es **multiplicativa**: cuando la serie sube, la diferencia entre temporada alta y baja también crece. Se corrige con un logaritmo.

**Ejercicios (tarea moral):**
1. Serie trimestral 5, 9, 7, 3, 7, 11, 9, 5: calcular ambas diferencias, decir cuál deja una constante y qué significa.
2. Clasificar como aditiva o multiplicativa y justificar: temperatura diaria de San José, ventas mensuales de una tienda que crece rápido, casos semanales de dengue en años de brote.
3. El **modelo ingenuo estacional** pronostica que cada mes repite el valor del mismo mes del año anterior: ¿qué pronostica para enero de 2020 con las llegadas de 2019? ¿Por qué es difícil de superar?

---

# Parte 2: Series temporales en R (diapositivas 14–32)

## 9. El stack de la semana y para qué sirven las series (diapositivas 15–16)

| Paquete | Uso |
|---|---|
| `fpp3` 1.0 | Carga todo de un golpe; acompaña al libro gratuito de Hyndman y Athanasopoulos (otexts.com/fpp3) |
| `tsibble` 1.2 | La tabla que sabe que su índice es el tiempo |
| `fable` 0.5 | Los modelos: `ARIMA()`, `ETS()`, `SNAIVE()` (`STL()` viene de `feasts`) |
| `ggtime` 1.1 | Gráficos de series (`gg_season`, `gg_tsresiduals`) |

- **Colab:** Entorno de ejecución → Cambiar tipo de entorno → R; luego `install.packages("fpp3")` (tarda unos minutos, una vez por sesión) y `library(fpp3)`. Regla de la semana: siempre `library(fpp3)` al inicio.
- **Usos:** turismo (llegadas e itinerarios, estacionalidad anual muy marcada), energía (demanda eléctrica hora a hora con estacionalidad diaria, semanal y anual a la vez), salud pública (casos de dengue por semana epidemiológica, ligados a la temporada de lluvias), comercio y finanzas (ventas, flujos de caja, inventarios).
- **ARIMA y SARIMA siguen siendo la línea base** que cualquier modelo moderno debe superar.

## 10. El protagonista: el objeto `tsibble` (diapositiva 17)

```r
ventas <- tsibble(Trim = yearquarter("2023 Q1") + 0:3,
                  Total = c(120, 90, 105, 160), index = Trim)
```

- Es una tabla que sabe que **el tiempo es su eje**: `[1Q]` indica una observación por trimestre, sabe que después de 2023 T4 viene 2024 T1 y detecta huecos en el calendario.
- Los índices de calendario se crean con `yearmonth()`, `yearquarter()` y `yearweek()`.
- Graficar, descomponer, modelar y validar: todo el ecosistema recibe un `tsibble`.

## 11. La serie de hoy: turismo simulado (diapositiva 18)

120 meses (2010–2019) al estilo de las llegadas del ICT: tendencia de **+650 llegadas por mes**, patrón estacional fijo **multiplicativo** y ruido de 4.5 %.

- **Por qué simulada:** se conoce la verdad (para comprobar que el modelo la recupera) y se evita el quiebre de la pandemia de la serie real.

## 12. Mirar antes de modelar: `gg_season` (diapositiva 19)

`turismo |> gg_season(Llegadas)` dibuja un año por línea, superpuestos sobre los 12 meses.

- **Forma de cada línea:** alto de diciembre a marzo y bajo en setiembre: la estacionalidad.
- **Altura de las líneas:** los años recientes van más arriba: la tendencia.

## 13. ACF y PACF de la serie (diapositiva 20)

```r
turismo |> gg_tsdisplay(Llegadas, plot_type = "partial")
```

La ACF repunta en 12, 24 y 36 (0.82 en el rezago 12): estacionalidad anual muy marcada. Hace falta al menos una diferencia estacional; la prueba KPSS lo confirma después.

## 14. Descomposición STL: separar la receta (diapositiva 21)

```r
turismo |> model(STL(Llegadas ~ trend() + season(window = "periodic"), robust = TRUE)) |>
  components() |> autoplot()
```

- Separa una **tendencia** suave que sube, una **estacionalidad** que se repite cada 12 meses y un **resto** pequeño.
- `robust = TRUE` evita que un mes atípico deforme la tendencia.

## 15. Diferenciar y decidir cuántas veces (diapositiva 22)

```r
turismo |> features(Llegadas, unitroot_kpss)     # kpss_pvalue 0.01
turismo |> features(Llegadas, unitroot_nsdiffs)  # nsdiffs 1
turismo |> features(Llegadas, guerrero)          # lambda_guerrero 0.27
```

- **KPSS** (p = 0.01): la serie **no es estacionaria**. `unitroot_nsdiffs` dice que hace falta **una diferencia estacional**.
- **Guerrero** sugiere una transformación intermedia ($\lambda=0.27$, entre raíz y logaritmo) por la oscilación que crece.

## 16. Dejar que la máquina elija: `ARIMA()` y `report()` (diapositivas 23–24)

```r
fit <- turismo |> model(
  auto      = ARIMA(Llegadas),
  aerolinea = ARIMA(Llegadas ~ 0 + pdq(0,1,1) + PDQ(0,1,1)))
```

| Modelo | Elegido | Coeficientes |
|---|---|---|
| `auto` | $\text{ARIMA}(0,0,0)(0,1,1)_{12}$ con deriva | `sma1` = −0.776; constante = 7847 |
| `aerolinea` | $\text{ARIMA}(0,1,1)(0,1,1)_{12}$ | `ma1` = −0.953; `sma1` = −0.757 |

- El algoritmo eligió **una diferencia estacional, ninguna ordinaria y una deriva** (*drift*) que captura la tendencia de +650 por mes. No eligió el modelo de aerolínea.
- **`sma1`:** peso del error del mismo mes del año pasado (≈ −0.77 en ambos).
- **Constante ≈ 7847:** crecimiento de un año al siguiente, cerca de $12\times650=7800$: el modelo recuperó la tendencia simulada.
- **`ma1` ≈ −0.95:** un MA cerca de −1 delata una diferencia de más (sobrediferenciación); por eso el algoritmo no diferenció dos veces.
- **Trampa del AICc:** solo compara modelos con **las mismas diferencias**. Estos dos tienen distinto $d$, así que no se comparan por AICc; la decisión se toma con validación.

## 17. El modelo confiesa en sus residuos (diapositiva 25)

```r
fit |> select(auto) |> gg_tsresiduals()
augment(fit) |> filter(.model == "auto") |> features(.innov, ljung_box, lag = 24, dof = 1)
```

- `gg_tsresiduals()` muestra los residuos en el tiempo, su ACF y su histograma. La ACF de los residuos queda casi toda dentro de la franja.
- **Ljung-Box:** p = 0.29 (estadístico 26.1) → no hay evidencia de estructura sobrante: los residuos son **ruido blanco**. `dof` es el número de coeficientes ARMA (aquí, `sma1`).

## 18. Pronosticar: `forecast()` e intervalos (diapositiva 26)

```r
fc <- fit |> select(auto) |> forecast(h = "2 years")
fc |> autoplot(turismo, level = c(80, 95))
```

- **No es un número, sino una distribución de futuros:** cada mes trae una normal (media y varianza); las franjas son los intervalos de 80 % y 95 %.
- El pronóstico conserva la estacionalidad y la tendencia que el modelo aprendió.

## 19. ¿Le gana al ingenuo? SARIMA contra SNAIVE (diapositiva 27)

Se entrena hasta 2018 y se pronostica 2019. **SNAIVE** repite el mismo mes del año pasado: es gratis y difícil de superar.

| Modelo | RMSE | MAPE | MASE |
|---|---|---|---|
| `aerolinea` | 11461 | 4.09 | 0.818 |
| `auto` | 11373 | 4.11 | 0.818 |
| `snaive` | 15949 | 5.42 | 1.09 |

- **MASE** es el error relativo al ingenuo: **menos de 1 le gana**. Ambos SARIMA lo logran (0.82); SNAIVE queda en 1.09.
- Gráficamente el SARIMA se ajusta mejor que el ingenuo en la gran mayoría de los meses.
- Un solo año de prueba es poca evidencia: de ahí la siguiente validación.

## 20. Validar sin hacer trampa: ventana expansiva (diapositiva 28)

Es el `TimeSeriesSplit` de la semana pasada, ahora en R: una especie de validación cruzada, pero sin barajar, porque en datos de tiempo el orden manda.

```r
cv <- turismo |> filter(Mes < make_yearmonth(2019, 1)) |>
  stretch_tsibble(.init = 60, .step = 6)    # 9 ventanas
```

| Modelo | RMSE | MASE |
|---|---|---|
| `auto` | 9905 | 0.752 |
| `aerolinea` | 10207 | 0.764 |
| `snaive` | 13950 | 1.04 |

- **9 entrenamientos que solo ven su pasado**, cada uno pronosticando los 12 meses siguientes.
- **Lectura del RMSE:** el mejor modelo falla en promedio unas 9 900 llegadas hacia arriba o hacia abajo.
- Con más evidencia, los dos SARIMA quedan casi empatados y ambos le ganan al ingenuo: la diferencia de AICc no decidía nada.

## 21. Para el proyecto: datos reales de Costa Rica (diapositiva 29)

| Fuente | Serie |
|---|---|
| ICT | Llegadas mensuales (en 2025 llegaron 2 689 278 turistas por vía aérea; diciembre creció 13.6 % frente a 2024) |
| Ministerio de Salud | Dengue por semana epidemiológica ($m\approx52$); vienen en PDF, hay que transcribirlos |
| BCCR | IMAE mensual, tipo de cambio y otros indicadores |

> **Advertencia de modelador:** la serie real del ICT tiene un quiebre enorme en 2020 y 2021 por la pandemia. Conviene usar datos anteriores a 2020 o posteriores a 2022, o tratar ese período como una intervención. Por eso se aprende la mecánica con una serie simulada limpia.

## 22. ¿Siguen vigentes los clásicos? Las competencias M (diapositiva 30)

Las competencias M son *benchmarks* de series de tiempo:

| Competencia | Qué pasó |
|---|---|
| M4 (2018) | 100 000 series: ganó un híbrido de suavizamiento exponencial y red recurrente |
| M5 (2020) | Ventas de Walmart: ganaron métodos de aprendizaje automático (LightGBM) |
| M6 (2022–23) | Finanzas: solo el 23 % de los equipos superó el pronóstico de referencia |

- **Lección:** con muchos datos regulares y jerárquicos, el aprendizaje automático gana; con pocos datos o ruido casi puro, los clásicos siguen siendo competitivos; los mejores resultados suelen ser **combinaciones de modelos**.
- ARIMA y ETS (suavizamiento exponencial) **no están obsoletos**: en las empresas se usan como línea base, y solo se pasa a un modelo moderno si lo supera.

## 23. La frontera: modelos de fundación para series (diapositiva 31)

- Modelos preentrenados con millones de series que pronostican una serie nueva **sin reentrenar** (*zero-shot*), como un LLM: **Chronos** y Chronos-2 (Amazon), **TimesFM** (Google), **Moirai** (Salesforce).
- Se evalúan con **GIFT-Eval**: 23 conjuntos de datos, unas 144 000 series y 177 millones de puntos. Son competitivos en muchos casos, pero los clásicos siguen siendo difíciles de batir en varios dominios.
- **Idea unificadora:** del SARIMA al modelo de fundación, todos separan tendencia, estacionalidad y resto; solo cambia cómo se estima cada parte. La próxima semana se comparan Prophet, NeuralProphet y Chronos con el mismo MASE contra el mismo SNAIVE.

## 24. Síntesis: el flujo completo de `fpp3` (diapositiva 32)

| Paso | Qué hace | Función clave |
|---|---|---|
| 1. Estructurar | Tabla que entiende el calendario | `tsibble()`, `yearmonth()` |
| 2. Explorar | Ver tendencia y estacionalidad | `autoplot()`, `gg_season()`, `ACF()` |
| 3. Descomponer | Separar la receta | `STL()` + `components()` |
| 4. Estacionarizar | Decidir cuántas diferencias | `unitroot_kpss`, `unitroot_nsdiffs` |
| 5. Modelar | Elegir $(p,d,q)(P,D,Q)$ | `ARIMA()`, `report()` |
| 6. Diagnosticar | ¿Residuos de ruido blanco? | `gg_tsresiduals()`, `ljung_box` |
| 7. Pronosticar | Distribución de futuros | `forecast()`, `autoplot()` |
| 8. Validar | Comparar fuera de muestra | `stretch_tsibble()`, `accuracy()` |

Cambia la serie (turismo, dengue, electricidad); el flujo es siempre este.

---

## Fuera del PDF — logística, tareas y metodología (diapositivas 33–35)

- **Primer modelo del proyecto:** un SARIMA validado contra SNAIVE en MASE y con diagnóstico de residuos ya cumple el primer modelo del avance. Carriles donde encaja: demanda eléctrica (SARIMA frente a la regresión de la semana 5), turismo (SARIMA frente a un modelo de fundación) y dengue (SARIMA estacional junto al SEIR de la semana 2).
- **Proyecto, instrucciones del avance** (aún no están en el aula virtual: se suben cuando se armen los grupos en la plataforma):
  - Reparto: avance en la semana 8 (valor 15); entrega final en la semana 15 (escrito, 25; presentación final, 10).
  - Temas: los del documento son solo sugeridos (demanda eléctrica residencial, SEIR calibrado con datos de dengue, rutas de transporte público con teoría de grafos, crédito scoring con datos sintéticos, pobreza por hogar, red de coautoría científica, cartera de inversión, anomalías en el consumo de agua, llegada de turistas, propagación de información, inventario, tipo de cambio colón-dólar). Se puede proponer cualquier otro. **Los temas no pueden repetirse entre grupos.**
  - Esta semana, cada grupo debe enviar un correo con su número de grupo y el tema elegido (aclarando que es de este curso). Un grupo ya eligió turismo (llegadas).
  - Contenido del avance: portada, introducción y planteamiento del problema, justificación, objetivos, dataset definido, formulación matemática inicial, primer modelo aplicado, próximos pasos y referencias. Se entrega un PDF (parte escrita) y un notebook de Colab (código); basta con que lo entregue una persona del grupo. El documento incluye rúbrica, formato, ejemplos de objetivos bien formulados y consejos.
  - Conviene elegir algo que guste o parezca interesante, porque requiere tiempo de trabajo.
- **Calendario:**

| Semana | Qué pasa |
|---|---|
| 7 (22 de octubre) | Series temporales modernas: Prophet (tendencia más estacionalidad de Fourier), NeuralProphet, Chronos; mismo árbitro: MASE contra SNAIVE. Es la última clase de materia nueva |
| 8 (29 de octubre) | Repaso general (1 a 1.5 h) con un flujo real de modelado en Colab, parecido a la prueba parcial; luego se asigna la prueba parcial grupal y se empieza en salas (1 a 1.5 h) para resolver dudas. Entrega del avance del proyecto |
| 9 (5 de noviembre) | Entrega de la prueba parcial grupal, antes de la sesión (una semana después de asignarla) |
| 13 (3 de diciembre) | Las tres presentaciones grupales de tema complementario (rubro del sílabo, distinto del proyecto) |

- **Actividad grupal en salas (tarea moral, no se entrega ni se califica; no se realizó en clase):** 40 minutos con los grupos del proyecto y un notebook de Colab con entorno de R compartido (guardar copia en Drive o GitHub personal). Se permite usar IA si se entiende cada línea copiada y los comentarios del código los escribe el grupo (rige el protocolo de IA de Lead University). Partes:
  - **Parte 1, a mano:** colocaciones trimestrales de una cooperativa (20, 26, 18, 24, 23, 29, 21, 27). Primera diferencia: 6, −8, 6, −1, 6, −8, 6 (el patrón sigue); diferencia estacional: 3, 3, 3, 3 (crecen 3 millones por año sobre un patrón trimestral fijo). Tres ACF descritas en palabras: todas dentro de la franja = evento al azar; decae lento = población; repuntes en 12, 24 y 36 y negativas cerca de 6, 18 y 30 = helados (la única que necesita diferencia estacional).
  - **Parte 2, R:** demanda eléctrica mensual simulada de un país pequeño (96 meses): `tsibble`, `gg_season` (pico en abril, valle en setiembre) y STL (fuerza de tendencia 0.98, de estacionalidad 0.92).
  - **Parte 3, R:** auto-ARIMA elige $\text{ARIMA}(0,0,0)(0,1,1)_{12}$ con deriva; la constante (≈ 30) es el crecimiento anual, $12\times2.5$; Ljung-Box da p = 0.82.
  - **Parte 4, R:** entrenar con 2018–2024 y probar en 2025: SARIMA (MASE 0.39) contra SNAIVE (0.98). Pregunta: ¿por qué SNAIVE queda cerca de 1 y qué parte de la serie no puede capturar?
  - **Parte 5, reflexión:** una observación matemática (qué mostró la diferencia estacional), una técnica (por qué no validar con K-fold barajado) y una pregunta abierta (¿la serie del proyecto tiene estacionalidad, con qué período?).
- **Pendientes (tarea moral):** resolver los ejercicios de la parte de ideas, terminar la actividad y leer los capítulos de descomposición y ARIMA de `fpp3` (otexts.com/fpp3). En el aula virtual están la presentación en limpio, los apuntes y la actividad complementaria.
- **Evaluación intermedia:** está activa en el aula virtual, es anónima y debe completarse durante la semana.
- **Dudas de materia o proyecto:** jordy.alfaro@ulead.ac.cr.
- **Asistencia:** la lista se pasó al final de la clase.

## Conceptos clave (diapositiva 36)

1. **Una serie es una receta:** tendencia, estacionalidad, ciclo y ruido. STL los separa; lo que sobra debe ser pequeño y no tener patrón. Si la oscilación crece con la serie es multiplicativa y un logaritmo la vuelve aditiva.
2. **Estacionariedad:** media y variabilidad no dependen del momento; ARIMA solo funciona así. No es lo mismo que estacionalidad.
3. **Diferenciar aplana:** la "I" de ARIMA es una resta. La primera diferencia quita la tendencia y la estacional quita el patrón que se repite cada $m$ períodos. KPSS decide cuántas veces; la ACF y los residuos dicen si alcanzó.
4. **Leer la ACF:** dentro de la franja es ruido, decaimiento lento es tendencia y repuntes en 12, 24 y 36 son estacionalidad anual.
5. **ARIMA en palabras:** AR (depende de mi pasado), I (cuántas diferencias), MA (corrijo con mis errores pasados); minúsculas para el corto plazo y mayúsculas para el ciclo anual.
6. **Validar es mirar al futuro:** ventana expansiva (nunca barajar) y MASE contra el ingenuo; menos de 1 le gana. El AICc no compara modelos con distintas diferencias.
7. **Los clásicos siguen vigentes:** ARIMA y ETS son la línea base que todo modelo moderno debe superar.
