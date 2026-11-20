# Semana 10: Optimización con restricciones: Lagrange, KKT y el precio de cada cerca

**Curso:** BCD5105 Modelado matemático, Lead University (III cuatrimestre 2026, virtual)

**Docente:** Jordy Alfaro Brenes

**Fecha:** jueves 12 de noviembre de 2026

**PDF fuente:** `Clases/PDFs/10 - Optimizacion con restricciones 2.pdf`

**Cobertura del PDF:** completo (diapositivas 1 a 21). La transcripción cubre la parte teórica y aplicada sin cortes; la práctica en salas no quedó grabada, así que se resume desde su enunciado (`Practica clase 10 - Modelado matematico.pdf`) en la sección final.

**Contexto:** segunda de tres semanas de optimización. La semana 9 vio optimización sin restricciones y la primera "cerca" (programación lineal); hoy se formaliza qué es una restricción, cuándo molesta y cuánto vale aflojarla. La semana 11 cierra con optimización moderna (gradiente, Adam). Desde esta semana el curso es **conceptual y aplicado**: nada a mano, porque los ejemplos manuales son largos, la matemática de fondo (derivadas parciales, ecuaciones diferenciales) pesa y los cálculos los hace la computadora.

**Objetivos:** explicar con un ejemplo cotidiano qué es optimizar con una regla, reconocer cuándo la regla estorba y cuándo no, interpretar el precio sombra, obtenerlo con `cvxpy` (y leerlo en el despacho eléctrico) e interpretar una cartera de inversión óptima.

| Bloque | Tema | Diapositivas |
|---|---|---|
| 1 | La idea, con ejemplos cotidianos | 4 |
| 2 | ¿La regla estorba o no? | 5 |
| 3 | ¿Cuánto vale aflojar una regla? Lagrange y nombres técnicos | 6 a 9 |
| 4 | Python: la computadora lo calcula (`cvxpy`) | 10 a 13 |
| 5 | Despacho real y cartera de Markowitz | 14 a 17 |
| — | Proyecto integrador, próxima semana y cierre | 18 a 20 |
| 6 | Práctica en salas (después del receso) | 21 |

---

## 1. La idea en una frase (diapositiva 4)

> Optimizar con restricciones es hacer lo mejor posible sin romper las reglas.

Tres preguntas guían todo el tema: ¿qué quiero lograr?, ¿qué regla me limita? y ¿cuánto ganaría si me aflojaran esa regla?

| Situación | Lo que quiero | La regla |
|---|---|---|
| Hacer el súper | La mayor cantidad de comida | No pasarse de 50 000 |
| Despacho eléctrico (semana 9) | El menor costo del mes | Cubrir toda la demanda y no pasar la capacidad de cada planta |
| Invertir los ahorros | El menor riesgo | Ganar al menos 0,8 % por mes |

- A la regla se le llama **cerca** (tapia, malla, barrera): marca hasta dónde se puede llegar.
- "Lo mejor" depende del contexto: minimizar (riesgo, costo) o maximizar (ingresos).
- Ejemplo de la semana 9: un reparto de presupuesto de marketing con 10 % en televisión y 85 % en redes puede ser el mejor, pero no sirve si la regla exige 50 % en televisión. Se cumple la regla aunque exista un punto mejor fuera de ella.

---

## 2. Primera pregunta: ¿la regla estorba? (diapositiva 5)

Ejemplo del sueño: se quiere dormir cierta cantidad de horas, pero hay un límite.

| | Caso 1: no estorba | Caso 2: estorba |
|---|---|---|
| Ideal | 7 h | 9 h |
| Límite | 8 h | 7 h |
| Qué pasa | Lo ideal cabe: la regla está, pero no cambia nada | Lo ideal está prohibido: lo mejor posible es quedarse **pegado al borde** (7 h) |

- Siempre ocurre una de las dos cosas: la regla estorba (el óptimo queda en el borde) o no estorba (da igual que exista).
- Son situaciones sencillas, pero matemáticamente funcionan igual que en problemas grandes.

---

## 3. Segunda pregunta: ¿cuánto vale aflojar la regla? (diapositivas 6 a 8)

### Precio sombra (diapositiva 6)

El **precio sombra** es lo que se gana si se da una unidad más de aquello que limita.

- **Si la regla estorba:** aflojarla mejora el resultado; el "cuánto mejora por unidad" es el precio sombra.
- **Si no estorba:** aflojarla no cambia nada, así que su precio sombra es **cero** (como recibir 9 horas de sueño permitidas cuando solo se querían 7).

