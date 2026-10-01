# Semana 3: Cadenas y procesos de Markov

**Curso:** BCD5105 Modelado matemático, Lead University (III cuatrimestre 2026, virtual)
**Docente:** Jordy Alfaro Brenes
**Fecha:** jueves 24 de setiembre de 2026
**PDF fuente:** `Clases/PDFs/Semana 3 - Cadenas y procesos de Markov 2.pdf`
**Cobertura del PDF:** Completo (diapositivas 1 a 44). El ejemplo 2 de la propiedad de Markov quedó como tarea moral y la actividad en salas no se realizó en clase (solo se mostró el documento).
**Tramos solo del PDF:** la transcripción tiene cortes en PageRank, el SIR en redes y parte del código en R; esas secciones salen del PDF.

**Contexto:** la semana 2 fue determinística (EDO); esta semana los modelos son estocásticos. En la parte manual importan los conceptos, no la mecánica del cálculo. El código es en R dentro de Google Colab (solo se usa R en las semanas 3 y 6).
**Objetivos:** reconocer cuándo se cumple la propiedad de Markov; construir diagrama y matriz de transición; proyectar la distribución a varios pasos; calcular la distribución estacionaria y saber cuándo existe; entender qué agrega un modelo oculto; replicarlo en R.

---

# Parte 1: Cadenas de Markov, a mano (diapositivas 1–3)

## 1. La propiedad de Markov (diapositiva 4)

$$P(X_{t+1}\mid X_t, X_{t-1},\dots,X_0)=P(X_{t+1}\mid X_t)$$

El futuro depende solo del presente, no de cómo se llegó a él (la barra "|" indica probabilidad condicional).

- **Estado:** descripción del sistema en un instante (el clima de hoy, la página que se está viendo, la palabra que se acaba de escribir). En el curso el conjunto de estados es finito.
- **Tiempo discreto:** la cadena avanza a saltos; cada salto es una transición, posiblemente al mismo estado.
- **Memoria corta:** toda la historia relevante está resumida en el estado actual. Es una simplificación muy fuerte (aunque las probabilidades se hayan estimado con datos históricos, el modelo solo mira el estado actual), y de ahí viene su poder: alcanza para clima, clientes, web y texto.
- Preguntarse si algo cumple Markov es preguntarse si el estado elegido contiene toda la información necesaria; si no, a veces basta **redefinir el estado**.

## 2. La matriz de transición (diapositivas 5–9)

$$P_{ij}=P(X_{t+1}=j\mid X_t=i)$$

- Cada **fila** es "desde dónde" y cada **columna** "hacia dónde": siempre se lee primero la fila.
- Dos propiedades: $P_{ij}\ge0$ y **cada fila suma 1** (las columnas no tienen por qué). Si las filas no suman 1, la matriz está mal armada.
- Diagrama y matriz son la misma información (cada flecha es una entrada; los lazos son la diagonal), y se puede pasar de uno a otra.

**Clima** (S soleado, N nublado, L lluvioso):

| | S | N | L |
|---|---|---|---|
| **S** | 0.7 | 0.2 | 0.1 |
| **N** | 0.3 | 0.5 | 0.2 |
| **L** | 0.2 | 0.4 | 0.4 |

$P_{LN}=0.4$: si hoy llueve, hay 40 % de probabilidad de que mañana esté nublado. La diagonal mide la persistencia (soleado es el más persistente).

**Estudiante** (E estudia, N no): si estudió hoy, mañana estudia con 0.6; si no, con 0.3. Las flechas faltantes se completan para que cada fila sume 1: $P=\begin{pmatrix}0.6&0.4\\0.3&0.7\end{pmatrix}$. Supuestos del modelo:
1. Solo importa lo que pasó ayer (Markov).
2. **Homogeneidad:** las probabilidades son las mismas todos los días (no distingue lunes de semana de examen).
3. No hay estados intermedios: estudiar 10 minutos cuenta igual que 3 horas.

## 3. La cadena en el tiempo (diapositivas 10–14)

$$\pi_{t+1}=\pi_t P \qquad\qquad P(X_n=j\mid X_0=i)=(P^n)_{ij}$$

- $\pi$ es un vector fila con la distribución de los estados; cada multiplicación por $P$ es un día más. $P$ no cambia (consecuencia de Markov); solo cambia $\pi$. Su suma siempre debe dar 1.
- **Chapman-Kolmogorov:** ir de $i$ a $j$ en $n$ pasos es sumar sobre todos los caminos intermedios, lo que equivale a elevar la matriz a la $n$.
- **Clima, hoy soleado:** $\pi_0=(1,0,0)$, $\pi_1=(0.70,0.20,0.10)$ (la fila S de $P$), $\pi_2=\pi_1P=(0.57,0.28,0.15)$.
- **Estudiante, hoy estudió:** $\pi_1=(0.6,0.4)$ y $\pi_2=(0.48,0.52)$: 48 % de estudiar pasado mañana. Para "mañana" basta leer la fila.
- **Si se sigue multiplicando**, las curvas desde los tres climas iniciales convergen al mismo valor ($\pi(S)\approx0.468$). A dos días el punto de partida aún importa; en unos seis días el clima de hoy casi no informa sobre el de la próxima semana: la cadena "olvida" el inicio.

