#!/bin/bash
[ `ls /temp/websource|wc -l` -ne 1  ] && {
    echo "error: /temp/websource/文件不唯一,";exit 1
}
_file=`ls /temp/websource/`
echo "_file :$_file"
_prefix=`echo ${_file%%.*}`
ls -l /data/www/Lwebadmin/|grep '[^a-Z]maoding -> ' > /dev/null

[ $? -eq 0 ] && _ifold=`basename $(ls -l /data/www/Lwebadmin/|grep '[^a-Z]maoding -> ' |awk '{print $NF}')` || { 
    echo "maoding -> not found ";exit 1
}
[ -n $_ifold ] && _old_version=$_ifold

if [ -e /data/www/releases/${_prefix} ];then
mv -f /data/www/releases/${_prefix} /data/www/releases/${_prefix}_`date +%s`_old  &>/dev/null
fi
echo "正在解压war文件,请勿终止程序....."
unzip /temp/websource/${_prefix}.war -d /data/www/releases/${_prefix} >/dev/null
[ $? -ne 0 ] && { 
    echo "解压失败，退出";exit 1
}

echo -e "开始更新..."

killpid() {
_pid=`ps -ef|grep tomcat|grep  "\-Dcatalina.base=/usr/local/tomcat8/tomcat_ins/imaoding"|grep -v grep|awk '{print $2}'`
if [ -n "$_pid" ];then
kill -9 $_pid > /dev/null;sleep 2
fi

_pid=`ps -ef|grep tomcat|grep  "\-Dcatalina.base=/usr/local/tomcat8/tomcat_ins/imaoding"|grep -v grep|awk '{print $2}'`
if [ -n "$_pid" ];then
kill -9 $_pid > /dev/null;sleep 2
fi
rm -f /var/run/tom_imd.pid >/dev/null
}

killpid 

[ $? -ne 0 ] && {
	echo "停止旧进程失败"
	exit 1
}
echo "正在启动新版本..."

cd /usr/local/tomcat8/tomcat_ins/imaoding
rm -f /data/www/Lwebadmin/maoding
ln -s /data/www/releases/${_prefix} /data/www/Lwebadmin/maoding
echo '' > ./catalina.out
./tomcat.sh start &
sleep 10

_tomcatpid=/var/run/tom_imd.pid
_site='192.168.1.73:8081/maoding'  #检查网站连接
_ifcurl=`curl -o /dev/null --connect-timeout 3 -s -w "%{http_code}" $_site | egrep -w "200|300|302"|wc -l`


if [ -e $_tomcatpid -a $_ifcurl -eq 1 ];then 
    echo "新版本启动成功";exit 0
    echo -e "当前版本: $_prefix\n 旧版本: $_old_version"
else
    echo "新版本启动失败 "
	exit 1
fi

