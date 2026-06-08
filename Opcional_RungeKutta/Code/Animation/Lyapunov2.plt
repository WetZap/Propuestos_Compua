# 1. Inicializar variables para los límites con valores extremos
min_y = 1e38
max_y = -1e38
min_x = 1e38
max_x = -1e38
# Función para extraer el ID de la energía (j) y la iteración (i) del nombre del archivo
# Asume formato: RungeKutta_Lyapunov{i}Energia{j}.dat
get_i(name) = int(substr(name, strstrt(name, "Lyapunov") + 8, strstrt(name, "Energia") - 1))
get_j(name) = int(substr(name, strstrt(name, "Energia") + 7, strstrt(name, ".bin") - 1))
get_color_index(name) = get_j(name)*10 + get_i(name)

# Iterar sobre todos los archivos para encontrar los límites globales
do for [archivo in list_archi] {
    stats archivo binary format='%double%double' using 1:2 nooutput
    if (STATS_min_y < min_y) { min_y = STATS_min_y }
    if (STATS_max_y > max_y) { max_y = STATS_max_y }
    if (STATS_min_x < min_x) { min_x = STATS_min_x }
    if (STATS_max_x > max_x) { max_x = STATS_max_x }
}

# 2. Configuración del terminal
set terminal pngcairo size 800,600 background "#ffffff" enhanced font "Sans,12" truecolor
set xlabel x_label font "Sans,14"
set ylabel y_label font "Sans,14"
set grid

# Leyenda arriba a la derecha (puedes desactivarla si hay demasiadas líneas)
#set key top right
unset key
# 3. Rangos dinámicos globales
set xrange [0 : 1000] # Ajusta el rango de tiempo según tus datos
set yrange [*:*] # Ajusta el rango de energía según tus datos

set output img_out 

# 4. Definición de Paletas de Colores por Energía
# Energía 1 (j=1): Tonos de Azul
set style line 11 lc rgb "#00008B" lw 3 # Dark Blue
set style line 12 lc rgb "#0000CD" lw 3 # Medium Blue
set style line 13 lc rgb "#4169E1" lw 3 # Royal Blue
set style line 14 lc rgb "#1E90FF" lw 3 # Dodger Blue
set style line 15 lc rgb "#00BFFF" lw 3 # Deep Sky Blue

# Energía 2 (j=2): Tonos de Verde
set style line 21 lc rgb "#006400" lw 3 # Dark Green
set style line 22 lc rgb "#228B22" lw 3 # Forest Green
set style line 23 lc rgb "#32CD32" lw 3 # Lime Green
set style line 24 lc rgb "#3CB371" lw 3 # Medium Sea Green
set style line 25 lc rgb "#8FBC8F" lw 3 # Dark Sea Green

# Energía 3 (j=3): Tonos de Naranja/Rojo
set style line 31 lc rgb "#8B0000" lw 1.5 # Dark Red
set style line 32 lc rgb "#B22222" lw 1.5 # Firebrick
set style line 33 lc rgb "#FF4500" lw 1.5 # Orange Red
set style line 34 lc rgb "#FF8C00" lw 1.5 # Dark Orange
set style line 35 lc rgb "#FFA500" lw 1.5 # Orange

# Energía 4 (j=4): Tonos de Morado/Magenta
set style line 41 lc rgb "#4B0082" lw 1.5 # Indigo
set style line 42 lc rgb "#800080" lw 1.5 # Purple
set style line 43 lc rgb "#8B008B" lw 1.5 # Dark Magenta
set style line 44 lc rgb "#9932CC" lw 1.5 # Dark Orchid
set style line 45 lc rgb "#BA55D3" lw 1.5 # Medium Orchid



plot for [archivo in list_archi] archivo binary format='%double%double' using 1:2 #with lines ls #get_color_index(archivo) notitle
    #NaN with lines ls 15 lw 3 title "E_1 = -8.99", \
    #NaN with lines ls 25 lw 3 title "E_2 = -6.99", \
    #NaN with lines ls 35 lw 3 title "E_3 = 6.99", \
    #NaN with lines ls 45 lw 3 title "E_4 = 8.99"