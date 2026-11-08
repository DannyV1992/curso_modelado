# Semana 9: Optimización clásica (primera parte): encontrar el fondo del valle

**Curso:** BCD5105 Modelado matemático, Lead University (III cuatrimestre 2026, virtual)

**Docente:** Jordy Alfaro Brenes

**Fecha:** jueves 5 de noviembre de 2026

**PDF fuente:** `Clases/PDFs/9 - Optimizacion clasica 2.pdf`

**Cobertura del PDF:** completo (diapositivas 1 a 25). La transcripción cubre toda la sesión sin cortes. Las diapositivas 10 a 12 (ejemplos y ejercicios a mano) y la 20 (precio sombra con cvxpy) no se trabajaron en clase y salen solo del PDF.

**Contexto:** cierra la primera parte del curso (modelos: EDO, Markov, Monte Carlo, regresión, series) y abre la segunda: **optimización** y **grafos**. Hoy se ve optimización **sin restricciones** y se introduce la primera "cerca" (programación lineal). La semana siguiente se agregan restricciones, después los métodos modernos y por último grafos.

**Objetivos:** plantear un problema como "minimizar una función objetivo", usar condiciones de primer y segundo orden para encontrar y clasificar candidatos, explicar por qué la convexidad garantiza un único mínimo, describir el descenso de gradiente y el papel del tamaño de paso, y resolver problemas con `scipy.optimize`, `linprog` y `cvxpy`.

| Bloque | Tema | Diapositivas |
|---|---|---|
| 1 | Optimizar y condiciones de optimalidad | 4 a 6 |
| 2 | Convexidad y descenso de gradiente | 7 y 8 |
| 3 | La cerca: programación lineal | 9 |
| — | Ejemplos y ejercicios a mano | 10 a 12 |
| 4 | Python: `minimize` y calibración | 13 a 18 |
| 5 | Python: despacho eléctrico con `linprog` y `cvxpy` | 19 a 21 |
| 6 | Proyecto, cierre y práctica en salas | 22 a 25 |

---

## 1. Optimizar es buscar el punto más bajo (diapositiva 4)

Todo problema de optimización tiene tres piezas:

| Pieza | Significado | Ejemplo |
|---|---|---|
| **Variables** | Lo que se puede decidir ($x$) | Cuánto invertir en cada medio |
| **Objetivo** | Lo que se quiere hacer pequeño ($f(x)$) | El error del modelo, el costo |
| **Restricciones** | Lo que no se puede violar: **la cerca** | Al menos 50 % del presupuesto en redes sociales |

- "Optimizar" es maximizar o minimizar según el contexto (maximizar ingresos, minimizar costos). **Regla del curso: siempre se minimiza.**

$$\max f \;=\; \min(-f)$$

- El signo menos **refleja** la función (como un espejo, no es la inversa): un domo pasa a ser un tazón. Se hace porque casi todos los métodos vienen programados para minimizar.
- **En los modelos**, el objetivo es la **función de pérdida** (el error del modelo): entrenar es minimizarla.
- **Sin cerca:** se optimiza como se quiera. **Con cerca:** hay que cumplir la restricción aunque exista un punto mejor fuera de ella (un reparto de presupuesto más rentable que no cumple la exigencia del jefe no sirve).

### Ya se ha optimizado sin decirlo

- **Regresión (semana 5):** ajustar la mejor recta es minimizar el error cuadrático medio (MSE).
- **Series (semanas 6 y 7):** Prophet y SARIMA estiman parámetros minimizando un error o maximizando una verosimilitud.
- **EDO (semana 2):** encontrar los parámetros que dan el menor error posible.
- **Redes neuronales:** entrenar es tomar la función de pérdida y minimizarla.

---

## 2. Condiciones de optimalidad (diapositivas 5 y 6)

Hay tres tipos de punto donde el terreno es plano:

| Forma | Tipo de punto |
|---|---|
| Tazón | **Mínimo** |
| Domo | **Máximo** |
| Silla de montar | **Punto silla**: ni mínimo ni máximo |

| Orden | Condición | Qué da |
|---|---|---|
| **Primer orden** | $f'(x)=0$ (en varias variables, **gradiente** $=0$) | **Candidatos** |
| **Segundo orden** | $f''>0$: mínimo. $f''<0$: máximo | **Clasifica** los candidatos |

- En varias variables, si las curvaturas tienen signos distintos, es silla.
- Con la primera derivada se encuentran los candidatos; con la segunda se clasifican.

### Micro ejemplo: $f(x)=x^3-3x$

