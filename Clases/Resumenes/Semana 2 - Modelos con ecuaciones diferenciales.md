# Semana 2: Modelos con ecuaciones diferenciales

**Curso:** BCD5105 Modelado matemático, Lead University (III cuatrimestre 2026, virtual)
**Docente:** Jordy Alfaro Brenes
**Fecha:** jueves 17 de setiembre de 2026
**PDF fuente:** `Clases/PDFs/Semana 2 - Modelos con ecuaciones diferenciales 2.pdf`
**Cobertura del PDF:** Completo (diapositivas 1 a 53).
**Fuente:** solo el PDF; no hay transcripción de esta clase (la sesión se dictó grabada).

**Contexto:** primer tipo de modelo del curso, determinístico. Primero a mano (leer e interpretar EDO) y luego en Python con `scipy.integrate`.
**Objetivos:** leer una EDO como regla de cambio; contrastar Malthus y Verhulst; hallar equilibrios y juzgar su estabilidad; interpretar el SIR y $R_0$; resolver y calibrar estos modelos con SciPy.

---

# Parte 1: Modelos con EDO, a mano (diapositivas 1–3)

## 1. Qué es una EDO (diapositivas 4–8)

$$\frac{dy}{dt} = f(t, y)$$

No dice cuánto vale $y$, dice cómo cambia. $t$ es la variable independiente (casi siempre el tiempo), $y(t)$ lo que se quiere entender y $dy/dt$ su rapidez de cambio.

- **Resolver** = hallar $y(t)$ que cumpla la regla a partir de una condición inicial $y(0)=y_0$. Cambiar $y_0$ cambia la solución, no la regla.
- Modelar es traducir una frase ("el cambio de algo depende de…") a una ecuación; la mayor parte del trabajo es la traducción, no la integral.

| Etiqueta | Significado | Consecuencia |
|---|---|---|
| **Orden** | Derivada más alta | Orden $n$ requiere $n$ condiciones iniciales |
| **Lineal** | $y$ y sus derivadas a primera potencia, sin multiplicarse | Casi siempre tiene solución cerrada |
| **Autónoma** | $t$ no aparece explícitamente | Permite dibujar un diagrama de fase |

Ejemplo: $y'=y(1-y)$ es de orden 1, no lineal y autónoma (crecimiento logístico); $y''+2y'+y=\sin t$ es de orden 2, lineal y no autónoma.

## 2. Malthus y Verhulst (diapositivas 9–15)

### Malthus (1798)
$$\frac{dN}{dt}=rN \;\Rightarrow\; N(t)=N_0e^{rt}$$

- Se resuelve por separación de variables. $r$ es la tasa per cápita; el tiempo de duplicación es $\ln 2/r$.
- Supone recursos infinitos: nada crece exponencialmente para siempre.
- **Costa Rica:** 120 000 habitantes en 1864 ($t=0$) y 800 000 en 1950 ($t=86$) dan $r\approx 0.022$. Predice 4.14 M para 2025, pero la realidad es 5.19 M: con solo dos datos, $r$ mezcla épocas distintas y la tasa no fue constante.
- El error no invalida el modelo, lo ubica: sirve en ventanas cortas y lejos del límite.

### Verhulst (1838)
$$\frac{dN}{dt}=rN\left(1-\frac{N}{K}\right)$$

- $K$ es la capacidad de carga. El factor $(1-N/K)$ vale ≈ 1 con $N$ pequeño (Malthus puro) y tiende a 0 cuando $N\to K$: el crecimiento se frena solo.
- Curva en S; el crecimiento es máximo en $N=K/2$ (punto de inflexión).
- Ajustado a los nueve censos del INEC: $r\approx 0.04$, $K\approx 7$ M. El CCP-INEC proyecta 5.7 M en 2050 y luego un descenso, algo que Verhulst (con $K$ constante) no captura.
- Ejemplo: con $r=0.022$, Malthus duplica en ≈ 31.5 años y proyecta ≈ 9 M para 2050 desde 5.19 M, un resultado poco creíble por falta de freno.

## 3. Equilibrios y estabilidad (diapositivas 16–19)