Ejemplo con el despacho de marzo de 2026 (datos de Ember, costos supuestos de la semana 9):

| Agua disponible | Costo del mes |
|---|---|
| 660 GWh | 57,20 millones USD |
| 670 GWh | 55,15 millones USD |

- 10 GWh más de agua bajan el costo en 2,05 millones: cada GWh de agua extra vale **205 000 USD**.
- Respuesta a la duda de la semana 9: un GWh de agua desplaza un GWh de térmica (220) y cuesta 15, por eso vale $220-15=205$.

### La calle y la casa (diapositiva 7)

Con dos variables: la regla es una **calle** y lo que se quiere es estar lo más cerca posible de la **casa**.

- Las **curvas de nivel** son círculos alrededor de la casa: todos los puntos de un círculo están a la misma distancia.
- Hay puntos igual de buenos que el óptimo (mismo círculo) pero fuera de la calle; no sirven porque incumplen la regla. En el ejemplo de marketing, producirían las mismas ventas, pero no respetan lo que pidió el jefe.
- **El mejor punto es donde un círculo apenas toca la calle.**
- Si la calle se aleja, hay que caminar más y el resultado empeora; cuánto empeora por unidad movida es, otra vez, el precio sombra.
- Esto es el **método de Lagrange** (multiplicadores de Lagrange). No se calcula a mano: lo hace la computadora.

### Nombres técnicos (diapositiva 8)

No hay que memorizarlos; aparecen en libros y en la salida del código.

| Si se lee... | Quiere decir... |
|---|---|
| Restricción | La regla o la cerca |
| Restricción **activa** | La regla estorba: el óptimo quedó pegado al borde |
| Restricción **inactiva** | La regla no estorba: da igual que exista |
| Multiplicador de Lagrange, precio sombra, `dual_value` | Cuánto mejora el resultado si se afloja la regla una unidad |
| Condiciones **KKT** | Lo que cumple todo óptimo: cada restricción o estorba (y tiene precio) o no estorba (y su precio es cero) |
| Análisis de **sensibilidad** | Mover las reglas un poco y ver cuánto cambia el resultado |

- Forma compacta de la idea KKT para cada restricción $i$ (con precio $\lambda_i$ y holgura $g_i$): $\lambda_i \cdot g_i = 0$. Si hay holgura (no estorba), el precio es cero; si el precio es positivo, no hay holgura (estorba).
- **Análisis de sensibilidad:** barrer un parámetro y ver cómo cambia lo óptimo. Es muy usado en modelado y en políticas públicas. Ejemplo (modelo de vapeo): ¿qué pasa si los programas de prevención rinden más o menos?, ¿si la influencia entre pares pesa más? Si el resultado casi no se mueve, no conviene invertir en eso; si se mueve mucho, sí.
- Lo importante es la **idea**; el nombre es solo la etiqueta.

---

## 4. Prediga antes de correr (diapositiva 9)

| Pregunta | Respuesta |
|---|---|
| Se quiere gastar 8 000 en el almuerzo y el presupuesto es 10 000. ¿La regla estorba? Si sube a 12 000, ¿cuánto mejora? | No estorba; no mejora nada (precio sombra cero) |
| Punto de la calle más cercano a casa: si la calle se aleja un poco, la distancia... | **Sube**: la regla estorba, el punto ideal ya no está sobre la calle |
| Despacho de marzo: ¿qué ahorra más, 10 GWh más de agua o 10 GWh menos de demanda? | **Menos demanda**: $10\times220=2\,200$ (miles de USD) contra $10\times205=2\,050$ |

---

## 5. Python: la computadora lo calcula (diapositivas 10 a 13)

Se describe el problema (objetivo y regla) y `cvxpy` devuelve el óptimo y el precio sombra. No se escribe ninguna derivada. El solver usado es **CLARABEL**.

### La calle y la casa en código (diapositiva 11)

```python
import cvxpy as cp
x = cp.Variable(); y = cp.Variable()
restr = [x + y == 1]                       # la calle
prob = cp.Problem(cp.Minimize(x**2 + y**2), restr)   # distancia a la casa (0,0)
prob.solve(solver=cp.CLARABEL)
# x = 0.5, y = 0.5, f* = 0.5, restr[0].dual_value = -1.0
```

