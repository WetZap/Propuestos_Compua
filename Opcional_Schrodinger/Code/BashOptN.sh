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
DIR_DATOS_OUT_3="$DIR/Data/Clasico"
DIR_GIFS_SISTEMA="$DIR/Video/Auto"
DIR_GIFS_SISTEMA_2="$DIR/Video/Func"
DIR_GIFS_SISTEMA_3="$DIR/Video/Clasico"

DIR_SCRIPT="$DIR/Scripts/Schrodinger_Auto.f90"
DIR_EJECUTABLE="$DIR/Scripts/Schrodinger_Auto.out"
DIR_SCRIPT_2="$DIR/Scripts/Schrodinger_Func.f90"
DIR_EJECUTABLE_2="$DIR/Scripts/Schrodinger_Func.out"
DIR_SCRIPT_3="$DIR/Scripts/Mov_Armonico_Clasico.f90"
DIR_EJECUTABLE_3="$DIR/Scripts/Mov_Armonico_Clasico.out"

# Valores de n a iterar, aquí escogemos los valores de n que queremos simular. 
VALORES_N=(4)

# Valores de n para los que que se borraran los datos anteriores y las carpetas de salida.
VALORES_N_2=(0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 50 80 100 1000)

N_JOBS=$(( $(nproc) ))

# ─── Funciones auxiliares ─────────────────────────────────────────────────────
limit_jobs() {
    while [ "$(jobs -rp | wc -l)" -ge "$N_JOBS" ]; do
        wait -n
    done
}

render_espaciales() {
    local data_dir="$1" out_dir="$2" 
    local n_val="${3:-0}"
    local archivos=("Phi_Abs.dat" "Phi_Fase.dat")
    local y_labels=("Valor de Phi" "Fase de Phi")
    cd "$data_dir"
    for i in "${!archivos[@]}"; do
        local video_out="$out_dir/simulacion_${archivos[$i]%.dat}.mp4"
        local captura_out="$out_dir/simulacion_${archivos[$i]%.dat}_captura.png" # Nombre para la captura

        gnuplot -e "archivo_entrada='${archivos[$i]}'; video_out='$video_out'; x_label='Posición (x)'; y_label='${y_labels[$i]}'; valor_n=$n_val" \
            "$DIR/Animation/Espacial.plt" 
        ffmpeg -y -i "$video_out" -vframes 1 -ss 00:00:00 -q:v 2 "$captura_out" > /dev/null 2>&1
    done &
}

render_Prob_Auto() {
    local data_dir="$1" out_dir="$2"
    local n_val="${3:-0}"
    local archivos=("Phi_Prob.dat")
    local archivos_t=("Tiempo.dat")
    local y_labels=("Probabilidad |Phi|^2")
    cd "$data_dir"
    for i in "${!archivos[@]}"; do
        local video_out="$out_dir/simulacion_${archivos[$i]%.dat}.mp4"
        local captura_out="$out_dir/simulacion_${archivos[$i]%.dat}_captura.png" # Nombre para la captura

        gnuplot -e "archivo_entrada='${archivos[$i]}'; video_out='$video_out'; archivo_tiempo='${archivos_t[$i]}'; x_label='Posición (x)'; y_label='${y_labels[$i]}'; valor_n=$n_val" \
            "$DIR/Animation/Prob_Auto.plt" 
        ffmpeg -y -i "$video_out" -vframes 1 -ss 00:00:00 -q:v 2 "$captura_out" > /dev/null 2>&1
    done &
}

render_Prob_Func() {
    local data_dir="$1" out_dir="$2"
    local n_val="${3:-0}"
    local archivos=("Phi_Prob.dat")
    local y_labels=("Probabilidad |Phi|^2")
    cd "$data_dir"
    for i in "${!archivos[@]}"; do
        local video_out="$out_dir/simulacion_${archivos[$i]%.dat}.mp4"

        local captura_out="$out_dir/simulacion_${archivos[$i]%.dat}_captura.png" # Nombre para la captura

        gnuplot -e "archivo_entrada='${archivos[$i]}'; video_out='$video_out'; x_label='Posición (x)'; y_label='${y_labels[$i]}'; valor_n=$n_val" \
            "$DIR/Animation/Prob_Func.plt" 
        # Después de que gnuplot genere tu video original (ej: video_out.mp4), recodifícalo así:
        ffmpeg -y -i "$video_out" -vframes 1 -ss 00:00:00 -q:v 2 "$captura_out" > /dev/null 2>&1
    done &
}

