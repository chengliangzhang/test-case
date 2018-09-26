#!/bin/bash
# maoding_web 项目打包
projecthome=/project/maoding-web-branche-from-26561/
redisconfHome=${projecthome}/web2/src/main/resources/
propertiesHome=${redisconfHome}/properties/
targetwar=${projecthome}/web2/target/web2-1.0.war
gulppath=${projecthome}/node_modules/gulp/bin/
dest=/temp/websource


Svn=/usr/bin/svn
Mvn=/usr/local/maven/bin/mvn
Node=/usr/local/node/bin/node

#echo -e "--------------------------- \n
#      准备打包maoding_branche项目 \n
#      项目地址: $projecthome \n
#      配置文件地址:$confsrc \n
#      生成war包地址: $dest \n
#      请确认是否有新配置需要更改，或bundle, mysql是否也要更新!！ \n"
#



cd $projecthome 
echo -e "---------正在执行:mvn clean ------------\n" 
$Mvn clean 
[ $? -ne 0 ] && {
	echo "mvn clean 执行失败"
	exit;
}

echo -e "------------正在执行: svn revert -----------\n"
$Svn revert -R $projecthome
[ $? -ne 0 ] && {
	echo "svn revert执行失败"
	exit;
}

echo -e "------------正在执行: svn update-----------\n"
$Svn update --accept theirs-conflict --ignore-externals
[ $? -ne 0 ] && {
	echo "svn update失败"
	exit;
}

#svnversion=`$Svn info|grep 'Revision'|cut -d' ' -f2`
svnversion=`$Svn info|grep 'Last Changed Rev:'|cut -d' ' -f4`
committime=`svn info|grep 'Last Changed Date'|cut -d' ' -f4,5`
author=`svn info|grep 'Last Changed Author'|cut -d' ' -f4`
#配置文件目录
confsrc="/project/configure/73_web"

#配置文件
viewsHome=${projecthome}/web2/src/main/webapp/views
redisSessionConf=${confsrc}/redissonConfig-session.json
redisCorpConf=${confsrc}/redissonConfig-corp.json
jdbcConf=${confsrc}/jdbc.properties
sysproperties=${confsrc}/system.properties
redisproperties=${confsrc}/redis.properties
#footerNew=${viewsHome}/lib_footer_new.jsp 
#footerNewLite=${viewsHome}/lib_footer_new_lite.jsp
#lib_footer=${viewsHome}/website/lib_footer.jsp


echo -e "--------------正在拷贝配置文件--------------  \n"
/bin/cp -f $redisSessionConf $redisconfHome || {
	echo "拷贝${redisSessionConf}出错,退出!"
	exit
}
/bin/cp -f $redisCorpConf $redisconfHome || {
	echo "拷贝${redisCorpConf}出错 !退出"
	exit
}
/bin/cp -f $jdbcConf $propertiesHome || {
	echo "拷贝${jdbcConf}出错 !退出"
	exit
}
/bin/cp -f $sysproperties $propertiesHome || {
	echo "拷贝${sysproperties}出错，退出"
	exit
}
/bin/cp -f $redisproperties $propertiesHome || {
	echo "拷贝${redisproperties}出错 !退出"
	exit
}


#echo "--------------正在sed-------------"
#echo $footerNew
#
#sed -i  s'#<script type="text/javascript" src="<%=rootPath %>/assets/js/module.js?v=<%=v%>"></script>#<script type="text/javascript" src="<%=rootPath %>/assets/js/module.min.js?v=<%=v%>"></script>#' $footerNew
#
#echo "--------------正在sed-------------"
#echo $footerNewLite
#
#sed -i  s'#<script type="text/javascript" src="<%=rootPath %>/assets/js/module.js?v=<%=v%>"></script>#<script type="text/javascript" src="<%=rootPath %>/assets/js/module.min.js?v=<%=v%>"></script>#' $footerNewLite
#
#echo "--------------正在sed-------------"
#echo $footerNew
#
#sed  -i  s'#<script type="text/javascript" src="<%=rootPath %>/assets/js/module.js?v=<%=v%>"></script>#<script type="text/javascript" src="<%=rootPath %>/assets/js/module.min.js?v=<%=v%>"></script>#' $lib_footer
#
#

echo -e "------------正在执行 gulp generate_module-------------\n"
$Node $gulppath/gulp.js --gulpfile $projecthome/gulpfile.js generate_module
[ $? -ne 0 ] && {
	echo "gulp generate_module执行失败"
	exit;
}

#echo -e "-------------正在执行 gulp generate_module_min--------------\n"
#$Node $gulppath/gulp.js --gulpfile $projecthome/gulpfile.js generate_module_min
#[ $? -ne 0 ] && {
#	echo "gulp generate_module_min执行失败"
#	exit;
#}


echo -e "-------------正在执行 gulp generate_vendor--------------\n"
$Node $gulppath/gulp.js --gulpfile $projecthome/gulpfile.js generate_vendor
[ $? -ne 0 ] && {
	echo "gulp generate_vendor执行失败"
	exit;
}


echo -e "------------正在执行 mvn package -----------------\n"
$Mvn package -Dmaven.test.skip=true
[ $? -ne 0 ] && {
	echo "mvn package执行失败"
	exit;
} || {
	echo "mvn package执行完毕"
}

sleep 2
packname=web`date +%Y%m%d`_svn${svnversion}.war
releases_dir=/data/www/releases


[ ! -e $targetwar ] && echo "war包未生成!" || {
        echo "开始拷贝war包到目标目录.."
		rm -rf /temp/websource/*.war
        /bin/cp -f $targetwar $dest/$packname && echo "${targetwar}已复制到${dest}" || {
        echo "文件拷贝失败"
        exit 1
        }
}




