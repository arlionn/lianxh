 
> `lianxh` 命令：在 Stata 里看推文

使用过程中若发现 bugs 或有好的建议，可以通过两种途径反馈 (我们会定期抽取部分幸运者，赠送连享会直播课程)：
- 发邮件至 <StataChina@163.com>
- 在线提交 (1-2 分钟即可)：[我的建议和问题](https://www.wjx.cn/jq/98072236.aspx)

&emsp;

## 1. 简介

`lianxh` 命令是连享会编写的一个小程序，目的在于让用户可以便捷地从 Stata 窗口中使用关键词检索 [连享会](https://www.lianxh.cn) 发布的推文，同时，也可以列出常用的 Stata 资源链接，包括 Stata 官网地址，Stata 官方 [FAQs](https://www.stata.com/support/faqs/)，Stata 论坛 ([Statalist](https://www.statalist.org/forums/))，[Stata Journal](https://www.lianxh.cn/news/12ffe67d8d8fb.html)；Stata 网络教程、[论文重现资料](https://www.lianxh.cn/news/e87e5976686d5.html) 等。

## 2. 安装

在 Stata 命令窗口中输入如下命令即可安装：

```stata
. ssc install lianxh, replace 
```

查看帮助文件：
```stata
. help lianxh     // 英文版
. help lianxh_cn  // 中文版
```

## 3. 常用命令
```stata
. lianxh        // 呈现 Stata 资源链接和常用网址
 
. lianxh all    // 呈现所有分类

. lianxh DID    // 呈现包含 DID 关键词的推文

. lianxh DID 倍分 双差分 // 多个关键词查询 (并集)

. lianxh DID+倍分        // 多个关键词查询 (交集)

. lianxh 资源

. lianxh book

. lianxh sj

. lianxh DID, m   // Markdown 爱好者的惊喜
```

&emsp;

&emsp;
![](https://fig-lianxh.oss-cn-shenzhen.aliyuncs.com/Lianxh_装饰黄线.png)

### 4. 示例
```stata
. lianxh        // 呈现 Stata 资源链接和常用网址
```
![](https://fig-lianxh.oss-cn-shenzhen.aliyuncs.com/20201126171249.png)


```stata
. lianxh all 
```

![](https://fig-lianxh.oss-cn-shenzhen.aliyuncs.com/20201126171219.png)

```stata
. lianxh DID
```
![](https://fig-lianxh.oss-cn-shenzhen.aliyuncs.com/20201126171337.png)

![](https://fig-lianxh.oss-cn-shenzhen.aliyuncs.com/Lianxh_装饰黄线.png)

```stata
. lianxh 面板 门槛 +  
```
![](https://fig-lianxh.oss-cn-shenzhen.aliyuncs.com/20201126171454.png)

```stata
. lianxh 结果输出, weixin
```
![](https://fig-lianxh.oss-cn-shenzhen.aliyuncs.com/20201126171728.png)

## 4. 宝贵建议

`lianxh` 还不完善，大家使用过程中若发现 bugs，或有好的建议，可以通过两种途径反馈 (我们会定期抽取部分幸运者，赠送连享会直播课程)：
- 发邮件至 <StataChina@163.com>
- 在线提交 (1-2 分钟即可)：[我的建议和问题](https://www.wjx.cn/jq/98072236.aspx)

![](https://fig-lianxh.oss-cn-shenzhen.aliyuncs.com/Lianxh_装饰黄线.png)

&emsp; 

&emsp; 
