# 1. Analizamos el archivo
stats archivo_entrada using 1:2 nooutput

# 2. Configuración estética
set terminal pngcairo size 800,600 background "#ffffff" enhanced font "Sans,12"
set output video_out

set xlabel x_label_t
set ylabel y_label_t
set grid
# 2.5 Cálculo del valor teórico 
omega = 800.0
Hamiltoniano_teorico =  (2 * valor_n + 1) * omega / 2.0

print sprintf("Valor teórico del Hamiltoniano: %f", Hamiltoniano_teorico)

# 3. Rangos: Ajustamos para incluir tanto el archivo como el valor teórico
min_total_y = (STATS_min_y < Hamiltoniano_teorico) ? STATS_min_y : Hamiltoniano_teorico
max_total_y = (STATS_max_y > Hamiltoniano_teorico) ? STATS_max_y : Hamiltoniano_teorico

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
# Dibujamos primero la evolución y luego el teórico con línea discontinua para que se distingan si se solapan
plot archivo_entrada using 1:2 with lines linewidth 2 linecolor rgb "purple" title "Evolución", \
     Hamiltoniano_teorico with lines linewidth 3 dashtype 2 linecolor rgb "#02006c" title "Teórico"

unset output