## 4. Distribución estacionaria (diapositivas 15–19)

$$\pi P=\pi,\qquad \sum_i\pi_i=1$$

- Es el "clima promedio" al que converge la cadena: si hoy la probabilidad está repartida según $\pi$, mañana sigue igual. El clima cambia todos los días, pero la proporción de días de cada tipo a largo plazo no.
- **Cómo se plantea:** los coeficientes de cada ecuación son los de la **columna** correspondiente de $P$. Con $n$ estados salen $n$ ecuaciones más la de suma 1; una de las primeras es combinación de las otras y se reemplaza por $\sum\pi_i=1$. Se resuelve con software.
- **Clima:** $0.7\pi_S+0.3\pi_N+0.2\pi_L=\pi_S$ (y análogas), con solución $\pi=(22/47,\,16/47,\,9/47)\approx(46.8\,\%,\,34.0\,\%,\,19.1\,\%)$, el valor hacia el que convergían las curvas.
- **Estudiante:** $\pi=(3/7,\,4/7)$. En un cuatrimestre de 105 días estudia en promedio $105\times0.4285\approx45$ días.

**Cuándo existe y es única:** la cadena debe ser irreducible y aperiódica.

| Condición | Significado | Contraejemplo |
|---|---|---|
| **Irreducible** | Se puede llegar de todos los estados a todos | Un estado absorbente C (sin salida) atrapa la cadena y $\pi=(0,0,1)$ |
| **Aperiódica** | Sin ritmo fijo | A ⇄ B con probabilidad 1 alterna para siempre: $\pi=(\tfrac12,\tfrac12)$ existe, pero $\pi_t$ oscila. Basta una autotransición para romper el ritmo |

Si una cadena no cumple las condiciones, el estado inicial sí importa. Un estado "Cancelado" sin regreso hace reducible la cadena de streaming, lo que no significa que el negocio esté perdido en el corto plazo.

## 5. Modelos de Markov ocultos (HMM): el monje en la cueva (diapositivas 20–24)

Un monje en una cueva sin ventanas recibe cada día un objeto (paraguas, lentes o sombrero) y con esa secuencia quiere adivinar el clima de afuera.

- **Estados ocultos:** el clima, que sigue su cadena con matriz $P$. **Observaciones:** el objeto, que depende solo del clima de ese día.
- **Dos matrices:** $P$ mueve el estado oculto; $B=P(\text{objeto}\mid\text{clima})$ (matriz de emisión) dice qué señal emite cada estado.

| | Paraguas | Lentes | Sombrero |
|---|---|---|---|
| Soleado | 0.05 | 0.80 | 0.15 |
| Nublado | 0.30 | 0.20 | 0.50 |
| Lluvioso | 0.85 | 0.05 | 0.10 |

- **Cuentas del monje (Bayes en una tabla):** sin información previa supone $\pi_0=(\tfrac13,\tfrac13,\tfrac13)$, multiplica por la columna del objeto, suma (la **evidencia**) y divide cada producto entre la suma (posterior).
- **Lentes:** $0.2667+0.0667+0.0167=0.35$, posterior (S, N, L) = (0.762, 0.19, 0.04). **Paraguas:** suma 0.400, posterior (4 %, 25 %, 71 %): el paraguas no prueba la lluvia, la vuelve muy probable.
- **Día siguiente, predecir y corregir:** se proyecta la creencia con $P$ y luego se multiplica por la columna del nuevo objeto y se normaliza. Repetido día a día es el **algoritmo forward**; **Viterbi** guarda el mejor camino en cada paso (programación dinámica, como Dijkstra).
- Mismo esquema en finanzas (régimen de mercado tras los retornos), voz (fonemas tras el sonido) y genómica (genes tras el ADN).
- A mano se trabaja con dos decimales; en código, con más (las sumas pueden quedar cerca de 1 sin ser exactas).

---

# Parte 2: Cadenas de Markov en R (diapositiva 25)

## 6. Por qué R esta semana (diapositivas 26–27)
- Python domina la IA y la producción; R domina estadística, series temporales y análisis exploratorio. Un científico de datos competitivo lee ambos.
- **markovchain** define un objeto de cadena con métodos para estacionaria, clasificación de estados, simulación y ajuste, cada uno en una línea.
- **R en Colab:** Entorno de ejecución → Cambiar tipo de entorno → R (o colab.to/r). `drive.mount()` solo funciona en Python.

