# Semana 5: Regresión clásica y regularizada

**Curso:** BCD5105 Modelado matemático, Lead University (III cuatrimestre 2026, virtual)

**Docente:** Jordy Alfaro Brenes

**Fecha:** jueves 8 de octubre de 2026

**PDF fuente:** `Clases/PDFs/Semana 5 - Regresion clasica y regularizada 2.pdf`

**Cobertura del PDF:** Completo (diapositivas 1 a 52). Según la transcripción no se trabajaron los ejemplos de las diapositivas 13, 21 y 26 ni el ejemplo 1 de la 7 (las soluciones que aparecen aquí se calcularon a partir del enunciado), y todos los bloques de ejercicios quedan como tarea moral. La actividad en salas (diapositiva 49) no se realizó; quedó como actividad complementaria en el aula virtual. Las diapositivas 8, 14, 22 y 27 son espacios de trabajo en blanco.

**Tramos solo del PDF:** la transcripción no toca la comparación de modelos con LOO (diapositiva 47) ni el código del modelo de PyMC línea por línea. La demostración en vivo de PyMC y Bambi tuvo problemas (Bambi no viene instalado en Colab, reinicio de sesión, error de nombre de variable); sus resultados salen de las diapositivas 45 y 46.

**Contexto:** la semana 4 terminó en "prior × verosimilitud"; esta semana se parte de la recta de mínimos cuadrados y se llega a ver la regularización como un prior. La regresión parece un modelo simple, pero es de los más usados en la práctica (banca, política social, energía) por dos razones: **interpretabilidad** (los coeficientes se leen directamente) y **explicabilidad regulatoria** (hoy no basta con decir "el modelo no aprobó el crédito"; hay que poder justificarlo). Mucha gente la usa sin saber qué ocurre por dentro: por eso se construye primero a mano. La sesión tiene dos mitades: a mano y en Python.

**Objetivos:** calcular a mano la recta de mínimos cuadrados y predecir con ella; juzgarla con $R^2$ y residuos; explicar qué hacen Ridge, Lasso y Elastic Net y cuándo usar cada uno; elegir la fuerza de la regularización con validación cruzada sin fuga de datos; leer una regresión bayesiana.

| Bloque | Tema | Diapositivas |
|---|---|---|
| 1 | La recta de mínimos cuadrados | 4–9 |
| 2 | ¿Qué tan buena es la recta? | 10–15 |
| 3 | Regularización: Ridge, Lasso y Elastic Net | 16–23 |
| 4 | Validación cruzada | 24–28 |
| — | Receso | — |
| 5 | Python: OLS, diagnóstico y regularización | 29–40 |
| 6 | Python: validación y regresión bayesiana | 41–48 |
| 7 | Actividad en salas (no realizada) | 49 |

---

# Parte 1: Regresión, a mano (diapositivas 3–28)

## 1. Adivinar el ingreso de un hogar (diapositiva 4)

Problema simplificado: predecir el ingreso de un hogar solo con los años de escolaridad del jefe del hogar, a partir de una encuesta.

$$y_i=\beta_0+\beta_1x_i+\varepsilon_i$$

| Símbolo | Qué es |
|---|---|
| $y_i$ | Ingreso del hogar $i$ (variable dependiente) |
| $x_i$ | Años de escolaridad del jefe (variable independiente) |
| $\beta_0$ | **Intercepto:** ingreso esperado con 0 años de escolaridad |
| $\beta_1$ | **Pendiente:** cuánto sube el ingreso por cada año extra de escolaridad |
| $\varepsilon_i$ | **Error:** lo que la recta no explica |

- Los puntos son los datos observados; la **recta de mejor ajuste** es la que, en promedio, pasa más cerca de ellos. No puede pasar por todos salvo que los puntos sean colineales.
- **Residuo:** distancia vertical entre el dato y la recta, $y_i-\hat y_i$.

> **Nota:** el residuo es la diferencia entre el valor real y el valor **predicho** por la recta ($\hat y_i$), no el "observado" (que es el real).

- La regresión lineal es un **problema de optimización**: se busca la recta que minimice una función de pérdida, y esa pérdida son los residuos al cuadrado.

## 2. Mínimos cuadrados (diapositiva 5)

$$\text{RSS}(\beta_0,\beta_1)=\sum_i (y_i-\beta_0-\beta_1x_i)^2\;\to\;\text{minimizar}$$

$$\hat\beta_1=\frac{S_{xy}}{S_{xx}}=\frac{\sum(x_i-\bar x)(y_i-\bar y)}{\sum(x_i-\bar x)^2}\qquad\hat\beta_0=\bar y-\hat\beta_1\bar x$$

