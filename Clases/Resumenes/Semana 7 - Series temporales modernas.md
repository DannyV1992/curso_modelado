# Semana 7: Series temporales modernas

**Curso:** BCD5105 Modelado matemático, Lead University (III cuatrimestre 2026, virtual)

**Docente:** Jordy Alfaro Brenes

**Fecha:** jueves 22 de octubre de 2026

**PDF fuente:** `Clases/PDFs/Semana 7 - Series temporales modernas 2.pdf`

**Cobertura del PDF:** Completo (diapositivas 1 a 29). La diapositiva 12 es un espacio de trabajo (allí se resolvió el ejemplo 1), los ejercicios de la diapositiva 13 quedan como tarea moral y la práctica en salas (diapositiva 29) se inició pero no se terminó.

**Tramos solo del PDF:** la transcripción cubre toda la clase sin cortes. Solo salen del PDF la conexión con las cadenas de Markov (diapositiva 9), los ejercicios (13), la tabla de versiones y el parámetro `changepoint_prior_scale` (15 y 17), el zoológico de modelos de fundación (24) y las cifras de `plot_components` (18), que en la transcripción salen deformadas.

**Contexto:** es la "parte 2" de series de tiempo: los fundamentos de la semana pasada (tendencia, estacionalidad, ruido, ARIMA, MASE, ventana expansiva) se mantienen y ahora se comparan con modelos modernos. Es la **última clase de materia nueva**. Se pasa de R a **Python** (Colab). El formato cambia: unos 90 minutos de ideas y demostración, y el resto en salas con el grupo, con una actividad complementaria.

**Objetivos:** distinguir un modelo local de uno global; leer un modelo aditivo tipo Prophet; explicar qué es un modelo de fundación y qué significa *zero-shot*; ajustar Prophet y Chronos-2 en Python; comparar modelos con MASE en varias ventanas y elegir con criterio.

| Bloque | Tema | Diapositivas |
|---|---|---|
| 1 | Local contra global y mapa de modelos | 5–6 |
| 2 | Prophet: descomponer es la idea (con micro ejemplo a mano) | 7–8 |
| 3 | Modelos de fundación y MASE | 9–10 |
| — | Ejemplos y ejercicios | 11–13 |
| 4 | Python: stack, Prophet, NeuralProphet y Chronos-2 | 14–21 |
| 5 | ¿Quién gana? y cuándo usar cada enfoque | 22–25 |
| 6 | Proyecto, próxima semana y cierre | 26–28 |
| — | Práctica en salas | 29 |

---

# Parte 1: Las ideas (diapositivas 4–13)

## 1. El cambio de paradigma: local contra global (diapositiva 5)

| | Local | Global |
|---|---|---|
| Idea | **Un modelo por serie** | **Un solo modelo** que aprende de muchas series |
| Escala | 100 000 series → 100 000 modelos | 100 000 series → 1 modelo |
| Qué aprende | Solo los patrones de su serie | **Patrones compartidos**: lo que aprende de una serie ayuda a las demás |
| Ejemplos | ARIMA, ETS (suavizamiento exponencial), Prophet | LightGBM con rezagos, redes profundas, modelos de fundación |

- Un modelo global con 3 series no aprende nada útil; con millones de series sí detecta patrones comunes.
- De la idea global salieron modelos como TimesFM y Chronos (hoy Chronos-2).

## 2. El mapa de los modelos modernos (diapositiva 6)

Cuatro familias conviven en 2026:

| Familia | Ejemplos | Rasgos |
|---|---|---|
| **Aditivos** | Prophet, NeuralProphet | Separan tendencia, estacionalidad y festivos; interpretables. Hoy se usan como **línea base**, no como campeones |
| **Gradient boosting** | LightGBM, XGBoost | Con variables de calendario y rezagos. Ganaron la competencia M5; es el "caballo de batalla" de la industria (hasta hace poco se hablaba de XGBoost por todos lados) |
| **Aprendizaje profundo** | N-HiTS, TFT, DeepAR | Potentes, pero piden muchos datos y cómputo |
| **Modelos de fundación** | Chronos-2, TimesFM, Toto | Preentrenados a gran escala; pronostican series que nunca vieron. Es la frontera de hoy |

