# 1. Encontrar los límites globales de y para todos los archivos
min_y = 1e38
max_y = -1e38



# Iterar sobre todos los archivos de theta 1 para encontrar los límites
do for [archivo in list_theta1] {
    stats archivo using 1:2 nooutput
    if (STATS_min_y < min_y) { min_y = STATS_min_y }
    if (STATS_max_y > max_y) { max_y = STATS_max_y }
}


# Iterar sobre todos los archivos de theta 2 para encontrar los límites
do for [archivo in list_theta2] {
    stats archivo using 1:2 nooutput
    if (STATS_min_y < min_y) { min_y = STATS_min_y }
    if (STATS_max_y > max_y) { max_y = STATS_max_y }
}


# 2. Configuración del terminal y estilos
set terminal pngcairo size 800,600 background "#ffffff" enhanced font "Sans,12"


set xlabel x_label
set ylabel y_label
set grid


unset key
array xmin[3] = [0, 0, 80]
array xmax[3] = [100,10, 100]
# 3. Rangos dinámicos globales
do for [j=1:3] {
set output video_out."_".j.".png"

set xrange [xmin[j]:xmax[j]]
set yrange [min_y*1.3: max_y * 1.3]


# 4. Plotear dibujando cada archivo con su propio nombre en la leyenda
plot for [archivo in list_theta1] archivo using 1:2 with points title "Theta1 (".archivo.")", \
     for [archivo in list_theta2] archivo using 1:2 with points title "Theta2 (".archivo.")"

}


# Cerrar el proceso
print "¡Múltiples archivos renderizados directamente!"