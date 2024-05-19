program bcast
    use mpi
    implicit none
    integer :: rank, size, merr
    integer :: count, orgn
    integer :: rank_sum
    
    call mpi_init(merr) 
    call mpi_comm_size(mpi_comm_world, size, merr) 
    call mpi_comm_rank(mpi_comm_world, rank, merr) 

    ! 各rankの合計を計算
    call mpi_allreduce(rank, rank_sum, count, mpi_integer, mpi_sum, mpi_comm_world, merr)
    if(rank == 0) then
    write(*,*) 'rank = ', rank, ' rank_sum = ', rank_sum, ' ; after allreduce'
    endif

    call mpi_finalize(merr) ! MPIの終了設定
end program bcast