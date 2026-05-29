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
print "Rango en y: ", rango_y

if ((rango_y*1000) < 1.0 || (rango_y == 0.0)) {
    margen_y = abs(STATS_max_y) * 0.5
    if (margen_y == 0) { margen_y = 0.1 }
} else {
    margen_y = rango_y * 0.05
}
if (archivo_entrada eq "Valor_E.dat") {
    set xrange [STATS_min_x : STATS_max_x]
    set yrange [99 : 101]

}else{set xrange [STATS_min_x : STATS_max_x]
set yrange [STATS_min_y - margen_y : STATS_max_y + margen_y]}
# 4. Gráfica estática completa
plot archivo_entrada using 1:2 with points linecolor rgb "red" title "Evolución-Clásica", archivo_entrada using 1:3 with points pointtype 5  linecolor rgb "blue" title "Evolución-Cuántica"

unset output