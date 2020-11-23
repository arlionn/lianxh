{smcl}
{* *! version 1.0.06  06nov2020}{...}
{cmd:help lianxh}
{hline}

{title:Title}

{p2colset 5 16 18 2}{...}
{p2col:{hi: lianxh} {hline 2}}在 Stata 命令窗口中实现对 {browse "https://www.lianxh.cn/":lianxh.cn} 推文的关键词检索{p_end}
{p2colreset}{...}

{marker syntax}{...}
{title:Syntax}

{p 4} Quick syntax

{p 8 14 2}
{cmd:. lianxh}

{p 8 14 2}
{cmd:. lianxh all}

{p 4} Full syntax

{p 8 14 2}
{cmd:lianxh}
{bind:[{it:keywords},}
{cmdab:m:link}
{cmdab:mt:ext}
{cmdab:w:eixin}
{cmdab:s:aving(}{it:string}{cmd:)}
{cmdab:cls}
{cmdab:noc:at}
{bind:{cmdab:c:atfirst}]}

{p 8 14 2}

{synoptset 20}{...}
{synopthdr:Options}
{synoptline}
{synopt:{cmdab:m:link}}
以 Markdown 形式列示推文信息
{p_end}
{synopt:{cmdab:mt:ext}}
以文内链接形式显示 Markdown 文本 (默认为列表)
{p_end}
{synopt:{cmdab:w:eixin}}
以推文标题+URL的形式显示输出结果
{p_end}
{synopt:{cmdab:s:aving(}{it:string}{cmd:)}}
检索结果输出为 Markdown/csv/txt 文档，指定文档名称
{p_end}
{synopt:{cmdab:cls}}
清屏后显示结果
{p_end}
{synopt:{cmdab:noc:at}}
不呈现推文分类信息，需要和 mlink 或 mtext 一起用 
{p_end}
{synopt:{cmdab:c:atfirst}}
先整体列出分类信息，再统一列出推文信息，需要和 mlink 一起用
{p_end}
{synoptline}

{marker description}{...}
{title:简介}

{pstd}
{opt lianxh} 是连享会编写的一个小程序,
目的在于让用户可以便捷地从 Stata 窗口中使用关键词检索
 {browse "https://www.lianxh.cn":[连享会]} 发布的推文，同时，
 也可以列出常用的 Stata 资源链接，包括 Stata 官网地址，Stata 官方
 {browse "https://www.stata.com/support/faqs/":[FAQs]}，
Stata 论坛 {browse "https://www.statalist.org/forums/":[Statalist]}，
{browse "https://www.lianxh.cn/news/12ffe67d8d8fb.html":[Stata Journal]}；
Stata 网络教程、{browse "https://www.lianxh.cn/news/e87e5976686d5.html":[论文重现资料]} 等。
	
	
{marker Examples}{...}
{title:Examples}

{pstd}

{ul:一般用法}

{pstd}呈现一些常用资源链接，包括：论文重现网站、在线课程等{p_end}
{phang2}. {stata "lianxh "}{p_end}

{pstd}呈现所有推文主题分类列表{p_end}
{phang2}. {stata "lianxh all"}{p_end}   
{pstd}呈现包含标题中包含 [DID] 关键词的推文超链接{p_end}
{phang2}. {stata "lianxh DID"}{p_end}

{pstd}呈现含有 [DID] 或 [倍分法] 的推文 (并集){p_end}
{phang2}. {stata "lianxh DID 倍分法"}{p_end}

{pstd}呈现含有 [DID] 和 [倍分法] 的推文 (交集){p_end}
{phang2}. {stata "lianxh DID+倍分法"}{p_end}
{phang2}. {stata "lianxh DID 倍分法 +"}{p_end}

{pstd}呈现含有 [Python] [Stata] 和 [对比] 的推文 (交集){p_end}
{phang2}. {stata "lianxh Python+Stata+对比"}{p_end}
{phang2}. {stata "lianxh Python Stata 对比 +"}{p_end}

{pstd}将推文列表输出为 Markdown 文件 -mydid.md-{p_end}
{phang2}. {stata "lianxh DID, saving(mydid)"}{p_end}

{pstd}指定 Markdown 输出文件的存储路径为 [D:\连享会推文] 文件名为 mydid{p_end}
{phang2}. {stata "lianxh DID, s(D:\连享会推文/mydid)"}{p_end}

{pstd}以 推文标题+URL 格式列示推文链接文本{p_end}
{phang2}. {stata "lianxh DID, w"}{p_end}

{pstd}清屏后显示检索结果{p_end}
{phang2}. {stata "lianxh DID, cls"}{p_end}

{ul:便捷用法}

{pstd}列出所有推文专题{p_end}
{phang2}. {stata "lianxh all"}{p_end}
{p 8 14 2}
Note: 当用户最开始不知道检索什么时，可输入 all (可以简写为 a)

{ul:辅助功能: 输出 Markdown 文本}

Note: 献给喜欢用 Markdown 写东西的朋友们

{pstd}以 Markdown 格式列示推文链接文本{p_end}
{phang2}. {stata "lianxh DID, m"}{p_end}

{pstd}同上，差别自品味 ^-^{p_end}
{phang2}. {stata "lianxh DID 倍分法, mt"}{p_end}
{phang2}. {stata "lianxh DID 倍分法,m mt"}{p_end}

Attention-1: 使用 nocat 的前提是使用 mlink 或 mtext^-^
{phang2}. {stata "lianxh DID, m noc"}{p_end}
{phang2}. {stata "lianxh DID, mt noc"}{p_end}
Attention-2: 使用 catfirst 的前提是使用 mlink ^-^
{phang2}. {stata "lianxh DID, m c"}{p_end}

{title:作者}

{phang}
{cmd:Yujun, Lian (连玉君)} Lingnan College, Sun Yat-Sen University, China (中山大学岭南学院).{break}
E-mail: {browse "mailto:arlionn@163.com":arlionn@163.com}. {break}
{p_end}
{phang}
{cmd:Junjie, Kang (康峻杰)} Lingnan College, Sun Yat-Sen University, China (中山大学岭南学院).{break}
E-mail: {browse "mailto:642070192@qq.com":642070192@qq.com}. {break}
{p_end}
{phang}
{cmd:Qingqing, Liu (刘庆庆)} Lingnan College, Sun Yat-Sen University, China (中山大学岭南学院).{break}
E-mail: {browse "mailto:2428172451@qq.com":2428172451@qq.com}. {break}
HomePage: {browse "lianxh.cn":https://www.lianxh.cn}. {break}
{p_end}


{title:问题和建议}

{p 4 4 2}
使用中有任何蹩脚之处，我们都会第一时间修改，请电邮至：
{browse "mailto:arlionn@163.com":arlionn@163.com}. 

{p 4 4 2}
同时欢迎将您的问题留言给我们：
{browse "https://www.wjx.cn/jq/98072236.aspx":[点击留言：Questions about lianxh]}.



