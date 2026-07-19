---
title: 算法与数据结构基础：排序稳定性、时间复杂度、空间复杂度与链表
slug: algorithms-and-data-structures-26nugm
date: '2026-04-23 13:12:49+08:00'
lastmod: '2026-07-19 18:09:37+08:00'
tags:
  - 算法
  - 数据结构
  - 排序
  - 复杂度
  - 链表
categories:
  - 技术
keywords: 算法,数据结构,排序,复杂度,链表
description: >-
  本文介绍了算法与数据结构的基础知识，包括排序的稳定性定义（稳定/不稳定排序的示例），算法的时间复杂度（大O表示法，常见量级如O(1)、O(logn)、O(n)、O(nlogn)、O(n²)等）和空间复杂度（O(1)、O(n)、O(n²)），以及链表数据结构的概念、应用场景（适合增删频繁、元素个数不确定的场景）和Go语言实现示例（简单链表和循环链表）。
toc: true
isCJKLanguage: true
---



# 算法与数据结构基础：排序稳定性、时间复杂度、空间复杂度与链表

## 什么是稳定和不稳定的排序

- **选择排序、快速排序、希尔排序、堆排序不是稳定的排序算法。**
- **冒泡排序、插入排序、归并排序、基数排序是稳定的排序算法。**

**稳定：如果 a 原本在 b 前面，而 a\=b，排序之后 a 仍然在 b 前面。**

**不稳定：如果 a 原本在 b 前面，而 a\=b，排序之后 a 可能在 b 的后面。**

# 基础知识

## [算法的时间与空间复杂度](https://zhuanlan.zhihu.com/p/50479555)

算法（Algorithm）是指用来操作数据、解决程序问题的一组方法。对于同一个问题，使用不同的算法，也许最终得到的结果是一样的，但在过程中消耗的资源和时间却会有很大的区别。

那么我们应该如何去衡量不同算法之间的优劣呢？

**主要还是从算法所占用的「时间」和「空间」两个维度去考量。**

- **时间维度：是指执行当前算法所消耗的时间，我们通常用「时间复杂度」来描述。**
- **空间维度：是指执行当前算法需要占用多少内存空间，我们通常用「空间复杂度」来描述。**

### 时间复杂度

通用的表示时间复杂度的方法：「 大 O 符号表示法 」，即 **T(n) \= O(f(n))**

常见的时间复杂度量级有（从小到大）：

- 常数阶 `O(1)`
- 对数阶 `O(logN)`
- 线性阶 `O(n)`
- 线性对数阶 `O(nlogN)`
- 平方阶 `O(n²)`
- 立方阶 `O(n³)`
- K 次方阶 `O(n^k)`
- 指数阶 `O(2^n)`

#### 常数阶 `O(1)`

无论代码执行了多少行，只要是没有循环等复杂结构，那这个代码的时间复杂度就都是 O(1)，如：

#### 线性阶 `O(n)`

这段代码，for 循环里面的代码会执行 n 遍，因此它消耗的时间是随着 n 的变化而变化的，因此这类代码都可以用 O(n)来表示它的时间复杂度。

```C
for(i=1; i<=n; ++i)
{
   j = i;
   j++;
}
```

#### 对数阶 `O(logN)`

当循环 log2\^n 次以后，这个代码就结束了。因此这个代码的时间复杂度为：O(logn)

```C
int i = 1;
while(i<n)
{
    i = i * 2;
}
```

#### 线性对数阶 `O(nlogN)`

线性对数阶 `O(nlogN)`​ 其实非常容易理解，将时间复杂度为 `O(logn)` ​的代码循环 N 遍的话，那么它的时间复杂度就是 `n * O(logN)`​，也就是了 `O(nlogN)`。

```C
for(m=1; m<n; m++)
{
    i = 1;
    while(i<n)
    {
        i = i * 2;
    }
}
```

#### 平方阶 `O(n²)`

如果把 O(n) 的代码再嵌套循环一遍，它的时间复杂度就是 O(n²) 了。

```Plain
for(x=1; i<=n; x++)
{
   for(i=1; i<=n; i++)
    {
       j = i;
       j++;
    }
}
```

### 空间复杂度

空间复杂度是对一个算法在运行过程中临时占用存储空间大小的一个量度，同样反映的是一个趋势，我们用 S(n) 来定义。

空间复杂度比较常用的有：O(1)、O(n)、O(n²)

#### 空间复杂度 `O(1)`

**如果算法执行所需要的临时空间不随着某个变量 n 的大小而变化，即此算法空间复杂度为一个常量，可表示为 O(1)**

```C
int i = 1;
int j = 2;
++i;
j++;
int m = i + j;
```

#### 空间复杂度 `O(n)`

```C
int[] m = new int[n]
for(i=1; i<=n; ++i)
{
   j = i;
   j++;
}
```

这段代码中，第一行 new 了一个数组出来，这个数据占用的大小为 n，

# [常见数据结构及算法](https://hunterhug.gitlab.io/goa.c/#/algorithm/README?id=%e5%b8%b8%e8%a7%81%e6%95%b0%e6%8d%ae%e7%bb%93%e6%9e%84%e5%8f%8a%e7%ae%97%e6%b3%95)

## [链表](https://hunterhug.gitlab.io/goa.c/#/algorithm/link?id=%e9%93%be%e8%a1%a8)

> 链表由一个个数据节点组成的，它是一个递归结构，要么它是空的，要么它存在一个指向另外一个数据节点的引用。

**应用场景**

- 如果需要支持随机访问的话，链表没办法做到。
- 如果需要存储的数据元素的个数不确定，并且需要经常添加和删除数据的话，使用链表比较合适。
- 如果需要存储的数据元素的个数确定，并且不需要经常添加和删除数据的话，使用数组比较合适。

简单链表：

```Go
package main

import ("fmt"
)type LinkNode struct {
    Data     int64
    NextNode *LinkNode
}
func main() {// 新的节点
    node := new(LinkNode)
    node.Data = 2// 新的节点
    node1 := new(LinkNode)
    node1.Data = 3
    node.NextNode = node1 // node1 链接到 node 节点上// 新的节点
    node2 := new(LinkNode)
    node2.Data = 4
    node1.NextNode = node2 // node2 链接到 node1 节点上// 按顺序打印数据
    nowNode := node
    for {if nowNode != nil {// 打印节点值
            fmt.Println(nowNode.Data)// 获取下一个节点
            nowNode = nowNode.NextNode
            continue}// 如果下一个节点为空，表示链表结束了break}
}
 
```

 循环链表：

```Go
type Ring struct {
   next, prev *Ring
   data       interface{}
}

func InitRing() *Ring {
   var ring Ring
   ring.prev = &ring
   ring.next = &ring
   return &ring
}

// InsertByHead 头插法
func (r *Ring) InsertByHead(data ...interface{}) {
   for i := 0; i < len(data); i++ {
      p := &Ring{
         next: r.next,
         prev: r,
         data: data[i],
      }
      r.next.prev = p
      r.next = p
   }
}

// InsertByTail 尾插法
func (r *Ring) InsertByTail(data ...interface{}) {
   for i := 0; i < len(data); i++ {
      p := &Ring{
         next: r,
         prev: r.prev,
         data: data[i],
      }
      r.prev.next = p
      r.prev = p
   }
}

func (r *Ring) PrevNode() *Ring {
   if r.prev == nil {
      return InitRing()
   }
   return r.prev
}

func (r *Ring) NextNode() *Ring {
   if r.next == nil {
      return InitRing()
   }
   return r.next
}

func (r *Ring) NodeData() interface{} {
   return r.data
}

func (r *Ring) Move(n int) *Ring {
   if r.next == nil || r.prev == nil {
      return InitRing()
   }
   p := r
   switch n > 0 {
   case true:
      for i := 0; i < n; i++ {
         p = p.next
      }
   default:
      for i := 0; i < n; i++ {
         p = p.prev
      }
   }
   return p
}

// Link 往节点A，链接一个节点，并且返回之前节点A的后驱节点
func (r *Ring) Link(s *Ring) *Ring {
   n := r.next
   if s != nil {
      p := s.prev
      r.next = s
      s.prev = r
      n.prev = p
      p.next = n
   }
   return n
}
```

## Set

```Go
package set

import "sync"

// Set 集合
type Set struct {
   m  map[interface{}]struct{} // 字典实现
   rw sync.RWMutex             // 锁
}

func New() *Set {
   return &Set{
      m:  make(map[interface{}]struct{}),
      rw: sync.RWMutex{},
   }
}

func NewSet(cap int) *Set {
   var temp map[interface{}]struct{}
   if cap <= 0 {
      temp = make(map[interface{}]struct{})
   } else {
      temp = make(map[interface{}]struct{}, cap)
   }
   return &Set{
      m:  temp,
      rw: sync.RWMutex{},
   }
}

func (s *Set) Add(item interface{}) {
   s.rw.Lock()
   defer s.rw.Unlock()
   s.m[item] = struct{}{}
}

func (s *Set) Remove(item int) {
   s.rw.Lock()
   defer s.rw.Unlock()
   delete(s.m, item)
}

func (s *Set) Has(item int) bool {
   s.rw.RLock()
   defer s.rw.RUnlock()
   _, ok := s.m[item]
   return ok
}

func (s *Set) Len() int {
   return len(s.m)
}

func (s *Set) IsEmpty() bool {
   return s.Len() == 0
}

func (s *Set) Clear() {
   s.rw.Lock()
   defer s.rw.Unlock()
   s.m = map[interface{}]struct{}{}
}

func (s *Set) List() (list []interface{}) {
   s.rw.RLock()
   defer s.rw.RUnlock()
   for item := range s.m {
      list = append(list, item)
   }
   return list
}
```

