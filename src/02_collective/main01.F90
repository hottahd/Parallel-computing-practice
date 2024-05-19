program bcast
    use mpi
    implicit none
    integer :: rank, size, merr
    integer :: count, orgn
    integer :: a
    
    call mpi_init(merr) 
    call mpi_comm_size(mpi_comm_world, size, merr) 
    call mpi_comm_rank(mpi_comm_world, rank, merr) 

    ! ここで全てのrankでaを初期化
    a = 0
    if (rank == 0) then
        a = 123 ! rank = 0 でだけaを設定
    endif

    ! 情報送受信前のaを全プロセスで確認
    write(*,*) 'rank = ', rank, ' a = ', a, ' ; before bcast'

    ! rank = 0 から 全rankへaを送信
    count = 1
    orgn = 0
    call mpi_bcast(a, count, mpi_integer, orgn, mpi_comm_world, merr)
    
    ! 情報送受信後のaを確認
    write(*,*) 'rank = ', rank, ' a = ', a, ' ; after bcast'

    call mpi_finalize(merr) ! MPIの終了設定
end program bcast