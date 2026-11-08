# Semana 8: Repaso integrador (semanas 1 a 7) y prueba parcial

**Curso:** BCD5105 Modelado matemático, Lead University (III cuatrimestre 2026, virtual)

**Docente:** Jordy Alfaro Brenes

**Fecha:** jueves 29 de octubre de 2026

**Fuente:** notebook `Clases/Actividades/Clase8_Repaso/Clase8_Repaso.ipynb` (la clase no tiene PDF de diapositivas) y transcripción de la clase

**Cobertura:** completa (secciones 0 a 9 del notebook). La transcripción cubre toda la sesión sin cortes. Solo salen del notebook el formulario mínimo y la lista de errores frecuentes (sección 9), que no se leyeron en clase.

**Contexto:** repaso de los temas 1 a 7 sobre **un solo caso real**: la demanda eléctrica mensual de Costa Rica (enero de 2019 a junio de 2026). El recorrido es el mismo de la prueba parcial: **descargar → explorar → modelar → validar → elegir → pronosticar**. Después del repaso se asigna la prueba parcial grupal y se trabaja en salas.

**Objetivos:** ver el pipeline completo de punta a punta, reconocer dónde entra cada tema del curso y conocer la estructura de la prueba parcial.

| Bloque | Tema | Sección |
|---|---|---|
| 1 | Datos y supuestos (fundamentos) | 1 |
| 2 | Exploración y descomposición | 2 |
| 3 | EDO: crecimiento exponencial | 3 |
| 4 | Cadenas de Markov | 4 |
| 5 | Regresión y regularización | 5 |
| 6 | Series de tiempo: clásicos contra modernos | 6 |
| 7 | Monte Carlo | 7 |
| 8 | Pronóstico final con banda del 80 % | 8 |
| — | Prueba parcial y logística | Fuera del notebook |

---

## 0. Entorno

- Se descarga el notebook del aula virtual y se sube a Colab (colab.research.google.com → subir).
- **Prophet** y **Chronos-2** no vienen preinstalados en Colab: se instalan con `pip` (tarda un par de minutos). Se corre primero esa celda.
- Se fija una semilla (`default_rng(2026)`) y se definen colores de marca para los gráficos.

---

## 1. Los datos: descargarlos de la fuente

**Fuente:** Ember, *Monthly Electricity Data* (CC BY 4.0). Recopila datos oficiales de generación y demanda de unos 90 países y publica un CSV abierto que se actualiza cada mes. Costa Rica tiene datos mensuales desde enero de 2019.

- El archivo pesa unos 70 MB y está en **formato largo** (una fila por país, mes y variable). Se lee con `pd.read_csv(URL, usecols=...)`, apuntando a la URL; no se descarga a mano.
- Se filtra `Area == "Costa Rica"` y `Unit == "TWh"`, se pasa a **formato ancho** (una fila por mes, una columna por variable) y se convierte a **GWh** (1 TWh = 1000 GWh).
- Resultado: **90 meses** (enero de 2019 a junio de 2026) con demanda, hidro, eólica, geotérmica/otras, bio, solar y fósil. Se corta en junio de 2026 y se guarda una copia local.

**Supuestos y cuidados (fundamentos del modelado):**

- Son datos oficiales **agregados**, redondeados a 10 GWh: una diferencia de 10 GWh puede ser solo redondeo.
- "Otras renovables" en Costa Rica es casi toda **geotermia**.
- Ember agrega y puede **revisar** cifras recientes; por eso el corte fijo y la copia local.
- 90 meses alcanzan para ver estacionalidad, pero son pocos para modelos que piden miles de datos.

---

## 2. Exploración

- **Tendencia creciente** en la demanda, con un bache en 2020 por la pandemia. Cada año repite picos y valles parecidos.
- **Generación por fuente** (gráfico apilado): sirve para ver de dónde sale la electricidad.
- **2024:** El Niño redujo las lluvias, los embalses bajaron y se encendieron plantas térmicas (franja oscura de generación fósil); hubo racionamientos en mayo de 2024.

> Los datos reales traen eventos que ningún modelo "sabe" de antemano.

- **Estacionalidad** (cajas por mes): marzo tiene la mayor demanda promedio (época seca y calurosa, 31 días) y febrero la menor (menos días).
- **Descomposición aditiva** (`seasonal_decompose`, periodo 12): tendencia casi lineal creciente, estacionalidad con picos marcados y residuo de apariencia aleatoria (lo deseable).
- La prueba pide exactamente estos pasos: graficar, describir con palabras (tendencia y estacionalidad) y descomponer. Cada paso se pide de forma explícita y guiada.

---

## 3. Ecuaciones diferenciales: ¿a qué ritmo crece la demanda?

Modelo de Malthus (crecimiento exponencial):

