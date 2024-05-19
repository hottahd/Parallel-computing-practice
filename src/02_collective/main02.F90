program bcast
    use mpi
    implicit none
    integer :: myrank, npe, merr
    integer :: count, orgn
    integer :: myrank_sum
    
    call mpi_init(merr) 
    call mpi_comm_size(mpi_comm_world, npe   , merr) 
    call mpi_comm_rank(mpi_comm_world, myrank, merr) 

    ! 各rankの合計を計算
    count = 1
    call mpi_allreduce(myrank, myrank_sum, count, mpi_integer, mpi_sum, mpi_comm_world, merr)
    if(myrank == 0) then
        write(*,*) 'rank = ', myrank, ' rank_sum = ', myrank_sum, ' ; after allreduce'
    endif

    call mpi_finalize(merr) ! MPIの終了設定
end program bcast