- **¿Por qué al cuadrado?** (1) Los errores hacia arriba y hacia abajo no se cancelan, porque todos quedan positivos. (2) Se castiga más a los errores grandes.
- $S_{xy}$ mide si $x$ e $y$ se mueven juntas: es positivo si los hogares con más escolaridad que el promedio tienen más ingreso que el promedio.
- $\hat\beta_0=\bar y-\hat\beta_1\bar x$ obliga a la recta a pasar por el punto $(\bar x,\bar y)$. Siempre se calcula primero la pendiente y con ella el intercepto.

## 3. Micro ejemplo: cinco hogares (diapositiva 6)

Escolaridad $x$ = 6, 9, 11, 14, 16 años; ingreso $y$ = 4, 6, 7, 10, 12 (cientos de miles de colones). Es la misma fórmula, hecha de forma sistemática en una tablita.

1. **Promedios:** $\bar x=56/5=11.2$ y $\bar y=39/5=7.8$.
2. **Tablita:** columnas $x-\bar x$, $y-\bar y$, su producto y $(x-\bar x)^2$.

| Hogar | $x$ | $y$ | $x-\bar x$ | $y-\bar y$ | Producto | $(x-\bar x)^2$ |
|---|---|---|---|---|---|---|
| 1 | 6 | 4 | −5.2 | −3.8 | 19.76 | 27.04 |
| 2 | 9 | 6 | −2.2 | −1.8 | 3.96 | 4.84 |
| 3 | 11 | 7 | −0.2 | −0.8 | 0.16 | 0.04 |
| 4 | 14 | 10 | 2.8 | 2.2 | 6.16 | 7.84 |
| 5 | 16 | 12 | 4.8 | 4.2 | 20.16 | 23.04 |
| **Suma** | | | | | **50.2** ($S_{xy}$) | **62.8** ($S_{xx}$) |

3. **Coeficientes:** $\hat\beta_1=50.2/62.8\approx0.8$ y $\hat\beta_0=7.8-0.8\cdot11.2\approx-1.15$. La recta es $\hat y=0.8x-1.15$.
4. **Predicción** para 12 años: $0.8\cdot12-1.15\approx8.4$, es decir, unos ₡843 000 (con la pendiente sin redondear sale 8.43; con 0.8 exacto, 8.45).

**Interpretación (lo importante):**
- **Pendiente:** cada año extra de escolaridad se asocia a unos ₡80 000 más de ingreso.
- **Intercepto:** −₡115 000 para 0 años de escolaridad no tiene sentido (ingreso negativo), así que aquí no se interpreta.
- Con más de una variable el cálculo a mano deja de ser viable; ahí entra el computador, que hace exactamente lo mismo.

## 4. Interpretar la recta (diapositivas 7–9)

**Ejemplo 2 (tienda):** $\hat y=2.1+0.45x$, con $y$ = ventas (millones) y $x$ = publicidad (cientos de miles).
- **Pendiente:** por cada ₡100 000 de publicidad se obtienen ₡450 000 más en ventas.
- **Predicción** con $x=20$ (₡2 000 000 en publicidad): $2.1+0.45\cdot20=11.1$ millones en ventas.
- **Intercepto:** técnicamente sí tiene sentido: sin publicidad, las ventas base serían de 2.1 millones.

> **Nota:** el intercepto es el nivel base de ventas sin publicidad, no un "tope".

**Ejemplo 1 (sin resolver en clase):** cuatro hogares con $x$ = 8, 10, 12, 14 y $y$ = 5, 6, 8, 9: $\bar x=11$, $\bar y=7$, $S_{xy}=14$, $S_{xx}=20$, $\hat\beta_1=0.7$, $\hat\beta_0=-0.7$; con 13 años, $\hat y=8.4$. Esta recta se reutiliza en los bloques siguientes.

**Ejercicios (tarea moral):** horas de estudio $x$ = 2, 4, 6, 8 y nota $y$ = 60, 70, 75, 85 (recta, predicción con 5 y con 20 horas, ¿se le cree la de 20?); interpretar una pendiente de −0.6 en ingreso por persona contra tamaño del hogar y decidir si implica que tener más hijos *causa* menos ingreso; por qué no se minimiza la suma de residuos sin elevarlos al cuadrado y cuánto suman los residuos de una recta horizontal en $\bar y$.

---

## 5. ¿Qué tan buena es la recta? (diapositiva 10)

$$R^2=1-\frac{\text{RSS}}{\text{TSS}}$$

- **TSS:** suma de las distancias al cuadrado de los datos a su promedio $\bar y$ (cuánto varían los datos).
- **RSS:** suma de las distancias al cuadrado de los datos a la recta (lo que queda sin explicar).
- $R^2$ (coeficiente de determinación) es la fracción de la variación que la recta explica, o cuánto mejora la recta frente a predecir siempre el promedio.
- **$R^2=1$:** ajuste perfecto, todos los puntos sobre la recta. **$R^2=0$:** la recta no mejora al promedio; mejor usar el promedio.
- **Advertencia:** un $R^2$ alto no prueba causalidad ni que los supuestos se cumplan. Ejemplo clásico: más helados y más ahogamientos van juntos, pero ambos coinciden con el verano.