1. Derivar: $f'(x)=3x^2-3$ y $f''(x)=6x$.
2. Candidatos: $3x^2-3=0 \Rightarrow x^2=1 \Rightarrow x=\pm 1$ (hay que poner el $\pm$ al sacar raíz).
3. Evaluar en $f$ (no en la derivada) y en $f''$:

| Candidato | $f(x)$ | $f''(x)$ | Tipo |
|---|---|---|---|
| $x=1$ | $-2$ | $6>0$ | Mínimo |
| $x=-1$ | $2$ | $-6<0$ | Máximo |

- El mínimo es el punto $(1,\,-2)$. Evaluar en $f$ solo da la altura; **el que clasifica es $f''$**.

> **Nota:** en clase se llamó a $(1,-2)$ "mínimo global", pero $x^3-3x\to-\infty$ cuando $x\to-\infty$, así que es solo un **mínimo local**. La propia diapositiva pregunta "piensen qué pasa cuando $x\to-\infty$". Este caso muestra por qué importa distinguir local de global (sección 3).

**Analogía con el entrenamiento:** el error empieza alto en la primera iteración y baja iteración tras iteración hasta tocar fondo. Si se itera de más, el error puede volver a subir (por ejemplo, por un paso mal elegido): hay que saber cuándo parar.

---

## 3. Convexidad: un solo valle (diapositiva 7)

| | Función convexa | Función no convexa |
|---|---|---|
| Valles | Uno solo | Varios |
| Mínimo local | **Es** el mínimo global | Puede no serlo |
| Riesgo | Ninguno: si se encuentra un fondo, es el fondo | Quedar atrapado en un valle equivocado |

- La convexidad da **confianza**: la computadora reporta un mínimo y, si el problema es convexo, no hay otro más bajo.
- En la vida real casi nunca es convexo. Entrenar una red neuronal es bajar "a ciegas" en una superficie con muchos valles.
- Gráficamente, en una función convexa la cuerda entre dos puntos queda por encima de la curva.
- En problemas no convexos el resultado depende del **punto de partida**, y de la elección del tamaño de paso (ver sección 4).

---

## 4. Descenso de gradiente: bajar a pasos (diapositiva 8)

Cuando no se puede despejar, se camina cuesta abajo, como bajar una montaña con los ojos cerrados:

$$x_{k+1}=x_k-\eta\,\nabla f(x_k)$$

$\eta$ es el **tamaño del paso** (tasa de aprendizaje) y $\nabla f$ el gradiente (la dirección de máxima subida; se resta para bajar).

Sobre la misma función (curvas de nivel = tazón visto desde arriba, con la estrella en el fondo):

| Tamaño de paso | Comportamiento |
|---|---|
| Muy pequeño ($\eta=0{,}02$) | Lento pero seguro: muchas iteraciones |
| Intermedio ($\eta=0{,}06$) | Llega bien y rápido |
| Muy grande ($\eta=0{,}13$) | Zigzaguea y **diverge**: nunca llega |

- El tamaño de paso es **la decisión más delicada**. Un paso diminuto parece "más seguro", pero con millones de parámetros (una red grande) miles de iteraciones son carísimas computacionalmente.
- En problemas no convexos, un paso pequeño puede dejar atrapado en el primer valle; uno mayor puede saltar hacia el valle global.
- Es el motor de **Adam** y **AdamW** (semana 11) y del entrenamiento de redes.

---

## 5. La cerca: programación lineal (diapositiva 9)

Con restricciones, **el óptimo vive en la frontera**.

- **Programación lineal:** objetivo lineal y restricciones lineales (rectas). La **región factible** es un polígono (un poliedro en más dimensiones).
- **El óptimo siempre está en un vértice.** Se imaginan las rectas de nivel del objetivo desplazándose en la dirección de mejora hasta tocar el último punto de la región factible.
- Salirse del polígono equivale a encontrar un reparto "mejor" que no se puede pagar (por ejemplo, invertir más de lo que hay de presupuesto).
- **Simplex** recorre vértices vecinos mejorando en cada paso; hoy `linprog` usa **HiGHS** por dentro.

---

## 6. Ejemplos y ejercicios a mano (diapositivas 10 a 12)

> En clase se dejó de lado la parte a mano. La segunda prueba será muy aplicada y probablemente no tendrá parte a mano.

**Ejemplos (para resolver con calma):**

