# Semana 4: Simulación de Monte Carlo y MCMC

**Curso:** BCD5105 Modelado matemático, Lead University (III cuatrimestre 2026, virtual)
**Docente:** Jordy Alfaro Brenes
**Fecha:** jueves 1 de octubre de 2026
**PDF fuente:** `Clases/PDFs/Semana 4 - Simulacion de Monte Carlo y MCMC 2.pdf`
**Cobertura del PDF:** Completo (diapositivas 1 a 45). En clase quedaron sin resolver los ejemplos de Metropolis-Hastings (diapositiva 19) y de Bayes a mano (diapositiva 24), y todos los bloques de ejercicios como tarea moral. La actividad en salas (diapositiva 42) no se realizó.
**Tramos solo del PDF:** la transcripción no toca el diagnóstico del muestreo (diapositiva 39: R-hat y ESS) ni el código de PyMC línea por línea; esas partes salen del PDF.

**Contexto:** la semana 3 fue "dada una cadena, encontrar su $\pi$"; esta semana es al revés: dada una $\pi$ (el posterior), diseñar la cadena. Sigue el enfoque estocástico, y se vuelve a Python (R solo se usó en las semanas 3 y 6). La sesión tiene dos mitades: primero a mano, después en Python.
**Objetivos:** explicar por qué el azar sirve para calcular cosas que no son aleatorias; estimar $\pi$, una integral y un VaR con pocos puntos y saber cuánto confiar; dar dos pasos de Metropolis-Hastings a mano; actualizar una creencia con Bayes y leer un posterior; replicarlo con NumPy y PyMC.

| Bloque | Tema | Diapositivas |
|---|---|---|
| 1 | Monte Carlo y la ley de los grandes números | 4–9 |
| 2 | Monte Carlo como promedio: integrales y VaR | 10–14 |
| 3 | MCMC: Metropolis-Hastings y Gibbs | 15–21 |
| 4 | Bayes a mano | 22–26 |
| 5–6 | Python: $\pi$, integrales, riesgo cambiario, Metropolis, NUTS y PyMC | 27–41 |
| 7 | Actividad en salas (no realizada) | 42 |

---

# Parte 1: Monte Carlo y MCMC, a mano (diapositivas 3–26)

## 1. Hacer estadística con dados (diapositiva 4)

$$\frac1N\sum_{i=1}^{N} f(X_i)\;\approx\;E[f(X)]\quad\text{para } N \text{ grande}$$

$E$ es la esperanza, es decir, el **valor esperado**; el lado izquierdo es un promedio de $N$ imágenes.

- **Ley de los grandes números:** cuantas más repeticiones, más se acerca el promedio al valor esperado teórico. Es la garantía de que el método funciona.
- **Ejemplo de la moneda:** con 5 lanzamientos pueden salir 4 escudos y 1 corona sin que la moneda esté trucada; con 100 000 lanzamientos la proporción anda cerca de 50/50. La diferencia inicial se va cerrando.
- **Cualquier pregunta se escribe como promedio:** una probabilidad es el promedio de un "sí o no"; un área, una esperanza y un riesgo también.
- **Origen del nombre:** Ulam y von Neumann (Los Álamos, fines de los años 40); Metropolis propuso el nombre por el casino de Mónaco.
- **Regla de Monte Carlo:** si la fórmula no existe o es intratable, se generan muchos números al azar y la ley de los grandes números hace el trabajo. Lo esencial es que está diseñado para hacer **muchas simulaciones**.

> **Nota:** la ley de los grandes números no asume normalidad; requiere observaciones independientes (o casi) con valor esperado finito. Lo que se acerca es el promedio a la probabilidad o esperanza teórica, cualquiera sea la distribución (uniforme, gamma, etc.).

## 2. Micro ejemplo: estimar $\pi$ tirando puntos (diapositiva 5)

Cuadrado de lado 1 con un cuarto de círculo de radio 1. Se tiran puntos al azar en el cuadrado y se cuentan los que caen dentro del cuarto de círculo.

