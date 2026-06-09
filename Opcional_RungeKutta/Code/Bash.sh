#!/usr/bin/env bash
set -Eeuo pipefail

# ─── Temporizador ────────────────────────────────────────────────────────────
T_TOTAL_INICIO=$(date +%s%3N)

fmt_tiempo() {
    local ms=$1
    local seg=$(( ms / 1000 ))
    local ms_resto=$(( ms % 1000 ))
    local min=$(( seg / 60 ))
    local seg_resto=$(( seg % 60 ))
    printf "%dm %ds %dms" "$min" "$seg_resto" "$ms_resto"
}

fase() {
    local nombre="$1"
    local inicio="$2"
    local fin
    fin=$(date +%s%3N)
    printf "  %-35s → %s\n" "$nombre" "$(fmt_tiempo $(( fin - inicio )))"
}

echo "====================================="
echo " SIMULACIÓN RUNGE-KUTTA"
echo "====================================="

# ─── Rutas ───────────────────────────────────────────────────────────────────
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

DIR_DATOS_OUT="$DIR/Data/Tarea1"
DIR_DATOS_OUT_2="$DIR/Data/Tarea2"
DIR_DATOS_OUT_3="$DIR/Data/Tarea3"
DIR_DATOS_OUT_4="$DIR/Data/Tarea4"

DIR_DATOS_Lyapunov="$DIR/Data/Lyapunov"

DIR_DATOS_TEMP_1="$DIR/Data/Tarea1/Temporal"
DIR_DATOS_TEMP_2="$DIR/Data/Tarea2/Temporal"
DIR_DATOS_TEMP_3="$DIR/Data/Tarea3/Temporal"
DIR_DATOS_TEMP_4="$DIR/Data/Tarea4/Temporal"

DIR_DATOS_POINCARE="$DIR/Data/Poincare"


DIR_GIFS_SISTEMA="$DIR/Video/Tarea1"
DIR_GIFS_SISTEMA_2="$DIR/Video/Tarea2"
DIR_GIFS_SISTEMA_3="$DIR/Video/Tarea3"
DIR_GIFS_SISTEMA_4="$DIR/Video/Tarea4"

DIR_GIFS_Lyapunov="$DIR/Video/Lyapunov"

DIR_GIFS_POINCARE="$DIR/Video/Poincare"

DIR_SCR="$DIR/Scripts"

DIR_SCRIPT="$DIR/Scripts/Opcional_Kutta1.f90"
DIR_EJECUTABLE="$DIR/Scripts/Opcional_Kutta1.out"

DIR_SCRIPT_2="$DIR/Scripts/Opcional_Kutta2.f90"
DIR_EJECUTABLE_2="$DIR/Scripts/Opcional_Kutta2.out"

DIR_SCRIPT_3="$DIR/Scripts/Opcional_Kutta3.f90"
DIR_EJECUTABLE_3="$DIR/Scripts/Opcional_Kutta3.out"

DIR_SCRIPT_4="$DIR/Scripts/Opcional_Kutta4.f90"
DIR_EJECUTABLE_4="$DIR/Scripts/Opcional_Kutta4.out"

DIR_SCRIPT_5="$DIR/Scripts/Opcional_KuttaThetaMax.f90"
DIR_EJECUTABLE_5="$DIR/Scripts/Opcional_KuttaThetaMax.out"

DIR_SCRIPT_TEMP_1="$DIR/Scripts/Scripts_Temporal/Opcional_Kutta1Temp.f90"
DIR_EJECUTABLE_TEMP_1="$DIR/Scripts/Scripts_Temporal/Opcional_Kutta1Temp.out"

DIR_SCRIPT_TEMP_2="$DIR/Scripts/Scripts_Temporal/Opcional_Kutta2Temp.f90"
DIR_EJECUTABLE_TEMP_2="$DIR/Scripts/Scripts_Temporal/Opcional_Kutta2Temp.out"

DIR_SCRIPT_TEMP_3="$DIR/Scripts/Scripts_Temporal/Opcional_Kutta3Temp.f90"
DIR_EJECUTABLE_TEMP_3="$DIR/Scripts/Scripts_Temporal/Opcional_Kutta3Temp.out"