| Paquete | Uso |
|---|---|
| markovchain | Cadenas de tiempo discreto |
| igraph | Grafos y `page_rank()` exacto |
| depmixS4 | Modelos de Markov ocultos |
| expm | Potencias de matrices con `%^%` |
| diagram | Diagrama de flujo de la matriz |

Se instalan con `install.packages(...)` una vez por sesión y hay que cargarlos con `library(...)`.

## 7. Por qué importan hoy (diapositiva 28)
- **Búsqueda:** PageRank de Google (Brin y Page, 1998), estacionaria de un grafo gigante.
- **Recomendación:** PinSage de Pinterest, caminatas aleatorias sobre un grafo de 3 mil millones de nodos (Ying et al., 2018).
- **IA:** un LLM autorregresivo equivale a una cadena de Markov (Zekri et al., 2024).
- **Finanzas y biología:** los HMM detectan regímenes de mercado y predicen genes en el ADN (AUGUSTUS, Tiberius).

## 8. El clima en R (diapositivas 29–31)
```r
mc_clima <- new("markovchain", states = estados, transitionMatrix = P, name = "Clima_CR")
steadyStates(mc_clima)     # 0.468 0.340 0.191 (= 22/47, 16/47, 9/47)
is.irreducible(mc_clima)   # TRUE
period(mc_clima)           # 1 (aperiódica)
```
- **Convergencia:** `round(P %^% 10, 3)` da todas las filas ≈ (0.468, 0.340, 0.191). La fila S de $P^2$ es (0.57, 0.28, 0.15), como en la pizarra; en $P^{10}$ ya no importa el punto de partida: es la estacionaria vista como matriz.
- **Simulación:** `markovchainSequence(n = 365, markovchain = mc_clima, t0 = "Soleado")` con `set.seed()`. Con 365 días la frecuencia de nublados (0.397) se desvía casi seis puntos de $\pi$ (0.340); con 10 000 días coincide a la milésima. Es la ley de los grandes números para cadenas, y un año de datos sigue siendo una muestra ruidosa.

## 9. PageRank (diapositivas 32–33)
- **Problema (Stanford, 1996-1998):** los buscadores ordenaban por frecuencia de palabras clave, algo fácil de manipular. Pregunta de Brin y Page: ¿se puede ordenar la web por importancia?
- **Idea recursiva:** una página es importante si páginas importantes la enlazan; es la estacionaria de un **navegante aleatorio**.
- **Factor de amortiguación $d=0.85$:** con esa probabilidad sigue un enlace y con 0.15 salta a una página al azar, lo que hace la cadena irreducible y aperiódica.
- **Mini-web de seis páginas:** `page_rank(g, damping = 0.85)$vector` da A 0.353, C 0.346, B 0.201, D 0.040, E 0.036, F 0.025. C casi empata con A porque recibe enlaces de A y B; F nadie la enlaza y solo vive del salto aleatorio.

## 10. SIR en redes como proceso de Markov (diapositiva 34)
- El SIR de la semana 2, persona por persona: cada nodo está en S, I o R; un infectado contagia a cada vecino susceptible con probabilidad $\beta$ y se recupera con probabilidad $\gamma$.
- Es Markov (el estado en $t+1$ depende solo del de $t$), pero el espacio de estados es $3^{100}$ para 100 personas: imposible como matriz, fácil de simular. La curva resultante es menos suave que la de las EDO.

## 11. N-gramas y modelos de lenguaje (diapositivas 35–37)
- Un **bigrama** es una cadena de Markov donde cada estado es una palabra y la matriz es $|V|\times|V|$.

| Modelo | Estado | Orden | Limitación |
|---|---|---|---|
| Bigrama | Última palabra | 1 | Olvida todo lo anterior |
| Trigrama | Últimas 2 palabras | 2 | $|V|^2$ estados |
| 5-grama | Últimas 4 palabras | 4 | Intratable sin suavizado |
| Transformer (LLM) | Últimos $K$ tokens | $K$ | Memoria compacta por atención |

- Un $n$-grama es una cadena de orden $n-1$; un LLM es de orden $K$ (la ventana de contexto). La diferencia no es matemática, es de representación.
- **Bigrama con El Quijote** (50 000 palabras): se arma un mapa palabra → siguientes y se muestrea con `sample()`. Los pares tienen sentido ("vuestra merced") pero la frase no. Después de "sancho", el 17 % de las veces viene "panza": eso es una fila de la matriz.
- **¿Los LLM son cadenas de Markov?** Matemáticamente sí; computacionalmente no sirve escribirlos así. Zekri et al. (2024): un LLM con vocabulario $T$ y ventana $K$ equivale a una cadena sobre $\sim T^K$ estados con matriz muy dispersa (vocabulario ~$10^5$ tokens, contexto $10^5$–$10^6$). Permite hablar de estacionaria, de repeticiones a temperatura alta y de cotas de generalización, pero no significa que el modelo guarde la matriz: la red neuronal la aproxima de forma compacta.

