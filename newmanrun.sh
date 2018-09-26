#!/bin/bash
#不写上面这行被python调用时会报错
#用postman导出的测试用例
collection=webTest.postman_collection.json
environment=postman_environment.json
echo '' > newman_result.html
newman run ${collection} --reporters html --reporter-html-export newman_result.html -e ${environment}
exit 0