> **Hilo conductor:** del SARIMA de la semana pasada al modelo de fundación más nuevo, todos intentan separar **tendencia, estacionalidad y resto**. Cambia cómo estiman cada parte y de cuántas series aprenden.

## 3. Prophet: descomponer es la idea (diapositiva 7)

Modelo **aditivo e interpretable**, pariente del STL de la semana pasada:

$$\hat y(t)=g(t)+s(t)+h(t)+\varepsilon(t)$$

| Componente | Qué es |
|---|---|
| $g(t)$ | **Tendencia por tramos**: una recta que cambia de pendiente en los *quiebres* (no hay una única tendencia, sino una por tramo) |
| $s(t)$ | **Estacionalidad**: ondas de Fourier (senos y cosenos) que se repiten |
| $h(t)$ | **Festivos**: picos en fechas especiales (feriados, Semana Santa) |
| $\varepsilon(t)$ | Lo que sobra: debe parecer ruido |

- **Quién fija los valores:** los quiebres y la estacionalidad los **deduce el modelo del histórico**, con ondas de Fourier; los números del ejemplo siguiente son inventados para poder armarlo a mano.
- **Período $m$:** número de observaciones por ciclo estacional. Con datos trimestrales $m=4$; con mensuales $m=12$; con semanales $m=52$. Depende de la serie y de su granularidad: una juguetería con pico cada diciembre tiene un ciclo anual; un restaurante, probablemente semanal.
- **Cómo saber qué período usar:** descomponer la serie y mirar solo el componente estacional. Si los picos caen en los meses 3, 6, 9 y 12, el ciclo es trimestral ($m=4$). En la serie completa esos picos pueden no notarse.

> **Nota:** Prophet **no detecta festivos por sí solo**. Hay que declararlos con un DataFrame `holidays=` o con `m.add_country_holidays(country_name=...)`. En la demostración de la clase solo se activó la estacionalidad anual, así que no se usaron festivos.

## 4. Micro ejemplo: armar el pronóstico a mano (diapositiva 8)

Tendencia por tramos con quiebre en $t=4$ y estacionalidad trimestral ($m=4$):

$$g(t)=\begin{cases}50+2t & t\le 4\\ 58+5(t-4) & t>4\end{cases}\qquad s(t):\ \text{T1 } {+6},\ \text{T2 } {-2},\ \text{T3 } {-8},\ \text{T4 } {+4}$$

| $t$ | Trim. | $g(t)$ | $s(t)$ | $\hat y(t)=g+s$ |
|---|---|---|---|---|
| 1 | T1 | 52 | +6 | 58 |
| 2 | T2 | 54 | −2 | 52 |
| 3 | T3 | 56 | −8 | 48 |
| 4 | T4 | 58 | +4 | 62 |
| 5 | T1 | 63 | +6 | 69 |
| 6 | T2 | 68 | −2 | 66 |
| 7 | T3 | 73 | −8 | 65 |
| 8 | T4 | 78 | +4 | 82 |

- **Antes y después del quiebre:** la tendencia crece **2 por trimestre** en el primer año y **5 por trimestre** en el segundo. Es plausible en la vida real: una PYME puede vender menos volumen el primer año que el segundo.
- **Por qué las cuatro $s(t)$ suman cero** ($6-2-8+4=0$): así la estacionalidad se **reparte durante el año sin mover el nivel promedio**, y el nivel lo lleva solo la tendencia. Si no sumaran cero, tendencia y estacionalidad se **confundirían**; que sumen cero es lo que las separa limpiamente.
- Como el modelo es aditivo, $\hat y$ se obtiene **sumando** los componentes.