## 树

一棵树具有以下特点：

1. 一棵树中的任意两个结点有且仅有唯一的一条路径连通。
2. 一棵树如果有 n 个结点，那么它一定恰好有 n-1 条边。
3. 一棵树不包含回路。

下图就是一棵树，并且是一颗二叉树。

![](https://127.0.0.1:57868/assets/network-asset-asynccode-20260423131308-7jk292p.png)

如上图所示，通过上面这张图说明一下树中的常用概念：

- 节点 ：树中的每个元素都可以统称为节点。
- 根节点 ：顶层节点或者说没有父节点的节点。上图中 A 节点就是根节点。
- 父节点 ：若一个节点含有子节点，则这个节点称为其子节点的父节点。上图中的 B 节点是 D 节点、E 节点的父节点。
- 子节点 ：一个节点含有的子树的根节点称为该节点的子节点。上图中 D 节点、E 节点是 B 节点的子节点。
- 兄弟节点 ：具有相同父节点的节点互称为兄弟节点。上图中 D 节点、E 节点的共同父节点是 B 节点，故 D 和 E 为兄弟节点。
- 叶子节点 ：没有子节点的节点。上图中的 D、F、H、I 都是叶子节点。
- 节点的高度 ：该节点到叶子节点的最长路径所包含的边数。
- 节点的深度 ：根节点到该节点的路径所包含的边数
- 节点的层数 ：节点的深度 +1。
- 树的高度 ：根节点的高度。

### 二叉树的分类

二叉树（Binary tree）是每个节点最多只有两个分支（即不存在分支度大于 2 的节点）的树结构。

二叉树 的分支通常被称作“左子树”或“右子树”。并且，二叉树 的分支具有左右次序，不能随意颠倒。

**二叉树 的第** **​`i`​**​**层至多拥有** ​**​`2^(i-1)`​** ​ **个节点，深度为** **​`k`​**​**的二叉树至多总共有** ​**​`2^(k+1)-1`​**​ **个节点（满二叉树的情况），至少有 2\^(k) 个节点。**

#### 满二叉树

一个二叉树，如果每一个层的结点数都达到最大值，则这个二叉树就是 满二叉树。也就是说，如果一个二叉树的层数为 K，且结点总数是(2\^k) -1 ，则它就是 满二叉树。如下图所示：

![](https://127.0.0.1:57868/assets/network-asset-asynccode-20260423131308-s6eyizm.png)

#### 完全二叉树

除最后一层外，若其余层都是满的，并且最后一层或者是满的，或者是在右边缺少连续若干节点，则这个二叉树就是 完全二叉树 。

大家可以想象为一棵树从根结点开始扩展，扩展完左子节点才能开始扩展右子节点，每扩展完一层，才能继续扩展下一层。如下图所示：

![](https://127.0.0.1:57868/assets/network-asset-asynccode-20260423131308-w1feucl.png)

#### 平衡二叉树

平衡二叉树 是一棵​**二叉排序树**，且具有以下性质：

1. 可以是一棵空树
2. 如果不是空树，**它的左右两个子树的高度差的绝对值不超过 1，并且左右两个子树都是一棵平衡二叉树。**

平衡二叉树的常用实现方法有 红黑树、AVL 树、替罪羊树、加权平衡树、伸展树 等。

## 排序算法

### 冒泡排序

`O(n^2)`

```Go
// BubbleSort 冒泡排序 n^2
func BubbleSort(list []int, cmp func(i, j int) bool) {
   flag := true
   for i := 0; i < len(list); i++ {
      flag = true
      for j := len(list) - 2; j >= i; j-- { // 从后往前冒泡
         if !cmp(j, j+1) {
            flag = false
            list[j], list[j+1] = list[j+1], list[j]
         }
      }
      if flag == true {
         return
      }
   }
}
```

### 选择排序

`O(n^2)`

![](https://127.0.0.1:57868/assets/network-asset-asynccode-20260423131309-7ycfycu.gif)

每次扫描数列找出最小的数，然后与第一个数交换，然后排除第一个数，从第二个数开始重复这个操作，这种排序叫做简单选择排序。

```Go
func SelectSort(list []int) {
    n := len(list)
    // 进行 N-1 轮迭代
    for i := 0; i < n-1; i++ {
        // 每次从第 i 位开始，找到最小的元素
        min := list[i] // 最小数
        minIndex := i  // 最小数的下标
        for j := i + 1; j < n; j++ {
            if list[j] < min {
                // 如果找到的数比上次的还小，那么最小的数变为它
                min = list[j]
                minIndex = j
            }
        }

        // 这一轮找到的最小数的下标不等于最开始的下标，交换元素
        if i != minIndex {
            list[i], list[minIndex] = list[minIndex], list[i]
        }
    }
}
 
```

我们每一轮，除了找最小数之外，还找最大数，然后分别和前面和后面的元素交换，这样循环次数减少一半，如：

```Go
// SelectSort 选择排序 n^2
func SelectSort(list []int, cmp func(i, j int) bool) {
   n := len(list)
   for i := 0; i < n/2; i++ {
      minIndex, maxIndex := i, i
      for j := i + 1; j < n-i; j++ {
         if cmp(maxIndex, j) { // 这一轮这个是大的，直接 continue
            maxIndex = j
            continue
         }
         if !cmp(minIndex, j) { // 找到最小值下标
            minIndex = j
         }
      }
      if maxIndex == i && minIndex != n-i-1 {
         // 如果最大值是开头的元素，而最小值不是最尾的元素
         // 先将最大值和最尾的元素交换
         list[n-i-1], list[maxIndex] = list[maxIndex], list[n-i-1]
         // 然后最小的元素放在最开头
         list[i], list[minIndex] = list[minIndex], list[i]
      } else if maxIndex == i && minIndex == n-i-1 {
         // 如果最大值在开头，最小值在结尾，直接交换
         list[minIndex], list[maxIndex] = list[maxIndex], list[minIndex]
      } else {
         // 否则先将最小值放在开头，再将最大值放在结尾
         list[i], list[minIndex] = list[minIndex], list[i]
         list[n-i-1], list[maxIndex] = list[maxIndex], list[n-i-1]
      }
   }
}
```

### 插入排序

`O(n^2)`

插入排序，一般我们指的是简单插入排序，也可以叫直接插入排序。就是说，每次把一个数插到已经排好序的数列里面形成新的排好序的数列，以此反复。

```Go
// InsertSort 插入排序 n^2
func InsertSort(list []int, cmp func(i, j int) bool) {
   n := len(list)
   // 进行 N-1 轮迭代
   for i := 1; i <= n-1; i++ {
      deal := list[i] // 待排序的数
      j := i - 1      // 待排序的数左边的第一个数的位置
      // 如果第一次比较，比左边的已排好序的第一个数小，那么进入处理
      if cmp(deal, list[j]) {
         // 一直往左边找，比待排序大的数都往后挪，腾空位给待排序插入
         for ; j >= 0 && cmp(deal, list[j]); j-- {
            list[j+1] = list[j] // 某数后移，给待排序留空位
         }
         list[j+1] = deal // 结束了，待排序的数插入空位
      }
   }
}
```

### 希尔排序

`O(nlogn)`

希尔排序是直接插入排序的改进版本。因为直接插入排序对那些几乎已经排好序的数列来说，排序效率极高，达到了 `O(n)`​ 的线性复杂度，但是每次只能将数据移动一位。希尔排序创造性的可以将数据移动 `n`​ 位，然后将 `n`​ 一直缩小，缩到与直接插入排序一样为 `1`

有一个 `N` 个数的数列：

1. 先取一个小于 `N`​ 的整数 `d1`​，将位置是 `d1` 整数倍的数们分成一组，对这些数进行直接插入排序。
2. 接着取一个小于 `d1`​ 的整数 `d2`​，将位置是 `d2` 整数倍的数们分成一组，对这些数进行直接插入排序。
3. 接着取一个小于 `d2`​ 的整数 `d3`​，将位置是 `d3` 整数倍的数们分成一组，对这些数进行直接插入排序。
4. ...
5. 直到取到的整数 `d=1`，接着使用直接插入排序。

这是一种分组插入方法，最后一次迭代就相当于是直接插入排序，其他迭代相当于每次移动 `n` 个距离的直接插入排序，这些整数是两个数之间的距离，我们称它们为增量。

我们取数列长度的一半为增量，以后每次减半，直到增量为 1。

```Go
// ShellSort 希尔排序
func ShellSort(list []int, cmp func(i, j int) bool) {
   // 数组长度
   n := len(list)
   // 每次减半，直到步长为 1
   for step := n / 2; step >= 1; step /= 2 {
      // 开始插入排序，每一轮的步长为 step
      for i := step; i < n; i += step {
          // 待排序的数左边的第一个数的位置
         for j := i - step; j >= 0; j -= step {
            // 满足插入那么交换元素
            if cmp(list[j+step], list[j]) {
               list[j], list[j+step] = list[j+step], list[j]
               continue
            }
            break
         }
      }
   }
}
```

### 归并排序

`O(nlogn)`

`递归`

归并排序是一种分治策略的排序算法。它是一种比较特殊的排序算法，通过递归地先使每个子序列有序，再将两个有序的序列进行合并成一个有序的序列。

**时间：每次都是一分为二，特别均匀，所以最差和最坏时间复杂度都一样。归并操作的时间复杂度为：**​**​`O(n)`​** ​​ **，因此总的时间复杂度为：**​**​`T(n)=2T(n/2)+O(n)`​** ​​ **，根据主定理公式可以知道时间复杂度为：**​**​`O(nlogn)`​** ​ **。我们可以自己计算一下：**

```Plaintext
归并排序，每次归并操作比较的次数为两个有序数组的长度： n/2

T(n) = 2*T(n/2) + n/2
T(n/2) = 2*T(n/4) + n/4
T(n/4) = 2*T(n/8) + n/8
T(n/8) = 2*T(n/16) + n/16
...
T(4) = 2*T(2) + 4
T(2) = 2*T(1) + 2
T(1) = 1

进行合并也就是：

T(n) = 2*T(n/2) + n/2
     = 2^2*T(n/4)+ n/2 + n/2
     = 2^3*T(n/8) + n/2 + n/2 + n/2
     = 2^4*T(n/16) + n/2 + n/2 + n/2 + n/2
     = ...
     = 2^logn*T(1) + logn * n/2
     = 2^logn + 1/2*nlogn
     = n + 1/2*nlogn

因为当问题规模 n 趋于无穷大时 nlogn 比 n 大，所以 T(n) = O(nlogn)。

因此时间复杂度为：O(nlogn)。
```

**空间：因为不断地递归，程序栈层数会有** **​`logn`​**​​ **层，所以递归栈的空间复杂度为：**​**​`O(logn)`​** ​​ **，对于排序十亿个整数，也只要：**​**​`log(100 0000 0000)=29.897`​**​ **，占用的堆栈层数最多** **​`30`​**​ **层忧。**

**自顶向下排序**

![](https://127.0.0.1:57868/assets/network-asset-asynccode-20260423131309-zb64qar.png)

```Go
// MergeSort 归并排序 nlogn
func MergeSort(nums []int, l, r int) {
   // 至少有两个元素,进入排序
   if r-l > 1 {
      mid := l + (r-l)/2
      MergeSort(nums, l, mid)
      MergeSort(nums, mid, r)
      merge(nums, l, mid, r)
   }
}

func merge(nums []int, begin, mid, end int) {
   tmp := make([]int, 0, end-begin+1)
   l, r := begin, mid
   for l < mid && r < end {
      if nums[r] < nums[l] {
         tmp = append(tmp, nums[r])
         r++
      } else {
         tmp = append(tmp, nums[l])
         l++
      }
   }
   tmp = append(tmp, nums[l:mid]...)
   tmp = append(tmp, nums[r:end]...)
   for i := range tmp {
      nums[begin+i] = tmp[i]
   }
}
```

```Go
// MergeSort2 非递归
func MergeSort2(array []int, begin int, end int) {
   // 步长从1开始
   step := 1
   for end-begin > step {
      for i := begin; i < end; i += step << 1 { // 每次找到两个合并部分
         lo := i
         mid := lo + step
         ro := mid + step
         if mid > end { // 不到一个的范围就break
            break
         }
         if ro > end {
            ro = end
         }
         merge(array, lo, mid, ro)
      }
      step <<= 1
   }
}
```

`链表归并`

```Go
// SortList 给出链表的第一个有效节点和最后一个有效节点的下一个节点
func SortList(head, tail *ListNode) *ListNode {
   // 0
   if head == nil {
      return head
   }
   // 1
   if head.Next == tail {
      head.Next = nil
      return head
   }
   // >=2 快慢指针找中点
   slow, fast := head, head
   for fast != tail {
      slow = slow.Next
      fast = fast.Next
      if fast != tail {
         fast = fast.Next
      }
   }
   mid := slow
   // merge
   return mergeList(SortList(head, mid), SortList(mid, tail))
}

func mergeList(head1, head2 *ListNode) *ListNode {
   dummyHead := &ListNode{}
   // 合并两个有序链表
   t, t1, t2 := dummyHead, head1, head2
   for t1 != nil && t2 != nil {
      if t1.Val <= t2.Val {
         t.Next = t1
         t1 = t1.Next
      } else {
         t.Next = t2
         t2 = t2.Next
      }
      t = t.Next
   }
   if t1 != nil {
      t.Next = t1
   } else {
      t.Next = t2
   }
   return dummyHead.Next
}
```

### 快排

`O(nlogn)`

快速排序通过一趟排序将要排序的数据分割成独立的两部分，其中一部分的所有数据都比另外一部分的所有数据都要小，然后再按此方法对这两部分数据分别进行快速排序，

步骤如下：

1. 先从数列中取出一个数作为基准数。一般取第一个数。
2. 分区过程，将比这个数大的数全放到它的右边，小于或等于它的数全放到它的左边。
3. 再对左右区间重复第二步，直到各区间只有一个数。
   ​**时间**​：在最好情况下，每一轮都能平均切分，每一轮遍历比较元素 `n`​ 次就可以把数列分成两部分，每一轮的时间复杂度都是：`O(n)`​。因为问题规模每次被折半，折半的数列继续递归进行切分，也就是总的时间复杂度计算公式为： `T(n) = 2*T(n/2) + O(n)`​。按照主定理公式计算，我们可以知道时间复杂度为：`O(nlogn)`

最差的情况下，每次都不能平均地切分，每次切分都因为基准数是最大的或者最小的，不能分成两个数列，这样时间复杂度变为了 `T(n) = T(n-1) + O(n)`​，按照主定理计算可以知道时间复杂度为：`O(n^2)`。

**空间**​：快速排序使用原地排序，存储空间复杂度为：`O(1)`​。而因为递归栈的影响，递归的程序栈开辟的层数范围在 `logn ~ n`​，所以递归栈的空间复杂度为：`O(logn) ~ log(n)`​，最坏为：`log(n)`，当元素较多时，程序栈可能溢出。

```Go
// QSort 快排 nlogn
func QSort(array []int, low, high int, cmp func(a, b int) bool) {
   i, j := low, high
   if low >= high {
      return
   }
   k := array[low]
   for low < high {
      for ; low < high && !cmp(k, array[high]); high-- {
      }
      if cmp(k, array[high]) {
         array[low] = array[high]
      }
      for ; low < high && cmp(k, array[low]); low++ {
      }
      if !cmp(k, array[low]) {
         array[high] = array[low]
      }
   }
   array[low] = k
   QSort(array, i, low-1, cmp)
   QSort(array, low+1, j, cmp)      
}
```

### 堆排

最大堆实现细节(两个操作)：

1. push：向堆中插入数据时，**首先在堆的末尾插入数据，如果该数据比父亲节点还大，那么交换，然后不断向上提升，直到没有大小颠倒为止。**

   > 操作一次 `push`​ 的最好时间复杂度为：`O(1)`​，因为第一次上浮时如果不大于父亲，那么就结束了。最坏的时间复杂度为： `O(logn)`​，相当于每次都大于父亲，会一直往上浮到根节点，翻转次数等于树的高度，而树的高度等于元素个数的对数：`log(n)`。
   >
2. pop：**从堆中删除最大值时，首先把最后一个值复制到根节点上，并且删除最后一个数值，然后和儿子节点比较，如果值小于儿子，与儿子节点交换，然后不断向下交换， 直到没有大小颠倒为止。在向下交换过程中，如果有两个子儿子都大于自己，就选择较大的。**

   > 操作一次 `pop`​ 最好的时间复杂度也是：`O(1)`​，因为第一次比较时根节点就是最大的。最坏时间复杂度仍然是树的高度：`O(logn)`。
   >

```Go
const MaxSize ​= 1000
const MaxData ​= math.MaxInt64 ​// 哨兵节点

// Heap 一个最大堆，一棵完全二叉树
// 最大堆要求节点元素都不小于其左右孩子
type Heap struct {
   // 堆的大小
   Len int
   Cap int
   // 使用内部的数组来模拟树
   // 一个节点下标为 i，那么父亲节点的下标为 (i)/2
   // 一个节点下标为 i，那么左儿子的下标为 2i，右儿子下标为 2i+1
   Array []int
}

// NewHeap 初始化一个空堆,创建哨兵
func NewHeap(cap int) *Heap {
   maxCap := MaxSize
​   ​if cap > 0 && cap < maxCap {
      maxCap = cap
   }
   return &Heap{
      Len:   0,
      Cap:   MaxSize,
      Array: append([]int{MaxData}, make([]int, maxCap)...),
   }
}

// Push 最大堆插入元素
func (h *Heap) Push(x int) {
   // 堆没有元素时，使元素成为顶点后退出
   h.Len++
   if h.Len > h.Cap {
      h.Array = append(h.Array, make([]int, h.Len)...)
      h.Cap += h.Len
   }
   // i 是要插入节点的下标
   i := h.Len
   for i > 0 {
      // parent为该元素父亲节点的下标
      parent := i / 2
      // 如果插入的值小于等于父亲节点，那么可以直接退出循环，因为父亲仍然是最大的
      if x <= h.Array[parent] { // 有个哨兵
         break
      }
      // 否则将父亲节点与该节点互换，然后向上翻转，将最大的元素一直往上推
      h.Array[i] = h.Array[parent]
      i = parent
   }
   h.Array[i] = x
}

// 向下调整: num 下标，size 元素个数
func (h *Heap) siftDown(num, size int) {
   t := 0
   for num*2 <= size {
      if h.Array[num] >= h.Array[num*2] {
         t = num
      } else {
         t = num * 2
      }
      if num*2+1 <= size {
         if h.Array[t] < h.Array[num*2+1] {
            t = num*2 + 1
         }
      }
      if t == num {
         break
      } else {
         h.Array[t], h.Array[num] = h.Array[num], h.Array[t]
         num = t
      }
   }
}

// Pop 最大堆移除根节点元素，也就是最大的元素
func (h *Heap) Pop() int {
   // 没有元素，返回-1
   if h.Len == 0 {
      return -1
   }
   // 取出根节点
   ret := h.Array[1]
   // 因为根节点要被删除了，将最后一个节点放到根节点的位置上
   h.Array[1] = h.Array[h.Len] // 将最后一个元素的值先拿出来
   h.Len--
   // 对根节点进行向下翻转，小的值 x 一直下沉，维持最大堆的特征
   h.siftDown(1, h.Len)
   return ret
}

func (h *Heap) MaxHeap(size int) {
   h.siftDown(1, size)
}

// HeapSort 堆排 有效元素下标为[1,h.Len]
func (h *Heap) HeapSort() {
   h.MaxHeap(h.Len)
   for i := h.Len; i > 1; i-- {
      h.Array[1], h.Array[i] = h.Array[i], h.Array[1]
      h.siftDown(1, i-1)
   }
}
```

```Go
func HeapSort(ans []int) {
      ansLen := len(ans)
      for i := ansLen/2 - 1; i >= 0; i-- {
              adjustHeap(ans, i, ansLen)
      }
      for j := ansLen - 1; j > 0; j-- {
              ans[0], ans[j] = ans[j], ans[0]
              adjustHeap(ans, 0, j)
      }
      fmt.Printf("堆排序：%d个随机数\n", ansLen)
}

// 调整堆
func adjustHeap(ans []int, i, length int) {
        pos := i
        for k := 2*i + 1; k < length; k = 2*k + 1 {
                if k+1 < length && ans[k] < ans[k+1] {
                        k++
                }
                if ans[k] > ans[pos] {
                        ans[k], ans[pos] = ans[pos], ans[k]
                        pos = k
                } else {
                        break
                }
        }
}
```

```Go
package​ main

import​ ​"fmt"

func​ ​buildHeap(nums []int)​ {
​   NLen := ​len(nums)
​   ​for​ i := NLen / ​2; i >= ​0; i-- {
​      adjustSort(nums, i, NLen)
​   }
}

func​ ​adjustSort(nums []int, i, heapSize ​int)​ {
​   l, r, maxn := ​2*i+1, ​2*i+2, i
​   ​if​ l < heapSize && nums[l] > nums[maxn] {
​      maxn = l
​   }
​   ​if​ r < heapSize && nums[r] > nums[maxn] {
​      maxn = r
​   }
​   ​if​ maxn != i {
​      nums[i], nums[maxn] = nums[maxn], nums[i]
​      adjustSort(nums, maxn, heapSize)
​   }
}

func​ ​heapSort(nums []int)​ {
​   buildHeap(nums)
​   NLen := ​len(nums)
​   ​for​ i := NLen - ​1; i > ​0; i-- {
​      nums[0], nums[i] = nums[i], nums[0]
​      adjustSort(nums, ​0, i)
​   }
}
func​ ​main()​ {
​   nums := []int{2, ​3, ​4, ​12, ​4, ​3, ​62, ​1}
​   heapSort(nums)

​   ​for​ _, num := ​range​ nums {
​      fmt.Println(num)
​   }
}
```

堆排序

1. 将乱序数组构建成一个大根堆(最后排序为递增序列)。通过下滤操作来维护堆性质。
2. 将堆顶数(最大数)移动到数组末尾。(移除堆)
3. 缩小堆范围。heapSize--
4. 下滤操作维护堆性质。

```Go

func main() {
   nums := []int{3, 1, 4, 1, 5, 9, 2, 6, 5, 3, 5}
   heapSort(nums)
   fmt.Println(nums)
}

// 下滤操作 保持堆的性质
func maxHeapify(nums []int, i, heapSize int) {
   largest := i // 父节点与两个子节点 大的数的索引
   l := 2*i + 1 // 左子节点索引
   r := 2*i + 2 // 右子节点索引

   // 与左子节点比较
   if l < heapSize && nums[l] > nums[largest] {
      largest = l
   }
   // 与右子节点比较
   if r < heapSize && nums[r] > nums[largest] {
      largest = r
   }
   // 如果最大值不是父节点，则交换
   if largest != i {
      nums[i], nums[largest] = nums[largest], nums[i]
      // 递归保持交换后子树的堆性质
      maxHeapify(nums, largest, heapSize) // 被交换的子节点索引 的孩子节点
   }
}

// 从一个无序数组构建最大堆
func buildMaxHeap(nums []int) {
   heapSize := len(nums)
   // 从最后一个父节点开始向上构建最大堆
   for i := heapSize/2 - 1; i >= 0; i-- {
      maxHeapify(nums, i, heapSize)
   }
}

// 堆排序
func heapSort(nums []int) {
   heapSize := len(nums)
   buildMaxHeap(nums) // 构建大根堆
   // 进行排序
   for i := heapSize - 1; i > 0; i-- {
      // 将堆顶数移动到数组末尾(最大数)
      nums[0], nums[i] = nums[i], nums[0]
      // 缩小堆的范围
      heapSize--
      // 下滤，维护堆性质
      maxHeapify(nums, 0, heapSize)
   }
}
```

**堆排序是用堆实现的一个算法，优先队列是用堆实现的数据结构，堆排序仅仅是排序，优先队列可以随时取队中最大值，插入等，手动实现也可以一定程度上实现删除**

#### **优先队列**

优先队列是一种能完成以下任务的队列：插入一个数值，取出最小或最大的数值（获取数值，并且删除）。

```Go
// 最小堆

type Item struct {
   value    string
   priority int
   index    int
}

type PriorityQueue []*Item

func (pq *PriorityQueue) Len() int {
   return len(*pq)
}
func (pq *PriorityQueue) Less(i, j int) bool {
   return (*pq)[i].priority > (*pq)[j].priority
}
func (pq *PriorityQueue) Swap(i, j int) {
   (*pq)[i], (*pq)[j] = (*pq)[j], (*pq)[i]
   (*pq)[i].index, (*pq)[j].index = i, j
}

func (pq *PriorityQueue) Pop() interface{} {
   t := (*pq)[len(*pq)-1]
   t.index = -1 // 标记被弹出
   *pq = (*pq)[:len(*pq)-1]
   return t
}

// Push 添加节点
func (pq *PriorityQueue) Push(x interface{}) {
   item := x.(*Item)
   item.index = len(*pq)
   *pq = append(*pq, item)
}

// Update 更新节点
func (pq *PriorityQueue) Update(item *Item, value string, priority int) {
   item.value = value
   item.priority = priority
   heap.Fix(pq, item.index)
}

func main() {
   // 创建节点并设计他们的优先级
   items := map[string]int{"二毛": 5, "张三": 3, "狗蛋": 9}
   i := 0
   pq := make(PriorityQueue, len(items)) // 创建优先级队列，并初始化
   for k, v := range items {             // 将节点放到优先级队列中
      pq[i] = &Item{
         value:    k,
         priority: v,
         index:    i}
      i++
   }
   heap.Init(&pq) // 初始化堆
   item := &Item{ // 创建一个item
      value:    "李四",
      priority: 1,
   }
   heap.Push(&pq, item)           // 入优先级队列
   pq.Update(item, item.value, 6) // 更新item的优先级
   for len(pq) > 0 {
      item := heap.Pop(&pq).(*Item)
      fmt.Printf("%.2d:%s index:%.2d\n", item.priority, item.value, item.index)
   }
}
```

### 计数排序

**计数排序 (Counting sort) 是一种稳定的排序算法。计数排序使用一个额外的数组** ​**​`C`​**​ **，其中第** ​**​`i`​**​ **个元素是待排序数组** ​**​`A`​**​ **中值等于** ​**​`i`​**​ **的元素的个数。然后根据数组** ​**​`C`​**​ **来将** ​**​`A`​**​ **中的元素排到正确的位置。它只能对整数进行排序。**

**算法步骤：**

1. 找出数组中的最大值 `max`​、最小值 `min`；
2. 创建一个新数组 `C`​，其长度是 `max-min+1`，其元素默认值都为 0；
3. 遍历原数组 `A`​ 中的元素 `A[i]`​，以 `A[i]-min`​ 作为 `C`​ 数组的索引，以 `A[i]`​ 的值在 `A`​ 中元素出现次数作为 `C[A[i]-min]` 的值；
4. 对 `C`​ 数组变形，新元素的值是该元素与前一个元素值的和，即当 `i>1`​ 时 `C[i] = C[i] + C[i-1]`；
5. 创建结果数组 `R`，长度和原始数组一样。
6. 从后向前遍历原始数组 `A`​ 中的元素 `A[i]`​，使用 `A[i]`​ 减去最小值 `min`​ 作为索引，在计数数组 `C`​ 中找到对应的值 `C[A[i]-min]`​，`C[A[i]-min]-1`​ 就是 `A[i]`​ 在结果数组 `R`​ 中的位置，做完上述这些操作，将 `count[A[i]-min]` 减小 1。

![](https://127.0.0.1:57868/assets/network-asset-asynccode-20260423131309-ndtaamt.gif)

### 桶排序

桶排序的工作的原理：假设输入数据服从均匀分布，将数据分到有限数量的桶里，每个桶再分别排序（有可能再使用别的排序算法或是以递归方式继续使用桶排序进行。

 **算法步骤：**

1. 设置一个 BucketSize，作为每个桶所能放置多少个不同数值；
2. 遍历输入数据，并且把数据依次映射到对应的桶里去；
3. 对每个非空的桶进行排序，可以使用其它排序方法，也可以递归使用桶排序；
4. 从非空桶里把排好序的数据拼接起来。

![](https://127.0.0.1:57868/assets/network-asset-asynccode-20260423131309-nyqin5z.gif)

### 基数排序

基数排序也是非比较的排序算法，对元素中的每一位数字进行排序，从最低位开始排序，复杂度为 `O(n×k)`​，`n`​ 为数组长度，`k` 为数组中元素的最大的位数；

### 算法步骤

1. 取得数组中的最大数，并取得位数，即为迭代次数 `N`​（例如：数组中最大数值为 1000，则 `N=4`）；
2. `A`​ 为原始数组，从最低位开始取每个位组成 `radix` 数组；
3. 对 `radix` 进行计数排序（利用计数排序适用于小范围数的特点）；
4. 将 `radix` 依次赋值给原数组；
5. 重复 2\~4 步骤 `N` 次

![](https://127.0.0.1:57868/assets/network-asset-asynccode-20260423131309-uoptyt4.gif)

### 为什么很多内置库使用快排？

首先堆排序，归并排序最好最坏时间复杂度都是：`O(nlogn)`​，而快速排序最坏的时间复杂度是：`O(n^2)`，但是很多编程语言内置的排序算法使用的仍然是快速排序，这是为什么？

1. 这个问题有偏颇，选择排序算法要看具体的场景，`Linux`​ 内核用的排序算法就是堆排序，而 `Java` 对于数量比较多的复杂对象排序，内置排序使用的是归并排序，只是一般情况下，快速排序更快。
2. 归并排序有两个稳定，第一个稳定是排序前后相同的元素位置不变，第二个稳定是，每次都是很平均地进行排序，读取数据也是顺序读取，能够利用存储器缓存的特征，比如从磁盘读取数据进行排序。因为排序过程需要占用额外的辅助数组空间，所以这部分有代价损耗，但是原地手摇的归并排序克服了这个缺陷。
3. **复杂度中，大** **​`O`​**​​ **有一个常数项被省略了，堆排序每次取最大的值之后，都需要进行节点翻转，重新恢复堆的特征，做了大量无用功**​，常数项比快速排序大，大部分情况下比快速排序慢很多。但是堆排序时间较稳定，不会出现快排最坏 `O(n^2)` 的情况，且省空间，不需要额外的存储空间和栈空间。
   当待排序数量大于 16000 个元素时，使用自底向上的堆排序比快速排序还快，可见此：[https://core.ac.uk/download/pdf/82350265.pdf](https://core.ac.uk/download/pdf/82350265.pdf)。
4. 快速排序最坏情况下复杂度高，主要在于切分不像归并排序一样平均，而是很依赖基准数的现在，我们通过改进，比如随机数，三切分等，这种最坏情况的概率极大的降低。大多数情况下，它并不会那么地坏，大多数快才是真的块。
5. **归并排序和快速排序都是分治法，排序的数据都是相邻的，而堆排序比较的数可能跨越很大的范围，导致局部性命中率降低，不能利用现代存储器缓存的特征，加载数据过程会损失性能。**

对稳定性有要求的，要求排序前后相同元素位置不变，可以使用归并排序，`Java` 中的复杂对象类型，要求排序前后位置不能发生变化，所以小规模数据下使用了直接插入排序，大规模数据下使用了归并排序。

对栈，存储空间有要求的可以使用堆排序，比如 `Linux` 内核栈小，快速排序占用程序栈太大了，使用快速排序可能栈溢出，所以使用了堆排序。

## 查找方式

### 跳表

![](https://127.0.0.1:57868/assets/network-asset-asynccode-20260423131312-wm5exfg.png)

```Go
const (
   MaxLevel    = 18         // 最大层数
   Probability = 1 / math.E​ ​// 每一个节点是否可以向上的概率基数
)

type (
   // Comparable 大于返回正数,小于返回负数,等于返回0
   Comparable interface {
      CompareTo(Comparable) int
   }
   
   KV struct {
      K Comparable
      V interface{}
   }
   
   Element struct {
      next []*Element
      kv   *KV
   }
   
   SkipList struct {
      node          Element     // 第一个为头结点,不存值
      maxLevel      int         // 最大层数
      len           int         // 跳表长度
      randSource    rand.Source // 生成随机数
      probTable     []float64   // 用于查询每一层生成索引的概率
      prevNodeCache []*Element  // 用于保存查询一个值时经过每一层时的最后一个节点
   }
)

func NewKV(key Comparable, value interface{}) *KV {
   return &KV{
      K: key,
      V: value,
   }
}

// 计算每一层生成索引的概率-> 生成一张概率表
func probabilityTable(probability float64, level int) (ret []float64) {
   for i := 1; i <= level; i++ {
      ret = append(ret, math.Pow(probability, float64(i-1)))
   }
   return ret
}

func NewSkipList() *SkipList {
   return &SkipList{
      node:          Element{next: make([]*Element, MaxLevel)},
      maxLevel:      MaxLevel,
      randSource:    rand.NewSource(time.Now().UnixNano()),
      probTable:     probabilityTable(Probability, MaxLevel),
      prevNodeCache: make([]*Element, MaxLevel),
   }
}

// Len 获取长度
func (sList *SkipList) Len() int {
   return sList.len
}

// Get 获取数据 如果没有相等的数据，返回它的下一个元素(也可能是nil),bool仍是false
func (sList *SkipList) Get(k Comparable) (*KV, bool) {
   prev := &sList.node // 重要 从头结点开始遍历
   var node *Element
   for now := sList.maxLevel - 1; now >= 0; now-- {
      node = prev.next[now]
      for node != nil && k.CompareTo(node.kv.K) > 0 {
         prev = node
         node = node.next[now]
      }
   }
   // 指针已经到达第一层
   if node != nil {
      return node.kv, k.CompareTo(node.kv.K) == 0
   }
   return nil, false
}

// PrevNodeCache 每一层下来的节点所组成的切片
func (sList *SkipList) PrevNodeCache(k Comparable) []*Element {
   prev := &sList.node
   var node *Element
   for now := sList.maxLevel - 1; now >= 0; now-- { // 在每一层进行搜索合适的位置然后向下一层
      node = prev.next[now]
      for node != nil && k.CompareTo(node.kv.K) > 0 { // 发现没到就继续往右走
         prev = node // 保留着向下的通道
         node = node.next[now]
      }
      sList.prevNodeCache[now] = prev // 存放每层搜索的最后一个节点
   }
   return sList.prevNodeCache
}

// Delete 删除数据
func (sList *SkipList) Delete(key Comparable) {
   prev := sList.PrevNodeCache(key)
   if ele := prev[0].next[0]; ele != nil && key.CompareTo(ele.kv.K) == 0 { // 如果找到了那个k
      for k, v := range ele.next { // 把连接key的节点的next跳过key
         prev[k].next[k] = v
      }
      sList.len--
   }
}

// 对每一层进行概率评估
func (sList *SkipList) randomLevel() int {
   n := float64(sList.randSource.Int63()) / math.MaxInt64 ​// 随机概率
   level := 1                                             // 第1层始终有索引
   for level < sList.maxLevel && n < sList.probTable[level-1] {
      level++
   }
   return level
}

func newElement(kv *KV, level int) *Element {
   return &Element{
      kv:   kv,
      next: make([]*Element, level),
   }
}

// Put 插入数据
func (sList *SkipList) Put(kv *KV) {
   prev := sList.PrevNodeCache(kv.K)                                        // 保存着每层最后一个小于目标值得节点
   if ele := prev[0].next[0]; ele != nil && kv.K.CompareTo(ele.kv.K) == 0 { // 找到就替换值
      ele.kv.V = kv.V
      return
   }
   // 没找到就新创建一个
   element := newElement(kv, sList.randomLevel()) // 随机分配一个层数
   // 加入一个索引层
   for k := range element.next { // 把k层的element都插入
      element.next[k] = prev[k].next[k]
      prev[k].next[k] = element
   }
   sList.len++
}

// GetMax 获取最后一个元素
func (sList *SkipList) GetMax() (kv *KV) {
   node := &sList.node
   for now := sList.maxLevel - 1; now >= 0; now-- {
      for node.next[now] != nil {
         node = node.next[now]
      }
   }
   return node.kv
}

// GetMin 获取第一个元素
func (sList *SkipList) GetMin() (kv *KV) {
   return sList.node.next[0].kv
}
```

### 红黑树

红黑树特点 :

1. 每个节点非红即黑；
2. 根节点总是黑色的；
3. 每个叶子节点都是黑色的空节点（NIL 节点）；
4. 如果节点是红色的，则它的子节点必须是黑色的（反之不一定）；
5. 从根节点到叶节点或空子节点的每条路径，必须包含相同数目的黑色节点（即相同的黑色高度）。

### 二分查找

#### 基础版

**查找条件可以在不与元素的两侧进行比较的情况下确定**（或使用它周围的特定元素）。

不需要后处理，因为每一步中，你都在检查是否找到了元素。如果到达末尾，则知道未找到该元素.

```C
int search(int* nums, int numsSize, int target){
    int left = 0,right = numsSize-1,mid;
    while(left <= right)
    {
        mid = left+(right-left)/2;
        if(nums[mid]==target)
            return mid;
        else if(nums[mid]<target)
            left = mid+1;
        else
            right = mid-1;
    }
    return -1;
}
```

#### 进阶版

**它用于查找需要访问数组中当前索引及其直接右邻居索引的元素或条件。**

查找条件需要访问元素的直接右邻居。 使用元素的右邻居来确定是否满足条件，并决定是向左还是向右。

保证查找空间在每一步中至少有 2 个元素。 需要进行后处理。 当你剩下 1 个元素时，循环 / 递归结束。 需要评估剩余元素是否符合条件.

```C
int search(int* nums, int numsSize, int target){
    int left = 0,right = numsSize-1,mid;
    while(left<right)
    {
        mid = left+(right-left)/2;
        if(nums[mid]==target)
            return mid;
        else if(nums[mid]<target)
            left = mid+1;
        else
            right = mid;
    }
    if(nums[left]==target)
        return left;
    return -1;
}
```

#### 特殊版

**它用于搜索需要访问当前索引及其在数组中的直接左右邻居索引的元素或条件。**

查找条件需要访问元素的直接右邻居。 使用元素的右邻居来确定是否满足条件，并决定是向左还是向右。 保证查找空间在每一步中至少有 2 个元素。 需要进行后处理。 当你剩下 1 个元素时，循环 / 递归结束。 需要评估剩余元素是否符合条件。

```C
int search(int* nums, int numsSize, int target){
    int left = 0,right = numsSize-1,mid;
    while(left+1 < right)
    {
        mid = left+(right-left)/2;
        if(nums[mid]==target)
            return mid;
        else if(nums[mid]<target)
            left = mid;
        else
            right = mid;
    }
    if(nums[left] == target)
        return left;
    if(nums[right] == target)
        return right;
    return -1;
}
```

## 一致性哈希

```Go
import (
   "hash/crc32"
   "sort"
   "strconv"
   "sync"
)

/*一致性哈希算法的实现
一致性哈希算法将 key 映射到 2^32 的空间中，将这个数字首尾相连，形成一个环.
   1. 计算节点/机器(通常使用节点的名称、编号和 IP 地址)的哈希值，放置在环上。
   2. 计算 key 的哈希值，放置在环上，顺时针寻找到的第一个节点，就是应选取的节点/机器。
优点:
   一致性哈希算法，在新增/删除节点时，只需要重新定位该节点附近的一小部分数据，而不需要重新定位所有的节点
问题:数据倾斜
解决:使用虚拟节点扩充节点数
   1. 计算虚拟节点的 Hash 值，放置在环上。
   2. 计算 key 的 Hash 值，在环上顺时针寻找到应选取的虚拟节点，例如是 peer2-1，那么就对应真实节点 peer2。
*/

type Hash func(data []byte) uint32

type Map struct {
   mu       sync.RWMutex   // 并发安全
   hash     Hash           // Hash函数
   replicas int            // 虚拟节点倍数
   keys     []int          // 哈希环 存着节点的hash值
   hashMap  map[int]string // 虚拟节点与真实节点的映射表,键是虚拟节点的哈希值,值是真实节点的名称
}

// New 构造函数 允许自定义hash函数和节点倍数
func New(replicas int, hash Hash) *Map {
   m := &Map{hash: hash, replicas: replicas, hashMap: map[int]string{}}
   if m.hash == nil {
      m.hash = crc32.ChecksumIEEE
   }
   return m
}

// Add 增加节点
func (m *Map) Add(keys ...string) {
   m.mu.Lock()
   defer m.mu.Unlock()
   for _, key := range keys {
      for i := 0; i < m.replicas; i++ {
         hash := int(m.hash([]byte(strconv.Itoa(i) + key)))
         // 加入哈希环
         m.keys = append(m.keys, hash)
         // 建立映射
         m.hashMap[hash] = key
      }
   }
   sort.Ints(m.keys)
}

// Get 获取对应节点
func (m *Map) Get(key string) string {
   m.mu.RLock()
   defer m.mu.RUnlock()
   if len(m.keys) == 0 {
      return ""
   }
   hash := int(m.hash([]byte(key)))
   // 通过hash值找到在key之后的第一个节点,因为可能i为n,所以取余,使其称为环
   idx := sort.Search(len(m.keys), func(i int) bool {
      return m.keys[i] >= hash
   })
   return m.hashMap[m.keys[idx%len(m.keys)]]
}

// Remove 移除节点
func (m *Map) Remove(key string) {
   m.mu.Lock()
   defer m.mu.Unlock()
   for i := 0; i < m.replicas; i++ {
      hash := int(m.hash([]byte(strconv.Itoa(i) + key)))
      idx := sort.SearchInts(m.keys, hash)
      if idx == len(m.keys) {
         continue
      }
      m.keys = append(m.keys[:idx], m.keys[idx+1:]...)
      delete(m.hashMap, hash)
   }
}
```

## 图论

### 图的存储结构

### 邻接矩阵

使用两个矩阵来表示图:一维数组 Vex 存储顶点,二维数组 map 存储边或弧的信息，可以存储边数较多的稠密图

```C
/*构建邻接矩阵*/
typedef char VexType;        //顶点的数据类型
typedef int EdgeType;        //边上的权值类型
#define MAXVEX 100  //最大顶点数
#define INF        9999        //表示无穷大   
/*图的遍历*/
int visited[MAXVEX];//访问标记的数组

typedef struct
{
        VexType vexs[MAXVEX];        //顶点表
        EdgeType map[MAXVEX][MAXVEX];        //邻接矩阵
        int vexnum,edgenum;        //顶点数和边数
} AdjGraph; //邻接矩阵
```

#### 图的遍历

##### DFS

```C
void DFSTraverse(AdjGraph* M)//邻接矩阵的深度优先遍历操作
{
        memset(visited,0,M->vexnum*(sizeof(int)));//初始化标记数组为0表示未被访问过
        for(int i = 0; i<M->vexnum; i++)
                if(visited[i]==0)//没有被访问过就DFS它
                {
                        DFS(M,i);
                        printf("\n");
                }
}

void DFS(AdjGraph* M,int i)//邻接矩阵的深度优先遍历算法--以每个点为跳板找其他连着的点
{
        visited[i] = 1;//标记为已经访问过
        printf("%c ",M->vexs[i]);
        for(int j = 0; j<M->vexnum; j++)//遍历顶点
        {
                if(M->map[i][j]!=INF && visited[j]==0)//如果有边而且没有被访问过就DFS它
                {
                        DFS(M,j);
                }
        }
}
```

##### BFS

```C
void BFSTraverse(AdjGraph* M)//邻接矩阵的广度优先遍历算法-- 遇到一个点就把和它相连接的点压入队列,然后继续往下遍历
{
        memset(visited,0,M->vexnum*(sizeof(int)));
        printf("广度优先遍历为:\n");
        queue<int> Que;
        for(int i = 0; i<M->vexnum; i++)//遍历顶点
        {
                if(visited[i] == 0)//没访问过的点
                {
                        visited[i] = 1;//标记访问过然后压入队列尾并打印
                        Que.push(i);
                        printf("%c ",M->vexs[i]);

                        while(!Que.empty())
                        {
                                i = Que.front();//这里i可以更新到最近的一个已经访问过的点
                                for(int j = 0; j<M->vexnum; j++)//遍历顶点
                                {
                                        if(M->map[i][j] != INF && visited[j]==0)//如果有边而且没有被访问过
                                        {
                                                visited[j] = 1;//标记访问过然后压入队列尾并打印
                                                Que.push(j);
                                                printf("%c ",M->vexs[j]);
                                        }
                                }
                                Que.pop();//弹出队首顶点
                        }
                }
        }
}
```

#### 最小生成树--Prim 算法

从某一顶点开始构建树,每次找到目前离顶点最近的点,然后通过这个点来更新顶点与其他点的权值,从而达到最小树

```C
void MiniSpanTree_Prim(AdjGraph* M)
{
        printf("最小生成图为:\n");
        int adjvex[MAXVEX];//保存相关顶点的下标,表示该顶点是由某个顶点延伸下来的
        EdgeType edgewight[MAXVEX];//保存顶点到各顶点的权值
        for(int i = 0; i<M->vexnum; i++)
        {
                adjvex[i] = 0;//先初始化都是0
                edgewight[i] = M->map[0][i];//存储根节点vexs[0]到各个顶点的距离,0表示已经被纳入树的节点
        }
        for(int i = 1; i<M->vexnum; i++)
        {
                int min = INF,num;//min为搜索到离根节点的最小权值,num为离根节点最近的顶点的下标
                for(int j = 1; j<M->vexnum; j++)//搜索目前最短的边
                {
                        if(edgewight[j]!=0 && edgewight[j]<min)
                        {
                                min = edgewight[j];
                                num = j;
                        }
                }
                //此时的num存的就是离根节点最短的点的下标
                printf("%c -> %c : %d\n",M->vexs[adjvex[num]],M->vexs[num],M->map[adjvex[num]][num]);//打印当前顶点中权值最小的边
                edgewight[num] = 0;//表示该顶点已经被打印
                for(int j = 1; j<M->vexnum; j++)//循环所有定点,通过目前最短的边来更新根节点到其他顶点的权值
                {
                        if(edgewight[j] != 0 && M->map[num][j] < edgewight[j])//判断这个边是否可以通过此节点变得更小[因为此节点是目前离根节点最近的顶点了]
                        {
                                edgewight[j] = M->map[num][j];
                                adjvex[j] = num; //表示此顶点是由下标为num的顶点所连接
                        }
                }
        }
}
```

### 边集数组

```C
typedef struct
{
        int begin,end;    //起点和终点的下标
        EdgeType weight;  //权值
} EdgeNode;

typedef struct
{
        VexType vexs[MAXVEX];   //顶点表
        EdgeNode edge[MAXEDGE];        //边数组
        int vexnum,edgenum;     //顶点数和边数
} EdgeArray;//边集数组 
```

#### 最小生成树--Kruskal 算法

先按照权值从小到大排序,每次遍历,如果可以加入树就加入树（可以从图中某一顶点开始构建树）

```C
int Find(int *parent,int num)//找头头
{
        if(parent[num] == num)//发现自己就是头头,说明找到这个组织的头了 
                return num;
        else
        {
                parent[num] = Find(parent,parent[num]);//顺便可以统一下头头,我的头头是我头头的头头 
                return parent[num];
        }
}

void MiniSpanTree_Kruskal(EdgeArray* M)//
{
        printf("\n最小生成树为:\n");
        int parent[MAXEDGE];//判断是否会形成回路的数组
        for(int i = 0; i<M->vexnum; i++) //先初始化为自身下标表示自己是自己的头头
                parent[i] = i;
        qsort(M->edge,M->edgenum,sizeof(M->edge[0]),cmp);//按照边的权值将边从小到大排序
        for(int i = 0; i<M->edgenum; i++)
        {
                int m = Find(parent,M->edge[i].begin);//寻找左边节点的头头
                int n = Find(parent,M->edge[i].end);//寻找右边节点的头头
                if(m!=n)//如果两个节点的头头不相同说明两个节点不在一个集合中,即不会形成回路,即可以构成树
                {
                        parent[n] = m;//表示m点已经在以n点为头的集合之中,[人为规定靠左]
                        printf("%c -> %c : %d\n",M->vexs[M->edge[i].begin],M->vexs[M->edge[i].end],M->edge[i].weight);//打印 
                }
        }
}
```

### 最短路径

#### 多源求解最短路径-Floyd\_Warshall

可以解决带有负边权的图--邻接矩阵

```C
void Floyd_Warshall(AdjGraph* M)//多源求解最短路径 注:可以解决带有负边权的图--邻接矩阵
{
        for(int i = 0; i<M->vexnum; i++)//通过此顶点来松弛各边
                for(int j = 0; j<M->vexnum; j++)
                        for(int k = 0; k<M->vexnum; k++)
                                if(M->map[j][k]>M->map[j][i]+M->map[i][k])//判断j到k顶点能否通过k顶点来松弛
                                        M->map[j][k] = M->map[j][i]+M->map[i][k];
        int start,end;
        printf("输入从ai到aj顶点的下标i和j:");
        scanf("%d%d",&start,&end);
        if(M->map[start][end]==INF)
                printf("INF\n");
        else
                printf("%d\n",M->map[start][end]);
}
```

#### 单源求解最短路径--Dijkstra 算法

稠密图适合用这种方式--注:不能解决负边权--邻接矩阵

```C
void Dijkstra(AdjGraph* M)
{
        int num;
        EdgeType dis[MAXVEX];//到每个顶点的距离
        int book[MAXVEX] = {0};//标记是否通过此顶点进行松弛过
        printf("输入需要求解的顶点的下标:");
        scanf("%d",&num);
        for(int i = 0; i<M->vexnum; i++)//先初始化dis数组为num到各个顶点的距离
                dis[i] = M->map[num][i];
        book[num] = 1;//表示不需要通过num顶点松弛
        for(int i = 0; i<M->vexnum; i++)
        {
                int min = INF;
                int p;
                for(int j = 0; j<M->vexnum; j++)//找到目前离顶点最近的顶点 下标为p;
                {
                        if(book[j]==0 && dis[j]<min)
                        {
                                min = dis[j];
                                p = j;
                        }
                }
                for(int j = 0; j<M->vexnum; j++)//通过这个最近的顶点所连接的边来松弛dis数组 
                {
                        if(M->map[p][j]!=INF)
                        {
                                if(dis[p]+M->map[p][j]<dis[j])
                                        dis[j] = dis[p]+M->map[p][j];
                        }
                }
                book[p] = 1;//表示此通过顶点松弛过了
        }
        for(int i = 0; i<M->vexnum; i++)
        {
                printf("%d ",dis[i]);
        }
}
```

Dijkstra 邻接表改进算法--单源求解最短路径--稀疏图适合这种--注:不能解决负边权--邻接表

```C
void Dijkstra(AdjList* M)
{
        int num;
        EdgeType dis[MAXVEX];//顶点到各个顶点的距离
        int book[MAXVEX] = {0};//标记该顶点是否用于松弛过
        printf("输入需要求解的点的下标:");
        scanf("%d",&num);
        for(int i = 0; i<M->vexnum; i++)//都先初始化为INF
                dis[i] = INF;
        dis[num] = 0;//到自己初始化为0
        book[num] = 1;
        for(EdgeNode *p = M->list[num].firstedge;p;p=p->next)//遍历和目标节点相连接的顶点并且填充到dis数组中
        {
                dis[p->index] = p->weight;
        }
        while(1)
        {
                int min = INF;
                int t = -1;
                for(int i = 0;i<M->vexnum;i++) //遍历dis数组 
                {
                        if(book[i]==0 && dis[i]<min)
                        {
                                min = dis[i];
                                t = i;
                        }
                }
                if(t == -1)//当t为-1说明所有连接的点都已经被用于松弛过就可以结束了
                        break;
                book[t] = 1;
                
                for(EdgeNode* p = M->list[t].firstedge;p;p=p->next)//通过目前最近的点来松弛
                {
                        if(dis[p->index]>dis[t]+p->weight)
                        {
                                dis[p->index] = dis[t]+p->weight;
                        }
                }
        }
        for(int i = 0; i<M->vexnum; i++)
        {
                printf("%d ",dis[i]);//打印结果
        }
}
```

#### 单源求解算法-Bellman\_Ford

可以求解负权--边集数组

```C
void Bellman_Ford(EdgeArray* M)
{
        int num;
        printf("输入需要求解的顶点下标:\n");
        scanf("%d",&num);
        EdgeType dis[MAXVEX];//存求解的顶点到各顶点的距离,先初始化为INF
        for(int i = 0; i<M->vexnum; i++) 
        {
                dis[i] = INF;
        }
        dis[num] = 0;
        for(int i = 0; i<M->vexnum-1; i++)//在一个含有n个顶点的图中,任意两点之间的最短路径最多只含有n-1条边,所以只需要通过最多n-1条边来松弛
        {
                int flag = 1;//判断是否此次循环是否存在松弛,如果没有松弛说明所有松弛已经结束
                for(int j = 0; j<M->edgenum; j++)//遍历边尝试优化  即遍历所有的边B dis[B] = min(dis[B],dis[A] + len<A,B>) 
                {
                        if(dis[M->edge[j].end] > M->edge[j].weight + dis[M->edge[j].begin])
                        {
                                dis[M->edge[j].end] = M->edge[j].weight+dis[M->edge[j].begin];
                                flag = 0;
                        }
                }
                if(flag)
                {
                        break;
                }
        }
        for(int i = 0; i<M->edgenum; i++)//检测负权回路--如果n-1此优化后还能再优化说明存在负权回路 
        {
                if(dis[M->edge[i].end]>M->edge[i].weight+dis[M->edge[i].begin])
                {
                        printf("该图存在负权回路\n");
                        break;
                }
        }
        for(int i = 0; i<M->vexnum; i++)
        {
                printf("%d ",dis[i]);
        }
}
```

### 拓扑排序

AOV 网: 在一个表示工程的有向图中,用顶点表示活动,用弧表示活动间的优先关系,这样的有向图为 顶点表示活动的网

若存在 vi--\>vj 路径 则 vi 一定在 vj 前 -- 拓扑序列

求解拓扑序列:使用邻接表

1. 将每个没有入度的顶点纳入栈 stack.push()中
2. 通过弹出栈中的顶点 stack.pop()然后将此顶点加入拓扑序列数组 List 并且断开此顶点与其他顶点的边,并且将入度为 0 的其他顶点再入栈 stack.push()
3. 如果 List 中元素数目小于总顶点数,说明存在回路,否则应该全部被按顺序弹出.

拓扑序列中的邻接表相对于普通邻接表增加了一个入度 in

```C
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<stack>
using namespace std;
typedef int VexType;        //顶点的数据类型
typedef int EdgeType;        //边上的权值类型
#define ERROR 0;
#define OK 1;
#define MAXVEX 100  //最大顶点数 

typedef struct EdgeNode
{
        int index;        //节点下标
        struct EdgeNode* next;
} EdgeNode;        //边表节点

typedef struct
{
        int in;                        //入度
        VexType vex;        //顶点
        EdgeNode *firstedge;        //指向第一个边节点
} VexNode; //顶点表节点

typedef struct
{
        VexNode list[MAXVEX];        //顶点表节点数组
        int vexnum,egdenum;  //顶点数和边数
} AdjList; //邻接表

void InitAdjList(AdjList* M)//初始化图
{
        printf("输入顶点数和边数:");
        scanf("%d%d",&(M->vexnum),&(M->egdenum));
        fflush(stdin);
        printf("输入顶点:");
        for(int i = 0; i<M->vexnum; i++)
        {
                scanf("%d",&(M->list[i].vex));
                M->list[i].firstedge = NULL;  //将边表制空
                M->list[i].in = 0;
        }
        fflush(stdin);
        for(int i = 0; i<M->egdenum; i++)
        {
                printf("输入边(Vi,Vj)的下标i,j:");
                int l,r;
                EdgeType w;
                scanf("%d%d",&l,&r);

                EdgeNode* edge = (EdgeNode*)malloc(sizeof(EdgeNode));//头插法
                edge->index = r;//记录下标
                edge->next = M->list[l].firstedge;
                M->list[l].firstedge = edge;
                M->list[r].in++;//入度+1
        }
}
//(int *)returnList拓扑序列数组
//(int *)returnSize拓扑序列的元素个数
int TopologicalSort(AdjList *M,int *returnList,int *returnSize)//拓扑排序
{
        *returnSize = 0;//记录弹出的顶点数
        stack<int> Stack;
        printf("拓扑排序为:\n");
        for(int i = 0; i<M->vexnum; i++) //先把所有入度为0的节点入栈
        {
                if(M->list[i].in==0)
                {
                        Stack.push(i);
                }
        }
        while(!Stack.empty())
        {
                int num = Stack.top();//取栈顶元素
                Stack.pop();
                returnList[(*returnSize)++] = num;//保存下标
                EdgeNode* p = M->list[num].firstedge;
                while(p)//删除它连向的点,即减少该点的入度
                {
                        if(--(M->list[p->index].in)==0)//如果此点入度变为0说明可以被打印就入栈
                        {
                                Stack.push(p->index);
                        }
                        p = p->next;
                }
        }
        if((*returnSize) < M->vexnum)//存在回路
        {
                (*returnSize) = 0;
                return ERROR;
        }
        return OK;
}

int main()
{
        AdjList* M = (AdjList*)malloc(sizeof(AdjList));
        InitAdjList(M);
        int List[MAXVEX];//拓扑序列数组,保存拓扑排序后数组的元素下标
        int ListSize = 0;//拓扑序列数组的大小
        if(TopologicalSort(M,List,&ListSize))
        {
                for(int i = 0; i<ListSize; i++)
                {
                        printf("%d ",M->list[List[i]].vex);
                }
        }
        else
        {
                printf("此图存在回路\n");
        }
        return 0;
}
```

### 关键路径

AOE 网:在一个表示工程的带权有向图中,用顶点表示事件,用有向边表示活动,用边上的权值表示活动的持续时间,这种有向图的边表示活动的网称为 AOE 网

求解关键路径:使用邻接表

1. 求解 n 个顶点(事件)的最早发生时间(etv)和最晚发生时间(ltv)

   etv 求法:先初始化为 0,对顶点进行拓扑排序,对于每个顶点的最早发生时间 etv[k] \= max(etv[k],etv[i]+len\<i,k\>)就是每次取到此节点路径的最大值

   ltv 求法:先初始化 ltv 为 etv[n-1]即初始化为最早发生时间的最大值,从后往前遍历拓扑序列,使每个 ltv[k] \= min(ltv[k],ltv[i]-len\<k,i\>)就是反着推看最多有多少空余时间
2. 求解 m 个边(活动)的最早发生时间(ete)和最晚发生时间(lte)

   ete 和 lte 求法:早头晚尾: 最早活动时间(ete)看此边(活动)的 头顶点的最早发生时间(etv),最晚活动时间(lte)看尾顶点的最晚发生时间(ltv)

   即:遍历拓扑序列:对于顶点 k 的每一条边\<k,i\>而言: ete \= etv[k] lte \= ltv[i] - len\<k,i\>

   对于每个顶点如果 ete \=\= lte 说明这个活动的发生没有延迟可言,说明它就是关键活动,打印出来就可以.

```C
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<stack>
using namespace std;
typedef int VexType;        //顶点的数据类型
typedef int EdgeType;        //边上的权值类型
#define ERROR 0;
#define OK 1;
#define MAXVEX 100  //最大顶点数

typedef struct EdgeNode
{
        int index;        //节点下标
        EdgeType weight;        //权值
        struct EdgeNode* next;
} EdgeNode;

typedef struct
{
        int in;                        //入度
        VexType vex;
        EdgeNode* firstedge;
} VexNode;

typedef struct
{
        VexNode list[MAXVEX];
        int vexnum,edgenum;
} AdjList;

void InitAdjList(AdjList* M)
{
        printf("输入顶点数和边数:\n");
        scanf("%d%d",&(M->vexnum),&(M->edgenum));
        printf("输入顶点:\n");
        for(int i = 0; i<M->vexnum; i++)
        {
                scanf("%d",&(M->list[i].vex));
                M->list[i].firstedge = NULL;
                M->list[i].in = 0;
        }
        fflush(stdin);
        for(int i = 0; i<M->edgenum; i++)
        {
                printf("输入边(Vi,Vj)的下标i,j和权值w:");
                int l,r;
                EdgeType weight;
                scanf("%d%d%d",&l,&r,&weight);

                EdgeNode* edge = (EdgeNode*)malloc(sizeof(EdgeNode));
                edge->next = M->list[l].firstedge;
                M->list[l].firstedge = edge;
                edge->index = r;
                edge->weight = weight;
                M->list[r].in++;
        }
}

int TopologicalSort(AdjList *M,int *returnList,int *returnSize,int *etv)//拓扑排序 
{
        (*returnSize) = 0;//记录拓扑序列个数
        stack<int> Stack;
        memset(etv,0,M->vexnum*sizeof(int));
        for(int i = 0; i<M->vexnum; i++)
        {
                if(M->list[i].in == 0)
                {
                        Stack.push(i);
                }
        }
        while(!Stack.empty())
        {
                int gettop = Stack.top();
                Stack.pop();
                returnList[(*returnSize)++] = gettop;
                for(EdgeNode* p = M->list[gettop].firstedge; p; p=p->next)
                {
                        if(--(M->list[p->index].in) == 0)
                        {
                                Stack.push(p->index);
                        }
                        if(etv[p->index] < etv[gettop] + p->weight)//求最大
                        {
                                etv[p->index] = etv[gettop] + p->weight;
                        }
                }
        }
        if((*returnSize) < M->vexnum)
        {
                (*returnSize) = 0;
                return ERROR;
        }
        else
        {
                return OK;
        }
}

void CriticalPath(AdjList *M)//求解关键路径
{
        int etv[MAXVEX];//事件最早开始时间
        int ltv[MAXVEX];//事件最晚开始时间
        int List[MAXVEX];//拓扑序列
        int ListSize = 0;//拓扑序列元素个数
        if(TopologicalSort(M,List,&ListSize,etv))//拓扑排序
        {
                for(int i = 0; i<ListSize; i++)
                {
                        ltv[i] = etv[ListSize-1];//全部初始化为结束点的最早开始时间(最大)
                }
                for(int i = ListSize-1; i>=0; i--) //从后往前遍历拓扑序列
                {
                        int gettop = List[i];
                        for(EdgeNode* p = M->list[gettop].firstedge; p; p=p->next)
                        {
                                if(ltv[gettop] > ltv[p->index] - p->weight)//求最小
                                {
                                        ltv[gettop] = ltv[p->index] - p->weight;
                                }
                        }
                }
                printf("最早事件发生时间"); 
                for(int i = 0;i<M->vexnum;i++)
                {
                        printf("%d ",etv[i]);
                }
                printf("\n最晚事件发生时间"); 
                for(int i = 0;i<M->vexnum;i++)
                {
                        printf("%d ",ltv[i]);
                }
                putchar('\n');
                for(int i = 0; i<ListSize; i++) //求关键活动的ete和lte 
                {
                        int gettop = List[i];//拓扑序列
                        for(EdgeNode* p = M->list[gettop].firstedge; p; p=p->next) //遍历边
                        {
                                int ete,lte;//最早活动时间和最晚活动时间
                                ete = etv[gettop];//早头晚尾--最早活动时间看头事件的最早,最晚活动时间看尾事件的最晚
                                lte = ltv[p->index] - p->weight;
                                if(ete == lte)
                                {
                                        printf("%d,%d length: %d\n",M->list[gettop].vex,M->list[p->index].vex,p->weight);
                                }
                        }
                }
        }
        else
        {
                printf("此图存在回路\n");
        }
}

int main()
{
        AdjList* M = (AdjList*)malloc(sizeof(AdjList));
        InitAdjList(M);
        CriticalPath(M);
        return 0;
}
```

‍