- **Equilibrio:** $N^*$ con $dN/dt=0$. Malthus tiene solo $N^*=0$; Verhulst tiene $N^*=0$ y $N^*=K$.
- **Estable** si, al perturbarlo, la solución regresa; **inestable** si se aleja. El signo de $f(N)$ a cada lado lo decide: positivo empuja a la derecha, negativo a la izquierda.
- Verhulst: $f>0$ en $0<N<K$ y $f<0$ en $N>K$, así que $N^*=0$ es inestable y $N^*=K$ es estable (diagrama de fase).
- Ejemplo: en $y'=y(1-y)$, los equilibrios son $0$ (inestable) y $1$ (estable); desde $y(0)=0.1$, $0.5$ o $1.5$ la solución tiende a 1. En el enfriamiento de Newton, $T'=-k(T-20)$, el equilibrio $T=20$ (ambiente) es estable.

## 4. Sistemas de EDO: el modelo SIR (diapositivas 20–25)

Kermack y McKendrick (1927); población cerrada, $S+I+R=N$:

$$\frac{dS}{dt}=-\frac{\beta SI}{N},\qquad \frac{dI}{dt}=\frac{\beta SI}{N}-\gamma I,\qquad \frac{dR}{dt}=\gamma I$$

- $\beta$: contactos efectivos por día; $S I/N$ cuenta los encuentros susceptible–infectado. $\gamma=1/(\text{duración})$ (7 días → $\gamma=1/7$).
- Lo que sale de un compartimento entra al siguiente, por eso la suma de las derivadas es cero. No tiene solución cerrada.

### $R_0$
$$R_0=\frac{\beta}{\gamma}$$

- Umbral, no velocidad: con $S\approx N$, $dI/dt\approx(\beta-\gamma)I$. Si $R_0>1$ la epidemia crece; si $R_0<1$ se extingue.
- **Inmunidad de rebaño:** proteger a la fracción $1-1/R_0$ (con $R_0=3$, 67 %; sarampión, $R_0\approx15$, 93 %). El pico de infectados ocurre cuando $S=N/R_0$.
- Referencias: gripe ≈ 1.3; SARS-CoV-2 (cepa original) 2.5–3; sarampión 12–18; dengue 1–4.
- A mayor $R_0$: pico más temprano y alto, y más contagiados al final (con $R_0=3$, 94 %; con 1.5, 58 %). Nunca se contagia el 100 %: el brote se apaga cuando faltan susceptibles.
- Ejemplo: $\beta=0.3$ y 7 días dan $R_0=2.1$ y hay que vacunar ≈ 52 %; si la enfermedad dura 4 días, $R_0=1.2$ y basta ≈ 17 %.

## 5. Caso real: el vapeo como epidemia social (diapositivas 26–30)

Alfaro Brenes y Sevilla Moreira (2026), trabajo final de la Maestría en Métodos Matemáticos y Aplicaciones, UCR.

- **Modelo SVR de cinco compartimentos:** S susceptibles, P predispuestos (evidencia de pares, OR ≈ 5), V vapeadores activos, Qt abandono temporal y Qp abandono permanente. La recaída ($\rho Q_tV/N$) depende del contacto con vapeadores, igual que el contagio. Entra nacimiento ($q\mu N$ a S, $(1-q)\mu N$ a P) y sale mortalidad $\mu$.
- $R_0=\dfrac{\varphi\beta q+\varphi_p\beta_p(1-q)}{\mu+\gamma_t+\gamma_p}$ (método de la próxima generación). $\rho$ no aparece, porque en el equilibrio libre de vapeo no hay nadie en Qt.
- Antes se verifica que el sistema esté bien planteado (existencia y unicidad de Picard-Lindelöf, positividad, conservación de $N$).
- **Datos:** con parámetros de la literatura internacional (PATH, SAVM), $R_0=0.69$ y el vapeo se extinguiría. Pero la prevalencia juvenil pasó de 4 % a 13 % entre 2021 y 2025. La calibración inversa exige $R_0\approx2.3$ y un pico cercano al 19 % hacia 2029. Un modelo correcto según la literatura puede contradecir el dato local: la discrepancia es el resultado.
- **$R_0<1$ no siempre basta:** en el SIR la bifurcación es transcrítica (bajar $R_0$ bajo 1 elimina la endemia). Si $\rho\gamma_t>(\varphi\beta)^2q+(\varphi_p\beta_p)^2(1-q)$ hay **bifurcación hacia atrás**: coexisten el equilibrio libre de vapeo y uno endémico estable. Con $\rho=2.5$, $R_0=0.85$ y aun así hay equilibrios endémicos (0.2 % inestable y 4.9 % estable). Para política pública, hay que prevenir recaídas.