## 5. Modelos de fundación: pronosticar sin entrenar (diapositiva 9)

- **Preentrenamiento:** se entrenan una vez con cientos de miles o millones de series (miles de millones de puntos) y luego se aplican mil veces: a una serie nueva, a otra, a turismo de Costa Rica.
- **Zero-shot:** se le pasa la **historia de la serie como contexto** y pronostica, sin ajustar ningún parámetro con nuestros datos. Detecta patrones compartidos con lo que vio en el preentrenamiento.
- **Analogía con un LLM:** igual que ChatGPT predice la siguiente palabra sin reentrenarse con la pregunta, el modelo predice el siguiente valor sin reentrenarse con la serie. Y así como un LLM distingue "banco" de dinero de "banco" para sentarse, el modelo reconoce el tipo de patrón (turismo, economía, tipo de cambio).
- **Tamaño:** Chronos-2 tiene 120 millones de parámetros; GPT-3, 175 000 millones.
- **Conexión con el curso:** un LLM se puede ver como una cadena de Markov enorme (semana 3). El Chronos original convertía los valores en fichas (*tokens*) y trataba la serie como un idioma.
- Igual que todos los demás, se juzga con **MASE contra el ingenuo**.

## 6. El árbitro no cambia: MASE (diapositiva 10)

$$\text{MASE}=\frac{\text{error medio del modelo}}{\text{error medio del ingenuo estacional en el entrenamiento}}$$

(Error medio absoluto escalado: M de media, A de absoluto, S de escalado, E de error.)

| MASE | Lectura |
|---|---|
| $<1$ | Le gana al ingenuo. Es la condición mínima para que valga la pena |
| $\approx 1$ | Empata con repetir el año anterior: toda la sofisticación no aportó nada |
| $>1$ | Peor que el ingenuo. Pasa más seguido de lo que parece; si ocurre, no tiene sentido seguir con ese modelo |

- **No tiene unidades:** sirve igual para turistas, colones o casos de dengue. Por eso es la métrica de los *benchmarks* (GIFT-Eval) y la que se usa para comparar Prophet, Chronos-2 y los clásicos.

## 7. Ejemplos resueltos (diapositivas 11–12)

**Ejemplo 1.** Ventas trimestrales de entrenamiento: 20, 30, 25, 35, 24, 34, 29, 39. Valores reales de prueba: 28, 38, 33, 43. Modelo A pronostica 27, 39, 32, 41; modelo B, 30, 37, 35, 42.

- **a) Escala** (error del ingenuo estacional en el entrenamiento, $m=4$): se resta cada trimestre contra el mismo trimestre del año anterior: $|24-20|,\ |34-30|,\ |29-25|,\ |39-35|$ = 4, 4, 4, 4. La escala es **4** (en datos reales saldría algo alrededor de 4, como 3.96 o 4.05).
- **b) MASE** (pronóstico → errores absolutos → error medio → MASE):

| Modelo | Pronóstico | Errores | Error medio | MASE |
|---|---|---|---|---|
| A | 27, 39, 32, 41 | 1, 1, 1, 2 | 1.25 | $1.25/4=\mathbf{0.3125}$ |
| B | 30, 37, 35, 42 | 2, 1, 2, 1 | 1.5 | $1.5/4=0.375$ |
| Ingenuo | 24, 34, 29, 39 | 4, 4, 4, 4 | 4 | $4/4=1$ |

- **Decisión:** se elige el **modelo A** (menor MASE). Ambos le ganan por mucho al ingenuo.

> **Nota:** la escala sale del entrenamiento, así que el ingenuo no siempre da exactamente 1 en la prueba (aquí sí, porque el ejemplo está armado). Conviene calcular también el MASE del ingenuo como referencia.

**Ejemplo 2.** Elegir el enfoque y justificarlo en una frase:

| Caso | Enfoque | Justificación |
|---|---|---|
| a) Tienda nueva con dos meses de ventas | **Modelo de fundación zero-shot** (Chronos-2) | No hay historia para estimar, ni se sabe si habrá estacionalidad: se parte "en frío" con patrones aprendidos de otras series. Alternativa simple: promedio de tiendas similares de la zona |
| b) 30 000 productos con promociones y feriados | **Modelo global**: LightGBM con rezagos y variables de calendario | Muchas series comparten patrones y variables externas; es lo que ganó M5 |
| c) Serie mensual de 10 años y un gerente que pide entender el pronóstico | **Prophet** (o ETS / ARIMA automático) | Con 10 años ya se pueden buscar tendencia y estacionalidad: piezas legibles |
| d) Tipo de cambio diario, casi sin estacionalidad | **Empezar por el ingenuo** | Se parece a una **caminata aleatoria** y con tanta volatilidad la sofisticación casi nunca aporta. Cualquier modelo que se use debe superar al ingenuo; se prueban varios y gana el de menor MASE |

> **Nota:** en una serie sin estacionalidad el ingenuo es el **último valor observado** (en una caminata aleatoria, mañana = hoy + ruido).

### Pronosticar es entregar una distribución

- Cada mes el modelo genera una **distribución de valores posibles**; el número que se suele mostrar es el centro (el promedio). Un intervalo al 95 % deja 2.5 % de la distribución en cada cola: el límite inferior y el superior son esos cortes. Los modelos entregan esos límites, útiles por ejemplo para fijar un nivel de inventario de seguridad.
- **Horizonte:** los pronósticos son seguros a **corto plazo** (un mes, una semana, 7 días). A medida que se avanza, el intervalo **se abre**: puede cambiar el patrón por un hecho imprevisto (una campaña que dispara las ventas o una crisis que las hunde). Forecastear un período completo ya es mucho; lo recomendable es pronosticar corto y **reentrenar**.

### Validar con el orden del tiempo

- Se entrena con la parte inicial de la serie y se prueba con una parte posterior que **ya ocurrió**; así se compara el pronóstico con lo real en lugar de confiar a ciegas en el futuro.
- **Error grave:** entrenar con un pedazo del medio o del final y probar con uno anterior. Es entrenar con el futuro y probar con el pasado.
- En la práctica se entrenan **varios modelos y se comparan** con los datos propios: no siempre gana el mismo, y el contexto del negocio orienta pero no sustituye la comparación.

## 8. Ejercicios (diapositiva 13) — tarea moral

1. Tendencia $g(t)=100+3t$ hasta $t=6$ y pendiente 1 después; estacionalidad trimestral $+10, 0, -15, +5$. Calcular $\hat y(t)$ para $t=5,\dots,10$.
2. Un modelo tiene MASE 1.15 en la prueba: ¿qué significa y qué se haría antes de descartarlo?
3. Explicar con palabras propias la diferencia entre un modelo local, uno global y uno de fundación, con un ejemplo costarricense donde convenga cada uno.

---

# Parte 2: Series modernas en Python (diapositivas 14–25)

## 9. El stack de Python a octubre de 2026 (diapositiva 15)

| Librería | Versión | Estado | Para qué |
|---|---|---|---|
| `prophet` | 1.5.0 | Mantenido, sin cambios grandes | Línea base aditiva interpretable |
| `neuralprophet` | 0.9.0 (2024) | **Estancado** | Puente conceptual a lo neuronal |
| `chronos-forecasting` | 2.3.2 | Muy activo | Chronos-2, sin entrenar |
| `statsforecast` (Nixtla) | 2.1.1 | Muy activo | AutoARIMA y AutoETS rapidísimos |
| `mlforecast` (Nixtla) | — | Activo | LightGBM con rezagos |
| `autogluon.timeseries` | 1.6.3 | Muy activo | Combina todo lo anterior |