DIR_SCRIPT_TEMP_4="$DIR/Scripts/Scripts_Temporal/Opcional_Kutta4Temp.f90"
DIR_EJECUTABLE_TEMP_4="$DIR/Scripts/Scripts_Temporal/Opcional_Kutta4Temp.out"

DIR_SCRIPT_LYAPUNOV="$DIR/Scripts/Opcional_Kutta_Lyapunov.f90"
DIR_EJECUTABLE_LYAPUNOV="$DIR/Scripts/Opcional_Kutta_Lyapunov.out"

N_JOBS=$(( $(nproc) ))


# ─── Preparación ─────────────────────────────────────────────────────────────
T_PREP=$(date +%s%3N)

# TAREA 1: Crear directorios y limpiar
mkdir -p "$DIR_DATOS_OUT/Poincare" "$DIR_GIFS_SISTEMA" "$DIR_DATOS_TEMP_1"
mkdir -p "$DIR_GIFS_SISTEMA/Fase_1" "$DIR_GIFS_SISTEMA/Fase_2"
find "$DIR_DATOS_OUT" -maxdepth 1 -name '*.dat' -delete
find "$DIR_DATOS_OUT/Temporal" -maxdepth 1 -name '*.dat' -delete
find "$DIR_DATOS_OUT/Poincare" -maxdepth 1 -name '*.bin' -delete
find "$DIR_GIFS_SISTEMA" -maxdepth 1 -name '*.mp4' -delete
find "$DIR_GIFS_SISTEMA" -maxdepth 1 -name '*.png' -delete
find "$DIR_GIFS_SISTEMA/Fase_1" -maxdepth 1 -name '*.png' -delete
find "$DIR_GIFS_SISTEMA/Fase_2" -maxdepth 1 -name '*.png' -delete

# TAREA 2: Crear directorios y limpiar
mkdir -p "$DIR_DATOS_OUT_2/Poincare" "$DIR_GIFS_SISTEMA_2" "$DIR_DATOS_TEMP_2"
mkdir -p "$DIR_GIFS_SISTEMA_2/Fase_1" "$DIR_GIFS_SISTEMA_2/Fase_2"
find "$DIR_DATOS_OUT_2" -maxdepth 1 -name '*.dat' -delete
find "$DIR_DATOS_OUT_2/Temporal" -maxdepth 1 -name '*.dat' -delete
find "$DIR_DATOS_OUT_2/Poincare" -maxdepth 1 -name '*.bin' -delete
find "$DIR_GIFS_SISTEMA_2" -maxdepth 1 -name '*.mp4' -delete
find "$DIR_GIFS_SISTEMA_2" -maxdepth 1 -name '*.png' -delete
find "$DIR_GIFS_SISTEMA_2/Fase_1" -maxdepth 1 -name '*.png' -delete
find "$DIR_GIFS_SISTEMA_2/Fase_2" -maxdepth 1 -name '*.png' -delete

# TAREA 3: Crear directorios y limpiar
mkdir -p "$DIR_DATOS_OUT_3/Poincare" "$DIR_GIFS_SISTEMA_3" "$DIR_DATOS_TEMP_3"
mkdir -p "$DIR_GIFS_SISTEMA_3/Fase_1" "$DIR_GIFS_SISTEMA_3/Fase_2"
find "$DIR_DATOS_OUT_3" -maxdepth 1 -name '*.dat' -delete
find "$DIR_DATOS_OUT_3/Temporal" -maxdepth 1 -name '*.dat' -delete
find "$DIR_DATOS_OUT_3/Poincare" -maxdepth 1 -name '*.bin' -delete
find "$DIR_GIFS_SISTEMA_3" -maxdepth 1 -name '*.mp4' -delete
find "$DIR_GIFS_SISTEMA_3" -maxdepth 1 -name '*.png' -delete
find "$DIR_GIFS_SISTEMA_3/Fase_1" -maxdepth 1 -name '*.png' -delete
find "$DIR_GIFS_SISTEMA_3/Fase_2" -maxdepth 1 -name '*.png' -delete

