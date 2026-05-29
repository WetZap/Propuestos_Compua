module hermite_poly
   implicit none
contains

   ! Función para calcular Hn(x) utilizando la relación de recurrencia
   real*8 function hermite(n, x)
      integer, intent(in) :: n
      real*8, intent(in) :: x
      real*8 :: h_prev, h_curr, h_next
      integer :: i

      if (n < 0) then
         hermite = 0.0
         return
      else if (n == 0) then
         hermite = 1.0
         return
      else if (n == 1) then
         hermite = 2.0 * x
         return
      end if

      ! Inicialización
      h_prev = 1.0  ! H0
      h_curr = 2.0 * x ! H1

      ! Bucle para generar Hn(x) a partir de la recurrencia
      do i = 1, n - 1
         h_next = 2.0 * x * h_curr - 2.0 * i * h_prev
         h_prev = h_curr
         h_curr = h_next
      end do

      hermite = h_curr
   end function hermite

end module hermite_poly


program Resolucion
   use hermite_poly
   implicit none
   real*8 delta_x, delta_t, Longitud, omega, pi, valor_promedio_x, valor_promedio_p,norma, norma_inicial,hamiltoniano, incert_x, incert_p, valor_promedio_x_2,omega_2, valor_alpha, valor_promedio_p_2
   real*8, dimension(:), allocatable :: V, x_discreto, tiempo_discreto
   complex*16, dimension(:), allocatable :: alpha, gammia
   complex*16, dimension(:), allocatable :: beta, q, phi, phi_aux,dphi_dx, dphi_dx_2
   integer i, j, N, S, corte, valor_n
   character(len=10) :: arg_n
   character(len=256) :: dir_out

   ! Inicializacion de variables
   S = 1000
   Longitud = 1.d0
   delta_x = Longitud / real(S, 8)
   delta_t = 0.0000001d0
   N = 10000
   pi = 4.d0 * datan(1.d0)
   norma = 0.d0
   corte = 10 ! Escribe 1 frame cada 5 iteraciones


   ! Leer valor_n desde los argumentos de la terminal
   if (command_argument_count() >= 1) then
      call get_command_argument(1, arg_n)
      read(arg_n, *) valor_n
   else
      valor_n = 3 ! Valor por defecto si no se le pasa nada
   end if

   ! Leer directorio de salida desde los argumentos
   if (command_argument_count() >= 2) then
      call get_command_argument(2, dir_out)
   else
      dir_out = "Data/Auto" ! Ruta por defecto
   end if

   omega =  delta_t / (delta_x**2)
   omega_2 = 1500.d0


   allocate(V(0:S), q(0:S), phi(0:S), phi_aux(0:S), x_discreto(0:S), dphi_dx(0:S), dphi_dx_2(0:S))
   allocate(alpha(0:S-1), beta(0:S-1), gammia(0:S-1), tiempo_discreto(0:N-1))

   ! Inicializacion de arrays (vectorizado)
   x_discreto = [(i * delta_x, i=0, S)]
   tiempo_discreto = [(i * delta_t, i=0, N-1)]

   q(0) = (0.d0, 0.d0)
   q(S) = (0.d0, 0.d0)

   do i = 0, S
      V(i) = (omega_2**2 / 4.d0) * (x_discreto(i) - 0.5)**2
   end do ! Potencial armónico

   gammia(S-1) = 1.d0/(-2.d0 + (2.d0*(0.d0,1.d0)/omega - V(S-1)*delta_x**2))
   alpha(S-1) = (0.d0, 0.d0)

   do i = S-2, 0, -1
      alpha(i) = - gammia(i+1)
      gammia(i) = 1.d0/(-2.d0 + (2.d0*(0.d0,1.d0)/omega - V(i)*delta_x**2 + alpha(i)))
   end do

   ! Funcion de onda inicial

   valor_alpha = sqrt(omega_2/2.d0)
   do i = 1, S-1
      phi(i) = hermite(valor_n, valor_alpha*(x_discreto(i) - 0.5)) * exp(-(valor_alpha**2 * (x_discreto(i) - 0.5)**2)/2)

   end do

   !---------------------------------------------------
   ! Normalización de la funcion de onda
   !---------------------------------------------------
   norma_inicial = 0.d0 ! Inicializamos la variable a 0
   ! Calculamos la norma de la función de onda
   norma_inicial = sum(abs(phi)**2 * delta_x)
   ! Aplicamos la normalización a cada punto del espacio
   do i = 1, S-1
      phi(i) = phi(i) / sqrt(norma_inicial)
   end do
   ! Aplicamos condiciones de frontera
   phi(0) = (0.d0, 0.d0)
   phi(S) = (0.d0, 0.d0)

   ! Abrimos archivos
   open(10, file=trim(dir_out)//"/Phi_Fase.dat", status="replace")
   open(11, file=trim(dir_out)//"/Phi_Abs.dat", status="replace")
   open(12, file=trim(dir_out)//"/Phi_Prob.dat", status="replace")
   open(13, file=trim(dir_out)//"/ValorMediox.dat", status="replace")
   open(14, file=trim(dir_out)//"/ValorMediop.dat", status="replace")
   open(15, file=trim(dir_out)//"/Norma.dat", status="replace")
   open(16, file=trim(dir_out)//"/Juntos.dat", status="replace")
   open(17, file=trim(dir_out)//"/Hamiltoniano.dat", status="replace")
   open(18, file=trim(dir_out)//"/PrincIncertidumbre.dat", status="replace")
   open(19, file=trim(dir_out)//"/Tiempo.dat", status="replace")


   do i = 0, N-1
      ! Escribimos datos a disco SOLO cada 'corte' iteraciones
      if (mod(i, corte) == 0) then

         norma = sum(abs(phi)**2) * delta_x


         !  -----------------------------------
         ! Cálculo de valores promedio de x y p.
         !  -----------------------------------

         ! Valor de x
         valor_promedio_x = sum(x_discreto * (abs(phi)**2)) * delta_x

         ! Valor de p

         do j = 1, S-1 ! Calculamos la derivada de phi usando diferencias centrales
            dphi_dx(j) = (phi(j+1) - phi(j)) / (delta_x)
         end do

         valor_promedio_p = real(sum(conjg(phi(1:S-1)) *(0.d0,-1.d0) * dphi_dx(1:S-1)) * delta_x, 8)


         !--------------------------------------------------------------------
         ! Cálculo de la incertidumbre de x y p, así como el valor medio de H.
         !--------------------------------------------------------------------

         ! Calculo de <H>
         hamiltoniano = 0.d0

         !Calculamos la segunda derivada de phi usando diferencias centrales
         do j = 1, S-1 !
            dphi_dx_2(j) = (phi(j+1) + phi(j-1) - 2*phi(j)) / (delta_x**2)
         end do
         ! Calculamos <H> usando la expresión discretizada.
         hamiltoniano = real(sum(conjg(phi(1:S-1)) * (-1.d0,0.d0) * dphi_dx_2(1:S-1))&
         &*delta_x + sum( V(1:S-1) * abs(phi(1:S-1))**2) * delta_x, 8)



         ! Calculo de la incertidumbre de x y p

         ! Calculo de <x^2> y <p^2>
         valor_promedio_x_2 = sum(x_discreto**2 * (abs(phi)**2)) * delta_x

         valor_promedio_p_2 = real(sum(conjg(phi(1:S-1))* (-1.d0,0.d0) * dphi_dx_2(1:S-1)) * delta_x, 8)

         ! Delta x Delta p sqrt(<x^2> - <x>^2) * sqrt(<p^2> - <p>^2)
         incert_p = sqrt(valor_promedio_p_2 - valor_promedio_p**2)
         incert_x = sqrt(valor_promedio_x_2 - valor_promedio_x**2)


         do j = 0, S
            ! Usamos formatos explicitos para escribir mas rapido que el asterisco (*)
            write(10,'(2ES15.6)') x_discreto(j), aimag(phi(j))
            write(11,'(2ES15.6)') x_discreto(j), real(phi(j),8)
            write(12,'(2ES15.6)') x_discreto(j), abs(phi(j))**2
            write(16,'(3ES15.6)') x_discreto(j), real(phi(j),8), aimag(phi(j))
         end do

         write(10,*) ; write(10,*)
         write(11,*) ; write(11,*)
         write(12,*) ; write(12,*)
         write(16,*) ; write(16,*)

         write(13,'(2ES15.6)') tiempo_discreto(i), valor_promedio_x
         write(14,'(2ES15.6)') tiempo_discreto(i), valor_promedio_p
         write(15,'(2ES15.6)') tiempo_discreto(i), norma
         write(17,'(2ES15.6)') tiempo_discreto(i), hamiltoniano
         write(18,'(2ES15.6)') tiempo_discreto(i), incert_x * incert_p
         write(19,'(ES15.6)') tiempo_discreto(i)
      end if

      ! Actualizacion temporal (Algoritmo de resolucion)
      beta(S-1) = (0.d0, 0.d0)
      do j = S-2, 0, -1
         beta(j) = gammia(j+1)*((4.d0*(0.d0,1.d0)*phi(j+1))/omega - beta(j+1))
      end do

      do j = 1, S-1
         q(j) = alpha(j-1)*q(j-1) + beta(j-1)
      end do

      do j = 1, S-1
         phi_aux(j) = q(j) - phi(j)
      end do

      phi = phi_aux
      phi(0) = (0.d0, 0.d0)
      phi(S) = (0.d0, 0.d0)
   end do

   close(10) ; close(11) ; close(12) ; close(13) ; close(14) ; close(15); close(16); close(17); close(18)

   deallocate(V, alpha, beta, q, phi, gammia, phi_aux, x_discreto, tiempo_discreto, dphi_dx, dphi_dx_2)

end program Resolucion