```python
!pip install -q prophet chronos-forecasting statsforecast   # Colab ya trae pandas y matplotlib
```

- Normalmente no se instala nada en Colab porque trae muchas librerías; estas son muy particulares y no vienen. Un solo `pip install` de `prophet` trae sus dependencias. Fuera de Colab (por ejemplo en VS Code) se instala igual.

## 10. La serie de hoy: turismo, ahora en Python (diapositiva 16)

Es la misma serie simulada de la semana pasada: 120 meses (2010–2019), tendencia de **+650 por mes**, patrón estacional **multiplicativo** fijo (pico en enero, valle en setiembre) y ruido de 4.5 %. Se construye con `numpy` y `pandas`.

- **Formato de Prophet:** una tabla con una columna `ds` (fecha) y otra `y` (valor).
- Se conoce la verdad, así que se puede comprobar si cada modelo la recupera.

## 11. Prophet en cinco líneas (diapositiva 17)

```python
from prophet import Prophet

m = Prophet(yearly_seasonality=True, seasonality_mode="multiplicative",
            changepoint_prior_scale=0.05)
m.fit(df)
futuro = m.make_future_dataframe(periods=24, freq="MS")
fcst = m.predict(futuro)
fig = m.plot(fcst)
```

| Parámetro | Significado |
|---|---|
| `seasonality_mode="multiplicative"` | La oscilación crece con el nivel de la serie, como en el turismo |
| `changepoint_prior_scale` | Cuánto puede doblarse la tendencia: más alto, más flexible y más riesgo de sobreajuste |

- **Lectura del gráfico:** los puntos negros son los datos reales; la curva es lo que reconstruye Prophet, con su intervalo de confianza. Se pronostican 24 meses (2 años).
- **Puntos fuera de la banda:** los picos que nunca caen dentro del intervalo parecen atípicos (*outliers*) o eventos que el modelo no acomodó. Hay que sentarse a analizar qué pudo pasar en esos períodos.

## 12. `plot_components`: la receta por dentro (diapositiva 18)

`m.plot_components(fcst)` separa el pronóstico en su **tendencia** y su **estacionalidad anual**.

- **Tendencia:** sube unos 676 por mes; la verdad simulada era $650\times1.025\approx666$. Muy cerca.
- **Estacionalidad (`yearly`):** en la multiplicativa se lee como fracción de la tendencia. Diciembre = 0.310 (31 % sobre la tendencia); setiembre queda cerca de 30 % abajo. Coincide con el patrón simulado.
- **Interpretabilidad:** otros modelos son más "cajas negras". Prophet se puede abrir y explicar paso por paso, y como es popular, mucha gente ya sabe interpretarlo.

## 13. Prophet no es el estado del arte (diapositiva 19)

| Aspecto | Qué hay que saber |
|---|---|
| Mantenimiento | Recibe arreglos y versiones nuevas (1.5.0 en octubre de 2026), pero **el modelo no cambia desde hace años** |
| Comparaciones | En el libro `fpp3` y en estudios independientes suele quedar **detrás de ETS y ARIMA bien ajustados** |
| Su creador | Sean Taylor (coautor) reconoció en 2021 que suele haber mejores enfoques y que *«no hay sustituto para la evaluación»* |
| Cuándo sí usarlo | Series de negocio con **estacionalidad fuerte y varios años de historia**, cuando explicar pesa más que el último punto de precisión |

> **Popularidad no es precisión:** un gráfico bonito no es un buen modelo.

## 14. NeuralProphet: Prophet más autorregresión (diapositiva 20)

- Son las mismas piezas de Prophet reescritas sobre PyTorch, más una **autorregresión con una red (AR-Net)**: la "AR" de ARIMA, estimada con descenso por gradiente. Sin rezagos rinde casi igual que Prophet; con rezagos mejora.
- **Proyecto estancado:** la última versión estable es de junio de 2024 y ya no corre con las librerías actuales sin parches (da errores con pandas 3 y con PyTorch 2.6). Por eso no se usa en el curso.
- **Lección de modelador:** antes de elegir una herramienta para el proyecto, revisar si sigue viva.