# TAREA 4: Crear directorios y limpiar
mkdir -p "$DIR_DATOS_OUT_4/Poincare" "$DIR_GIFS_SISTEMA_4" "$DIR_DATOS_TEMP_4"
mkdir -p "$DIR_GIFS_SISTEMA_4/Fase_1" "$DIR_GIFS_SISTEMA_4/Fase_2"
find "$DIR_DATOS_OUT_4" -maxdepth 1 -name '*.dat' -delete
find "$DIR_DATOS_OUT_4/Temporal" -maxdepth 1 -name '*.dat' -delete
find "$DIR_DATOS_OUT_4/Poincare" -maxdepth 1 -name '*.bin' -delete
find "$DIR_GIFS_SISTEMA_4" -maxdepth 1 -name '*.mp4' -delete
find "$DIR_GIFS_SISTEMA_4" -maxdepth 1 -name '*.png' -delete
find "$DIR_GIFS_SISTEMA_4/Fase_1" -maxdepth 1 -name '*.png' -delete
find "$DIR_GIFS_SISTEMA_4/Fase_2" -maxdepth 1 -name '*.png' -delete

mkdir -p "$DIR_DATOS_Lyapunov" "$DIR_GIFS_Lyapunov"
find "$DIR_DATOS_Lyapunov" -maxdepth 1 -name '*.dat' -delete
find "$DIR_DATOS_Lyapunov" -maxdepth 1 -name '*.bin' -delete
find "$DIR_GIFS_Lyapunov" -maxdepth 1 -name '*.mp4' -delete
find "$DIR_GIFS_Lyapunov" -maxdepth 1 -name '*.png' -delete

mkdir -p "$DIR_DATOS_POINCARE" "$DIR_GIFS_POINCARE"
find "$DIR_DATOS_POINCARE" -maxdepth 1 -name '*.bin' -delete
find "$DIR_GIFS_POINCARE" -maxdepth 1 -name '*.mp4' -delete
find "$DIR_GIFS_POINCARE" -maxdepth 1 -name '*.png' -delete

fase "Preparación de directorios" "$T_PREP"


# Funciones para la ejecución en paralelo

render_Poincare() {
    local data_dir="$1" out_dir="$2" 

    local ruta="$data_dir/Poincare/Thread_"
    cd "$data_dir"
    local video_out="$out_dir/simulacion_Poincare.png"

    local num_archivos=$(find "$data_dir/Poincare" -maxdepth 1 -name "Thread_*.bin" | wc -l)

    gnuplot -e "ruta='${ruta}'; video_out='$video_out'; x_label='\theta_2'; y_label='$\omega_2'; N_archivos=$num_archivos" "$DIR/Animation/Poincare.plt" > /dev/null 2>&1
}
render_PoincareEFI() {
    local data_dir="$1" 
    local out_dir="$2" 

    local ruta="$data_dir/Poincare/Thread_"
    local video_out="$out_dir/simulacion_Poincare.png"

    # Contamos cuántos archivos Thread_*.bin hay en la carpeta
    local num_archivos=$(find "$data_dir/Poincare" -maxdepth 1 -name "Thread_*.bin" | wc -l)
    echo "Número de archivos de Poincaré encontrados: $num_archivos"
    # Si no hay archivos, avisamos y salimos
    if [ "$num_archivos" -eq 0 ]; then
        echo "No se encontraron archivos binarios de Poincaré."
        return 1
    fi
    echo "Renderizando gráfica de Poincaré con $num_archivos archivos..."
    # Usamos sintaxis {/Symbol q} para letras griegas en Gnuplot
    gnuplot -e "ruta='${ruta}'; video_out='${video_out}'; x_label='{/Symbol q}_2'; y_label='{/Symbol w}_2'; N_archivos=${num_archivos}" "$DIR/Animation/PoincareEFI.plt" > /dev/null 2>&1
    
    echo "Gráfica guardada en: $video_out"
}