---

# Parte 2: De la pizarra al código (diapositiva 31)

## 6. Por qué las EDO importan hoy (diapositivas 32–33)
- **IA generativa:** Stable Diffusion 3, Sora y FLUX usan *flow matching* (Lipman et al., ICLR 2023): una red aprende el campo vectorial $dx/dt=v_\theta(x,t)$ de una EDO que transforma ruido en imagen.
- **Salud:** Latent ODE/Neural ODE para series clínicas con muestreo irregular. **Epidemiología:** SIR/SEIR/SEICR guiaron confinamientos. **Negocios:** el modelo de Bass (1969) es matemáticamente el logístico (adopción de Sinpe Móvil, Netflix).

## 7. scipy.integrate (diapositivas 34–36, 38–39)

- `solve_ivp` es la API moderna; `odeint` es legada y no se usa en código nuevo.
- Receta: función `campo(t, y)` que devuelve la derivada, `t_span`, `y0` y opcionalmente `t_eval`.

```python
sol = solve_ivp(campo, t_span=(0, 5), y0=[1.0], t_eval=np.linspace(0, 5, 100))
```

| Método | Cuándo usarlo |
|---|---|
| RK45 | Por defecto, problemas no rígidos |
| RK23 | Tolerancia baja |
| DOP853 | Alta precisión (rtol < 1e-8) |
| Radau | Rígidos con precisión |
| BDF | Rígidos grandes (estilo ode15s) |
| LSODA | No se sabe si es rígido |

Regla práctica: empezar con RK45; si hay muchos pasos rechazados, probar LSODA; si conmuta a BDF, el problema es rígido y se pasa a Radau.

- **Lotka-Volterra:** `args=params` pasa los parámetros a `campo`; `t_eval` define dónde se evalúa la solución (no es la malla interna, que es adaptativa); `rtol`/`atol` son las tolerancias (típico 1e-6 y 1e-9). El plano de fase muestra órbitas cerradas.
- **SIR en código:** `campo(t, y, beta, gamma)` devuelve `[dS, dI, dR]`; con $\beta=0.3$, $\gamma=1/7$ ($R_0=2.1$) se obtiene el pico con `argmax`. La estructura escala a 10 o 20 compartimentos.
- **Eventos (`events`):** registran el instante exacto en que una función cruza cero (p. ej. $dI/dt=0$ para el pico), con la precisión del solver y no de `t_eval`. Útil para alarmas o umbrales; `odeint` no lo tiene.

## 8. Calibración a datos reales (diapositivas 37, 42–43)
- **`curve_fit`:** ajusta $K$, $r$ y $N_0$ del logístico a los nueve censos del INEC (1864 a 2022, 5 044 197 habitantes en 2022). Estima $K$, cosa que a mano con dos censos no se podía.
- **`least_squares`** con `loss='soft_l1'` o `'huber'` sobre los residuos de simular el SIR: pérdidas robustas ante subreporte y outliers; separa un modelo de juguete de uno utilizable.
- **Calibración bayesiana (PyMC):** da una distribución (p. ej. "con 95 % de probabilidad $R_0$ está entre 1.9 y 2.4"); se verá en la semana 4.

## 9. Casos costarricenses (diapositivas 40–41)
- **SEICR** (de-Camino-Beck, Lead University, medRxiv 2020): SEIR con un compartimento C de confinados y flujo paralelo S ↔ C; las intervenciones no farmacéuticas reducen los susceptibles disponibles.
- **Dengue:** 30 649 casos en 2023 y 31 259 en 2024 (7 fallecidos). Buen tema de proyecto: estacionalidad ligada a *Aedes aegypti*, cuatro serotipos, datos semanales públicos y modelos SEIR vectoriales. Alternativa: OpenDengue.

