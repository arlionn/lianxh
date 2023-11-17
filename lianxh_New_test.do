*------------------
*- lianxh.ado test
*------------------

* Notes:
*
* 这是 lianxh.ado 程序的测试文档。
*
* >>>> 执行方法：
*  你无须选中任何命令，
*  只需打开此文档后，按快捷键 'Ctrl+D' 执行所有命令即可

  cap log close
  dis as error _n "请在命令窗口输入你的姓名：____" _n , _request(uName) 
  log using lianxh_test_${uName}.log, text replace 
  
  about 
  sysdir 
  adopath 
  
  cap noi which lianxh
  cap noi which insheetjson
  cap noi findfile libjson.mlib
  
*-安装新版 lianxh.ado 命令
  net install lianxh, from("https://gitee.com/arlionn/lianxh/raw/master/src/") replace  
  
*-basic use

  cap help lianxh
  dis as error _n "能看到 lianxh 命令的帮助文件吗？ __回复 1 或 0 __", _request(yes_help) 
  
  lianxh DID 多期 +
  
  lianxh DID, from(2023-1) gsort(-pubdate) nocat c d
  
  lianxh DID, new(10) md1
  dis as error _n "点击上方的蓝色 <View> 链接，能看到文字版的搜索结果吗？(1/0)", _request(yes_view) 
  
*-time usage 1: timer 
  forvalues i = 1/3{
      timer clear `i'
      timer on  `i' 
      qui lianxh, updata
      timer off `i'     
  }
  timer list 1 
  timer list 2
  timer list 3
  
*-time usage 2: profiler  
  forvalues i = 1/3{
      cap profiler clear
      profiler on
      qui lianxh, updata
      profiler off  
      dis _n(2) in red _dup(20) ">" _col(8) " Round : `i'"
      profiler report
  }  
  
*-Final report   
  
  log close 

  dis as error "Finished! "
  dis as error _n "请点击如下链接，打开当前工作路径，并将 {lianxh_test_${uName}.log} 文件通过微信或邮箱 arlionn@163.com 发送给连老师, 多谢啦！"
  di `"{browse `"`c(pwd)'"'}"'