render_temporales() {
    local data_dir="$1" out_dir="$2"
    local n_val="${3:-0}"
    local archivos_t=("ValorMediox.dat" "ValorMediop.dat" "Norma.dat")
    local y_labels_t=("Valor Medio <x>" "Valor Medio <p>" "Norma")
    local colores_t=("#e55555" "green" "purple")
    cd "$data_dir"
    for i in "${!archivos_t[@]}"; do
        local video_out="$out_dir/simulacion_${archivos_t[$i]%.dat}.png"
        limit_jobs
        gnuplot -e "archivo_entrada='${archivos_t[$i]}'; video_out='$video_out'; x_label_t='Tiempo (t)'; y_label_t='${y_labels_t[$i]}'; valor_n=$n_val; color_elegido='${colores_t[$i]}'" "$DIR/Animation/Temporal.plt" 
    done
}

render_Principio() {
    local data_dir="$1" out_dir="$2" 
    local n_val="${3:-0}"
    local archivos_t=("PrincIncertidumbre.dat")
    local y_labels_t=("Incertidumbre Δx * Δp")
    cd "$data_dir"
    for i in "${!archivos_t[@]}"; do
        local video_out="$out_dir/simulacion_${archivos_t[$i]%.dat}.png"
        limit_jobs
        gnuplot -e "archivo_entrada='${archivos_t[$i]}'; video_out='$video_out'; x_label_t='Tiempo (t)'; y_label_t='${y_labels_t[$i]}'; valor_n=$n_val" \
            "$DIR/Animation/Principio_Incerti.plt" &
    done
}

render_Hamiltoniano() {
    local data_dir="$1" out_dir="$2" 
    local n_val="${3:-0}"
    local archivos_t=("Hamiltoniano.dat")
    local y_labels_t=("Hamiltoniano")
    cd "$data_dir"
    for i in "${!archivos_t[@]}"; do
        local video_out="$out_dir/simulacion_${archivos_t[$i]%.dat}.png"
        limit_jobs
        gnuplot -e "archivo_entrada='${archivos_t[$i]}'; video_out='$video_out'; x_label_t='Tiempo (t)'; y_label_t='${y_labels_t[$i]}'; valor_n=$n_val" \
            "$DIR/Animation/Hamiltoniano.plt" &
    done
}

render_HamiltonianoFunc() {
    local data_dir="$1" out_dir="$2" 
    local n_val="$3"
    local archivos_t=("Hamiltoniano.dat")
    local y_labels_t=("Hamiltoniano")
    cd "$data_dir"
    for i in "${!archivos_t[@]}"; do
        local video_out="$out_dir/simulacion_${archivos_t[$i]%.dat}.png"
        limit_jobs
        gnuplot -e "archivo_entrada='${archivos_t[$i]}'; video_out='$video_out'; x_label_t='Tiempo (t)'; y_label_t='${y_labels_t[$i]}'; valor_n=$n_val" "$DIR/Animation/HamiltonianoFunc.plt" &
    done
}

render_juntos() {
    local data_dir="$1" out_dir="$2"
    local n_val="${3:-0}"
    local captura_out="$out_dir/simulacion_Juntos_captura.png" # Nombre para la captura
    local video_out="$out_dir/simulacion_Juntos.mp4"


    cd "$data_dir"
    limit_jobs
    gnuplot -e "archivo_entrada='Juntos.dat'; video_out='$video_out'; x_label='Posición (x)'; y_label='Valor de Phi'; valor_n=$n_val" "$DIR/Animation/Juntos.plt" 
    ffmpeg -y -i "$video_out" -vframes 1 -ss 00:00:00 -q:v 2 "$captura_out" > /dev/null 2>&1
}

render_Clasicos() {
    local data_dir="$1" out_dir="$2"
    #local archivos_t=("Valor_x.dat" "Valor_p.dat" "Valor_E.dat" "Posicion.dat" "Momento.dat")
    #local y_labels_t=("Valor Medio <x>" "Valor Medio <p>" "Valor Medio <E>" "Posición (x) " "Momento (p)")

    local archivos_t=("Valor_E.dat" "Posicion.dat" "Momento.dat" "Error.dat")
    local y_labels_t=("Valor Medio <E>" "Posición (x) " "Momento (p)" "Error Relativo (%)")
    cd "$data_dir"
    for i in "${!archivos_t[@]}"; do
        local video_out="$out_dir/simulacion_cla_${archivos_t[$i]%.dat}.png"
        limit_jobs
        gnuplot -e "archivo_entrada='${archivos_t[$i]}'; video_out='$video_out'; x_label_t='Tiempo (t)'; y_label_t='${y_labels_t[$i]}'" "$DIR/Animation/Clasico.plt"
    done
}