- $(0{,}5;\,0{,}5)$ es el punto de la calle $x+y=1$ más cercano a la casa $(0,0)$.
- `dual_value` es el precio sombra: si la calle se aleja un poco, el objetivo sube a ese ritmo.
- **Ojo con el signo:** sale $-1$, pero el signo depende de cómo se escribe la regla. Lo que importa es el **tamaño** (1) y la pregunta "¿mejora o empeora el objetivo si se afloja la regla?".

> **Nota:** el objetivo $x^2+y^2$ es el **cuadrado** de la distancia, no la distancia misma; por eso $f^*=0{,}5$ y no $\sqrt{0{,}5}$.

### ¿La regla estorba? Lo responde la computadora (diapositiva 12)

Misma meta, dos reglas distintas ($x+y\ge b$), con una función `resolver(b)` que devuelve $x$, $y$ y el precio:

| $b$ | Punto | $\lambda$ | Estado | Lectura |
|---|---|---|---|---|
| $+1$ | $(0{,}5;\,0{,}5)$ | 1,00 | **APRIETA** | Lo ideal $(0,0)$ está prohibido: se queda en el borde y aflojar vale 1 |
| $-1$ | $(0;\,0)$ | 0,00 | **SOBRA** | Lo ideal ya está permitido: aflojar vale 0 (como el almuerzo) |

Nunca ocurren las dos cosas a la vez: o estorba y tiene precio, o no estorba y su precio es cero.

### Si la calle se aleja, ¿cuánto empeora? (diapositiva 13)

Se mueve la calle ($x+y=c$) y se compara el cambio del resultado con el precio sombra:

| Calle en $c$ | Mejor resultado | Precio sombra |
|---|---|---|
| 1,0 | 0,500 | 1,00 |
| 1,5 | 1,125 | 1,50 |
| 2,0 | 2,000 | 2,00 |
| 2,01 | 2,020 | 2,01 |

- De 2,0 a 2,01 el resultado sube $0{,}020 = 2\times0{,}01$: **el precio sombra predijo el cambio**.
- El precio sombra **crece** al alejarse la calle: cuanto más lejos, más caro cada paso extra. Analogía: pagar un Uber hasta una calle cercana es distinto a pagarlo hasta una lejana; el precio sombra dice cuánto más caro sale mover la línea una unidad.

---

## 6. Sensibilidad con datos reales: el despacho (diapositiva 14)

Misma serie de marzo de 2026 con `linprog`: cada punto de la curva es un problema resuelto, y las pendientes coinciden con `res.upper.marginals`. El precio sombra del agua es una **función por tramos**, porque según cuánta agua se agregue, reemplaza una fuente u otra:

| Agua disponible | Ahorro por GWh | Qué reemplaza |
|---|---|---|
| Hasta 760 GWh | 205 | Térmica (la más cara) |
| De 760 a 820 GWh | 105 | Importación |
| Más de 820 GWh | 45 | Eólica |

- Se reemplaza primero la energía más cara para obtener el mayor beneficio posible.
- Bajar 10 GWh de demanda ahorra 2 200 (precio 220); 10 GWh más de agua ahorran 2 050. Conviene bajar la demanda.

---

## 7. Invertir los ahorros: la cartera de Markowitz (diapositivas 15 a 17)

**Lo que se quiere:** el menor riesgo. **La regla:** ganar al menos cierto retorno $R$ (lo define quien invierte).

$$\min_{w}\; w^\top \Sigma\, w \quad \text{s. a.} \quad \sum_i w_i = 1,\;\; w_i \ge 0,\;\; \mu^\top w \ge R$$

$w$ son los pesos por fondo, $\Sigma$ la matriz de covarianzas ($=\text{diag(vol)}\cdot\text{corr}\cdot\text{diag(vol)}$), $\mu$ los retornos esperados. El objetivo es la **varianza**; la volatilidad es su raíz cuadrada.

Las tres reglas:

1. **Pesos suman 1:** se invierte todo el dinero.
2. **Retorno esperado de al menos $R$.**
3. **Ningún peso negativo:** no se apuesta en contra de un fondo; lo mínimo es no meterle nada (cero).

Datos del ejemplo (supuestos, estilo SUGEVAL; con datos reales se estiman de precios históricos):

| Fondo | Retorno mensual | Volatilidad |
|---|---|---|
| Liquidez | 0,3 % | 0,4 % |
| Bonos CRC | 0,6 % | 1,2 % |
| Bonos USD | 0,8 % | 2,0 % |
| Accionario | 1,1 % | 4,5 % |

