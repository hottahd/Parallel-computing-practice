program hello_world
    ! MPIを使うためのモジュールを読み込む
    ! include 'mpif.h'としてもよい
    use mpi
    implicit none
    ! rank: プロセスの番号
    ! size: プロセスの総数
    ! merr: エラーコード
    integer :: myrank, npe, merr
    
    call mpi_init(merr) ! MPIの初期設定
    call mpi_comm_size(mpi_comm_world, npe   , merr) ! MPIのプロセス数を取得
    call mpi_comm_rank(mpi_comm_world, myrank, merr) ! MPIのランクを取得

    write(*,*) 'Hello World from myrank', myrank, 'of', npe ! ランクとプロセス数を表示

    call mpi_finalize(merr) ! MPIの終了設定
end program hello_world