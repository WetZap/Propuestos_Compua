program Funcion
   implicit none
   real*8 delta_x, delta_t, Longitud, omega, pi, valor_promedio_x, valor_promedio_p,norma, norma_inicial,hamiltoniano, incert_x, incert_p, valor_promedio_x_2,omega_2, x_0,sigma, valor_promedio_p_2
   real*8, dimension(:), allocatable :: V, x_discreto, tiempo_discreto
   complex*16, dimension(:), allocatable :: alpha, gammia
   complex*16, dimension(:), allocatable :: beta, q, phi, phi_aux,dphi_dx, dphi_dx_2
   integer i, j, N, S, corte

   ! Inicializacion de variables
   S = 1000
   Longitud = 1.d0
   delta_x = Longitud / real(S, 8)
   delta_t = 0.0001d0
   N = 10000
   pi = 4.d0 * datan(1.d0)
   norma = 0.d0

   corte = 5 ! Escribe 1 frame cada 5 iteraciones

   x_0 = 0.5d0
   sigma = 1.d0/16.d0

   omega =  delta_t / (delta_x**2)
   omega_2 = 200.d0

   allocate(V(0:S), q(0:S), phi(0:S), phi_aux(0:S), x_discreto(0:S), dphi_dx(0:S), dphi_dx_2(0:S))
   allocate(alpha(0:S-1), beta(0:S-1), gammia(0:S-1), tiempo_discreto(0:N-1))

   ! Inicializacion de arrays (vectorizado)
   x_discreto = [(i * delta_x, i=0, S)]
   tiempo_discreto = [(i * delta_t, i=0, N-1)]

   q(0) = (0.d0, 0.d0)
   q(S) = (0.d0, 0.d0)

   do i = 0, S
      V(i) = omega_2**2 / 4.d0 * (x_discreto(i) - 0.5)**2
   end do ! Potencial armónico

   gammia(S-1) = 1.d0/(-2.d0 + (2.d0*(0.d0,1.d0)/omega - V(S-1)*delta_x**2))
   alpha(S-1) = (0.d0, 0.d0)

   do i = S-2, 0, -1
      alpha(i) = - gammia(i+1)
      gammia(i) = 1.d0/(-2.d0 + (2.d0*(0.d0,1.d0)/omega - V(i)*delta_x**2 + alpha(i)))
   end do

   ! Funcion de onda inicial
   norma_inicial = 0.d0

   do i = 1, S-1
      phi(i) = exp((-(i * delta_x - x_0)**2 )/ (2.d0 * (sigma)**2))

   end do

   norma_inicial = 0.d0

   norma_inicial = sum(abs(phi)**2 * delta_x)
   do i = 1, S-1
      phi(i) = phi(i) / sqrt(norma_inicial) ! Normalizamos la funcion de onda
   end do

   phi(0) = (0.d0, 0.d0)
   phi(S) = (0.d0, 0.d0)

   ! Abrimos archivos
   open(10, file="Data/Func/Phi_Fase.dat", status="replace")
   open(11, file="Data/Func/Phi_Abs.dat", status="replace")
   open(12, file="Data/Func/Phi_Prob.dat", status="replace")
   open(13, file="Data/Func/ValorMediox.dat", status="replace")
   open(14, file="Data/Func/ValorMediop.dat", status="replace")
   open(15, file="Data/Func/Norma.dat", status="replace")
   open(16, file="Data/Func/Juntos.dat", status="replace")
   open(17, file="Data/Func/Hamiltoniano.dat", status="replace")
   open(18, file="Data/Func/PrincIncertidumbre.dat", status="replace")


   do i = 0, N-1
      ! Escribimos datos a disco SOLO cada 'corte' iteraciones
      if (mod(i, corte) == 0) then
         valor_promedio_x = sum(x_discreto * (abs(phi)**2)) * delta_x
         valor_promedio_x_2 = sum(x_discreto**2 * (abs(phi)**2)) * delta_x
         incert_x = sqrt(valor_promedio_x_2 - valor_promedio_x**2)
         norma = sum(abs(phi)**2) * delta_x


         valor_promedio_p = 0.d0
         hamiltoniano = 0.d0
         do j = 1, S-1
            dphi_dx(j) = (phi(j+1) - phi(j-1)) / (2*delta_x)
            dphi_dx_2(j) = (phi(j+1) + phi(j-1) - 2*phi(j)) / (delta_x**2)
         end do

         valor_promedio_p = real(sum(conjg(phi(1:S-1))  * (0.d0,-1.d0) * dphi_dx(1:S-1)) * delta_x, 8)
         valor_promedio_p_2 = real(sum(conjg(phi(1:S-1)) * (-1.d0,0.d0) * dphi_dx_2(1:S-1)) * delta_x, 8)

         hamiltoniano = real(sum(conjg(phi(1:S-1)) * (-1.d0,0.d0) * dphi_dx_2(1:S-1) + conjg(phi(1:S-1))*V(1:S-1) * phi(1:S-1)) * delta_x, 8)

         incert_p = sqrt(valor_promedio_p_2 - valor_promedio_p**2)


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

end program Funcion