- **Correlaciones:** diversificar no es repartir entre muchos fondos, sino entre fondos poco correlacionados; si dos se mueven igual, caen juntos y no reducen el riesgo.
- **Frontera eficiente:** para cada retorno exigido, la cartera de menor riesgo. A más retorno, más riesgo: el accionario rinde más pero es el más volátil; la liquidez es el más conservador. Con 0,8 % **no se puede llegar solo con liquidez** (rinde 0,3 %).
- Cada punto de la curva es un problema de `cvxpy` resuelto.

### Cartera óptima con $R = 0{,}8\,\%$ mensual

```python
w = cp.Variable(4)
riesgo = cp.quad_form(w, cp.psd_wrap(Sigma))
restr = [cp.sum(w) == 1, w >= 0, mu @ w >= 0.008]
prob = cp.Problem(cp.Minimize(riesgo), restr)
prob.solve(solver=cp.CLARABEL)
```

| Fondo | Peso |
|---|---|
| Liquidez | 0 % |
| Bonos CRC | 28,2 % |
| Bonos USD | 53,0 % |
| Accionario | 18,8 % |

- **Precio sombra del retorno: 0,172.** Pedir más ganancia cuesta más riesgo; este número mide cuánto riesgo extra cuesta cada poquito de retorno adicional.
- **Liquidez queda fuera:** la regla "ningún peso negativo" le estorba, así que su precio es positivo (0,00028); los otros tres fondos entran y su precio es 0.
- Con solo 0,7 % de retorno, la Liquidez sí entra (1,8 %).
- Markowitz ganó el Nobel de Economía (1990) por la teoría moderna de carteras (análisis media-varianza): mostró cómo diversificar de forma inteligente para equilibrar rentabilidad y riesgo, que es justamente un problema de optimización con restricciones.

---

## 8. Para el proyecto integrador (diapositiva 18)

- **Operaciones y energía** (presupuesto, inventario, despacho, asignación de recursos): reportar qué restricciones aprietan y su precio sombra.
- **Finanzas** (carteras, reservas): la frontera eficiente y el precio del retorno exigido son resultados para el documento.
- **Todos:** la rúbrica final pide **análisis de sensibilidad**: barrer un parámetro y mostrar cómo cambia el óptimo.
- Frase modelo para el informe: *"si la capacidad aumentara una unidad, el costo bajaría X, mientras esa regla siga estorbando"* (p. ej., si la capacidad de producción aumenta una unidad, el costo baja 300 dólares).

---

## 9. Cierre (diapositivas 19 a 21)

- **Lo mejor sin romper reglas:** lo que se quiere, limitado por lo que no se puede violar.
- **¿Estorba o no?:** si lo ideal está permitido, la regla da igual; si no, el óptimo queda pegado al borde.
- **El precio de una regla:** cuánto se gana si se la afloja una unidad; si no estorba, vale cero.

### Conceptos clave

1. Optimizar con restricciones = mejor resultado posible **sin romper las reglas** (cercas).
2. Una restricción es **activa** (estorba, el óptimo está en el borde) o **inactiva** (no estorba); nunca ambas.
3. **Precio sombra** (multiplicador de Lagrange, `dual_value`): mejora por unidad al aflojar la regla; **cero si no estorba**.
4. **KKT:** todo óptimo cumple que cada restricción o estorba (con precio) o no estorba (sin precio).
5. **Geometría de Lagrange:** el óptimo está donde la curva de nivel del objetivo apenas toca la restricción.
6. El **signo** de `dual_value` depende de cómo se escribe la regla: interpretar la magnitud.
7. El precio sombra vale **por tramos**: cambia cuando otra fuente pasa a ser la que cierra el balance (205, 105, 45 en el despacho).
8. El precio sombra **predice** el cambio al mover la regla un poco (mientras siga estorbando).
9. **Markowitz:** minimizar riesgo con retorno mínimo; el precio del retorno crece al exigir más (la frontera es cada vez más empinada).
10. **Sensibilidad:** barrer un parámetro y ver cómo cambia lo óptimo; el proyecto la exige.

---

## Fuera del PDF — logística, tareas y metodología

### Práctica en salas (actividad complementaria)

