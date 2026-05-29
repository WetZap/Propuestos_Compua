# 1. Analizamos el archivo
stats archivo_entrada using 1:2 nooutput

# 2. Configuración estética
set terminal pngcairo size 800,600 background "#ffffff" enhanced font "Sans,12"
set output video_out

set xlabel x_label_t
set ylabel y_label_t
set grid
Principio_Incertidumbre = (valor_n + 0.5)

# 3. Rangos: Ajustamos para incluir tanto el archivo como el valor teórico
min_total_y = (STATS_min_y < Principio_Incertidumbre) ? STATS_min_y : Principio_Incertidumbre
max_total_y = (STATS_max_y > Principio_Incertidumbre) ? STATS_max_y : Principio_Incertidumbre

rango_y = max_total_y - min_total_y

if (rango_y == 0) {
    margen_y = abs(max_total_y) * 0.1
    if (margen_y == 0) { margen_y = 0.1 }
} else {
    margen_y = rango_y * 0.05
}

set xrange [STATS_min_x : STATS_max_x]
set yrange [min_total_y - margen_y : max_total_y + margen_y]

# 4. Gráfica estática completa
plot archivo_entrada using 1:2 with lines linewidth 2 linecolor rgb "red" title "Evolución", \
     Principio_Incertidumbre with lines linewidth 2 linetype 2 linecolor rgb "blue" title "Teórico"    

unset output