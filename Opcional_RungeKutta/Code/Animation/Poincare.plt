
set terminal pngcairo size 800,600 background "#ffffff" enhanced font "Sans,12"
set output video_out

set xlabel x_label
set ylabel y_label
set grid
unset key
# Configurar el rango de colores (de 1 al total de archivos)
#N_archivos = 20

set cbrange [1:N_archivos]
unset colorbox # Oculta la barra de leyenda de colores si no la quieres en la imagen

#set xrange [-10:-4]
#set yrange [-4:4]


# Bucle plot que lee dinámicamente y asigna color gradualmente
plot for [i=1:N_archivos] sprintf("%s%d.bin", ruta, i) binary format='%double%double' using 1:2 with points pointsize 0.5 linecolor palette cb i