---
marp: true
size: 16:9
theme: gaia
class: invert
headingDivider: 1
paginate: true
style: |
  section {
    font-size: 21px;
  }
---

<!--
_header: "MPIを用いた並列数値シミュレーション"
-->
# MPIを用いた並列数値シミュレーション

## 名古屋大学 宇宙地球環境研究所 堀田英之

1. MPIとは
1. 環境設定
1. Hello World

# MPIとは

Message Passing Interface (MPI) とは、並列コンピューティングを利用するための標準化された規格である。実装自体を指すこともある。[wikipedia](https://ja.wikipedia.org/wiki/Message_Passing_Interface)より。

今回は、MPIの基礎を(fortran)で学ぶことにより、並列実行可能なコードを実装できるようになることを目指す。

## 前提知識
- UNIX・Linux
- エディタ(Emacs・vi・VS code...)
- fortranの基礎構文
- 移流方程式の解法(簡単に復習する)

# 環境設定など

## CIDAS (ISEE, Nagoya-U)

CIDASシステムの`solar0*`で実行することを想定しているために特別な環境設定は必要ない。

## ローカルマシンに環境構築する場合

### Mac
`Homebrew`を用いる
```SHELL
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" # Homebrew
brew install gcc # gfortran
brew install openmpi # OpenMPI
```

### Linux (Ubuntu)
管理者権限が必要
```SHELL
sudo apt-get install gfortran # gfortran
sudo apt-get install openmpi-doc openmpi-bin libopenmpi-dev # OpenMPI
```

# Hello world: code

`src/00_hello_world/main.F90`以下にプログラムあり

MPIを使う場合は
```fortran
use mpi
```
としてモジュールを宣言する。以下でMPIの初期設定
```fortran
call mpi_init(merr)
```

MPIのプロセス数(`size`)やMPIのランク(`rank`)を呼び出すには以下
```fortran
call mpi_comm_size(mpi_comm_world, size, merr)
call mpi_comm_rank(mpi_comm_world, rank, merr)
```

最後にはMPIの終了設定をする。

```fortran
call mpi_finalize(merr)
```
# Hello world: compile

コンパイルは`mpif90`を用いる
```SHELL
mpif90 main.f90
```

実行は`mpiexec`。以下のような書式
```SHELL
mpiexec -n np ./a.out
```
`np`はプロセス数である。8プロセスを立ち上げたい場合は

```SHELL
mpiexec -n 8 ./a.out
```
などとする。