render_Poincare2() {
    local data_dir="$1" 
    local out_dir="$2" 

    # La ruta base ahora apunta a los nuevos nombres de archivo generados por el Fortran
    local ruta="$data_dir/Thread_Tmax_"
    
    # Cambiamos al directorio correcto
    cd "$data_dir/" || return
    
    local video_out="$out_dir/simulacion_Poincare_2"

    # Buscamos cuántos hilos han generado archivos .bin (deberían ser 12 si usaste OMP_NUM_THREADS=12)
    local num_archivos=$(find . -maxdepth 1 -name "Thread_Tmax_*.bin" | wc -l)
    
    if [ "$num_archivos" -eq 0 ]; then
        echo "No se encontraron archivos Thread_Tmax en $data_dir"
        return 1
    fi

    # Pasamos las variables a Gnuplot
    gnuplot -e "ruta='${ruta}'; video_out='${video_out}'; x_label='Energia'; y_label='{/Symbol q}_{2max}'; N_archivos=${num_archivos}" "$DIR/Animation/Poincare2.plt" > /dev/null 2>&1
}
render_Tiempo() {
    local data_dir="$1" out_dir="$2" 
    cd "$data_dir" || return
    
    local video_out="$out_dir/simulacion_Temporal.png"
    
    # El uso de 'echo' con el comodín (*) guarda todos los archivos coincidentes 
    # separados por un espacio dentro de la variable local.
    local archivos_theta1=$(ls -v RungeKutta_theta1_*.dat | tr '\n' ' ')
    local archivos_theta2=$(ls -v RungeKutta_theta2_*.dat | tr '\n' ' ')

   gnuplot -e "video_out='$video_out'; data_dir='$data_dir'; x_label='Tiempo (t)'; y_label='Angulo'; \
            list_theta1='$archivos_theta1'; list_theta2='$archivos_theta2'; \
            prefijo1='RungeKutta_theta1_'; prefijo2='RungeKutta_theta2_'" \
        "$DIR/Animation/Animacion.plt" > /dev/null 2>&1
}

render_TiempoGlobal() {
    local data_dir="$1" out_dir="$2" 
    cd "$data_dir" || return

    local archivos_theta1=$(ls -v RungeKutta_theta1_*.dat | tr '\n' ' ')
    local archivos_theta2=$(ls -v RungeKutta_theta2_*.dat | tr '\n' ' ')
    
    local video_out="$out_dir/simulacion_Temporal_Global.png"
    
    # El uso de 'echo' con el comodín (*) guarda todos los archivos coincidentes 
    # separados por un espacio dentro de la variable local.

   gnuplot -e "video_out='$video_out'; data_dir='$data_dir'; x_label='Tiempo (t)'; y_label='Angulo'; \
            list_theta1='$archivos_theta1'; list_theta2='$archivos_theta2'; \
            prefijo1='RungeKutta_theta1_'; prefijo2='RungeKutta_theta2_'" \
        "$DIR/Animation/Temporal.plt" > /dev/null 2>&1
}

render_Proyeccion() {
    local data_dir="$1" out_dir="$2" 

    local ruta="$data_dir"
    cd "$data_dir" || return
    
    local video_out="$out_dir/Fase_1/simulacion_Theta_1.png"
    local video_out2="$out_dir/Fase_2/simulacion_Theta_2.png"

    local archivos_theta1=$(ls -v RungeKutta_Fase1*.dat | tr '\n' ' ')
    local archivos_theta2=$(ls -v RungeKutta_Fase2*.dat | tr '\n' ' ')

    # Añadimos col_theta=1 (leerá $1 en awk)
    gnuplot -e "video_out='$video_out'; x_label='{/Symbol q}_1'; y_label='{/Symbol w}_1'; list_archi='$archivos_theta1'; prefijo='RungeKutta_Fase1_'; col_theta=1" "$DIR/Animation/Proyeccion.plt"

    # Añadimos col_theta=2 (leerá $2 en awk)
    gnuplot -e "video_out='$video_out2'; x_label='{/Symbol q}_2'; y_label='{/Symbol w}_2'; list_archi='$archivos_theta2'; prefijo='RungeKutta_Fase2_'; col_theta=2" "$DIR/Animation/Proyeccion.plt" > /dev/null 2>&1
}

render_Lyapunov() {
    local data_dir="$1" out_dir="$2" 

    local ruta="$data_dir"
    cd "$data_dir" || return
    local img_out="$out_dir/Lyapunov.png"

    archivos=$(find . -maxdepth 1 -type f -name 'RungeKutta_Lyapunov*.bin' -size +0 -printf '%P\n' | sort -V | tr '\n' ' ')
    # Cambiamos las etiquetas para que muestre t y la letra griega lambda (λ)
    gnuplot -e "img_out='$img_out'; x_label='Tiempo (t)'; y_label='Exponente de Lyapunov ({/Symbol l})'; list_archi='$archivos'" "$DIR/Animation/Lyapunov.plt" > /dev/null 2>&1
}