**Ejemplo (no resuelto en clase)**, con $\hat y=-0.7+0.7x$ y los cuatro hogares anteriores: predicciones 4.9, 6.3, 7.7, 9.1; residuos 0.1, −0.3, 0.3, −0.1; $\text{RSS}=0.2$; $\text{TSS}=10$; $R^2=1-0.2/10=0.98$: la recta explica el 98 % de la variación del ingreso.

## 6. Regresión múltiple (diapositiva 11)

$$y=\beta_0+\beta_1x_1+\beta_2x_2+\dots+\beta_px_p+\varepsilon\qquad\hat{\boldsymbol\beta}=(X^TX)^{-1}X^Ty$$

- Hay un intercepto y una pendiente **por variable** (con 5 variables, 5 pendientes); a las pendientes en general se les llama **coeficientes**.
- Forma matricial $y=X\beta+\varepsilon$: $X$ tiene una fila por hogar, una columna por variable y una columna de unos para el intercepto. Con una sola $x$, la fórmula vuelve a dar $S_{xy}/S_{xx}$.
- **Ceteris paribus:** $\beta_1$ es el cambio en $y$ cuando $x_1$ sube una unidad y las demás variables se quedan fijas.
- El ingreso puede depender también del número de hijos, del estado civil, etc.

## 7. Los supuestos: LINE (diapositiva 12)

Hay que revisarlos antes de confiar en la recta ("si no, se construye una casa sobre barro"):

| Supuesto | Qué dice | Señal de falla |
|---|---|---|
| **L**inealidad | La relación es una recta, no una curva | Residuos con patrón en U (convendría un modelo parabólico) |
| **I**ndependencia | El error de un hogar no informa sobre el de otro | Residuos con memoria (parecidos entre observaciones seguidas) |
| **N**ormalidad | Los errores siguen una campana; importa para los intervalos | Histograma muy asimétrico |
| Homocedasticidad (**E** de varianza igual) | Los errores tienen la misma dispersión en todo el rango | Residuos en forma de embudo |

**Ejemplo 2 (no resuelto en clase):** embudo en los hogares más ricos → homocedasticidad; residuos parecidos en días seguidos → independencia; residuos en U contra la edad → linealidad.

**Ejercicios (tarea moral):** $R^2$ del ejercicio de horas de estudio; ¿es mal modelo uno con $R^2=0.30$? ¿para qué podría seguir sirviendo?; un ejemplo del proyecto donde la independencia probablemente falle y qué se haría.

---

## 8. Cuando el modelo memoriza (diapositiva 16)

Los dos enemigos de la regresión:

- **Sobreajuste:** con demasiada flexibilidad (p. ej. un polinomio de grado 9) el modelo pasa por todos los puntos, con error de entrenamiento casi cero, pero aprende el **ruido** y se dispara fuera de los datos: no sirve para hogares nuevos. Es como el estudiante que memoriza las preguntas del examen pasado: si cambian un poco, no sabe qué hacer.
- **Colinealidad:** dos variables casi iguales (escolaridad del jefe y de la pareja) hacen que los coeficientes se vuelvan enormes e inestables.

La solución es ponerles una **correa** a los coeficientes para que no crezcan sin necesidad: eso es **regularizar**.

## 9. Ridge: una correa para los coeficientes (diapositivas 17–18)

$$\hat\beta_{\text{ridge}}=\arg\min\;\sum_i(y_i-\hat y_i)^2+\lambda\sum_j\beta_j^2\qquad\text{(simple: }\hat\beta_{\text{ridge}}=\tfrac{S_{xy}}{S_{xx}+\lambda}\text{)}$$

Mínimos cuadrados más una **penalización** por coeficientes grandes ("freno de mano"). $\lambda$ es la fuerza de la correa.

- $\lambda=0$ es mínimos cuadrados. Si $\lambda$ crece, los coeficientes se encogen hacia cero, **sin llegar nunca a cero**.
- **El costo:** se acepta un poco de sesgo a cambio de mucha menos varianza, y eso permite predecir mejor con datos nuevos.
- Se usa en machine learning de forma generalizada.

**Micro ejemplo** con los cinco hogares ($S_{xy}=50.2$, $S_{xx}=62.8$):

| $\lambda$ | $S_{xx}+\lambda$ | $\hat\beta_1=S_{xy}/(S_{xx}+\lambda)$ |
|---|---|---|
| 0 | 62.8 | 0.80 (mínimos cuadrados) |
| 20 | 82.8 | 0.61 |
| 100 | 162.8 | 0.31 |

- La pendiente baja a medida que $\lambda$ sube y nunca llega a cero.
- **¿Qué $\lambda$ elegir?** No se elige a ojo: se elige con **validación cruzada** (se prueban muchos valores por computador). Si el modelo se reentrena meses después, se puede volver a elegir $\lambda$ (p. ej. pasar de 30 a 35).

