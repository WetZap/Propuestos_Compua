# 1. Inicializar variables para los límites con valores extremos
min_y = 1e38
max_y = -1e38
min_x = 1e38
max_x = -1e38

# Iterar sobre todos los archivos para encontrar los límites globales
do for [archivo in list_archi] {
    stats archivo using 1:2 nooutput
    if (STATS_min_y < min_y) { min_y = STATS_min_y }
    if (STATS_max_y > max_y) { max_y = STATS_max_y }
    if (STATS_min_x < min_x) { min_x = STATS_min_x }
    if (STATS_max_x > max_x) { max_x = STATS_max_x }
}

# 2. Configuración del terminal (quitamos set output de aquí)
set terminal pngcairo size 800,600 background "#ffffff" enhanced font "Sans,12" truecolor
set xlabel x_label
set ylabel y_label
set grid
unset key


# 3. Rangos dinámicos globales (fijos para todas las gráficas generadas)
set xrange [min_x*1.2: max_x * 1.2]
set yrange [min_y*1.3: max_y * 1.3]

# 4. Generar múltiples gráficas (Base vs Resto)
n_archivos = words(list_archi)
base_out = video_out[1:strlen(video_out)-4]

# --- PROCESAR EL ARCHIVO BASE (SIEMPRE ES EL ÍNDICE 1) ---
arch_base = word(list_archi, 1)
idx_base = arch_base[strlen(prefijo)+1 : strlen(arch_base)-4]
file_ini_base = "RungeKutta_Inicial_" . idx_base . ".dat"

# Extraer el valor inicial del archivo base
cmd_base = sprintf("awk 'NR==1{print $%d}' %s", col_theta, file_ini_base)
val_base = system(cmd_base)
tit_base = sprintf("{/Symbol q}_%d(0) = %.6f", col_theta, val_base + 0)

# Bucle desde el archivo 2 hasta el final
do for [i=2:n_archivos] {
    
    # El número de gráfica será 1, 2, 3... (corresponde a i-1)
    num_grafica = i - 1
    set output sprintf("%s_%d.png", base_out, num_grafica)
    
    # --- PROCESAR EL ARCHIVO SECUNDARIO (ÍNDICE i) ---
    arch_sec = word(list_archi, i)
    idx_sec = arch_sec[strlen(prefijo)+1 : strlen(arch_sec)-4]
    file_ini_sec = "RungeKutta_Inicial_" . idx_sec . ".dat"
    
    # Extraer el valor inicial del archivo secundario
    cmd_sec = sprintf("awk 'NR==1{print $%d}' %s", col_theta, file_ini_sec)
    val_sec = system(cmd_sec)
    tit_sec = sprintf("{/Symbol q}_%d(0) = %.6f", col_theta, val_sec + 0)
    
    # Ploteamos el archivo base (siempre el mismo) vs el archivo secundario actual
    plot arch_base using 1:2 with dots lc 1 title tit_base, \
         arch_sec using 1:2 with dots lc 2 title tit_sec
}

# Cerrar el proceso
print "¡Múltiples gráficas renderizadas (" . (n_archivos-1) . " imágenes generadas) comparando siempre con el inicial!"