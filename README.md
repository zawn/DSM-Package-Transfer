# DSM7 套件迁移脚本

#### 介绍
用于在Synology DSM7 中将套件迁移到不同的存储空间。

#### 测试平台
所有功能在DS3615xs DSM 7.1.1-42962 Update 2中测试通过。


#### 原理

1.  所有套件均安装在/var/packages目录，进入相应套件（以StorageAnalyzer为例）的目录可以看到，如图所示的结构：
![输入图片说明](pic/2022-12-24%2017%2003%2023.png)
其中"etc" "home" "target" "tmp" "var"目录链接到了对应存储空间的相应目录
2.  操作步骤：1）复制原存储空间的目录到新存储空间；2）修改"etc" "home" "target" "tmp" "var"链接到新存储空间。

#### 使用说明

1.  为避免数据丢失，操作前建议先停用要迁移的套件
![输入图片说明](pic/2022-12-24%2016%2035%2000.png)
2.  `./transferpackage.sh list`显示所有套件目录，找到要迁移套件的目录名
![输入图片说明](pic/2022-12-28%2011%2002%2007.png)
3. `./transferpackage.sh transfer [packagefolder_name] [targetvolume_num]`
例如：要把“存储空间分析器”套件迁移到存储空间2，则运行`./transferpackage.sh transfer StorageAnalyzer 2`
![输入图片说明](pic/2022-12-24%2017%2004%2030(1).png)
4. 查看迁移结果
![输入图片说明](pic/2022-12-24%2016%2052%2007.png)