**Ejemplo (no resuelto en clase)**, con $S_{xy}=14$, $S_{xx}=20$: $\hat\beta_{\text{ridge}}=0.70$ con $\lambda=0$, $0.56$ con $\lambda=5$, $0.35$ con $\lambda=20$; si $\lambda\to\infty$ la pendiente tiende a 0; $\lambda=0$ devuelve mínimos cuadrados.

## 10. Lasso y Elastic Net (diapositiva 19)

$$\hat\beta_{\text{lasso}}=\arg\min\;\sum_i(y_i-\hat y_i)^2+\lambda\sum_j|\beta_j|$$

$$\text{Elastic Net:}\quad\sum_i(y_i-\hat y_i)^2+\lambda_1\sum_j|\beta_j|+\lambda_2\sum_j\beta_j^2$$

| | Ridge | Lasso | Elastic Net |
|---|---|---|---|
| Penalización | $\beta_j^2$ | $\lvert\beta_j\rvert$ | Ambas (dos $\lambda$) |
| Efecto | Encoge todos, ninguno se apaga | Lleva algunos a **cero exacto**: elige variables | Selecciona como Lasso y reparte el efecto entre variables correlacionadas como Ridge |

- **Apagar** una variable es que su coeficiente valga cero: ya no aparece en el modelo.
- **Uso industrial de Lasso:** con 100 variables, Lasso puede dejar solo 10. Con esas 10 se puede reentrenar otro modelo (XGBoost, SVM, etc.); es decir, se usa regresión en una primera fase para descartar variables que solo meten ruido.
- **Regla de decisión:** Lasso selecciona variables; Ridge reparte el efecto entre variables correlacionadas; Elastic Net cuando hay grupos de variables correlacionadas y no se sabe cuáles importan.

## 11. Por qué Lasso apaga: el círculo y el rombo (diapositiva 20)

- Las elipses son las **curvas de nivel** del error; el centro es la solución de mínimos cuadrados (OLS). La solución regularizada es el **primer punto donde la elipse toca la región permitida**.
- **Ridge:** elevar al cuadrado genera una región circular, sin esquinas; el toque cae en un punto con ambos $\beta$ distintos de cero.
- **Lasso:** el valor absoluto genera un rombo, con esquinas sobre los ejes; el toque suele caer ahí, con un $\beta$ exactamente en cero.

**Ejemplo 2 (no resuelto en clase):** 200 variables de un censo y se sospecha que solo unas 10 importan → Lasso; escolaridad del jefe y de la pareja muy correlacionadas y se quieren conservar ambas → Ridge; grupos de variables correlacionadas sin saber cuáles importan → Elastic Net.

**Ejercicios (tarea moral):** $\hat\beta_{\text{ridge}}$ con $S_{xy}=30$, $S_{xx}=50$ y $\lambda=0,10,50,150$, y graficar $\hat\beta$ contra $\lambda$; por qué hay que estandarizar variables en colones y en años antes de Ridge; dibujar círculo y rombo con una elipse centrada sobre el eje $\beta_1$ y ver qué solución da cada correa.

## 12. Validación cruzada: simulacros de examen (diapositiva 24)

$$\text{Error}_{CV}=\frac1K\sum_{k=1}^{K}\text{Error}_k$$

- **Receta:** partir los datos en $K$ partes (folds); cada parte sirve una vez de examen y el resto de entrenamiento; promediar los $K$ errores.
- **Por qué:** una sola partición puede dar una prueba muy fácil (93 %) o muy difícil (85 %) por azar; promediar da un error más sensato.
- El error sobre los datos de entrenamiento siempre engaña a favor del modelo: solo el examen con datos no vistos dice la verdad. Por eso siempre se reserva una parte (p. ej. 70/30 u 80/20) que el modelo nunca ve.
- **Elegir $\lambda$:** se calcula el error CV para varios $\lambda$ y se elige el que da el menor error.

**Métricas de error.** Hay varias y la mejor depende del contexto; lo importante es saber interpretarlas, no memorizar fórmulas.
- Regresión: **MAE** (error absoluto medio), **MSE** (error cuadrático medio) y **RMSE** (su raíz).
- Clasificación: precisión, recall, F1.
- El **RMSE** es más interpretable porque queda en las unidades del problema: un RMSE de 1.5 en millones de dólares significa que el modelo falla en promedio por 1.5 millones hacia arriba o hacia abajo.
- **¿Es bueno un error?** Depende: 92 % de precisión puede ser excelente en finanzas y inaceptable en salud; en pronóstico de fútbol, 65–70 % se considera bueno por la alta variabilidad.

**Ejemplo (no resuelto en clase):** RMSE por parte, $\lambda=1$: 2.1, 1.8, 2.4, 2.0, 1.7 (promedio 2.0); $\lambda=10$: 1.9, 1.9, 2.0, 1.8, 1.9 (promedio 1.9). Se elige $\lambda=10$: menor error y menor dispersión entre partes, es decir, más estable.

