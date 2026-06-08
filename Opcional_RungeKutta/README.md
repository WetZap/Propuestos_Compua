# Simulación Péndulo Doble — Runge-Kutta (Fortran + OpenMP)

Implementación numérica del péndulo doble mediante el método de Runge-Kutta de orden 4, escrita en **Fortran 90** con paralelización **OpenMP** y orquestada por un script **Bash** que automatiza compilación, simulación y renderizado de resultados.

---

## Estructura del repositorio

```
Opcional_RungeKutta/
├── Code/
│   ├── Bash.sh                        # Script principal de ejecución
│   ├── Scripts/
│   │   ├── Opcional_Kutta1.f90        # Tarea 1 — diagrama de Poincaré (caso 1)
│   │   ├── Opcional_Kutta2.f90        # Tarea 2 — diagrama de Poincaré (caso 2)
│   │   ├── Opcional_Kutta3.f90        # Tarea 3 — diagrama de Poincaré (caso 3)
│   │   ├── Opcional_Kutta4.f90        # Tarea 4 — diagrama de Poincaré (caso 4)
│   │   ├── Opcional_KuttaThetaMax.f90 # Cálculo de θ₂_max en función de la energía
│   │   ├── Opcional_Kutta_Lyapunov.f90# Exponente de Lyapunov
│   │   └── Scripts_Temporal/          # Versiones sin OpenMP para series temporales
│   ├── Animation/                     # Scripts Gnuplot para generar gráficas
│   ├── Data/                          # Carpeta generada automáticamente con los datos
│   └── Video/                         # Carpeta generada automáticamente con las imágenes
├── Image/                             # Imágenes de resultados incluidas en la memoria
├── Video/                             # Vídeos y animaciones
├── Main.tex                           # Memoria del proyecto (LaTeX)
├── Main.pdf                           # Memoria compilada
└── biblio.bib / references.bib        # Referencias bibliográficas
```

---

## Requisitos

| Herramienta | Versión mínima | Notas |
|---|---|---|
| **Compilador Fortran** | gfortran ≥ 9 **o** Intel `ifx` (OneAPI) | El script usa `ifx` por defecto |
| **OpenMP** | incluido en el compilador | Para paralelización de hilos |
| **Gnuplot** | ≥ 5.4 | Renderizado de gráficas |
| **Bash** | ≥ 4 | Orquestación del pipeline |

> **Nota sobre el compilador:** el script tiene dos funciones de compilación (`Compilacion_gfortran` y `Compilacion_INTEL`). Por defecto se invoca `Compilacion_INTEL`. Para usar `gfortran`, comenta la línea `Compilacion_INTEL` y descomenta `#Compilacion_gfortran`.

---

## Método de ejecución

Todo el flujo se lanza con un único comando desde dentro de `Code/`:

```bash
cd Opcional_RungeKutta/Code
bash Bash.sh
```

El script ejecuta automáticamente las siguientes **4 fases** en orden:

### Fase 1 — Preparación de directorios

Crea la estructura de carpetas necesaria y **limpia los datos de ejecuciones anteriores** (archivos `.dat`, `.bin`, `.png`, `.mp4`):

```
Data/Tarea{1..4}/
Data/Tarea{1..4}/Temporal/
Data/Tarea{1..4}/Poincare/
Data/Lyapunov/
Data/Poincare/
Video/Tarea{1..4}/
Video/Lyapunov/
Video/Poincare/
```

### Fase 2 — Compilación en paralelo

Se compilan **10 ejecutables Fortran simultáneamente** en background (`&`) para aprovechar todos los núcleos disponibles:

```bash
ifx -O3 -xHost -fp-model=fast=2 -qopenmp -ipo -fno-alias Opcional_Kutta1.f90 -o Opcional_Kutta1.out &
# ... (ídem para los 9 restantes)
wait  # espera a que todos terminen
```

Las banderas de optimización utilizadas son:

| Flag | Efecto |
|---|---|
| `-O3` | Máxima optimización del compilador |
| `-xHost` | Instrucciones SIMD nativas de la CPU (equivalente a `-march=native`) |
| `-fp-model=fast=2` | Aritmética en coma flotante relajada (equivalente a `-ffast-math`) |
| `-qopenmp` | Habilita paralelismo OpenMP |
| `-ipo` | Optimización interprocedural (Link-Time Optimization) |

### Fase 3 — Simulaciones

Las simulaciones se ejecutan en el siguiente orden:

1. **Series temporales** (sin OpenMP, un hilo): los 4 scripts `*Temp.f90` generan las trayectorias θ₁(t) y θ₂(t) para cada condición inicial.
2. **Exponente de Lyapunov**: `Opcional_Kutta_Lyapunov.f90` calcula la divergencia exponencial entre trayectorias cercanas.
3. **Diagramas de Poincaré** (con OpenMP, 10 hilos): los 4 ejecutables principales generan los cortes de Poincaré en paralelo. Los hilos se anclan a los primeros 10 núcleos del procesador mediante:
   ```bash
   export OMP_NUM_THREADS=10
   export KMP_AFFINITY="explicit,proclist=[0-9]"
   ```
4. **θ₂_max vs energía**: `Opcional_KuttaThetaMax.f90` barre el espacio de energías y registra el ángulo máximo alcanzado por el segundo péndulo.

### Fase 4 — Renderizado con Gnuplot

Las gráficas se generan automáticamente llamando a los scripts `.plt` de `Animation/`:

| Función Bash | Gráfica generada |
|---|---|
| `render_PoincareEFI` | Diagrama de Poincaré (θ₂ vs ω₂) |
| `render_Tiempo` | Serie temporal θ(t) — escala corta |
| `render_TiempoGlobal` | Serie temporal θ(t) — escala global |
| `render_Proyeccion` | Espacio de fases (θ₁ vs ω₁, θ₂ vs ω₂) |
| `render_Poincare2` | θ₂_max en función de la energía |
| `render_Lyapunov` | Exponente de Lyapunov λ(t) |
| `render_Energia_Lyapunov` | Energía del sistema durante el cálculo de Lyapunov |

Al finalizar, los ejecutables `.out` son eliminados automáticamente y se imprime un resumen de tiempos por fase.

---

## Salida esperada

```
=====================================
 SIMULACIÓN RUNGE-KUTTA
=====================================
  Preparación de directorios         → 0m 0s 45ms
[1/4] Compilando...
  Compilación (ambos .f90 en paralelo) → 0m 8s 312ms
[2/4] Ejecutando simulaciones ...
  ...
[3/4] Renderizando vídeos y gráficas...
  ...
=====================================
 RESUMEN DE TIEMPOS
=====================================
  Tiempo total: Xm Ys Zms
=====================================
¡Proceso finalizado con éxito!
```

Los resultados (imágenes `.png`) quedarán en `Code/Video/Tarea{1..4}/`, `Code/Video/Lyapunov/` y `Code/Video/Poincare/`.

---

## Memoria del proyecto

La documentación matemática completa del método Runge-Kutta, las ecuaciones del péndulo doble y el análisis de los resultados se encuentran en [`Main.pdf`](./Main.pdf).