## 10. Más allá de SciPy (diapositivas 44–46)
- Lo que cambió es propagar gradientes a través del solver: los parámetros de una EDO se aprenden por descenso de gradiente.
- **Diffrax** (JAX, GPU), **torchdiffeq** (referencia de Neural ODE), **DifferentialEquations.jl** (el más maduro, fuera del stack del curso), **NumPyro + Diffrax** (SIR bayesiano en GPU).
- Neural ODE ganan cuando la dinámica subyacente es continua (series clínicas irregulares, modelos cinéticos, finanzas de alta frecuencia); en muchos benchmarks siguen ganando transformers y RNN.
- **PINN:** sirven en problemas inversos y geometrías sin malla; aún no en problemas multiescala ni directos estándar (CFD y FEM ganan). Resultados mixtos; solo se mencionan.

## 11. Datasets para el proyecto integrador (diapositiva 47)

| Dataset | Fuente | Ideal para |
|---|---|---|
| Población de Costa Rica 1864-2025 | INEC, CCP-INEC | Malthus, Verhulst, `curve_fit` |
| Dengue semanal / regional | Ministerio de Salud / OpenDengue | SEIR vectorial, calibración bayesiana |
| Demanda eléctrica | ICE, CNFL | EDO con forzante estacional |
| Llegadas de turistas | ICT | Bass, logísticos generalizados |
| Usuarios de Sinpe Móvil | BCCR | Bass para adopción tecnológica |

Cada grupo elige un tema distinto; la elección formal es en la clase 3.

## 12. Validación y limitaciones (diapositivas 48–49)

**Validación en series temporales:**
- k-fold no sirve: barajar rompe la dependencia temporal y el modelo "ve el futuro".
- Alternativas: hold-out hacia adelante, backtesting epidemiológico (ajustar hasta la semana $k$, predecir $k+1$ a $k+4$, repetir) y la métrica WIS (weighted interval score).
- **Sensibilidad con SALib:** Morris (screening) y Sobol (varianza global) muestran qué parámetros pesan más.

**Limitaciones de los modelos compartimentales:** (1) mezcla homogénea; (2) población cerrada; (3) parámetros constantes; (4) determinismo, que falla en poblaciones pequeñas; (5) identificabilidad (distintos $(\beta,\gamma)$ dan curvas similares; $\varphi$ y $\beta$ solo se identifican por su producto); (6) sin estructura de edad. Un modelador profesional enumera primero las limitaciones y luego propone mejoras.

## Síntesis (diapositiva 51)

| A mano | En la computadora | Vuelve en |
|---|---|---|
| EDO = regla de cambio | Función `campo(t, y)` de `solve_ivp` | Resto del curso |
| Malthus / Verhulst | `curve_fit` sobre censos | Semana 6, series temporales |
| Equilibrios y diagrama de fase | Eventos en `solve_ivp` | Semanas 9 y 10, optimización |
| SIR y umbral $R_0$ | Simulación y calibración | Semana 4, MCMC con PyMC |
| Modelo del vapeo | Mismo código; SALib | Proyecto integrador |

---

## Fuera del PDF — tareas y actividades (diapositivas 50 y 52)

- **Tarea moral (cuatro bloques):** (1) clasificar EDO y traducir frases a ecuaciones; (2) Malthus/Verhulst, incluyendo estimar $r$ con los censos de 1950 y 2022 y la bacteria en el frasco; (3) equilibrios, con cosecha constante en una pesquería y la deuda de un préstamo; (4) SEIR, SIS y dengue con humanos y mosquitos.
- **Actividad en salas (no se califica):** Ley de Newton a mano; Verhulst con `solve_ivp`; SIR con $R_0=0.8$, $1.5$ y $3$; `curve_fit` a los censos para estimar $K$.
- **Para la clase 3 (24 de setiembre, cadenas de Markov):** terminar las miniexploraciones de Colab, leer el capítulo 1 de Giordano, Fox y Horton, hojear el SEICR de de-Camino-Beck y decidir en grupo el tema preliminar del proyecto.

## Conceptos clave (diapositiva 53)
1. **Una EDO se lee antes de resolverse:** regla de cambio, parámetros con significado, equilibrios y estabilidad.
2. **Todos los modelos son incorrectos:** Malthus falló por un millón de personas y la literatura internacional falló con el vapeo en Costa Rica; esas discrepancias son resultados.
3. **$R_0$ es un umbral, y a veces no basta:** con recaída fuerte hay equilibrio endémico aun con $R_0<1$.
4. **Dos herramientas:** la lectura conceptual a mano y la computacional (`solve_ivp`, `curve_fit`, `least_squares`) que resuelve lo que la pizarra no puede.
