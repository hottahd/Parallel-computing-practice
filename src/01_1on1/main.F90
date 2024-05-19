program one_on_one
    use mpi
    implicit none
    integer :: myrank, npe, merr, mreq
    integer :: count, dest, tag
    integer, allocatable :: mstatus(:)
    integer :: a
    
    allocate(mstatus(mpi_status_size))

    call mpi_init(merr) 
    call mpi_comm_size(mpi_comm_world, npe   , merr) 
    call mpi_comm_rank(mpi_comm_world, myrank, merr) 

    ! ここで全てのrankでaを初期化
    a = 0
    if (myrank == 0) then
        a = 123 ! myrank = 0 でだけaを設定
    endif


    ! 情報送受信前のaを確認
    if (myrank == 1) then
        write(*,*) 'myrank = ', myrank, ' a = ', a, ' ; before send/recv'
    endif

    count = 1 ! データ数。スカラーなので1
    ! myrank = 0 から myrank = 1 へaを送信
    if (myrank == 0) then
        dest = 1
        tag = 0
        call mpi_isend(a, count, mpi_integer, dest, tag, mpi_comm_world, mreq, merr)
    endif

    ! myrank = 0 から myrank = 1 へaを受信
    if (myrank == 1) then
        dest = 0
        tag = 0
        call mpi_irecv(a, count, mpi_integer, dest, tag, mpi_comm_world, mreq, merr)
    endif

    ! 非同期通信を待機。これが終わるとデータに触れる
    if (myrank == 0 .or. myrank == 1) then
        call mpi_wait(mreq, mstatus, merr)
    endif
    
    ! 情報送受信後のaを確認
    if (myrank == 1) then
        write(*,*) 'myrank = ', myrank, ' a = ', a, ' ; after send/recv'
    endif

    call mpi_finalize(merr) ! MPIの終了設定
end program one_on_one