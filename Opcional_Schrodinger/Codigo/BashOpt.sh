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
echo " SIMULACIÓN SCHRÖDINGER"
echo "====================================="

# ─── Rutas ───────────────────────────────────────────────────────────────────
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

DIR_DATOS_OUT="$DIR/Data/Auto"
DIR_DATOS_OUT_2="$DIR/Data/Func"
DIR_GIFS_SISTEMA="$DIR/Video/Auto"
DIR_GIFS_SISTEMA_2="$DIR/Video/Func"

DIR_SCRIPT="$DIR/Scripts/Schrodinger_Auto.f90"
DIR_EJECUTABLE="$DIR/Scripts/Schrodinger_Auto.out"
DIR_SCRIPT_2="$DIR/Scripts/Schrodinger_Func.f90"
DIR_EJECUTABLE_2="$DIR/Scripts/Schrodinger_Func.out"


VALORES_N=(0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20)

N_JOBS=$(( $(nproc) ))
# ─── Preparación ─────────────────────────────────────────────────────────────
T_PREP=$(date +%s%3N)
 Crear directorios base y subdirectorios para cada n
for n in "${VALORES_N[@]}"; do
    mkdir -p "$DIR_DATOS_OUT/n_${n}"
    mkdir -p "$DIR_GIFS_SISTEMA/n_${n}"
    # Limpiamos datos anteriores si existen
    rm -f "$DIR_DATOS_OUT/n_${n}"/*.dat
    rm -f "$DIR_GIFS_SISTEMA/n_${n}"/*.mp4 "$DIR_GIFS_SISTEMA/n_${n}"/*.png
done
fase "Preparación de directorios" "$T_PREP"
mkdir -p "$DIR_DATOS_OUT_2" "$DIR_GIFS_SISTEMA_2"
rm -f "$DIR_DATOS_OUT_2"/*.dat
rm -f "$DIR_GIFS_SISTEMA_2"/*.mp4 "$DIR_GIFS_SISTEMA_2"/*.png
fase "Preparación de directorios" "$T_PREP"

# ─── Funciones auxiliares ─────────────────────────────────────────────────────
limit_jobs() {
    while [ "$(jobs -rp | wc -l)" -ge "$N_JOBS" ]; do
        wait -n
    done
}

render_espaciales() {
    local data_dir="$1" out_dir="$2"
    local archivos=("Phi_Abs.dat" "Phi_Fase.dat")
    local y_labels=("Valor de Phi" "Fase de Phi")
    cd "$data_dir"
    for i in "${!archivos[@]}"; do
        local video_out="$out_dir/simulacion_${archivos[$i]%.dat}.mp4"
        gnuplot -e "archivo_entrada='${archivos[$i]}'; video_out='$video_out'; x_label='Posición (x)'; y_label='${y_labels[$i]}'" \
            "$DIR/Animation/Espacial.plt" &
    done
}
render_Prob_Auto() {
    local data_dir="$1" out_dir="$2"
    local archivos=("Phi_Prob.dat")
    local archivos_t=("Tiempo.dat")
    local y_labels=("Probabilidad |Phi|^2")
    cd "$data_dir"
    for i in "${!archivos[@]}"; do
        local video_out="$out_dir/simulacion_${archivos[$i]%.dat}.mp4"
        gnuplot -e "archivo_entrada='${archivos[$i]}'; video_out='$video_out';archivo_tiempo='${archivos_t[$i]}'; x_label='Posición (x)'; y_label='${y_labels[$i]}'" \
            "$DIR/Animation/Prob_Auto.plt" &
    done
}
render_Prob_Func() {
    local data_dir="$1" out_dir="$2"
    local archivos=("Phi_Prob.dat")
    local y_labels=("Probabilidad |Phi|^2")
    cd "$data_dir"
    for i in "${!archivos[@]}"; do
        local video_out="$out_dir/simulacion_${archivos[$i]%.dat}.mp4"
        gnuplot -e "archivo_entrada='${archivos[$i]}'; video_out='$video_out'; x_label='Posición (x)'; y_label='${y_labels[$i]}'" \
            "$DIR/Animation/Prob_Func.plt" &
    done
}

render_temporales() {
    local data_dir="$1" out_dir="$2"
    local archivos_t=("ValorMediox.dat" "ValorMediop.dat" "Norma.dat")
    local y_labels_t=("Valor Medio <x>" "Valor Medio <p>" "Norma")
    cd "$data_dir"
    for i in "${!archivos_t[@]}"; do
        local video_out="$out_dir/simulacion_${archivos_t[$i]%.dat}.png"
        limit_jobs
       gnuplot -e "archivo_entrada='${archivos_t[$i]}'; video_out='$video_out'; x_label_t='Tiempo (t)'; y_label_t='${y_labels_t[$i]}'" \
            "$DIR/Animation/Temporal.plt" &
    done
}



render_Principio() {
    local data_dir="$1" out_dir="$2"
    local archivos_t=("PrincIncertidumbre.dat")
    local y_labels_t=("Incertidumbre Δx * Δp")
    cd "$data_dir"
    for i in "${!archivos_t[@]}"; do
        local video_out="$out_dir/simulacion_${archivos_t[$i]%.dat}.png"
        limit_jobs
       gnuplot -e "archivo_entrada='${archivos_t[$i]}'; video_out='$video_out'; x_label_t='Tiempo (t)'; y_label_t='${y_labels_t[$i]}'" \
            "$DIR/Animation/Principio_Incerti.plt" &
    done
}

render_Hamiltoniano() {
    local data_dir="$1" out_dir="$2"
    local archivos_t=("Hamiltoniano.dat")
    local y_labels_t=("Hamiltoniano")
    cd "$data_dir"
    for i in "${!archivos_t[@]}"; do
        local video_out="$out_dir/simulacion_${archivos_t[$i]%.dat}.png"
        limit_jobs
       gnuplot -e "archivo_entrada='${archivos_t[$i]}'; video_out='$video_out'; x_label_t='Tiempo (t)'; y_label_t='${y_labels_t[$i]}'" \
            "$DIR/Animation/Hamiltoniano.plt" &
    done
}

render_HamiltonianoFunc() {
    local data_dir="$1" out_dir="$2"
    local archivos_t=("Hamiltoniano.dat")
    local y_labels_t=("Hamiltoniano")
    cd "$data_dir"
    for i in "${!archivos_t[@]}"; do
        local video_out="$out_dir/simulacion_${archivos_t[$i]%.dat}.png"
        limit_jobs
       gnuplot -e "archivo_entrada='${archivos_t[$i]}'; video_out='$video_out'; x_label_t='Tiempo (t)'; y_label_t='${y_labels_t[$i]}'" \
            "$DIR/Animation/HamiltonianoFunc.plt" &
    done
}

render_juntos() {
    local data_dir="$1" out_dir="$2"
    cd "$data_dir"
    limit_jobs
    gnuplot -e "archivo_entrada='Juntos.dat'; video_out='$out_dir/simulacion_Juntos.mp4'; x_label='Posición (x)'; y_label='Valor de Phi'" \
        "$DIR/Animation/Juntos.plt" &
}

# ─── Compilación en paralelo ─────────────────────────────────────────────────
T_COMP=$(date +%s%3N)
echo "[1/4] Compilando..."

gfortran -O3 -march=native -ffast-math "$DIR_SCRIPT"   -o "$DIR_EJECUTABLE"  &
pid_c1=$!
gfortran -O3 -march=native -ffast-math "$DIR_SCRIPT_2" -o "$DIR_EJECUTABLE_2" &
pid_c2=$!

wait "$pid_c1" || { echo "Error compilando Auto.f90"; exit 1; }
wait "$pid_c2" || { echo "Error compilando Func.f90"; exit 1; }
fase "Compilación (ambos .f90 en paralelo)" "$T_COMP"

# ─── Simulaciones en paralelo ─────────────────────────────────────────────────
T_SIM=$(date +%s%3N)
echo "[2/4] Ejecutando simulaciones..."

"$DIR_EJECUTABLE"  &
pid_s1=$!
"$DIR_EJECUTABLE_2" &
pid_s2=$!

wait "$pid_s1" || { echo "Error en simulación Auto"; exit 1; }
wait "$pid_s2" || { echo "Error en simulación Func"; exit 1; }
fase "Simulaciones Fortran (ambas en paralelo)" "$T_SIM"

# ─── Renderizado en paralelo ──────────────────────────────────────────────────
T_RENDER=$(date +%s%3N)
echo "[3/4] Renderizando vídeos (N_JOBS=$N_JOBS)..."

render_espaciales "$DIR_DATOS_OUT"   "$DIR_GIFS_SISTEMA"
render_Prob_Auto       "$DIR_DATOS_OUT"   "$DIR_GIFS_SISTEMA"
render_temporales "$DIR_DATOS_OUT"   "$DIR_GIFS_SISTEMA"
render_juntos     "$DIR_DATOS_OUT"   "$DIR_GIFS_SISTEMA"
render_Principio  "$DIR_DATOS_OUT"   "$DIR_GIFS_SISTEMA"
render_Hamiltoniano  "$DIR_DATOS_OUT"   "$DIR_GIFS_SISTEMA"


render_espaciales "$DIR_DATOS_OUT_2" "$DIR_GIFS_SISTEMA_2"
render_Prob_Func     "$DIR_DATOS_OUT_2" "$DIR_GIFS_SISTEMA_2"
render_temporales "$DIR_DATOS_OUT_2" "$DIR_GIFS_SISTEMA_2"
render_juntos     "$DIR_DATOS_OUT_2" "$DIR_GIFS_SISTEMA_2"
render_Principio  "$DIR_DATOS_OUT_2" "$DIR_GIFS_SISTEMA_2"
render_HamiltonianoFunc  "$DIR_DATOS_OUT_2" "$DIR_GIFS_SISTEMA_2"

wait
fase "Renderizado de vídeos ($(( 3+1+3+1 )) MP4)" "$T_RENDER"

# ─── Resumen final ────────────────────────────────────────────────────────────
T_TOTAL_FIN=$(date +%s%3N)
echo ""
echo "====================================="
echo " RESUMEN DE TIEMPOS"
echo "====================================="
echo "  Tiempo total: $(fmt_tiempo $(( T_TOTAL_FIN - T_TOTAL_INICIO )))"
echo "====================================="
echo "¡Proceso finalizado con éxito!"