- **Tarea moral:** no se entrega ni se califica. Grupal, 60 minutos con los grupos del proyecto; lo pendiente se termina durante la semana. Es un notebook de Colab (primera celda: `!pip install -q cvxpy`), guardado en Drive o GitHub con un nombre como `Clase10_Restricciones_Grupo.ipynb`.
- El código viene guiado; **lo importante es la interpretación** de los resultados, no escribirlo. Primero se anota la predicción en una celda de texto y después se corre el código.

| Parte | Qué se hace | Resultado de referencia |
|---|---|---|
| 1. Predecir (15 min) | **A:** minimizar $2x^2+y^2$ sobre $x+y=3$. **B:** minimizar $(x-5)^2$ con $x\le4$ y con $x\le6$ | A: $(1,\,2)$, $f^*=6$, precio 4 (la variable más cara, $x$, pesa menos). Con $x+y=3{,}1$: $f^*$ sube 0,4067, casi lo que predice el precio ($4\times0{,}1$). B: con $x\le4$ **aprieta** ($x^*=4$, precio 2); con $x\le6$ **sobra** ($x^*=5$, precio 0) |
| 2. Cartera (20 min) | Mínimo riesgo con $R=0{,}7\,\%$ y $0{,}9\,\%$; anotar pesos, volatilidad y precio del retorno; revisar qué fondos quedan fuera | $R=0{,}7\,\%$: pesos $[0{,}018;\,0{,}598;\,0{,}289;\,0{,}096]$, vol. 1,31 %, precio 0,082. $R=0{,}9\,\%$: pesos $[0;\,0;\,0{,}667;\,0{,}333]$, vol. 2,29 %, precio 0,332. Salen Liquidez y Bonos CRC (su cerca $w\ge0$ pasa a tener precio positivo) |
| 3. Sensibilidad (15 min) | Mover $R$ de 0,009 a 0,00901 y comparar con el dual; despacho con 1 040, 1 160 y 1 170 GWh de demanda | Dual 0,332 contra pendiente numérica 0,334 (la diferencia viene de la curvatura de la frontera). Despacho: 1 160 → 1 170 cuesta $2\,200=10\times220$ (la térmica sigue cerrando el balance); con 1 040 GWh el último GWh lo pone la importación y cuesta **120**: el precio sombra vale por tramos |
| 4. Decisión (10 min) | Tres respuestas cortas en una celda de texto | Ver abajo |

Preguntas de la parte 4:

- **Despacho:** ¿50 GWh más de agua o de eólica ahorran más? (Comparar $-205$ con $-160$: gana el agua.)
- **Cartera:** ¿qué decirle a un cliente que pide 0,9 % frente a 0,7 %? (El riesgo sube de 1,31 % a 2,29 % de volatilidad y cada punto extra de retorno cuesta más riesgo.)
- **Proyecto:** ¿el modelo tiene alguna restricción? Si la tiene, ¿qué significaría su precio sombra en palabras?

**Tarea moral extra:** adaptar el código de la cartera (con ayuda de IA) a otros activos, como Bitcoin o el S&P 500, y ver cómo se comporta.

> **Nota sobre los retornos:** son **mensuales**. Multiplicados por 12 (aproximación simple), 0,7 % equivale a unos 8,4 % anual y 0,9 % a unos 10,8 %.

### Proyecto, presentaciones y evaluación

- **Semana 11** (19 de noviembre): sin entregable.
- **Presentación grupal de tema complementario:** 10 % de la nota. Los temas se asignan el 26 de noviembre (semana 12) y se presenta el **3 de diciembre** (semana 13): 15 a 20 minutos más 5 de preguntas, con demostración en código desde Colab y sin documento escrito. Instrucciones en `Tareas/Proyecto_complementario/`. Se puede usar IA, pero todo el grupo debe poder explicar cualquier diapositiva y línea de código.
- **Desde esta semana** la prueba final y las prácticas son aplicadas: nada a mano.

### Próximas clases

| Clase | Fecha | Tema |
|---|---|---|
| Semana 11 | 19 de noviembre | Optimización moderna basada en gradiente: del descenso de gradiente a SGD con momento, Adam y AdamW, diferenciación automática con PyTorch y trayectorias de convergencia en superficies de pérdida |
| Semana 12 | 26 de noviembre | Asignación de temas complementarios; heurísticos sin gradiente (incluye CMA-ES) |
| Semana 13 | 3 de diciembre | Presentaciones grupales de tema complementario |

**Pendientes para la próxima semana:** terminar las partes de la práctica que quedaron abiertas e identificar las restricciones del modelo del proyecto, si las tiene.