$$\frac{dD}{dt}=rD \quad\Rightarrow\quad D(t)=D_0e^{rt}$$

- Con logaritmo en ambos lados queda una recta: $\ln D=\ln D_0+rt$. La tasa $r$ se estima con una **regresión de $\ln D$ contra el año**, usando la demanda anual de los años completos (2019 a 2025).
- Resultado: **$r \approx 2{,}7\ \%$ anual**. Con ese modelo, la proyección para 2030 es de unos **14 632 GWh**, frente a unos 12 810 GWh en 2025.
- La EDO se resuelve también de forma numérica con `solve_ivp` (SciPy) y se compara con la solución exacta; coinciden.

> **Nota:** el modelo supone crecimiento exponencial indefinido, algo poco realista para el consumo eléctrico. Un modelo logístico agregaría un techo $K$, pero con estos datos no hay evidencia de saturación, así que estimarlo no se justifica (parsimonia).

---

## 4. Cadenas de Markov: ¿cuándo se encienden las térmicas?

Dos estados por mes:

- **R (renovable):** generación fósil menor de 20 GWh.
- **T (térmica):** generación fósil de 20 GWh o más.

La **matriz de transición** se estima contando las transiciones de un mes al siguiente y dividiendo cada fila por su total (cada fila suma 1).

| Lectura | Valor |
|---|---|
| Si un mes fue T, el siguiente también (T → T) | 72,4 % |
| Si un mes fue R, el siguiente es T (R → T) | cerca de 15 % |

- Los periodos secos **duran varios meses** (memoria entre meses).
- **Distribución estacionaria** ($\pi P=\pi$, $\sum\pi_i=1$): a largo plazo, **cerca de una tercera parte de los meses** (unos cuatro al año) requeriría térmicas, si el clima y la demanda se comportaran como en 2019 a 2026.
- La propiedad de Markov es un supuesto: un año como 2024 rompe la "memoria de un paso".

---

## 5. Regresión: tendencia y mes del año

Modelo: tendencia lineal más un efecto por mes, con enero como referencia.

$$\text{demanda}=\beta_0+\beta_1 t+\sum_{m=2}^{12}\gamma_m\,\mathbb 1[\text{mes}=m]+\varepsilon$$

- **Partición:** entrenar con 78 meses (hasta junio de 2025) y probar con 12 (julio de 2025 a junio de 2026). En series de tiempo **no se baraja**.
- Resultado OLS: pendiente de **2,19 GWh por mes**, $R^2=0{,}782$ (decente para datos reales).

| Modelo | RMSE en prueba (GWh) |
|---|---|
| OLS (sin regularizar) | 28,6 |
| Ridge | 32,2 |
| Lasso | 35,1 |

- **La regularización no ayudó:** con 12 variables poco correlacionadas no hay sobreajuste que corregir, y encoger los coeficientes recorta la pendiente. No siempre ayuda; sirve cuando hay **muchas variables** o **variables parecidas entre sí**.
- **Lasso** (con $\alpha\approx 3{,}99$) dejó 4 de 12 coeficientes en cero: sirve también para **seleccionar variables** (se podría reajustar un modelo con las 8 restantes).
- La regresión con mes del año ya es un modelo de serie de tiempo (tendencia más estacionalidad, como Prophet).
- **Validación cruzada para series:** `TimeSeriesSplit` (validación cruzada incremental), nunca K-fold normal.

---

## 6. Series de tiempo: clásicos contra modernos

Es el corazón del pipeline.

- **Partición:** entrenar hasta junio de 2025, probar los 12 meses siguientes.
- **Línea base:** ingenuo estacional (cada mes repite el mismo mes del año anterior).
- **Clásicos:** Holt-Winters y SARIMA. **Modernos:** Prophet y Chronos-2 (zero-shot).
- **Métricas iguales para todos:** RMSE, MAE y MASE. El RMSE está en las unidades del problema: un RMSE de 25,64 significa que el modelo se equivoca unos 25,64 GWh en promedio.

### SARIMA definido a mano contra Auto-ARIMA

SARIMA(1,0,0)(0,1,1)₁₂ con constante:

- La **diferencia estacional** quita el patrón anual.
- La **constante** hace de deriva (cuánto crece la demanda de un año al siguiente).
- El **AR(1)** recoge la memoria de un mes al siguiente.

| | SARIMA | Auto-ARIMA |
|---|---|---|
| Parámetros | Los define el modelador | Los busca la computadora |
| Cómo elige | Criterio experto | Prueba combinaciones y se queda con la de menor error |
| Cuándo usarlo | Con mucha experiencia en series y patrones conocidos | **Por defecto**, si no hay esa experiencia |

### Resultado con un solo año de prueba

- Todos los modelos le ganan al ingenuo estacional.
- **SARIMA** queda primero (menor RMSE), con Prophet cerca; ningún modelo alcanza bien el pico más alto.

