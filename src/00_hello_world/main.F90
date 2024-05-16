program hello_world
    ! MPIを使うためのモジュールを読み込む
    ! include 'mpif.h'としてもよい
    use mpi
    implicit none
    ! rank: プロセスの番号
    ! size: プロセスの総数
    ! merr: エラーコード
    integer :: rank, size, merr
    
    call mpi_init(merr) ! MPIの初期設定
    call mpi_comm_size(mpi_comm_world, size, merr) ! MPIのプロセス数を取得
    call mpi_comm_rank(mpi_comm_world, rank, merr) ! MPIのランクを取得

    write(*,*) 'Hello World from rank', rank, 'of', size ! ランクとプロセス数を表示

    call mpi_finalize(merr) ! MPIの終了設定
end program hello_world