1. $f(x,y)=x^2+2y^2-4x+4y$: punto de gradiente cero y clasificación con curvaturas; luego el punto $(0,0)$ de $g(x,y)=x^2-y^2$ (es una silla). Resultado del primero: mínimo en $(2,-1)$ con valor $-6$.
2. Descenso de gradiente en $f(x)=x^2$ desde $x_0=4$ con $\eta=0{,}1$, $0{,}5$ y $1{,}1$: ver qué pasa y desde qué $\eta$ diverge.
3. Maximizar $3x+5y$ sujeto a $x+y\le4$, $x+3y\le6$, $x,y\ge0$: dibujar la región factible y evaluar los vértices.

**Ejercicios (tarea moral, durante la semana):**

1. $f(x)=x^4-2x^2$: candidatos, clasificación y mínimo global.
2. $f(x)=(x-3)^2$, $x_0=0$, $\eta=0{,}25$: tres pasos y valores de $\eta$ que divergen.
3. Minimizar $2x+3y$ sujeto a $x+y\ge4$, $x\ge1$, $y\ge1$, de forma gráfica.

---

## 7. Optimización en Python: el stack (diapositivas 13 y 14)

La matemática pesada la hace la máquina; el trabajo es **plantear bien el problema y leer bien la respuesta**.

| Herramienta | Para qué | En el curso |
|---|---|---|
| `scipy.optimize` | `minimize` (BFGS, Nelder-Mead…) y `linprog` (HiGHS) | Hoy |
| `cvxpy` | Problemas convexos escritos como la matemática | Hoy y semana 10 |
| PyTorch y JAX | Autodiff y descenso de gradiente a gran escala | Semana 11 |
| `scipy` (`differential_evolution`) | Heurísticos sin gradiente | Semana 12 |
| Gurobi, OR-Tools | Programación lineal y entera industrial | Referencia |

`scipy` ya viene en Colab; `cvxpy` se instala con `!pip install -q cvxpy`.

---

## 8. `minimize`: el fondo en dos variables (diapositiva 15)

Se resuelve en una línea el Ejemplo 1 ($f(x,y)=x^2+2y^2-4x+4y$, una superficie en 3D con un único fondo):

```python
from scipy.optimize import minimize

def f(v):
    x, y = v
    return x**2 + 2*y**2 - 4*x + 4*y

res = minimize(f, x0=[0, 0], method="BFGS")
```

| Atributo | Contenido |
|---|---|
| `res.x` | Punto óptimo: $(2,-1)$, igual que a mano |
| `res.fun` | Valor mínimo: $-6$ (la altura del punto) |
| `res.nfev` | Cuántas veces evaluó $f$ (18) |

- El gradiente no se da: se aproxima con diferencias finitas.
- La función es convexa (las dos curvaturas son positivas), así que el punto hallado es el **mínimo global** y el `x0` solo cambia la cantidad de iteraciones.
- **Punto de inicio:** empezar cerca del mínimo ahorra iteraciones. Con una función **no convexa**, el resultado depende de `x0`: conviene **probar varios puntos de partida**.

---

## 9. Distintas formas de bajar (diapositiva 16)

Función de Rosenbrock (valle en forma de banana), mismo óptimo $(1,1)$:

| Método | Usa | Evaluaciones |
|---|---|---|
| Nelder-Mead | Solo valores de $f$ | 159 |
| CG | Gradiente | 78 |
| BFGS | Gradiente + curvatura | 39 |
| L-BFGS-B | Gradiente + curvatura | 44 |

- Los cuatro llegan al mismo punto; **cambia el esfuerzo**. Usar el gradiente reduce el trabajo a la cuarta parte.
- **Regla práctica:** si hay gradiente, BFGS o L-BFGS-B. Si la función es ruidosa o no derivable, Nelder-Mead (y los heurísticos de la semana 12).
- Estos métodos son muy computacionales y no se estudian por dentro.

---

## 10. Calibrar es optimizar (diapositivas 17 y 18)

**Pregunta:** ¿a qué ritmo crece la demanda eléctrica de Costa Rica? Datos reales de Ember (mensuales, 2019 a junio de 2026).

- Modelo de la semana 2: $D(t)=D_0e^{rt}$, con parámetros $D_0$ y $r$.
- **Función de pérdida:** el MSE entre la demanda real y la del modelo, en función de $(D_0,r)$.

```python
def perdida(p):
    D0, r = p
    return np.mean((y - D0 * np.exp(r * t)) ** 2)   # MSE

res = minimize(perdida, x0=[0.9, 0.0], method="BFGS")
```

