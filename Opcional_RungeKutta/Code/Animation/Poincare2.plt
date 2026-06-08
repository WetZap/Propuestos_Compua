set terminal pngcairo size 800,600 background "#ffffff" enhanced font "Sans,12"
set xlabel x_label
set ylabel y_label
set grid
unset key

# 1. Crear arreglos numéricos para los límites de X
array xmin[5] = [0.0,-8.71,-9.1, -9.1,18.0]
array xmax[5] = [0.05,-8.64,-4.0, 0.0,25.0]

# 2. Crear el arreglo de nombres de salida (sin la extensión en video_out_list)
array video_out_list[5]
video_out_list[1] = video_out."_1.png"
video_out_list[2] = video_out."_2.png"
video_out_list[3] = video_out."_3.png"
video_out_list[4] = video_out."_4.png"
video_out_list[5] = video_out."_5.png"

# 3. Bucle usando la sintaxis 'do for'
do for [j=1:5] {
    set output video_out_list[j]

    # Rango de color ajustado de 0 a N_archivos-1 (porque los hilos empiezan en 0)
    set cbrange [0:N_archivos-1]
    unset colorbox
    print sprintf("Generando %s con rango x [%g:%g]", video_out_list[j], xmin[j], xmax[j])

    set xrange [xmin[j]:xmax[j]]
    #set xrange [*:*]
    
    # ATENCIÓN: El bucle de lectura de archivos empieza en 0 y termina en N_archivos - 1
    # porque los hilos en OpenMP son 0, 1, 2...
    plot for [i=0:(N_archivos-1)] sprintf("%s%d.bin", ruta, i) binary format='%double%double' using 1:2 every 100 with points pointsize 0.5 linecolor palette cb i
}