render_ClasicoVSCuantico() {
    local data_dir="$1" out_dir="$2" data_dir_2="$3"
    local archivos_t=( "Posicion.dat" "Momento.dat")

    local archivos_t_2=( "$data_dir_2/ValorMediox.dat" "$data_dir_2/ValorMediop.dat")
    local y_labels_t=("Valor Medio <x>" "Valor Medio <p>")
    cd "$data_dir"
    for i in "${!archivos_t[@]}"; do
        local video_out="$out_dir/simulacion_clsvscua${archivos_t[$i]%.dat}.png"

        limit_jobs
        
        gnuplot -e "archivo_entrada='${archivos_t[$i]}'; archivo_entrada_2='${archivos_t_2[$i]}'; video_out='$video_out'; x_label_t='Tiempo (t)'; y_label_t='${y_labels_t[$i]}'" "$DIR/Animation/ClasicoVSCuantico.plt"
    done
    
}

combinar_imagenes_Valor_Medio() {
    local data_dir="$1" out_dir="$2"
    cd "$out_dir"
    
    # Asegúrate de que los nombres coinciden con la salida de tu gnuplot
    local img1="simulacion_ValorMediox.png"
    local img2="simulacion_ValorMediop.png"
    
    # Comprobar si existen antes de combinarlas
        # -append las junta verticalmente
        magick "$img1" "$img2"  -append "Resumen_Valor_Medio.png"
        echo "Imágenes combinadas en $out_dir/Resumen_Valor_Medio.png"
    
}

combinar_imagenes_Temporal() {
    local data_dir="$1" out_dir="$2"
    cd "$out_dir"
    
    # Asegúrate de que los nombres coinciden con la salida de tu gnuplot
    local img1="simulacion_Hamiltoniano.png"
    local img2="simulacion_PrincIncertidumbre.png"
    
    # Comprobar si existen antes de combinarlas
        magick "$img1" "$img2"  -append "Resumen_Temporal.png"
        echo "Imágenes combinadas en $out_dir/Resumen_Temporal.png"

}

# ─── Preparación ─────────────────────────────────────────────────────────────
T_PREP=$(date +%s%3N)
# Crear directorios base y subdirectorios para cada n
for n in "${VALORES_N_2[@]}"; do
    rm -rf "$DIR_DATOS_OUT/n_${n}" "$DIR_GIFS_SISTEMA/n_${n}"
