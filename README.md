# jar-launcher
linux下的shell脚本，可以针对普通的java可执行jar文件进行启动，停止，重启等操作

## WHY
执行jar文件时，若是每次都是直接在命令行使用`java -jar`指令的话，会非常麻烦，而且也有很多问题：没办法优雅的结束应用，没办法便捷的配置一些变量......

## HOW
将`app.sh`和你的jar文件放在同一个目录下，约定该jar文件的名字是`app.jar`，同时需要在该目录下建一个文件夹`logs`用于存放默认控制台输出的日志内容。
启动
```shell
./app.sh start
```
停止
```shell
./app.sh stop
```
重启
```shell
./app.sh restart
```
若是想要在java程序启动时进行一些参数的配置，譬如典型的虚拟器参数`-Xms`、`-Xmx`，只需要在该目录下新建一个`app.conf`，在里面可以填写如下内容：
```
JAVA_OPTS="-Xms64m -Xmx256m"
```
那么使用`app.sh`启动程序时，会自动加载该文件，读取`JAVA_OPTS`的值作为java程序的启动参数。