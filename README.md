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
1. 基本的な使い方

# MPIとは

Message Passing Interface (MPI) とは、並列コンピューティングを利用するための標準化された規格である。実装自体を指すこともある。[wikipedia](https://ja.wikipedia.org/wiki/Message_Passing_Interface)より。

今回は、MPIの基礎を(fortran)で学ぶことにより、並列実行可能なコードを実装できるようになることを目指す。

## 前提知識
- UNIX・Linux
- エディタ(Emacs・vi・VS code...)
- fortranの基礎構文
- 移流方程式の解法(簡単に復習する)