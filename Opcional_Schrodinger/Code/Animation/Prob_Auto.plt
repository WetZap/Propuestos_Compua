stats archivo_entrada using 1:2 nooutput

set terminal pngcairo size 800,600 background "#ffffff" enhanced font "Sans,12"
set xlabel x_label
set ylabel y_label
set grid




num_frames = STATS_blocks
set samples 1500

comando_ffmpeg = sprintf("| ffmpeg -y -f image2pipe -vcodec png -framerate 20 -i - -c:v libx264 -preset fast -crf 18 -pix_fmt yuv420p %s", video_out)
set output comando_ffmpeg

omega = 200.0
masa  = 0.5
pi    = 4.0*atan(1.0)
hbar  = 1.0
L = 1.0
S = 1000.0

if (!exists("valor_n")) valor_n = 3.0


#32800

Ener = (valor_n + 0.5) * omega
x_c  = sqrt((2.0*Ener)/(masa*omega**2))
x0 = 0.5
# Probabilidad clásica en posición para el oscilador armónico
y_teo(x) = (abs(x-x0) < x_c) ? 1.0/(pi*sqrt(x_c**2 - (x-x0)**2 )) : 1/0

set xrange [STATS_min_x : STATS_max_x]
set yrange [STATS_min_y : STATS_max_y * 1.1]

do for [a=0:500-1] {
    plot archivo_entrada index a using 1:2 with lines lw 2 lc rgb "blue" title sprintf("|Phi|^2 numérica (n=%g)", valor_n), \
    y_teo(x) with lines lw 2 lc rgb "red" title "Probabilidad clásica"
}

set output
print "¡Vídeo renderizado directamente sin PNG temporales!"