- Resultado en solo **6 iteraciones**: $D_0\approx0{,}8975$ TWh/mes y $r\approx0{,}0276$, es decir, **crecimiento de 2,76 % anual** (la diapositiva lo redondea a 2,8 %).
- Coincide con el repaso de la semana 8 (2,7 % con datos anuales).
- "Óptimo" significa que esos parámetros hacen el MSE lo más pequeño posible: ninguna otra curva exponencial se ajusta mejor.
- El método decide cuándo parar con su propia **tolerancia**; no se le dice el número de iteraciones.

### La superficie de costo y el camino al fondo

El mapa de curvas de nivel tiene en cada punto un par $(D_0,r)$ y la altura es el error.

| Método | Iteraciones | Camino |
|---|---|---|
| BFGS | 6 | Usa la pendiente: va casi directo al mínimo |
| Nelder-Mead | 37 | Solo compara valores: da un rodeo largo |

- Ambos llegan al mismo fondo; de ahí la importancia de elegir el método.
- **El valle es alargado:** $D_0$ y $r$ se compensan (un nivel inicial más alto con menos crecimiento ajusta casi igual), y se ve como curvas de nivel ovaladas estiradas en diagonal. Entre más ovaladas, **más probabilidad de zigzag**. Las curvas perfectamente redondas son el caso de libro de texto, no el de la vida real.

---

## 11. La cerca en Python: despacho eléctrico (diapositivas 19 y 20)

**Problema:** cubrir **1160 GWh** de marzo de 2026 al menor costo.

| Fuente | Costo (miles USD/GWh) | Capacidad (GWh) |
|---|---|---|
| Hidro | 15 | 660 |
| Geotermia | 40 | 130 |
| Eólica | 60 | 200 |
| Biomasa | 90 | 10 |
| Importación | 120 | 60 |
| Térmica | 220 | 500 |

Es programación lineal:

$$\min\; c^\top x \quad\text{s.a.}\quad \sum_i x_i=1160,\quad 0\le x_i\le \text{cap}_i$$

```python
from scipy.optimize import linprog

res = linprog(c=costo, A_eq=[[1]*6], b_eq=[1160],
              bounds=[(0, k) for k in cap], method="highs")
```

- **Solución:** hidro, geotermia, eólica, biomasa e importación **al tope**, y térmica en **100 de 500 GWh**. Costo mínimo: **57 200** (miles de USD, unos 57,2 millones).
- El método lo decide solo y tiene sentido: llena de la más barata a la más cara y usa lo menos posible la más cara. Sin la restricción de 1160 GWh el costo mínimo sería trivial (no generar).
- Coincide con el despacho real de marzo (unos 100 GWh térmicos). Los costos son **ilustrativos**, no reales.

### Lo mismo en `cvxpy`

Misma solución, otra sintaxis (declarativa, "como la matemática"):

```python
import cvxpy as cp
x = cp.Variable(6)
restr = [cp.sum(x) == 1160, x >= 0, x <= np.array(cap)]
prob = cp.Problem(cp.Minimize(np.array(costo) @ x), restr)
prob.solve()
```

### Sensibilidad: el precio sombra (diapositiva 20)

| Agua disponible | Térmica | Costo (miles USD) |
|---|---|---|
| 660 GWh | 100 GWh | 57 200 |
| 560 GWh | 200 GWh | 77 700 |

- Guardar 100 GWh de agua en el embalse cuesta 20,5 millones de USD: cada GWh de agua vale **205** miles de USD ($220-15$).
- Ese 205 es el **precio sombra**: cuánto cambia el costo óptimo si se afloja una cerca en una unidad. `cvxpy` (`restriccion.dual_value`) y `linprog` (`res.eqlin.marginals`, `res.upper…`) lo calculan solos. La semana 10 explica de dónde sale (multiplicadores de Lagrange y condiciones KKT).

---

## 12. ¿`scipy` o `cvxpy`? (diapositiva 21)

| Criterio | `scipy.optimize` | `cvxpy` |
|---|---|---|
| Cómo se escribe | Función de Python y lista de restricciones | Declarativo, "como la matemática" |
| Tipo de problema | General, también no convexo | **Solo convexo** (garantiza el óptimo global) |
| Programación lineal | `linprog` (HiGHS) | Lo detecta solo |
| Precios sombra | `res.eqlin.marginals`, `res.upper`… | `restriccion.dual_value` |
| Ideal para | Calibrar modelos no lineales, funciones a la medida | Carteras, despacho, asignación |

> **Regla simple:** si el problema es convexo y se puede escribir en `cvxpy`, usarlo. Si no es convexo (como la calibración de un SEIR), `scipy.optimize` con varios puntos de partida.

