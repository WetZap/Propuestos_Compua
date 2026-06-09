# Guía de Ejecución de Simulaciones (Runge-Kutta y Schrödinger)

Esta guía explica cómo ejecutar las simulaciones computacionales en cualquier sistema operativo (macOS o Windows) utilizando Docker. Esto asegura que todas las dependencias (Fortran, Gnuplot, FFmpeg, OpenMP) funcionen perfectamente sin necesidad de configurarlas a mano.

---

## 🍎 Guía para macOS

### 1. Requisitos previos
1. **Instalar Docker:** 
   - Ve a [Docker Desktop para Mac](https://www.docker.com/products/docker-desktop/).
   - Descarga la versión correspondiente a tu procesador (**Apple Silicon** para M1/M2/M3 o **Intel chip**).
   - Instálalo, ábrelo desde la carpeta Aplicaciones y espera a que el icono de la ballena en la barra de menú superior deje de parpadear.
2. **Instalar Git:** Abre la aplicación **Terminal** (búscala con `Cmd + Espacio`) y ejecuta:
   ```bash
   xcode-select --install
   ```
   *(Acepta la ventana emergente si te pide instalar las herramientas de desarrollo).*

### 2. Descargar el código
En la Terminal, ejecuta estos comandos para guardar el proyecto en tu Escritorio:
```bash
cd ~/Desktop
git clone https://github.com/WetZap/Propuestos_Computacional.git
cd Propuestos_Computacional
```

### 3. Ejecutar Runge-Kutta
Construye la imagen de Docker (solo tarda unos 2-3 minutos la primera vez) y ejecuta la simulación:
```bash
cd Opcional_RungeKutta

# 1. Construir el entorno
docker build -t simulacion-rk .

# 2. Ejecutar (los vídeos y gráficas se guardarán en tu Escritorio)
docker run --rm -v "$(pwd)/Resultados_RK:/app/Code/Video" simulacion-rk
```
> **Nota:** Al terminar, encontrarás una nueva carpeta llamada `Resultados_RK` en `Opcional_RungeKutta` con todas las gráficas y animaciones generadas.

### 4. Ejecutar Schrödinger
```bash
cd ../Opcional_Schrodinger

# 1. Construir el entorno
docker build -t simulacion-schro .

# 2. Ejecutar (los resultados se guardarán en tu Escritorio)
docker run --rm -v "$(pwd)/Resultados_Schro:/app/Codigo/Video" simulacion-schro
```

---

## 🪟 Guía para Windows

### 1. Requisitos previos
1. **Instalar Docker:**
   - Ve a [Docker Desktop para Windows](https://www.docker.com/products/docker-desktop/) y descarga el instalador.
   - Ejecútalo y asegúrate de dejar marcada la opción **Use WSL 2 instead of Hyper-V** (recomendado).
   - Reinicia el ordenador si te lo pide. Abre Docker Desktop y espera a que el icono de la ballena en la barra de tareas esté fijo.
2. **Instalar Git:**
   - Descarga Git desde [git-scm.com/download/win](https://git-scm.com/download/win).
   - Ejecuta el instalador pulsando "Next" con todas las opciones por defecto.

### 2. Descargar el código
Abre **PowerShell** (búscalo en el menú Inicio de Windows) y ejecuta:
```powershell
cd $HOME\Desktop
git clone https://github.com/WetZap/Propuestos_Computacional.git
cd Propuestos_Computacional
```

### 3. Ejecutar Runge-Kutta
Dentro de PowerShell, ejecuta los siguientes comandos:
```powershell
cd Opcional_RungeKutta

# 1. Construir el entorno (tarda unos minutos la primera vez)
docker build -t simulacion-rk .

# 2. Ejecutar (los vídeos y gráficas se guardarán en tu Escritorio)
docker run --rm -v "${PWD}\Resultados_RK:/app/Code/Video" simulacion-rk
```
> **Nota:** Cuando el proceso acabe, verás una carpeta `Resultados_RK` con los vídeos y gráficas dentro de `Opcional_RungeKutta`.

### 4. Ejecutar Schrödinger
```powershell
cd ..\Opcional_Schrodinger

# 1. Construir el entorno
docker build -t simulacion-schro .

# 2. Ejecutar
docker run --rm -v "${PWD}\Resultados_Schro:/app/Codigo/Video" simulacion-schro
```