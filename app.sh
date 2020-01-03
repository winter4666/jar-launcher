#!/bin/bash
# Program:
#       针对普通的可执行的jar文件，提供启动，停止，重启等功能
# History:
# 2019/12/20    winter  First release

SHELL_FOLDER=$(cd "$(dirname "$0")";pwd)
APP_JAR="app.jar"
APP_PID="app.pid"
APP_CONF="app.conf"

start(){
	if [ -e "$SHELL_FOLDER/$APP_PID" ]; then
		echo "File $SHELL_FOLDER/$APP_PID is existed. App appears to still be running. Start aborted."
		exit 1
	fi

	if [ -s "$SHELL_FOLDER/$APP_CONF" ]; then
		source $SHELL_FOLDER/$APP_CONF
		echo "JAVA_OPTS:$JAVA_OPTS"
	fi
	
	if [ $RM_LOGS -eq 1 ]; then
		echo "remove all logs in $SHELL_FOLDER/logs/"
		rm -rf $SHELL_FOLDER/logs/*
	fi
	
	nohup java $JAVA_OPTS -jar $SHELL_FOLDER/$APP_JAR >$SHELL_FOLDER/logs/system.log 2>&1 & 
	echo $! > $SHELL_FOLDER/$APP_PID
	echo "app $SHELL_FOLDER started."
}

stop(){
	if [ ! -e "$SHELL_FOLDER/$APP_PID" ]; then
		echo "File $SHELL_FOLDER/$APP_PID is not found. App appears to have been stopped. Stop aborted."
		exit 1
	fi

	PID=`cat "$SHELL_FOLDER/$APP_PID"`
	kill -9 $PID
	KILL_SLEEP_INTERVAL=5
	while [ $KILL_SLEEP_INTERVAL -ge 0 ]; do
		kill -0 $PID >/dev/null 2>&1
		if [ $? -gt 0 ]; then
		    rm -f $SHELL_FOLDER/$APP_PID
		    echo "app $SHELL_FOLDER stopped."
		    break
		fi
		if [ $KILL_SLEEP_INTERVAL -gt 0 ]; then
		    sleep 1
		fi
		KILL_SLEEP_INTERVAL=`expr $KILL_SLEEP_INTERVAL - 1 `
	done
	if [ $KILL_SLEEP_INTERVAL -lt 0 ]; then
	    echo "app has not been stopped completely yet. The process might be waiting on some system call or might be UNINTERRUPTIBLE."
	fi
}

restart(){
	stop
	start
}

echo "APP_HOME:$SHELL_FOLDER"
RM_LOGS=0
if [ "$2" = "-rmlogs" ]; then
	RM_LOGS=1
fi
case $1 in
	"start")
		start
		;;
	"stop")
		stop
		;;
	"restart")
		restart
		;;
	*)
		echo "Usage: app.sh ( commands ... )"
		echo "commands:"
		echo "  start             Start java app"
		echo "  stop              Stop java app"
		echo "  restart           Restart java app"
		echo "  start -rmlogs     Start java app after removing logs"
		echo "  restart -rmlogs   Restart java app and remove logs"
		;;
esac