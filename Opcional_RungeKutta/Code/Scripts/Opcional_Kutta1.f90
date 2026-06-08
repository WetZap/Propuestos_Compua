program RungeKuta_1
   use omp_lib ! IMPORTANTE: Incluir módulo OpenMP
   implicit none

   ! Declaración de variables globales
   real*8 :: t, A, B, K, raiz_AB
   real*8 :: m_1, m_2, l_1, l_2, g, pi, ajuste_fin, h, limite_tiempo, Energia
   real*8 :: theta_1, theta_2, omega_1, omega_2

   real*8 :: k_1_t1, k_1_t2, k_1_o1, k_1_o2
   real*8 :: k_2_t1, k_2_t2, k_2_o1, k_2_o2
   real*8 :: k_3_t1, k_3_t2, k_3_o1, k_3_o2
   real*8 :: k_4_t1, k_4_t2, k_4_o1, k_4_o2

   integer :: i, cont, j, limite_i, limite_j
   real*8, dimension(2, 50000) :: poincare_buffer
   integer :: num_poincare

   character(len=256) :: nombre_archivo_thread, dir_out
   integer :: thread_id, file_unit

   ! Variables para precalcular (Loop Hoisting)
   real*8 :: dos_pi, inv_dos_pi, un_sexto, un_medio

   ! Leer directorio de salida desde los argumentos
   if (command_argument_count() >= 1) then
      call get_command_argument(1, dir_out)
   else
      dir_out = "Data/Tarea1"
   end if

   ! Inicializamos las variables globales comunes (No cambian durante la ejecución)
   m_1 = 3.d0
   m_2 = 1.d0
   pi = 4.d0 * datan(1.d0)
   l_1 = 2.d0
   l_2 = 1.d0
   g = 1.d0
   ajuste_fin = 0.01d0

   limite_i = 50
   limite_j = 300

   Energia = -9.d0 + 0.01d0

   ! --- PRECÁLCULOS MATEMÁTICOS PARA ACELERAR EL BUCLE ---
   dos_pi = 2.d0 * pi
   inv_dos_pi = 1.d0 / dos_pi
   un_sexto = 1.d0 / 6.d0
   un_medio = 0.5d0

   ! ================================================================
   ! ZONA PARALELA OPENMP
   ! ================================================================
   !$omp parallel private(thread_id, file_unit, nombre_archivo_thread, &
   !$omp t, A, B, K, raiz_AB, theta_1, theta_2, omega_1, omega_2, &
   !$omp k_1_t1, k_1_t2, k_1_o1, k_1_o2, k_2_t1, k_2_t2, k_2_o1, k_2_o2, &
   !$omp k_3_t1, k_3_t2, k_3_o1, k_3_o2, k_4_t1, k_4_t2, k_4_o1, k_4_o2, &
   !$omp num_poincare, poincare_buffer, cont, h, limite_tiempo)

   ! 1. Identificar qué hilo de ejecución soy
   thread_id = omp_get_thread_num()
   file_unit = 100 + thread_id ! Unidad única (Ej. 100, 101, 102...)

   ! 2. Abrir UN SOLO ARCHIVO BINARIO por hilo para toda la ejecución
   write(nombre_archivo_thread, '(A,I0,A)') trim(dir_out)//'/Poincare/Thread_', thread_id, '.bin'
   open(unit=file_unit, file=trim(nombre_archivo_thread), status='unknown', form='unformatted', access='stream')

   ! Usamos GUIDED para evitar cuellos de botella por los 'cycle'
   !$omp do collapse(2) schedule(guided)
   do i = 1, limite_i
      do j = 1, limite_j

         omega_1 = 0.d0
         theta_2 = -pi + dos_pi * (real(i,8) / real(limite_i,8))
         omega_2 = -7.d0 + 14.d0 * (real(j,8) / real(limite_j,8))

         ! Sustituimos potencias por multiplicaciones
         A = m_2 * l_1 * l_2 * omega_1 * omega_2 * cos(theta_2) - (m_1 + m_2) * g * l_1
         B = m_2 * l_1 * l_2 * omega_1 * omega_2 * sin(theta_2)
         K = Energia  - 0.5d0 * (m_1 + m_2) * (l_1*l_1) * (omega_1*omega_1) - &
            0.5d0 * m_2 * (l_2*l_2) * (omega_2*omega_2) + m_2 * g * l_2 * cos(theta_2)

         ! Evitamos calcular la raíz dos veces
         raiz_AB = sqrt(A*A + B*B)
         if (abs(K / raiz_AB) > 1.d0) then
            cycle
         end if

         theta_1 = datan2(B,A) + acos(K / raiz_AB)

         t = 0.d0
         limite_tiempo = 300.d0
         h = 0.001d0
         cont = 0
         num_poincare = 0

         do while(t < limite_tiempo)
            ! Verificación de Sección de Poincaré
            if (omega_1 > 0.d0 .and. abs(theta_1) < 1.d-4) then
               num_poincare = num_poincare + 1
               poincare_buffer(1, num_poincare) = theta_2
               poincare_buffer(2, num_poincare) = omega_2

               ! Vaciado seguro si se llena el buffer de esta trayectoria
               if (num_poincare >= 50000) then
                  write(file_unit) poincare_buffer(:, 1:50000)
                  num_poincare = 0
               end if
            end if

            ! Paso 1
            call derivadas(theta_1, theta_2, omega_1, omega_2, k_1_t1, k_1_t2, k_1_o1, k_1_o2,m_1,m_2, l_1, l_2, g)
            k_1_t1 = h * k_1_t1; k_1_t2 = h * k_1_t2; k_1_o1 = h * k_1_o1; k_1_o2 = h * k_1_o2

            ! Paso 2
            call derivadas(theta_1 + k_1_t1*un_medio, theta_2 + k_1_t2*un_medio, omega_1 + k_1_o1*un_medio, omega_2 + k_1_o2*un_medio, k_2_t1, k_2_t2, k_2_o1, k_2_o2, m_1,m_2, l_1, l_2, g)
            k_2_t1 = h * k_2_t1; k_2_t2 = h * k_2_t2; k_2_o1 = h * k_2_o1; k_2_o2 = h * k_2_o2

            ! Paso 3
            call derivadas(theta_1 + k_2_t1*un_medio, theta_2 + k_2_t2*un_medio, omega_1 + k_2_o1*un_medio, omega_2 + k_2_o2*un_medio, k_3_t1, k_3_t2, k_3_o1, k_3_o2, m_1,m_2, l_1, l_2, g)
            k_3_t1 = h * k_3_t1; k_3_t2 = h * k_3_t2; k_3_o1 = h * k_3_o1; k_3_o2 = h * k_3_o2

            ! Paso 4
            call derivadas(theta_1 + k_3_t1, theta_2 + k_3_t2, omega_1 + k_3_o1, omega_2 + k_3_o2, k_4_t1, k_4_t2, k_4_o1, k_4_o2, m_1,m_2, l_1, l_2, g)
            k_4_t1 = h * k_4_t1; k_4_t2 = h * k_4_t2; k_4_o1 = h * k_4_o1; k_4_o2 = h * k_4_o2

            theta_1 = theta_1 + un_sexto * (k_1_t1 + 2.d0*k_2_t1 + 2.d0*k_3_t1 + k_4_t1)
            theta_2 = theta_2 + un_sexto * (k_1_t2 + 2.d0*k_2_t2 + 2.d0*k_3_t2 + k_4_t2)
            omega_1 = omega_1 + un_sexto * (k_1_o1 + 2.d0*k_2_o1 + 2.d0*k_3_o1 + k_4_o1)
            omega_2 = omega_2 + un_sexto * (k_1_o2 + 2.d0*k_2_o2 + 2.d0*k_3_o2 + k_4_o2)

            ! Normalización de ángulos súper rápida
            theta_1 = theta_1 - dos_pi * anint(theta_1 * inv_dos_pi)
            theta_2 = theta_2 - dos_pi * anint(theta_2 * inv_dos_pi)

            t = t + h
         end do

         ! Escribimos el buffer residual de esa partícula AL ARCHIVO ESPECÍFICO DEL HILO
         if (num_poincare > 0) then
            write(file_unit) poincare_buffer(:, 1:num_poincare)
         end if

      end do
   end do
   !$omp end do

   ! 3. Cerrar el archivo del hilo antes de terminar la zona paralela
   close(file_unit)
   !$omp end parallel
   ! ================================================================