## 13. Tres formas de hacer trampa sin querer: fuga de datos (diapositiva 25)

La **fuga de datos** es que el examen se filtre antes de tiempo:

1. **Estandarizar antes de partir:** si la media y la desviación se calculan con todos los datos, el examen ya influyó en el entrenamiento.
2. **Elegir $\lambda$ mirando la prueba:** si se prueban muchos $\lambda$ contra el mismo conjunto de prueba, deja de ser un examen honesto.
3. **Barajar una serie de tiempo:** con datos fechados, un K-fold barajado usa el futuro para predecir el pasado.

> **Regla de oro:** todo lo que se aprende de los datos (medias, $\lambda$, selección de variables) se aprende **solo con la parte de entrenamiento**. Los datos de prueba solo sirven para evaluar. En Python, esto es un **Pipeline**.

**Ejemplo 2 (no resuelto en clase):** estandarizar todo el conjunto y luego hacer K-fold → no es honesta; pronosticar el tipo de cambio con K-fold barajado → no es honesta; elegir $\lambda$ con CV en entrenamiento y reportar el error en una prueba nunca usada → sí es honesta.

**Ejercicios (tarea moral):** con 100 hogares y $K=10$, cuántos hogares hay en cada examen, cuántas veces se entrena el modelo para un solo $\lambda$ y para 50 valores de $\lambda$; dejar uno fuera (LOOCV) es K-fold con $K=n$: con $n=5$, cuántos modelos se ajustan y qué ventaja y costo tiene; diseñar la validación para pronosticar la demanda eléctrica mensual del ICE y qué no se puede hacer.

---

# Parte 2: Regresión en Python (diapositivas 29–48)

## 14. El stack de la semana (diapositiva 30)

| Librería | Uso |
|---|---|
| scikit-learn 1.9 | **Predecir** y regularizar: `Pipeline`, `StandardScaler`, `RidgeCV`, `LassoCV`, `ElasticNetCV` |
| statsmodels 0.15 | **Inferir**: errores estándar, p-valores, intervalos y diagnósticos de residuos |
| PyMC 6 y Bambi | Regresión bayesiana; Bambi acepta fórmulas estilo R y arma el modelo de PyMC |
| ArviZ 1.x | Diagnóstico y comparación de modelos con LOO (WAIC ya no está disponible) |

| | Inferir y explicar | Predecir |
|---|---|---|
| Pregunta | ¿Cuánto afecta la escolaridad al ingreso? | ¿Cuál será el ingreso de un hogar nuevo? |
| Herramienta | statsmodels | scikit-learn |
| Métrica reina | Intervalos y significancia | Error en datos no vistos (CV) |

Instalación en Colab: `!pip install -q "pymc>=6" nutpie bambi` (scikit-learn y statsmodels ya vienen instalados).

## 15. ¿Para qué sirve la regresión hoy? (diapositiva 31)

- **Banca (scoring de crédito):** los modelos lineales regularizados son interpretables, auditables y rápidos; el punto de partida típico en riesgo de crédito.
- **Política social (proxy-means test):** predecir el ingreso de un hogar con pocas variables observables para focalizar programas, con selección de variables.
- **Energía y precios:** demanda eléctrica según clima y calendario, elasticidades de precio; regresión múltiple con validación temporal.
- **Modelo de referencia en aprendizaje automático:** antes de una red neuronal, una regresión regularizada bien validada muchas veces gana y se queda en producción.

## 16. Los cinco hogares en scikit-learn (diapositiva 32)

```python
from sklearn.linear_model import LinearRegression
X = np.array([[6], [9], [11], [14], [16]]); y = np.array([4, 6, 7, 10, 12])
ols = LinearRegression().fit(X, y)
ols.coef_[0], ols.intercept_, ols.score(X, y)   # 0.7994, -1.1529, R² = 0.984
```

Coincide con lo calculado a mano (0.80 y −1.15): el computador no cambia la matemática, solo no se equivoca en la aritmética y escala a miles de hogares. Con más variables, `X` simplemente tiene más columnas.

## 17. Los datos de hoy: 300 hogares simulados (diapositiva 33)

Se simulan 300 hogares para conocer la verdad: **0.75** por año de escolaridad, **−0.9** por miembro del hogar, **0.02** por año de edad del jefe y tres variables de **puro ruido** (`ruido1`, `ruido2`, `ruido3`). El ingreso va en cientos de miles, igual que los cinco hogares. La escolaridad de la pareja (`esc_pareja`) es casi gemela de la del jefe: correlación **0.95**.

## 18. statsmodels: cuando la pregunta es inferir (diapositiva 34)

```python
import statsmodels.formula.api as smf
modelo = smf.ols("ingreso ~ escolaridad + tamano_hogar", data=df).fit()
print(modelo.summary())
```

| | Coeficiente | Intervalo 95 % |
|---|---|---|
| Intercepto | 3.033 | [2.218, 3.848] |
| Escolaridad | 0.735 | [0.678, 0.792] |
| Tamaño del hogar | −0.873 | [−0.979, −0.766] |