1. Área del cuarto de círculo: $\pi r^2/4=\pi/4$ (con $r=1$).
2. Fracción esperada de puntos dentro = razón de áreas: $\dfrac{\text{puntos dentro}}{\text{puntos totales}}=\dfrac{\pi/4}{1}=\dfrac{\pi}{4}$.
3. Se despeja: $\pi\approx 4\cdot\dfrac{\text{puntos dentro}}{\text{puntos totales}}$. El denominador son los puntos **totales** (incluye los de adentro), no los de afuera.
4. Con 20 puntos y 16 dentro: $\pi\approx4\cdot16/20=3.2$. Está cerca de 3.14 pero con diferencia apreciable.

Los puntos caen al azar (con `random`): en otra corrida podrían ser 15 dentro y 5 fuera. No se busca forzar el valor de $\pi$; la teoría dice que con más puntos la estimación tiende a la constante.

## 3. El error baja como $1/\sqrt{N}$ (diapositiva 6)

| Puntos $N$ | 100 | 1 000 | 10 000 | 100 000 |
|---|---|---|---|---|
| Error típico de la estimación de $\pi$ | 0.171 | 0.052 | 0.015 | 0.005 |

- Los puntos (error típico de 200 estimaciones con $N$ puntos) caen sobre una recta de pendiente $-\tfrac12$ en escala log-log.
- **Regla de oro:** para bajar el error a la mitad hay que **cuadruplicar** la muestra. Para ganar un decimal, multiplicar $N$ por 100.
- La tasa $1/\sqrt{N}$ **no depende de la dimensión** del problema.

## 4. Ejemplos de Monte Carlo y la ley de los grandes números (diapositivas 7–9)

**Ejemplo 1 (50 puntos, 41 dentro):** $\pi\approx4\cdot41/50=3.28$.
- Para pasar de un error de 0.23 a uno de 0.06: $0.23/0.06\approx3.83\approx4$, o sea un error **cuatro veces menor**. Como dos veces menor exige ×4, cuatro veces menor exige ×4 dos veces: $50\cdot16=800$ puntos.
- El factor se aplica solo al total de puntos; los de adentro también crecen, pero la cuenta usa el total.

**Ejemplo 2 (12 lanzamientos de dos dados):** sumas 7, 5, 9, 7, 11, 6, 7, 8, 4, 7, 10, 3.
- $P(\text{suma}=7)\approx4/12\approx0.33$. El valor exacto es $6/36=1/6\approx0.167$ (de las 36 parejas posibles, 6 suman 7).
- La estimación es el doble del valor real porque la muestra es diminuta ($N=12$). Con 1 200 lanzamientos el error ya sería ≈ 0.011.

**Ejercicios (tarea moral):** 30 puntos con 25 dentro y evaluar si la estimación es "mala" con $1/\sqrt N$; cuánto hay que agrandar una encuesta para bajar el error de 5 a 1 punto porcentual; describir cómo estimar por simulación la probabilidad de que en 23 personas dos cumplan años el mismo día (paradoja del cumpleaños: con 23 ya es alta y con 40–50 es casi un hecho).

---

## 5. Monte Carlo como promedio: integrales (diapositiva 10)

$$\int_a^b f(x)\,dx\;\approx\;\frac{b-a}{N}\sum_{i=1}^{N} f(x_i)$$

La integral es un promedio disfrazado: el promedio de $f$ en puntos al azar, multiplicado por la longitud del intervalo. Aquí $a$ es el límite inferior y $b$ el superior; $N$ es la cantidad de puntos.

**Micro ejemplo** $\int_0^1 x^2dx$ (valor real $1/3\approx0.33$), con los puntos 0.2, 0.4, 0.6, 0.8:
1. Se evalúa $f$ en cada punto: 0.04, 0.16, 0.36, 0.64.
2. Se suman: 1.2.
3. Se multiplica por $(b-a)/N=1/4$: estimación $0.3$.

- Cambiar la función solo cambia la columna de $f(x_i)$ (aquí $x^2$).
- Más puntos intermedios dan mejor aproximación; con uno solo (0.5) sería peor.
- Los puntos pueden ser negativos (el intervalo puede estar en negativos) y no tienen por qué ser equidistantes; lo esencial es que sean **al azar**.

