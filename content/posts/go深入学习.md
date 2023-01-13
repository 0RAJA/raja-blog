---
title: "Go深入学习" # 标题
subtitle: "Go深入学习" # 副标题
description: "深入学习go的相关知识" # 文章内容描述
date: 2022-11-20T18:10:02+08:00 # 时间
lastmod: 2022-11-20T18:10:02+08:00 # 上次修改时间
tags: ["go","总结"] # 标签
categories: ["go"] # 分类
featuredImagePreview: "https://go.dev/images/go_core_data_case_study.png" # 封面链接
draft: false # 是否为草稿
hiddenFromHomePage: false # 私人
---
<!--more-->

# go深入学习

参考<a href="https://draveness.me/golang/">《Go语言设计与实现》</a> <a href="">《Go专家编程》</a> 的简单总结

## 编译过程

### 概念

1. 抽象语法树(AST)

   一种用来表示编译语言的语法结构的树形结构，用于辅助编译器进行语法分析。

2. 静态单赋值(SSA)

   是一种中间代码的特性，即每个变量只赋值一次。

3. 指令集架构(CPU中用来计算和控制计算机系统的一套指令的集合)

   分为复杂指令集体系（CISC）和精简指令集体系（RISC）

   复杂指令集：

   1. 特点：指令数量多长度不等，有额外损失性能。
   2. 常用的是AMD64(x86_64/x64) 指令集

   精简指令集：

   1. 特点：指令精简长度相等
   2. 常用有ARM

### 编译四阶段