$R^2=0.765$ (ajustado 0.763).

- **Lectura:** cada año de escolaridad suma unos ₡73 500 al ingreso con el tamaño del hogar fijo; cada miembro extra lo baja unos ₡87 000.
- **Intervalo de confianza:** es más honesto dar un rango ("entre ₡67 800 y ₡79 200") que un valor puntual que difícilmente sea exacto. El valor verdadero (0.75) cae dentro del intervalo.

> **Nota:** el 95 % no es la probabilidad de que el coeficiente esté dentro de este intervalo concreto: significa que, al repetir el muestreo muchas veces, el 95 % de los intervalos así construidos contiene el valor real (ver credibilidad vs. confianza, semana 4).

- **Regla práctica:** statsmodels para el informe que explica; scikit-learn para el sistema que predice (este último no da errores estándar, p-valores ni intervalos).

## 19. El modelo confiesa en sus residuos (diapositiva 35)

- **Residuos vs. ajustados:** una nube sin patrón indica linealidad y homocedasticidad. **Gráfico Q-Q:** puntos sobre la diagonal indican normalidad. Aquí ambos se ven bien.
- **Prueba de Breusch-Pagan** (`het_breuschpagan`): p = 0.017 < 0.05, por lo que detecta una heterocedasticidad leve que a simple vista no se nota.
- En conjunto, los supuestos se cumplen razonablemente y se puede confiar en la regresión.

## 20. Colinealidad en consola (diapositiva 36)

Con solo 25 hogares y una gemela casi exacta de la escolaridad (`esc_gemela`, ruido de desviación 0.1):

| Método | Coef. escolaridad | Coef. gemela |
|---|---|---|
| OLS | +4.84 | −4.05 |
| Ridge ($\alpha=10$, variables estandarizadas) | +0.82 | +0.79 |

- OLS "inventa" coeficientes enormes y de signo opuesto que se cancelan: ₡484 000 por año de escolaridad es absurdo.
- Ridge suma $\lambda I$ a $X^TX$, $\hat\beta=(X^TX+\lambda I)^{-1}X^Ty$, y obliga a las variables correlacionadas a **repartirse el efecto**: estabiliza.
- En `sklearn`, $\lambda$ se llama `alpha`.

## 21. El patrón correcto: Pipeline (diapositiva 37)

```python
pipe = make_pipeline(StandardScaler(), Ridge(alpha=1.0))
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.25, random_state=42)
pipe.fit(X_train, y_train)
pipe.score(X_test, y_test)    # R² en prueba: 0.845
```

- **Por qué estandarizar:** la penalización depende de las unidades; con media 0 y desviación 1 se castiga a todas las variables por igual.
- **Por qué dentro del Pipeline:** el scaler aprende solo del entrenamiento, así que la trampa 1 queda resuelta.
- En tutoriales viejos aparece `Ridge(normalize=True)`; esa opción ya no existe.

## 22. Las rutas de los coeficientes (diapositiva 38)

Al apretar la correa (subir `alpha`) y graficar cada coeficiente: **Ridge** los baja a todos suavemente, muy cerca de cero pero sin apagarlos; **Lasso** los lleva a cero exacto **uno por uno**. Es la tabla del micro ejemplo de Ridge, pero para 7 variables a la vez.

## 23. Lasso: variables que se apagan (diapositiva 39)

```python
lasso = make_pipeline(StandardScaler(), LassoCV(cv=10, random_state=0)).fit(X, y)
```

`LassoCV` eligió `alpha` = 0.056 con CV de 10 partes. Coeficientes (escala estandarizada): escolaridad +2.664, tamaño del hogar −1.636, edad +0.192, esc_pareja 0, ruido1 +0.098, ruido2 0, ruido3 0.

- **Acertó:** apagó la escolaridad de la pareja (redundante) y dos de los tres ruidos.
- **Falló:** `ruido1` sobrevivió con un coeficiente pequeño, y debió apagarse.
- **Elastic Net:** `ElasticNetCV` (con `l1_ratio` entre 0.1 y 1) eligió 1, es decir, Lasso puro, porque los ruidos son inútiles.

## 24. Validación cruzada en código (diapositiva 40)

```python
cv = KFold(n_splits=5, shuffle=True, random_state=42)
rmse = -cross_val_score(pipe, X, y, cv=cv, scoring="neg_root_mean_squared_error")
# [1.447 1.837 2.349 1.732 1.736] -> promedio 1.82
```

- El RMSE promedio de 1.82 significa que el modelo falla en unos **₡182 000** (hacia arriba o abajo). Con ingresos de entre ₡400 000 y ₡1 200 000 no es poco, pero la data es simulada, así que el modelo no es culpable de todo.
- Con una sola partición se podría creer que el modelo es peor (parte 3, RMSE 2.35) o mejor (parte 1, 1.45) de lo que es: por eso se promedia.
- El Pipeline completo va **dentro** de `cross_val_score`: el escalado se reaprende en cada pliegue. OLS, Ridge y Lasso dan el mismo resultado (≈ 1.82): aquí hay pocos ruidos y regularizar casi no cambia el error.