render_Energia_Lyapunov() {
    local data_dir="$1" out_dir="$2" 

    local ruta="$data_dir"
    cd "$data_dir" || return
    
    local img_out="$out_dir/Lyapunov_Energia.png"

    archivos=$(find . -maxdepth 1 -type f -name 'Lyapunov_Energia*.bin' -size +0 -printf '%P\n' | sort -V | tr '\n' ' ')
    # Cambiamos las etiquetas para que muestre t y la letra griega lambda (λ)
    gnuplot -e "img_out='$img_out'; x_label='Tiempo (t)'; y_label='Energía'; list_archi='$archivos'" "$DIR/Animation/Lyapunov2.plt" > /dev/null 2>&1
}

# ─── Compilación en paralelo ─────────────────────────────────────────────────
T_COMP=$(date +%s%3N)
echo "[1/4] Compilando..."

Compilacion_gfortran() {

    gfortran -O3 -march=native -ffast-math -fopenmp "$DIR_SCRIPT"   -o "$DIR_EJECUTABLE"  &
    pid_c1=$!
    gfortran -O3 -march=native -ffast-math -fopenmp "$DIR_SCRIPT_2" -o "$DIR_EJECUTABLE_2" &
    pid_c2=$!
    gfortran -O3 -march=native -ffast-math -fopenmp "$DIR_SCRIPT_3" -o "$DIR_EJECUTABLE_3" &
    pid_c3=$!
    gfortran -O3 -march=native -ffast-math -fopenmp "$DIR_SCRIPT_4" -o "$DIR_EJECUTABLE_4" &
    pid_c4=$!

    gfortran -O3 -march=native -ffast-math -fopenmp -flto "$DIR_SCRIPT_5" -o "$DIR_EJECUTABLE_5" &
    pid_c5=$!

    gfortran -O3 -march=native -ffast-math  "$DIR_SCRIPT_TEMP_1" -o "$DIR_EJECUTABLE_TEMP_1" &
    pid_c6=$!
    gfortran -O3 -march=native -ffast-math  "$DIR_SCRIPT_TEMP_2" -o "$DIR_EJECUTABLE_TEMP_2" &
    pid_c7=$!
    gfortran -O3 -march=native -ffast-math  "$DIR_SCRIPT_TEMP_3" -o "$DIR_EJECUTABLE_TEMP_3" &
    pid_c8=$!
    gfortran -O3 -march=native -ffast-math  "$DIR_SCRIPT_TEMP_4" -o "$DIR_EJECUTABLE_TEMP_4" &
    pid_c9=$!

    gfortran -O3 -march=native -ffast-math -flto "$DIR_SCRIPT_LYAPUNOV" -o "$DIR_EJECUTABLE_LYAPUNOV" &
    pid_c10=$!

}

Compilacion_INTEL() {

    # 1. CARGAR EL ENTORNO DE INTEL ONEAPI
    
    # Desactivamos temporalmente el chequeo de variables vacías (-u) 
    # para que el script de Intel no provoque un error fatal
    set +u
    
    # Cargamos el entorno en modo silencioso (con dev null) para que no ensucie la consola
    source /opt/intel/oneapi/setvars.sh > /dev/null 2>&1
    
    # Volvemos a activar el chequeo de variables vacías
    set -u


    # 2. CAMBIAR gfortran POR ifx CON SUS BANDERAS ÓPTIMAS
    # Banderas equivalentes:
    # -O3 : máxima optimización
    # -xHost : equivalente a -march=native (optimiza para tu Core Ultra)
    # -qopenmp : equivalente a -fopenmp
    # -ipo : equivalente a -flto (Interprocedural Optimization)
    # -fp-model=fast=2 : equivalente a -ffast-math
    ifx -O3 -xHost -fp-model=fast=2 -qopenmp -ipo -fno-alias "$DIR_SCRIPT"   -o "$DIR_EJECUTABLE"  &
    pid_c1=$!
    ifx -O3 -xHost -fp-model=fast=2 -qopenmp -ipo -fno-alias "$DIR_SCRIPT_2" -o "$DIR_EJECUTABLE_2" &
    pid_c2=$!
    ifx -O3 -xHost -fp-model=fast=2 -qopenmp -ipo -fno-alias "$DIR_SCRIPT_3" -o "$DIR_EJECUTABLE_3" &
    pid_c3=$!
    ifx -O3 -xHost -fp-model=fast=2 -qopenmp -ipo -fno-alias "$DIR_SCRIPT_4" -o "$DIR_EJECUTABLE_4" &
    pid_c4=$!

    ifx -O3 -xHost -fp-model=fast=2 -qopenmp -ipo -fno-alias "$DIR_SCRIPT_5" -o "$DIR_EJECUTABLE_5" &
    pid_c5=$!

    ifx -O3 -xHost -fp-model=fast=2  "$DIR_SCRIPT_TEMP_1" -o "$DIR_EJECUTABLE_TEMP_1" &
    pid_c6=$!
    ifx -O3 -xHost -fp-model=fast=2  "$DIR_SCRIPT_TEMP_2" -o "$DIR_EJECUTABLE_TEMP_2" &
    pid_c7=$!
    ifx -O3 -xHost -fp-model=fast=2  "$DIR_SCRIPT_TEMP_3" -o "$DIR_EJECUTABLE_TEMP_3" &
    pid_c8=$!
    ifx -O3 -xHost -fp-model=fast=2  "$DIR_SCRIPT_TEMP_4" -o "$DIR_EJECUTABLE_TEMP_4" &
    pid_c9=$!
    ifx -O3 -xHost -fp-model=fast=2 -ipo "$DIR_SCRIPT_LYAPUNOV" -o "$DIR_EJECUTABLE_LYAPUNOV" &
    pid_c10=$!

}

