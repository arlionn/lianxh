
*! Verion: 2.17
*! Update: 2020/11/21 12:21
*! https://www.lianxh.cn
* Author: 连玉君 (Email: arlionn@163.com)
*         康峻杰 (Email: 642070192@qq.com)
*         刘庆庆 (Email: 2428172451@qq.com)


cap program drop lianxh
program define lianxh

version 14
	
syntax [anything(name = class)] [, ///
        Mlink           ///   // - [推文标题](URL)
	    MText           ///   //   [推文标题](URL)
		Weixin          ///   // 推文标题  URL
	    Saving(string)  ///   // 保存路径及文件名
		CLS             ///   // 清屏后显示结果
		NOCat           ///   // 不呈现推文分类信息  
		Catfirst        ///   // 先整体列出分类信息，再统一列出推文信息
	   ]
	
*===============================================================================
* Part I: 无需爬虫的部分

*------------------------------------------------------------------------------*
*- 预先设定option
		
	if "`cls'" != "" {
		 cls
	}

	if "`class'" == "" {  
		 lianxh_links                    // sub-program
		 exit
	}

	if "`class'" == "mybook" {
		 dis _n in w  _col(6)  /// 
		  `"{browse "https://quqi.com/s/880197/hmpmu2ylAcvHnXwY": [计量 Books] }"' 
		 if "`weixin'" != "" {
			dis "计量 Books: https://quqi.com/s/880197/hmpmu2ylAcvHnXwY "
		 }
		 exit
	}
	
	if "`class'" == "sj" | "`class'"=="SJ"  {
		 dis _n in w  _col(6)  /// 
		  `"{browse "https://www.lianxh.cn/news/12ffe67d8d8fb.html": [Stata Journals] }"' 
		  if "`weixin'" != ""{
			dis "Stata Journals: https://www.lianxh.cn/news/12ffe67d8d8fb.html "
		  }
		 exit
	}	
	
	if "`class'" == "33" | "`class'" == "my33" {
		 dis _n in w  _col(6)  /// 
		  `"{browse "https://gitee.com/lianxh/Stata33": [连享会公开课：Stata 33讲] }"' 
		  if "`weixin'" != ""{
		 	 dis  "连享会公开课：Stata 33讲: https://gitee.com/lianxh/Stata33 "
		  }
		 exit
	}	
	
	if "`class'" == "mylink"  {
		 dis _n in w  _col(6)  /// 
		  `"{browse "https://www.lianxh.cn/news/9e917d856a654.html": [Super Links] }"' 
		  if "`weixin'" != "" {
		     dis "Super Links: https://www.lianxh.cn/news/9e917d856a654.html"
		  }
		 exit
	}
	
	if "`class'" == "mypaper"  {
		 dis _n in w  _col(6)  /// 
		  `"{browse "https://www.lianxh.cn/news/e87e5976686d5.html": [论文重现网站] }"' 
		  if "`weixin'" != ""{
			 dis "论文重现网站: https://www.lianxh.cn/news/e87e5976686d5.html"
		  }
		 exit
	}
	
	if "`class'" == "myopen"  {
		 dis _n in w  _col(6)  /// 
		  `"{browse "https://gitee.com/arlionn/Course": [连享会课程] }"' 
		  if "`weixin'" != ""{
			 dis "连享会课程: https://gitee.com/arlionn/Course " 
		  }
		 exit
	}

