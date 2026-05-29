program Mov_Armonico
   implicit none
   real*8 x,p,t ,paso, delta_t, x_medio, p_medio, Energia,fase
   real*8 masa, omega, x_0,x_eq ,Amplitud, Energia_ini, Periodo,pi,limite_tiempo
   integer i, N

   character(len=256) :: dir_out


   ! Inicializacion de variables
   pi = 4.d0 * datan(1.d0)
   masa = 0.5d0
   omega = 200.d0
   N = 100000
   x_0 = 0.5d0
   x_eq = 0.5d0
   !Energia_ini = 9.999938E+01 ! x= 0,5 sigma = 1/10
   Energia_ini = 1.475272E+02 ! x= 0,5 sigma = 1/16

   ! Energia_ini = 5.475272E+02 ! x= 0,3
   Periodo = 2.d0 * pi / omega
   limite_tiempo = 4.d0 * Periodo

   delta_t = Periodo / N

   dir_out = "Data/Clasico/" ! Ruta para el movimiento armónico clásico

   Energia_ini = Energia_ini
   print *, "Energía inicial: ", Energia_ini

   Amplitud = sqrt(2.d0 * (Energia_ini / masa)) / omega

   !Amplitud = x_eq - x_0

   print *, "Amplitud: ", Amplitud

   open(10, file=trim(dir_out)//"Valor_x.dat", status="unknown")
   open(11, file=trim(dir_out)//"Valor_p.dat", status="unknown")
   open(12, file=trim(dir_out)//"Valor_E.dat", status="unknown")

   open(13, file=trim(dir_out)//"Posicion.dat", status="unknown")
   open(14, file=trim(dir_out)//"Momento.dat", status="unknown")
   open(15, file=trim(dir_out)//"Error.dat", status="unknown")



   t = 0
   x_medio = 0.d0
   p_medio = 0.d0
   do while(t < limite_tiempo)
      x = -Amplitud * cos(omega * t) + x_eq
      p = masa * Amplitud * omega * sin(omega * t)

      x_medio = x_medio + x * delta_t
      p_medio = p_medio + p * delta_t

      Energia = 0.5d0 * masa * (Amplitud * omega * sin(omega * t))**2 + 0.5d0 * masa * (Amplitud * omega * cos(omega * t))**2
      write(12,*) t, Energia, Energia_ini;write(12,*);write(12,*)
      write(13,*) t, x;write(13,*);write(13,*)
      write(14,*) t, p;write(14,*);write(14,*)
      write(15,*) t, abs(Energia - Energia_ini)/Energia_ini*100;write(15,*);write(15,*)

      t = t + delta_t

   end do
   x_medio = (1.d0/limite_tiempo) * x_medio
   p_medio = (1.d0/limite_tiempo) * p_medio

   print *, "Valor medio de x: ", x_medio
   print *, "Valor medio de p: ", p_medio

! Calculo del valor medio

   t = 0.d0
   do i = 1, N
      write(10,*) t, x_medio;write(10,*);write(10,*)
      write(11,*) t, p_medio;write(11,*);write(11,*)
      t = t + delta_t
   end do

   close(10)
   close(11)
   close(12)
   close(13)
   close(14)
   close(15)
   print *, "El programa ha finalizado correctamente."
end program Mov_Armonico
