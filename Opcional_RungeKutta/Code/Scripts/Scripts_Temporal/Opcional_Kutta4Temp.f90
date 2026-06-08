program RungeKuta_Temporal
   implicit none
   real*8 :: t, h, limite_tiempo, A, B, K, raiz_AB
   real*8 :: m_1, m_2, l_1, l_2, g, pi
   real*8 :: theta_1, theta_2, omega_1, omega_2, Energia

   real*8 :: k_1_t1, k_1_t2, k_1_o1, k_1_o2
   real*8 :: k_2_t1, k_2_t2, k_2_o1, k_2_o2
   real*8 :: k_3_t1, k_3_t2, k_3_o1, k_3_o2
   real*8 :: k_4_t1, k_4_t2, k_4_o1, k_4_o2

   integer :: i, cont, buffer_idx

   character(len=256) :: valor_j, dir_out

   ! Variables para precalcular
   real*8 :: dos_pi, inv_dos_pi, un_sexto, un_medio
   real*8 :: m2_l1, m2_l2, m2_l2_2, ge_m2_2, ge_m1_2, ge_m1m2_2, m1m2_l1_2
   real*8 :: inv_l1_2, inv_l2_2

   ! Búferes en memoria para evitar el cuello de botella del disco
   integer, parameter :: BUFFER_SIZE = 100000
   real*8, dimension(BUFFER_SIZE) :: buf_t, buf_th1, buf_th2, buf_om1, buf_om2

   ! Leer directorio de salida desde los argumentos
   if (command_argument_count() >= 1) then
      call get_command_argument(1, dir_out)
   else
      dir_out = "Data/Tarea1/Temporal"
   end if

   m_1 = 3.d0
   m_2 = 1.d0
   pi = 4.d0 * datan(1.d0)
   l_1 = 2.d0
   l_2 = 1.d0
   g = 1.d0

   ! Precálculos matemáticos
   dos_pi = 2.d0 * pi
   inv_dos_pi = 1.d0 / dos_pi
   un_sexto = 1.d0 / 6.d0
   un_medio = 0.5d0

   m2_l1 = m_2 * l_1
   m2_l2 = m_2 * l_2
   m2_l2_2 = 2.d0 * m_2 * l_2
   ge_m2_2 = 2.d0 * g * m_2
   ge_m1_2 = 2.d0 * g * m_1
   ge_m1m2_2 = 2.d0 * g * (m_1 + m_2)
   m1m2_l1_2 = 2.d0 * (m_1 + m_2) * l_1
   inv_l1_2 = -1.d0 / (2.d0 * l_1)
   inv_l2_2 =  1.d0 / (2.d0 * l_2)

   Energia = 9.d0 - 0.01d0  ! Energia 1

   do i = 1, 10
      write(valor_j, '(I10)') i

      omega_1 = 0.01d0
      omega_2 = 0.d0
      theta_2 = pi + i * 0.001d0

      A = m_2 * l_1 * l_2 * omega_1 * omega_2 * cos(theta_2) - (m_1 + m_2) * g * l_1
      B = m_2 * l_1 * l_2 * omega_1 * omega_2 * sin(theta_2)
      K = Energia - 0.5d0 * (m_1 + m_2) * (l_1*l_1) * (omega_1*omega_1) - &
         0.5d0 * m_2 * (l_2*l_2) * (omega_2*omega_2) + m_2 * g * l_2 * cos(theta_2)

      raiz_AB = sqrt(A*A + B*B)
      if (abs(K / raiz_AB) > 1.d0) then
         print *, "Error: La energía dada no es suficiente para esa configuración."
         cycle
      end if

      theta_1 = datan2(B,A) + acos(K / raiz_AB)

      ! Normalización
      theta_1 = theta_1 - dos_pi * anint(theta_1 * inv_dos_pi)
      theta_2 = theta_2 - dos_pi * anint(theta_2 * inv_dos_pi)

      t = 0.d0
      limite_tiempo = 1000.d0
      h = 0.001d0
      cont = 0
      buffer_idx = 0

      open(10, file=trim(dir_out)//"/RungeKutta_theta1_"//trim(adjustl(valor_j))//".dat", status="unknown")
      open(11, file=trim(dir_out)//"/RungeKutta_theta2_"//trim(adjustl(valor_j))//".dat", status="unknown")
      open(14, file=trim(dir_out)//"/RungeKutta_Fase1_"//trim(adjustl(valor_j))//".dat", status="unknown")
      open(15, file=trim(dir_out)//"/RungeKutta_Fase2_"//trim(adjustl(valor_j))//".dat", status="unknown")
      open(16, file=trim(dir_out)//"/RungeKutta_Inicial_"//trim(adjustl(valor_j))//".dat", status="unknown")

      write(16,*) theta_1, theta_2, omega_1, omega_2
      close(16)

      do while(t < limite_tiempo)

         if (cont == 10) then
            buffer_idx = buffer_idx + 1
            buf_t(buffer_idx)   = t
            buf_th1(buffer_idx) = theta_1
            buf_th2(buffer_idx) = theta_2
            buf_om1(buffer_idx) = omega_1
            buf_om2(buffer_idx) = omega_2

            ! Si el búfer se llena, lo vaciamos todo junto al disco
            if (buffer_idx == BUFFER_SIZE) then
               call flush_buffers(buffer_idx)
            end if
            cont = 0
         end if
         cont = cont + 1

         ! Runge Kutta fusionado
         call derivadas(theta_1, theta_2, omega_1, omega_2, k_1_t1, k_1_t2, k_1_o1, k_1_o2, m_1, m_2, m2_l1, m2_l2, m2_l2_2, ge_m2_2, ge_m1_2, ge_m1m2_2, m1m2_l1_2, inv_l1_2, inv_l2_2)
         k_1_t1 = h * k_1_t1; k_1_t2 = h * k_1_t2; k_1_o1 = h * k_1_o1; k_1_o2 = h * k_1_o2

         call derivadas(theta_1 + k_1_t1*un_medio, theta_2 + k_1_t2*un_medio, omega_1 + k_1_o1*un_medio, omega_2 + k_1_o2*un_medio, k_2_t1, k_2_t2, k_2_o1, k_2_o2, m_1, m_2, m2_l1, m2_l2, m2_l2_2, ge_m2_2, ge_m1_2, ge_m1m2_2, m1m2_l1_2, inv_l1_2, inv_l2_2)
         k_2_t1 = h * k_2_t1; k_2_t2 = h * k_2_t2; k_2_o1 = h * k_2_o1; k_2_o2 = h * k_2_o2

         call derivadas(theta_1 + k_2_t1*un_medio, theta_2 + k_2_t2*un_medio, omega_1 + k_2_o1*un_medio, omega_2 + k_2_o2*un_medio, k_3_t1, k_3_t2, k_3_o1, k_3_o2, m_1, m_2, m2_l1, m2_l2, m2_l2_2, ge_m2_2, ge_m1_2, ge_m1m2_2, m1m2_l1_2, inv_l1_2, inv_l2_2)
         k_3_t1 = h * k_3_t1; k_3_t2 = h * k_3_t2; k_3_o1 = h * k_3_o1; k_3_o2 = h * k_3_o2

         call derivadas(theta_1 + k_3_t1, theta_2 + k_3_t2, omega_1 + k_3_o1, omega_2 + k_3_o2, k_4_t1, k_4_t2, k_4_o1, k_4_o2, m_1, m_2, m2_l1, m2_l2, m2_l2_2, ge_m2_2, ge_m1_2, ge_m1m2_2, m1m2_l1_2, inv_l1_2, inv_l2_2)
         k_4_t1 = h * k_4_t1; k_4_t2 = h * k_4_t2; k_4_o1 = h * k_4_o1; k_4_o2 = h * k_4_o2

         theta_1 = theta_1 + un_sexto * (k_1_t1 + 2.d0*k_2_t1 + 2.d0*k_3_t1 + k_4_t1)
         theta_2 = theta_2 + un_sexto * (k_1_t2 + 2.d0*k_2_t2 + 2.d0*k_3_t2 + k_4_t2)
         omega_1 = omega_1 + un_sexto * (k_1_o1 + 2.d0*k_2_o1 + 2.d0*k_3_o1 + k_4_o1)
         omega_2 = omega_2 + un_sexto * (k_1_o2 + 2.d0*k_2_o2 + 2.d0*k_3_o2 + k_4_o2)

         theta_1 = theta_1 - dos_pi * anint(theta_1 * inv_dos_pi)
         theta_2 = theta_2 - dos_pi * anint(theta_2 * inv_dos_pi)

         t = t + h
      end do

      ! Escribimos los datos residuales al terminar la trayectoria
      if (buffer_idx > 0) call flush_buffers(buffer_idx)

      close(10); close(11); close(14); close(15)
   end do

contains

   ! Subrutina interna que escribe el búfer de memoria a disco
   subroutine flush_buffers(idx)
      integer, intent(inout) :: idx
      integer :: n
      do n = 1, idx
         write(10,*) buf_t(n), buf_th1(n)
         write(11,*) buf_t(n), buf_th2(n)
         write(14,*) buf_th1(n), buf_om1(n)
         write(15,*) buf_th2(n), buf_om2(n)

         ! Emular los saltos de línea de Gnuplot (aunque Gnuplot no los necesita para puntos simples)
         write(10,*); write(11,*); write(14,*); write(15,*)
         write(10,*); write(11,*); write(14,*); write(15,*)
      end do
      idx = 0
   end subroutine flush_buffers

   pure subroutine derivadas(th1_in, th2_in, omg1_in, omg2_in, d_th1_out, d_th2_out, d_om1_out, d_om2_out, mass1, mass2, m2l1, m2l2, m2l2_sq, ge_m2sq, ge_m1sq, ge_m1m2sq, m1m2l1sq, inv_l1sq, inv_l2sq)
      real*8, intent(in)  :: th1_in, th2_in, omg1_in, omg2_in
      real*8, intent(out) :: d_th1_out, d_th2_out, d_om1_out, d_om2_out
      real*8, intent(in)  :: mass1, mass2, m2l1, m2l2, m2l2_sq, ge_m2sq, ge_m1sq, ge_m1m2sq, m1m2l1sq, inv_l1sq, inv_l2sq

      real*8 :: s_delta, c_delta, s2_delta, den, inv_den
      real*8 :: num1, num2, omg1_sq, omg2_sq
      real*8 :: s1, c1, s2, c2

      s1 = sin(th1_in)
      c1 = cos(th1_in)
      s2 = sin(th2_in)
      c2 = cos(th2_in)

      s_delta = s1 * c2 - c1 * s2
      c_delta = c1 * c2 + s1 * s2
      s2_delta = 2.d0 * s_delta * c_delta

      omg1_sq = omg1_in * omg1_in
      omg2_sq = omg2_in * omg2_in

      den = mass1 + mass2 * (s_delta * s_delta)
      inv_den = 1.d0 / den

      d_th1_out = omg1_in
      d_th2_out = omg2_in

      num1 = m2l1 * omg1_sq * s2_delta + m2l2_sq * omg2_sq * s_delta + &
         ge_m2sq * c2 * s_delta + ge_m1sq * s1

      num2 = m2l2 * omg2_sq * s2_delta + m1m2l1sq * omg1_sq * s_delta + &
         ge_m1m2sq * c1 * s_delta

      d_om1_out = num1 * inv_l1sq * inv_den
      d_om2_out = num2 * inv_l2sq * inv_den
   end subroutine derivadas

end program RungeKuta_Temporal