done
for n in "${VALORES_N[@]}"; do
    mkdir -p "$DIR_DATOS_OUT/n_${n}" "$DIR_GIFS_SISTEMA/n_${n}"

    
    # Limpiamos datos anteriores si existen
    rm -f "$DIR_DATOS_OUT/n_${n}"/*.dat 
    rm -f "$DIR_GIFS_SISTEMA/n_${n}"/*.mp4 "$DIR_GIFS_SISTEMA/n_${n}"/*.png
done

# Creamos los directorios para Func y Clasico y limpiamos datos anteriores.
mkdir -p "$DIR_DATOS_OUT_2" "$DIR_GIFS_SISTEMA_2"

rm -f "$DIR_DATOS_OUT_2"/*.dat
rm -f "$DIR_GIFS_SISTEMA_2"/*.mp4 "$DIR_GIFS_SISTEMA_2"/*.png

rm -rf "$DIR_DATOS_OUT_3" "$DIR_GIFS_SISTEMA_3"
mkdir -p "$DIR_DATOS_OUT_3" "$DIR_GIFS_SISTEMA_3"

fase "Preparación de directorios" "$T_PREP"

# ─── Compilación en paralelo ─────────────────────────────────────────────────
T_COMP=$(date +%s%3N)
echo "[1/4] Compilando..."

gfortran -O3 -march=native -ffast-math "$DIR_SCRIPT"   -o "$DIR_EJECUTABLE"  &
pid_c1=$!
gfortran -O3 -march=native -ffast-math "$DIR_SCRIPT_2" -o "$DIR_EJECUTABLE_2" &
pid_c2=$!
gfortran -O3 -march=native -ffast-math "$DIR_SCRIPT_3" -o "$DIR_EJECUTABLE_3" &
pid_c3=$!

wait "$pid_c1" || { echo "Error compilando Auto.f90"; exit 1; }
wait "$pid_c2" || { echo "Error compilando Func.f90"; exit 1; }
wait "$pid_c3" || { echo "Error compilando Clasico.f90"; exit 1; }
fase "Compilación (ambos .f90 en paralelo)" "$T_COMP"

# ─── Simulaciones en paralelo ─────────────────────────────────────────────────
T_SIM=$(date +%s%3N)
echo "[2/4] Ejecutando simulaciones para n=(${VALORES_N[*]})..."

for n in "${VALORES_N[@]}"; do
    limit_jobs # Evita lanzar más simulaciones pesadas que núcleos disponibles
    
    # Se ejecutan pasándole el parámetro 'n' y su respectivo directorio de salida
    "$DIR_EJECUTABLE"   "$n" "$DIR_DATOS_OUT/n_${n}" &
done
    "$DIR_EJECUTABLE_2" "$n" "$DIR_DATOS_OUT_2"
    "$DIR_EJECUTABLE_3" "$DIR_DATOS_OUT_3"




wait
fase "Simulaciones Fortran" "$T_SIM"

# ─── Renderizado en paralelo ──────────────────────────────────────────────────
T_RENDER=$(date +%s%3N)
echo "[3/4] Renderizando vídeos y gráficas (N_JOBS=$N_JOBS)..."


# Aqui lo que haremos será ejecutar los scripts de renderizado para cada caso, vamos comentando y descomentando según lo que queramos renderizar.


# Temporal - Valores medios de x y p, y la norma.
# Espacial - La parte real e imaginaria de la función de onda.
# Juntos - La parte real e imaginaria de la función de onda en el mismo gráfico.
# Principio - El producto de las incertidumbres.
# Hamiltoniano - El valor del Hamiltoniano a lo largo del tiempo.
# Prob_Auto - La evolución de la probabilidad a lo largo del tiempo para el caso Auto.
# Prob_Func - La evolución de la probabilidad a lo largo del tiempo para el caso Func.



for n in "${VALORES_N[@]}"; do
    # Rutas para Auto
    DIR_DATOS_N_AUTO="$DIR_DATOS_OUT/n_${n}"
    DIR_GIFS_N_AUTO="$DIR_GIFS_SISTEMA/n_${n}"
    
    #render_espaciales   "$DIR_DATOS_N_AUTO" "$DIR_GIFS_N_AUTO" "$n"
    render_Prob_Auto    "$DIR_DATOS_N_AUTO" "$DIR_GIFS_N_AUTO" "$n"
    render_temporales   "$DIR_DATOS_N_AUTO" "$DIR_GIFS_N_AUTO" "$n"
    render_juntos       "$DIR_DATOS_N_AUTO" "$DIR_GIFS_N_AUTO" "$n"
    render_Principio    "$DIR_DATOS_N_AUTO" "$DIR_GIFS_N_AUTO" "$n"
    render_Hamiltoniano "$DIR_DATOS_N_AUTO" "$DIR_GIFS_N_AUTO" "$n"

done

for n in "${VALORES_N[@]}"; do
    DIR_DATOS_N_AUTO="$DIR_DATOS_OUT/n_${n}"
    DIR_GIFS_N_AUTO="$DIR_GIFS_SISTEMA/n_${n}"
    combinar_imagenes_Valor_Medio "$DIR_DATOS_N_AUTO" "$DIR_GIFS_N_AUTO"
    combinar_imagenes_Temporal "$DIR_DATOS_N_AUTO" "$DIR_GIFS_N_AUTO"
done

# Los espaciales no hacen falta, se hacen en juntos
#render_espaciales "$DIR_DATOS_OUT_2" "$DIR_GIFS_SISTEMA_2" "0"
render_Prob_Func     "$DIR_DATOS_OUT_2" "$DIR_GIFS_SISTEMA_2" "0"
render_temporales "$DIR_DATOS_OUT_2" "$DIR_GIFS_SISTEMA_2" "0"
render_juntos     "$DIR_DATOS_OUT_2" "$DIR_GIFS_SISTEMA_2" "0"
render_Principio  "$DIR_DATOS_OUT_2" "$DIR_GIFS_SISTEMA_2"  "0"
render_HamiltonianoFunc  "$DIR_DATOS_OUT_2" "$DIR_GIFS_SISTEMA_2"   "0"

combinar_imagenes_Valor_Medio "$DIR_DATOS_OUT_2" "$DIR_GIFS_SISTEMA_2"
combinar_imagenes_Temporal "$DIR_DATOS_OUT_2" "$DIR_GIFS_SISTEMA_2"

render_Clasicos "$DIR_DATOS_OUT_3" "$DIR_GIFS_SISTEMA_3"
render_ClasicoVSCuantico "$DIR_DATOS_OUT_3" "$DIR_GIFS_SISTEMA_3" "$DIR_DATOS_OUT_2"

wait
fase "Renderizado de vídeos y gráficas" "$T_RENDER"

# ─── Resumen final ────────────────────────────────────────────────────────────
T_TOTAL_FIN=$(date +%s%3N)
echo ""
echo "====================================="
echo " RESUMEN DE TIEMPOS"
echo "====================================="
echo "  Tiempo total: $(fmt_tiempo $(( T_TOTAL_FIN - T_TOTAL_INICIO )))"
echo "====================================="
echo "¡Proceso finalizado con éxito!"