# Simulación de la ecuación de Schrödinger

Este directorio contiene una simulación numérica en Fortran del oscilador armónico cuántico y scripts auxiliares para generar visualizaciones de la evolución temporal de la función de onda.

## Contenido

```text
Codigo/
├── BashOptN.sh
├── hermite_poly.mod
├── hermite_poly_2.mod
├── Data/
├── Video/
├── Scripts/
│   ├── Schrodinger_Auto.f90
│   ├── Schrodinger_Func.f90
│   └── Mov_Armonico_Clasico.f90
└── Animation/
    ├── Espacial.plt
    ├── Prob_Auto.plt
    ├── Prob_Func.plt
    ├── Temporal.plt
    ├── Juntos.plt
    ├── Principio_Incerti.plt
    ├── Hamiltoniano.plt
    └── HamiltonianoFunc.plt

```

## Qué hace el script principal

El archivo `BashOptN.sh` automatiza todo el proceso de ejecución del proyecto:

1. Crea y limpia los directorios de salida.
2. Compila en paralelo los programas:
   - `Scripts/Schrodinger_Auto.f90`
   - `Scripts/Schrodinger_Func.f90`
   - `Scripts/Mov_Armonico.f90`
3. Ejecuta ambas simulaciones.
4. Genera gráficos y vídeos con `gnuplot`.

## Requisitos

Para ejecutar el proyecto necesitas tener instalados:

- `bash`
- `gfortran`
- `gnuplot`
- `ffmpeg`
- `nproc` o un entorno Linux compatible

En Ubuntu o Debian puedes instalarlo con:

```bash
sudo apt update
sudo apt install gfortran gnuplot ffmpeg coreutils
```

En distribuciones basadas en Arch se puede instalar con:

```bash
sudo pacman -Syu
sudo pacman -S gfortran gnuplot ffmpeg coreutils

```

En **macOS**, puedes instalar las dependencias fácilmente usando [Homebrew](https://brew.sh/):

```bash
brew install gcc gnuplot ffmpeg coreutils
```


Si no tuvieras Homebrew instalado en tu Mac, primero tienes que abrir la Terminal y ejecutar este comando:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

*(Nota: El compilador `gfortran` viene incluido en el paquete `gcc` de Homebrew).*
Por si necesitas instalar Homebrew primero (si no lo tienes):

## Cómo ejecutar

Sitúate dentro de este directorio:

```bash
cd Opcional_Schrodinger/Codigo
```

Da permisos al script principal:

```bash
chmod +x BashOpt.sh
```

Ejecuta la simulación:

```bash
./BashOptN.sh
```

## Qué hace la ejecución

Durante la ejecución, el script realiza estas fases:

### 1. Preparación

Crea los directorios de salida:

- `Data/Auto`
- `Data/Func`
- `Data/Clasico`
- `Video/Auto`
- `Video/Func`
- `Video/Clasico`


Además, prepara subdirectorios para los niveles cuánticos `n = 0, 1, ..., 20` y elimina resultados anteriores si existen.

### 2. Compilación

Compila los tres programas principales con optimización:

```bash
gfortran -O3 -march=native -ffast-math Scripts/Schrodinger_Auto.f90 -o Scripts/Schrodinger_Auto.out
gfortran -O3 -march=native -ffast-math Scripts/Schrodinger_Func.f90 -o Scripts/Schrodinger_Func.out
gfortran -O3 -march=native -ffast-math Scripts/Mov_Armonico.f90 -o Scripts/Mov_Armonico.out
```

### 3. Simulación

Ejecuta en paralelo:

```bash
Scripts/Schrodinger_Auto.out
Scripts/Schrodinger_Func.out
Scripts/Mov_Armonico.out
```

- `Schrodinger_Auto.out` genera datos automáticos para varios estados.
- `Schrodinger_Func.out` trabaja con la evolución funcional de la función de onda.
- `Mov_Armonico.out` trabaja con el caso clásico.

### 4. Renderizado

A partir de los datos generados, se crean animaciones y gráficas usando los scripts `.plt` del directorio `Animation`.

Se renderizan salidas como:

- `Phi_Abs.dat`
- `Phi_Fase.dat`
- `Phi_Prob.dat`
- `ValorMediox.dat`
- `ValorMediop.dat`
- `Norma.dat`
- `PrincIncertidumbre.dat`
- `Hamiltoniano.dat`
- `Juntos.dat`

Y se generan archivos de salida en formato:

- `.mp4` para animaciones
- `.png` para gráficas temporales

## Salida esperada

Al finalizar, el script muestra un resumen de tiempos parecido a este:

```text
=====================================
 SIMULACIÓN SCHRÖDINGER
=====================================
[1/4] Compilando...
[2/4] Ejecutando simulaciones...
[3/4] Renderizando vídeos...
=====================================
 RESUMEN DE TIEMPOS
=====================================
Tiempo total: ...
=====================================
¡Proceso finalizado con éxito!
```

## Archivos generados

Los resultados se guardan en:

- `Data/Auto/`
- `Data/Func/`
- `Data/Clasico/`

- `Video/Auto/`
- `Video/Func/`
- `Video/Clasico/`

Dentro de esos directorios encontrarás los datos numéricos y las visualizaciones producidas por la simulación.

## Notas

- El script está pensado para ejecutarse desde Linux.
- La compilación y el renderizado aprovechan paralelización.
- Si falta alguna dependencia, la ejecución fallará en la fase correspondiente.
- Si quieres modificar la simulación, revisa los archivos Fortran del directorio `Scripts/`.

## Autor

Repositorio: [WetZap/Propuestos_Computacional](https://github.com/WetZap/Propuestos_Computacional)