> **Nota:** $b-a$ es siempre positivo porque $b>a$, pero la integral es un área con signo: si $f$ toma valores negativos, el resultado puede ser negativo.

**Ejemplo 1:** $\int_0^2 x^2dx$ (real $8/3\approx2.67$) con los puntos 0.2, 0.7, 1.1, 1.6: imágenes 0.04, 0.49, 1.21, 2.56; suma 4.3; $\tfrac{2}{4}\cdot4.3=2.15$.
- **¿Por qué sale baja?** Hay un hueco entre 1.6 y 2, justo donde $f$ es más alta. La respuesta directa es más puntos; la más fina es muestrear donde la función es grande (p. ej. agregar 1.85), idea llamada **muestreo por importancia**.

**Ejercicios (tarea moral):** $\int_0^1 \frac{4}{1+x^2}dx$ con 0.1, 0.4, 0.6, 0.9 (¿qué número aparece?); VaR 99 % de los mismos escenarios; probabilidad de terminar en menos de 120 días una obra de tres etapas inciertas.

## 6. Value at Risk: el percentil de las pérdidas (diapositivas 11–14)

**Pregunta del banco:** ¿cuánto podría perder en los próximos 30 días en un mal escenario, pero no en el peor imaginable?

$$\text{VaR}_{95\%}=\text{percentil 95 de las pérdidas}$$

**Receta:** (1) simular muchos escenarios del factor de riesgo, (2) calcular la pérdida de cada uno, (3) ordenar y leer el percentil. Solo el 5 % de los escenarios es peor; el histograma concentra el grueso en pérdidas bajas y deja una cola derecha pequeña.

**Ejemplo 2:** 20 escenarios de pérdida (millones): 2.1, −0.5, 3.4, 1.2, 0.8, 5.9, −1.3, 2.7, 0.3, 4.1, 1.9, −0.2, 3.0, 7.8, 0.6, 2.2, 1.5, −0.9, 3.8, 1.1.
- **a) VaR 95 %:** se ordenan de menor a mayor y se toma la posición $20\times0.95=19$: **5.9 millones**.
- **Lectura:** con 95 % de confianza, la pérdida en el periodo no supera 5.9 millones.
- **b) Pérdida promedio:** $39.5/20\approx1.98$ millones.
- **c) ¿Por qué el banco mira el VaR y no el promedio?** El promedio describe un periodo típico; con 1.98 de reserva, 9 de los 20 escenarios quedarían sin cubrir. El VaR responde cuánto colchón hace falta para sobrevivir a casi todos los escenarios (lo que un regulador pregunta).

> **Nota:** `np.percentile(perdidas, 95)` interpola entre el 19.º y el 20.º valor y da ≈ 5.995, no exactamente 5.9. A mano, con 20 escenarios, el 5 % peor es un único escenario y se lee directamente.

**Ejercicio 2:** con los mismos datos el VaR 99 % obliga a pensar qué pasa cuando 20 escenarios no alcanzan para leer una cola de 1 %.

---

## 7. ¿Y si no sé muestrear? (diapositiva 15)

- **Límite del Monte Carlo simple:** se supone que se saben generar puntos de la distribución (uniforme, normal). En inferencia bayesiana el posterior es una fórmula conocida solo salvo una constante:

$$p(x)=c\cdot g(x),\quad g \text{ fácil de evaluar},\ c \text{ desconocida}$$

- **Idea de MCMC (Markov Chain Monte Carlo):** construir una caminata (una cadena de Markov) que pase más tiempo donde $g$ es grande, en la proporción exacta de la densidad.
- **Puente con la semana 3:** entonces se tenía una cadena y se encontraba su distribución estacionaria $\pi$; ahora se tiene $\pi$ (el posterior) y se **diseña la cadena**.

## 8. Metropolis-Hastings (diapositivas 16–17)

