program RungeKuta
   implicit none
   real*8 :: t, A, B, K
   real*8 :: m_1, m_2, l_1, l_2, g, pi, ajuste_fin, h, limite_tiempo, Energia
   real*8 :: theta_1, theta_2, omega_1, omega_2, fraccion, theta_2_max, theta_2_old, omega_2_old, omega_2_punto
   real*8 :: theta_1_sombra, theta_2_sombra, omega_1_sombra, omega_2_sombra

   real*8 :: k_1_t1, k_1_t2, k_1_o1, k_1_o2
   real*8 :: k_2_t1, k_2_t2, k_2_o1, k_2_o2
   real*8 :: k_3_t1, k_3_t2, k_3_o1, k_3_o2
   real*8 :: k_4_t1, k_4_t2, k_4_o1, k_4_o2

   real*8 :: k_1_t1_sombra, k_1_t2_sombra, k_1_o1_sombra, k_1_o2_sombra
   real*8 :: k_2_t1_sombra, k_2_t2_sombra, k_2_o1_sombra, k_2_o2_sombra
   real*8 :: k_3_t1_sombra, k_3_t2_sombra, k_3_o1_sombra, k_3_o2_sombra
   real*8 :: k_4_t1_sombra, k_4_t2_sombra, k_4_o1_sombra, k_4_o2_sombra

   real*8 :: Energia_bucle

   real*8 :: d_0 , d_t, suma_log


   integer :: i, cont, limite_i
   integer :: j,num

   real*8 :: dos_pi, inv_dos_pi, un_sexto, un_medio


   character(len=256) ::  dir_out, nombre_archivo_total,valor_j,valor_i,nombre_energia

   ! Leer directorio de salida desde los argumentos
   if (command_argument_count() >= 1) then
      call get_command_argument(1, dir_out)
   else
      dir_out = "Data/Tarea1" ! Ruta por defecto
   end if


   ! Inicializamos las variables globales

   m_1 = 3.d0
   m_2 = 1.d0


   pi = 4.d0 * datan(1.d0)

   dos_pi = 2.d0 * pi
   inv_dos_pi = 1.d0 / dos_pi

   l_1 = 2.d0
   l_2 = 1.d0



   g = 1.d0

   un_sexto = 1.d0 / 6.d0
   un_medio = 0.5d0


   limite_i = 5




   do j = 1, 4
      if (j == 1) then
         Energia = -9.d0 + 0.01d0
      else if (j == 2) then
         Energia = -7.d0 - 0.01d0
      else if (j == 3) then
         Energia = 7.d0 - 0.01d0
      else if (j == 4) then
         Energia = 9.d0 - 0.01d0
      end if

      do i = 1, limite_i
         write(valor_j, '(I10)') j
         write(valor_i, '(I10)') i
         nombre_archivo_total = trim(dir_out)//'/RungeKutta_Lyapunov'//trim(adjustl(valor_i))//'Energia'//trim(adjustl(valor_j))//'.bin'
         nombre_energia = trim(dir_out)//'/Lyapunov_Energia'//trim(adjustl(valor_j))//'_'//trim(adjustl(valor_i))//'.bin'
         open(10, file=nombre_archivo_total,status='unknown',form='unformatted',access='stream')
         open(11, file=nombre_energia,status='unknown',form='unformatted',access='stream')


         do cont = 1, 2

            t = 0.d0
            limite_tiempo = 10000.d0
            h = 0.001d0
            suma_log = 0.d0
            num = 0

            if (j == 1 )then
               ! FIJAMOS theta_1, theta_2 y omega_2
               theta_1 = 0.d0
               theta_2 = 0.d0
               omega_2 = 0.d0

               theta_2_sombra = theta_2 + (dble(i)/dble(limite_i)) * 1.d-8
               omega_2_sombra = omega_2
               theta_1_sombra = theta_1
            else if (j == 2 )then
               ! FIJAMOS theta_1, theta_2 y omega_2
               theta_1 = 0.d0
               theta_2 = 0.d0
               omega_2 = 0.d0

               theta_2_sombra = theta_2 + (dble(i)/dble(limite_i)) * 1.d-8
               omega_2_sombra = omega_2
               theta_1_sombra = theta_1

            else if  (j == 3 )then

               ! FIJAMOS theta_1, theta_2 y omega_2
               theta_1 = 0.d0
               theta_2 = 0.d0
               omega_2 = 0.d0

               theta_2_sombra = theta_2 + (dble(i)/dble(limite_i)) * 1.d-8
               omega_2_sombra = omega_2
               theta_1_sombra = theta_1
            else if (j == 4 )then
               ! FIJAMOS theta_1, theta_2 y omega_2
               theta_1 = 0.d0
               theta_2 = 0.d0
               omega_2 = 0.d0

               theta_2_sombra = theta_2 + (dble(i)/dble(limite_i)) * 1.d-8
               omega_2_sombra = omega_2
               theta_1_sombra = theta_1
            end if








            K = -(m_1 + m_2) * g * l_1 * cos(theta_1) - m_2 * g * l_2 * cos(theta_2)

            A = Energia - K - 0.5d0 * m_2 * l_2*l_2 * omega_2*omega_2
            if (A < 0.d0) cycle ! Si A es negativo, no hay solución real para omega_1, así que saltamos esta configuración

            if (cont ==1) then
               ! Para la primera mitad de las simulaciones, usamos la ra��z positiva
               omega_1 = sqrt( (2.d0 * A) / ((m_1 + m_2) * l_1*l_1) )
            else
               ! Para la segunda mitad, usamos la raíz negativa para explorar la otra rama de soluciones
               omega_1 = -sqrt( (2.d0 * A) / ((m_1 + m_2) * l_1*l_1) )
            end if

            K = -(m_1 + m_2) * g * l_1 * cos(theta_1_sombra) - m_2 * g * l_2 * cos(theta_2_sombra)

            A = Energia - K - 0.5d0 * m_2 * l_2*l_2 * omega_2_sombra*omega_2_sombra
            if (A < 0.d0) cycle ! Si A es negativo, no hay solución real para omega_1, así que saltamos esta configuración
            if (cont ==1) then
               ! Para la primera mitad de las simulaciones, usamos la raíz positiva
               omega_1_sombra = sqrt( (2.d0 * A) / ((m_1 + m_2) * l_1*l_1) )
            else
               ! Para la segunda mitad, usamos la raíz negativa para explorar la otra rama de soluciones
               omega_1_sombra = -sqrt( (2.d0 * A) / ((m_1 + m_2) * l_1*l_1) )
            end if

            d_0 = sqrt( (theta_1 - theta_1_sombra)**2 + (theta_2 - theta_2_sombra)**2 + (omega_1 - omega_1_sombra)**2 + (omega_2 - omega_2_sombra)**2 )

            do while(t < limite_tiempo)
               if (num >= 100) then
                  ! 1. Calculas la distancia final de este tramo
                  d_t = sqrt( (theta_1 - theta_1_sombra)**2 + (theta_2 - theta_2_sombra)**2 + &
                     (omega_1 - omega_1_sombra)**2 + (omega_2 - omega_2_sombra)**2 )

                  ! 2. Acumulas el logaritmo
                  if (d_t > 1.d-16) then
                     suma_log = suma_log + dlog(d_t / d_0)
                  else
                     suma_log = suma_log + dlog(1.d-16 / d_0)
                  end if

                  !  3. ESCRIBES el valor en el archivo.
                  write(10) t, suma_log / t

                  ! 4. Reinicias el contador de pasos
                  num = 0

                  ! 5. Teletransporte SEGURO
                  if (d_t > 1.d-16) then
                     fraccion = d_0 / d_t
                  else
                     fraccion = 1.d0
                  end if

                  theta_1_sombra = theta_1 + (theta_1_sombra - theta_1) * fraccion
                  theta_2_sombra = theta_2 + (theta_2_sombra - theta_2) * fraccion
                  omega_1_sombra = omega_1 + (omega_1_sombra - omega_1) * fraccion
                  omega_2_sombra = omega_2 + (omega_2_sombra - omega_2) * fraccion

                  Energia_bucle = -(m_1 + m_2) * g * l_1 * cos(theta_1) - m_2 * g * l_2 * cos(theta_2) + 0.5d0 * (m_1 + m_2) * l_1*l_1 * omega_1*omega_1 + 0.5d0 * m_2 * l_2*l_2 * omega_2*omega_2 + m_2 * l_1*l_2 * omega_1*omega_2*cos(theta_1 - theta_2)
                  write(11)t, abs(Energia-Energia_bucle)
               end if

               num = num + 1


               ! 2. PASOS DE RUNGE-KUTTA

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

               ! Normalización de ángulos
               !theta_1 = theta_1 - dos_pi * anint(theta_1 * inv_dos_pi)
               !theta_2 = theta_2 - dos_pi * anint(theta_2 * inv_dos_pi)


               ! 2. PASOS DE RUNGE-KUTTA para la sombra
               call derivadas(theta_1_sombra, theta_2_sombra, omega_1_sombra, omega_2_sombra, k_1_t1_sombra, k_1_t2_sombra, k_1_o1_sombra, k_1_o2_sombra, m_1,m_2, l_1, l_2, g)
               k_1_t1_sombra = h * k_1_t1_sombra; k_1_t2_sombra = h * k_1_t2_sombra; k_1_o1_sombra = h * k_1_o1_sombra; k_1_o2_sombra = h * k_1_o2_sombra

               call derivadas(theta_1_sombra + k_1_t1_sombra*un_medio, theta_2_sombra + k_1_t2_sombra*un_medio, omega_1_sombra + k_1_o1_sombra*un_medio, omega_2_sombra + k_1_o2_sombra*un_medio, k_2_t1_sombra, k_2_t2_sombra, k_2_o1_sombra, k_2_o2_sombra, m_1,m_2, l_1, l_2, g)
               k_2_t1_sombra = h * k_2_t1_sombra; k_2_t2_sombra = h * k_2_t2_sombra; k_2_o1_sombra = h * k_2_o1_sombra; k_2_o2_sombra = h * k_2_o2_sombra

               call derivadas(theta_1_sombra + k_2_t1_sombra*un_medio, theta_2_sombra + k_2_t2_sombra*un_medio, omega_1_sombra + k_2_o1_sombra*un_medio, omega_2_sombra + k_2_o2_sombra*un_medio, k_3_t1_sombra, k_3_t2_sombra, k_3_o1_sombra, k_3_o2_sombra, m_1,m_2, l_1, l_2, g)
               k_3_t1_sombra = h * k_3_t1_sombra; k_3_t2_sombra = h * k_3_t2_sombra; k_3_o1_sombra = h * k_3_o1_sombra; k_3_o2_sombra = h * k_3_o2_sombra

               call derivadas(theta_1_sombra + k_3_t1_sombra, theta_2_sombra + k_3_t2_sombra, omega_1_sombra + k_3_o1_sombra, omega_2_sombra + k_3_o2_sombra, k_4_t1_sombra, k_4_t2_sombra, k_4_o1_sombra, k_4_o2_sombra, m_1,m_2, l_1, l_2, g)
               k_4_t1_sombra = h * k_4_t1_sombra; k_4_t2_sombra = h * k_4_t2_sombra; k_4_o1_sombra = h * k_4_o1_sombra; k_4_o2_sombra = h * k_4_o2_sombra

               theta_1_sombra = theta_1_sombra + un_sexto * (k_1_t1_sombra + 2.d0*k_2_t1_sombra + 2.d0*k_3_t1_sombra + k_4_t1_sombra)
               theta_2_sombra = theta_2_sombra + un_sexto * (k_1_t2_sombra + 2.d0*k_2_t2_sombra + 2.d0*k_3_t2_sombra + k_4_t2_sombra)
               omega_1_sombra = omega_1_sombra + un_sexto * (k_1_o1_sombra + 2.d0*k_2_o1_sombra + 2.d0*k_3_o1_sombra + k_4_o1_sombra)
               omega_2_sombra = omega_2_sombra + un_sexto * (k_1_o2_sombra + 2.d0*k_2_o2_sombra + 2.d0*k_3_o2_sombra + k_4_o2_sombra)

               !theta_1_sombra = theta_1_sombra - dos_pi * anint(theta_1_sombra * inv_dos_pi)
               !theta_2_sombra = theta_2_sombra - dos_pi * anint(theta_2_sombra * inv_dos_pi)


               t = t + h


            end do ! fin bucle while (tiempo)

         end do ! fin bucle cont
         close(10)
         close(11)

      end do ! fin bucle i
   end do ! fin bucle j

contains
   ! Subrutina actualizada para recibir parámetros como argumentos,
   ! necesario para que sea segura en un entorno paralelo (Thread-safe)

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
