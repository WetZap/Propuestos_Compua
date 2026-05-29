# 1. Analizamos el archivo
stats archivo_entrada using 1:2 nooutput

# 2. Configuración estética
set terminal pngcairo size 800,600 background "#ffffff" enhanced font "Sans,12"
set output video_out

set xlabel x_label_t
set ylabel y_label_t
set grid

# 3. Rangos
rango_y = STATS_max_y - STATS_min_y
print sprintf("Rango Y: %f", rango_y)
print sprintf("Archivo de entrada: %s", archivo_entrada)

if ((rango_y*100) < 1.0 || (rango_y == 0.0)) { margen_y = 0.5 }
else { margen_y = rango_y * 0.1 }
    


set xrange [STATS_min_x : STATS_max_x]
set yrange [STATS_min_y - margen_y : STATS_max_y + margen_y]


# 4. Gráfica estática completa
plot archivo_entrada using 1:2 with lines linewidth 2 linecolor rgb color_elegido title "Evolución"

unset output