# Elegimos la compilación según el entorno disponible


Compilacion_gfortran

#Compilacion_INTEL

# Esperamos a que terminen las compilaciones y verificamos si hubo errores
wait "$pid_c1" || { echo "Error compilando Kutta_1.f90"; exit 1; }
wait "$pid_c2" || { echo "Error compilando Kutta_2.f90"; exit 1; }
wait "$pid_c3" || { echo "Error compilando Kutta_3.f90"; exit 1; }
wait "$pid_c4" || { echo "Error compilando Kutta_4.f90"; exit 1; }
wait "$pid_c5" || { echo "Error compilando Opcional_KuttaThetaMax.f90"; exit 1; }
wait "$pid_c6" || { echo "Error compilando Opcional_Kutta1Temp.f90"; exit 1; }
wait "$pid_c7" || { echo "Error compilando Opcional_Kutta2Temp.f90"; exit 1; }
wait "$pid_c8" || { echo "Error compilando Opcional_Kutta3Temp.f90"; exit 1; }
wait "$pid_c9" || { echo "Error compilando Opcional_Kutta4Temp.f90"; exit 1; }
wait "$pid_c10" || { echo "Error compilando Opcional_Kutta_Lyapunov.f90"; exit 1; }
fase "Compilación (ambos .f90 en paralelo)" "$T_COMP"

# ─── Simulaciones en paralelo ─────────────────────────────────────────────────
T_SIM=$(date +%s%3N)
echo "[2/4] Ejecutando simulaciones ..."



echo "Ejecutando simulación temporal 1...":
"$DIR_EJECUTABLE_TEMP_1" "$DIR_DATOS_TEMP_1"
echo "Ejecutando simulación temporal 2...":
"$DIR_EJECUTABLE_TEMP_2" "$DIR_DATOS_TEMP_2"
echo "Ejecutando simulación temporal 3...":
"$DIR_EJECUTABLE_TEMP_3" "$DIR_DATOS_TEMP_3"
echo "Ejecutando simulación temporal 4...":
"$DIR_EJECUTABLE_TEMP_4" "$DIR_DATOS_TEMP_4"

fase "Simulaciones Temporales" "$T_SIM"

echo "Ejecutando simulación para el cálculo del exponente de Lyapunov..."
"$DIR_EJECUTABLE_LYAPUNOV" "$DIR_DATOS_Lyapunov"

fase "Simulaciones de Lyapunov" "$T_SIM"

# Definimos los hilos que usaremos
export OMP_NUM_THREADS=10

# Usamos la variable específica de Intel para anclar los hilos
# "proclist=[0-9]" amarra los 10 hilos a los primeros 10 núcleos del procesador.
# "explicit" fuerza a que se respete esa lista, y "bind" evita que el SO los mueva
export KMP_AFFINITY="explicit,proclist=[0-9]"