## 12. HMM en R: regímenes financieros (diapositiva 38)
- Retornos sintéticos de 600 días con régimen calmo (sd 0.008) y volátil (sd 0.025); `depmix(retornos ~ 1, nstates = 2)` y `posterior(..., type = "viterbi")`.
- El modelo nunca vio el régimen real, solo los retornos: estimó las volatilidades (0.008 y 0.024) y una matriz muy persistente (0.998 y 0.993), y Viterbi recuperó los 600 días. Con datos reales los regímenes se mezclan y el acierto baja.

## 13. Caso costarricense y escalas (diapositivas 39–40)
- **Pensiones (UCR, 2018):** Víquez, Víquez, Campos, Loría y Mendoza modelan cada persona de un régimen de pensiones con una cadena cuyos estados combinan situación, edad y tiempo cotizado (*Revista de Matemática: Teoría y Aplicaciones*, 25(2), 185-214). Idea de proyecto: estados de empleo, morosidad crediticia, uso de transporte.
- **Una sola idea, escalas distintas:** la misma matemática del clima (matriz estocástica, Chapman-Kolmogorov, estacionaria) con espacios de estados de distinto tamaño.

| Sistema | Tamaño del espacio |
|---|---|
| Clima | 3 |
| Cliente de un banco (activo, ocasional, inactivo, fuga) | 4 |
| Epidemia en una red | $3^N$ |
| Bigrama del Quijote | ≈ 7 000 |
| PageRank | Miles de millones |
| LLM | $T^K$ |

## Síntesis (diapositiva 42)

| A mano | En la computadora | Vuelve en |
|---|---|---|
| Propiedad de Markov y $P$ | Objeto markovchain | Semana 14: procesos de decisión de Markov |
| $\pi_{t+1}=\pi_tP$ y $P^n$ | `P %^% n` | Semana 6: series temporales |
| Distribución estacionaria | `steadyStates()` y simulación | Semana 4: MCMC |
| Irreducible y aperiódica | `is.irreducible()`, `period()` | Semana 13: grafos |
| El monje en la cueva | depmixS4 y Viterbi | Presentación grupal 9: LLM y Markov |

---

## Fuera del PDF — logística, tareas y metodología (diapositivas 41 y 43)

- **Grupos:** todos los trabajos del curso son en grupo y los formados esta sesión se mantienen todo el cuatrimestre (tres grupos de 3 o 4 integrantes). Cada grupo envía un correo al docente con su nombre e integrantes; los grupos se arman en el aula virtual durante la semana.
- **Asistencia:** se pasa lista manual, casi siempre al final.
- **Actividad complementaria semanal** (aula virtual, tarea moral, no se entrega): guiada, se puede apoyar en un asistente de IA mientras se razone. La de la semana 3 incluye una matriz de cuatro estados a mano, el mismo ejemplo en R y dos casos aplicados (campaña de retención y PageRank de un sitio de trámites).
- **Tarea moral:** completar los ejercicios de los cuatro bloques (Markov y matriz, cadena en el tiempo, estacionaria, modelos ocultos) y las miniexploraciones en R.
- **Actividad en salas (no realizada):** cliente de un banco con cuatro estados a mano; la misma cadena en markovchain con 1000 meses; efecto de una campaña de retención sobre $\pi$; PageRank de siete páginas cambiando $d$. Además, el grupo confirma su carril del proyecto integrador por correo (no se repiten temas: gana el primero en enviarlo).
- **Clase 4 (1 de octubre, Monte Carlo y MCMC):** simulación de Monte Carlo, MCMC (diseñar una cadena cuya $\pi$ sea la distribución que se quiere muestrear), Metropolis-Hastings y Gibbs, e inferencia bayesiana con PyMC (de vuelta en Python). Lectura: Murphy, *Probabilistic Machine Learning* (introducción a la inferencia bayesiana).

## Conceptos clave (diapositiva 44)
1. **El futuro depende solo del presente:** simplificación radical que alcanza para clima, clientes, epidemias, web y modelos de lenguaje.
2. **$\pi$ es la huella del sistema:** cómo se ve a largo plazo sin importar dónde empezó, si la cadena es irreducible y aperiódica.
3. **Lo oculto también se modela:** con $P$ y $B$ se infiere lo que no se ve a partir de sus señales.
4. **Lectura de $P$:** fila = desde, columna = hacia; cada fila suma 1, las columnas no.
5. **Pasos múltiples:** $\pi_n=\pi_0P^n$; con $n$ grande todas las filas de $P^n$ tienden a $\pi$.