### Validación en varias ventanas (ventana expansiva)

Un solo año de prueba no basta para elegir. Se repite el ejercicio con tres ventanas (pruebas desde julio de 2023, 2024 y 2025): cada vez se entrena con todo lo anterior y se pronostican 12 meses. Se promedia el MASE. Prophet se dejó fuera por tiempo de ejecución, pero conviene incluirlo en la prueba.

- **Orden por MASE promedio:** Holt-Winters, Chronos-2, SARIMA e ingenuo.
- En la ventana desde **julio de 2023** (contiene la sequía de 2024 y el salto de demanda), SARIMA empata con el ingenuo (MASE ≈ 1), mientras Holt-Winters se mantiene alrededor de 0,5 en las tres ventanas.
- **Criterio de elección:** el modelo más simple que le gane al ingenuo de forma consistente (MASE promedio menor que 1 y ninguna ventana desastrosa). Aquí gana **Holt-Winters**.

> **Evento aislado:** la sequía de 2024 puede considerarse un evento atípico que arrastra el promedio de SARIMA hacia arriba. Fuera de esa ventana, SARIMA fue el mejor. Elegirlo igual es una decisión defendible si se argumenta que el evento no es frecuente: es un riesgo que el modelador asume y debe explicitar. Lo importante es razonar la elección, no solo mirar una métrica.

---

## 7. Monte Carlo: ¿qué tan probable es superar cierto consumo?

Un pronóstico puntual no basta para decidir. Se reentrena Holt-Winters con **todos** los datos y se simulan **5000 futuros** de 12 meses; cada futuro suma al pronóstico errores aleatorios del tamaño de los que el modelo cometió en el pasado.

| Resultado | Valor |
|---|---|
| Demanda de los últimos 12 meses observados | 13 070 GWh |
| Media simulada (julio de 2026 a junio de 2027) | 13 941 GWh |
| Intervalo del 90 % | 13 155 a 14 701 GWh |
| P(demanda total > 14 000 GWh) | 45 % |

- Con las simulaciones se obtiene una distribución, se calcula la simulación promedio y se responden preguntas de probabilidad. Es el mismo enfoque de los bancos para estimar, por ejemplo, la probabilidad de que no les paguen cierto monto en créditos.
- **Monte Carlo o MCMC:** aquí se simulan futuros de un modelo ya ajustado (Monte Carlo). MCMC (Metropolis, Gibbs, PyMC) obtiene muestras de la **distribución posterior de los parámetros** cuando no se puede calcular directamente.

> **Nota crítica:** la media simulada implica un crecimiento cercano al **7 %**, muy por encima del 2,7 % anual de la EDO. O el modelo exponencial se queda corto, o la tendencia aditiva de Holt-Winters se está disparando (extrapola el empuje reciente; `damped_trend=True` lo amortigua). Un buen modelador revisa que el pronóstico tenga sentido, no solo su MASE.

---

## 8. Pronóstico final

Con el modelo elegido y todos los datos se pronostica julio de 2026 a junio de 2027.

- **Banda del 80 %:** percentil 10 a percentil 90 de las simulaciones de Monte Carlo. Deja 10 % de los futuros en cada cola y 80 % en el centro.
- El 80 % es una **elección del modelador**: con 90 % o 95 % la banda se ensancha, con menos confianza se angosta.
- **Cómo comunicarlo:** decir "la demanda de noviembre será X GWh" es arriesgado; es mejor decir "con 80 % de confianza estará entre A y B GWh". El pronóstico es una distribución, no un número.

---

## 9. Checklist para la prueba (del notebook)

**Errores frecuentes**

- Barajar los datos o usar K-fold normal en una serie (se filtra el futuro).
- Comparar modelos con conjuntos de prueba o métricas distintos.
- Elegir con un solo año de prueba sin ver si el resultado se repite.
- Decir "el modelo es bueno" sin compararlo con el ingenuo estacional.
- Leer un MASE mayor que 1 como "malo" sin mirar al ingenuo en la prueba.
- Celdas que solo corren en cierto orden o variables sin definir.

**Formulario mínimo**

| Concepto | Fórmula |
|---|---|
| Mínimos cuadrados | $\hat\beta_1=\dfrac{\sum(x_i-\bar x)(y_i-\bar y)}{\sum(x_i-\bar x)^2}$, $\ \hat\beta_0=\bar y-\hat\beta_1\bar x$ |
| MAE | $\frac1n\sum\lvert y_t-\hat y_t\rvert$ |
| RMSE | $\sqrt{\frac1n\sum(y_t-\hat y_t)^2}$ |
| MASE | $\dfrac{\text{MAE del modelo}}{\frac1{T-m}\sum_{t=m+1}^{T}\lvert y_t-y_{t-m}\rvert}$ |
| EDO exponencial | $dD/dt=rD\Rightarrow D(t)=D_0e^{rt}$ |
| Estacionaria | $\pi P=\pi$, $\ \sum_i\pi_i=1$ |

