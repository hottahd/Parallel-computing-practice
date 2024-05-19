program advection
    use mpi
    implicit none

    ! MPIの変数
    integer :: myrank, npe, merr
    integer :: count, dest, orgn, tag_dw2up, tag_up2dw
    double precision :: buffsnd_up, buffsnd_dw, buffrcv_up, buffrcv_dw
    integer, allocatable :: mstatus(:)
    integer :: mreqsnd_dw2up, mreqsnd_up2dw, mreqrcv_dw2up, mreqrcv_up2dw
    character(LEN=4) :: cno ! プロセス番号
    character(LEN=4) :: cnd ! データアウトプット番号

    ! 移流方程式で用いる変数
    integer :: i, nd, n
    integer, parameter :: ix = 16 ! 各プロセスでのx方向の格子数
    integer, parameter :: margin = 1 ! 各プロセスでの境界の数
    integer, parameter :: ixg = ix + 2*margin ! marginも含めた格子
    double precision, dimension(ixg) :: x, qq, qqn ! x座標、変数
    double precision :: dt, tmax, dx, dtmin, cfl, cvel
    double precision :: t = 0.d0 ! 時間
    double precision :: tout = 0.02d0 ! 出力時間間隔
    double precision :: tend = 1.d0 ! 計算終了時間
    double precision :: dw ! 初期条件のガウス関数の幅
    double precision, parameter :: xmax = 1.d0, xmin = 0.d0 ! x座標の最大値、最小値
    double precision :: xmaxl, xminl ! 各プロセスのx座標の最大値、最小値
    double precision :: xwidthl ! 各プロセスのx座標の幅

    ! data directory作成
    logical :: exist

    allocate(mstatus(mpi_status_size))

    call mpi_init(merr) 
    call mpi_comm_size(mpi_comm_world, npe   , merr) 
    call mpi_comm_rank(mpi_comm_world, myrank, merr) 

    write(cno, ('(I4.4)')) myrank

    if (myrank == 0) then
        inquire(file = 'data/params.txt', exist = exist)
        if (.not. exist) then
            call system('mkdir data')
            call system('mkdir data/x')
            call system('mkdir data/qq')
        endif

        open(10,file='data/params.txt',form='formatted')
        write(10,*) ix
        write(10,*) margin
        write(10,*) npe
        close(10)

    endif

    ! myrank =0 でディレクトリ作成が終わるまで待つ
    call mpi_barrier(mpi_comm_world, merr)
    
    ! 座標設定
    xwidthl = (xmax - xmin) / dble(npe)
    xminl = xmin + dble(myrank) * xwidthl
    xmaxl = xminl + xwidthl
    dx = (xmaxl - xminl)/dble(ix)

    x(1) = xminl + (0.5d0 - dble(margin) )*dx
    do i = 2,ixg
        x(i) = x(i-1) + dx
    enddo

    ! 座標書き出し
    open(10,file='data/x/x.'//cno//'.dat',form='unformatted',access='stream')
    write(10) x
    close(10)

    ! 初期条件
    dw = 0.05d0
    do i = 1,ixg
        qq(i) = exp(-((x(i)-0.5d0*(xmax + xmin))/dw)**2)
        !qq(i) = dble(myrank)
    enddo

    ! 移流速度
    cvel = 1.d0

    !
    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    nd = 0
    n = 0

    ! 初期条件書き出し(あとでも同じことするのでサブルーチンにした方が良い)
    write(cnd, ('(I4.4)')) nd   
    open(10,file='data/qq/qq.'//cno//'.'//cnd//'.dat',form='unformatted',access='stream')
    write(10) qq
    close(10)

    do 
        ! 時間発展
        ! CFL条件(こんなことする必要はないのだが、練習のため)
        dtmin = 1.d10
        cfl = 0.99d0
        do i = 1+margin,ixg-margin
            dtmin = min(dtmin, cfl*dx/abs(cvel))
        enddo

        call mpi_allreduce(dtmin, dt, 1, mpi_double_precision, mpi_min, mpi_comm_world, merr)
        
        qqn = 0.d0
        do i = 1+margin,ixg-margin
            qqn(i) = 0.5d0*(qq(i+1) + qq(i-1)) - cvel*dt*(qq(i+1) - qq(i-1))/2.d0/dx
        enddo
        ! 境界条件
        ! mpi_sendrecvでやった方が簡単だが、ブロッキング通信は避ける
        tag_dw2up = 0
        tag_up2dw = 1
        if(myrank == npe -1) then
            dest = 0
        else
            dest = myrank + 1
        endif

        buffsnd_up = qqn(ixg - margin) ! 1次元の場合はそのまま渡してもいいが、多次元の場合はbuffに入れるのがおすすめ
        call mpi_isend(buffsnd_up,margin, mpi_double_precision, dest, tag_dw2up, mpi_comm_world, mreqsnd_dw2up, merr)
        call mpi_irecv(buffrcv_up,margin, mpi_double_precision, dest, tag_up2dw, mpi_comm_world, mreqrcv_up2dw, merr)

        if(myrank == 0) then
            dest = npe - 1
        else
            dest = myrank - 1
        endif
        buffsnd_dw = qqn(1 + margin)
        call mpi_isend(buffsnd_dw,margin, mpi_double_precision, dest, tag_up2dw, mpi_comm_world, mreqsnd_up2dw, merr)
        call mpi_irecv(buffrcv_dw,margin, mpi_double_precision, dest, tag_dw2up, mpi_comm_world, mreqrcv_dw2up, merr)

        call mpi_wait(mreqsnd_dw2up, mstatus, merr)
        call mpi_wait(mreqsnd_up2dw, mstatus, merr)
        call mpi_wait(mreqrcv_dw2up, mstatus, merr)
        call mpi_wait(mreqrcv_up2dw, mstatus, merr)

        ! 上記のmpi_waitをするまで、buffrcv_up, buffrcv_dwは更新されない
        ! よくやるミス
        qqn(ixg) = buffrcv_up
        qqn(1) = buffrcv_dw

        qq = qqn

        t = t + dt
        n = n + 1
        if(int(t/tout) /= int((t-dt)/tout)) then
            nd = nd + 1
            write(cnd, ('(I4.4)')) nd
            open(10,file='data/nd.txt',form='formatted')
            write(10,*) nd
            close(10)

            open(10,file='data/qq/qq.'//cno//'.'//cnd//'.dat',form='unformatted',access='stream')
            write(10) qq
            close(10)
        endif

        if (t > tend) exit
    enddo
    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

    call mpi_finalize(merr) ! MPIの終了設定
    stop
end program advection