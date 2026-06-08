set terminal pngcairo size 1000,800 background "#ffffff" enhanced font "Sans,14"
set output video_out

set xlabel x_label font "Sans,18"
set ylabel y_label font "Sans,18"
set title "Seccion de Poincare" font "Sans-Bold,20"

set grid
unset key

# Configurar el rango de colores (de 0 a N-1 hilos)
set cbrange [0:N_archivos-1]
unset colorbox # Oculta la barra de leyenda de colores

# Bucle plot: iteramos desde 0 hasta N_archivos-1 (OpenMP empieza en el hilo 0)
# 'pointtype 7' hace puntos redondos sólidos, que quedan genial en Poincaré
plot for [i=0:N_archivos-1] sprintf("%s%d.bin", ruta, i) \
    binary format='%double%double' using 1:2 \
    with points pointtype 7 pointsize 0.3 linecolor palette cb i