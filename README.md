# Propuestos Computacional

Este repositorio contiene dos proyectos principales:

- `Opcional_RungeKutta`
- `Opcional_Schrodinger`

## Importante

Antes de ejecutar el código, es necesario leer la guía de ejecución:

- [Guía de ejecución](./GuiaEjecucion.md)

En esa guía se explica la instalación en macOS y Windows, el uso de Docker y la ubicación de los resultados generados.

---

## 🔬 Descripción de los Proyectos

Ambos proyectos forman parte de las simulaciones y resoluciones numéricas para la asignatura de Física Computacional. Están diseñados para exprimir el rendimiento del procesador mediante ejecución en paralelo.

### 1. Sistema Dinámico (Runge-Kutta)
Resolución numérica de ecuaciones diferenciales no lineales mediante métodos de Runge-Kutta. El proyecto incluye:
- Simulaciones de evolución temporal y proyecciones en el espacio fásico.
- Generación de Secciones de Poincaré para el estudio del caos determinista.
- Cálculo de exponentes de Lyapunov y dependencia energética.

### 2. Ecuación de Schrödinger
Resolución computacional de la ecuación de Schrödinger dependiente del tiempo. El proyecto realiza:
- Evolución temporal de la función de onda y su densidad de probabilidad.
- Implementación de polinomios de Hermite para los autoestados del oscilador armónico.
- Cálculo de valores medios y renderizado de animaciones del comportamiento cuántico.

## 🛠 Herramientas y Tecnologías

Todo el flujo de trabajo está automatizado mediante *Bash scripts* que orquestan la compilación, simulación y renderizado:
- **Fortran 90 (`gfortran`)**: Para el cálculo numérico intensivo, paralelizado con OpenMP para reducir los tiempos de ejecución.
- **Gnuplot**: Generación masiva de gráficas y fotogramas a partir de los datos binarios/dat de Fortran.
- **FFmpeg / ImageMagick**: Ensamblado de fotogramas para crear animaciones `.mp4` y `.png` del sistema.
- **Docker**: Contenerización del entorno (Ubuntu 22.04) para garantizar la total reproducibilidad en cualquier sistema operativo (Windows, macOS o Linux) sin problemas de dependencias.

## 📂 Estructura del Repositorio

- `/Opcional_RungeKutta`: Contiene el código fuente (`Code/`), la memoria en LaTeX/PDF (`Main.pdf`) y su respectivo `Dockerfile`.
- `/Opcional_Schrodinger`: Contiene el código fuente (`Codigo/`), módulos de polinomios, la memoria (`Main.pdf`) y su `Dockerfile`.
- `/GUIA_DOCKER.md`: Guía de instalación y ejecución rápida paso a paso.

---
**Autor:** Jorge Del Rio - Grado en Física (Universidad de Granada)