## 25. Elegir $\lambda$: la curva de validación (diapositiva 41)

```python
ridge = make_pipeline(StandardScaler(), RidgeCV(alphas=np.logspace(-3, 3, 50))).fit(X, y)
ridge[-1].alpha_    # 0.655
```

- `RidgeCV` usa una versión eficiente de dejar uno fuera: prueba 50 valores casi al costo de un ajuste.
- **Regla 1-SE:** en vez del mínimo del error, elegir el modelo más simple (más penalizado) a una barra de error estándar del mínimo.

## 26. Cuando los datos tienen reloj: TimeSeriesSplit (diapositiva 42)

Con datos fechados se entrena en el pasado y se prueba en el futuro: el conjunto de entrenamiento **crece de forma incremental** y la prueba siempre viene después.

```python
tss = TimeSeriesSplit(n_splits=4, gap=5)    # gap = colchón de 5 días entre entrenamiento y prueba
```

Resuelve la trampa 3 (nunca usar el futuro para predecir el pasado, ni mezclar fechas de 2024 y 2025 al azar). Vuelve con fuerza en las semanas 6 y 7.

## 27. Caso Costa Rica: pobreza y la ENAHO (diapositiva 43)

- Según la ENAHO 2025 del INEC (Encuesta Nacional de Hogares), el **15.2 %** de los hogares está en pobreza (286 365 hogares) y el ingreso promedio es de **₡1 209 825** mensuales por hogar.
- **Pregunta:** ¿se puede predecir el ingreso con pocas variables fáciles de observar para focalizar programas? El *proxy-means test* es un Lasso con propósito social.
- **Simulación:** de 64 variables, solo 8 tienen efecto real; Lasso seleccionó 20, es decir, las 8 reales y 12 de ruido que se colaron.
- **Asterisco:** el INEC reconoció inconsistencias entre la ENAHO 2025 y la Encuesta Continua de Empleo.

## 28. La regularización es un prior disfrazado (diapositiva 44)

Puente con la semana 4:

- **Prior Normal$(0,\tau^2)$** sobre cada $\beta$: la moda del posterior es **Ridge**, con $\lambda=\sigma^2/\tau^2$.
- **Prior Laplace** (pico en cero: "este $\beta$ vale 0"): la moda del posterior es **Lasso**.
- Un prior más concentrado equivale a una correa más corta.
- **La diferencia que importa:** Ridge entrega un solo punto; el enfoque bayesiano entrega la **distribución completa** de cada coeficiente, es decir, su incertidumbre.

## 29. Regresión bayesiana con PyMC (diapositiva 45)

```python
with pm.Model():
    b0 = pm.Normal("intercepto", mu=0, sigma=10)
    betas = pm.Normal("betas", mu=0, sigma=1, shape=3)       # prior Normal: sabor Ridge
    sigma = pm.HalfNormal("sigma", sigma=5)
    mu = b0 + pm.math.dot(X_std, betas)
    pm.Normal("y_obs", mu=mu, sigma=sigma, observed=y)
    idata = pm.sample(random_seed=2026)
```

Es el mismo patrón de la semana 4 (priors, verosimilitud con `observed=`, `pm.sample`), ahora con coeficientes. Con escolaridad, tamaño del hogar y edad estandarizadas, las medias de los posteriores son 2.7, −1.7 y 0.25. La edad tiene un efecto pequeño cuyo intervalo de 89 % (0.077 a 0.41) no llega a cero. Cada coeficiente es una distribución, y lo que se reporta es su valor central. Para sabor Lasso, basta usar `pm.Laplace`. Este modelo tarda en correr.

## 30. Bambi: la fórmula hace el trabajo (diapositiva 46)

```python
m = bmb.Model("ingreso ~ escolaridad + tamano_hogar", data=df)
idata = m.fit(draws=2000, chains=4, random_seed=2026)
```

- Misma sintaxis de fórmula que statsmodels; con `family="bernoulli"` se vuelve una **regresión logística bayesiana**.
- Elige **priors débilmente informativos** según la escala de los datos (p. ej. `Normal(0, 2.55)` para la escolaridad): siempre hay que leerlos con `print(m)`.
- Resultado: escolaridad 0.74 y tamaño del hogar −0.87, que coincide con statsmodels (0.735 y −0.873), ahora con distribución completa.

## 31. ¿Cuál modelo gana? `az.compare` (diapositiva 47)

