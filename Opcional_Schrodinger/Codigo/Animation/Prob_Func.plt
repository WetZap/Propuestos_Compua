# 1. Analizamos el archivo completo para los límites
stats archivo_entrada using 1:2 nooutput

set terminal pngcairo size 800,600 background "#ffffff" enhanced font "Sans,12"
set xlabel "Posición x"
set ylabel "Probabilidad | Phi |^2"
set grid

set xrange [STATS_min_x : STATS_max_x]
set yrange [0 : STATS_max_y * 1.1]

num_frames = 600

# 2. PRE-PROCESAMIENTO: Extraer la posición (X,Y) del máximo en cada frame
print "Extrayendo trayectoria del máximo..."

# 'set print' redirige todo lo que imprimamos a este archivo
set print "trayectoria_maximos.dat" 

do for [a=0:num_frames-1] {
    stats archivo_entrada index a using 1:2 nooutput
    print sprintf("%g %g", STATS_pos_max_y, STATS_max_y)
}

# 'set print' sin argumentos cierra el archivo y devuelve la salida a la terminal
set print 


# 3. Tubería directa a FFmpeg
comando_ffmpeg = sprintf("| ffmpeg -y -f image2pipe -vcodec png -framerate 20 -i - -c:v libx264 -preset fast -crf 18 -pix_fmt yuv420p %s", video_out)
set output comando_ffmpeg

omega = 200.0
x_0 = 0.5
delta_x = 0.001

V_teo(x) = (omega**2/4 * (x-x_0)**2) *delta_x
print "Generando frames de la animación..."

## 4. Bucle de dibujo
do for [a=0:500-1] {
    plot archivo_entrada index a using 1:2 with filledcurves y1=0 linecolor rgb "blue" fill solid 0.5 title sprintf("Frame %d", a), \
         "trayectoria_maximos.dat" every ::0::a using 1:2 with lines linewidth 3 linecolor rgb "red" title "Trayectoria Máximo" ,\

}
# 5. Cerrar el pipe
set output
print "¡Vídeo renderizado con la trayectoria del máximo!"