1. **Estar en $x$:** posición actual de la cadena.
2. **Proponer $x'$:** un salto al azar cerca, $x'=x+\text{ruido}$.
3. **Comparar:** razón $r=g(x')/g(x)$. La constante $c$ **se cancela**, que es justo la ventaja: no hace falta conocerla.
4. **Decidir:** se sortea $u\sim U(0,1)$; si $u<r$ se pasa a $x'$, si no la cadena se queda en $x$. Equivale a aceptar con probabilidad $\min(1,\,g(x')/g(x))$.

- Si $x'$ es más probable ($r\ge1$), siempre se acepta: la cadena sube hacia donde hay más densidad.
- Si $x'$ es menos probable, se acepta a veces (con probabilidad $r$): por eso la cadena también visita las colas en la proporción correcta.

**Micro ejemplo:** $g(x)=e^{-x^2/2}$ (normal estándar sin normalizar), $x_0=0$, con razón $r=e^{-(x'^2-x^2)/2}$.

| Paso | $x$ | $x'$ | $r$ | $u$ | Decisión |
|---|---|---|---|---|---|
| 1 | 0 | 0.8 | 0.73 | 0.5 | $u<r$: acepto, $x_1=0.8$ |
| 2 | 0.8 | 1.6 | 0.38 | 0.7 | $u>r$: rechazo, $x_2=0.8$ |

Cuando se rechaza la propuesta, la cadena **se queda** y ese valor se cuenta otra vez como muestra. El paso 2 muestra por qué las colas se visitan menos: alejarse del centro baja la probabilidad de aceptación.

## 9. Gibbs: una variable a la vez (diapositiva 18)

- Con varios parámetros, en vez de saltar en todas las direcciones a la vez se actualiza una variable fijando las demás ("ajustar una perilla a la vez"). Es un caso de Metropolis-Hastings que siempre acepta.
- **Conviene** cuando las condicionales son conocidas y fáciles de muestrear.
- **Debilidad:** con variables muy correlacionadas avanza "en escalera" con pasos cortos y tarda en recorrer la distribución.
- A mano no se trabaja (es largo); queda para la parte computacional.

**Ejercicios (tarea moral, diapositivas 19–21):** completar tres pasos de Metropolis con $g(x)=e^{-x^2/2}$ desde $x_0=1$ y con $g(x)=e^{-|x|}$ desde $x_0=0$; razonar qué ocurre con saltos diminutos o enormes; por qué no importa desconocer $c$; en qué sentido $x_0,x_1,\dots$ es una cadena de Markov y cuál es su estacionaria; qué pasaría con la escalera de Gibbs si las variables fueran independientes.

## 10. Bayes: actualizar creencias con datos (diapositiva 22)

$$\text{posterior}\;\propto\;\text{prior}\times\text{verosimilitud}$$

El símbolo $\propto$ se lee "proporcional a": el posterior es prior por verosimilitud salvo una constante. En palabras: lo que creo antes, más lo que veo, da lo que creo después.

- **Prior:** lo que se cree del parámetro antes de ver los datos.
- **Verosimilitud:** qué tan compatibles son los datos con cada valor del parámetro.
- **Posterior:** la creencia actualizada; es una **distribución completa**, no un número.
- El posterior de hoy es el prior de los datos nuevos; repetir el proceso da creencias cada vez más confiables. Con la misma proporción observada (36 %), más datos estrechan la curva.

## 11. Micro ejemplo: una prueba diagnóstica (diapositivas 23–26)

Datos: prevalencia $P(E)=0.01$, $P(\neg E)=0.99$, sensibilidad $P(+\mid E)=0.99$, falsos positivos $P(+\mid\neg E)=0.05$. Pregunta: una persona da positivo, ¿cuál es la probabilidad de que esté enferma, $P(E\mid+)$?

Árbol con 10 000 personas:

| | Total | Positivos | Negativos |
|---|---|---|---|
| Enfermas (1 %) | 100 | 99 | 1 |
| Sanas (99 %) | 9 900 | 495 | 9 405 |

Hay 594 positivos, y de ellos 99 están enfermos:

$$P(E\mid+)=\frac{99}{594}\approx0.17=\frac{P(+\mid E)P(E)}{P(+\mid E)P(E)+P(+\mid\neg E)P(\neg E)}$$

- Es la fórmula de Bayes, pero el árbol es más fácil de interpretar.
- **Conclusión:** como la enfermedad es rara (1 %), los falsos positivos de la gran mayoría sana superan a los verdaderos positivos. Un positivo solo sube la probabilidad del 1 % al 17 %.

**Ejercicios (tarea moral):** la misma prueba con prevalencia 10 %; repetir la prueba y usar 1/6 como nuevo prior; posterior de una proporción $\theta\in\{0.2,0.4,0.6\}$ con prior uniforme y verosimilitud $3\theta^2(1-\theta)$; alarma antifraude (0.5 % de fraudes, detecta 95 %, falsa alarma 2 %); identificar un parámetro desconocido del proyecto, un prior razonable y los datos que lo actualizarían.

---

# Parte 2: Monte Carlo y MCMC en Python (diapositivas 27–41)

## 12. El stack de la semana y el generador aleatorio (diapositivas 28, 30)

| Herramienta | Uso |
|---|---|
| NumPy y SciPy | Monte Carlo clásico; `default_rng` y `scipy.stats` |
| PyMC 6 | Inferencia bayesiana (Numba como motor por defecto desde mayo de 2026) |
| nutpie | Implementación rápida de NUTS; PyMC 6 la usa si está instalada |
| ArviZ 1.0 | Diagnóstico y resumen del muestreo; reporta intervalos de 89 % por defecto |
| Bambi | Modelos bayesianos con fórmulas estilo R sobre PyMC (se usa en la semana 5) |

```python
!pip install -q "pymc>=6" nutpie
import numpy as np, pymc as pm, arviz as az, matplotlib.pyplot as plt
rng = np.random.default_rng(2026)   # generador explícito, no np.random.seed
```

- Se usa `default_rng` (mejores propiedades estadísticas y más rápido) en lugar del `RandomState` legado, y se pasa el objeto `rng` a las funciones en vez de fijar una semilla global.
- La semilla del curso es siempre 2026; si la salida no coincide con la de la lámina, revisar que el generador se cree una sola vez y en el mismo orden.

## 13. ¿Para qué sirve Monte Carlo hoy? (diapositiva 29)

- **Finanzas:** Value at Risk; se combinan varios factores de riesgo.
- **Gestión de proyectos:** una distribución a cada costo o duración incierta y se simula el proyecto completo (probabilidad de pasarse de presupuesto o fecha).
- **Ciencia e ingeniería:** integrales en muchas dimensiones; una cuadrícula de 10 puntos por eje necesita $10^d$ evaluaciones, Monte Carlo mantiene su error $1/\sqrt N$ en cualquier dimensión.
- **Estadística e IA:** MCMC muestrea posteriores conocidos salvo una constante; es el corazón de PyMC y Stan.

## 14. $\pi$ e integración a escala (diapositivas 31–32)

```python
pts = rng.random((N, 2))                      # N = 100_000
dentro = (pts[:, 0]**2 + pts[:, 1]**2) <= 1
pi_est = 4 * dentro.mean()                    # 3.14704
```

- Con $10^5$ puntos el error es 0.0054, justo lo que predice $1.64/\sqrt N\approx0.0052$: Monte Carlo promete un error controlado, no decimales. La curva de la estimación salta al inicio y se asienta dentro de una banda que se estrecha como $1/\sqrt N$.
- **Integral de $x^2$** en $[0,1]$: `(rng.random(100_000)**2).mean()` da 0.3317 (frente a 0.30 con 4 puntos a mano); el error baja de 0.033 a 0.0016.
- **Cuándo se usa de verdad:** nunca para $x^2$ (eso se integra directo), sino para integrales de 10, 100 o 1 000 dimensiones, como las esperanzas de un posterior bayesiano. **Maldición de la dimensión:** una cuadrícula de 10 puntos por eje en 20 dimensiones requiere $10^{20}$ evaluaciones; Monte Carlo con $10^6$ puntos ya da un error de milésimas.

## 15. Caso Costa Rica: riesgo cambiario (diapositiva 33)

Un importador debe pagar US\$100 000 dentro de 30 días hábiles. Se simulan 10 000 trayectorias del tipo de cambio y se lee el percentil 95 del día 30.

```python
tc_hoy, sigma = 458.43, 0.004         # BCCR 30/09/2026; volatilidad supuesta
r = rng.normal(0, sigma, size=(10_000, 30))
tc30 = tc_hoy * np.exp(r.sum(axis=1))
np.percentile(tc30, 95)               # 475.33
```

- Costo hoy: ₡45.84 millones; costo en el escenario 95 %: ₡47.53 millones; **VaR 95 % ≈ ₡1.69 millones** (la diferencia).
- La volatilidad diaria de 0.4 % es un supuesto; en el proyecto se calibra con la serie histórica del BCCR.

## 16. Metropolis-Hastings en código (diapositiva 34)

```python
def metropolis(log_g, x0, pasos, paso, rng):
    x = x0; muestras = np.empty(pasos)
    for t in range(pasos):
        xp = x + rng.normal(0, paso)
        a = log_g(xp) - log_g(x)        # en log, la constante desaparece en la resta
        if np.log(rng.random()) < a:
            x = xp                       # acepto
        muestras[t] = x
    return muestras
```

Lo hecho a mano, automatizado. **El tamaño del paso lo es todo:**

| Paso | Aceptación | Resultado |
|---|---|---|
| 0.1 | 97 % | Acepta casi todo, pero avanza lento; no llega a las colas |
| 2.5 | 42 % | Buen balance; el histograma recupera la campana $N(0,1)$ |
| 10 | 11 % | Rechaza casi todo; el histograma no se parece |

## 17. Verificar a Bayes con un millón de personas (diapositiva 35)

Se simula la población (1 % enfermos, positivo con prob. 0.99 si enfermo y 0.05 si no) y se cuenta: la fracción de enfermos entre los positivos da 0.1667, es decir el 1/6 exacto de la cuenta a mano. Simular la población y contar es Bayes sin fórmula, y sigue funcionando cuando el modelo se complica (varias pruebas, prevalencia incierta).

## 18. Lo que domina hoy: HMC y NUTS (diapositiva 36)

- **Hamiltonian Monte Carlo (HMC):** trata el parámetro como una partícula que se desliza por la superficie del $-\log$ posterior y usa el **gradiente** para proponer saltos largos que casi siempre se aceptan: fluir en vez de caminar al azar.
- **NUTS (No-U-Turn Sampler, Hoffman y Gelman, 2014):** elimina el ajuste manual de la trayectoria; se detiene sola cuando empieza a devolverse. Es el muestreador por defecto de PyMC y Stan.

| Método | Cuándo conviene | Debilidad |
|---|---|---|
| Metropolis-Hastings | Solo se puede evaluar la densidad | Hay que afinar el paso; camina al azar |
| Gibbs | Condicionales conocidas y fáciles | Lento con variables correlacionadas |
| HMC / NUTS | Parámetros continuos con gradiente | No maneja parámetros discretos directamente |

## 19. PyMC y leer el posterior (diapositivas 37–38)

Problema: 18 de 50 hogares tienen cierto atributo; ¿qué proporción $\theta$ hay en la población?

```python
with pm.Model() as modelo:
    theta = pm.Beta("theta", alpha=1, beta=1)            # prior: lo que creo antes
    y = pm.Binomial("y", n=50, p=theta, observed=18)     # verosimilitud: los datos
    idata = pm.sample(1000, tune=1000, chains=4, random_seed=2026)   # NUTS automático
az.summary(idata)   # media 0.363, intervalo 89 %: 0.26 a 0.47, r_hat 1.00
```

- **Patrón de siempre:** `pm.Model()`, declarar priors, declarar la verosimilitud con `observed=`, llamar a `pm.sample()`.
- Este modelo tiene solución cerrada (posterior Beta(19, 33), media 0.365) y MCMC coincide: sirve de comprobación.
- **Leer el posterior:** no es un número sino una distribución de valores plausibles. $\theta$ está cerca de 0.36 y con 89 % de probabilidad entre 0.26 y 0.47.
- **Preguntas directas se responden contando muestras:** $P(\theta>0.5)\approx2.3\,\%$ (exacto 2.4 %).
- **Prior plano** Beta(1, 1): "sin ver datos, cualquier proporción es igual de creíble"; los datos hacen el resto.

## 20. Diagnóstico: ¿confiamos en el muestreo? (diapositiva 39)

Solo del PDF. Se corren cuatro cadenas desde puntos distintos y se comparan:

| Indicador | Criterio | Qué revisa |
|---|---|---|
| R-hat | ≤ 1.01 | Variación entre cadenas frente a dentro de ellas; lejos de 1 significa que no convergieron |
| ESS | alto (> 400) | Muestras efectivas: cuántas muestras independientes valen las que se tienen |
| Trazas | "peludas" | Cadenas superpuestas y sin tendencia; si se ven separadas, no reportar nada |

Cadenas bien mezcladas: R-hat = 1.00, ESS ≈ 1058. Cadenas pegadas: R-hat = 3.30, ESS ≈ 4.

## 21. Credibilidad vs. confianza (diapositiva 40)

| Intervalo de credibilidad (bayesiano) | Intervalo de confianza (frecuentista) |
|---|---|
| "Dados los datos y el prior, hay 89 % de probabilidad de que $\theta$ esté entre 0.26 y 0.47": afirmación directa sobre el parámetro | "Si repitiéramos el muestreo muchas veces, el 95 % de los intervalos así construidos contendría el valor real": no es una probabilidad sobre este intervalo |

- La lectura intuitiva que casi todo el mundo da al intervalo de confianza es en realidad la del intervalo de credibilidad: quien dice "hay 95 % de probabilidad de que esté aquí" habla como bayesiano sin saberlo.
- **¿Por qué 89 % y no 95 %?** ArviZ 1.0 lo cambió para recordar que ningún nivel es sagrado: 95 % es una convención, no una ley.

## 22. Caso Costa Rica: dengue bayesiano (diapositiva 41)

Chou-Chen, Barboza, Vásquez, García, Calvo, Hidalgo y Sánchez (UCR, 2023) modelaron los casos de dengue de 32 cantones entre 2000 y 2021 con un modelo bayesiano espacio-temporal de conteo (binomial negativa), usando lluvia, temperatura de superficie, vegetación e índices climáticos ENSO y TNA con rezagos.

- Cada cantón tiene su propio riesgo pero "toma prestada" información de sus vecinos; el resultado es un riesgo con incertidumbre, no un número suelto.
- **Matiz:** usaron **INLA**, una aproximación determinista mucho más rápida, no MCMC. Bayes no es sinónimo de MCMC.
- Referencia: Chou-Chen, S.-W., et al. (2023). Bayesian spatio-temporal model with INLA for dengue fever risk prediction in Costa Rica. *Environmental and Ecological Statistics*, 30(4), 687-713. https://doi.org/10.1007/s10651-023-00580-9

## Síntesis (diapositiva 43)

| A mano | En la computadora | Vuelve en |
|---|---|---|
| $\pi$ con 20 puntos y el error $1/\sqrt N$ | 100 000 puntos y la banda de error | Todo el curso: cualquier simulación |
| Integral con 4 puntos y VaR con 20 escenarios | Integral y VaR del colón-dólar con 10 000 | Proyecto: carriles de riesgo |
| Dos pasos de Metropolis | Metropolis con 5000 pasos y tres tamaños de paso | Semana 12: recocido simulado |
| Bayes de la prueba diagnóstica | Un millón de personas simuladas | Semana 14: bandidos y muestreo de Thompson |
| Prior × verosimilitud | PyMC, NUTS y ArviZ | Semana 5: Ridge y Lasso como priors |

---

## Fuera del PDF — logística, tareas y metodología (diapositivas 42 y 44)

- **Actividad grupal en salas (tarea moral, no se entrega ni se califica; no se realizó en clase):** 40 minutos con los grupos del proyecto y un notebook de Colab compartido. Lo que no se termine queda para la semana. Partes: (1) a mano, VaR con 20 escenarios de cartera de crédito y dos pasos de Metropolis sobre una tasa de morosidad (7 morosos de 40, $g(\theta)=\theta^7(1-\theta)^{33}$); (2) riesgo de plazo de una obra con tres etapas triangulares (probabilidad de pasarse de 120 días y percentil 90); (3) Metropolis propio para la tasa de morosidad, comparado con la solución exacta Beta(8, 34); (4) el mismo modelo en PyMC, con diagnóstico, intervalo y efecto de un prior informativo. Al cerrar, cada grupo piensa qué parte de su carril del proyecto tiene incertidumbre que valdría la pena simular.
- **Tarea moral:** resolver los ejercicios de los cuatro bloques (Monte Carlo, integrales y VaR, Metropolis-Hastings, Bayes a mano), terminar lo abierto de la actividad, repasar mínimos cuadrados y la idea de sobreajuste, y leer la introducción a la regresión lineal en Murphy, *Probabilistic Machine Learning* (probml.github.io).
- **Prueba parcial (grupal, temas 1 a 6):** se asigna en la semana 7 y se resuelve en la semana 8 (según el cronograma; confirmar fechas en el sílabo). Monte Carlo y la inferencia bayesiana entran en ella.
  - Formato habitual: una situación real y encadenada en tres partes: Python (≈ 60 %), conceptual (≈ 25 %) y manual (≈ 15 %). Se da un dataset y se guía el paso a paso.
  - La prueba del cuatrimestre anterior fue un pronóstico de serie temporal (análisis, entrenamiento/prueba, SARIMA, Prophet/Chronos, RMSE y MAE, elegir el mejor modelo y predecir), más preguntas conceptuales de regresión y Markov, y un ejercicio a mano.
  - **Se prioriza la interpretación** sobre cualquier procedimiento.
  - Habrá una clase de repaso integrador en Colab antes de la prueba, haciendo juntos un dataset parecido al de la evaluación. Hasta ahora las clases han sido más teóricas y manuales.
- **Uso de IA:** permitido y alentado, incluso para el código, siempre que se entienda lo que se hace y la parte interpretativa sea propia. No se pedirán métodos que no se hayan visto en el curso, por lo que la IA debe guiarse para coincidir con lo visto.
- **Asistencia:** la lista se pasa al final de la clase.
- **Clase 5 (jueves 8 de octubre, regresión clásica y regularizada):** mínimos cuadrados ordinarios con scikit-learn, regularización (Ridge, Lasso, Elastic Net), validación cruzada y selección de modelos, y regresión bayesiana con PyMC y Bambi (posiblemente algo de regresión logística). Si la idea de prior quedó clara, la semana 5 fluye: Ridge y Lasso equivalen a poner un prior sobre los coeficientes. Dudas: jordy.alfaro@ulead.ac.cr.

## Conceptos clave (diapositiva 45)
1. **El azar calcula:** muchas muestras y un promedio estiman $\pi$, integrales y riesgos. El error baja como $1/\sqrt N$ en cualquier dimensión; para reducirlo a la mitad hay que cuadruplicar la muestra.
2. **MCMC muestrea lo que no sabemos dibujar:** una cadena de Markov diseñada para que su $\pi$ sea el posterior. Metropolis-Hastings es la idea (proponer, comparar con $r=g(x')/g(x)$, aceptar o rechazar; la constante se cancela); NUTS es la herramienta actual.
3. **Bayes actualiza creencias:** prior × verosimilitud da un posterior, una distribución completa que responde directamente lo que se quiere preguntar.
4. **Lo único que cambia es qué tan inteligente es la forma de generar las muestras.**
5. **Credibilidad ≠ confianza:** "hay 89 % de probabilidad de que $\theta$ esté aquí" es una afirmación bayesiana sobre el parámetro.