contains

   ! Subrutina completamente vectorizable y libre de divisiones
   pure subroutine derivadas(th_1, th_2, omg_1, omg_2, d_th1, d_th2, d_om1, d_om2, m_1,m_2, l_1, l_2, g)
      real*8, intent(in)  :: th_1, th_2, omg_1, omg_2
      real*8, intent(in)  :: m_1, m_2, l_1, l_2, g
      real*8, intent(out) :: d_th1, d_th2, d_om1, d_om2

      real*8 :: delta, s, c, den, m12, o1, o2

      delta = th_1 - th_2
      s   = sin(delta)
      c   = cos(delta)
      den = m_1 + m_2*s*s        ! m1 + m2 sin^2(delta)
      m12 = m_1 + m_2
      o1  = omg_1*omg_1
      o2  = omg_2*omg_2

      d_th1 = omg_1
      d_th2 = omg_2

      d_om1 = ( -m_2*l_1*s*c*o1 - m_2*l_2*s*o2 - g*m12*sin(th_1) + g*m_2*c*sin(th_2) ) / (l_1*den)
      d_om2 = (  m12*l_1*s*o1   + g*m12*c*sin(th_1) + m_2*l_2*c*s*o2 - g*m12*sin(th_2) ) / (l_2*den)
   end subroutine derivadas

end program RungeKuta_1