*- 存储路径处理	
	if `"`saving'"'~="" {
	  *-split file path and fileanme
		local saving = subinstr(`"`saving'"',`"""',"",.)  // 去掉路径中的 ["]
		local saving = subinstr(`"`saving'"',"\","/",.)   // 把 [\] 换成 [/],保持跨平台通用性
		
		local path_reverse = ustrreverse("`saving'")   //将用户输入颠倒，提取第一个/来分割路径和文件名
		local index_fullname = index(`"`path_reverse'"',"/")
		if `index_fullname' ~= 0{
			local path   = ustrreverse(substr(`"`path_reverse'"',`=`index_fullname'+1',.))
			local saving = ustrreverse(substr(`"`path_reverse'"',1,`=`index_fullname'-1'))
		}
		else {
			local path `c(pwd)'
		}
	  *-split file mainname and suffixname
		local beg_dot = index(`"`saving'"',".")
		if `beg_dot'~=0 {
			local suffixname = substr(`"`saving'"',`=`beg_dot'+1',.)
			if ~inlist("`suffixname'","txt","csv","md"){
			   noi dis in red "Only [.txt .csv .md] files are supported by {opt saving()}"
			   exit 
			}
			local mainname = substr(`"`saving'"',1,`=`beg_dot'-1')
		}
		else {
			local mainname `"`saving'"'
			local suffixname = "md"
		}
		local saving `"`mainname'.`suffixname'"'
		
	  *-检查输入的路径是否存在	
		local path_origin `c(pwd)' //存储用户路径
		cap cd `"`path'"'			
		if _rc {
			local saving ""        //相当于取消掉用户saving的输入，避免下文出现找不到文件的错误
			local path_warn "1"    //存储报错暂元，在程序末尾进行报错并返回提示信息
		}
		cap cd `path_origin'       //恢复用户路径		
	}	

  
*==============================================================================*
* Part II: 爬取 lianxh.cn/blogs 网页

	preserve

	clear    // 避免变量与用户变量冲突

	tempfile            ///
	         lxh_BlogTitle    ///
	         catID_dta        ///
			 CatIDnew_data    ///
			 catSort          ///
			 Final_data       ///
			 outcome          ///
			 mycovs1          ///
			 


	*------------------------------------------------------------------------*
	***正则表达式抽取网址 标题 分类标签等***
	
	qui{	
		local URL "https://www.lianxh.cn/blogs.html" 

		tempfile  html_text   HTML_text_dta   catID_dta
		
		capture copy `"`URL'"' "`html_text'.txt", replace   
		local times = 0
		while _rc ~= 0 {
			local times = `times' + 1
			sleep 1000
			cap copy `"`URL'"' "`html_text'.txt", replace
			if `times' > 10 {
				disp as error "Internet speeds is too low to get the data"
				exit 601
			}
		}
	}

	
	qui{
		infix strL v 1-1000 using "`html_text'.txt", clear
		save "`HTML_text_dta'", replace
		
		*- 抽取原始链接
		local regex    = `"(?<="><a href=")(.*)(?=")"' 
		* 以 「"><a href="」开头，「"」结尾的字符串 
		gen BlogURL     = ustrregexs(0) if ustrregexm(v, `"`regex'"')
		replace BlogURL = "https://www.lianxh.cn" + BlogURL if BlogURL!=""
		
		*- 抽取标题
		local regex   = `"(?<=html">)(.+)(?=</a></h3>)"'
		gen BlogTitle = ustrregexs(0) if ustrregexm(v, `"`regex'"')
		
		*- 抽取分类标签
		local regex = `"(<span>)(\D.*)(?:</span>)"'  
		gen CatName = ustrregexs(2) if ustrregexm(v, `"`regex'"')	
		drop if ustrregexm(CatName, "(data\[item\])")
		keep if (BlogURL !="" | CatName!="")
		replace CatName = CatName[_n+1] if CatName==""
		keep if BlogTitle !=""
		drop v
		drop if ustrregexm(BlogTitle, "(data\[item\])")
		format BlogTitle %-60s
		gen id = _n         // 推文发表时间序号
		save "`lxh_BlogTitle'", replace 	
		

		use "`HTML_text_dta'", clear
		local regex = `"(?<=/blogs/)\d+(?=\.html)"'
		gen catID_str   = ustrregexs(0) if ustrregexm(v, `"`regex'"')  // 分类编号

		keep if catID_str != ""
		local regex = `"(?<=\s>).+(?=</a>)"'
		gen CatName = ustrregexs(0) if ustrregexm(v, `"`regex'"')  // 分类名称
		drop v 
		destring catID_str, gen(catID)
					
		gen CatIDnew = .
		
		replace CatIDnew = 0.01   if catID == 44
		replace CatIDnew = 0.02	  if catID == 34
		replace CatIDnew = 0.03	  if catID == 31
		replace CatIDnew = 0.1	  if catID == 43
		replace CatIDnew = 0.08	  if catID == 16
		replace CatIDnew = 0.09	  if catID == 17
		replace CatIDnew = 0.04	  if catID == 18
		replace CatIDnew = 0.11	  if catID == 35
		replace CatIDnew = 0.12	  if catID == 25
		replace CatIDnew = 0.13	  if catID == 24
		replace CatIDnew = 0.14	  if catID == 26
		replace CatIDnew = 0.17	  if catID == 22
		replace CatIDnew = 0.21	  if catID == 32
		replace CatIDnew = 0.22	  if catID == 20
		replace CatIDnew = 0.24	  if catID == 38
		replace CatIDnew = 0.26	  if catID == 39
		replace CatIDnew = 0.28	  if catID == 40
		replace CatIDnew = 0.3	  if catID == 41
		replace CatIDnew = 0.32	  if catID == 42
		replace CatIDnew = 0.43	  if catID == 19
		replace CatIDnew = 0.45	  if catID == 21
		replace CatIDnew = 0.47	  if catID == 28
		replace CatIDnew = 0.49	  if catID == 29
		replace CatIDnew = 0.51	  if catID == 27
		replace CatIDnew = 0.61	  if catID == 36
		replace CatIDnew = 0.63	  if catID == 37
		replace CatIDnew = 0.96	  if catID == 45
		replace CatIDnew = 0.97	  if catID == 30
		replace CatIDnew = 0.98	  if catID == 23
		replace CatIDnew = 0.99	  if catID == 33	
			
		save "`catID_dta'", replace  // 临时保存文件，随后与主文件合并 
      		  
		use "`catID_dta'", clear	
		merge 1:m CatName   using "`lxh_BlogTitle'", nogen 
			
			
		*----根据 mlink mtext weixin 等选项设定这里的格式 

		local url "https://www.lianxh.cn/blogs/"
		gen CatURL = "`url'" + catID_str + ".html"
		gen CatNameURL_md = "[" + CatName + "](" + CatURL + ")"

		gen blog_Mlink = "- [" + BlogTitle + "](" + BlogURL + ")"  // list
		gen blog_Mtext =  " [" + BlogTitle + "](" + BlogURL + ") " // list2
		gen blog_Weixin= BlogTitle + ": " + BlogURL

		gen blog_br = `"{browse ""' + BlogURL +`"": "' + BlogTitle +`"}"'           
		gen Cat_br  = `"{browse ""' + "`url'" + catID_str +`"": "' + CatName +`"}"' 


		*-后续检索关键词不区分大小写
		replace BlogTitle = lower(BlogTitle)  

		save "`Final_data'", replace

		*- 前期数据处理完毕	
	}

	
	