---

## Fuera del notebook — prueba parcial y logística

### Prueba parcial 1 (grupal)

- **Peso:** 20 % de la nota; es la primera evaluación del curso. Evalúa las semanas 1 a 7.
- **Caso:** generación **hidroeléctrica** de Costa Rica (enero de 2019 a 2026). Con poca lluvia, como en 2023 y 2024 con El Niño, los embalses bajan y el país enciende térmicas, más caras y contaminantes; pronosticar la hidro ayuda a anticipar esos momentos. Es muy parecida al ejemplo de hoy, pero con otra serie.
- **Entrega:** grupal, antes de la clase del **5 de noviembre**. En el aula virtual vienen el enunciado y el CSV con los datos.
- **Estructura:**

| Parte | Peso | Contenido |
|---|---|---|
| 1. Aplicación en Python | 60 % | Pipeline completo, muy guiado paso a paso |
| 2. Interpretación conceptual y de código | 25 % | Preguntas independientes entre sí y de la parte 1 |
| 3. Ejercicios a mano | 15 % | Cálculos sin código |

- **Parte 1:** partición fija, entrenar de enero de 2019 a junio de 2025 (78 meses) y probar los 12 meses siguientes, con las mismas tres métricas (RMSE, MAE, MASE). Pasos:
  1. Graficar la hidro completa y, en otro gráfico, la generación fósil.
  2. Describir en dos o tres frases tendencia y estacionalidad (qué meses generan más y menos, y su relación con la época seca y lluviosa).
  3. Descomponer la serie.
  4. Ajustar un modelo clásico y uno moderno.
  5. Comparar y validar, elegir con criterio.
  6. Pronóstico final de 12 meses y riesgo.
- **Parte 2:** preguntas conceptuales, por ejemplo:
  - Qué hacen Ridge y Lasso sobre los coeficientes, por qué controlan el sobreajuste, su diferencia práctica y su relación con el compromiso sesgo-varianza.
  - Interpretar en palabras la segunda fila de una matriz de transición.
  - Dado un código ya hecho, decir si es Monte Carlo o MCMC.
  - Interpretación de resultados.
- **Parte 3 (a mano):**
  - Un modelo de crecimiento exponencial como el del código y el cálculo de métricas.
  - Una cadena de dos estados: distribución a dos pasos desde un estado dado y distribución estacionaria (con un sistema de ecuaciones, como en clase).
- **Formato de entrega:**
  - "A mano" significa sin código: puede ser en tablet o cuaderno (escaneado a PDF), o en LaTeX.
  - Se puede hacer todo en el notebook usando celdas de texto con LaTeX, o aparte en un PDF.
  - Las respuestas de la parte 2 pueden ir en celdas de texto o en un PDF escrito en computadora.
  - Se permite apoyarse en IA, por ejemplo para escribir LaTeX.

### Organización de la sesión

- El resto de la clase se trabajó en salas por grupo, con el docente disponible para dudas hasta las 5:50 p. m.

---

## Conceptos clave

1. **El pipeline es siempre el mismo:** descargar, explorar, modelar, validar, elegir, pronosticar. Cada paso se pide explícitamente en la prueba.
2. **Los datos reales tienen eventos imprevisibles** (El Niño y los racionamientos de 2024): ningún modelo los anticipa.
3. **EDO exponencial:** $r$ se estima con una regresión sobre $\ln D$; es útil como primer modelo, pero supone crecimiento exponencial para siempre.
4. **Markov:** la matriz de transición se estima contando transiciones (filas suman 1) y la distribución estacionaria da la fracción de meses a largo plazo en cada estado.
5. **La regularización no siempre mejora:** ayuda con muchas variables o variables correlacionadas; Lasso además selecciona variables.
6. **En series de tiempo no se baraja:** se valida con `TimeSeriesSplit` o ventana expansiva.
7. **Un solo año de prueba engaña:** se valida en varias ventanas y se elige el modelo más simple que le gane al ingenuo de forma consistente (MASE promedio menor que 1).
8. **Eventos aislados:** conviene identificarlos y decidir de forma explícita si se asume o no el riesgo de que se repitan.
9. **Monte Carlo** simula muchos futuros del modelo ajustado y permite responder preguntas de probabilidad; **MCMC** muestrea la posterior de los parámetros.
10. **Pronosticar es dar una distribución:** "con 80 % de confianza entre A y B" es más honesto que un solo número.
11. **Revisar la coherencia:** comparar el pronóstico con otros modelos y con lo observado (7 % contra 2,7 %) antes de confiar en él.