Solo del PDF. `az.compare` usa **LOO** (validación cruzada dejando uno fuera, calculada sin reajustar el modelo 300 veces) para estimar qué tan bien predice cada modelo datos nuevos. En ArviZ 1.x reemplaza a WAIC. El modelo completo (escolaridad + tamaño del hogar) gana por 90 puntos de `elpd`, unas 8 veces el error de la diferencia (`dse` = 11): tiene sentido, porque el ingreso se simuló con el tamaño del hogar.

## 32. De Ridge a los modelos de lenguaje (diapositiva 48)

- **L2** = Ridge: penalizar el cuadrado de los coeficientes (Hoerl y Kennard, 1970).
- **Weight decay** = la misma penalización aplicada a los pesos de una red neuronal (millones de pesos).
- Con optimizadores como Adam ambos dejan de ser equivalentes; **AdamW** (Loshchilov y Hutter, 2019) los separa y es el optimizador habitual para entrenar modelos de lenguaje.
- Se verá en la semana 11 con PyTorch. Entender por qué Ridge encoge coeficientes es entender una parte de cómo se regulariza un modelo grande.

## Síntesis (diapositiva 50)

| A mano | En la computadora | Vuelve en |
|---|---|---|
| La tablita de los cinco hogares | `LinearRegression` y statsmodels | Semana 6: ARIMA como regresión con rezagos |
| $R^2$ y los supuestos LINE | Residuos, Q-Q y Breusch-Pagan | Semana 6: diagnóstico de series |
| Ridge con $\lambda=0,20,100$ | Rutas de coeficientes y `RidgeCV` | Semana 11: weight decay y AdamW |
| El círculo y el rombo | `LassoCV` y la ENAHO simulada | Proyecto: selección de variables |
| K-fold y las tres trampas | `Pipeline`, `KFold` y `TimeSeriesSplit` | Semanas 6 y 7: validación temporal |

Tres preguntas detrás de todo: ¿cuál es la mejor recta?, ¿cuánto debo frenarla? y ¿qué creo de sus coeficientes?

---

## Fuera del PDF — logística, tareas y metodología (diapositivas 49 y 51)

- **Actividad grupal en salas (tarea moral, no se entrega ni se califica; no se realizó en clase):** 40 minutos con los grupos del proyecto y un notebook de Colab compartido. Está subida al aula virtual como actividad complementaria; el énfasis está en la reflexión y la interpretación, no en el código, que viene muy guiado. Partes: (1) a mano, recta de cuatro tiendas, su $R^2$ y el encogimiento de Ridge con tres valores de $\lambda$; (2) Python, consumo eléctrico de 400 hogares con statsmodels y lectura de residuos; (3) Python, Ridge, Lasso y Elastic Net con Pipeline y validación cruzada, ¿quién gana?; (4) Python, la fuga de datos en vivo: seleccionar variables antes o dentro de la validación.
- **Recordatorio del proyecto:** el avance se entrega en la **semana 8** con un primer modelo aplicado. Una regresión bien validada ya cumple ese requisito.
- **Pendientes (tarea moral):** resolver los ejercicios de los cuatro bloques, terminar lo abierto de la actividad y leer Hyndman y Athanasopoulos, *Forecasting: Principles and Practice* (3.ª ed.), capítulos 1 a 3 (otexts.com/fpp3).
- **Clase 6 (jueves 15 de octubre, series temporales clásicas):** componentes (tendencia, estacionalidad y ruido), modelos ARIMA y SARIMA, diagnóstico y validación de modelos de series, con statsmodels en Python y fpp3 en R (con más énfasis en R). Más adelante se ven modelos modernos (Prophet, Chronos y TimesFM): a veces superan a los clásicos, pero en otros datos un ARIMA o SARIMA clásico funciona igual de bien. Un ARIMA es, en el fondo, una regresión de la serie contra su propio pasado, validada siempre hacia adelante como en `TimeSeriesSplit`. Dudas: jordy.alfaro@ulead.ac.cr.
- **Asistencia:** la lista se pasó al final de la clase.

## Conceptos clave (diapositiva 52)
1. **La mejor recta minimiza los errores al cuadrado:** se calcula con una tablita ($S_{xy}/S_{xx}$) y se juzga con $R^2$ y con los residuos (supuestos LINE). Un $R^2$ alto no prueba causalidad.
2. **Regularizar es ponerle correa al modelo:** Ridge encoge, Lasso apaga variables y Elastic Net mezcla. El precio es un poco de sesgo a cambio de menos varianza; ayuda con el sobreajuste y la colinealidad. Siempre se estandariza dentro de un Pipeline.
3. **Validar es examinar con datos no vistos:** K-fold elige $\lambda$; `TimeSeriesSplit` cuando hay reloj. Todo lo que se aprende de los datos se aprende solo con el entrenamiento (si no, hay fuga de datos).
4. **Un prior es una correa con incertidumbre:** prior Normal es Ridge, prior Laplace es Lasso; el enfoque bayesiano entrega la distribución completa de cada coeficiente.
5. **La interpretación pesa más que el procedimiento:** el contexto decide si un error o un $R^2$ es bueno o malo.