*==============================================================================*
**** 输入变量识别 ****
    
	qui use  "`Final_data'", clear
	
	*------------------------------------------------------------------------*
	***class识别***

	if "`class'" == "mylist" {
		sort CatIDnew id
		qui egen tag = tag(CatName)
		qui gen id_temp = _n
		qui expand 2 if tag==1, gen(tag_expand)  
		*-分类标题
		qui replace blog_Mlink = "## " + CatName  if tag_expand==1 
		gsort id_temp -tag -tag_exp
	
		local date = subinstr("`c(current_date)'"," ","",3)
		qui {
			insobs 4, before(1)  //增加几行观察值，以便写大标题
			replace id = -9 in 1
			replace id = -8 in 2
			replace id = -7 in 3
			replace id = -6 in 4 
			
			replace blog_Mlink = "## 连享会 - 推文列表" if id==-9
			replace blog_Mlink = "> &emsp;     " if id==-8
			replace blog_Mlink = "> &#x231A; Update: ``date'` &emsp;  &#x2B55; [**按时间顺序查看**](https://www.lianxh.cn/news/451e863542710.html)  " if id==-7
			replace blog_Mlink = "> &emsp;     " if id==-6
		}
		*local date = subinstr("`c(current_date)'"," ","",3)
		
		if "`saving'" == ""{
			local path `c(pwd)'
			local saving "连享会主页_推文列表-分类_`date'.md"
		}
        local n = _N
		forvalues j = 1/`n' {
			if tag_expand[`j']==1{
			   dis " 专题 >>" Cat_br[`j']
			}
			else{
			   dis "	" blog_br[`j']				
			}
		}
		dis _n _c
		export delimited blog_Mlink using "`path'/`saving'" , ///
			   novar nolabel delimiter(tab) replace
		local save "`saving'"   
	   
		noi dis _n ///
				_col(5)  `"{stata `" view  "`path'/`save'" "': View}"' ///
				_col(17) `"{stata `" !open "`path'/`save'" "' : open_Mac}"' ///
				_col(30) `"{stata `" winexec cmd /c start "" "`path'/`save'" "' : open_Win}"'

		noi dis _col(10) `"{browse `"`path'"': dir}"'		
		exit
	}
	  
	else if "`class'" == "all" {
		qui duplicates drop CatName, force
		sort CatIDnew
		local n = _N
		dis _col(30) `"{browse "https://www.lianxh.cn/news/d4d5cd7220bc7.html": - 分类查看所有推文 - }"' _n
        
         local G = 4               // 每行显示个数
         local N = _N              // 类别数
         local NN = ceil(`N'/`G')  // 行数
        
        local i = 1
        forvalues row = 1/`NN'{
           forvalues j=0/`=`G'-1'{
              if mod(`i',`G')==0{
                 local newline "_n"
              }   
              else{
                 local newline ""
              }
              local colpos = `j'*25
              dis _col(`colpos') Cat_br[`i++'] _c `newline'
           }
        }
		exit
	}	
	if ustrregexm(`"`class'"', "\+") != 0 {
		local class_c       = lower("`class'")
		while ustrregexm(`"`class_c'"', "\+"){
			local class_c   =  ustrregexrf(`"`class_c'"',"\+"," ")
		}
		foreach name in `class_c'{
			qui gen index_`name' = ustrregexm(BlogTitle,`"`name'"')
			qui keep if index_`name' ==1
		}
		sort CatIDnew id
		local n = _N
		if `n' > 0{
			dis " 专题 >>" Cat_br[1] 
		}
		forvalues j = 1/`n' {
			if (`j'>1) & (Cat_br[`j'] != Cat_br[`j'-1]) {
			   dis " 专题 >>" Cat_br[`j']
			}
			dis "	"blog_br[`j']				
		}
		cap save "`outcome'", replace
	}	
	else{
		// 空格情况，取并集
		qui gen code = 0
		foreach name in `class'{
			local name = lower("`name'")
			qui gen index_`name' = ustrregexm(BlogTitle,`"`name'"')
			qui replace code = code + index_`name'
		}
		qui keep if code != 0
		sort CatIDnew id
		local n = _N
		if `n' > 0 {
			dis " 专题 >>" Cat_br[1] 
		}
		forvalues j = 1/`n' {
			if (`j'>1) & (Cat_br[`j'] != Cat_br[`j'-1]) {
			    dis _n " 专题 >>" Cat_br[`j'] 
			}
			dis "	" blog_br[`j']				
		}
		qui save "`outcome'", replace
	}
	
	if `"`path_warn'"' == "1" {
		dis as error `"  存储路径有误，see { stata  " help lianxh" } "'
	}	
	
	qui use "`outcome'", clear
	local n = _N

	*------------------------------------------------------------------------*
	***options识别***
		
		if `n' > 0{
		    dis _n
			if "`mlink'" != ""{
				use "`outcome'", clear
				sort CatIDnew id
				local n = _N
				if "`catfirst'" != "" {
					dis _n
					dis "-" " 专题：" CatNameURL_md[1]
					forvalues j = 1/`n' {
						if (`j'>1) & (Cat_br[`j'] != Cat_br[`j'-1]) {
						dis "-" " 专题：" CatNameURL_md[`j'] 	
						}		
					}
					dis _n		
					forvalues j = 1/`n'{
						dis blog_Mlink[`j']
					}
				}
				if "`nocat'" != "" {    //nocat选项 
					dis _n 
					forvalues j = 1/`n'{
						dis blog_Mlink[`j']
					}
				}
				if "`catfirst'" == "" & "`nocat'" == "" {
					dis _n
					dis "-" " 专题：" CatNameURL_md[1]
					forvalues j = 1/`n' {
						if (`j'>1) & (Cat_br[`j'] != Cat_br[`j'-1]) {
						dis "-" " 专题：" CatNameURL_md[`j'] 	
						}		
						dis  "  " blog_Mlink[`j'] //前面空两格
					}
					dis _n
				}
			}
		
			if "`mtext'" != ""{
				use "`outcome'", clear
				sort CatIDnew id
				local n = _N
				dis _n
				if "`nocat'" == "" {
					dis " 专题：" CatNameURL_md[1]
					forvalues j = 1/`n' {
						if (`j'>1) & (Cat_br[`j'] != Cat_br[`j'-1]) {
							dis " 专题：" CatNameURL_md[`j'] 	
						}			
						dis blog_Mtext[`j']
					}
				}
				else {
					forvalues j = 1/`n'{
						dis blog_Mlink[`j']
					}
				}
				dis _n
			}
			
			if "`weixin'" != ""{  
				use "`outcome'", clear
				sort CatIDnew id
				local n = _N
				*dis "  "
				local Ng = 8               // 每组 8 条记录
				forvalues j = 1/`n' {
				    if `j'>=8&mod(`j',8)==0{
					    local newline "_n"
					}	
					else{
					    local newline ""
					}		
					dis blog_Weixin[`j'] `newline'
				}
				if `n'>=10{
				    dis in red _n "Note: 建议分多次复制到微信对话框，每次 8 行，否则超链接无法生效"
				}
			}
						
			if "`saving'" ~= ""{
			    dis _n _c
				export delimited blog_Mlink using "`path'/`saving'" , ///
					   novar nolabel delimiter(tab) replace
				local save "`saving'"   
					   
				noi dis _n ///
				        _col(5)  `"{stata `" view  "`path'/`save'" "': View}"' ///
				        _col(15) `"{stata `" !open "`path'/`save'" "' : open_Mac}"' ///
						_col(30) `"{stata `" winexec cmd /c start "" "`path'/`save'" "' : open_Win}"'
				
				noi dis _col(10) `"{browse `"`path'"': dir}"'
			}			
			
		}
		
		else{
			dis as error `"  一无所获? 试试 {stata "   lianxh all  "} 或 {browse "https://www.lianxh.cn/blogs.html":  [推文列表]        }"' 
			dis as text  `"  烦请您花一分钟反馈您刚才未检索到的关键词，以便我们优化程序："'
			dis _col(20) `"  {browse "https://www.wjx.cn/jq/98072236.aspx":点击填写 (有惊喜!)      }"'
		}    
	
restore	
end





*==============================================================================*	
****Sub programs****
cap program drop lianxh_links
program define lianxh_links
version 8

	  dis    in w _col(20) _n _skip(25) "Hello, Stata!" _n
	  local c1 = 15    // 起始位置
	  local skip = 20  // 间距
	  local G = 6      // 每行个数
	  local cF = `skip'*`G'
	  forvalues i = 2/`G'{
	     local c`i' = `c1' + `skip'*`=`i'-1'
		 *dis "`c`i''"
	  }
	  

	  
	  dis in w " Stata官方: "  ///
		 _col(`c1') `"{browse "http://www.stata.com":`Lbb'Stata.com`Rbb'}"' ///
		 _col(`c2') `"{browse "http://www.stata.com/support/faqs/":`Lbb'FAQs`Rbb'}"' ///
		 _col(`c3') `"{browse "https://blog.stata.com/":`Lbb'Blogs`Rbb'}"' 
      dis in w  _col(11)  ///			 
		 _col(`c1') `"{browse "https://www.stata.com/links/resources-for-learning-stata/":`Lbb'Resources`Rbb'}"' ///
		 _col(`c2') `"{browse "https://www.stata.com/bookstore/stata-cheat-sheets/":`Lbb'Stata小抄`Rbb'}"' ///		 
		 _col(`c3') `"{browse "https://www.stata.com/links/examples-and-datasets/":`Lbb'Textbook Example`Rbb'}"' ///
		 _n

	  dis in w " Stata资源: "  ///	
		 _col(`c1') `"{browse "https://www.lianxh.cn/news/a630af7e186a2.html":`Lbb'书单`Rbb'}"' ///
		 _col(`c2') `"{browse "https://www.lianxh.cn/news/790a2c4103539.html":`Lbb'资源汇总`Rbb'}"' ///
		 _col(`c3') `"{browse "https://www.lianxh.cn/news/f2ad8bf464575.html":`Lbb'Stata16手册`Rbb'}"' 
      dis in w  _col(11)  ///			 
		 _col(`c1') `"{browse "https://www.lianxh.cn/news/12ffe67d8d8fb.html":`Lbb'Stata Journal`Rbb'}"' ///
		 _col(`c3') `"{browse "https://www.lianxh.cn/news/9e917d856a654.html":`Lbb'Links/Tools`Rbb'}"' ///
		 _n
		  	  
	  dis in w " 提问交流: "  ///
		 _col(`c1') `"{browse "http://www.statalist.com":`Lbb'Stata List`Rbb'}"'      ///
		 _col(`c2') `"{browse "https://gitee.com/arlionn/WD":`Lbb'连享会FAQs`Rbb'}"'  ///
		 _col(`c3') `"{browse "https://bbs.pinggu.org/forum-67-1.html":`Lbb'经管之家`Rbb'}"'  
      dis in w  _col(11)  ///			 
		 _col(`c1') `"{browse "https://stackoverflow.com":`Lbb'Stack Overflow`Rbb'}"' ///
		 _n
	  
	  dis in w " 推文视频: "  /// 
	     _col(`c1') `"{browse "https://www.lianxh.cn/news/d4d5cd7220bc7.html":`Lbb'连享会推文`Rbb'}"' ///
		 _col(`c2') `"{browse "https://www.zhihu.com/people/arlionn/":`Lbb'知乎`Rbb'}"'  ///
		 _col(`c3') `"{browse "https://gitee.com/arlionn/Course":`Lbb'码云仓库`Rbb'}"' 
	  dis in w  _col(11)  ///		 
		 _col(`c1') `"{browse "https://www.lianxh.cn/news/46917f1076104.html":`Lbb'计量专题`Rbb'}"' ///
		 _col(`c2') `"{browse "http://lianxh.duanshu.com":`Lbb'视频直播`Rbb'}"'  ///
		 _col(`c3') `"{browse "https://www.techtips.surveydesign.com.au/blog/categories/stata":`Lbb'Tech-Tips`Rbb'}"'  ///
		 _n

	  dis in w " 在线课程: "  ///
		 _col(`c1') `"{browse "https://stats.idre.ucla.edu/stata/":`Lbb'UCLA`Rbb'}"' ///
		 _col(`c2') `"{browse "http://www.princeton.edu/~otorres/Stata/":`Lbb'Princeton`Rbb'}"' ///
		 _col(`c3') `"{browse "http://wlm.userweb.mwn.de/Stata/":`Lbb'Online Stata`Rbb'}"'
	  dis in w  _col(11)  ///	
		 _col(`c1') `"{browse "https://gitee.com/arlionn/stata101":`Lbb'Stata 33 讲`Rbb'}"' ///	  
		 _col(`c3') `"{browse "https://gitee.com/arlionn/PanelData":`Lbb'面板数据模型`Rbb'}"' ///
		 _n
		 
	  dis in w " 学术搜索: "  /// 
		 _col(`c1') `"{browse "https://scholar.google.com/":`Lbb'Google学术`Rbb'}"'  ///
		 _col(`c2') `"{browse "https://academic.microsoft.com/home":`Lbb'微软学术`Rbb'}"'  ///		  
		 _col(`c3') `"{browse "http://scholar.chongbuluo.com/":`Lbb'学术搜索`Rbb'}"'  
	  dis in w  _col(11)  ///
		 _col(`c1') `"{browse "http://scholar.cnki.net/":`Lbb'CNKI`Rbb'}"' ///	
		 _col(`c2') `"{browse "http://xueshu.baidu.com/":`Lbb'百度学术`Rbb'}"' ///
		 _col(`c3') `"{browse "https://sci-hub.ren":`Lbb'SCI-HUB`Rbb'}"' ///
		 _n
		  
	  dis in w " 论文重现: "  ///	  		  
	     _col(`c1') `"{browse "https://www.lianxh.cn/news/e87e5976686d5.html":`Lbb'论文重现网站`Rbb'}"' ///
		 _col(`c2') `"{browse "https://dataverse.harvard.edu/dataverse/harvard?q=stata":`Lbb'Harvard dataverse`Rbb'}"' ///
		 _col(`c3') `"{browse "http://replication.uni-goettingen.de/wiki/index.php/Main_Page":`Lbb'Replication WIKI`Rbb'}"' 
	  dis in w  _col(11)  ///
	     _col(`c1') `"{browse "https://www.icpsr.umich.edu/icpsrweb/":`Lbb'ICPSR`Rbb'}"' ///
		 _col(`c2') `"{browse "https://data.mendeley.com/":`Lbb'Mendeley`Rbb'}"' ///
		 _col(`c3') `"{browse "https://github.com/search?utf8=%E2%9C%93&q=stata&type=":`Lbb'Github`Rbb'}"' ///
		 _n
	  dis in w  _col(11)  ///
	     _col(`c1') `"{browse "https://www.aeaweb.org/journals":`Lbb'AEA`Rbb'}"' ///
		 _col(`c2') `"{browse "https://data.mendeley.com/":`Lbb'JFE`Rbb'}"' ///
		 _col(`c3') `"{browse "https://github.com/search?utf8=%E2%9C%93&q=stata&type=":`Lbb'Github`Rbb'}"' ///
		 _n		 
		  
	  dis in w _col(15) ///
		  as smcl `"{stata "net install lianxh.pkg, from(https://arlionn.gitee.io/lianxh) replace": -更新lianxh-}"' ///
		  _skip(8)     ///
		  as smcl `"{stata "lianxh all": -查看分类推文-}"' 
		  
end
   	




	