echo "Ejecutando simulacion 1...":
"$DIR_EJECUTABLE" "$DIR_DATOS_OUT"
echo "Ejecutando simulacion 2...": 
"$DIR_EJECUTABLE_2" "$DIR_DATOS_OUT_2" 
echo "Ejecutando simulacion 3...":
"$DIR_EJECUTABLE_3" "$DIR_DATOS_OUT_3" 
echo "Ejecutando simulacion 4...":
"$DIR_EJECUTABLE_4" "$DIR_DATOS_OUT_4" 

fase "Simulaciones Poincaré" "$T_SIM"

echo "Ejecutando simulación para el cálculo de \theta_{2max}..."
"$DIR_EJECUTABLE_5" "$DIR_DATOS_POINCARE" 


wait
fase "Simulaciones Fortran" "$T_SIM"

# ─── Renderizado en paralelo ──────────────────────────────────────────────────
T_RENDER=$(date +%s%3N)
echo "[3/4] Renderizando vídeos y gráficas..."
# Renderizar vídeos y gráficas en paralelo

#render_Poincare "$DIR_DATOS_OUT" "$DIR_GIFS_SISTEMA"
#render_Poincare "$DIR_DATOS_OUT_2" "$DIR_GIFS_SISTEMA_2"
#render_Poincare "$DIR_DATOS_OUT_3" "$DIR_GIFS_SISTEMA_3"
#render_Poincare "$DIR_DATOS_OUT_4" "$DIR_GIFS_SISTEMA_4"

render_PoincareEFI "$DIR_DATOS_OUT" "$DIR_GIFS_SISTEMA"
render_PoincareEFI "$DIR_DATOS_OUT_2" "$DIR_GIFS_SISTEMA_2"
render_PoincareEFI "$DIR_DATOS_OUT_3" "$DIR_GIFS_SISTEMA_3"
render_PoincareEFI "$DIR_DATOS_OUT_4" "$DIR_GIFS_SISTEMA_4"



render_Tiempo "$DIR_DATOS_TEMP_1" "$DIR_GIFS_SISTEMA"
render_Tiempo "$DIR_DATOS_TEMP_2" "$DIR_GIFS_SISTEMA_2"
render_Tiempo "$DIR_DATOS_TEMP_3" "$DIR_GIFS_SISTEMA_3"
render_Tiempo "$DIR_DATOS_TEMP_4" "$DIR_GIFS_SISTEMA_4"

render_TiempoGlobal "$DIR_DATOS_TEMP_1" "$DIR_GIFS_SISTEMA"
render_TiempoGlobal "$DIR_DATOS_TEMP_2" "$DIR_GIFS_SISTEMA_2"
render_TiempoGlobal "$DIR_DATOS_TEMP_3" "$DIR_GIFS_SISTEMA_3"
render_TiempoGlobal "$DIR_DATOS_TEMP_4" "$DIR_GIFS_SISTEMA_4"


render_Proyeccion "$DIR_DATOS_TEMP_1" "$DIR_GIFS_SISTEMA"
render_Proyeccion "$DIR_DATOS_TEMP_2" "$DIR_GIFS_SISTEMA_2"
render_Proyeccion "$DIR_DATOS_TEMP_3" "$DIR_GIFS_SISTEMA_3"
render_Proyeccion "$DIR_DATOS_TEMP_4" "$DIR_GIFS_SISTEMA_4"

render_Poincare2 "$DIR_DATOS_POINCARE" "$DIR_GIFS_POINCARE"

render_Lyapunov "$DIR_DATOS_Lyapunov" "$DIR_GIFS_Lyapunov"
render_Energia_Lyapunov "$DIR_DATOS_Lyapunov" "$DIR_GIFS_Lyapunov"


wait
fase "Renderizado de vídeos y gráficas" "$T_RENDER"

# Borramos .out

find "$DIR_SCR" -maxdepth 1 -name '*.out' -delete
find "$DIR_SCR/Scripts_Temporal" -maxdepth 1 -name '*.out' -delete

# ─── Resumen final ────────────────────────────────────────────────────────────
T_TOTAL_FIN=$(date +%s%3N)
echo ""
echo "====================================="
echo " RESUMEN DE TIEMPOS"
echo "====================================="
echo "  Tiempo total: $(fmt_tiempo $(( T_TOTAL_FIN - T_TOTAL_INICIO )))"
echo "====================================="
echo "¡Proceso finalizado con éxito!"