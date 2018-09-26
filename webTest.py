#!/root/.pyenv/shims/python
# -*- coding: UTF-8 -*-
# 每天23:00 运行该脚本:  “00  23 *  *  *  root python webTest.py”

import sys
import os
import time
import requests
import smtplib
from email.mime.text import MIMEText
from email.header import Header
import subprocess
import pdb
from os import popen


def	sendmail(receivers,msg,headerTo,subject):
	sender = 'liuqinyi@imaoding.com'
	password = 'HWpHq69jpPCwH6ee'
	smtp_server = 'smtp.exmail.qq.com'
	smtp_port = 465

	message = MIMEText(msg, 'html', 'utf-8')
	message['From'] = Header("liuqinyi", 'utf-8')
	message['To'] =  Header(headerTo, 'utf-8')
	message['Subject'] = Header(subject, 'utf-8')
	smtpObj = smtplib.SMTP_SSL(smtp_server,smtp_port)
	smtpObj.login(sender,password)
	smtpObj.sendmail(sender, receivers, message.as_string())
	return



def exceShell(cmd,errMsg):
	try:
		p = os.system(cmd)
		if p != 0:
			raise Exception('1')
	except Exception:
		print(errMsg)
		receivers  = ['liuqinyi@imaoding.com']
		headerTo = "liuqinyi"
		sendmail(receivers,errMsg,headerTo,errMsg)
		sys.exit(1)


def loadFile(report):
	if os.path.isfile(report):
		with open(report,'r') as f:
			result = ''.join(f.readlines())
		return result
	else:
		return "%s" % (report) #or str(report)


def exceNewman(collection,environment,report,describe):
	cmd = "newman run %s --reporters html --reporter-html-export %s -e %s" % (collection,report,environment)
	try:
		try:
			p = os.system(cmd)
			if p == 0:
				receivers  = ['liuqinyi@imaoding.com','zhangchengliang@imaoding.com']
				msg = describe + " 测试通过"
				subject = describe + "通过"
				headerTo = "admin"
				print("p==0,pass")
				sendmail(receivers,msg,headerTo,subject)
			else:
				raise("p!=0")
				
		except Exception:
			subject = describe + "不通过"
			receivers  = ['liuqinyi@imaoding.com','zhangchengliang@imaoding.com']
			headerTo = "developer"
			msg = loadFile(report)
			sendmail(receivers,msg,headerTo,subject)
			#sendmail(receivers,"msg",headerTo,subject)
			print("inner unpass,mail have been sended")
			print("p != 0")
			
			
	except Exception as err:
		print("outter err:",err)
		subject = describe + "程序报错"
		receivers  = ['liuqinyi@imaoding.com']
		headerTo = "liuqinyi"
		msg = "%s"%(err)
		sendmail(receivers,msg,headerTo,subject)
		
			 
#mvn 打包
cmd = "/project/web_pack.sh"
exceShell(cmd,'package失败')
##更新tomcat
cmd = "/root/shell_script/4.web_update.sh"
exceShell(cmd,'tomcat启动失败')


exceNewman("api8880.postman_collection.json","192.168.1.73_api.postman_environment.json","testapi_result.html",'api测试用例')
exceNewman("webTest.postman_collection.json","192.168.1.73.postman_environment.json","testweb_result.html",'web测试用例')

	