## 15. Chronos-2 en Colab, sin entrenar (diapositiva 21)

Modelo de Amazon (octubre de 2025), 120 millones de parámetros, licencia Apache 2.0.

```python
from chronos import Chronos2Pipeline

pipeline = Chronos2Pipeline.from_pretrained("amazon/chronos-2", device_map="cpu")
contexto = df.assign(id="turismo_cr").rename(columns={"ds": "timestamp", "y": "target"})
pred = pipeline.predict_df(contexto, prediction_length=24,
                           quantile_levels=[0.1, 0.5, 0.9],
                           id_column="id", timestamp_column="timestamp", target="target")
```

- **No hay `fit`:** el modelo lee los 120 meses como contexto y devuelve **cuantiles**. En CPU tarda unos segundos (la primera vez descarga los pesos).
- **Salida:** la mediana (línea central) y los cuantiles 10 %–90 %, es decir, una banda del 80 %.
- Es el mismo formato largo (`id`, `timestamp`, `target`) para cualquier serie.

## 16. Clásico contra fundación, en el mismo gráfico (diapositiva 22)

Entrenan hasta 2017 y pronostican 2018 y 2019:

| Modelo | MASE | MAPE |
|---|---|---|
| AutoETS | 0.66 | 3.8 % |
| Prophet | 0.66 | 3.8 % |
| Chronos-2 | 0.78 | 4.5 % |
| AutoARIMA | 0.81 | 4.6 % |
| SeasonalNaive | 1.29 | 7.4 % |

- Los cuatro le ganan al ingenuo. **Chronos-2 queda cerca sin haber visto nunca la serie** (hizo *zero-shot*), mientras Prophet y AutoETS sí se entrenaron con 2010–2017.
- Pero esto es **un solo corte**.

## 17. Nadie gana siempre (diapositiva 23)

MASE por año de prueba, con ventana expansiva (se entrena con el pasado de cada año):

| Modelo | 2016 | 2017 | 2018 | 2019 | Promedio |
|---|---|---|---|---|---|
| AutoETS | **0.80** | 0.80 | **0.53** | **0.72** | **0.71** |
| Chronos-2 | 0.93 | 0.78 | 0.63 | 0.77 | 0.78 |
| AutoARIMA | 0.93 | 0.82 | 0.68 | 0.91 | 0.84 |
| Prophet | 1.38 | 0.81 | 0.56 | 0.72 | 0.86 |
| SeasonalNaive | 1.72 | **0.71** | 0.88 | 1.13 | 1.11 |

- **AutoETS gana en promedio (0.71)**; Chronos-2 es segundo sin entrenar (0.78).
- **Prophet pierde feo en 2016** (solo tenía 5 años de historia) y casi empata en 2018 y 2019. Ese único año hunde su promedio: mirando cada año o el corte de 2018–2019, queda a la par de AutoETS.
- **El promedio también puede engañar** en el sentido contrario: un modelo puede verse bueno en promedio por haberla pegado casi perfecto en un solo año. Por eso conviene mirar el MASE año por año además del promedio.
- **Regla:** un solo corte puede engañar. Antes de elegir, probar varios años: es la **ventana expansiva** de la semana 6 (el equivalente de la validación cruzada para series de tiempo).

## 18. El zoológico de modelos de fundación (diapositiva 24)

El liderazgo rota cada pocos meses.

| Modelo | Origen | Datos |
|---|---|---|
| Chronos-2 | Amazon, oct 2025 | 120 M de parámetros; univariado, multivariado y con covariables; Apache 2.0 |
| Moirai 2.0 | Salesforce, nov 2025 | Más pequeño y rápido que su versión anterior |
| Toto 2.0 | Datadog, jun 2026 | De 4 M a 2 500 M de parámetros; primer lugar en GIFT-Eval al publicarse; Apache 2.0 |
| TimesFM-3 | Google, ago 2026 | 330 M de parámetros, con covariables; pesos solo para uso no comercial |

