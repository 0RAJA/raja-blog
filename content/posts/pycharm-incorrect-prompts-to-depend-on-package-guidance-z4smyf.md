
# pycharm 不正确提示依赖包导入项

# 问题

使用 pycharm 开发时，填入一个依赖的名称时正常 IDE 会提示从哪里导入，例如：

​![image](https://raw.githubusercontent.com/0RAJA/img/main/20241013140406.png)​

但突然发现新项目中 IDE 不会提醒可选的依赖，例如：

​![image](https://raw.githubusercontent.com/0RAJA/img/main/20241013134814.png)​

# 解决方案

将当前项目的 python 虚拟环境标记为 `已排除` ​即可

​![image](https://raw.githubusercontent.com/0RAJA/img/main/20241013135457.png)​
