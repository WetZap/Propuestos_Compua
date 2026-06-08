# ============================================================
# 1. Mínimos y máximos GLOBALES (para la gráfica principal)
# ============================================================
min_y = 1e38
max_y = -1e38

do for [archivo in list_theta1] {
    stats archivo using 1:2 nooutput
    if (STATS_min_y < min_y) { min_y = STATS_min_y }
    if (STATS_max_y > max_y) { max_y = STATS_max_y }
}
do for [archivo in list_theta2] {
    stats archivo using 1:2 nooutput
    if (STATS_min_y < min_y) { min_y = STATS_min_y }
    if (STATS_max_y > max_y) { max_y = STATS_max_y }
}

# ============================================================
# 2. Rango del zoom con stats (funciona con notación científica)
# ============================================================
zoom_x_min = 4.5
zoom_x_max = 5.0
zoom_y_min =  1e38
zoom_y_max = -1e38

do for [archivo in list_theta2] {
    stats archivo using 1:($1>=zoom_x_min && $1<=zoom_x_max ? $2 : 1/0) \
        name "ZM" nooutput
    if (ZM_min_y < zoom_y_min) { zoom_y_min = ZM_min_y }
    if (ZM_max_y > zoom_y_max) { zoom_y_max = ZM_max_y }
}

margen = (zoom_y_max - zoom_y_min) * 0.15
zoom_y_min = zoom_y_min - margen
zoom_y_max = zoom_y_max + margen


# ============================================================
# 3. Terminal
# ============================================================
set terminal pngcairo size 1200,900 background "#ffffff" enhanced font "Sans,14" truecolor
set output video_out
set multiplot

# ============================================================
# 4. GRÁFICA PRINCIPAL
# ============================================================
set margins -1, -1, -1, -1   # -1 = automático en Gnuplot 6



set xlabel x_label
set ylabel y_label
set grid
set key top left samplen 3 spacing 1.5 font "Sans,14"

set xrange [0 : 10]
set yrange [min_y : max_y * 1.3]

# Posicion del inset
ins_x = 0.60
ins_y = 0.55
ins_w = 0.38
ins_h = 0.42


# -------------------------------------------------------
# FLECHAS CONECTORAS
# Arrow 1: esquina superior izquierda del zoom a esquina superior izquierda del inset
# Arrow 2: esquina inferior derecha del zoom a esquina inferior derecha del inset
# -------------------------------------------------------

# Recuadro en la zona a ampliar
set object 1 rectangle \
    from zoom_x_min, zoom_y_min to zoom_x_max, zoom_y_max \
    fs empty border lc rgb "black" lw 2 front
# Plotear gráfica principal
plot \
    word(list_theta1, 1) using 1:2 with lines lw 4 lc rgb '#1f77b4' title "{/Symbol q}_1", \
    word(list_theta2, 1) using 1:2 with lines lw 4 lc rgb '#ff7f0e' title "{/Symbol q}_2", \
    for [archivo in list_theta1] archivo using 1:2 with points pt 7 ps 0.2 lc rgb '#1f77b4' notitle, \
    for [archivo in list_theta2] archivo using 1:2 with points pt 7 ps 0.2 lc rgb '#ff7f0e' notitle

# ============================================================
# 5. GRÁFICA INSET
# ============================================================
unset xlabel
unset ylabel
unset grid
unset object 1
unset object 2
unset arrow 1
unset arrow 2
unset margins

set origin ins_x, ins_y
set size ins_w, ins_h



# Forzar que Gnuplot no herede el autoescalado de la gráfica principal
set autoscale fix

set xtics 0.1
set ytics auto
set format x "%.1f"
set format y "%.4f"
set border 15 lc rgb "black" lw 2




idx_f(f, pref) = f[strlen(pref)+1 : strlen(f)-4]
val_t2(f) = system(sprintf("awk 'NR==1{print $2}' RungeKutta_Inicial_%s.dat",idx_f(f, prefijo2))) + 0
tit_t2(f) = sprintf("{/Symbol q}_2(0) = %.4f", val_t2(f))

set key bottom right inside box opaque font "Sans,9" samplen 2 spacing 0.9



# CLAVE: repetir set yrange justo antes del plot
set yrange [zoom_y_min : zoom_y_max]
set xrange [zoom_x_min : zoom_x_max]




plot \
    for [i=1:words(list_theta1)] \
        word(list_theta1, i) using 1:2 \
        with points pt 7 ps 0.2 lc rgb "#c8c8c8" notitle, \
    for [i=1:words(list_theta2)] \
        word(list_theta2, i) using 1:2 \
        with points pt 7 ps 0.5 lc i \
        title tit_t2(word(list_theta2, i))


unset autoscale
unset multiplot
print "¡Imagen renderizada!"