- **Tableros de referencia:** GIFT-Eval y fev-bench, que miden con MASE y CRPS sobre cientos de series de varios dominios.
- **Con asterisco:** algunos modelos vieron datos de prueba al entrenar y las cifras de cada empresa son propias. **Ganar en promedio no es ganar en su serie.**

## 19. ¿Cuándo usar cada enfoque? (diapositiva 25)

| Situación | Enfoque recomendado |
|---|---|
| Siempre, como primer paso | Ingenuo estacional + AutoETS o AutoARIMA. **Si no lo superan, se para ahí** y se queda con el clásico |
| Pocas series y hay que explicar el pronóstico | Prophet o ETS: piezas legibles |
| Muchas series, promociones, feriados, variables externas | LightGBM con rezagos (`mlforecast`) |
| Serie nueva o con poca historia, sin tiempo de entrenar | Modelo de fundación zero-shot (Chronos-2) |
| Producción a escala en una empresa | Combinaciones automáticas (AutoGluon) |

> **El mejor modelo no es el más sofisticado:** es el más simple que le gana al ingenuo de forma consistente en varias ventanas. Los modelos clásicos siguen siendo base porque los modernos no les ganan tan fácil; no hay que meter complejidad si uno clásico funciona bien.

---

## Fuera del PDF — logística, tareas y metodología (diapositivas 2–3 y 26–29)

- **Formato nuevo de la clase** (pedido en la evaluación intermedia: menos escuchar, más hacer): unos 90 minutos de parte magistral con código en vivo, receso de 30 minutos y 60 minutos de práctica en salas con el grupo del proyecto. Lo que no se termine queda como tarea moral: no se entrega ni se califica, pero entra en la prueba parcial y sirve para el proyecto. En esta sesión se omitió el receso y la práctica duró unos 40 minutos.
- **Proyecto integrador** (diapositiva 26):
  - **Avance:** se sube a Moodle antes de las 4:00 p. m. del **jueves 29 de octubre**. Revisar la rúbrica del instructivo.
  - Si el tema es una serie (turismo, demanda eléctrica, dengue, tipo de cambio): un clásico (semana 6) y un modelo moderno (hoy) ya son los dos métodos de la entrega final. Para el avance basta **un modelo** comparado con el ingenuo en MASE; el segundo puede quedar en "próximos pasos".
  - **Datos reales:** las series del ICT y del Ministerio de Salud tienen el quiebre de 2020; decidir cómo tratarlo y escribirlo como supuesto.
  - **Temas:** no pueden repetirse entre grupos. Ya están tomados tipo de cambio y turismo (llegadas); el resto de la lista (o una propuesta propia) queda disponible.
- **Semana 8 (jueves 29 de octubre): repaso integrador de las semanas 1 a 7.**
  - Primera hora aprox.: un caso aplicado en Colab, paso a paso y muy parecido a la parte 1 de la prueba parcial. Luego se asigna la prueba parcial y se empieza en salas para resolver dudas. Traer dudas de todo el cuatrimestre.
  - **Prueba parcial grupal:** híbrida (parte a mano y parte aplicada en Colab). Se asigna el 29 de octubre y se entrega **antes de la sesión del 5 de noviembre**, no el mismo día. Se permite apoyarse en IA; pesa más la parte conceptual que lo mecánico. Probablemente se entregarán dos archivos (parte manual y notebook).
  - **Estructura del ejemplo de la prueba anterior** (no será igual, pero va en esa línea): (1) un caso de serie de tiempo: ventas mensuales de autos de 1960 a 1967 con tendencia y estacionalidad; graficar, describir tendencia y estacionalidad, descomponer, entrenar hasta 1966 y probar con 1967, ajustar un modelo clásico (SARIMA), pronosticar 12 meses, calcular RMSE y MAE, ajustar un modelo moderno (Prophet o Chronos), elegir el mejor justificando con métricas y pronosticar 1968; (2) preguntas conceptuales de interpretación sobre regularización (Ridge, Lasso), cadenas de Markov, Monte Carlo y MCMC; (3) dos ejercicios a mano: una regresión lineal y el cálculo de MAE y RMSE.