![image-20220511171644989](https://raja-img.oss-cn-hangzhou.aliyuncs.com/img/image-20220511171644989.png)

![image-20220403171010475](https://raja-img.oss-cn-hangzhou.aliyuncs.com/img/image-20220403171010475.png)

#### 词法分析+语法分析

1. 词法分析(词法分析器)作用：将源文件转换为一个不包含空格，回车，换行等的Token序列。

   通过`cmd/compile/internal/syntax/scanner.go`扫描数据源文件来匹配对应的字符，跳过空格和换行等空白字符。

2. 语法分析(语法分析器)作用：将Token序列转为具有意义的结构体所组成的抽象语法树。

   使用`LALR(1)`文法解析Token，

#### 类型检查

按顺序检查语法树中定义和使用的类型，确保不存在类型匹配问题。（包括结构体对接口的实现等）

同时也会展开和改写一些内置函数如`make` 改写为`makechan`,`makeslice`,`makemap`等

拓展：

1. 强弱类型

   1. 强类型：类型错误在编译期间会被指出。`Go,Java`
   2. 弱类型：在运行时将类型错误进行隐式转换。`Js,PHP`

2. 静态类型检查和动态类型检查

   1. 静态类型检查：对源代码的分析来确定程序类型安全的过程，可以减少运行时的类型检查。
   2. 动态类型检查：编译时为所有对象添加类型标签之类的信息。运行时根据这些类型信息进行动态派发，向下转型，反射等特性。

   `Go Java`等都是两者相结合。比如接口像具体类型的转换等。。。

3. 执行过程

   1. 切片`OTARRAY`

      先对元素类型进行检查，再根据操作类型(`[]int,[...]int,[3]int`)的不同更新节点类型。

   2. 哈希表 `OTMAP`

      创建`TMAP`结构，存储哈希表的键值类型并检查是否存在类型不匹配的错误。

   3. 关键字 `OMAKE`

      根据`make`的第一个参数的类型进入不同的分支，然后更改当前节点的Op属性

      1. 切片:

         长度参数必须被传入，长度必须小于等于切片的容量。

      2. 哈希表:

         检查哈希表的可选初始容量大小

      3. Channel

         检查可选Channel初识缓冲大小

#### 中间代码生成

经过类型检查后，编译器并发编译所有go项目的函数生成中间代码，中间会对AST做一些替换工作。

![image-20220403174623630](https://raja-img.oss-cn-hangzhou.aliyuncs.com/img/image-20220403174623630.png)

go编译器中间代码使用`SSA`特性，会对无用的变量和片段进行优化。

细节：

1. 生成中间代码前编译器会替换一些抽象语法树中的元素。在遍历语法树时会将一些关键字和内置函数转化为函数调用。

   ![image-20220403182952672](https://raja-img.oss-cn-hangzhou.aliyuncs.com/img/image-20220403182952672.png)

#### 机器码生成

Go语言将SSA中间代码生成对应的目标机器码。

`GOOS=linux  GOARCH=amd64  go build main.go`

参数说明：

```
1. `GOOS`: 目标平台
    1. mac 对应 darwin
    2. linux 对应 linux
    3. windows 对应 windows
2. `GOARCH` ：目标平台的体系架构【386,amd64,arm】, 目前市面上的个人电脑一般都是amd64架构的
    1. 386 也称 x86 对应 32位操作系统
    2. amd64 也称 x64 对应 64位操作系统
    3. arm 这种架构一般用于嵌入式开发。比如 Android ， IOS ， Win mobile , TIZEN 等
```

go语言支持的架构：`AMD64,ARM,ARM64,MIPS,MIPS64,ppc64,s390x,x86,Wasm`

## 类型系统

![image-20220929135552902](https://raja-img.oss-cn-hangzhou.aliyuncs.com/img/image-20220929135552902.png)

### 分类

go语言数据类型分为`命名类型`和`未命名类型`

命名类型：`预声明的简单类型`和`自定义类型`

未命名类型（类型字面量）：`array,chan,slice,map,pointer,struct,interface,func`

注意：`未命名类型==类型字面两==复合类型`

### 底层类型

1. `预声明类型`和`类型字面量`的底层类型是自身

2. `自定义类型`的底层类型需要逐层向下查找

   ```go
   type new old // new 的底层类型和old的底层类型相同
   ```

![image-20220929140301377](https://raja-img.oss-cn-hangzhou.aliyuncs.com/img/image-20220929140301377.png)

> [仔细研究 Go(golang) 类型系统 - 知乎 (zhihu.com)](https://zhuanlan.zhihu.com/p/269025588)

### 类型相同

1. 两个`命名类型`：两个类型声明语句相同

   ```go
   var a int
   var b int
   //a 和 b类型相同
   var c A
   var d A
   //c 和 d类型相同
   ```

2. 两个`未命名`类型：声明时的`类型字面量`相同且`内部元素类型`相同

3. 别名：永远相同 `type myInt2 = int//起别名--myInt1和int完全相同`

4. `命名类型`和`未命名类型`：永远不同

### 类型赋值

```go
var a T1	//a的类型是T1
var b T2	//b的类型是T2
b = a		//如果成功说明a可以直接赋值b
```

可以赋值条件：

1. T1和T2类型相同

2. T1和T2具有相同的底层类型，且其中至少有一个是`未命名类型`

   ```go
   type mySlice []int
   var list1 mySlice //mySlice 命名类型
   var list2 []int	  //[]int   未命名类型
   list1 = list2	  //可以直接赋值
   ```

3. 接口类型看方法集，只要实现了就能赋值。

4. T1和T2的底层类型都是chan类型，且T1和T2至少有一个是`未命名类型`

   ```go
   	type T chan int // 相同元素类型
   	var t1 chan int // 未命名类型
   	var t2 T        // 命名类型
   	t2 = t1         // 成功赋值
   ```

5. nil可以赋值给`pointer,func,slice,map,chan,interface`

6. a是可以表示类型T1的常量值

   ```go
   	var a int32
   	a = 1
   ```

### 类型强制转换

Go是强类型语言,如果不满足自动类型转换的条件,则必须强制类型转换.

语法：`var a T = (T)(x)` 将x强制类型转换为T

非常量类型的变量x可以强制转化并传递给类型T,需要满足如下任一条件:

1. 可以`直接赋值`

2. `相同底层类型`.

3. x的类型和T都是`未命名的指针类型`，并且指针指向的类型具有`相同的底层类型`。

   ```go
   	type T1 int
   	type T2 T1
   	var p1 *T2      // *T2
   	var p2 *int     // *int
   	p2 = (*int)(p1) // 指针指向的底层类型都是int
   ```

4. x的类型和T`都是整型，或者都是浮点型`。

5. x的类型和T`都是复数类型`。

6. x是`整数值`或`[]byte`类型的值，T是`string`类型。

   ```go
   	s := string(123)
   	fmt.Println([]byte(s)) // [123]
   ```

7. x是一个`字符串`，T是`[]byte或[]rune`。

8. `浮点型,整型`之间可以强制类型转换(可能会损失数据精度)

### 类型方法

只有命名类型才有方法，且只能给当前包下的类型添加方法

#### 自定义类型

```go
struct {//这是一个未命名结构体类型
	name string
	age int
}
type Student struct{//Student是一个命名结构体类型
    name string
    age int
}
interface{//未命名接口类型
    eat()
}
type name interface {//name是一个命名接口类型
	eat()
}
```

#### 方法

Go语言类型方法是对类型行为的封装,GO语言的方法其实是特殊的函数,其将方法接收者作为函数第一个参数

```go
//类型接收者是值类型
func (t typeName)methodName(paramList)(ReturnList){
    //method body
}
//类型接收者是指针类型
func (t *typeName)methodName(paramList)(ReturnList){
    //method body
}
```

#### 方法调用

1. 一般调用:`实例.方法名(参数)`

   ```go
   s := Student{name: "张三", age: 19}//Student类型对象的创建和初始化
   s.eat()//调用方法
   ```

2. 类型字面量调用:`类型.方法(实例,参数)`

   ```go
   Student.eat(s)//因为方法其实就是特殊的函数
   
   //eat()方法转为函数
   func eat(s Student){
       fmt.Println(s.name, "正在吃饭")
   }
   ```

#### 方法调用时的类型转换

1. `一般调用`会根据`接受者类型`自动转换。`值->指针,指针->值`

   ```go
   type T struct {
   	a int
   }
   func (t T) VSet(n int) {
   	t.a = n
   }
   func (t *T) PointSet(n int) {
   	t.a = n
   }
   func method() {
   	t1 := T{a: 0}
   	t2 := T{a: 0}
   	(&t1).VSet(1)
   	fmt.Println(t1.a) // 0
   	t2.PointSet(1)
   	fmt.Println(t2.a) // 1
   }
   ```

2. `类型字面量`调用不自动转换

   ```go
   	pointer := &Data{"张三"}
   	value := Data{"张三"}
   	pointer := &Data{"张三"}
   	value := Data{"张三"}
   	(*Data).testPointer(pointer, 3) // 类型字面量 显式调用
   	(*Data).testValue(pointer, 3)   // 正常
   	Data.testValue(value, 3)
   	// Data.testPointer(pointer, 3) // 类型检查错误
   	// Data.testPointer(value, 3) 	// 类型检查错误
   	// Data.testPointer(pointer, 3) // 类型检查错误
   ```

### 类型断言

```go
i.(TypeName)
   i必须是接口变量
   TypeName可以是具体类型名或者接口类型名
      若TypeName是具体类型名:判断i所绑定的实例类型是否就是具体类型TypeName
      若TypeName是接口类型名:判断i所绑定的实例对象是否同时实现了TypeName接口
方式一:
   1. o := i.(TypeName) //不安全， 会panic()
      (1) TypeName是具体类型名,此时如果接口i绑定的实例类型就是具体类型TypeName,
         则变量o的类型就是TypeName,变量o的值就是i接口绑定的实例值的副本(当然实例可能是
         指针值,那就是指针值的副本)。
      (2) TypeName是接口类型名,如果接口i绑定的实例类型满足接口类型TypeName,则变
         量o的类型就是接口类型TypeName，o底层绑定的具体类型实例是i绑定的实例的副本(当然
         实例可能是指针值，那就是指针值的副本)。
      (3)如果上述两种情况都不满足，则程序抛出panic。
   2. o, ok := i.(TypeName) //安全
      o的类型和方法一一致,唯一不同在于方法一如果不匹配就panic(),而方法二可以避免
      (3)如果上述两个都不满足，则ok为false(满足一个就是true), 变量o是TypeName类型的“零值”，此种条
          件分支下程序逻辑不应该再去引用o，因为此时的o没有意义。
```

### 接口类型查询

```c
i必须是接口类型
如果case后面是一个接口类型名，且接口变量i绑定的实例类型实现了该接口类型的方法,则匹配成功，v的类型是接口类型，v底层绑定的实例是i绑定具体类型实例的副本.
```

```
switch v := i.(type){
case type1:
   ...
case type2:
   ...
...
}
```

## 数据结构

#### 数组

##### 初始化

```go
[5]int{1,2,3} //显式指定大小
[...]int{1,2,3}//隐式推导
```

1. 上限推导：编译器在编译时就会会确定元素个数来确定类型，所以两者在运行时没有区别。

2. 语句转换：

   由字面量组成的数组根据元素个数编译器在类型检查期间会做出两种优化（不考虑逃逸分析）

   1. 元素个数`n<=4`:直接在栈上赋值初始化

      ```go
      var arr [3]int
      arr[0] = 1
      arr[1] = 2
      arr[2] = 3
      ```

   2. 元素个数`n>4` :先在静态存储区初始化数组元素，并将临时变量赋值给数组（栈）。

      ```go
      var arr [5]int
      statictmp_0[0] = 1
      statictmp_0[1] = 2
      statictmp_0[2] = 3
      statictmp_0[3] = 4
      statictmp_0[4] = 5
      arr = statictmp_0
      ```

##### 访问和赋值

使用常量或整数直接访问数组会在类型检查期间进行数组越界分析，使用变量会在运行时检查。

#### 切片

动态数组，长度不固定，可以追加元素，它会在容量不足的情况下自动扩容。

##### 数据结构

```go
type SliceHeader struct {
   Data uintptr //指向底层数组
   Len  int //切片长度
   Cap  int //切片容量,Data数组长度
}
```

##### 初始化

```go
arr[0:3] or slice[0:3] //使用下标
slice := []int{1, 2, 3} //字面量
slice := make([]int, 10) //关键字
```

1. 使用下标

   创建一个指向底层数组的切片结构体。修改数据会影响底层数组。

2. 字面量

   编译时会展开为下列形式

   ```go
   var vstat [3]int //先创建数组
   vstat[0] = 1
   vstat[1] = 2
   vstat[2] = 3
   var vauto *[3]int = new([3]int)
   *vauto = vstat
   slice := vauto[:] //最后使用下标创建切片
   ```

3. 关键字

   1. 切片很小且不会发生逃逸，直接通过下标在栈或静态存储区创建。

      ```go
      // make([]int,3,4)
      var arr [4]int
      n := arr[:3]
      ```

   2. 切片较大或逃逸

      在堆上初始化切片 

4. new 相当于nil

   ```go
   	a := *new([]int)
   	// var a []int
   ```

##### 追加和扩容

append会在编译时期被当成一个TOKEN直接编译成汇编代码，因此append并不是在运行时调用的一个函数

```go
// expand append(l1, l2...) to
//   init {
//     s := l1
//     n := len(s) + len(l2)
//     // Compare as uint so growslice can panic on overflow.
//     if uint(n) > uint(cap(s)) {
//       s = growslice(s, n)
//     }
//     s = s[:n]
//     memmove(&s[len(l1)], &l2[0], len(l2)*sizeof(T))
//   }
//   s
//
```

```go
func growslice(et *_type, old slice, cap int) slice {
	newcap := old.cap
	doublecap := newcap + newcap
	if cap > doublecap {
		newcap = cap
	} else {
		if old.cap < 1024 {
			newcap = doublecap
		} else {
			// Check 0 < newcap to detect overflow
			// and prevent an infinite loop.
			for 0 < newcap && newcap < cap {
				newcap += newcap / 4
			}
			// Set newcap to the requested cap when
			// the newcap calculation overflowed.
			if newcap <= 0 {
				newcap = cap
			}
		}
	}
    
    var overflow bool
	var lenmem, newlenmem, capmem uintptr
	// Specialize for common values of et.size.
	// For 1 we don't need any division/multiplication.
	// For sys.PtrSize, compiler will optimize division/multiplication into a shift by a constant.
	// For powers of 2, use a variable shift.
	switch {
	case et.size == 1:
		lenmem = uintptr(old.len)
		newlenmem = uintptr(cap)
		capmem = roundupsize(uintptr(newcap))
		overflow = uintptr(newcap) > maxAlloc
		newcap = int(capmem)
	case et.size == sys.PtrSize:
		lenmem = uintptr(old.len) * sys.PtrSize
		newlenmem = uintptr(cap) * sys.PtrSize
		capmem = roundupsize(uintptr(newcap) * sys.PtrSize)
		overflow = uintptr(newcap) > maxAlloc/sys.PtrSize
		newcap = int(capmem / sys.PtrSize)
	case isPowerOfTwo(et.size):
		...
	default:
		...
	}
```

1. 期望长度不超过cap直接向后覆盖
2. 超过则扩容：为切片重新分配新的空间并复制原数组内容。
   1. 期望容量`newcap>2*cap` : 直接使用期望容量
   2. 当前切片长度<1024` :直接分配`2*cap`
   3. 当前切片长度>=1024`:每次增加`cap1.25倍`直到大于为止

然后根据切片中的元素大小对齐内存。如果元素所占字节大小为`1,2或8`的倍数时会根据`class_to_size数组`向上取整来提高内存分配效率减少碎片。

```go
var class_to_size = [_NumSizeClasses]uint16{0, 8, 16, 24, 32, 48, 64, 80, 96, 112, 128, 144, 160, 176,...]
```

例:

```go
var arr []int64 //元素占8字节
arr = append(arr, 1, 2, 3, 4, 5) //期望cap为5 期望分配5*8=40字节
fmt.Println(len(arr), cap(arr)) // 经过对齐分配48字节， cap为48/8=6
//5 6
```

##### 拓展表达式

`arr2 := arr1[start:end:max]`

指定arr2的容量为`max-start` 所以`max`不能超过`cap(arr1)`

```go
	arr := make([]int, 0, 5)//len=0 cap=5
	arr1 := arr[2:3] //len=1 cap=3 默认max=5
	arr2 := arr[2:3:4] //len=1 cap=2
	arr3 := arr[5:5:5] //len=0 cap=0
```

#### 哈希表

##### 设计原理

1. 哈希函数

   输出范围大于输入范围且结果需较为均匀

2. 处理哈希冲突

   1. 开放寻址法

      依次探测和比较数组中的元素来判断目标是否存在于哈希表中，冲突了就继续往后找位置

      ![image-20220403211523247](https://raja-img.oss-cn-hangzhou.aliyuncs.com/img/image-20220403211523247.png)
      $$
      装载因子 = 元素÷数组大小
      $$
      如果大于0.7则效率低下

   2. 拉链法

      1. 找到键相同的键值对 — 更新键对应的值；
      2. 没有找到键相同的键值对 — 在链表的末尾追加新的键值对；

      ![image-20220403212315105](https://raja-img.oss-cn-hangzhou.aliyuncs.com/img/image-20220403212315105.png)
      $$
      装载因子=元素数量÷桶数量
      $$
      在一般情况下使用拉链法的哈希表装载因子都不会超过 1

##### 数据结构

```go
// map数据结构 runtime/map.go/hmap
type hmap struct {
	count     int // # live cells == size of map.  Must be first (used by len() builtin)
	flags     uint8 // 并发
	B         uint8  // buckets桶个数为2^B次方
	noverflow uint16 // approximate number of overflow buckets; see incrnoverflow for details
	hash0     uint32 // hash seed

	buckets    unsafe.Pointer // array of 2^B Buckets. may be nil if count==0. bucket数组指针
	oldbuckets unsafe.Pointer // previous bucket array of half the size, non-nil only when growing
	nevacuate  uintptr        // progress counter for evacuation (buckets less than this have been evacuated)

	extra *mapextra // optional fields
}
```

![image-20220403212911988](https://raja-img.oss-cn-hangzhou.aliyuncs.com/img/image-20220403212911988.png)

```go
//bucket数据结构 runtime/map.go/bmap 运行时
type bmap struct {
    topbits  [8]uint8 //存储key hash高8位，用于快速查找到目标
    keys     [8]keytype
    values   [8]valuetype
    overflow uintptr //溢出桶
}
//每个bucket可以存储8个kv
```

##### 初始化

1. 字面量

   ```go
   	hash := map[string]int{
   		"1": 1,
   		"2": 2,
   		"3": 3,
   	}
   
   hash := make(map[string]int,3)
   hash["1"] = 1
   ...
   ```

   1. 元素个数`n<=25`：先`make`再挨个赋值
   2. 元素个数`n>25` ：先`make`再创建两个数组保存`k,v`然后使用for循环进行赋值

2. 运行时

   1. 当hash被分配在堆上且容量`n<8`则使用快速初始化hash表

      ```GO
      func makemap_small() *hmap {
      	h := new(hmap)
      	h.hash0 = fastrand()
      	return h
      }
      ```

   2. 否则：由传参元素个数`n`确定`B`

      1. 如果桶数`x = 2^B < 24` 不创建溢出桶
      2. 否则创建`2^(B-4)`个溢出桶

##### 读写操作

1. 查找

   1. 跟据key值算出哈希值
   2. 取哈希值低位与hmpa.B取模确定bucket位置
   3. 取哈希值高位在tophash数组中查询
   4. 如果tophash[i]中存储值也哈希值相等，则去找到该bucket中的key值进行比较
   5. 当前bucket没有找到，则继续从下个overflow的bucket中查找。
   6. 如果当前处于搬迁过程，则优先从oldbuckets查找

   注：如果查找不到，也不会返回空值，而是返回相应类型的0值。

2. 插入

   1. 跟据key值算出哈希值
   2. 取哈希值低位与hmap.B取模确定bucket位置
   3. 查找该key是否已经存在，如果存在则直接更新值
   4. 如果没找到将key插入

   如果当前bucket已满则使用预先创建的溢出桶或者新创建一个溢出桶来保存数据，溢出桶不仅会被追加到已有桶的末尾，还会增加`noverflow`的数量

##### 扩容

1. 装载因子`n > 6.5` 引发增量扩容

   创建2倍原`bucket`大小的`newbucket`放到`bucket`上，原`bucket`放到`oldbucket`上.

2. 溢出桶数量 `n > 2^15` 引发等量扩容

   和增量扩容的区别就是创建和原`bucket`等大小的新桶，最后清空旧桶和旧的溢出桶

如果处于扩容状态，每次插入或者删除时，就先搬迁1~2个kv到新桶（增量扩容分到两个桶，等量扩容分到一个桶）再继续，读会优先从旧桶读。因为分流不是原子的。

`tophash`可以用来加速访问（>=5表示hash高8位，否则表示标志位）

##### 为什么字符串不可修改

1. string通常指向字符串字面量存储在只读段，不可修改
2. map中可以使用string作为key，如果key可变则其实现会变得复杂

#### 字符串

##### 概念

```go
// string is the set of all strings of 8-bit bytes, conventionally but not
// necessarily representing UTF-8-encoded text. A string may be empty, but
// not nil. Values of string type are immutable.
type string string // string是8比特字节的集合，通常但并不一定是UTF-8编码的文本。
```

string可以为空（长度为0），但不会是nil；string对象不可以修改。

##### 数据结构

```go
type StringHeader struct {
	Data uintptr //指向底层数组的指针
	Len  int //数组大小
}
```

字符串分配到只读内存，所有的修改操作都是复制到切片然后修改

##### 拼接

拼接会先获取长度，然后开辟空间最后复制数据

##### 类型转换

一般两者之间直接转换会复制一遍，但`[]byte 转为 string`在某些情况下不会复制

1. 作为`map`的key进行临时查找
2. 字符串临时拼接时
3. 字符串比较时

强制类型转换会开辟新空间然后复制一遍

使用反射不需要开辟新空间(使用有风险)

```go
// String to Bytes
func UnsafeStringToBytes(str string) []byte {
	p := *(*reflect.StringHeader)(unsafe.Pointer(&str))
	b := reflect.SliceHeader{
		Data: p.Data,
		Len:  p.Len,
		Cap:  p.Len,
	}
	return *(*[]byte)(unsafe.Pointer(&b))
}
// Bytes to String
func UnsafeBytesToString(bs []byte) string {
	return *(*string)(unsafe.Pointer(&bs))
}
```

为什么字符串不能修改

	只读字段，map中的键

#### iota

##### 规则

iota代表了const声明块的行索引（下标从0开始）

##### 编译原理

const块中每一行在Go中使用`spec`数据结构描述，`spec`声明如下：

```go
    // A ValueSpec node represents a constant or variable declaration
    // (ConstSpec or VarSpec production).
    //
    ValueSpec struct {
        Doc     *CommentGroup // associated documentation; or nil
        Names   []*Ident      // value names (len(Names) > 0)
        Type    Expr          // value type; or nil
        Values  []Expr        // initial values; or nil
        Comment *CommentGroup // line comments; or nil
    }
```

这里我们只关注`ValueSpec.Names`， 这个切片中保存了一行中定义的常量，如果一行定义N个常量，那么`ValueSpec.Names`切片长度即为N。

`const`块实际上是`spec`类型的切片，用于表示`const`中的多行。

```go
    for iota, spec := range ValueSpecs {
        for i, name := range spec.Names {
            obj := NewConst(name, iota...) //此处将iota传入，用于构造常量
            ...
        }
    }
```

所以`iota`就是`const`的行索引。

## 语言特色

### 函数调用

#### C

```c
int func(int a1,int a2,...) int
{
    return ...;
}
```

参数<=6会使用寄存器传递，>6的参数会从右往左依次入栈。通过`eax`寄存器返回返回值.

#### Go

Go 语言完全使用栈来传递参数和返回值并由调用者负责清栈，通过栈传递返回值使得 Go 函数能支持多返回值，调用者清栈则可以实现可变参数的函数。Go 使用值传递的模式传递参数，因此传递数组和结构体时，应该尽量使用指针作为参数来避免大量数据拷贝从而提升性能。
　　Go 方法调用的时候是将接收者作为参数传递给了 callee，接收者分值接收者和指针接收者。
　　当传递匿名函数的时候，传递的实际上是函数的入口指针。当使用闭包的时候，Go 通过逃逸分析机制将变量分配到堆内存，变量地址和函数入口地址组成一个存在堆上的结构体，传递闭包的时候，传递的就是这个结构体的地址。
　　Go 的数据类型分为值类型和引用类型，但 Go 的参数传递是值传递。当传递的是值类型的时候，是完全的拷贝，callee 里对参数的修改不影响原值；当传递的是引用类型的时候，callee 里的修改会影响原值。
　　带返回值的 return 语句对应的是多条机器指令，首先是将返回值写入到 caller 在栈上为返回值分配的空间，然后执行 ret 指令。有 defer 语句的时候，defer 语句里的函数就是插入到 ret 指令之前执行。

### 闭包

当函数引用外部作用域的变量时，我们称之为闭包。在底层实现上，闭包由函数地址和引用到的变量的地址组成，并存储在一个结构体里，在闭包被传递时，实际是该结构体的地址被传递。因为栈帧上的值在该帧的函数退出后就失效了，因此闭包引用的外部作用域的变量会被分配到堆上。

#### defer

**defer 语句调用的函数的参数是在 defer 注册时求值或复制的**。因此局部变量作为参数传递给 defer 的函数语句后，后面对局部变量的修改将不再影响 defer 函数内对该变量值的使用。但是 defer 函数里使用非参数传入的外部函数的变量，将使用到该变量在外部函数生命周期内最终的值。

### 接口

一组方法签名的集合。其存在静态类型（绑定的实例的类型）和静态类型（方法签名）。注：类型指针接受者实现接口，类型自身不可进行初始化接口。类型自身实现接口，类型自身和类型指针均可初始化接口，且因为在调用方法时会对接受者进行复制，所以推荐指针接受者实现接口。

##### 数据结构

```go
//src/runtime/runtime2.go 

//非空接口
type iface struct {
	tab  *itab //用来存放接口自身类型和绑定的实例类型及实例相关的函数指针
	data unsafe.Pointer //数据
}

// layout of Itab known to compilers
// allocated in non-garbage-collected memory
// Needs to be in sync with
// ../cmd/compile/internal/gc/reflect.go:/^func.dumptabs.
type itab struct {
	inter *interfacetype //接口自身静态类型
	_type *_type // 数据类型
	hash  uint32 // copy of _type.hash. Used for type switches.
	_     [4]byte
	fun   [1]uintptr // variable sized. fun[0]==0 means _type does not implement inter.
}


//空接口
type eface struct {
	_type *_type //数据类型信息
	data  unsafe.Pointer //数据
}

// 类型信息
// Needs to be in sync with ../cmd/link/internal/ld/decodesym.go:/^func.commonsize,
// ../cmd/compile/internal/gc/reflect.go:/^func.dcommontype and
// ../reflect/type.go:/^type.rtype.
// ../internal/reflectlite/type.go:/^type.rtype.
type _type struct {
	size       uintptr // 类型占用的内存空间
	ptrdata    uintptr // size of memory prefix holding all pointers
	hash       uint32 // 用于判断类型是否相等
	tflag      tflag
	align      uint8
	fieldAlign uint8
	kind       uint8
	// function for comparing objects of this type
	// (ptr to object A, ptr to object B) -> ==?
	equal func(unsafe.Pointer, unsafe.Pointer) bool
	// gcdata stores the GC type data for the garbage collector.
	// If the KindGCProg bit is set in kind, gcdata is a GC program.
	// Otherwise it is a ptrmask bitmap. See mbitmap.go for details.
	gcdata    *byte
	str       nameOff
	ptrToThis typeOff
}
```

##### 类型转换

`interface = *struct`

结构体在堆上，接口中仅存放指针

`interface = struct`

结构体在栈上。

##### 动态派发

运行时（如果编译不能确定接口类型）选择具体方法执行的过程。

从接口中获取保存的方法指针然后再进行调用。

### 反射

反射是指在程序运行期对程序本身进行访问和修改的能力

```go
   reflect.TypeOf //能获取类型信息；
   reflect.ValueOf //能获取数据的运行时表示；
```

#### 三大法则

```go
//第一法则:反射可以将接口类型变量转换为反射对象
/*
      有了变量的类型之后，我们可以通过 Method 方法获得类型实现的方法，通过 Field 获取类型包含的全部字段。
   对于不同的类型，我们也可以调用不同的方法获取相关信息：

   结构体：获取字段的数量并通过下标和字段名获取字段 StructField；
   哈希表：获取哈希表的 Key 类型；
   函数或方法：获取入参和返回值的类型；
   …
*/
var x int64 = 4
fmt.Println(reflect.TypeOf(x), reflect.ValueOf(x))
//第二法则:反射可以把反射对象还原为接口对象
		/*
				不过调用 reflect.Value.Interface 方法只能获得 interface{} 类型的变量，
					如果想要将其还原成最原始的状态还需要经过如下所示的显式类型转换：

				v := reflect.ValueOf(1)
				v.Interface().(int)

			当然不是所有的变量都需要类型转换这一过程。
			如果变量本身就是 interface{} 类型的，那么它不需要类型转换，
			因为类型转换这一过程一般都是隐式的，所以我不太需要关心它，只有在我们需要将反射对象转换回基本类型时才需要显式的转换操作。
		*/
		var a interface{} = 4.0
		v := reflect.ValueOf(a) //反射对象
		b := v.Interface()      //接口对象
		fmt.Println(a == b)
		fmt.Println(reflect.TypeOf(a), reflect.TypeOf(b))
//第三法则:反射对象可修改,value值必须是可设置的
		/*
			func main() {
				i := 1
				v := reflect.ValueOf(i)
				v.SetInt(10)
				fmt.Println(i)
			}

			$ go run reflect.go
			panic: reflect: reflect.flag.mustBeAssignable using unaddressable value

			由于 Go 语言的函数调用都是传值的，所以我们得到的反射对象跟最开始的变量没有任何关系，那么直接修改反射对象无法改变原始变量，程序为了防止错误就会崩溃。
			想要修改原变量只能使用如下的方法：
		*/
		i := 1
		v = reflect.ValueOf(&i)
		v.Elem().SetInt(20) //必须是通过目标的指针对其修改
		fmt.Println(i)
```

```
当我们想要将一个变量转换成反射对象时，Go 语言会在编译期间完成类型转换，将变量的类型和值转换成了 interface{} 并等待运行期间使用 reflect 包获取接口中存储的信息。
```

#### 更新变量

```go
/*
   当我们想要更新 reflect.Value 时，就需要调用 reflect.Value.Set 更新反射对象，
   该方法会调用 reflect.flag.mustBeAssignable 和 reflect.flag.mustBeExported
   分别检查当前反射对象是否是可以被设置的以及字段是否是对外公开的：

   func (v Value) Set(x Value) {
      v.mustBeAssignable()   //是否可以被设置 即必须是一个指针所指向的
      x.mustBeExported()    //是否对外公开
      var target unsafe.Pointer
      if v.kind() == Interface {
         target = v.ptr
      }
      x = x.assignTo("reflect.Set", v.typ, target)
      typedmemmove(v.typ, v.ptr, x.ptr)
   }
*/
	fmt.Println("更新变量======")
	x := 3
	v := reflect.ValueOf(&x)
	v.Elem().Set(reflect.ValueOf(4))
	fmt.Println("更新结构体并获取未导出字段值")
	test1 := &test{test: 1}
	vtest := reflect.ValueOf(test1)
	vtest.Elem().Set(reflect.ValueOf(test{test: 2}))
	fmt.Println(vtest.Elem().FieldByName("test").Int())
```

#### 函数调用

```go
//函数调用
   /*
      1.通过 reflect.ValueOf 获取函数 Add 对应的反射对象；
      2.调用 reflect.rtype.NumIn 获取函数的入参个数；
      3.多次调用 reflect.ValueOf 函数逐一设置 argv 数组中的各个参数；
      4.调用反射对象 Add 的 reflect.Value.Call 方法并传入参数列表；
      5.获取返回值数组、验证数组的长度以及类型并打印其中的数据；
   */
   v := reflect.ValueOf(Add) //反射对象
   if v.Kind() != reflect.Func {
      return
   }
   t := v.Type()
   argv := make([]reflect.Value, t.NumIn()) //入参个数
   for i := range argv {
      if t.In(i).Kind() != reflect.Int {
         return
      }
      argv[i] = reflect.ValueOf(i) //填充参数
   }
   result := v.Call(argv) //调用方法
   if len(result) != 1 || result[0].Kind() != reflect.Int {
      return
   }
   fmt.Println(result[0].Int()) // #=> 1
```

#### 获取匿名字段

```go
func NiM(boy Boy) {
	t := reflect.TypeOf(boy)
	v := reflect.ValueOf(boy)
	fmt.Println(t, v)
	// Anonymous：匿名
	for i := 0; i < t.NumField(); i++ {
		fmt.Println(t.Field(i))
		// 值信息
		fmt.Println(v.Field(i))
	}
	fmt.Println(t.FieldByName("private"))
}
```

#### 设置字段值

```go
func SetValue(o interface{}) {
   v := reflect.ValueOf(o)
   newUser := User{
      Id:   19,
      Name: "raja",
      Age:  19,
   }
   // 设置值
   v.Elem().Set(reflect.ValueOf(newUser))
   fmt.Println(v.Elem())
   // 获取指针指向的元素
   v = v.Elem()
   // 取字段
   f := v.FieldByName("Name")
   if f.Kind() == reflect.String {
      f.SetString("Name")
   }
}
```

#### 调用方法

```go
func CallFunc(o interface{}) {
   v := reflect.ValueOf(o)
   // 获取方法 导出
   // fmt.Println(v.MethodByName("hello"))
   m := v.MethodByName("Hello")
   t := m.Type()
   // 构建参数
   args := make([]reflect.Value, t.NumIn())
   for i := 0; i < len(args); i++ {
      if t.In(i).Kind() != reflect.String {
         fmt.Println("Kind Err!")
         return
      }
      args[i] = reflect.ValueOf(strconv.Itoa(i))
   }
   m.Call(args)
}
```

#### 获取标签

```go
func GetTag(o interface{}) {
   v := reflect.ValueOf(o)
   t := v.Type()
   f := t.Field(0)
   fmt.Println(f.Tag.Get("json"))
}
```

## 常见关键字

### for range

使用`for range`最终都会转换为普通的`for`循环

#### 现象

1. 遍历数组时同时修改数组的元素（追加）,不会造成无限循环

   ```go
   func testSliceRange() {
   	nums := []int{1, 2, 3, 4}
   	for i := range nums {
   		nums = append(nums, 1)
   		fmt.Println(nums[i])
   	}
   }
   ```

2. `for _,v := range nums` 的 `v`是同一个变量

3. 遍历清空数组，切片，哈希表这些地址连续的结构时会直接选择清空这一片的内容

4. 使用`for range`遍历`map`时被引入随机性，强调不要依赖map的遍历顺序

#### 循环结构

```go
// 经典循环
for Ninit ; Left ; Right {
    NBody
}
```

编译器会在编译期间把所有`for range`转换为经典循环。

##### 数组和切片

1. 遍历数组或者切片清空元素

   直接调用`runtime.memclrNoHeapPointers`清空全部数据并更新遍历数组的索引

2. `for range a {}` 直接转换为下列形式

   ```go
   ha := a // 复制数组
   hv1 := 0
   hn := len(ha) // 获取长度
   v1 := hv1
   for ; hv1 < hn; hv1++ {
       ...
   }
   ```

3. `for i := range a {}` 在循环体中添加了 `v1 = hv1` 语句，传递遍历数组时的索引

   ```go
   ha := a
   hv1 := 0
   hn := len(ha)
   v1 := hv1
   for ; hv1 < hn; hv1++ {
       v1 = hv1
       ...
   }
   ```

4. `for i,v := range a {}`  循环使用v变量

   ```go
   ha := a
   hv1 := 0
   hn := len(ha)
   v1 := hv1 // 下标
   v2 := nil // 值
   for ; hv1 < hn; hv1++ {
       tmp := ha[hv1]
       v1, v2 = hv1, tmp
       ...
   }
   ```

##### 哈希表

编译器会根据 `range` 返回值的数量在循环体中插入需要的赋值语句：

![golang-range-map](https://raja-img.oss-cn-hangzhou.aliyuncs.com/img/2020-01-17-15792766877639-golang-range-map.png)

例如 k,v情况

```go
ha := a
hit := hiter(n.Type)
th := hit.Type
mapiterinit(typename(t), ha, &hit)
for ; hit.key != nil; mapiternext(&hit) {
    key := *hit.key
    val := *hit.val
}
```

遍历方式：随机选一个起始桶，遍历桶中元素，再遍历溢出桶，再遍历下一个桶，直到回到最开始。

![golang-range-map-and-buckets](https://raja-img.oss-cn-hangzhou.aliyuncs.com/img/2020-01-17-15792766877646-golang-range-map-and-buckets.png)

注意：哈西表的遍历时插入是随机的，不保证是否会被遍历到。

##### 字符串

遍历时会获取字符串的索引对应字节转换为rune类型，并更新索引。

```go
ha := s
for hv1 := 0; hv1 < len(ha); {
    hv1t := hv1
    hv2 := rune(ha[hv1])
    if hv2 < utf8.RuneSelf { // ascii
        hv1++
    } else {
        hv2, hv1 = decoderune(ha, hv1) // unicode
    }
    v1, v2 = hv1t, hv2
}
```

##### channel

`for v := range ch {}` 会被转换为下列，(channel关闭了会结束,没数据会阻塞)

```go
ha := a
hv1, hb := <-ha
for ; hb != false; hv1, hb = <-ha { // 会判断是否close
    v1 := hv1
    hv1 = nil
    ...
}
```

### select

#### 现象

1. 非阻塞收发操作

   如果存在可收发的channel时会直接处理该channel对应的操作

   如果不存在上述情况，且存在`default` 则执行`default`语句

2. 多个channel同时响应会随机选一个执行

   为了避免饥饿问题发生

#### 实现原理

`select` 语句在编译期间会被转换成 `OSELECT` 节点。每个 `OSELECT` 节点都会持有一组 `OCASE` 节点，如果 `OCASE` 的执行条件是空，那就意味着这是一个 `default` 节点。

![golang-oselect-and-ocases](https://raja-img.oss-cn-hangzhou.aliyuncs.com/img/2020-01-18-15793463657473-golang-oselect-and-ocases.png)

编译器会根据select中case的不同做出不同优化

1. `select`中没有`case`

   直接调用`runtime.block()`阻塞

2. `select`中只有一个`case`

   转换为`if`语句

   ```go
   if ch == nil { // nil 直接阻塞
       block()
   }
   v, ok := <-ch // case ch <- v
   ```

3. `select` 存在两个 `case`，其中一个 `case` 是 `default`

   非阻塞接发消息。

4. `select` 存在多个 `case`

   默认情况下：

   将所有的 `case` 转换成包含 Channel 以及类型等信息的 [`runtime.scase`](https://draveness.me/golang/tree/runtime.scase) 结构体

   ```go
   type scase struct {
   	c    *hchan         // chan
   	elem unsafe.Pointer // data element
   }
   ```

   1. 随机生成一个遍历的轮询顺序 `pollOrder` (防止饥饿)并根据 Channel 地址排序生成锁定顺序 `lockOrder`(防止死锁)；

      注意如果尝试写入数据到已经关闭的channel则会panic

   2. 根据`pollOrder`遍历所有的`case`查看是否有可以立刻处理的 Channel；

      1. 如果存在，直接获取 `case` 对应的索引并返回；
      2. 如果不存在，创建 [`runtime.sudog`](https://draveness.me/golang/tree/runtime.sudog) 结构体，将当前 Goroutine 加入到所有相关 Channel 的收发队列，并调用 [`runtime.gopark`](https://draveness.me/golang/tree/runtime.gopark) 挂起当前 Goroutine 等待调度器的唤醒；

   3. 当调度器唤醒当前 Goroutine 时，会再次按照 `lockOrder` 遍历所有的 `case`，从中查找需要被处理的 [`runtime.sudog`](https://draveness.me/golang/tree/runtime.sudog) 对应的case索引，之后会吧其他sudog从剩余channel中释放。

### defer

使用 `defer` 的最常见场景是在函数调用结束后完成一些收尾工作，例如在 `defer` 中回滚数据库的事务：

#### 规则

1. 延迟函数执行按后进先出顺序执行，即先出现的defer最后执行

   定义defer类似于入栈操作，执行defer类似于出栈操作。

2. 延迟函数的参数在defer语句出现时就已经确定下来了

   ```go
   func deferFuncParameter() {
       var aInt = 1
       defer fmt.Println(aInt)
       aInt = 2
       return
   }
   // output: 1
   ```

3. 延迟函数可能操作主函数的具名返回值

   ```go
   func deferFuncReturn() (ret int) {
       i := 1
       defer func() {
          result++
       }()
       return i
   }
   // output: 2
   // ret = i ; defer ; return
   ```

#### 数据结构

```go
type _defer struct {
	siz       int32 	// 参数和结果的内存大小
	openDefer bool 		// 表示当前 defer 是否经过开放编码的优化；
	sp        uintptr 	// 函数栈指针
	pc        uintptr 	// 程序计数器
	fn        *funcval 	// 函数地址
	_panic    *_panic 	// 是触发延迟调用的结构体，可能为空
	link      *_defer 	// 指向自身结构的指针，用于链接多个defer
}
```

![image-20220511133528416](https://raja-img.oss-cn-hangzhou.aliyuncs.com/img/image-20220511133528416.png)

#### 执行机制

根据条件不同分为`堆中分配`，`栈中分配`，`开放编码`

##### 堆中分配 [兜底方案] 1.1 ~ 1.12

- 编译期将 `defer` 关键字转换成 [`runtime.deferproc`](https://draveness.me/golang/tree/runtime.deferproc) 并在调用 `defer` 关键字的函数返回之前插入 [`runtime.deferreturn`](https://draveness.me/golang/tree/runtime.deferreturn)；
- 运行时调用 [`runtime.deferproc`](https://draveness.me/golang/tree/runtime.deferproc) 会将一个新的 [`runtime._defer`](https://draveness.me/golang/tree/runtime._defer) 结构体追加到当前 Goroutine 的链表头；
- 运行时调用 [`runtime.deferreturn`](https://draveness.me/golang/tree/runtime.deferreturn) 会从 Goroutine 的链表中取出 [`runtime._defer`](https://draveness.me/golang/tree/runtime._defer) 结构并依次执行；

##### 栈中分配 [函数中出现最多一次] 1.13

编译器会将 `runtime._defer`分配到栈上

##### 开放编码 [defer <= 8，return * defer <=15] 1.14

使用代码内联优化`defer`关键字.

1. 启动优化(条件判断)

2. 延迟记录

   编译期间在栈上创建8bit的延迟比特数组。每一位表示对应的defer是否需要被执行

3. 执行

   如果defer的执行可以在编译时确定则直接插入bits位判断并执行函数到返回前。否则在运行中判断。

### panic 和 recover

1. 编译器会负责做转换关键字的工作；
   1. 将 `panic` 和 `recover` 分别转换成 [`runtime.gopanic`](https://draveness.me/golang/tree/runtime.gopanic) 和 [`runtime.gorecover`](https://draveness.me/golang/tree/runtime.gorecover)；
   2. 将 `defer` 转换成 [`runtime.deferproc`](https://draveness.me/golang/tree/runtime.deferproc) 函数；
   3. 在调用 `defer` 的函数末尾调用 [`runtime.deferreturn`](https://draveness.me/golang/tree/runtime.deferreturn) 函数；
2. 在运行过程中遇到 [`runtime.gopanic`](https://draveness.me/golang/tree/runtime.gopanic) 方法时，会从 Goroutine 的链表依次取出 [`runtime._defer`](https://draveness.me/golang/tree/runtime._defer) 结构体并执行；
3. 如果调用延迟执行函数时遇到了`runtime.gorecover`就会将`_panic.recovered`标记成 true 并返回`panic`的参数；
   1. 在这次调用结束之后，[`runtime.gopanic`](https://draveness.me/golang/tree/runtime.gopanic) 会从 [`runtime._defer`](https://draveness.me/golang/tree/runtime._defer) 结构体中取出程序计数器 `pc` 和栈指针 `sp` 并调用 [`runtime.recovery`](https://draveness.me/golang/tree/runtime.recovery) 函数进行恢复程序；
   2. [`runtime.recovery`](https://draveness.me/golang/tree/runtime.recovery) 会根据传入的 `pc` 和 `sp` 跳转回 [`runtime.deferproc`](https://draveness.me/golang/tree/runtime.deferproc)；
   3. 编译器自动生成的代码会发现 [`runtime.deferproc`](https://draveness.me/golang/tree/runtime.deferproc) 的返回值不为 0，这时会跳回 [`runtime.deferreturn`](https://draveness.me/golang/tree/runtime.deferreturn) 并恢复到正常的执行流程；
4. 如果没有遇到 [`runtime.gorecover`](https://draveness.me/golang/tree/runtime.gorecover) 就会依次遍历所有的 [`runtime._defer`](https://draveness.me/golang/tree/runtime._defer)，并在最后调用 [`runtime.fatalpanic`](https://draveness.me/golang/tree/runtime.fatalpanic) 中止程序、打印 `panic` 的参数并返回错误码 2；

### make 和 new

`make` 初始化内置的数据结构，`chan，map，chan`。

`new` 只接受一个参数，这个参数是一个类型，分配好内存后，返回一个指向该类型内存地址的指针。同时请注意它同时把分配的内存置为零，也就是类型的零值。

都会先进行逃逸分析，然后再进行内存分配。

## 并发编程

### 乐观锁，悲观锁

存在共享资源X需要被多个线程修改，分为3步

1. 取值，2. 修改，3. 写入

#### 悲观锁

每次操作都先获取锁，操作完再释放锁。

#### 乐观锁

前两步正常进行，第三步完了再判断下是否进行了修改，修改了就重新走一遍或者放弃。

atomic可以在不形成临界区和创建互斥量的情况下完成并发安全的值替换操作，这个包应用的便是乐观锁的原理

#### CAS 

CAS用来确保在乐观锁下对某一共享变量的操作没有被其他线程修改过。

CAS（V，A，B）：内存位置（V）、预期原值（A）和新值 (B)，如果内存地址里面的值和 A 的值是一样的，那么就将内存里面的值更新成 B。CAS 是通过无限循环来获取数据的，若果在第一轮循环中，a 线程获取地址里面的值被 b 线程修改了，那么 a 线程需要自旋，到下次循环才有可能机会执行。

```go
while(!swapped) {
    swapped = CAS(V, E, N)
    sleep(1)
}
```

问题：

1. 自旋锁：可能造成开销大
2. ABA：需要每次更新版本号来确保中途变量没有被修改

### 死锁

发生的必要条件，打破任意一个即可。

1. **互斥**：解决临界区安全（不考虑破坏）。
2. **占有且等待**：一个进程因请求资源而阻塞时，对已占有的资源不释放。
3. **不可抢占**：进程已获得的资源，在未使用之前，不能强行剥夺(抢夺资源)。
4. **循环等待**：若干进程之间形成一种头尾相接的循环等待的资源关闭(死循环)。

解决方法：

1. **占有且等待**：所有的进程在开始运行之前，必须一次性的申请其在整个运行过程各种所需要的全部资源。
2. **不可抢占**：当持有一定资源的线程在无法申请到新的资源时必须释放已有的资源，待以后需要使用的时候再重新申请
3. **循环等待**：规定资源的申请顺序

### 并发哲学

CSP通信顺序进程（在进程之间正确通信）作为Go的核心思想之一，让并发程序更容易被编写和理解。

**通过通信来共享内存,而不是通过共享内存来通信**

`mutex`和`channel`的选择

![image-20221002084724528](https://raja-img.oss-cn-hangzhou.aliyuncs.com/img/image-20221002084724528.png)

当然如果只是为了保护某个变量的操作的原子性，完全可以使用`atomic`进行原子更新，`mutex`常用于维护某个代码片段。

### atomic

```go
// TSL
// 
// old = *addr
// *addr = new
// return old
func SwapInt32(addr *int32, new int32) (old int32)
func SwapInt64(addr *int64, new int64) (old int64)
func SwapUint32(addr *uint32, new uint32) (old uint32)
func SwapUint64(addr *uint64, new uint64) (old uint64)
func SwapUintptr(addr *uintptr, new uintptr) (old uintptr)
func SwapPointer(addr *unsafe.Pointer, new unsafe.Pointer) (old unsafe.Pointer)

// FAA
// 
// *addr += delta
// return *addr
func AddInt32(addr *int32, delta int32) (new int32)
func AddUint32(addr *uint32, delta uint32) (new uint32)
func AddInt64(addr *int64, delta int64) (new int64)
func AddUint64(addr *uint64, delta uint64) (new uint64)
func AddUintptr(addr *uintptr, delta uintptr) (new uintptr)

// CAS
// 
// if *addr == old {
//     *addr = new
//     return true
// }
// return false
func CompareAndSwapInt32(addr *int32, old, new int32) (swapped bool)
func CompareAndSwapInt64(addr *int64, old, new int64) (swapped bool)
func CompareAndSwapUint32(addr *uint32, old, new uint32) (swapped bool)
func CompareAndSwapUint64(addr *uint64, old, new uint64) (swapped bool)
func CompareAndSwapUintptr(addr *uintptr, old, new uintptr) (swapped bool)
func CompareAndSwapPointer(addr *unsafe.Pointer, old, new unsafe.Pointer) (swapped bool)

// Read
func LoadInt32(addr *int32) (val int32)
func LoadInt64(addr *int64) (val int64)
func LoadUint32(addr *uint32) (val uint32)
func LoadUint64(addr *uint64) (val uint64)
func LoadUintptr(addr *uintptr) (val uintptr)
func LoadPointer(addr *unsafe.Pointer) (val unsafe.Pointer)

// Write
func StoreInt32(addr *int32, val int32)
func StoreInt64(addr *int64, val int64)
func StoreUint32(addr *uint32, val uint32)
func StoreUint64(addr *uint64, val uint64)
func StoreUintptr(addr *uintptr, val uintptr)
func StorePointer(addr *unsafe.Pointer, val unsafe.Pointer)

// https://juejin.cn/post/6907091130039894023
```

##### atomic.Value

```go
// 零值为nil 使用后不允许被拷贝
type Value struct {
    v interface{} // ifaceWords
}

type ifaceWords struct {
    // 类型
    typ  unsafe.Pointer
    // 值
    data unsafe.Pointer
}

// 不能存 nil，存一次后类型就固定了
func (v *Value) Store(val interface{}) {
	if val == nil {
		panic("sync/atomic: store of nil value into Value")
	}
	vp := (*ifaceWords)(unsafe.Pointer(v))
	vlp := (*ifaceWords)(unsafe.Pointer(&val))
	// 抢占乐观锁
	for {
		typ := LoadPointer(&vp.typ)
		if typ == nil {
			// 禁止当前 P 被抢占
			runtime_procPin()
			// 调用CAS抢占乐观锁,没抢到就继续
			if !CompareAndSwapPointer(&vp.typ, nil, unsafe.Pointer(^uintptr(0))) {
				runtime_procUnpin()
				continue
			}
			// 存储值和类型
			// Complete first store.
			StorePointer(&vp.data, vlp.data)
			StorePointer(&vp.typ, vlp.typ)
			runtime_procUnpin()
			return
		}
		// 判断是否还在抢占乐观锁
		if uintptr(typ) == ^uintptr(0) {
			continue
		}
		// First store completed. Check type and overwrite data.
		if typ != vlp.typ {
			panic("sync/atomic: store of inconsistently typed value into Value")
		}
        // 只需要存值就系
		StorePointer(&vp.data, vlp.data)
		return
	}
}

func (v *Value) Load() (val interface{}) {
	vp := (*ifaceWords)(unsafe.Pointer(v))
	typ := LoadPointer(&vp.typ)
	if typ == nil || uintptr(typ) == ^uintptr(0) {
		// First store not yet completed.
		return nil
	}
	data := LoadPointer(&vp.data)
	vlp := (*ifaceWords)(unsafe.Pointer(&val))
	vlp.typ = typ
	vlp.data = data
	return
}
```

这里就是先判断之前是否已经存了，存了就直接原子存值就行，否则需要CAS抢占乐观锁并且禁止P被调度，然后存值和类型。

### context

建议直接看这个<a href="https://www.bookstack.cn/read/GoExpertProgramming/chapter05-5.3-context.md">《go专家编程》context 实现</a>

#### Context

```go
type Context interface {
	Deadline() (deadline time.Time, ok bool) // 返回 context.Context 被取消的时间，也就是完成工作的截止日期；
	Done() <-chan struct{} // 返回一个只读Channel，context关闭后关闭这个channel
	Err() error // 返回 context.Context 结束的原因，它只会在 Done 方法对应的 Channel 关闭时返回非空的值；
	// 如果 context.Context 被取消，会返回 Canceled 错误；
	// 如果 context.Context 超时，会返回 DeadlineExceeded 错误；
	Value(key interface{}) interface{} // 用于父子上下文之间传递数据
}
```

```go
type emptyCtx int

var (
	background = new(emptyCtx)
	todo       = new(emptyCtx)
)
```

`emptyCtx`只是一个实现了`Context`的结构,可以作为`context`的根节点

context 包中实现 Context 接口的 `emptyCtx`，除了 emptyCtx 外，还有 `cancelCtx`、`timerCtx` 和 `valueCtx` 三种，正是基于这三种 context 实例，实现了上述 4 种类型的 context。

![5.3 Context - 图2](https://static.sitestack.cn/projects/GoExpertProgramming/chapter05/images/context-02-relation.png)

#### cancelCtx

```go
type cancelCtx struct {
	Context

	mu       sync.Mutex            // protects following fields
	done     atomic.Value          // of chan struct{}, created lazily, closed by first cancel call
	children map[canceler]struct{} // set to nil by the first cancel call
	err      error                 // set to non-nil by the first cancel call
}
```

`cancelCtx`被取消后会`cancel()`它的所有`child`

1. `Done()`

   ```go
   func (c *cancelCtx) Done() <-chan struct{} {
      d := c.done.Load()
      if d != nil {
         return d.(chan struct{})
      }
      c.mu.Lock()
      defer c.mu.Unlock()
      d = c.done.Load()
      if d == nil {
         d = make(chan struct{}) // 懒汉模式创建
         c.done.Store(d)
      }
      return d.(chan struct{})
   }
   ```

2. `Err()`

   ```go
   func (c *cancelCtx) Err() error {
      c.mu.Lock()
      err := c.err
      c.mu.Unlock()
      return err
   }
   ```

3. `cancel ()`

   ```go
   // cancel closes c.done, cancels each of c's children, and, if
   // removeFromParent is true, removes c from its parent's children.
   ```

   ```go
   func (c *cancelCtx) cancel(removeFromParent bool, err error) {
   	if err == nil {
   		panic("context: internal error: missing cancel error")
   	}
   	c.mu.Lock()
   	if c.err != nil {
   		c.mu.Unlock()
   		return // already canceled
   	}
   	c.err = err
   	d, _ := c.done.Load().(chan struct{})
   	if d == nil {
   		c.done.Store(closedchan) // 放入关闭的channel
   	} else {
   		close(d) // 关闭channel
   	}
   	// 通知下游
   	for child := range c.children {
   		// NOTE: acquiring the child's lock while holding parent's lock.
   		child.cancel(false, err)
   	}
   	// 删除下游
   	c.children = nil
   	c.mu.Unlock()
   
   	// 删除上游
   	if removeFromParent {
   		removeChild(c.Context, c)
   	}
   }
   ```

   如果多次`cancel`直接返回，否则`close channel`，之后`cancel`并删除下游，最后判断是否需要将自己与上游断开

4. `WithCancel()`

   ```go
   func WithCancel(parent Context) (ctx Context, cancel CancelFunc) {
      if parent == nil {
         panic("cannot create context from nil parent")
      }
      c := newCancelCtx(parent) // 初始化cancel实例
      propagateCancel(parent, &c) // 将 cancelCtx 实例添加到其父节点的 children 中 (如果父节点也可以被 cancel 的话)
      return &c, func() { c.cancel(true, Canceled) } // 返回 cancelCtx 实例和 cancel () 方法
   }
   ```

   1. 添加这一步，如果父节点支持`cancel`则添加自己到上游
   2. 如果父节点不支持`cancel`则记录并启动一个新`go程`来监听父节点`Done()`并`cancel`当前ctx

#### timerCtx

```go
type timerCtx struct {
   cancelCtx
   timer *time.Timer // Under cancelCtx.mu.

   deadline time.Time
}
```

timerCtx 在 cancelCtx 基础上增加了 deadline 用于标示自动 cancel 的最终时间，而 timer 就是一个触发自动 cancel 的定时器。

由此，衍生出 WithDeadline () 和 WithTimeout ()。实现上这两种类型实现原理一样，只不过使用语境不一样：

- deadline: 指定最后期限，比如 context 将 2018.10.20 00:00:00 之时自动结束
- timeout: 指定最长存活时间，比如 context 将在 30s 后结束。

对于接口来说，timerCtx 在 cancelCtx 基础上还需要实现 Deadline () 和 cancel () 方法，其中 cancel () 方法是重写的。

1. `cancel()`

   ```go
   func (c *timerCtx) cancel(removeFromParent bool, err error) {
      c.cancelCtx.cancel(false, err)
      if removeFromParent {
         // Remove this timerCtx from its parent cancelCtx's children.
         removeChild(c.cancelCtx.Context, c)
      }
      c.mu.Lock()
      if c.timer != nil {
         c.timer.Stop()
         c.timer = nil
      }
      c.mu.Unlock()
   }
   ```

   和`cancelCtx`差不多，但是最后需要停止`timer`

2. `WithTimeout`

   ```go
   func WithTimeout(parent Context, timeout time.Duration) (Context, CancelFunc) {
      return WithDeadline(parent, time.Now().Add(timeout))
   }
   
   func WithDeadline(parent Context, d time.Time) (Context, CancelFunc) {
   	if parent == nil {
   		panic("cannot create context from nil parent")
   	}
   	if cur, ok := parent.Deadline(); ok && cur.Before(d) {
   		// The current deadline is already sooner than the new one.
   		return WithCancel(parent)
   	}
   	c := &timerCtx{
   		cancelCtx: newCancelCtx(parent),
   		deadline:  d,
   	}
   	propagateCancel(parent, c)
   	dur := time.Until(d)
   	if dur <= 0 {
   		c.cancel(true, DeadlineExceeded) // deadline has already passed
   		return c, func() { c.cancel(false, Canceled) }
   	}
   	c.mu.Lock()
   	defer c.mu.Unlock()
   	if c.err == nil {
   		c.timer = time.AfterFunc(dur, func() {
   			c.cancel(true, DeadlineExceeded)
   		})
   	}
   	return c, func() { c.cancel(true, Canceled) }
   }
   ```

   - 判断当前截止日期是否比新的早
   - 初始化一个 timerCtx 实例
   - 将 timerCtx 实例添加到其父节点的 children 中 (如果父节点也可以被 cancel 的话)
   - 启动定时器，定时器到期后会自动 cancel 本 context，然后从父节点删除
   - 返回 timerCtx 实例和 cancel () 方法

#### valueCtx

```go
type valueCtx struct {
   Context
   key, val interface{}
}
```

valueCtx 只是在 Context 基础上增加了一个 key-value 对，用于在各级协程间传递一些数据。

由于 valueCtx 既不需要 cancel，也不需要 deadline，那么只需要实现 Value () 接口即可。

1. `WithValue`

   ```go
   func WithValue(parent Context, key, val interface{}) Context {
      if parent == nil {
         panic("cannot create context from nil parent")
      }
      if key == nil {
         panic("nil key")
      }
      if !reflectlite.TypeOf(key).Comparable() {
         panic("key is not comparable")
      }
      return &valueCtx{parent, key, val}
   }
   ```

2. `Value`

   ```go
   func (c *valueCtx) Value(key interface{}) interface{} {
   	if c.key == key {
   		return c.val
   	}
   	return c.Context.Value(key)
   }
   ```

   当前ctx没有则去上游ctx寻找

###  同步原语和锁

#### 互斥锁

##### 数据结构

```go
type Mutex struct {
	state int32  //互斥锁的状态 waiter(29)阻塞协程数 starving(是否饥饿) woken(是否有协程被唤醒) locked(是否被锁定)
	sema  uint32 //信号量
}
```

![golang-mutex-state](https://img.draveness.me/2020-01-23-15797104328010-golang-mutex-state.png)

在默认情况下，互斥锁的所有状态位都是 0，`int32` 中的不同位分别表示了不同的状态：

- `mutexLocked` — 表示互斥锁的锁定状态；
- `mutexWoken` — 表示从正常模式被从唤醒；
- `mutexStarving` — 当前的互斥锁进入饥饿状态；
- `waitersCount` — 当前互斥锁上等待的 Goroutine 个数；

##### 加锁

```go
func (m *Mutex) Lock() {
	// Fast path: grab unlocked mutex.
	if atomic.CompareAndSwapInt32(&m.state, 0, mutexLocked) {
		return
	}
	// Slow path (outlined so that the fast path can be inlined)
	m.lockSlow()
}
```

1. `CAS`尝试将locked=1加锁成功
2. 判断是否可以自旋
   1. 可以自旋就将`woken`置为1,然后空转尝试获取锁
   2. 否则就直接阻塞等待被唤醒

##### 解锁

```go
func (m *Mutex) Unlock() {
   // Fast path: drop lock bit.
   new := atomic.AddInt32(&m.state, -mutexLocked)
   if new != 0 {
      // Outlined slow path to allow inlining the fast path.
      // To hide unlockSlow during tracing we skip one extra frame when tracing GoUnblock.
      m.unlockSlow(new)
   }
}
```

1. 饥饿模式下会直接把锁给下一个等待者
2. 普通模式下如果没有等待的协程，就选择唤醒等待者（有的话）或者直接返回

##### 自旋

1. 好处

   更充分的利用CPU，尽量避免协程切换

2. 自旋条件;

   1. 多CPU
   2. 当前协程为了获取此锁进入自旋数量<4
   3. 当前机器上至少存在一个正在运行的处理器P且其运行队列为空
      总结：当CPU闲着的时候可以让它忙一下。

##### 饥饿模式

   当自旋的协程每次都抢到锁，为了防止正常阻塞的等待锁的协程不被饿死，当协程等待时间超过1ms时就会启动饥饿模式，处于饥饿模式下，不会启动自旋过程，也即一旦有协程释放了锁，那么一定会唤醒协程，被唤醒的协程将会成功获取锁，同时也会把等待计数减1。
   如果当前协程是最后一个协程或者等待时间小于1ms就恢复为普通模式

#### 读写锁

##### 数据结构

```go
type RWMutex struct {
	w           Mutex  // held if there are pending writers
	writerSem   uint32 // 写阻塞等待的信号量，最后一个读协程释放锁后会释放
	readerSem   uint32 // 读阻塞等待的信号量，持有写锁的协程释放锁后会释放
	readerCount int32  // 正在读协程的个数
	readerWait  int32  // 写阻塞时读协程的个数
}

const rwmutexMaxReaders = 1 << 30
```

##### 写锁

```go
func (rw *RWMutex) Lock() {
   // First, resolve competition with other writers.
   rw.w.Lock()
   // 通过将readerCount变为负值，阻塞后续访问的reader
   r := atomic.AddInt32(&rw.readerCount, -rwmutexMaxReaders) + rwmutexMaxReaders
   // 记录当前reader的数量，然后阻塞
   if r != 0 && atomic.AddInt32(&rw.readerWait, r) != 0 {
      runtime_SemacquireMutex(&rw.writerSem, false, 0)
   }
}
```

先将`readerCount`变为负值阻止之后的读然后等待现有的读结束。同时将当前的读数量记录到`readerWait`

##### 写解锁

```go
func (rw *RWMutex) Unlock() {
   // 恢复正值，释放后续的reader
   r := atomic.AddInt32(&rw.readerCount, rwmutexMaxReaders)
   // 唤醒已经阻塞的reader
   for i := 0; i < int(r); i++ {
      runtime_Semrelease(&rw.readerSem, false, 0)
   }
   // Allow other writers to proceed.
   rw.w.Unlock()
}
```

先将`readerCount`变正然后唤醒之前的读，然后解锁

##### 读锁

```go
func (rw *RWMutex) RLock() {
   // 增加reader数,如果是负数说明前面有write，则阻塞
   if atomic.AddInt32(&rw.readerCount, 1) < 0 {
      // A writer is pending, wait for it.
      runtime_SemacquireMutex(&rw.readerSem, false, 0)
   }
}
```

将 `readerCount`+1同时判断如果小于0说明在此之前有写操作就阻塞，否则就执行写

##### 读解锁

```go
func (rw *RWMutex) RUnlock() {
   // 减少reader数，并判断如果是最后一个reader则释放writer
   if r := atomic.AddInt32(&rw.readerCount, -1); r < 0 {
      // Outlined slow-path to allow the fast-path to be inlined
      rw.rUnlockSlow(r)
   }
}
```

将 `readerCount`-1同时判断如果小于0说明有写锁，之后将`readerWait`-1同时判断如果自己是最后一个阻塞写的读就唤醒写。

使用`channel`实现

```go
const RWMutexMaxReaders = 1 << 30 //一个无法达到的最大读数量

type RWMutex struct {
	mu          chan struct{} //互斥锁
	readerCount int32 // 读数量
	readerWait  int32 // 写等待的读的数量
	wchan       chan struct{} //用于唤醒等待读的写
	rchan       chan struct{} //用于唤醒等待写的读
}

func NewRWMutex() *RWMutex {
	return &RWMutex{mu: make(chan struct{}, 1), wchan: make(chan struct{}), rchan: make(chan struct{})}
}

func (rw *RWMutex) Lock() {
	rw.mu <- struct{}{} //获取锁
	//阻止之后的读操作，等待现有的读操作
	if r := atomic.AddInt32(&rw.readerCount, -RWMutexMaxReaders) + RWMutexMaxReaders; r > 0 {
		atomic.AddInt32(&rw.readerWait, r) //增加写阻塞时读数量
		<-rw.wchan
	}
}

func (rw *RWMutex) Unlock() {
	//唤醒等待的读
	if r := atomic.AddInt32(&rw.readerCount, RWMutexMaxReaders); r > 0 {
		for i := 0; i < int(r); i++ {
			rw.rchan <- struct{}{}
		}
	}
	//解锁
	<-rw.mu
}

func (rw *RWMutex) RLock() {
	//增加读数量，如果有写就等待写
	if r := atomic.AddInt32(&rw.readerCount, 1); r < 0 {
		<-rw.rchan
	}
}

func (rw *RWMutex) RUnlock() {
	//减少读数量，有写等待就进一步判断如果自己是最后一个读就唤醒写
	if r := atomic.AddInt32(&rw.readerCount, -1); r < 0 {
		if rwait := atomic.AddInt32(&rw.readerWait, -1); rwait == 0 {
			rw.wchan <- struct{}{}
		}
	}
}

func main() {
	rw := NewRWMutex()
	num := 0
	wg := new(sync.WaitGroup)
	wg.Add(100)
	for i := 0; i < 100; i++ {
		go func(i int) {
			defer wg.Done()
			switch i % 2 {
			case 0:
				rw.Lock()
				defer rw.Unlock()
				num++
			case 1:
				time.Sleep(time.Duration(rand.Intn(2)) * time.Millisecond)
				rw.RLock()
				defer rw.RUnlock()
				fmt.Println(num)
			}
		}(i)
	}
	wg.Wait()
}
```

#### WaitGroup

`WaitGroup`可以等待一组go

```go
type WaitGroup struct {
   noCopy noCopy // 确保不会拷贝

   // 64-bit value: high 32 bits are counter, low 32 bits are waiter count.
   // 64-bit atomic operations require 64-bit alignment, but 32-bit
   // compilers do not ensure it. So we allocate 12 bytes and then use
   // the aligned 8 bytes in them as state, and the other 4 as storage
   // for the sema.
   state1 [3]uint32
}
```

![golang-waitgroup-state](https://img.draveness.me/2020-01-23-15797104328035-golang-waitgroup-state.png)

[`sync.WaitGroup.state`](https://draveness.me/golang/tree/sync.WaitGroup.state) 能够帮我们从 `state1` 字段中取出它的状态和信号量

```go
func (wg *WaitGroup) Add(delta int) {
	statep, semap := wg.state()
	state := atomic.AddUint64(statep, uint64(delta)<<32)
	v := int32(state >> 32)
	w := uint32(state)
	if v < 0 {
		panic("sync: negative WaitGroup counter")
	}
	if v > 0 || w == 0 {
		return
	}
	*statep = 0
	for ; w != 0; w-- {
		runtime_Semrelease(semap, false, 0)
	}
}
```

[`sync.WaitGroup.Add`](https://draveness.me/golang/tree/sync.WaitGroup.Add) 可以更新 [`sync.WaitGroup`](https://draveness.me/golang/tree/sync.WaitGroup) 中的计数器 `counter`。虽然 [`sync.WaitGroup.Add`](https://draveness.me/golang/tree/sync.WaitGroup.Add) 方法传入的参数可以为负数，但是计数器只能是非负数，一旦出现负数就会发生程序崩溃。当调用计数器归零，即所有任务都执行完成时，才会通过 [`sync.runtime_Semrelease`](https://draveness.me/golang/tree/sync.runtime_Semrelease) 唤醒处于等待状态的 Goroutine。

```go
func (wg *WaitGroup) Wait() {
	statep, semap := wg.state()
	for {
		state := atomic.LoadUint64(statep)
		v := int32(state >> 32)
		if v == 0 {
			return
		}
		if atomic.CompareAndSwapUint64(statep, state, state+1) {
			runtime_Semacquire(semap)
			if +statep != 0 {
				panic("sync: WaitGroup is reused before previous Wait has returned")
			}
			return
		}
	}
}
```

[`sync.WaitGroup.Wait`](https://draveness.me/golang/tree/sync.WaitGroup.Wait) 会在计数器大于 0 并且不存在等待的 Goroutine 时，调用 [`runtime.sync_runtime_Semacquire`](https://draveness.me/golang/tree/runtime.sync_runtime_Semacquire) 陷入睡眠。

> 在 ThreadSafeCalcWords 中的递归情况下，您在调用 wg.Add 之前先调用 wg.Done。这意味着在实际完成所有工作之前，wg 可以降为 0 (这将触发 Wait 完成)。在 Wait 仍在解析过程中的同时再次调用 Add 会触发错误

#### Once

Go 语言标准库中 [`sync.Once`](https://draveness.me/golang/tree/sync.Once) 可以保证在 Go 程序运行期间的某段代码只会执行一次。在运行如下所示的代码时，我们会看到如下所示的运行结果：

```go
type Once struct {
    // done表示动作是否已经执行
	done uint32
	m    Mutex
}
```

```go
func (o *Once) Do(f func()) {
	if atomic.LoadUint32(&o.done) == 0 {
		o.doSlow(f)
	}
}

func (o *Once) doSlow(f func()) {
	o.m.Lock()
	defer o.m.Unlock()
	if o.done == 0 {
		defer atomic.StoreUint32(&o.done, 1)
		f()
	}
}
```

- 如果传入的函数已经执行过，会直接返回；
- 如果传入的函数没有执行过，会调用 [`sync.Once.doSlow`](https://draveness.me/golang/tree/sync.Once.doSlow) 执行传入的函数：

#### Cond

Cond 让一组goroutine在特定条件下被唤醒

```go
type Cond struct {
   // 用于保证结构体不会在编译期间拷贝；
   noCopy noCopy
   // 用于保护内部的 notify 字段，Locker 接口类型的变量
   L Locker
   // 一个 Goroutine 的链表，它是实现同步机制的核心结构；
   notify  notifyList
   // 用于禁止运行期间发生的拷贝；
   checker copyChecker
}
```

1. `Wait`

   ```go
   //    c.L.Lock()
   //    for !condition() {
   //        c.Wait()
   //    }
   //    ... make use of condition ...
   //    c.L.Unlock()
   func (c *Cond) Wait() {
      c.checker.check()
      t := runtime_notifyListAdd(&c.notify)
      c.L.Unlock()
      runtime_notifyListWait(&c.notify, t) 
      c.L.Lock()
   }
   ```

   1. 调用 [`runtime.notifyListAdd`](https://draveness.me/golang/tree/runtime.notifyListAdd) 将等待计数器加一并解锁；
   2. 调用 [`runtime.notifyListWait`](https://draveness.me/golang/tree/runtime.notifyListWait) 等待其他 Goroutine 的唤醒并加锁：

2. `Signal`

   ```go
   func (c *Cond) Signal() {
      c.checker.check()
      runtime_notifyListNotifyOne(&c.notify)
   }
   
   func (c *Cond) Broadcast() {
   	c.checker.check()
   	runtime_notifyListNotifyAll(&c.notify)
   }
   ```

   - [`sync.Cond.Signal`](https://draveness.me/golang/tree/sync.Cond.Signal) 方法会唤醒队列最前面的 Goroutine；
   - [`sync.Cond.Broadcast`](https://draveness.me/golang/tree/sync.Cond.Broadcast) 方法会唤醒队列中全部的 Goroutine；

[`sync.Cond`](https://draveness.me/golang/tree/sync.Cond) 不是一个常用的同步机制，但是在条件长时间无法满足时，与使用 `for {}` 进行忙碌等待相比，[`sync.Cond`](https://draveness.me/golang/tree/sync.Cond) 能够让出处理器的使用权，提高 CPU 的利用率。使用时我们也需要注意以下问题：

- [`sync.Cond.Wait`](https://draveness.me/golang/tree/sync.Cond.Wait) 在调用之前一定要使用获取互斥锁，否则会触发程序崩溃；
- [`sync.Cond.Signal`](https://draveness.me/golang/tree/sync.Cond.Signal) 唤醒的 Goroutine 都是队列最前面、等待最久的 Goroutine；
- [`sync.Cond.Broadcast`](https://draveness.me/golang/tree/sync.Cond.Broadcast) 会按照一定顺序广播通知等待的全部 Goroutine；

#### 拓展原语

##### ErrGroup

为我们在一组 Goroutine 中提供了同步、错误传播以及上下文取消的功能

```go
func main() {
	var g errgroup.Group
	var urls = []string{
		"https://www.google.com",
		"https://www.baidu.com",
	}
	for i := range urls {
		g.Go(func() error {
			if resp, err := http.Get(urls[i]); err != nil {
				return err
			} else {
				return resp.Body.Close()
			}
		})
	}
	if err := g.Wait(); err == nil { // 等待一个错误
		log.Println(err)
	}
}

```

[`golang/sync/errgroup.Group.Go`](https://draveness.me/golang/tree/golang/sync/errgroup.Group.Go) 方法能够创建一个 Goroutine 并在其中执行传入的函数，而 [`golang/sync/errgroup.Group.Wait`](https://draveness.me/golang/tree/golang/sync/errgroup.Group.Wait) 会等待所有 Goroutine 全部返回，该方法的不同返回结果也有不同的含义：

- 如果返回错误 — 这一组 Goroutine 最少返回一个错误；
- 如果返回空值 — 所有 Goroutine 都成功执行；

```go
type Group struct {
	cancel func()

	wg sync.WaitGroup

	errOnce sync.Once
	err     error
}
```

1. `cancel` — 创建 [`context.Context`](https://draveness.me/golang/tree/context.Context) 时返回的取消函数，用于在多个 Goroutine 之间同步取消信号；
2. `wg` — 用于等待一组 Goroutine 完成子任务的同步原语；
3. `errOnce` — 用于保证只接收一个子任务返回的错误；

在出现错误后会cancel当前ctx

```go
func WithContext(ctx context.Context) (*Group, context.Context) {
	ctx, cancel := context.WithCancel(ctx)
	return &Group{cancel: cancel}, ctx
}
```

```go
func (g *Group) Go(f func() error) {
	g.wg.Add(1) // 增加任务
	go func() {
		defer g.wg.Done()
		if err := f(); err != nil {
			g.errOnce.Do(func() { // 只有最早返回的错误才会被上游感知到
				g.err = err
				if g.cancel != nil {
					g.cancel()
				}
			})
		}
	}()
}

func (g *Group) Wait() error {
	g.wg.Wait()
	if g.cancel != nil {
		g.cancel()
	}
	return g.err
}
```

##### Semaphore

信号量是在并发编程中常见的一种同步机制，在需要控制访问资源的进程数量时就会用到信号量，它会保证持有的计数器在 0 到初始化的权重之间波动。

- 每次获取资源时都会将信号量中的计数器减去对应的数值，在释放时重新加回来；
- 当遇到计数器大于信号量大小时，会进入休眠等待其他线程释放信号；

```go
func NewWeighted(n int64) *Weighted {
   w := &Weighted{size: n}
   return w
}

type Weighted struct {
	size    int64 // 信号量上限
	cur     int64 // 计数器
	mu      sync.Mutex
	waiters list.List
}

```

信号量中的计数器会随着用户对资源的访问和释放进行改变，引入的权重概念能够提供更细粒度的资源的访问控制，尽可能满足常见的用例。

1. `Acquire`

   [`semaphore.Weighted.Acquire`](https://draveness.me/golang/tree/golang/sync/semaphore.Weighted.Acquire) 方法能用于获取指定权重的资源，其中包含三种不同情况：

   1. 当信号量中剩余的资源大于获取的资源并且没有等待的 Goroutine 时，会直接获取信号量；
   2. 如果超过上限，会等待ctx被cancel()
   3. 遇到其他情况时会将当前 Goroutine 加入到等待列表并通过 `select` 等待调度器唤醒当前 Goroutine，Goroutine 被唤醒后会获取信号量；

   ```go
   func (s *Weighted) Acquire(ctx context.Context, n int64) error {
   	s.mu.Lock()
       // 资源够用，且没go等着，直接用
   	if s.size-s.cur >= n && s.waiters.Len() == 0 {
   		s.cur += n
   		s.mu.Unlock()
   		return nil
   	}
   	
       // 如果超过上限，会等待ctx被cancel()
   	if n > s.size {
   		// Don't make other Acquire calls block on one that's doomed to fail.
   		s.mu.Unlock()
   		<-ctx.Done()
   		return ctx.Err()
   	}
   
   	ready := make(chan struct{})
       // 加入到队列后面
   	w := waiter{n: n, ready: ready}
   	elem := s.waiters.PushBack(w)
   	s.mu.Unlock()
   
   	select {
   	case <-ctx.Done():
   		err := ctx.Err()
   		s.mu.Lock()
   		select {
   		case <-ready:
   			// 取消时发现信号量获取了则忽略错误。
   			err = nil
   		default:
               // 从队列中删除元素。
   			isFront := s.waiters.Front() == elem
   			s.waiters.Remove(elem)
   			// 如果删除的是第一个，则通知其他的等待者。
   			if isFront && s.size > s.cur {
   				s.notifyWaiters()
   			}
   		}
   		s.mu.Unlock()
   		return err
   
   	case <-ready:
   		return nil
   	}
   }
   ```

2. `TryAcquire`

   [`semaphore.Weighted.TryAcquire`](https://draveness.me/golang/tree/golang/sync/semaphore.Weighted.TryAcquire) 只会非阻塞地判断当前信号量是否有充足的资源，如果有充足的资源会直接立刻返回 `true`，否则会返回 `false`：

   ```go
   func (s *Weighted) TryAcquire(n int64) bool {
   	s.mu.Lock()
   	success := s.size-s.cur >= n && s.waiters.Len() == 0
   	if success {
   		s.cur += n
   	}
   	s.mu.Unlock()
   	return success
   }
   ```

3. `Release`

   当我们要释放信号量时，[`semaphore.Weighted.Release`](https://draveness.me/golang/tree/golang/sync/semaphore.Weighted.Release) 方法会从头到尾遍历 `waiters` 列表中全部的等待者，如果释放资源后的信号量有充足的剩余资源就会通过 Channel 唤起指定的 Goroutine：

   ```go
   func (s *Weighted) Release(n int64) {
   	s.mu.Lock()
   	s.cur -= n
   	if s.cur < 0 {
   		s.mu.Unlock()
   		panic("semaphore: released more than held")
   	}
   	s.notifyWaiters()
   	s.mu.Unlock()
   }
   ```

   注意，申请资源比较多则可能会出现一直无法被唤醒的情况，所以需要ctx来设置过期时间

##### SingleFlight

它能够在一个服务中抑制对下游的多次重复请求。一个比较常见的使用场景是：我们在使用 Redis 对数据库中的数据进行缓存，发生缓存击穿时，大量的流量都会打到数据库上进而影响服务的尾延时。

[`singleflight.Group`](https://draveness.me/golang/tree/golang/sync/singleflight.Group) 能有效地解决这个问题，它能够限制对同一个键值对的多次重复请求，减少对下游的瞬时流量。

用法：

```go
type service struct {
    requestGroup singleflight.Group
}

func (s *service) handleRequest(ctx context.Context, request Request) (Response, error) {
    v, err, _ := requestGroup.Do(request.Hash(), func() (interface{}, error) {
        rows, err := // select * from tables
        if err != nil {
            return nil, err
        }
        return rows, nil
    })
    if err != nil {
        return nil, err
    }
    return Response{
        rows: rows,
    }, nil
}
```

结构：

```go
type Group struct {
	mu sync.Mutex // protects m
	m  map[string]*call // lazily initialized
}

type call struct {
	wg sync.WaitGroup
	//这些字段在WaitGroup完成之前写入一次，并且只在WaitGroup完成后读取。
	val interface{}
	err error
	forgotten bool

	// dups 和 chans 两个字段分别存储了抑制的请求数量以及用于同步结果的 Channel。
	dups  int
	chans []chan<- Result
}

```

1. `Do` 同步等待

   ```go
   func (g *Group) Do(key string, fn func() (interface{}, error)) (v interface{}, err error, shared bool) {
      g.mu.Lock()
       // 懒加载
      if g.m == nil {
         g.m = make(map[string]*call)
      }
       // 查看有没有相同key的请求正在运行。
      if c, ok := g.m[key]; ok {
         c.dups++
         g.mu.Unlock()
         c.wg.Wait()
   
         if e, ok := c.err.(*panicError); ok {
            panic(e)
         } else if c.err == errGoexit {
            runtime.Goexit()
         }
          // 返回前者的结果
         return c.val, c.err, true
      }
       // 自己先运行，并且记录在map中
      c := new(call)
      c.wg.Add(1)
      g.m[key] = c
      g.mu.Unlock()
    
      g.doCall(c, key, fn)
      return c.val, c.err, c.dups > 0
   }
   ```

   1. 当不存在对应的

      `singleflight.call`时：

      1. 初始化一个新的 [`golang/sync/singleflight.call`](https://draveness.me/golang/tree/golang/sync/singleflight.call) 指针；
      2. 增加 [`sync.WaitGroup`](https://draveness.me/golang/tree/sync.WaitGroup) 持有的计数器；
      3. 将 [`golang/sync/singleflight.call`](https://draveness.me/golang/tree/golang/sync/singleflight.call) 指针添加到映射表；
      4. 释放持有的互斥锁；
      5. 阻塞地调用 [`golang/sync/singleflight.Group.doCall`](https://draveness.me/golang/tree/golang/sync/singleflight.Group.doCall) 方法等待结果的返回；

   2. 当存在对应的`singleflight.call`时；

      1. 增加 `dups` 计数器，它表示当前重复的调用次数；
      2. 释放持有的互斥锁；
      3. 通过 [`sync.WaitGroup.Wait`](https://draveness.me/golang/tree/sync.WaitGroup.Wait) 等待请求的返回；

2. `DoChan` 异步等待

   ```go
   func (g *Group) DoChan(key string, fn func() (interface{}, error)) <-chan Result {
      ch := make(chan Result, 1)
      g.mu.Lock()
      if g.m == nil {
         g.m = make(map[string]*call)
      }
      if c, ok := g.m[key]; ok {
         c.dups++
         c.chans = append(c.chans, ch)
         g.mu.Unlock()
         return ch
      }
      c := &call{chans: []chan<- Result{ch}}
      c.wg.Add(1)
      g.m[key] = c
      g.mu.Unlock()
      go g.doCall(c, key, fn)
      return ch
   }
   ```

   和前面没啥区别，就是通过缓冲chan返回数据

### 计时器

采用四叉堆

1. 上推节点的操作更快。假如最下层某个节点的值被修改为最小，同样上推到堆顶的操作，N
   叉堆需要的比较次数只有二叉堆的logv2倍。

2. 对缓存更友好。二叉堆对数组的访问范围更大，更加随机，而N叉堆则更集中于数组的
   上部，这就对缓存更加友好，有利于提高性能。

3. Go1.10之前由全局唯一四叉堆维护

   所有go程对计时器操作都会争夺互斥锁，性能消耗大

4. Go1.10之后将全局四叉堆分为64个小的四叉堆

   理想情况下，堆数和处理器数量相同，但是如果处理器数量超过64,则可能多个处理器上的计时器就在一个桶中，每个桶由一个go程去处理。但是这个go程造成处理器和线程之间频繁切换引起性能问题

5. Go1.13之后采用网络轮训器方式

   所有计时器都采用最小四叉堆的形式存放在处理器`P`中，计时器都交给处理器的网络轮训=器和调度器来触发。

### chan

#### 设计原则

 不同go程通过channel来共享数据。

使用通信来共享内存

#### 使用特性

1. 先进先出，队列特性
2. 读取或写入
   1. 读取：
      1. nil：阻塞
      2. open非空：值
      3. open空：阻塞
      4. close：默认值，false
      5. 只写：编译错误

   2. 写入：    
      1.  nil：阻塞
      2.  满：阻塞
      3.  未满：写入值
      4.  关闭：panic
      5.  只读：编译错误
   3. close    
      1. nil：panic
      2. open未空：关闭chan，直到通道耗尽，然后读取默认值
      3. open空：关闭chan，读取默认值
      4. close：panic
      5. 只读：编译错误


#### 结构

```go
type hchan struct {
	qcount   uint // 当前队列中剩余元素
	dataqsiz uint // 环形队列长度（cap）
	buf      unsafe.Pointer // 唤醒队列指针
	elemsize uint16 // 元素大小
    closed   uint32 // 标识关闭
	elemtype *_type // 元素类型
	sendx    uint // 队列下标（下一个写入存放的位置）
	recvx    uint // 队列下标（下一个读取的位置）
	recvq    waitq // 等待读的协程队列
	sendq    waitq // 等待写的协程队列

	lock mutex // 不允许互斥读写
}
// 双向链表
type waitq struct {
	first *sudog
	last  *sudog
}
```

#### 创建

`make(chan)`会在编译阶段被转换为`makechan`函数

```go
func makechan(t *chantype, size int) *hchan {
	elem := t.elem
	mem, _ := math.MulUintptr(elem.size, uintptr(size))

	var c *hchan
	switch {
    case mem == 0: // 无缓冲：分配一段内存空间
		c = (*hchan)(mallocgc(hchanSize, nil, true))
		c.buf = c.raceaddr()
	case elem.kind&kindNoPointers != 0:// 存的元素类型不是指针，会为当前channel和底层数组分配一块连续内存
        c = (*hchan)(mallocgc(hchanSize+mem, nil, true))
		c.buf = add(unsafe.Pointer(c), hchanSize)
	default:// 默认单独为runtime.hchan和缓冲区分配内存
		c = new(hchan)
		c.buf = mallocgc(mem, elem, true)
	}
	c.elemsize = uint16(elem.size)
	c.elemtype = elem
	c.dataqsiz = uint(size)
	return c
}
```

#### 发送数据

![1.1 chan - 图3](https://static.sitestack.cn/projects/GoExpertProgramming/chapter01/images/chan-03-send_data.png)

`chan <- i`会被转换为`chansend`函数，参数`block`表示是否阻塞发送

```go
func chansend(c *hchan, ep unsafe.Pointer, block bool, callerpc uintptr) bool {
	lock(&c.lock) // 
	if c.closed != 0 {
		unlock(&c.lock)
		panic(plainError("send on closed channel"))
	}
```

##### 存在等待的接收者：直接发送

```go
	// 取出最先等待的读go程，然后给它发数据
	if sg := c.recvq.dequeue(); sg != nil {
		send(c, sg, ep, func() { unlock(&c.lock) }, 3)
		return true
	}
```

发送数据时会调用 [`runtime.send`](https://draveness.me/golang/tree/runtime.send)，该函数的执行可以分成两个部分

1. 调用 [`runtime.sendDirect`](https://draveness.me/golang/tree/runtime.sendDirect) 将发送的数据直接拷贝到 `x = <-c` 表达式中变量 `x` 所在的内存地址上；

2. 调用 [`runtime.goready`](https://draveness.me/golang/tree/runtime.goready) 将等待接收数据的 Goroutine 标记成可运行状态 `Grunnable` 并把该 Goroutine 放到发送方所在的处理器的 `runnext` 上等待执行，该处理器在下一次调度时会立刻唤醒数据的接收方

   ```go
   func send(c *hchan, sg *sudog, ep unsafe.Pointer, unlockf func(), skip int) {
   	if sg.elem != nil {
   		sendDirect(c.elemtype, sg, ep)
   		sg.elem = nil
   	}
   	gp := sg.g
   	unlockf()
   	gp.param = unsafe.Pointer(sg)
   	goready(gp, skip+1) // 下一次调度来唤醒接收方
   }
   ```

##### 存在可用缓冲：写入缓冲区

创建的channel有缓冲区且没有满

```go
func chansend(c *hchan, ep unsafe.Pointer, block bool, callerpc uintptr) bool {
	...
	if c.qcount < c.dataqsiz {
		qp := chanbuf(c, c.sendx) // 计算出下一个可以存放数据的位置
		typedmemmove(c.elemtype, qp, ep) // 拷贝数据到目标位置
		c.sendx++ // 下标增加
		if c.sendx == c.dataqsiz { // 循环
			c.sendx = 0
		}
		c.qcount++ // 计数
		unlock(&c.lock)
		return true
	}
	...
}
```

##### 无缓冲区或满了且没有接受者：阻塞发送

```go
func chansend(c *hchan, ep unsafe.Pointer, block bool, callerpc uintptr) bool {
	...
	if !block {
		unlock(&c.lock)
		return false
	}
	gp := getg() // 获取发送数据用的go程
	mysg := acquireSudog() // 获取并填充sudog结构
	mysg.elem = ep
	mysg.g = gp
	mysg.c = c
	gp.waiting = mysg // 等待sudog就绪
	c.sendq.enqueue(mysg)  // 阻塞
	goparkunlock(&c.lock, waitReasonChanSend, traceEvGoBlockSend, 3) // 释放资源

	gp.waiting = nil
	gp.param = nil
	mysg.c = nil
	releaseSudog(mysg)
	return true
}
```

#### 接收数据

![1.1 chan - 图4](https://static.sitestack.cn/projects/GoExpertProgramming/chapter01/images/chan-04-recieve_data.png)

`i<-ch`，编译期间最终都会调用 [`runtime.chanrecv`](https://draveness.me/golang/tree/runtime.chanrecv)函数

从`nil`阻塞接收数据会直接让出处理器。

```go
func chanrecv(c *hchan, ep unsafe.Pointer, block bool) (selected, received bool) {
	if c == nil {
		if !block {
			return
		}
		gopark(nil, nil, waitReasonChanReceiveNilChan, traceEvGoStop, 2)
		throw("unreachable")
	}
	lock(&c.lock)
	if c.closed != 0 && c.qcount == 0 {
		unlock(&c.lock)
		if ep != nil {
			typedmemclr(c.elemtype, ep)
		}
		return true, false
	}
```

如果当前`channel`已经关闭，且缓冲区为空则清空所有数据并返回。

##### 存在等待的发送者：直接获取数据

```go
	// 取出队头等待的go程接收数据
	if sg := c.sendq.dequeue(); sg != nil {
		recv(c, sg, ep, func() { unlock(&c.lock) }, 3)
		return true, true
	}

func recv(c *hchan, sg *sudog, ep unsafe.Pointer, unlockf func(), skip int) {
	// 不存在缓冲区 直接复制发送者的数据到目标位置
    if c.dataqsiz == 0 {
		if ep != nil {
			recvDirect(c.elemtype, sg, ep)
		}
	} else {
        // 将队列中数据复制到接收方的内存中
		qp := chanbuf(c, c.recvx)
		if ep != nil {
			typedmemmove(c.elemtype, ep, qp)
		}
		typedmemmove(c.elemtype, qp, sg.elem)
		c.recvx++
		c.sendx = c.recvx // c.sendx = (c.sendx+1) % c.dataqsiz
	}
	gp := sg.g
	gp.param = unsafe.Pointer(sg)
	goready(gp, skip+1) // 释放一个阻塞发送方
}
```

##### 缓冲区不为空：从缓冲区读

从缓冲区取出数据即可

```go
func chanrecv(c *hchan, ep unsafe.Pointer, block bool) (selected, received bool) {
	...
	if c.qcount > 0 {
		qp := chanbuf(c, c.recvx)
		if ep != nil {
			typedmemmove(c.elemtype, ep, qp)
		}
		typedmemclr(c.elemtype, qp)
		c.recvx++
		if c.recvx == c.dataqsiz {
			c.recvx = 0
		}
		c.qcount--
		return true, true
	}
	...
}
```

##### 无缓冲区或无数据：阻塞等待

当 Channel 的发送队列中不存在等待的 Goroutine 并且缓冲区中也不存在任何数据时，从管道中接收数据的操作会变成阻塞的，然而不是所有的接收操作都是阻塞的，与 `select` 语句结合使用时就可能会使用到非阻塞的接收操作

```go
func chanrecv(c *hchan, ep unsafe.Pointer, block bool) (selected, received bool) {
	...
    // 没数据直接返回
	if !block {
		unlock(&c.lock)
		return false, false
	}

	gp := getg()
	mysg := acquireSudog()
	mysg.elem = ep
	gp.waiting = mysg
	mysg.g = gp
	mysg.c = c
	c.recvq.enqueue(mysg) // 阻塞读队列，释放处理器
	goparkunlock(&c.lock, waitReasonChanReceive, traceEvGoBlockRecv, 3)
	// 释放资源
	gp.waiting = nil
	closed := gp.param == nil
	gp.param = nil
	releaseSudog(mysg)
	return true, !closed
}
```

#### 关闭管道

编译期间会把`close`替换为`closechan`函数

当 Channel 是一个空指针或者已经被关闭时，Go 语言运行时都会直接崩溃并抛出异常：

```go
func closechan(c *hchan) {
	if c == nil {
		panic(plainError("close of nil channel"))
	}
	lock(&c.lock)
	if c.closed != 0 {
		unlock(&c.lock)
		panic(plainError("close of closed channel"))
	}
```

下面这段代码的主要工作就是将 `recvq` 和 `sendq` 两个队列中的数据加入到 Goroutine 列表 `gList` 中，与此同时该函数会清除所有 [`runtime.sudog`](https://draveness.me/golang/tree/runtime.sudog) 上未被处理的元素：

```go
	c.closed = 1
	var glist gList
	for {
		sg := c.recvq.dequeue()
		if sg == nil {
			break
		}
        // 清理接收方
		if sg.elem != nil {
			typedmemclr(c.elemtype, sg.elem)
			sg.elem = nil
		}
		gp := sg.g
		gp.param = nil
		glist.push(gp)
	}

	for {
        // 处理发送放
		sg := c.sendq.dequeue()
		...
	}
// 释放所有阻塞的读go程。
	for !glist.empty() {
		gp := glist.pop()
		gp.schedlink = 0
		goready(gp, 3)
	}
}
```

### sync.Map

内置map不支持并发读写

> https://juejin.cn/post/6844904100287496206

`sync.Map` 的实现原理可概括为：

- 通过 read 和 dirty 两个字段将读写分离，读的数据存在只读字段 read 上，将最新写入的数据则存在 dirty 字段上
- 读取时会先查询 read，不存在再查询 dirty，写入时则只写入 dirty
- 读取 read 并不需要加锁，而读或写 dirty 都需要加锁
- 另外有 misses 字段来统计 read 被穿透的次数（被穿透指需要读 dirty 的情况），超过一定次数则将 dirty 数据同步到 read 上
- 对于删除数据则直接通过标记来延迟删除

![image-20220928205033186](https://raja-img.oss-cn-hangzhou.aliyuncs.com/img/image-20220928205033186.png)

```go
type Map struct {
	// 保护加锁字段
	mu Mutex
    // readOnly 结构是只读，但其中的操作也有写
	read atomic.Value
	// 最终写入的数据
	dirty map[interface{}]*entry
	// 计数器，每次read没有，读dirty就+1
	misses int
}

type readOnly struct {
	// 只读map
	m map[interface{}]*entry
	// 脏映射中有不在m中的值就true-> dirty被提升了置为false，dirty=nil,true表示上一次已经把read拷贝到dirty，且设置新的值
	amended bool // true if the dirty map contains some key not in m.
}

// expunge 代表 dirty 中被删掉的情况
var expunged = unsafe.Pointer(new(interface{}))

// 存储值的指针
type entry struct {
	p unsafe.Pointer // *interface{}
}

// read里面有key就直接原子读，否则如果dirty!=nil就尝试从dirty读（如果错过次数太多就将dirty提升，设置dirty=nil,amended=false）
func (m *Map) Load(key interface{}) (value interface{}, ok bool) {
	// 尝试从read读readonly对象
	read, _ := m.read.Load().(readOnly)
	e, ok := read.m[key]
	if !ok && read.amended {
		m.mu.Lock()
		read, _ = m.read.Load().(readOnly)
		e, ok = read.m[key]
		if !ok && read.amended {
			e, ok = m.dirty[key]
			// 标记错过，如果错过次数太多就将dirty提升
			m.missLocked()
		}
		m.mu.Unlock()
	}
	if !ok {
		return nil, false
	}
	// 返回结果
	return e.load()
}

// read里面或者dirty有key就乐观锁或原子更新对应的e.p，否则如果dirty为nil就拷贝read到dirty(amended=false,e.p如果等于nil->expunged),添加k，v到dirty
func (m *Map) Store(key, value interface{}) {
	read, _ := m.read.Load().(readOnly)
	// 如果read里面有就更新read
	if e, ok := read.m[key]; ok && e.tryStore(&value) {
		return
	}
	m.mu.Lock()
	read, _ = m.read.Load().(readOnly)
	// read有且标记为删除 则置为nil，然后添加到dirty中,最后更新read值
	if e, ok := read.m[key]; ok {
		// dirty != nil
		if e.unexpungeLocked() {
			// 添加dirty
			m.dirty[key] = e
		}
		e.storeLocked(&value)
	} else if e, ok := m.dirty[key]; ok { // read没有，dirty中有key就更新v
		e.storeLocked(&value)
	} else {
		// 这个表示dirty可能为nil
		if !read.amended {
			// 将read复制到dirty，同时把nil更改为标记删除
			m.dirtyLocked()
			// 标记dirty不为nil且数据多
			m.read.Store(readOnly{m: read.m, amended: true})
		}
		// dirty中添加value
		m.dirty[key] = newEntry(value)
	}
	m.mu.Unlock()
}

// read中有key则将e.p->nil，否则如果dirty!=nil，去dirty中找并删除key，最后如果这个值存在e.p->nil
func (m *Map) Delete(key interface{}) {
	m.LoadAndDelete(key)
}

// read中有key则将e.p->nil，否则如果dirty中有值，去dirty中找并删除key，最后如果这个值存在e.p->nil
func (m *Map) LoadAndDelete(key interface{}) (value interface{}, loaded bool) {
	read, _ := m.read.Load().(readOnly)
	e, ok := read.m[key]
	// read中没有且dirty数据多就去dirty中找，然后删除k并增加穿透次数，最后如果有就更新值为nil
	if !ok && read.amended {
		m.mu.Lock()
		read, _ = m.read.Load().(readOnly)
		e, ok = read.m[key]
		if !ok && read.amended {
			e, ok = m.dirty[key]
			delete(m.dirty, key)
			m.missLocked()
		}
		m.mu.Unlock()
	}
	// read中有就尝试把e.p置为nil
	if ok {
		return e.delete()
	}
	return nil, false
}
```

### 控制协程数量

#### 缓冲chan+sync

```go
package main

import (
    "fmt"
    "math"
    "sync"
    "runtime"
)

var wg = sync.WaitGroup{}

func busi(ch chan bool, i int) {

    fmt.Println("go func ", i, " goroutine count = ", runtime.NumGoroutine())

    <-ch

    wg.Done()
}

func main() {
    //模拟用户需求go业务的数量
    task_cnt := math.MaxInt64

    ch := make(chan bool, 3)

    for i := 0; i < task_cnt; i++ {
		wg.Add(1)

        ch <- true

        go busi(ch, i)
    }

	  wg.Wait()
}
```

#### 无缓冲chan+工作池

```go
package main

import (
    "fmt"
    "math"
    "sync"
    "runtime"
)

var wg = sync.WaitGroup{}

func busi(ch chan int) {

    for t := range ch {
        fmt.Println("go task = ", t, ", goroutine count = ", runtime.NumGoroutine())
        wg.Done()
    }
}

func sendTask(task int, ch chan int) {
    wg.Add(1)
    ch <- task
}

func main() {

    ch := make(chan int)   //无buffer channel

    goCnt := 3              //启动goroutine的数量
    for i := 0; i < goCnt; i++ {
        //启动go
        go busi(ch)
    }

    taskCnt := math.MaxInt64 //模拟用户需求业务的数量
    for t := 0; t < taskCnt; t++ {
        //发送任务
        sendTask(t, ch)
    }

	  wg.Wait()
}
```

这里实际上是将任务的发送和执行做了业务上的分离。使得消息出去，输入SendTask的频率可设置、执行Goroutine的数量也可设置。也就是既控制输入(生产)，又控制输出(消费)。

![img](https://github.com/aceld/golang/raw/main/images/151-goroutines5.jpeg)



### GMP

> 推荐阅读:https://www.yuque.com/aceld/golang/srxd6d

单进程：进程阻塞浪费CPU

多进程：切换资源消耗高

多线程：一个线程占用内存大，调度消耗CPU

于是线程被分为用户态线程（协程）和内核态线程，一个“用户态线程”必须要绑定一个“内核态线程”，但是CPU并不知道有“用户态线程”的存在，它只知道它运行的是一个“内核态线程”(Linux的PCB进程控制块)。

![img](https://github.com/aceld/golang/raw/main/images/8-%E7%BA%BF%E7%A8%8B%E7%9A%84%E5%86%85%E6%A0%B8%E5%92%8C%E7%94%A8%E6%88%B7%E6%80%81.png)

#### 映射关系

##### N：1

优点：

**协程在用户态线程即完成切换，不会陷入到内核态，这种切换非常的轻量快速**。

缺点：

1. 无法利用CPU多核加速能力，无法并行。
2. 一个协程阻塞，整个进程都阻塞。

![img](https://github.com/aceld/golang/raw/main/images/10-N-1%E5%85%B3%E7%B3%BB.png)

##### 1：1

1个协程绑定1个线程，这种最容易实现。协程的调度都由CPU完成了，不存在N:1缺点，

缺点：

协程的创建、删除和切换的代价都由CPU完成，有点略显昂贵了。

![img](https://github.com/aceld/golang/raw/main/images/11-1-1.png)

##### N：N

M个协程绑定1个线程，是N:1和1:1类型的结合，克服了以上2种模型的缺点，但实现起来最为复杂。

![img](https://github.com/aceld/golang/raw/main/images/12-m-n.png)

协程跟线程是有区别的，线程由CPU调度是抢占式的，**协程由用户态调度是协作式的**，一个协程让出CPU后，才执行下一个协程。

#### goroutine(Go的协程)

**Go为了提供更容易使用的并发方法，使用了goroutine和channel**。goroutine来自协程的概念，让一组可复用的函数运行在一组线程之上，即使有协程阻塞，该线程的其他协程也可以被`runtime`调度，转移到其他可运行的线程上。最关键的是，程序员看不到这些底层的细节，这就降低了编程的难度，提供了更容易的并发。

Go中，协程被称为goroutine，它非常轻量，一个goroutine只占几KB，并且这几KB就足够goroutine运行完，这就能在有限的内存空间内支持大量goroutine，支持了更多的并发。虽然一个goroutine的栈只占几KB，但实际是可伸缩的，如果需要更多内容，`runtime`会自动为goroutine分配。

Goroutine特点：

- 占用内存更小（几kb）
- 调度更灵活(runtime调度)

> G：协程 M：线程

#### GM调度器

![img](https://github.com/aceld/golang/raw/main/images/14-old%E8%B0%83%E5%BA%A6%E5%99%A8.png)

缺点：

1. M对G进行操作都需要持有全局锁，激烈的锁竞争
2. M转移G会造成延迟和额外负担：比如新的Go程肯定和原本的Go程资源相关。
3. CPU在M上状态切换增加系统开销

#### GMP调度器

> G：go程，M：线程，P：协程处理器（Processor）

**Processor，它包含了运行goroutine的资源**，如果线程想运行goroutine，必须先获取P，P中还包含了可运行的G队列。

##### GMP模型

在Go中，**线程是运行goroutine的实体，调度器的功能是把可运行的goroutine分配到工作线程上**。

![img](https://github.com/aceld/golang/raw/main/images/16-GMP-%E8%B0%83%E5%BA%A6.png)

1. 全局队列：存放等待运行的G
2. P本地队列：类似全局队列，数量有限（256）；新建G时优先加入本地队列，如果满了移动一半去全局
3. P列表：所有G在程序启动时创建，保存在数组中，最多有`GOMAXPROCS`个
4. M：线程运行任务需要获取P，从P的本地队列获取G，P空M就尝试去全局去一批G放本地，或者去其他P本地偷一半。M执行本地队列的G。

**Goroutine调度器和OS调度器是通过M结合起来的，每个M都代表了1个内核线程，OS调度器负责把内核线程分配到CPU的核上执行**。

##### P和M

1. 数量

   1. P数量
      由启动时环境变量`$GOMAXPROCS`或者是由`runtime`的方法`GOMAXPROCS()`决定。这意味着在程序执行的任意时刻都只有`$GOMAXPROCS`个goroutine在同时运行。
   2. M的数量:
      - go语言本身的限制：go程序启动时，会设置M的最大数量，默认10000.但是内核很难支持这么多的线程数，所以这个限制可以忽略。
        - runtime/debug中的SetMaxThreads函数，设置M的最大数量
        - 一个M阻塞了，会创建新的M。

   M和P没绝对关系，一个M阻塞P去创建或切换其他M。

2. 创建时间

  3. P何时创建：运行时就会根据最大数量来创建

  4. M何时创建：没有M来关联P，P就会去寻找或者创建新的M。


##### 调度器设计策略

复用线程：避免频繁的创建，销毁。

1）work stealing机制

 当本线程无可运行的G时，尝试从其他线程绑定的P偷取G，而不是销毁线程。

2）hand off机制

当本线程因为G进行系统调用阻塞时，线程释放绑定的P，把P转移给其他空闲的线程执行。

**利用并行**：`GOMAXPROCS`设置P的数量，最多有`GOMAXPROCS`个线程分布在多个CPU上同时运行。`GOMAXPROCS`也限制了并发的程度，比如`GOMAXPROCS = 核数/2`，则最多利用了一半的CPU核进行并行。

**抢占**：在coroutine中要等待一个协程主动让出CPU才执行下一个协程，在Go中，一个goroutine最多占用CPU **10ms**，防止其他goroutine被饿死，这就是goroutine不同于coroutine的一个地方。

**全局G队列**：在新的调度器中依然有全局G队列，但功能已经被弱化了，当M执行work stealing从其他P偷不到G时，它可以从全局G队列获取G。

##### go func() 调度流程

![img](https://github.com/aceld/golang/raw/main/images/18-go-func%E8%B0%83%E5%BA%A6%E5%91%A8%E6%9C%9F.jpeg)

1. `go func` 创建G程
2. 新的G优先存在本地队列，本地满了存到全局
3. M会从P中弹出一个G执行，P如果为空会去全局或者其他队列偷
4. 当M执行一个G时如果发生了IO或者其他阻塞操作，M会阻塞。然后P就会被脱离M，寻找其他空闲的M或者新建M去执行。
5. M恢复后会尝试绑定P，如果没有P则M会休眠加入空闲线程，然后G会放入全局队列。

##### 调度器声明周期

![img](https://github.com/aceld/golang/raw/main/images/17-pic-go%E8%B0%83%E5%BA%A6%E5%99%A8%E7%94%9F%E5%91%BD%E5%91%A8%E6%9C%9F.png)

特殊的M0金和G0

**M0**

M0负责初始化和启动第一个G，之后和其他M相同

**G0**

`G0`是每次启动一个M都会第一个创建的gourtine，G0仅用于负责调度的G，G0不指向任何可执行的函数, 每个M都会有一个自己的G0。在调度或系统调用时会使用G0的栈空间, 全局变量的G0是M0的G0。

```go
package main

import "fmt"

func main() {
    fmt.Println("Hello world")
}
```

1. runtime 创建并关联M0,G0
2. 调度器初始化：初始化M0,栈，GC，并创建所有P
3. 示例代码中的main函数是`main.main`，`runtime`中也有1个main函数——`runtime.main`，代码经过编译后，`runtime.main`会调用`main.main`，程序启动时会为`runtime.main`创建goroutine，称它为main goroutine吧，然后把main goroutine加入到P的本地队列。
4. 启动M0,M0会从本地获取G（main g）然后执行
5. M根据G中的栈信息和调度信息设置运行环境
6. M退出G
7. M获取可运行的G，直到main.main退出，runtime.main 执行`defer`或`panic`处理，或者`runtime.exit`退出

##### Go调度场景

1. 新建协程：P1拥有G1,G1创建G2,为了局部性，G2优先加入到P1的本地队列

   ![img](https://github.com/aceld/golang/raw/main/images/26-gmp%E5%9C%BA%E6%99%AF1.png)

2. 协程切换：G1完成后，M上G切换到G0,G0负责协程的调度。从P本地队列获取G2,然后切换到G2运行。

   ![img](https://github.com/aceld/golang/raw/main/images/27-gmp%E5%9C%BA%E6%99%AF2.png)

3. 本地队列满：假设每个P的本地队列只能存3个G。G2要创建了6个G，前3个G（G3, G4, G5）已经加入p1的本地队列，p1本地队列满了。此时创建G7,则需要敷**负载均衡**（把P1中前一半G和新的G打乱后移动到全局队列）

   ![img](https://github.com/aceld/golang/raw/main/images/29-gmp%E5%9C%BA%E6%99%AF4.png)

4. 唤醒M：在创建G时，运行的G会尝试唤醒其他空闲的P和M组合

   ![img](https://github.com/aceld/golang/raw/main/images/31-gmp%E5%9C%BA%E6%99%AF6.png)

   如果M2绑定了G0但没有G去执行，则M2会自旋一段时间寻找G

5. 从全局队列获取：M2尝试从全局队列(简称“GQ”)取一批G放到P2的本地队列（函数：`findrunnable()`）。M2从全局队列取的G数量符合下面的公式：

   ```c
   n = min(len(GQ)/GOMAXPROCS + 1, len(GQ/2))
   ```

   至少从全局队列取1个g，但每次不要从全局队列移动太多的g到p本地队列，给其他p留点。这是**从全局队列到P本地队列的负载均衡**

   ![img](https://github.com/aceld/golang/raw/main/images/32-gmp%E5%9C%BA%E6%99%AF7.001.jpeg)

6. 窃取G：全局和本地队列都没有G了，M会从其他有G的队列中窃取一半的G到本地

   ![img](https://github.com/aceld/golang/raw/main/images/33-gmp%E5%9C%BA%E6%99%AF8.png)

7. 自旋M：全局和本地都没G可运行，M则处于自旋状态来寻找G

   ![img](https://github.com/aceld/golang/raw/main/images/34-gmp%E5%9C%BA%E6%99%AF9.png)

   创建和销毁CPU也会浪费时间，我们**希望当有新goroutine创建时，立刻能有M运行它**，如果销毁再新建就增加了时延，降低了效率。当然也考虑了过多的自旋线程是浪费CPU，所以系统中最多有`GOMAXPROCS`个自旋的线程(当前例子中的`GOMAXPROCS`=4，所以一共4个P)，多余的没事做线程会让他们休眠。

8. M阻塞：M阻塞P就会脱离并寻找可用的M来绑定（如果本地有G）

   ![img](https://github.com/aceld/golang/raw/main/images/35-gmp%E5%9C%BA%E6%99%AF10.png)

9. 非阻塞系统调用：M会和P解绑，但之后会优先和先前的P绑定。

   ![img](https://github.com/aceld/golang/raw/main/images/36-gmp%E5%9C%BA%E6%99%AF11.png)

### 网络轮训器

> <a href="https://draveness.me/golang/docs/part3-runtime/ch06-concurrency/golang-netpoller/#等待事件">原文</a>

网络轮训器可以用于监控网络IO，文件IO等，利用操作系统提供的IO多路复用模型来提升IO设备的利用率和性能。

#### IO 模型

> https://cloud.tencent.com/developer/article/1684951

IO (Input/Output，输入 / 输出) 即数据的读取（接收）或写入（发送）操作，通常用户进程中的一个完整 IO 分为两阶段：用户进程空间 <--> 内核空间、内核空间 <--> 设备空间（磁盘、网络等）。IO 有内存 IO、网络 IO 和磁盘 IO 三种，通常我们说的 IO 指的是后两者。

LINUX 中进程无法直接操作 I/O 设备，其必须通过系统调用请求 kernel 来协助完成 I/O 动作；内核会为每个 I/O 设备维护一个缓冲区。

对于一个输入操作来说，进程 IO 系统调用后，内核会先看缓冲区中有没有相应的缓存数据，没有的话再到设备中读取，因为设备 IO 一般速度较慢，需要等待；内核缓冲区有数据则直接复制到进程空间。

所以，对于一个网络输入操作通常包括两个不同阶段：

1. 等待网络数据到达网卡→读取到内核缓冲区，数据准备好；
2. 从内核缓冲区复制数据到进程空间。

##### 阻塞IO模型

![img](https://ask.qcloudimg.com/http-save/yehe-2728002/iuau3ga8oh.png?imageView2/2/w/1620)

进程发起IO调用后进程阻塞，内核处理完数据后返回给进程。进程阻塞挂起不消耗 CPU 资源，及时响应每个操作

##### 非阻塞IO模型

![img](https://ask.qcloudimg.com/http-save/yehe-2728002/lmtlhwakd3.png?imageView2/2/w/1620)

进程发起调用后不阻塞，但需要进程通过轮训的方式来获取数据是否准备好，进程轮询（重复）调用，消耗 CPU 的资源；

##### IO多路复用模型

![img](https://ask.qcloudimg.com/http-save/yehe-2728002/th1phcx2qx.png?imageView2/2/w/1620)

多个进程的IO可以注册到一个复用器select上，可以用一个进程调用select来阻塞监听所有注册的IO，如何都没有数据返回，进程阻塞,如果任一IO在内核缓冲区有数据，select就返回通知。监听进程则可以自己或者告知其他进程读取。

即多路IO复用可以让一个进程阻塞等待多个IO操作。

1. select,poll

   **都是使用「线性结构」存储进程关注的 Socket 集合，因此都需要遍历文件描述符集合来找到可读或可写的 Socket，时间复杂度为 O(n)，而且也需要在用户态与内核态之间拷贝文件描述符集合**

3. epoll

   1. epoll 在内核里使用**红黑树来跟踪进程所有待检测的文件描述字**
   2. epoll 使用**事件驱动**的机制，内核里**维护了一个链表来记录就绪事件**，当某个 socket 有事件发生时，通过**回调函数**内核会将其加入到这个就绪事件列表中，

##### 信号驱动IO模型

![img](https://ask.qcloudimg.com/http-save/yehe-2728002/rn2e3tdvyk.png?imageView2/2/w/1620)

当进程发起一个 IO 操作，会向内核注册一个信号处理函数，然后进程返回不阻塞；当内核数据就绪时会发送一个信号给进程，进程便在信号处理函数中调用 IO 读取数据。

##### 异步IO模型

![img](https://ask.qcloudimg.com/http-save/yehe-2728002/2iv4y5otku.png?imageView2/2/w/1620)

当进程发起一个 IO 操作，进程返回（不阻塞），但也不能返回结果；内核把整个 IO 处理完后，会通知进程结果。如果 IO 操作成功则进程直接获取到数据。

##### 总结

![img](https://ask.qcloudimg.com/http-save/yehe-2728002/bbw4pzrbed.png?imageView2/2/w/1620)

**同步和异步IO**

主要是指访问数据的机制 (即实际 I/O 操作的完成方式)

**同步**一般指主动请求并等待 I/O 操作完毕的方式，I/O 操作未完成前，会导致应用进程挂起

而**异步**是指用户进程触发 IO 操作以后便开始做自己的事情，而当 IO 操作已经完成的时候会得到 IO完成的通知（异步的特点就是通知）, 这可以使进程在数据读写时也不阻塞。

所以， 阻塞 IO 模型、非阻塞 IO 模型、IO 复用模型、信号驱动的 IO 模型者为同步 IO 模型，只有异步 IO 模型是异步 IO。

**阻塞或者非阻塞 I/O** 主要是指 I/O 操作第一阶段的完成方式 (进程访问的数据如果尚未就绪)，即数据还未准备好的时候，应用进程的表现，如果这里进程挂起，则为阻塞 I/O，否则为非阻塞 I/O。说白了就是阻塞和非阻塞是针对于进程在访问数据的时候，根据 IO操作的就绪状态来采取的不同方式，说白了是一种读取或者写入操作函数的实现方式，**阻塞方式下读取或者写入函数将一直等待**，**而非阻塞方式下，读取或者写入函数会立即返回一个状态值。**

#### 多模块

Go采用IO多路复用模型，为了在不同操作系统中使用对应的复用方法，Go在编译时会编译指定平台的网络轮训模块。

![netpoll-modules](https://img.draveness.me/2020-02-09-15812482347853-netpoll-modules.png)

##### 接口

每个模块都实现了以下函数组成的接口

```go
func netpollinit() // 初始化网络轮询器，通过 sync.Once 和 netpollInited 变量保证函数只会调用一次；
func netpollopen(fd uintptr, pd *pollDesc) int32 // 监听文件描述符上的边缘触发事件，创建事件并加入监听
func netpoll(delta int64) gList //  轮询网络并返回一组已经准备就绪的 Goroutine，传入的参数会决定它的行为 3；
func netpollBreak() // 唤醒网络轮询器，例如：计时器向前修改时间时会通过该函数中断网络轮询器 4；
func netpollIsPollDescriptor(fd uintptr) bool //  判断文件描述符是否被轮询器使用
```

##### 数据结构

操作系统中 I/O 多路复用函数会监控文件描述符的可读或者可写，而 Go 语言网络轮询器会监听 [`runtime.pollDesc`](https://draveness.me/golang/tree/runtime.pollDesc) 结构体的状态，它会封装操作系统的文件描述符：

```go
type pollDesc struct {
	link *pollDesc

	lock    mutex
	fd      uintptr
	...
	rseq    uintptr
	rg      uintptr
	rt      timer
	rd      int64
	wseq    uintptr
	wg      uintptr
	wt      timer
	wd      int64
}
```

该结构体中包含用于监控可读和可写状态的变量，我们按照功能将它们分成以下四组：

- `rseq` 和 `wseq` — 表示文件描述符被重用或者计时器被重置 [5](https://draveness.me/golang/docs/part3-runtime/ch06-concurrency/golang-netpoller/#fn:5)；
- `rg` 和 `wg` — 表示二进制的信号量，可能为 `pdReady`、`pdWait`、等待文件描述符可读或者可写的 Goroutine 以及 `nil`；
- `rd` 和 `wd` — 等待文件描述符可读或者可写的截止日期；
- `rt` 和 `wt` — 用于等待文件描述符的计时器；

该结构体中还保存了用于保护数据的互斥锁、文件描述符。[`runtime.pollDesc`](https://draveness.me/golang/tree/runtime.pollDesc) 结构体会使用 `link` 字段串联成链表存储在 [`runtime.pollCache`](https://draveness.me/golang/tree/runtime.pollCache) 中：

```go
type pollCache struct {
	lock  mutex
	first *pollDesc
}
```

[`runtime.pollCache`](https://draveness.me/golang/tree/runtime.pollCache) 是运行时包中的全局变量，该结构体中包含一个用于保护轮询数据的互斥锁和链表头：

![poll-desc-list](https://img.draveness.me/2020-02-09-15812482347860-poll-desc-list.png)

运行时会在第一次调用 [`runtime.pollCache.alloc`](https://draveness.me/golang/tree/runtime.pollCache.alloc) 方法时初始化总大小约为 4KB 的 [`runtime.pollDesc`](https://draveness.me/golang/tree/runtime.pollDesc) 结构体，[`runtime.persistentAlloc`](https://draveness.me/golang/tree/runtime.persistentAlloc) 会保证这些数据结构初始化在不会触发垃圾回收的内存中，让这些数据结构只能被内部的 `epoll` 和 `kqueue` 模块引用：

```go
func (c *pollCache) alloc() *pollDesc {
	lock(&c.lock)
	if c.first == nil { // 第一次先初始化一批
		const pdSize = unsafe.Sizeof(pollDesc{})
		n := pollBlockSize / pdSize
		if n == 0 {
			n = 1
		}
		mem := persistentalloc(n*pdSize, 0, &memstats.other_sys)
		for i := uintptr(0); i < n; i++ {
			pd := (*pollDesc)(add(mem, i*pdSize))
			pd.link = c.first
			c.first = pd
		}
	}
    // 每次只获取第一个
	pd := c.first
	c.first = pd.link
	unlock(&c.lock)
	return pd
}
```

每次调用该结构体都会返回链表头还没有被使用的 [`runtime.pollDesc`](https://draveness.me/golang/tree/runtime.pollDesc)，这种批量初始化的做法能够增加网络轮询器的吞吐量。Go 语言运行时会调用 [`runtime.pollCache.free`](https://draveness.me/golang/tree/runtime.pollCache.free) 方法释放已经用完的 [`runtime.pollDesc`](https://draveness.me/golang/tree/runtime.pollDesc) 结构，它会直接将结构体插入链表的最前面：

```go
func (c *pollCache) free(pd *pollDesc) {
	lock(&c.lock)
	pd.link = c.first
	c.first = pd
	unlock(&c.lock)
}
```

上述方法没有重置 [`runtime.pollDesc`](https://draveness.me/golang/tree/runtime.pollDesc) 结构体中的字段，该结构体被重复利用时才会由 [`runtime.poll_runtime_pollOpen`](https://draveness.me/golang/tree/runtime.poll_runtime_pollOpen) 函数重置。

#### 多路复用

网络轮询器实际上是对 I/O 多路复用技术的封装，本节将通过以下的三个过程分析网络轮询器的实现原理：

1. 网络轮询器的初始化；
2. 如何向网络轮询器加入待监控的任务；
3. 如何从网络轮询器获取触发的事件；

4. 因为不同 I/O 多路复用模块的实现大同小异，本节会使用 Linux 操作系统上的 `epoll` 实现；
5. 因为处理读事件和写事件的逻辑类似，本节会省略写事件相关的代码；

##### 初始化

因为文件 I/O、网络 I/O 以及计时器都依赖网络轮询器，所以 Go 语言会通过以下两条不同路径初始化网络轮询器：

1. [`internal/poll.pollDesc.init`](https://draveness.me/golang/tree/internal/poll.pollDesc.init) — 通过 [`net.netFD.init`](https://draveness.me/golang/tree/net.netFD.init) 和 [`os.newFile`](https://draveness.me/golang/tree/os.newFile) 初始化网络 I/O 和文件 I/O 的轮询信息时；
2. [`runtime.doaddtimer`](https://draveness.me/golang/tree/runtime.doaddtimer) — 向处理器中增加新的计时器时；

网络轮询器的初始化会使用[`runtime.poll_runtime_pollServerInit`](https://draveness.me/golang/tree/runtime.poll_runtime_pollServerInit) 和 [`runtime.netpollGenericInit`](https://draveness.me/golang/tree/runtime.netpollGenericInit) 两个函数：

```go
func poll_runtime_pollServerInit() {
	netpollGenericInit()
}

func netpollGenericInit() {
	if atomic.Load(&netpollInited) == 0 {
		lock(&netpollInitLock)
		if netpollInited == 0 {
			netpollinit()
			atomic.Store(&netpollInited, 1)
		}
		unlock(&netpollInitLock)
	}
}
```

[`runtime.netpollGenericInit`](https://draveness.me/golang/tree/runtime.netpollGenericInit) 会调用平台上特定实现的 [`runtime.netpollinit`](https://draveness.me/golang/tree/runtime.netpollinit)，即 Linux 上的 `epoll`。

```go
var (
	epfd int32 = -1
	netpollBreakRd, netpollBreakWr uintptr
)

// 调用epoll；
// 1. epollcreate1 创建新的文件描述符
// 2. nonblockingPipe 创建用于通信的管道
// 3. 使用 epollctl 将用于读取数据的文件描述符打包成 epollevent 事件加入监听
func func netpollBreak() {
	for {
		var b byte
		n := write(netpollBreakWr, unsafe.Pointer(&b), 1)
		if n == 1 {
			break
		}
		if n == -_EINTR {
			continue
		}
		if n == -_EAGAIN {
			return
		}
	}
}() {
	epfd = epollcreate1(_EPOLL_CLOEXEC) // 1
	r, w, _ := nonblockingPipe() // 2
	ev := epollevent{
		events: _EPOLLIN,
	}
	*(**uintptr)(unsafe.Pointer(&ev.data)) = &netpollBreakRd
	epollctl(epfd, _EPOLL_CTL_ADD, r, &ev) // 3
	netpollBreakRd = uintptr(r)
	netpollBreakWr = uintptr(w)
}
```

初始化的管道为我们提供了中断多路复用等待文件描述符中事件的方法，[`runtime.netpollBreak`](https://draveness.me/golang/tree/runtime.netpollBreak) 会向管道中写入数据唤醒 `epoll`：

```go
func netpollBreak() {
	for {
		var b byte
		n := write(netpollBreakWr, unsafe.Pointer(&b), 1)
		if n == 1 {
			break
		}
		if n == -_EINTR {
			continue
		}
		if n == -_EAGAIN {
			return
		}
	}
}
```

因为目前的计时器由网络轮询器管理和触发，它能够让网络轮询器立刻返回并让运行时检查是否有需要触发的计时器。

##### 轮训事件

调用 [`internal/poll.pollDesc.init`](https://draveness.me/golang/tree/internal/poll.pollDesc.init) 初始化文件描述符时不止会初始化网络轮询器，还会通过 [`runtime.poll_runtime_pollOpen`](https://draveness.me/golang/tree/runtime.poll_runtime_pollOpen) 重置轮询信息 [`runtime.pollDesc`](https://draveness.me/golang/tree/runtime.pollDesc) 并调用 [`runtime.netpollopen`](https://draveness.me/golang/tree/runtime.netpollopen) 初始化轮询事件

```go
// 重置轮询信息
func poll_runtime_pollOpen(fd uintptr) (*pollDesc, int) {
	pd := pollcache.alloc() // 获取可用文件描述符
	lock(&pd.lock)
	if pd.wg != 0 && pd.wg != pdReady {
		throw("runtime: blocked write on free polldesc")
	}
	...
	pd.fd = fd
	pd.closing = false
	pd.everr = false
	...
	pd.wseq++
	pd.wg = 0
	pd.wd = 0
	unlock(&pd.lock)

	var errno int32
	errno = netpollopen(fd, pd) // 初始化轮询事件
	return pd, int(errno)
}

func netpollopen(fd uintptr, pd *pollDesc) int32 {
	var ev epollevent
	ev.events = _EPOLLIN | _EPOLLOUT | _EPOLLRDHUP | _EPOLLET
	*(**pollDesc)(unsafe.Pointer(&ev.data)) = pd
    // 调用 epollctl 向全局的轮询文件描述符 epfd 中加入新的轮询事件监听文件描述符的可读和可写状态：
	return -epollctl(epfd, _EPOLL_CTL_ADD, int32(fd), &ev)
}
```

从全局的 `epfd` 中删除待监听的文件描述符可以使用 [`runtime.netpollclose`](https://draveness.me/golang/tree/runtime.netpollclose)

##### 事件循环

事件循环的原理

- Goroutine 让出线程并等待读写事件；
- 多路复用等待读写事件的发生并返回；

###### 等待事件

当我们在文件描述符上执行读写操作时，如果文件描述符不可读或者不可写，当前 Goroutine 会执行 [`runtime.poll_runtime_pollWait`](https://draveness.me/golang/tree/runtime.poll_runtime_pollWait) 检查 [`runtime.pollDesc`](https://draveness.me/golang/tree/runtime.pollDesc) 的状态并调用 [`runtime.netpollblock`](https://draveness.me/golang/tree/runtime.netpollblock) 等待文件描述符的可读或者可写：

```go
func poll_runtime_pollWait(pd *pollDesc, mode int) int {
	...
    // 会调用gopark让出当前线程，将go程转为休眠状态
	for !netpollblock(pd, int32(mode), false) {
		...
	}
	return 0
}

func netpollblock(pd *pollDesc, mode int32, waitio bool) bool {
	gpp := &pd.rg
	if mode == 'w' {
		gpp = &pd.wg
	}
	...
	if waitio || netpollcheckerr(pd, mode) == 0 {
		gopark(netpollblockcommit, unsafe.Pointer(gpp), waitReasonIOWait, traceEvGoBlockNet, 5)
	}
	...
}
```

###### 轮训等待

Go 语言的运行时会在调度或者系统监控中调用 [`runtime.netpoll`](https://draveness.me/golang/tree/runtime.netpoll) 轮询网络，该函数的执行过程可以分成以下几个部分：

1. 根据传入的 `delay` 计算 `epoll` 系统调用需要等待的时间；
2. 调用 `epollwait` 等待可读或者可写事件的发生；
3. 在循环中依次处理 `epollevent` 事件；

```go
// 因为传入 delay 的单位是纳秒，下面这段代码会将纳秒转换成毫秒：
func netpoll(delay int64) gList {
	var waitms int32
	if delay < 0 {
		waitms = -1
	} else if delay == 0 {
		waitms = 0
	} else if delay < 1e6 {
		waitms = 1
	} else if delay < 1e15 {
		waitms = int32(delay / 1e6)
	} else {
		waitms = 1e9
	}
```

计算了需要等待的时间之后，[`runtime.netpoll`](https://draveness.me/golang/tree/runtime.netpoll) 会执行 `epollwait` 等待文件描述符转换成可读或者可写，如果该函数返回了负值，可能会返回空的 Goroutine 列表或者重新调用 `epollwait` 陷入等待：

```go
	var events [128]epollevent
retry:
	n := epollwait(epfd, &events[0], int32(len(events)), waitms)
	if n < 0 {
		if waitms > 0 {
			return gList{}
		}
		goto retry
	}
```

当 `epollwait` 系统调用返回的值大于 0 时，意味着被监控的文件描述符出现了待处理的事件，我们在如下所示的循环中会依次处理这些事件：

```go
var toRun gList
	for i := int32(0); i < n; i++ {
		ev := &events[i]
		if *(**uintptr)(unsafe.Pointer(&ev.data)) == &netpollBreakRd {
			...
			continue
		}

		var mode int32
		if ev.events&(_EPOLLIN|_EPOLLRDHUP|_EPOLLHUP|_EPOLLERR) != 0 {
			mode += 'r'
		}
		...
		if mode != 0 {
			pd := *(**pollDesc)(unsafe.Pointer(&ev.data))
			pd.everr = false
			netpollready(&toRun, pd, mode)
		}
	}
	return toRun
}
```

处理的事件总共包含两种，一种是调用 [`runtime.netpollBreak`](https://draveness.me/golang/tree/runtime.netpollBreak) 触发的事件，该函数的作用是中断网络轮询器；另一种是其他文件描述符的正常读写事件，对于这些事件，我们会交给 [`runtime.netpollready`](https://draveness.me/golang/tree/runtime.netpollready) 处理：

```go
func netpollready(toRun *gList, pd *pollDesc, mode int32) {
	var rg, wg *g
	...
	if mode == 'w' || mode == 'r'+'w' {
		wg = netpollunblock(pd, 'w', true)
	}
	...
	if wg != nil {
		toRun.push(wg)
	}
}
```

[`runtime.netpollunblock`](https://draveness.me/golang/tree/runtime.netpollunblock) 会在读写事件发生时，将 [`runtime.pollDesc`](https://draveness.me/golang/tree/runtime.pollDesc) 中的读或者写信号量转换成 `pdReady` 并返回其中存储的 Goroutine；如果返回的 Goroutine 不会为空，那么运行时会将该 Goroutine 会加入 `toRun` 列表，并将列表中的全部 Goroutine 加入运行队列并等待调度器的调度。

[`runtime.netpoll`](https://draveness.me/golang/tree/runtime.netpoll) 返回的 Goroutine 列表都会被 [`runtime.injectglist`](https://draveness.me/golang/tree/runtime.injectglist) 注入到处理器或者全局的运行队列上。因为**系统监控** Goroutine 直接运行在线程上，所以它获取的 Goroutine 列表会直接加入全局的运行队列，其他 Goroutine 获取的列表都会加入 Goroutine 所在处理器的运行队列上。

###### 截止日期

网络轮询器和计时器的关系非常紧密，这不仅仅是因为网络轮询器负责计时器的唤醒，还因为文件和网络 I/O 的截止日期也由网络轮询器负责处理。截止日期在 I/O 操作中，尤其是网络调用中很关键，网络请求存在很高的不确定因素，我们需要设置一个截止日期保证程序的正常运行，这时需要用到网络轮询器中的 [`runtime.poll_runtime_pollSetDeadline`](https://draveness.me/golang/tree/runtime.poll_runtime_pollSetDeadline)：

```go
func poll_runtime_pollSetDeadline(pd *pollDesc, d int64, mode int) {
	rd0, wd0 := pd.rd, pd.wd
	if d > 0 {
		d += nanotime()
	}
	pd.rd = d
	...
	if pd.rt.f == nil { // 没有对应执行函数
		if pd.rd > 0 {
			pd.rt.f = netpollReadDeadline
			pd.rt.arg = pd
			pd.rt.seq = pd.rseq
			resettimer(&pd.rt, pd.rd) // 重置计时器
		}
	} else if pd.rd != rd0 { // 读截止日期发生修改
		pd.rseq++
		if pd.rd > 0 { // 截止日期大于0修改计时器
			modtimer(&pd.rt, pd.rd, 0, rtf, pd, pd.rseq)
		} else { // 删除计时器
			deltimer(&pd.rt)
			pd.rt.f = nil
		}
	}
    ...
    // 重新检查轮训信息中存储的截止日期
   	var rg *g
	if pd.rd < 0 {
		if pd.rd < 0 {
			rg = netpollunblock(pd, 'r', false)
		}
		...
	}
	if rg != nil {
		netpollgoready(rg, 3) // 直接唤醒过期的go程
	}
	...
}
```

Goroutine 在被唤醒之后会意识到当前的 I/O 操作已经超时，可以根据需要选择重试请求或者中止调用。

#### 总结

网络轮询器并不是由运行时中的某一个线程独立运行的，运行时的调度器和系统调用都会通过 [`runtime.netpoll`](https://draveness.me/golang/tree/runtime.netpoll) 与网络轮询器交换消息，获取待执行的 Goroutine 列表，并将待执行的 Goroutine 加入运行队列等待处理。

## 内存管理

> 刘丹冰yyds！
>
> https://www.yuque.com/aceld/golang/qzyivn#cDuEt

Golang的内存管理就是基于TCMalloc的核心思想来构建的。

### TCMalloc

TCMalloc最大优势就是每个线程都会独立维护自己的内存池。

所有go程共享的内存池模型：

![image.png](https://cdn.nlark.com/yuque/0/2022/png/26269664/1651132777839-f6077cf7-f8e4-40d0-9fa0-1167208508da.png?x-oss-process=image%2Fwatermark%2Ctype_d3F5LW1pY3JvaGVp%2Csize_58%2Ctext_5YiY5Li55YawQWNlbGQ%3D%2Ccolor_FFFFFF%2Cshadow_50%2Ct_80%2Cg_se%2Cx_10%2Cy_10%2Fresize%2Cw_937%2Climit_0)

缺点：应用方内存申请需要和全局BufPool打交道，为了线程安全需要频繁加锁和解锁

#### 层级模型

TCMalloc则为每个线程预分配一块缓存，每个线程在申请内存的时候会先从**线程缓存池**中申请。每个**线程缓存池**共享一块**中心缓存**。

![TCMalloc模型图](https://cdn.nlark.com/yuque/0/2022/png/26269664/1651132869540-a130e8b3-1f7d-45ec-8413-52bba81426a0.png?x-oss-process=image%2Fwatermark%2Ctype_d3F5LW1pY3JvaGVp%2Csize_57%2Ctext_5YiY5Li55YawQWNlbGQ%3D%2Ccolor_FFFFFF%2Cshadow_50%2Ct_80%2Cg_se%2Cx_10%2Cy_10%2Fresize%2Cw_937%2Climit_0)

好处：线程独立缓存减少加锁发生次数

ThreadCache 作为线程独立的第一交互内存，访问无需加锁，CentralCache 则作为 ThreadCache 临时补充缓存。

**内存对象划分**：

| **对象** | **容量**     |
| -------- | ------------ |
| 小对象   | (0,256KB]    |
| 中对象   | (256KB, 1MB] |
| 大对象   | (1MB, +∞)    |

ThreadCache和CentralCache可以用来解决小对象内存块的申请。

而对于中，大对象的内存申请，TCMalloc提供一个全局共享的内存堆**PageHeap**。当然对其进行操作需要进行加锁。

![image.png](https://cdn.nlark.com/yuque/0/2022/png/26269664/1651133032054-ea888b96-0fb0-46ea-ac26-4c38abc2b66f.png?x-oss-process=image%2Fwatermark%2Ctype_d3F5LW1pY3JvaGVp%2Csize_89%2Ctext_5YiY5Li55YawQWNlbGQ%3D%2Ccolor_FFFFFF%2Cshadow_50%2Ct_80%2Cg_se%2Cx_10%2Cy_10%2Fresize%2Cw_1038%2Climit_0)

页堆主要时当中心缓存没空间时向其申请，过多时退还，以及线程在申请大对象超过Cache的内存单元块单元大小时也会直接向页堆申请。

#### 基础结构

##### Page

TCMalloc将虚拟内存划分为多份同等大小的Page，每个Page默认`8KB`，可以通过地址指针+偏移量来确定Page位置。

![image.png](https://cdn.nlark.com/yuque/0/2022/png/26269664/1651133095495-53138cb4-89b8-4833-ac41-7957a1c19354.png?x-oss-process=image%2Fwatermark%2Ctype_d3F5LW1pY3JvaGVp%2Csize_82%2Ctext_5YiY5Li55YawQWNlbGQ%3D%2Ccolor_FFFFFF%2Cshadow_50%2Ct_80%2Cg_se%2Cx_10%2Cy_10%2Fresize%2Cw_959%2Climit_0)

##### Span

多个连续的 Page 称之为是一个 Span，其定义含义有操作系统的管理的页表相似。

![image.png](https://cdn.nlark.com/yuque/0/2022/png/26269664/1651133255704-7c07cb59-d879-468f-a925-d3494454cb7d.png?x-oss-process=image%2Fwatermark%2Ctype_d3F5LW1pY3JvaGVp%2Csize_82%2Ctext_5YiY5Li55YawQWNlbGQ%3D%2Ccolor_FFFFFF%2Cshadow_50%2Ct_80%2Cg_se%2Cx_10%2Cy_10%2Fresize%2Cw_960%2Climit_0)

TCMalloc 是以 Span 为单位向操作系统申请内存的。每个 Span 记录了第一个起始 Page 的编号 Start，和一共有多少个连续 Page 的数量 Length。

同时**span之间通过双向链表来连接**。

##### Size Class

在**256KB以内的小对象**会被TCMalloc划分为多个内存刻度，同一个刻度下的内存集合称为**Size Class**.

![image.png](https://cdn.nlark.com/yuque/0/2022/png/26269664/1651133299709-8c33bad3-a31f-4844-b07c-ad54a0dc64d4.png?x-oss-process=image%2Fwatermark%2Ctype_d3F5LW1pY3JvaGVp%2Csize_67%2Ctext_5YiY5Li55YawQWNlbGQ%3D%2Ccolor_FFFFFF%2Cshadow_50%2Ct_80%2Cg_se%2Cx_10%2Cy_10%2Fresize%2Cw_937%2Climit_0)

每个`Size Class`都对应一个字节大小。在申请小对象内存时，TCMalloc会根据申请字节向上取一个`Size Class`的Span（多个page组成）的内存块给使用者。

##### ThreadCache

`ThreadCache`即线程自己的缓存。其对于每个`SizeClass`都有一个对应的`FreeList`，表示当前缓存中还有多少空闲的内存可用。

![image.png](https://cdn.nlark.com/yuque/0/2022/png/26269664/1651133403346-3d07b578-45df-41b1-880e-d1a591d106ff.png?x-oss-process=image%2Fwatermark%2Ctype_d3F5LW1pY3JvaGVp%2Csize_97%2Ctext_5YiY5Li55YawQWNlbGQ%3D%2Ccolor_FFFFFF%2Cshadow_50%2Ct_80%2Cg_se%2Cx_10%2Cy_10%2Fresize%2Cw_1139%2Climit_0)

流程：使用者申请小对象内存直接通过`ThreadCache`获取对应`Size Class`的一个`Span`，如果对应的`Size Class`下的链表为nil，则`ThreadCache`会向`ThreadCache`申请空间，线程用完内存后也是直接归还到本线程对应刻度下的span双向链表中。

##### CentralCache

`CentralCache`是所有线程共用的。其结构和`ThreadCache`相似，各个刻度的`span`链表被放置在`CentralFreeList`之中。

![image.png](https://cdn.nlark.com/yuque/0/2022/png/26269664/1651133530033-bd9265dc-fd49-4a77-a845-f175ab317ea9.png?x-oss-process=image%2Fwatermark%2Ctype_d3F5LW1pY3JvaGVp%2Csize_97%2Ctext_5YiY5Li55YawQWNlbGQ%3D%2Ccolor_FFFFFF%2Cshadow_50%2Ct_80%2Cg_se%2Cx_10%2Cy_10%2Fresize%2Cw_1140%2Climit_0)

流程：`ThreadCache`在内存不够时会向`CentralFreeList`申请指定刻度的内存，当其内存多余时也会归还给`CentralFreeList`。`PageHeap`和`CentralFreeList`关系也类似。

##### PageHeap

Head与CentralCache不同的是CentralCache是与ThreadCache布局一模一样的缓存，主要是起到针对ThreadCache的一层二级缓存作用，**且只支持小对象内存分配**。**而PageHeap则是针对CentralCache的三级缓存,弥补对于中对象内存和大对象内存的分配**，PageHeap也是直接和操作系统虚拟内存衔接的一层缓存。

![image.png](https://cdn.nlark.com/yuque/0/2022/png/26269664/1651133596465-fd16a3cc-256a-464c-a066-b896043a9f63.png?x-oss-process=image%2Fwatermark%2Ctype_d3F5LW1pY3JvaGVp%2Csize_101%2Ctext_5YiY5Li55YawQWNlbGQ%3D%2Ccolor_FFFFFF%2Cshadow_50%2Ct_80%2Cg_se%2Cx_10%2Cy_10%2Fresize%2Cw_1178%2Climit_0)

当一二级缓存都无法分配对应的内存时，三次缓存则通过系统调用来从虚拟内存的堆区中获取内存来填充。

`PageHeap`内部的`Span`管理采取两种方式

1. `128`个page以内使用链表
2. `128`以上的page则通过有序集合来存放

#### 小对象分配

![image.png](https://cdn.nlark.com/yuque/0/2022/png/26269664/1651133672724-0ac13b26-1623-444a-8c81-0b2120b2e2fa.png?x-oss-process=image%2Fwatermark%2Ctype_d3F5LW1pY3JvaGVp%2Csize_80%2Ctext_5YiY5Li55YawQWNlbGQ%3D%2Ccolor_FFFFFF%2Cshadow_50%2Ct_80%2Cg_se%2Cx_10%2Cy_10%2Fresize%2Cw_938%2Climit_0)

（1）Thread 用户线程应用逻辑申请内存，当前 Thread 访问对应的 ThreadCache 获取内存，此过程不需要加锁。

（2）ThreadCache 的得到申请内存的 SizeClass（一般向上取整，大于等于申请的内存大小），通过 SizeClass 索引去请求自身对应的 FreeList。

（3）判断得到的 FreeList 是否为非空。

（4）如果 FreeList 非空，则表示目前有对应内存空间供 Thread 使用，得到 FreeList 第一个空闲 Span 返回给 Thread 用户逻辑，流程结束。

（5）如果 FreeList 为空，则表示目前没有对应 SizeClass 的空闲 Span 可使用，请求 CentralCache 并告知 CentralCache 具体的 SizeClass。

（6）CentralCache 收到请求后，加锁访问 CentralFreeList，根据 SizeClass 进行索引找到对应的 CentralFreeList。

（7）判断得到的 CentralFreeList 是否为非空。

（8）如果 CentralFreeList 非空，则表示目前有空闲的 Span 可使用。返回多个 Span，将这些 Span（除了第一个 Span）放置 ThreadCache 的 FreeList 中，并且将第一个 Span 返回给 Thread 用户逻辑，流程结束。

（9）如果 CentralFreeList 为空，则表示目前没有可用是 Span 可使用，向 PageHeap 申请对应大小的 Span。

（10）PageHeap 得到 CentralCache 的申请，加锁请求对应的 Page 刻度的 Span 链表。

（11）PageHeap 将得到的 Span 根据本次流程请求的 SizeClass 大小为刻度进行拆分，分成 N 份 SizeClass 大小的 Span 返回给 CentralCache，如果有多余的 Span 则放回 PageHeap 对应 Page 的 Span 链表中。

（12）CentralCache 得到对应的 N 个 Span，添加至 CentralFreeList 中，跳转至第（8）步。

#### 中对象分配

中对象是在`256KB-1M`之间的内存。TCMalloc会直接从`Pageheap`获取。

![image.png](https://cdn.nlark.com/yuque/0/2022/png/26269664/1651133803693-486e9b4a-ffb1-4932-a989-1df013b601c1.png?x-oss-process=image%2Fwatermark%2Ctype_d3F5LW1pY3JvaGVp%2Csize_71%2Ctext_5YiY5Li55YawQWNlbGQ%3D%2Ccolor_FFFFFF%2Cshadow_50%2Ct_80%2Cg_se%2Cx_10%2Cy_10%2Fresize%2Cw_937%2Climit_0)

PageHeap将128个Page以内大小的Span定义为小Span，将128个Page以上大小的Span定义为大Span。

所以中对象划分为小span进行分配。

（1）Thread 用户逻辑层提交内存申请处理，如果本次申请内存超过 256KB 但不超过 1MB 则属于中对象申请。TCMalloc 将直接向 PageHeap 发起申请 Span 请求。

（2）PageHeap 接收到申请后需要判断本次申请是否属于小 Span（128 个 Page 以内），如果是，则走小 Span，即中对象申请流程，如果不是，则进入大对象申请流程。

（3）PageHeap 根据申请的 Span 在小 Span 的链表中向上取整，得到最适应的第 K 个 Page 刻度的 Span 链表。

（4）得到第 K 个 Page 链表刻度后，将 K 作为起始点，向下遍历找到第一个非空链表，直至 128 个 Page 刻度位置，找到则停止，将停止处的非空 Span 链表作为提供此次返回的内存 Span，将链表中的第一个 Span 取出。如果找不到非空链表，则当错本次申请为大 Span 申请，则进入大对象申请流程。

（5）假设本次获取到的 Span 由 N 个 Page 组成。PageHeap 将 N 个 Page 的 Span 拆分成两个 Span，其中一个为 K 个 Page 组成的 Span，作为本次内存申请的返回，给到 Thread，另一个为 N-K 个 Page 组成的 Span，重新插入到 N-K 个 Page 对应的 Span 链表中。

#### 大对象分配

对于超过 128 个 Page（即 1MB）的内存分配则为大对象分配流程。大对象分配与中对象分配情况类似，Thread 绕过 ThreadCache 和 CentralCache，直接向 PageHeap 获取

![image.png](https://cdn.nlark.com/yuque/0/2022/png/26269664/1651133987470-28f3feb2-8a9e-45be-a41b-596b1bd54e8d.png?x-oss-process=image%2Fwatermark%2Ctype_d3F5LW1pY3JvaGVp%2Csize_81%2Ctext_5YiY5Li55YawQWNlbGQ%3D%2Ccolor_FFFFFF%2Cshadow_50%2Ct_80%2Cg_se%2Cx_10%2Cy_10%2Fresize%2Cw_950%2Climit_0)

进入大对象分配流程除了申请的 Span 大于 128 个 Page 之外，对于中对象分配如果找不到非空链表也会进入大对象分配流程

（1）Thread 用户逻辑层提交内存申请处理，如果本次申请内存超过 1MB 则属于大对象申请。TCMalloc 将直接向 PageHeap 发起申请 Span      。

（2）PageHeap 接收到申请后需要判断本次申请是否属于小 Span（128 个 Page 以内），如果是，则走小 Span 中对象申请流程（上一节已介绍），如果不是，则进入大对象申请流程

（3）PageHeap根据Span的大小按照Page单元进行除法运算，向上取整，得到最接近Span的且大于Span的Page倍数K,此时的K应该是大于128。如果是从中对象流程分过来的（中对象申请流程可能没有非空链表提供Span),则K值应该小于128。

（4）搜索 Large Span Set 集合，找到不小于 K 个 Page 的最小 Span（N 个 Page）。如果没有找到合适的 Span，则说明 PageHeap 已经无法满足需求，则向操作系统虚拟内存的堆空间申请一堆内存，将申请到的内存安置在 PageHeap 的内存结构中，重新执行（3）步骤

（5）将从 Large Span Set 集合得到的 N 个 Page 组成的 Span 拆分成两个 Span，K 个 Page 的 Span 直接返回给 Thread 用户逻辑，N-K 个 Span 退还给 PageHeap。其中如果 N-K 大于 128 则退还到 Large Span Set 集合中，如果 N-K 小于 128，则退还到 Page 链表中。

### Go 堆内存管理

#### 层级模型

![image.png](https://cdn.nlark.com/yuque/0/2022/png/26269664/1651134285363-999c7495-7834-4785-a6ea-c44b4615ff19.png?x-oss-process=image%2Fwatermark%2Ctype_d3F5LW1pY3JvaGVp%2Csize_58%2Ctext_5YiY5Li55YawQWNlbGQ%3D%2Ccolor_FFFFFF%2Cshadow_50%2Ct_80%2Cg_se%2Cx_10%2Cy_10%2Fresize%2Cw_937%2Climit_0)

#### 结构模型

Golang 内存管理中依然保留 TCMalloc 中的 Page、Span、Size Class 等概念

1. Page

   与 TCMalloc 的 Page 一致。Golang 内存管理模型延续了 TCMalloc 的概念，一个 Page 的大小依然是 8KB。Page 表示 Golang 内存管理与虚拟内存交互内存的最小单元。操作系统虚拟内存对于 Golang 来说，依然是划分成等分的 N 个 Page 组成的一块大内存公共池

2. mSpan

   TCMalloc中的Span一致。mSpan概念依然延续TCMalloc中的Span概念，在Golang中将Span的名称改为mSpan，依然表示一组连续的Page。

3. Size Class相关

   1. Object Size

      指协程应用逻辑一次向Golang内存申请的对象Object大小。

      Object时Go内存管理模块更细化的管理单元。一个`span`在初始化时会被分为多个`Object`。逻辑层向Go内存模型取内存实际是获取`Object`。

      ![image.png](https://cdn.nlark.com/yuque/0/2022/png/26269664/1651134337384-3b5b18a9-63a2-41eb-89fb-d7a030b1e569.png?x-oss-process=image%2Fwatermark%2Ctype_d3F5LW1pY3JvaGVp%2Csize_79%2Ctext_5YiY5Li55YawQWNlbGQ%3D%2Ccolor_FFFFFF%2Cshadow_50%2Ct_80%2Cg_se%2Cx_10%2Cy_10%2Fresize%2Cw_937%2Climit_0)

      **注意 Page是Golang内存管理与操作系统交互衡量内存容量的基本单元，Golang内存管理内部本身用来给对象存储内存的基本单元是Object。**

   2. Size Clase

      Golang内存管理中的Size Class与TCMalloc所表示的设计含义是一致的，都表示一块内存的所属规格或者刻度。Golang内存管理中的Size Class是针对Object Size来划分内存的。也是划分Object大小的级别。比如Object Size在1Byte~8Byte之间的Object属于Size Class 1级别，Object Size 在8B~16Byte之间的属于Size Class 2级别。

   3. Span Class

      这个是 Golang 内存管理额外定义的规格属性，是针对 Span 来进行划分的，是 Span 大小的级别。一个 Size Class 会对应两个 Span Class，其中一个 Span 为存放需要 GC 扫描的对象（包含指针的对象），另一个 Span 为存放不需要 GC 扫描的对象（不包含指针的对象）

      ![image.png](https://cdn.nlark.com/yuque/0/2022/png/26269664/1651134377320-3f71752d-65fa-4081-a255-09c387f23a65.png?x-oss-process=image%2Fwatermark%2Ctype_d3F5LW1pY3JvaGVp%2Csize_70%2Ctext_5YiY5Li55YawQWNlbGQ%3D%2Ccolor_FFFFFF%2Cshadow_50%2Ct_80%2Cg_se%2Cx_10%2Cy_10%2Fresize%2Cw_937%2Climit_0)

      `Size Class`明细

      ```go
      //usr/local/go/src/runtime/sizeclasses.go
      
      package runtime
      
      // 标题Title解释：
      // [class]: Size Class
      // [bytes/obj]: Object Size，一次对外提供内存Object的大小
      // [bytes/span]: 当前Object所对应Span的内存大小
      // [objects]: 当前Span一共有多少个Object
      // [tail wastre]: 为当前Span平均分层N份Object，会有多少内存浪费
      // [max waste]: 当前Size Class最大可能浪费的空间所占百分比
      
      // class  bytes/obj  bytes/span  objects  tail waste  max waste
      //     1          8        8192     1024           0        87.50%
      //     2         16        8192      512           0        43.75%
      //     3         32        8192      256           0        46.88%
      //     4         48        8192      170          32        31.52%
      //     5         64        8192      128           0        23.44%
      //     6         80        8192      102          32        19.07%
      //     7         96        8192       85          32        15.95%
      //     8        112        8192       73          16        13.56%
      ...
      ```

##### MCache

类似于TCMalloc的`ThreadCache`，协程访问不需要加锁。

`MCache`绑定在`处理器P`中，因为实际可运行的M数量和`P`相同。

![image.png](https://cdn.nlark.com/yuque/0/2022/png/26269664/1651134640677-2a153c96-b7e8-46bc-86f3-dfaf50087329.png?x-oss-process=image%2Fwatermark%2Ctype_d3F5LW1pY3JvaGVp%2Csize_84%2Ctext_5YiY5Li55YawQWNlbGQ%3D%2Ccolor_FFFFFF%2Cshadow_50%2Ct_80%2Cg_se%2Cx_10%2Cy_10%2Fresize%2Cw_982%2Climit_0)

**MCache 中每个 Span Class 都会对应一个 MSpan**，不同 Span Class 的 MSpan 的总体长度不同，参考 runtime/sizeclasses.go 的标准规定划分。比如对于 Span Class 为 4 的 MSpan 来说，存放内存大小为 1Page，即 8KB。每个对外提供的 Object 大小为 16B，共存放 512 个 Object。其他 Span Class 的存放方式类似。当其中某个 Span Class 的 MSpan 已经没有可提供的 Object 时，MCache 则会向 MCentral 申请一个对应的 MSpan。

注：申请size时是0则返回固定地址。

##### MCentral

当 MCache 中某个 Size Class 对应的 Span 被一次次 Object 被上层取走后，如果出现当前 Size Class 的 Span 空缺情况，MCache 则会向 MCentral 申请对应的 Span。

![image.png](https://cdn.nlark.com/yuque/0/2022/png/26269664/1651134740690-c1fc15a5-af2a-474c-adaa-ddc4bb05a5e3.png?x-oss-process=image%2Fwatermark%2Ctype_d3F5LW1pY3JvaGVp%2Csize_89%2Ctext_5YiY5Li55YawQWNlbGQ%3D%2Ccolor_FFFFFF%2Cshadow_50%2Ct_80%2Cg_se%2Cx_10%2Cy_10%2Fresize%2Cw_1036%2Climit_0)

和TCMalloc类似，本层的span取完之后向上一层请求。

**其中协程逻辑层与MCache的内存交换单位是Object，MCache与MCentral的内存交换单位是Span，而MCentral与MHeap的内存交换单位是Page。**

**MCentral 与 TCMalloc 中的 Central 不同的是 MCentral 针对每个 Span Class 级别有两个 Span 链表，而 TCMalloc 中的 Central 只有一个**。

**MCentral与MCache不同的是，每个级别保存的不是一个Span，而是一个Span List链表。与TCMalloc中的Central不同的是，MCentral每个级别都保存了两个Span List。**

![image.png](https://cdn.nlark.com/yuque/0/2022/png/26269664/1651134816735-43c615ce-3c3c-485a-9ae2-e36dca963f95.png?x-oss-process=image%2Fwatermark%2Ctype_d3F5LW1pY3JvaGVp%2Csize_88%2Ctext_5YiY5Li55YawQWNlbGQ%3D%2Ccolor_FFFFFF%2Cshadow_50%2Ct_80%2Cg_se%2Cx_10%2Cy_10%2Fresize%2Cw_1032%2Climit_0)

> **注意 图 38 中 MCentral 是表示一层抽象的概念，实际上每个 Span Class 对应的内存数据结构是一个 mcentral，即在 MCentral 这层数据管理中，实际上有 Span Class 个 mcentral 小内存管理单元。**

1）NonEmpty Span List（非空，退还的span放里面）
表示还有可用空间的 Span 链表。链表中的所有 Span 都至少有 1 个空闲的 Object 空间。如果 MCentral 上游 MCache 退还 Span，会将退还的 Span 加入到 NonEmpty Span List 链表中。
2）Empty Span List（可能为空，分配的span放这里）
表示没有可用空间的 Span 链表。该链表上的 Span 都不确定否还有有空闲的 Object 空间。如果 MCentral 提供给一个 Span 给到上游 MCache，那么被提供的 Span 就会加入到 Empty List 链表中。

> 注意 在 Golang 1.16 版本之后，MCentral 中的 NonEmpty Span List 和 Empty Span List
> 均由链表管理改成集合管理，分别对应 Partial Span Set 和 Full Span Set。虽然存储的数据结构有变化，但是基本的作用和职责没有区别。

```go
// Go V1.14
//usr/local/go/src/runtime/mcentral.go

// Central list of free objects of a given size.
// go:notinheap
type mcentral struct {
lock      mutex      //申请MCentral内存分配时需要加的锁

spanclass spanClass //当前哪个Size Class级别的

// list of spans with a free object, ie a nonempty free list
// 还有可用空间的Span 链表
nonempty  mSpanList 

// list of spans with no free objects (or cached in an mcache)
// 没有可用空间的Span链表，或者当前链表里的Span已经交给mcache
empty     mSpanList 

// nmalloc is the cumulative count of objects allocated from
// this mcentral, assuming all spans in mcaches are
// fully-allocated. Written atomically, read under STW.
// nmalloc是从该mcentral分配的对象的累积计数
// 假设mcaches中的所有跨度都已完全分配。
// 以原子方式书写，在STW下阅读。
nmalloc uint64
}
```

```go
//Go V1.16+
//usr/local/go/src/runtime/mcentral.go

//…

type mcentral struct {
// mcentral对应的spanClass
spanclass spanClass

partial  [2]spanSet // 维护全部空闲的Span集合
full     [2]spanSet // 维护存在非空闲的Span集合
}

//…
```

注：分为两个集合元素的数组是为了GC，一个集合是已扫描，一个是未扫描

##### MHeap

Golang 内存管理的 MHeap 依然是继承 TCMalloc 的 PageHeap 设计

**MHeap 是对内存块的管理对象，是通过 Page 为内存单元进行管理,一系列的Page被称为一个HeapArena**

![image.png](https://cdn.nlark.com/yuque/0/2022/png/26269664/1651135097610-8b18c759-6207-435d-80d4-616ce62de8d3.png?x-oss-process=image%2Fwatermark%2Ctype_d3F5LW1pY3JvaGVp%2Csize_52%2Ctext_5YiY5Li55YawQWNlbGQ%3D%2Ccolor_FFFFFF%2Cshadow_50%2Ct_80%2Cg_se%2Cx_10%2Cy_10%2Fresize%2Cw_937%2Climit_0)

一个`HeapArena`占用`64MB`，其中是多个`mspan`，多个连续的基本单位`page`组成一个`mspan`。

所有的`HeapArena`组成的集合是一个`Arena`，即 MHeap 针对堆内存的管理。

所有的 HeapArena 组成的集合是一个 Arenas，也就是 MHeap 针对堆内存的管理。MHeap 是 Golang 进程全局唯一的所以访问依然加锁。图中又出现了 MCentral，因为 MCentral 本也属于 MHeap 中的一部分。只不过会优先从 MCentral 获取内存，如果没有 MCentral 会从 Arenas 中的某个 HeapArena 获取 Page。

![image.png](https://cdn.nlark.com/yuque/0/2022/png/26269664/1651135153113-4db62f09-063b-4470-9fa9-1229150f703c.png?x-oss-process=image%2Fwatermark%2Ctype_d3F5LW1pY3JvaGVp%2Csize_99%2Ctext_5YiY5Li55YawQWNlbGQ%3D%2Ccolor_FFFFFF%2Cshadow_50%2Ct_80%2Cg_se%2Cx_10%2Cy_10%2Fresize%2Cw_1159%2Climit_0)

MHeap 中 HeapArena 占用了绝大部分的空间，其中每个 HeapArean 包含一个 bitmap，其作用是用于标记当前这个 HeapArena 的内存使用情况。其主要是服务于 GC 垃圾回收模块，bitmap 共有两种标记，一个是标记对应地址中是否存在对象，一个是标记此对象是否被 GC 模块标记过，所以当前 HeapArena 中的所有 Page 均会被 bitmap 所标记

从图 3.40 中可以看出，MCentral 实际上就是隶属于 MHeap 的一部分，从数据结构来看，每个 Span Class 对应一个 MCentral，而之前在分析 Golang 内存管理中的逻辑分层中，是将这些 MCentral 集合统一归类为 MCentral 层。

#### Tiny对象分配

| TCMalloc | Golang    |
| -------- | --------- |
| 小对象   | Tiny 对象 |
| 中对象   | 小对象    |
| 大对象   | 大对象    |

在`MCache`中存在一个`Tiny`存储空间。

![image.png](https://cdn.nlark.com/yuque/0/2022/png/26269664/1651135206587-7442cb63-77a7-4b87-8822-db91367db164.png?x-oss-process=image%2Fwatermark%2Ctype_d3F5LW1pY3JvaGVp%2Csize_84%2Ctext_5YiY5Li55YawQWNlbGQ%3D%2Ccolor_FFFFFF%2Cshadow_50%2Ct_80%2Cg_se%2Cx_10%2Cy_10%2Fresize%2Cw_986%2Climit_0)

Tiny空间则是从`Size Class`中获取一个16B的Object，从而减少一些类似`int32、 byte、 bool`所造成的空间浪费。

![image.png](https://cdn.nlark.com/yuque/0/2022/png/26269664/1651135248063-4376ca60-ef0e-4463-a648-e87ffe2d7e51.png?x-oss-process=image%2Fwatermark%2Ctype_d3F5LW1pY3JvaGVp%2Csize_25%2Ctext_5YiY5Li55YawQWNlbGQ%3D%2Ccolor_FFFFFF%2Cshadow_50%2Ct_80%2Cg_se%2Cx_10%2Cy_10)

所以go尽量不使用`Size Class=1`的Span，而是同一将分配空间小于16B的申请归类为`Tiny`对象。

![image.png](https://cdn.nlark.com/yuque/0/2022/png/26269664/1651135299397-38b04b81-3179-44e4-81ca-bb476b69f22f.png?x-oss-process=image%2Fwatermark%2Ctype_d3F5LW1pY3JvaGVp%2Csize_73%2Ctext_5YiY5Li55YawQWNlbGQ%3D%2Ccolor_FFFFFF%2Cshadow_50%2Ct_80%2Cg_se%2Cx_10%2Cy_10%2Fresize%2Cw_937%2Climit_0)

（1）P 向 MCache 申请微小对象如一个 Bool 变量。如果申请的 Object 在 Tiny 对象的大小范围则进入 Tiny 对象申请流程，否则进入小对象或大对象申请流程。

（2）判断申请的 Tiny 对象是否包含指针，如果包含则进入小对象申请流程（不会放在 Tiny 缓冲区，因为需要 GC 走扫描等流程）。

（3）如果 Tiny 空间的 16B 没有多余的存储容量，则从 Size Class = 2（即 Span Class = 4 或 5）的 Span 中获取一个 16B 的 Object 放置 Tiny 缓冲区。

（4）将 1B 的 Bool 类型放置在 16B 的 Tiny 空间中，以字节对齐的方式。

#### 小对象分配

对于对象在(16B~32B)的内存分配，Go会采取小对象分配。

分配小对象的标准流程是按照 Span Class 规格匹配的。在之前介绍 MCache 的内部构造已经介绍了，MCache 一共有 67 份 Size Class 其中 Size Class 为 0 的做了特殊的处理直接返回一个固定的地址。Span Class 为 Size Class 的二倍，也就是从 0 至 133 共 134 个 Span Class。

![image.png](https://cdn.nlark.com/yuque/0/2022/png/26269664/1651135402859-c6404c6a-f0fd-4bb9-bbef-0c5286b0b2a4.png?x-oss-process=image%2Fwatermark%2Ctype_d3F5LW1pY3JvaGVp%2Csize_100%2Ctext_5YiY5Li55YawQWNlbGQ%3D%2Ccolor_FFFFFF%2Cshadow_50%2Ct_80%2Cg_se%2Cx_10%2Cy_10%2Fresize%2Cw_1166%2Climit_0)

（1）首先协程逻辑层 P 向 Golang 内存管理申请一个对象所需的内存空间。

（2）MCache 在接收到请求后，会根据对象所需的内存空间计算出具体的大小 Size。

（3）判断 Size 是否小于 16B，如果小于 16B 则进入 Tiny 微对象申请流程，否则进入小对象申请流程。

（4）根据 Size 匹配对应的 Size Class 内存规格，再根据 Size Class 和该对象是否包含指针，来定位是从 noscan Span Class 还是 scan Span Class 获取空间，没有指针则锁定 noscan。

（5）在定位的 Span Class 中的 Span 取出一个 Object 返回给协程逻辑层 P，P 得到内存空间，流程结束。

（6）如果定位的 Span Class 中的 Span 所有的内存块 Object 都被占用，则 MCache 会向 MCentral 申请一个 Span。

（7）MCentral 收到内存申请后，优先从相对应的 Span Class 中的 NonEmpty Span List（或 Partial Set，Golang V1.16+）里取出 Span（多个 Object 组成），NonEmpty Span List 没有则从 Empty List（或 Full Set Golang V1.16+）中取，返回给 MCache。

（8）MCache 得到 MCentral 返回的 Span，补充到对应的 Span Class 中，之后再次执行第（5）步流程。

（9）如果 Empty Span List（或 Full Set）中没有符合条件的 Span，则 MCentral 会向 MHeap 申请内存。

（10）MHeap 收到内存请求从其中一个 HeapArena 从取出一部分 Pages 返回给 MCentral，当 MHeap 没有足够的内存时，MHeap 会向操作系统申请内存，将申请的内存也保存到HeapArena 中的 mspan 中。MCentral 将从 MHeap 获取的由 Pages 组成的 Span 添加到对应的 Span Class 链表或集合中，作为新的补充，之后再次执行第（7）步。

（11）最后协程业务逻辑层得到该对象申请到的内存，流程结束。

#### 大对象分配流程

小对象是在 MCache 中分配的，而大对象是直接从 MHeap 中分配。对于不满足 MCache 分配范围的对象，均是按照大对象分配流程处理

大对象分配流程是协程逻辑层直接向 MHeap 申请对象所需要的适当 Pages，从而绕过从 MCaceh 到 MCentral 的繁琐申请内存流程。

![image.png](https://cdn.nlark.com/yuque/0/2022/png/26269664/1651135463380-9ee93382-7deb-48c0-ab38-519d679101e4.png?x-oss-process=image%2Fwatermark%2Ctype_d3F5LW1pY3JvaGVp%2Csize_90%2Ctext_5YiY5Li55YawQWNlbGQ%3D%2Ccolor_FFFFFF%2Cshadow_50%2Ct_80%2Cg_se%2Cx_10%2Cy_10%2Fresize%2Cw_1057%2Climit_0)

（1）协程逻辑层申请大对象所需的内存空间，如果超过 32KB，则直接绕过 MCache 和 MCentral 直接向 MHeap 申请。

（2）MHeap 根据对象所需的空间计算得到需要多少个 Page。

（3）MHeap 向 Arenas 中的 HeapArena 申请相对应的 Pages。

（4）如果 Arenas 中没有 HeapA 可提供合适的 Pages 内存，则向操作系统的虚拟内存申请，且填充至 Arenas 中。

（5）MHeap 返回大对象的内存空间。

（6）协程逻辑层 P 得到内存，流程结束。

### Go 栈内存管理

栈区的内存一般由编译器自动分配和释放，其中存储着函数的入参以及局部变量，这些参数会随着函数的创建而创建，函数的返回而消亡，一般不会在程序中长期存在，这种线性的内存分配策略有着极高地效率。

#### 寄存器

寄存器 是CPU中最块的存储单元，栈寄存器是 CPU 寄存器中的一种，它的主要作用是跟踪函数的调用栈。应用程序在获取栈空间时只需要移动栈顶指针，非常高效。

#### 逃逸分析

手动分配可能会出现问题：

1. 不需要分配在堆中的元素分配到堆中：浪费空间，效率低
2. 应该分配在堆上的分配到栈上：悬挂指针，影响内存安全

go语言编译器会自动决定把一个变量放在栈还是放在堆，编译器会做**逃逸分析(escape analysis)**，**当发现变量的作用域没有跑出函数范围，就可以在栈上，反之则必须分配在堆**。（堆中的变量引用了栈上的变量）

> 可以在函数定义时添加 `//go:noinline` 编译指令来阻止编译器内联函数

##### 逃逸规则

一般而言，给**一个引用对象的引用类成员进行赋值**可能出现逃逸现象

Go语言中的引用类型有`func（函数类型），interface（接口类型），slice（切片类型），map（字典类型），channel（管道类型），*（指针类型）`等。

##### 逃逸案例

```go
// 1. slice 为引用类型，interface{} 为引用类型，所以 二次访问 造成后者逃逸
data := []interface{}{1,2}
data[0] = 2
// 2. map 引用类型，interface{} 引用类型，造成后者逃逸
data := make(map[string]interface{})
data["key"] = 200
//3. map 引用类型，interface{} 引用类型, 造成kv逃逸
data := make(map[interface{}]interface{})
data[100] = 200
//4. map 引用, []string 引用，造成后者逃逸
data := make(map[string][]string)
data["key"] = []string{"value"}
//5. [] 引用，*int 引用，后者逃逸
data := []*int{nil}
data[0] = &a // a逃逸
//6. func 引用，*int 引用，导致后者逃逸
data := 10
f := foo
f(&data)
fmt.Println(data) // data逃逸
//7. func 引用，[]string 引用，后者逃逸
s := []string{"aceld"}
foo(s)
fmt.Println(s) // s逃逸
//8. chan 引用，[]string 引用，后者逃逸
ch := make(chan []string)
s := []string{"aceld"}
go func() {
   ch <- s
}()
```

 Golang 中一个函数内局部变量，不管是不是动态 new 出来的，它会被分配在堆还是栈，是由编译器做逃逸分析之后做出的决定。

![image-20220511173652315](https://raja-img.oss-cn-hangzhou.aliyuncs.com/img/image-20220511173652315.png)

#### 栈内存空间

Go 语言使用用户态线程 Goroutine 作为执行上下文，它的额外开销和默认栈大小都比线程小很多，然而 Goroutine 的栈内存空间和栈结构也在早期几个版本中发生过一些变化：

1. v1.0 ~ v1.1 — 最小栈内存空间为 4KB；
2. v1.2 — 将最小栈内存提升到了 8KB；
3. v1.3 — 使用**连续栈** 替换之前版本的分段栈；
4. v1.4 — 将最小栈内存降低到了 2KB；

> 从 4KB 提升到 8KB 是临时的解决方案，其目的是为了减轻分段栈中的栈分裂对程序的性能影响

##### 分段栈

所有Go程在初始化时会分配一块固定内存空间。

当 Goroutine 调用的函数层级或者局部变量需要的越来越多时，运行时会调用 [`runtime.morestack:go1.2`](https://draveness.me/golang/tree/runtime.morestack:go1.2) 和 [`runtime.newstack:go1.2`](https://draveness.me/golang/tree/runtime.newstack:go1.2) 创建一个新的栈空间，这些栈空间虽然不连续，但是当前 Goroutine 的多个栈空间会以链表的形式串联起来，运行时会通过指针找到连续的栈片段：

![segmented-stacks](https://img.draveness.me/2020-03-23-15849514795874-segmented-stacks.png)

一旦申请的栈空间不需要，运行时就会释放。

分段栈机制虽然能够按需为当前 Goroutine 分配内存并且及时减少内存的占用，但是它也存在两个比较大的问题：

1. 如果当前 Goroutine 的栈几乎充满，那么任意的函数调用都会触发栈扩容，当函数返回后又会触发栈的收缩，如果在一个循环中调用函数，栈的分配和释放就会造成巨大的额外开销，这被称为**热分裂问题**（Hot split）；
2. 一旦 Goroutine 使用的内存**越过**了分段栈的扩缩容阈值，运行时会触发栈的扩容和缩容，带来额外的工作量；

##### 连续栈

其核心原理是每当程序的栈空间不足时，初始化一片更大的栈空间并将原栈中的所有值都迁移到新栈中，新的局部变量或者函数调用就有充足的内存空间。

扩容操作：

1. 在内存空间中分配更大的栈内存空间；

2. 将旧栈中的所有内容复制到新栈中；

3. **将指向旧栈对应变量的指针重新指向新栈**；

   **指向栈对象的指针不能存在于堆中**，所以指向栈中变量的指针只能在栈上，我们只需要调整栈中的所有变量就可以保证内存的安全了。

4. 销毁并回收旧栈的内存空间；

因为需要拷贝变量和调整指针，连续栈增加了栈扩容时的额外开销，但是通过合理栈缩容机制就能避免热分裂带来的性能问题，在 GC 期间如果 Goroutine 使用了栈内存的四分之一，那就将其内存减少一半，这样在栈内存几乎充满时也只会扩容一次，不会因为函数调用频繁扩缩容。

### Go GC

> <a href="https://github.com/aceld/golang/blob/main/5、Golang三色标记+混合写屏障GC模式全分析.md">刘丹冰yyds</a> <a href="https://draveness.me/golang/docs/part3-runtime/ch07-memory/golang-garbage-collector/">Draven也是</a>

垃圾回收(Garbage Collection，简称GC)是编程语言中提供的自动的内存管理机制，自动释放不需要的对象，让出存储器资源，无需程序员手动执行。

Golang中的垃圾回收主要应用三色标记法，GC过程和其他用户goroutine可并发运行，但需要一定时间的**STW(stop the world)**，STW的过程中，CPU不执行用户代码，全部用于垃圾回收，这个过程的影响很大，Golang进行了多次的迭代优化来解决这个问题。

#### GC回收的是什么？

在应用程序中会使用到两种内存，分别为堆（Heap）和栈（Stack），GC负责回收堆内存，而不负责回收栈中的内存。

主要原因是栈是一块专用内存，专门为了函数执行而准备的，存储着函数中的局部变量以及调用栈。除此以外，栈中的数据都有一个特点—简单。比如局部变量不能被函数外访问，所以这块内存用完就可以直接释放。

#### GC算法的种类

主流的垃圾回收算法有两大类，分别是**追踪式垃圾回收算法**和**引用计数法**。而Go语言现在用的三色标记法就属于追踪式垃圾回收算法的一种。

#### Go垃圾回收算法

Go的垃圾收集器从一开始到现在一直在演进，在v1.5版本开始三色标记法作为垃圾回收算法前使用**Mark-And-Sweep**（标记清除）算法。从v1.5版本Go实现了基于**三色标记清除的并发**垃圾收集器，大幅度降低垃圾收集的延迟从几百 ms 降低至 10ms 以下。在v1.8又使用**混合写屏障**将垃圾收集的时间缩短至 0.5ms 以内。

#### GC触发时机

1. 内存达到上限或内存扩大一倍
2. 定期删除
3. 手动触发

#### Go1.3 标记-清除

##### 标记：从根对象出发查找并标记堆中存活的对象。

1. 暂停程序，分类出可达和不可达的对象，然后做标记

2. 程序找出左右可达的对象并做标记。

   ![img](https://github.com/aceld/golang/raw/main/images/42-GC2.png)

##### 清除：遍历堆中所有未标记的对象，回收未被标记的垃圾对象的内存。

##### 缺点

1. 全程STW，程序卡顿
2. 标记需要扫描整个堆
3. 清除数据会产生碎片

流程：

![img](https://github.com/aceld/golang/raw/main/images/54-STW2.png)

#### Go1.5 三色并发标记法

##### 三色？

1. 白色：新创建的对象默认为白色（未被扫描）
2. 灰色：活跃对象，引用的其他对象会被扫描（活跃对象，存在外部引用节点）
3. 黑色：活跃对象，本轮扫描中不会被清除（活跃对象）

##### 普通三色并发标记流程

1. GC开始时会从根节点遍历所有对象，标记为灰色
2. 按顺序遍历灰色节点，将其引用的白色节点标记为灰色，最后此灰色节点标记为黑色
3. 重复步骤2,直到没有灰色节点，清除所有白色节点

因为此过程可能会改变指针的引用，导致内存安全性问题所以需要STW。

**灰断开白且黑指向白**：导致被引用对象被清除（这个白色如果有下游，也会被清除）

##### 三色不变性

想让并发或者增量算法中保证正确性，需要满足**两种三色不变性中的一种**

1. **强三色不变性**：**黑不能指向白**

   ![img](https://github.com/aceld/golang/raw/main/images/60-%E4%B8%89%E8%89%B2%E6%A0%87%E8%AE%B0%E9%97%AE%E9%A2%986.jpeg)

2. **弱三色不变性**

   **黑指向的白必须被灰间接或直接引用**

   ![img](https://github.com/aceld/golang/raw/main/images/61-%E4%B8%89%E8%89%B2%E6%A0%87%E8%AE%B0%E9%97%AE%E9%A2%987.jpeg)

##### 内存屏障

**内存屏障：让CPU或编译器在执行内存相关操作时可以遵循特定约束，使其指令可以顺序化执行。**

垃圾回收机制中的屏障技术类似于一个钩子函数，在用户创建，读取，更新对象指针时执行的一段代码，根据类型不同，分为**读屏障和写屏障**。

##### 插入写屏障：满足强三色不变性(黑到白连接)

在更新和新增节点时，**被引用的白色对象会被标记为灰色。**

**但是因为栈空间容量小，速度快。不可以频繁进行函数调用，所以插入写只在堆中使用。**

##### 删除写屏障：满足弱三色不变性(灰到白断开)

**被删除的对象，如果自身为白色，那么被标记为灰色。**

可以在栈中使用。

![img](https://github.com/aceld/golang/raw/main/images/74-%E4%B8%89%E8%89%B2%E6%A0%87%E8%AE%B0%E5%88%A0%E9%99%A4%E5%86%99%E5%B1%8F%E9%9A%9C3.jpeg)

![img](https://github.com/aceld/golang/raw/main/images/75-%E4%B8%89%E8%89%B2%E6%A0%87%E8%AE%B0%E5%88%A0%E9%99%A4%E5%86%99%E5%B1%8F%E9%9A%9C4.jpeg)

但是这样会导致一个节点即使被删除了最后一个指向它的指针也可以活过这一轮GC。

**所以整个流程就是全部节点并发三色标记一遍，堆空间增加写屏障，然后栈空间STW重新标记一遍，最后清除白色节点。**

##### 缺点

插入写屏障和删除写屏障的短板：

- 插入写屏障：**结束时需要STW来重新扫描栈，标记栈上引用的白色对象的存活；**
- 删除写屏障：**回收精度低，一个对象即使被删除了最后一个指向它的指针也依旧可以活过这一轮，在下一轮GC中被清理掉。**

#### Go1.8 混合写屏障

Go V1.8版本引入了混合写屏障机制，避免了对栈`re-scan`的过程，极大的减少了STW的时间。结合了插入写和删除写的优点。

##### 规则

1、GC开始将栈上的可达对象标记为黑色(之后不再进行第二次重复扫描，无需STW)，

2、GC期间，任何在栈上创建的新对象，均为黑色。

3、删除写：被删除的对象标记为灰色。

4、插入写：被添加的对象标记为灰色。

##### 流程

>  注意混合写屏障是GC的一种屏障机制，所以只是当程序执行GC的时候，才会触发这种机制。
>
>  屏障技术是不在栈上应用的，因为要保证栈的运行效率

GC开始，扫描栈，将所有可达对象标记为黑。

1. 对象被一个堆对象删除引用，成为栈对象的下游（灰色删除，黑色添加）

   触发删除写，标记白色对象为灰

2. 对象被一个栈对象删除引用，成为另一个栈对象的下游（栈空间无屏障）

   反正也是黑色节点，无影响

3. 对象被一个堆对象删除引用，成为另一个堆对象的下游（灰色删除，黑色添加）

   触发屏障，标记白色对象为灰

4. 对象从一个栈对象删除引用，成为另一个堆对象的下游（灰色断开）

   触发删除写屏障，白色对象标记为灰

##### 总结

GoV1.3- 普通标记清除法，整体过程需要启动STW，效率极低。

GoV1.5- 三色标记法， 堆空间启动写屏障，栈空间不启动，全部扫描之后，需要重新扫描一次栈(需要STW)，效率普通

GoV1.8-三色标记法，混合写屏障机制， 栈空间不启动，堆空间启动。整个过程几乎不需要STW，效率较高。

![image-20221006163538246](https://raja-img.oss-cn-hangzhou.aliyuncs.com/img/image-20221006163538246.png)

### 自动内存管理

1. 动态内存：程序在运行时根据需求动态分配内存
2. 垃圾回收：由程序语言运行时系统回收动态内存
   1. 避免手动内存管理
   2. 保证内存使用的安全性和正确性
3. 三个任务：
   1. 为新对象分配空间
   2. 回收没有被使用的对象

#### 相关概念

![image-20220511162828286](https://raja-img.oss-cn-hangzhou.aliyuncs.com/img/image-20220511162828286.png)

![image-20220511162853126](https://raja-img.oss-cn-hangzhou.aliyuncs.com/img/image-20220511162853126.png)



#### 追踪垃圾回收

![image-20220511163349572](https://raja-img.oss-cn-hangzhou.aliyuncs.com/img/image-20220511163349572.png)

![image-20220511163419020](https://raja-img.oss-cn-hangzhou.aliyuncs.com/img/image-20220511163419020.png)



![image-20220511163452918](https://raja-img.oss-cn-hangzhou.aliyuncs.com/img/image-20220511163452918.png)

#### 分代GC

![image-20220511163709195](https://raja-img.oss-cn-hangzhou.aliyuncs.com/img/image-20220511163709195.png)

#### 引用计数

![image-20220511164140642](https://raja-img.oss-cn-hangzhou.aliyuncs.com/img/image-20220511164140642.png)

### Go内存管理和优化

#### 分块

![image-20220511164915292](https://raja-img.oss-cn-hangzhou.aliyuncs.com/img/image-20220511164915292.png)

#### 缓存

![image-20220511164945381](https://raja-img.oss-cn-hangzhou.aliyuncs.com/img/image-20220511164945381.png)

#### 优化

小对象分配过多，分配路径过长

![image-20220511165403488](https://raja-img.oss-cn-hangzhou.aliyuncs.com/img/image-20220511165403488.png)

![image-20220511165926961](https://raja-img.oss-cn-hangzhou.aliyuncs.com/img/image-20220511165926961.png)

## 元编程

### 插件系统

#### 设计原理

Go 语言的插件系统基于 C 语言动态库实现的，所以它也继承了 C 语言动态库的优点和缺点。

- 静态库或者静态链接库是由编译期决定的程序、外部函数和变量构成的，编译器或者链接器会将程序和变量等内容拷贝到目标的应用并生成一个独立的可执行对象文件；
  - 可以独立运行，但是二进制文件较大
- 动态库或者共享对象可以在多个可执行文件之间共享，程序使用的模块会在运行时从共享对象中加载，而不是在编译程序时打包成独立的可执行文件；
  - 可以在多个可执行文件之间共享，减少内存占用，一般在运行期间装载。

##### 插件系统

通过在主程序和共享库直接定义一系列的约定或者接口，我们可以通过以下的代码动态加载其他人编译的 Go 语言共享对象，这样做的好处是主程序和共享库的开发者不需要共享代码，只要双方的约定不变，修改共享库后也不需要重新编译主程序。

```go
type Driver interface {
    Name() string
}

func main() {
    p, err := plugin.Open("driver.so")
    if err != nil {
	   panic(err)
    }

    newDriverSymbol, err := p.Lookup("NewDriver")
    if err != nil {
        panic(err)
    }
	// 寻找任何可以导出的变量或函数
    newDriverFunc := newDriverSymbol.(func() Driver)
    newDriver := newDriverFunc()
    fmt.Println(newDriver.Name())
}
```

定义一个接口，并且动态库实现了它，当我们通过 [`plugin.Open`](https://draveness.me/golang/tree/plugin.Open) 读取包含 Go 语言插件的共享库后，获取文件中的 `NewDriver` 符号并转换成正确的函数类型，可以通过该函数初始化新的 `Driver` 并获取它的名字了。

##### 操组系统

Linux 中的共享对象会使用 ELF 格式 [3](https://draveness.me/golang/docs/part4-advanced/ch08-metaprogramming/golang-plugin/#fn:3) 并提供了一组操作动态链接器的接口

```c
void *dlopen(const char *filename, int flag);
char *dlerror(void);
void *dlsym(void *handle, const char *symbol);
int dlclose(void *handle);
```

`dlopen` 会根据传入的文件名加载对应的动态库并返回一个句柄（Handle）；我们可以直接使用 `dlsym` 函数在该句柄中搜索特定的符号，也就是函数或者变量，它会返回该符号被加载到内存中的地址。因为待查找的符号可能不存在于目标动态库中，所以在每次查找后我们都应该调用 `dlerror` 查看当前查找的结果。

#### 

Go 语言插件系统的全部实现都包含在 [`plugin`](https://pkg.go.dev/plugin) 中，这个包实现了符号系统的加载和决议。插件是一个带有公开函数和变量的包，我们需要使用下面的命令编译插件：

```bash
go build -buildmode=plugin ...
```

该命令会生成一个共享对象 `.so` 文件，当该文件被加载到 Go 语言程序时会使用下面的结构体 [`plugin.Plugin`](https://draveness.me/golang/tree/plugin.Plugin) 表示，该结构体中包含文件的路径以及包含的符号等信息：

```go
type Plugin struct {
	pluginpath string // 插件路径
	syms       map[string]interface{} // 符号信息
	...
}
```

与插件系统相关的两个核心方法分别是用于加载共享文件的 [`plugin.Open`](https://draveness.me/golang/tree/plugin.Open) 和在插件中查找符号的 [`plugin.Plugin.Lookup`](https://draveness.me/golang/tree/plugin.Plugin.Lookup)

##### CGO

包中使用的两个 C 语言函数 [`plugin.pluginOpen`](https://draveness.me/golang/tree/plugin.pluginOpen) 和 [`plugin.pluginLookup`](https://draveness.me/golang/tree/plugin.pluginLookup)；

[`plugin.pluginOpen`](https://draveness.me/golang/tree/plugin.pluginOpen) 只是简单包装了一下标准库中的 `dlopen` 和 `dlerror` 函数并在加载成功后返回指向动态库的句柄：

```c
static uintptr_t pluginOpen(const char* path, char** err) {
	void* h = dlopen(path, RTLD_NOW|RTLD_GLOBAL);
	if (h == NULL) {
		*err = (char*)dlerror();
	}
	return (uintptr_t)h;
}
```

[`plugin.pluginLookup`](https://draveness.me/golang/tree/plugin.pluginLookup) 使用了标准库中的 `dlsym` 和 `dlerror` 获取动态库句柄中的特定符号：

```c
static void* pluginLookup(uintptr_t h, const char* name, char** err) {
	void* r = dlsym((void*)h, name);
	if (r == NULL) {
		*err = (char*)dlerror();
	}
	return r;
}
```

##### 加载过程

用于加载共享对象的函数 [`plugin.Open`](https://draveness.me/golang/tree/plugin.Open) 会将共享对象文件的路径作为参数并返回 [`plugin.Plugin`](https://draveness.me/golang/tree/plugin.Plugin) 结构

```go
func Open(path string) (*Plugin, error) {
	return open(path)
}
```

上述函数会调用私有的函数 [`plugin.open`](https://draveness.me/golang/tree/plugin.open) 加载插件，它是插件加载过程的核心函数，我们可以将该函数拆分成以下几个步骤：

1. 准备 C 语言函数 [`plugin.pluginOpen`](https://draveness.me/golang/tree/plugin.pluginOpen) 的参数；
2. 通过 cgo 调用 [`plugin.pluginOpen`](https://draveness.me/golang/tree/plugin.pluginOpen) 并初始化加载的模块；
3. 查找加载模块中的 `init` 函数并调用该函数；
4. 通过插件的文件名和符号列表构建 [`plugin.Plugin`](https://draveness.me/golang/tree/plugin.Plugin) 结构；

> <a href="https://draveness.me/golang/docs/part4-advanced/ch08-metaprogramming/golang-plugin/">推荐阅读</a>

### 代码生成

元编程：使用代码生成代码

Go 语言的代码生成机制会读取包含预编译指令的注释，然后执行注释中的命令读取包中的文件，然后生成新的go代码文件，最后一起编译运行

```go
//go:generate command argument...
```

`go generate` 不会被 `go build` 等命令自动执行，该命令需要显式的触发，手动执行该命令时会在文件中扫描上述形式的注释并执行后面的执行命令，需要注意的是 `go:generate` 和前面的 `//` 之间没有空格，这种不包含空格的注释一般是 Go 语言的编译器指令，**而我们在代码中的正常注释都应该保留这个空格。**

代码生成最常见的例子就是官方提供的 `stringer`，这个工具可以扫描如下所示的常量定义，然后为当前常量类型 `Piller` 生成对应的 `String()` 方法：

```go
package painkiller

//go:generate stringer -type=Pill
type Pill int

const (
	Placebo Pill = iota
	Aspirin
	Ibuprofen
	Paracetamol
	Acetaminophen = Paracetamol
)
// 元编程: 为以上类型生成String()
```

然后执行`go generate`会自动生成`pill_string.go`文件

代码生成的过程可以分成以下两个部分：

1. 扫描 Go 语言源文件，查找待执行的 `//go:generate` 预编译指令；
2. 执行预编译指令，再次扫描源文件并根据源文件中的代码生成代码；

## 包管理

### Go Modules

Go modules 是 Go 语言的依赖解决方案，发布于 Go1.11，成长于 Go1.12，丰富于 Go1.13，正式于 Go1.14 推荐在生产上使用。

Go moudles 目前集成在 Go 的工具链中，只要安装了 Go，自然而然也就可以使用 Go moudles 了，而 Go modules 的出现也解决了在 Go1.11 前的几个常见争议问题：

1. Go 语言长久以来的依赖管理问题。
2. “淘汰”现有的 GOPATH 的使用模式。
3. 统一社区中的其它的依赖管理工具（提供迁移功能）。

### GOPATH 模式

```go
// GOPATH下
go
├── bin // 存储所编译生成的二进制文件。
├── pkg // 存储预编译的目标文件，以加快程序的后续编译速度。
└── src // 存储所有.go文件或源代码
    ├── github.com
    ├── golang.org
    ├── google.golang.org
    ├── gopkg.in
    ....
```

- **A. 无版本控制概念.** 在执行`go get`的时候，你无法传达任何的版本信息的期望，也就是说你也无法知道自己当前更新的是哪一个版本，也无法通过指定来拉取自己所期望的具体版本。

- **B.无法同步一致第三方版本号.** 在运行 Go 应用程序的时候，你无法保证其它人与你所期望依赖的第三方库是相同的版本，也就是说在项目依赖库的管理上，你无法保证所有人的依赖版本都一致。
- **C.无法指定当前项目引用的第三方版本号. ** 你没办法处理 v1、v2、v3 等等不同版本的引用问题，因为 GOPATH 模式下的导入路径都是一样的，都是`github.com/foo/bar`。

### Go Modules 模式

#### go mod命令

| 命令            | 作用                             |
| --------------- | -------------------------------- |
| go mod init     | 生成 go.mod 文件                 |
| go mod download | 下载 go.mod 文件中指明的所有依赖 |
| go mod tidy     | 整理现有的依赖                   |
| go mod graph    | 查看现有的依赖结构               |
| go mod edit     | 编辑 go.mod 文件                 |
| go mod vendor   | 导出项目所有的依赖到vendor目录   |
| go mod verify   | 校验一个模块是否被篡改过         |
| go mod why      | 查看为什么需要依赖某模块         |

#### go mod环境变量

```bash
$ go env
GO111MODULE="auto"
GOPROXY="https://proxy.golang.org,direct"
GONOPROXY=""
GOSUMDB="sum.golang.org"
GONOSUMDB=""
GOPRIVATE=""
```

##### GO111MODULE

Go语言提供了 `GO111MODULE `这个环境变量来作为 Go modules 的开关，其允许设置以下参数：

- auto：只要项目包含了 go.mod 文件的话启用 Go modules，目前在 Go1.11 至 Go1.14 中仍然是默认值。
- on：启用 Go modules，推荐设置，将会是未来版本中的默认值。
- off：禁用 Go modules，不推荐设置。

设置：`go env -w GO111MODULE=on`

##### GOPROXY

这个环境变量主要是用于设置 Go 模块代理（Go module proxy）,其作用是用于使 Go 在后续拉取模块版本时直接通过镜像站点来快速拉取。

GOPROXY 的默认值是：`https://proxy.golang.org,direct`

`proxy.golang.org`国内访问不了,需要设置国内的代理.

- 阿里云

  https://mirrors.aliyun.com/goproxy/

- 七牛云

  [https://goproxy.cn,direct](https://goproxy.cn/direct/)

如:

```bash
$ go env -w GOPROXY=https://goproxy.cn,direct
```

GOPROXY 的值是一个以英文逗号 `,` 分割的 Go 模块代理列表，允许设置多个模块代理，假设你不想使用，也可以将其设置为 “off” ，这将会禁止 Go 在后续操作中使用任何 Go 模块代理。

> 而在刚刚设置的值中，我们可以发现值列表中有 “direct” 标识，它又有什么作用呢？

实际上 “direct” 是一个特殊指示符，用于指示 Go 回源到模块版本的源地址去抓取（比如 GitHub 等），场景如下：当值列表中上一个 Go 模块代理返回 404 或 410 错误时，Go 自动尝试列表中的下一个，遇见 “direct” 时回源，也就是回到源地址去抓取，而遇见 EOF 时终止并抛出类似 “invalid version: unknown revision...” 的错误。

##### GOSUMDB

它的值是一个 Go checksum database，用于在拉取模块版本时（无论是从源站拉取还是通过 Go module proxy 拉取）保证拉取到的模块版本数据未经过篡改，若发现不一致，也就是可能存在篡改，将会立即中止。

GOSUMDB 的默认值为：`sum.golang.org`，在国内也是无法访问的，但是 GOSUMDB 可以被 Go 模块代理所代理（详见：Proxying a Checksum Database）。

因此我们可以通过设置 GOPROXY 来解决，而先前我们所设置的模块代理 `goproxy.cn` 就能支持代理 `sum.golang.org`，所以这一个问题在设置 GOPROXY 后，你可以不需要过度关心。

另外若对 GOSUMDB 的值有自定义需求，其支持如下格式：

- 格式 1：`<SUMDB_NAME>+<PUBLIC_KEY>`。
- 格式 2：`<SUMDB_NAME>+<PUBLIC_KEY> <SUMDB_URL>`。

也可以将其设置为“off”，也就是禁止 Go 在后续操作中校验模块版本。

##### GONOPROXY/GONOSUMDB/GOPRIVATE

这三个环境变量都是用在当前项目依赖了私有模块，例如像是你公司的私有 git 仓库，又或是 github 中的私有库，都是属于私有模块，都是要进行设置的，否则会拉取失败。

更细致来讲，就是依赖了由 GOPROXY 指定的 Go 模块代理或由 GOSUMDB 指定 Go checksum database 都无法访问到的模块时的场景。

而一般**建议直接设置 GOPRIVATE，它的值将作为 GONOPROXY 和 GONOSUMDB 的默认值，所以建议的最佳姿势是直接使用 GOPRIVATE**。

并且它们的值都是一个以英文逗号 “,” 分割的模块路径前缀，也就是可以设置多个，例如：

```bash
$ go env -w GOPRIVATE="git.example.com,github.com/eddycjy/mquote"设置后，前缀为 git.xxx.com 和 github.com/eddycjy/mquote 的模块都会被认为是私有模块。
```

如果不想每次都重新设置，我们也可以利用通配符，例如：

```bash
$ go env -w GOPRIVATE="*.example.com"
```

这样子设置的话，所有模块路径为 example.com 的子域名（例如：git.example.com）都将不经过 Go module proxy 和 Go checksum database，**需要注意的是不包括 example.com 本身**。

#### 初始化项目

1. 开启go mod

   ```bash
    $ go env -w GO111MODULE=on
   ```

   又或是可以通过直接设置系统环境变量（写入对应的~/.bash_profile 文件亦可）来实现这个目的：

   ```bash
   $ export GO111MODULE=on
   ```

2. 初始化项目

   ```bash
   go mod init 项目仓库地址
   ```

   之后创建`main.go`

   ```go
   package main
   
   import (
       "fmt"
       "github.com/aceld/zinx/znet"
       "github.com/aceld/zinx/ziface"
   )
   
   func main(){
       ...
   }
   ```

   然后`go get github.com/aceld/zinx/znet`拉取依赖

   项目目录下`go.mod`被修改，出现`go.sum`

3. go.mod

   ```go
   module github.com/aceld/modules_test // 项目基本路径 如果你的版本已经大于等于2.0.0，按照Go的规范，你应该加上major的后缀(例：module github.com/panicthis/modfile/v2)
   
   go 1.14 // 标识最低支持go版本
   
   require github.com/aceld/zinx v0.0.0-20200221135252-8a8954e75100 // indirect 间接依赖
   ```

   ```go
   // 语义化版本
   // {MAJOR}.{MINOR}.{PATCH}
   // {不兼容更新}.{新增功能}.{bug修复}
   ```

   ```go
   // indirect 间接依赖
   // 当前项目依赖A,但是A的go.mod遗漏了B, 那么就会在当前项目的go.mod中补充B, 加indirect注释
   // 当前项目依赖A,但是A没有go.mod,同样就会在当前项目的go.mod中补充B, 加indirect注释
   // 当前项目依赖A,A又依赖B,当对A降级的时候，降级的A不再依赖B,这个时候B就标记indirect注释
   ```

   ```go
   // +incompatible 兼容一些没用mod管理的包或者版本>=2.0.0却没有加后缀的包
   ```

4. go.sum

   其详细罗列了当前项目直接或间接依赖的所有模块版本，并写明了那些模块版本的 SHA-256 哈希值以备 Go 在今后的操作中保证项目所依赖的那些模块版本不会被篡改。

#### 最小版本控制MVS

<a href="https://learnku.com/docs/go-mod/1.17/minimal-version-selection/11441">原文</a>

MVS 在模块的有向图上运行，由 go.mod 文件 指定。 图中的每个顶点代表一个模块版本。 每条边代表依赖项的最低要求版本，使用 require 指令指定。 在主模块的 go.mod 文件中，使用 replace 和 exclude 指令修改图形。

MVS 从主模块开始（图中没有版本的特殊顶点），并遍历图，跟踪每个模块所需的最高版本。在遍历结束时，所需的最高版本构成构建列表：它们是满足所有要求的最低版本。

考虑下图中的示例。主模块需要模块 A 和 模块 B 最低 1.2 版本，A 1.2 和 B 1.2 分别依赖 C 1.3 和 C 1.4， C 1.3 和 C 1.4 都依赖 D 1.2。

![图片](https://cdn.learnku.com/uploads/images/202110/21/1/iBnQP2Wokm.png!large)

MVS 访问并加载所有标蓝版本模块的 go.mod 文件。在图上遍历结束时，MVS 返回一个包含粗体版本的构建列表：A 1.2、B 1.2、C 1.4 和 D 1.2。请注意，可以使用更高版本的 B 和 D，但 MVS 不会选择它们，因为不需要它们。

##### 替换

主模块的 `go.mod` 文件中，可以使用 [`replace` 指令](https://golang.org/ref/mod#go-mod-file-replace) 来替换模块内容（包括其 `go.mod` 文件）。 `replace` 指令可能适用于模块的指定版本或所有版本。

考虑下面的示例，其中 C 1.4 已被 R 替换。R 取决于 D 1.3 而不是 D 1.2，因此 MVS 返回包含 A 1.2、B 1.2、C 1.4（替换为 R）和 D 1.3 的构建列表

![替换的模块版本图](https://cdn.learnku.com/uploads/images/202110/21/1/XjW765LWcY.svg)

##### Exclusion

在主模块的 `go.mod` 文件中，也可以使用 [`exclude` 指令](https://golang.org/ref/mod#go-mod-file-exclude) 在特定版本中排除一个模块。

请看下面的例子。C 1.3 已经被排除。MVS 会像 A 1.2 要求 C 1.4（下一个更高版本）而不是 C 1.3 一样行事。

![图片](https://cdn.learnku.com/uploads/images/202110/21/1/oaBu7jjTri.png!large)

##### 升级

[`go get`](https://golang.org/ref/mod#go-get) 命令可以用来升级一组模块。为了执行升级，`go` 命令在运行 MVS 之前改变了模块图，增加了从访问的版本到升级后的版本。

看下面的例子。模块 B 可以从 1.2 升级到 1.3，C 可以从 1.3 升级到 1.4 ，D 可以从 1.2 升级到 1.3。

![Module version graph with upgrades](https://cdn.learnku.com/uploads/images/202110/21/1/Mibr7iz5LP.svg)

升级（和降级）可以增加或删除间接的依赖关系。在这种情况下，E 1.1 和 F 1.1 在升级后出现在构建列表中，因为 E 1.1 是 B 1.3 所需要的。

为了保持升级，`go` 命令更新 `go.mod` 中的需求。它将改变 B 的需求为 1.3 版本。它还将增加对 C 1.4 和 D 1.3 的需求，并加上 `//间接`注释，因为这些版本不会被选中。

##### 降级

[`go get`](https://golang.org/ref/mod#go-get)命令也可以用来降低一组模块的等级。为了执行降级，`go` 命令通过移除降级后的版本来改变模块图。它也会移除依赖于被移除版本的其他模块的版本，因为它们可能与降级后的依赖版本不兼容。如果主模块需要一个被降级移除的模块版本，该需求将被改变为未被移除的先前版本。如果没有以前的版本，需求将被放弃。

![降级的模块版本图](https://cdn.learnku.com/uploads/images/202110/21/1/fVO1TJb3Xz.svg)

[`go get`](https://golang.org/ref/mod#go-get) 也可以完全删除依赖项，在参数后使用 `@none` 后缀。 这种类似于降级。 命名模块的所有版本都从模块图中删除。

#### go get 指令

<a href="https://www.lsdcloud.com/go/middleware/go-get.html#go-get">原文</a>

下载导入路径指定的包及其依赖项，然后安装命名包，即执行 go install 命令。 用法如下：

### go get

```bash
go get [-d] [-f] [-t] [-u] [-fix] [-insecure] [build flags] [packages]
```

|   参数    | 描述                                                                                                                                                                    |
| :-------: | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
|    -d     | 让命令程序只执行下载动作，而不执行安装动作。                                                                                                                            |
|    -f     | 仅在使用 - u 标记时才有效。该标记会让命令程序忽略掉对已下载代码包的导入路径的检查。如果下载并安装的代码包所属的项目是你从别人那里 Fork 过来的，那么这样做就尤为重要了。 |
|   -fix    | 让命令程序在下载代码包后先执行修正动作，而后再进行编译和安装。                                                                                                          |
| -insecure | 允许命令程序使用非安全的 scheme（如 HTTP）去下载指定的代码包。如果你用的代码仓库（如公司内部的 Gitlab）没有 HTTPS 支持，可以添加此标记。请在确定安全的情况下使用它。    |
|    -t     | 让命令程序同时下载并安装指定的代码包中的测试源码文件中依赖的代码包。                                                                                                    |
|    -u     | 让命令利用网络来更新已有代码包及其依赖包。默认情况下，该命令只会从网络上下载本地不存在的代码包，而不会更新已有的代码包。                                                |
|    -v     | 打印出被构建的代码包的名字                                                                                                                                              |
|    -x     | 打印出用到的命令                                                                                                                                                        |

### go install

> go build 命令比较相似，go build 命令会编译包及其依赖，生成的文件存放在当前目录下。而且 go build 只对 main 包有效，其他包不起作用。而 go install 对于非 main 包会生成静态文件放在 $GOPATH/pkg 目录下，文件扩展名为 a。 如果为 main 包，则会在 $GOPATH/bin 下生成一个和给定包名相同的可执行二进制文件。具体语法如下:

```bash
go install [-i] [build flags] [packages]
```

## 拓展

### Go 初始化顺序

> [init 初始化](https://zhuanlan.zhihu.com/p/34211611 )，[变量初始化](https://studygolang.com/articles/13158)

1. go 初始化顺序 包作用域变量->init()->main()
2. runtime 需要解析包依赖关系，没有依赖的包最先初始化，没有依赖的变量先初始化
3. 一个包内的init()根据文件名字典序初始化
4. 不同包根据依赖关系来加载包，先初始化包变量，再初始化包内init()

```go
// a.go of pack
package pack

import (
	"fmt"
)

var _ = func() int {
	fmt.Println("init var in a.go of pack")
	return 0
}()

func init() {
	fmt.Println("init in a.go of pack")
}
```

```go
// pack.go of pack
package pack

import (
	"fmt"

	"test"
)

var Pack string = "pack.Val"

var _ = func() int {
	fmt.Println("init var in pack.go of pack")
	return 1
}()

func init() {
	fmt.Println("init in pack.go of pack:", test.Util)
}
```

```go
// test.go of test
import (
	"fmt"
)

var Util string = "test.Val"

var _ = func() int {
	fmt.Println("init var in test.go of test")
	return 1
}()

func init() {
	fmt.Println("init test.go of test")
}

```

```go
// main.go
package main

import (
	"fmt"

	"pack"
	"test"
)

// main -> pack -> test
// 由于 pack 包的初始化依赖 test，因此运行时先初始化 test 再初始化 pack 包；
func main() {
	fmt.Println(pack.Pack)
	fmt.Println(test.Util)
}
```

结果：

```shell
init var in test.go of test # test var
init test.go of test # test init()
init var in a.go of pack # pack var1
init var in pack.go of pack # pack var2
init in a.go of pack # pack init()
init in pack.go of pack: test.Val # pack init()
pack.Val # main
test.Val
```

### fmt 占位符

```go
func main() {
	var n = 100
	fmt.Printf("%T\n", n) // 类型
	fmt.Printf("%v\n", n) // 相应值的默认格式
	fmt.Printf("%b\n", n) // 二进制表示
	fmt.Printf("%d\n", n) // 十进制表示
	fmt.Printf("%o\n", n) // 八进制表示
	fmt.Printf("%x\n", n) // 十六进制表示，字母形式为小写 a-f
	var s = "Hello,你好！"
	fmt.Printf("%s\n", s)  // 输出字符串表示（string类型或[]byte)
	fmt.Printf("%v\n", s)  // 相应值的默认格式。
	fmt.Printf("%#v\n", s) // %#v 输出字符串具体描述，相应值的Go语法表示
	fmt.Printf("%#v\n", n)
	/*
		但是，紧跟在verb之前的[n]符号表示应格式化第n个参数（索引从1开始）。同样的在'*'之前的[n]符号表示采用第n个参数的值作为宽度或精度。在处理完方括号表达式[n]后，除非另有指示，会接着处理参数n+1，n+2……（就是说移动了当前处理位置）
	*/
	fmt.Printf("%[2]d %[1]d", 11, 2)
	fmt.Printf("%[3]*.[2]*[1]d", 12, 2, 6)
	fmt.Printf("%6.2d", 12)
}
```