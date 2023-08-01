# DSM7 套件迁移脚本



##### **2023.08.01 更新v0.2** 
1. 添加套件外部链接检测功能。
- 提示：部分套件会链接到套件文件夹外部的文件（夹），迁移后一般还能正常运行，如果外部的文件（夹）在需要调整的存储空间上，你可能需要手动移动它们，同时修改对应的软链接。
2. 增加显示特定存储空间上安装的套件清单功能。
3. 这里是列表文本增加对迁移目标存储空间的检测。

#### 一、介绍
用于在Synology DSM7 中将套件迁移到不同的存储空间。

#### 二、测试平台
所有功能在DS3615xs DSM 7.1.1-42962 Update 2中测试通过。
##### 经测试的套件
###### 1. 官方套件
| 套件目录名 | 套件名称 | 迁移结果 |
|-------|------|----|
| CloudSync |  Cloud Sync    | 正常   |
|  SynologyApplicationService     |  Synology应用程序服务    |  正常  |
|   StorageAnalyzer    |  存储空间分析器    |  正常  |
|   Node.js_v12    |  Node.js v12  | 正常   |
|   SynologyPhotos    |  Synology Photos    | 正常   |
|  LogCenter     |  日志中心    | 正常   |

###### 2. [SynoCommunity](https://packages.synocommunity.com)套件
| 套件目录名 | 套件名称 | 迁移结果 |
|-------|------|----|
|    transmission   |   Transmission   | 正常    |
|    vim   |   Vim   |  正常   |

#### 三、原理

1.  所有套件均安装在/var/packages目录，进入相应套件（以StorageAnalyzer为例）的目录可以看到，如图所示的结构：
![输入图片说明](pic/2022-12-24%2017%2003%2023.png)
其中"etc" "home" "target" "tmp" "var"目录链接到了对应存储空间的相应目录
2.  操作步骤：

 1）复制原存储空间的目录到新存储空间；

 2）修改"etc" "home" "target" "tmp" "var"链接到新存储空间。

#### 四、使用说明

1.  为避免数据丢失，操作前建议先停用要迁移的套件
![输入图片说明](pic/2022-12-24%2016%2035%2000.png)
2. 执行`sudo -i`获得root权限
3. `wget https://gitee.com/kangzeru/dsm_-transferpackage/raw/master/transferpackage.sh`
4. `chmod +x transferpackage.sh`
5. `./transferpackage.sh list`
 显示所有套件目录，找到要迁移套件的目录名
![输入图片说明](pic/2022-12-28%2011%2002%2007.png)
6. `./transferpackage.sh transfer [packagefolder_name] [targetvolume_num]`
 例如：要把“存储空间分析器”套件迁移到存储空间2，则运行`./transferpackage.sh transfer StorageAnalyzer 2`
![输入图片说明](pic/2022-12-24%2017%2004%2030(1).png)
7. 查看迁移结果
![输入图片说明](pic/2022-12-24%2016%2052%2007.png)