- **Actividad complementaria de la semana 7 (práctica en salas, 60 min):** notebook de Colab con kernel de Python (correr primero la celda de instalación, tarda un par de minutos). Cuatro partes:
  1. **A mano (15 min):** modelo aditivo de visitas trimestrales a un parque nacional (con una campaña que cambia la pendiente) y su MASE contra el ingenuo.
  2. **Prophet (20 min):** visitas mensuales simuladas 2017–2024 (entrenar hasta 2023, probar 2024); ajustar, leer los componentes (mes más alto y más bajo) y comprobar si recupera el cambio de pendiente de 2022.
  3. **Chronos-2 (15 min):** zero-shot y tabla de MASE contra el ingenuo (con AutoETS como referencia).
  4. **Decisión (10 min):** qué modelo usarían, por qué, qué validación harían antes de decidir y cómo se conecta con la serie del proyecto.
  - Prioridad si falta tiempo: partes 2 y 3 (Prophet y Chronos-2) y la 4 (reflexión); la parte manual es importante pero demanda más tiempo.
- **Puntos extra (opcional):** los grupos que terminen la actividad durante la semana y la envíen por correo (un integrante por grupo) obtienen **10 puntos sobre la nota de la prueba parcial** (p. ej. 90 en la prueba → 100). Se entregan dos archivos: el notebook de Colab y un PDF con la parte a mano (también sirve escribirla en una celda Markdown con LaTeX o insertar una foto en el notebook). Quien tenga tablet puede resolver a mano ahí y exportar el PDF.
- **Pendientes (tarea moral):** terminar las partes abiertas de la práctica, resolver los ejercicios de la parte de ideas (diapositiva 13) y subir el avance del proyecto. En el aula virtual se subirán las notas de la clase.
- **Dudas:** jordy.alfaro@ulead.ac.cr.

## Conceptos clave (diapositiva 28)

1. **Local contra global:** un modelo por serie (ARIMA, ETS, Prophet) o un modelo que aprende patrones compartidos de miles de series (LightGBM con rezagos, redes profundas, modelos de fundación). El modelo de fundación es el caso extremo.
2. **Prophet descompone:** $\hat y=g+s+h+\varepsilon$, con tendencia por tramos (quiebres), estacionalidad de Fourier y festivos. La estacionalidad suma cero para no confundirse con la tendencia. Es muy interpretable, pero por lo general no es campeón en los *benchmarks*.
3. **Zero-shot:** un modelo de fundación preentrenado pronostica una serie nueva con solo leer su historia como contexto, sin ajustar parámetros, igual que un LLM predice la siguiente palabra. Es la opción para series nuevas o con poca historia.
4. **El árbitro no cambió:** clásico, neuronal o de fundación, se compara con **MASE contra el ingenuo** (menor que 1 le gana) y en **varias ventanas**; nadie gana siempre y un solo corte engaña.
5. **Pronosticar es una distribución:** el valor central es solo el punto medio; el intervalo se abre con el horizonte, por eso se pronostica a corto plazo y se reentrena.
6. **Validar respetando el tiempo:** entrenar con el pasado y probar con el futuro que ya ocurrió; nunca al revés ni barajando.
7. **Empezar simple:** ingenuo estacional, luego AutoETS o AutoARIMA; solo se pasa a algo más sofisticado si lo supera de forma consistente. Revisar además que la herramienta siga viva (NeuralProphet).
