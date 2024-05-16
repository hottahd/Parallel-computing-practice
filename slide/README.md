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
1. 1対1通信
1. 集団通信
1. 実際の例(移流方程式)

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

# 1対1通信

MPIでは、プロセスごとに違うメモリ空間を持っており、明示的にプロセス間のデータのやり取りをする必要がある。ここではプロセスごとの1対1通信を解説する。通信にはブロッキング通信/ノンブロッキング通信がある。
### ブロッキング
送受信側で送信/受信バッファを解放しても良いタイミング(一般には送受信が完了したタイミング)になるまで送信関数・受信関数から復帰しない。処理の順番を間違えるとデッドロック(お互いに情報を待つ)が起こる可能性がある。今回はこちらは説明しない

### ノンブロッキング
送信処理・受信処理を開始する宣言のみで、送信関数・受信関数から復帰。データの同期は`mpi_wait`関数などでユーザーが保証する必要がある。今回はこちらを説明する。

# ノンブロッキング 1対1通信 (1/n)

`rank = 0`から`rank = 1`へノンブロッキングに変数`a`を`mpi_isend/mpi_irecv`関数を用いて送受信するプログラムを`src/01_1on1/main.F90`に配置した。

# `mpi_isend`関数

自分の`rank`から指定した`rank`へデータを送信する関数。書式は以下
```fortran
mpi_isend(buff,count,datatype,dest,tag,comm,mreq,merr)
```

|引数|型|入手力|意味|
|---    |---      |---|---|
|`buff`    |任意      |入力|送信する変数、配列も可
|`count`   |`integer`|入力|要素の個数。配列なら要素数。スカラーならば1。|
|`datatype`|`integer`|入力|送信するデータの型。MPIによる定義(後述)|
|`dest`    |`integer`|入力|送信先の`rank`|
|`tag`     |`integer`|入力|メッセージタグ。`mpi_irecv`で同じものを使う
|`comm`    |`integer`|入力|コミュニケータ。`mpi_comm_world`
|`mreq`    |`integer`|出力|通信識別子。サイズは`mpi_isend`呼び出す回数
|`merr`    |`integer`|出力|エラーコード

# `mpi_irecv`関数

自分の`rank`から指定した`rank`へデータを受信する関数。書式は以下
```fortran
mpi_isend(buff,count,datatype,orgn,tag,comm,mreq,merr)
```

|引数|型|入手力|意味|
|---    |---      |---|---|
|`buff`    |任意      |入力|送信する変数、配列も可
|`count`   |`integer`|入力|要素の個数。配列なら要素数。スカラーならば1。|
|`datatype`|`integer`|入力|送信するデータの型。MPIによる定義(後述)|
|`orgn`    |`integer`|入力|送信元の`rank`|
|`tag`     |`integer`|入力|メッセージタグ。`mpi_irecv`で同じものを使う
|`comm`    |`integer`|入力|コミュニケータ。`mpi_comm_world`
|`mreq`    |`integer`|出力|通信識別子。サイズは`mpi_isend`呼び出す回数
|`merr`    |`integer`|出力|エラーコード

# `mpi_wait`関数

`mpi_isend/mpi_irecv`を実行した後は、``通信が終わるまで待機する。
```fortran
call mpi_wait(mreq, mstatus,merr)
```
|引数|型|入手力|意味|
|---    |---      |---|---|
|`mreq`    |`integer`|入出力|通信識別子。サイズは`mpi_isend`呼び出す回数
|`mstatus` |`integer`|出力  |状況オブジェクト配列。サイズは`mpi_status_size`
|`merr`    |`integer`|出力  |エラーコード

複数回`mpi_isend/mpi_irecv`を行った場合は`mpi_waitall`でまとめて待機させることもできる(省略)。
# MPIの`datatype`
MPI関数の定義する型は多岐にわたるが、よく使うものだけここに示す

|MPI `datatype`        | fortran `type`    |意味|
|---                   |---                |---
|`mpi_integer`         | `integer`         |整数
|`mpi_real`            | `real`            |単精度実数
|`mpi_double_precision`| `double precision`|倍精度実数
|`mpi_complex`         | `complex`         |(通常は)単精度複素数
|`mpi_logical`         | `logical`         |ブール値。`true`か`false`


ユーザーが型を定義することも可能。`mpi_type_create_subarray`など。メモリ上不連続なデータをひとまとめにして送りたい場合に有用(省略)

# 集団通信

多くのプロセスと同時に関連して通信するのが集団通信。多数回1対1通信をしても実現できるが、MPIの集団通信は最適化してあるので、多数のプロセスが関わる場合はこちらを使うようにする。