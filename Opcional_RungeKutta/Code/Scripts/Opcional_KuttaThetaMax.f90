program RungeKuta
   use omp_lib
   implicit none

   real*8 :: t, A, B, K
   real*8 :: m_1, m_2, l_1, l_2, g, pi, ajuste_fin, h, limite_tiempo, Energia
   real*8 :: theta_1, theta_2, omega_1, omega_2, fraccion, theta_2_max, theta_2_old, omega_2_old

   real*8 :: k_1_t1, k_1_t2, k_1_o1, k_1_o2
   real*8 :: k_2_t1, k_2_t2, k_2_o1, k_2_o2
   real*8 :: k_3_t1, k_3_t2, k_3_o1, k_3_o2
   real*8 :: k_4_t1, k_4_t2, k_4_o1, k_4_o2

   integer :: i, cont, limite_i , num_poincare, cruce,n_cruces
   real*8, dimension(2, 100000) :: poincare_buffer
   integer :: un ! Unidad del hilo
   integer :: j
   integer :: thread_id

   real*8 :: dos_pi, inv_dos_pi, un_sexto, un_medio
   real*8 :: m2_l1, m2_l2, ge_m2_2, ge_m1_2, ge_m1m2_2, m1m2_l1_2, l1_2, l2_2
   real*8 :: inv_l1_2, inv_l2_2, ge_m1m2_2_sum, Vmin


   character(len=256) ::  dir_out, nombre_archivo_total

   ! Leer directorio de salida
   if (command_argument_count() >= 1) then
      call get_command_argument(1, dir_out)
   else
      dir_out = "Data/Tarea1"
   end if

   ! Inicializamos variables globales
   m_1 = 3.d0
   m_2 = 1.d0
   pi = 4.d0 * datan(1.d0)
   dos_pi = 2.d0 * pi
   inv_dos_pi = 1.d0 / dos_pi
   l_1 = 2.d0
   l_2 = 1.d0
   g = 1.d0

   m2_l1 = m_2 * l_1
   m2_l2 = m_2 * l_2
   ge_m2_2 = 2.d0 * g * m_2
   ge_m1_2 = 2.d0 * g * m_1
   ge_m1m2_2 = 2.d0 * g * (m_1 + m_2)
   m1m2_l1_2 = 2.d0 * (m_1 + m_2) * l_1
   inv_l1_2 = -1.d0 / (l_1 * 2.d0)
   inv_l2_2 = 1.d0 / (l_2 * 2.d0)


   un_sexto = 1.d0 / 6.d0
   un_medio = 0.5d0
   ajuste_fin = 0.01d0
   limite_i = 3500

   Vmin = -(m_1 + m_2) * g * l_1 - m_2 * g * l_2


   ! ================================================================
   ! ZONA PARALELA - ARCHIVOS POR HILO, NO POR ENERGÍA
   ! ================================================================
   !$OMP PARALLEL PRIVATE(thread_id, un, nombre_archivo_total, i, j, Energia, K, A, cont, &
   !$OMP theta_1, theta_2, omega_1, omega_2, t, limite_tiempo, h, &
   !$OMP theta_2_old, omega_2_old, fraccion, theta_2_max, num_poincare, cruce, &
   !$OMP k_1_t1, k_1_t2, k_1_o1, k_1_o2, k_2_t1, k_2_t2, k_2_o1, k_2_o2, &
   !$OMP k_3_t1, k_3_t2, k_3_o1, k_3_o2, k_4_t1, k_4_t2, k_4_o1, k_4_o2, &
   !$OMP poincare_buffer,n_cruces)

   ! Identificar hilo y abrir UN SOLO ARCHIVO
   thread_id = omp_get_thread_num()
   un = 200 + thread_id
   write(nombre_archivo_total, '(A,I0,A)') trim(dir_out)//'/Thread_Tmax_', thread_id, '.bin'
   open(unit=un, file=trim(nombre_archivo_total), status='unknown', form='unformatted', access='stream')

   num_poincare = 1

   !$OMP DO SCHEDULE(NONMONOTONIC:DYNAMIC, 1)
   do i = 0, limite_i

      Energia = 0.d0+ i * ajuste_fin

      cruce = 0
      t = 0.d0
      limite_tiempo = 5000.d0
      h = 0.001d0
      n_cruces = 0

      theta_1 = 0.0d0
      theta_2 = 0.d0
      omega_2 = 0.d0

      K = -(m_1 + m_2) * g * l_1 * cos(theta_1) - m_2 * g * l_2 * cos(theta_2)
      A = Energia - K - 0.5d0 * m_2 * l_2*l_2 * omega_2*omega_2
      if (A < 0.d0) cycle
      omega_1 = sqrt( 2.d0*A / ((m_1 + m_2)*l_1*l_1) )
      do while(t < limite_tiempo)

         theta_2_old = theta_2
         omega_2_old = omega_2

         call derivadas(theta_1, theta_2, omega_1, omega_2, k_1_t1, k_1_t2, k_1_o1, k_1_o2, m_1,m_2, l_1, l_2, g)
         k_1_t1 = h * k_1_t1; k_1_t2 = h * k_1_t2; k_1_o1 = h * k_1_o1; k_1_o2 = h * k_1_o2

         call derivadas(theta_1 + k_1_t1*un_medio, theta_2 + k_1_t2*un_medio, omega_1 + k_1_o1*un_medio, omega_2 + k_1_o2*un_medio, k_2_t1, k_2_t2, k_2_o1, k_2_o2, m_1,m_2, l_1, l_2, g)
         k_2_t1 = h * k_2_t1; k_2_t2 = h * k_2_t2; k_2_o1 = h * k_2_o1; k_2_o2 = h * k_2_o2

         call derivadas(theta_1 + k_2_t1*un_medio, theta_2 + k_2_t2*un_medio, omega_1 + k_2_o1*un_medio, omega_2 + k_2_o2*un_medio, k_3_t1, k_3_t2, k_3_o1, k_3_o2, m_1,m_2, l_1, l_2, g)
         k_3_t1 = h * k_3_t1; k_3_t2 = h * k_3_t2; k_3_o1 = h * k_3_o1; k_3_o2 = h * k_3_o2

         call derivadas(theta_1 + k_3_t1, theta_2 + k_3_t2, omega_1 + k_3_o1, omega_2 + k_3_o2, k_4_t1, k_4_t2, k_4_o1, k_4_o2, m_1,m_2, l_1, l_2, g)
         k_4_t1 = h * k_4_t1; k_4_t2 = h * k_4_t2; k_4_o1 = h * k_4_o1; k_4_o2 = h * k_4_o2

         theta_1 = theta_1 + un_sexto * (k_1_t1 + 2.d0*k_2_t1 + 2.d0*k_3_t1 + k_4_t1)
         theta_2 = theta_2 + un_sexto * (k_1_t2 + 2.d0*k_2_t2 + 2.d0*k_3_t2 + k_4_t2)
         omega_1 = omega_1 + un_sexto * (k_1_o1 + 2.d0*k_2_o1 + 2.d0*k_3_o1 + k_4_o1)
         omega_2 = omega_2 + un_sexto * (k_1_o2 + 2.d0*k_2_o2 + 2.d0*k_3_o2 + k_4_o2)

         theta_1 = theta_1 - dos_pi * anint(theta_1 * inv_dos_pi)
         theta_2 = theta_2 - dos_pi * anint(theta_2 * inv_dos_pi)
         t = t + h

         ! EVALUACIÓN Y GUARDADO
         !        if ((omega_2_old > 0.d0 .and. omega_2 <= 0.d0).or.(omega_2_old < 0.d0 .and. omega_2 >= 0.d0)) then
         !           cruce = cruce + 1
         !           fraccion = omega_2_old / (omega_2_old - omega_2)

         !           if (abs(theta_2 - theta_2_old) > pi) then
         !              if (theta_2_old < 0.d0) theta_2_old = theta_2_old + dos_pi
         !              if (theta_2 < 0.d0) theta_2 = theta_2 + dos_pi
         !           end if
         !           theta_2_max = theta_2_old + fraccion * (theta_2 - theta_2_old)
         !           theta_2_max = theta_2_max - dos_pi * anint(theta_2_max / dos_pi)
         !           if (cruce > 100) then
         !              poincare_buffer(1, num_poincare) = Energia
         !              poincare_buffer(2, num_poincare) = theta_2_max
         !              num_poincare = num_poincare + 1

         ! Vaciar cuando el búfer esté lleno
         !              if (num_poincare > 100000) then
         !                 write(un) poincare_buffer(:, 1:100000)
         !                 num_poincare = 1
         !              end if !Cerro de escritura por búfer lleno
         !           end if !Cerro de evaluación de cruce
         !           if (cruce > 200) exit

         !       end if! Cerro de evaluación de omega_2

         ! Detectar AMBOS retornos de theta_2 (seccion completa omega_2 = 0)
         cruce = 0
         if (omega_2_old > 0.d0 .and. omega_2 <= 0.d0) then
            cruce = 1                              ! maximo
         else if (omega_2_old < 0.d0 .and. omega_2 >= 0.d0) then
            cruce = 1                              ! minimo
         end if

         if (cruce == 1) then
            fraccion = omega_2_old / (omega_2_old - omega_2)
            if (abs(theta_2 - theta_2_old) > pi) then
               if (theta_2_old < 0.d0) theta_2_old = theta_2_old + dos_pi
               if (theta_2 < 0.d0)     theta_2     = theta_2     + dos_pi
            end if
            theta_2_max = theta_2_old + fraccion * (theta_2 - theta_2_old)
            theta_2_max = theta_2_max - dos_pi * anint(theta_2_max / dos_pi)

            n_cruces = n_cruces + 1                ! contador propio de esta trayectoria
            if (n_cruces > 20) then                ! descarta transitorio
               poincare_buffer(1, num_poincare) = Energia
               poincare_buffer(2, num_poincare) = theta_2_max
               num_poincare = num_poincare + 1
               if (num_poincare > 100000) then
                  write(un) poincare_buffer(:, 1:100000)
                  num_poincare = 1
               end if
            end if
            if (n_cruces > 130) exit               ! ya tengo 110 puntos: corta
         end if
      end do ! Cerro de integración temporal

   end do ! Cerro de energías
   !$OMP END DO

   ! Escribir los datos que hayan quedado
   if (num_poincare > 1) then
      write(un) poincare_buffer(:, 1:num_poincare-1)
   end if

   close(un)
   !$OMP END PARALLEL

contains

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

end program RungeKuta
