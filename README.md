<!--
 * @Author: Raja
 * @Description: README.md
 * @Date: 2023-01-14 00:21:05
 * @LastEditTime: 2023-01-14 00:22:08
 * @FilePath: /raja-blog/README.md
-->

**一个简单的博客网站,用于记录自己的点点滴滴**

# 安装主题(子模块)
`git submodule update --init --recursive `

# 友情链接使用方法:

>
>```css
><div class="flink" id="article-container">
><div class="friend-list-div" >
>
>{{< friend name="{友链名}" url="{友链地址}" logo="{友链图标链接}" word="{友链描述}" >}}
>{{< friend name="{友链名}" url="{友链地址}" logo="{友链图标链接}" word="{友链描述}" >}}
>...
>
></div>
></div>
>```