**Si dos librerías dan el mismo resultado:** primero se prioriza que el modelo sea el mejor posible; en igualdad de condiciones se elige el método que converge en menos iteraciones, sobre todo con datos grandes o modelos pesados.

---

## 13. Para el proyecto integrador (diapositiva 22)

La optimización está debajo de casi todo:

| Uso | Descripción |
|---|---|
| **Calibrar** | Si el modelo tiene parámetros (un SEIR, una curva de crecimiento), estimarlos es minimizar un error con `minimize`. Aplica a todos los carriles |
| **Asignar** | Inventario, rutas, despacho: objetivo de costo con capacidades. Programación lineal con `linprog` o `cvxpy` |
| **Invertir** | Una cartera es un problema convexo con presupuesto y riesgo: se resuelve en la semana 10 |

> Si el grupo ya tiene un modelo, hay que preguntarse **qué se está minimizando por debajo** y escribirlo explícitamente en el documento final como parte de la formulación matemática.

---

## Conceptos clave

1. **Optimizar es minimizar:** maximizar $f$ equivale a minimizar $-f$. Un problema tiene variables, objetivo y restricciones (la cerca).
2. **Primer orden da candidatos, segundo orden los clasifica:** gradiente cero marca mínimo, máximo o silla; la segunda derivada ($f''>0$ mínimo, $f''<0$ máximo) decide cuál es.
3. **La convexidad da confianza:** un solo valle significa que cualquier mínimo hallado es el global. En problemas no convexos hay que probar varios puntos de partida.
4. **Descenso de gradiente:** $x_{k+1}=x_k-\eta\nabla f(x_k)$. El tamaño de paso es la decisión más delicada: pequeño es lento y grande diverge. Es la base de Adam/AdamW.
5. **BFGS vs. Nelder-Mead:** el gradiente reduce mucho el número de evaluaciones. Con gradiente, BFGS o L-BFGS-B.
6. **Calibrar es optimizar:** estimar parámetros es minimizar una función de pérdida (MSE); la regresión, las series y las EDO ya lo hacían.
7. **Con cerca, el óptimo vive en la frontera:** en programación lineal está en un vértice del polígono factible.
8. **El precio sombra** mide cuánto cuesta (o ahorra) aflojar una restricción; se explica en la semana 10.
9. **`scipy` vs. `cvxpy`:** convexo y escribible en `cvxpy`, usarlo; si no, `scipy.optimize` con varios inicios.

---

## Fuera del PDF — logística, tareas y metodología

### Prueba parcial 1 y avance del proyecto

- La prueba parcial 1 se entregó esta semana. Se revisa lo antes posible, junto con el avance del proyecto.
- Aprendizaje práctico: las fuentes de datos externas pueden **cambiar de URL y de formato** (nombres de columnas) sin aviso. Conviene revisar y guardar una copia local antes de entregar.

### Segunda prueba

- Será **muy aplicada y práctica**; es muy probable que no incluya parte a mano.
- Cubre la segunda parte del curso (optimización y grafos). La prueba del cuatrimestre anterior estaba muy enfocada en grafos (viajes entre aeropuertos de Centroamérica), tema que todavía no se ve.

### Actividad complementaria de la semana 9

- Se trabaja en salas por grupo (está en el aula virtual, con los apuntes de la clase). Las partes:
  1. **A mano** (se puede omitir): candidatos, curvaturas y dos pasos de descenso de gradiente.
  2. **`minimize`:** descenso de gradiente propio contra BFGS en una superficie de costo.
  3. **`linprog`:** despacho de un mes lluvioso y comparación con marzo.
  4. **Decisión:** reflexión sobre qué cerca aprieta y cuánto vale aflojarla.
- Énfasis en las partes 2, 3 y 4. Lo que importa es la **interpretación** y relacionar los resultados con lo visto, no escribir el código.

### Próximas clases

| Clase | Fecha | Tema |
|---|---|---|
| Semana 10 | 12 de noviembre | Optimización con restricciones: multiplicadores de Lagrange, condiciones KKT (cada cerca aprieta o sobra), análisis de sensibilidad (el precio sombra de hoy, explicado) y cartera de Markowitz con `cvxpy` |
| Semana 11 | — | Optimización moderna: Adam y AdamW, PyTorch y JAX |
| Semana 12 | — | Heurísticos sin gradiente (`differential_evolution`) |
| Semana 13 | — | Presentación complementaria del proyecto (conviene ir avanzando antes) |

**Pendientes para la próxima semana:** resolver la tarea moral de la parte de ideas, terminar las partes de la práctica que quedaron abiertas, pensar qué minimiza el modelo del proyecto, y guardar el 205 del despacho.
