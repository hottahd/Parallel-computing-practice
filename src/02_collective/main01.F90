program bcast
    use mpi
    implicit none
    integer :: myrank, npe, merr
    integer :: count, orgn
    integer :: a
    
    call mpi_init(merr) 
    call mpi_comm_size(mpi_comm_world, npe   , merr) 
    call mpi_comm_rank(mpi_comm_world, myrank, merr) 

    ! ここで全てのrankでaを初期化
    a = 0
    if (myrank == 0) then
        a = 123 ! myrank = 0 でだけaを設定
    endif

    ! 情報送受信前のaを全プロセスで確認
    write(*,*) 'myrank = ', myrank, ' a = ', a, ' ; before bcast'

    ! rank = 0 から 全rankへaを送信
    count = 1
    orgn = 0
    call mpi_bcast(a, count, mpi_integer, orgn, mpi_comm_world, merr)
    
    ! 情報送受信後のaを確認
    write(*,*) 'myrank = ', myrank, ' a = ', a, ' ; after bcast'

    call mpi_finalize(merr) ! MPIの終了設定
end program bcast