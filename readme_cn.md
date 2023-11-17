 
> `lianxh` 命令：在 Stata 里看推文 (**update:** `2023/11/17 23:20`)

[English Version](https://github.com/arlionn/lianxh/blob/main/README.md)

## 1. 简介

`lianxh` 命令可以帮助用户便捷地在 Stata 中检索相关推文，同时，也可以列出常用的 Stata 资源链接。

## 2. 安装

有两种方法可以安装 `lianxh` 的最新版本。

### 方法1
第一种方法是使用 `cnssc` 命令：
```stata
ssc install cnssc, replace
cnssc install lianxh, replace
```
你可以输入 which lianxh 来检查是否安装了最新版本：
```stata
. which lianxh
D:\stata\plus\l\lianxh.ado
*! version 1.2  16nov2023  
*! version 1.1  11apr2021
*! Yujun Lian  arlionn@163.com
```
### 方法2
在 Stata 命令窗口中贴入如下命令即可安装：
```stata
net install lianxh, from("https://gitee.com/arlionn/lianxh/raw/master/src/") replace  
```

### 帮助文件
```stata
. help lianxh     // 英文版
. help lianxh_cn  // 中文版
```

## 3. 常用命令
```stata
. lianxh DID    // 呈现包含 DID 关键词的推文

. lianxh DID, hot(10)   // 包含关键词 'DID'，浏览量最大的 10 篇推文

. lianxh DID 倍分 双差分 // 多个关键词查询 (并集)

. lianxh DID+多期        // 多个关键词查询 (交集)

. lianxh DID, md        // 输出 Markdown 格式的文本

. lianxh, links         // 呈现 Stata 资源链接和常用网址
```

### 4. 部分使用效果展示
```stata
lianxh DID, hot(5)
lianxh DID 多期 +, weixin nocat
lianxh 刘 王 张 胡, f(a) md0 hot(10) nocat
```
![lianxh命令范例001](https://fig-lianxh.oss-cn-shenzhen.aliyuncs.com/lianxh%E5%91%BD%E4%BB%A4%E8%8C%83%E4%BE%8B001.png)

![lianxh命令范例002](https://fig-lianxh.oss-cn-shenzhen.aliyuncs.com/lianxh%E5%91%BD%E4%BB%A4%E8%8C%83%E4%BE%8B002.png)

![lianxh命令范例003](https://fig-lianxh.oss-cn-shenzhen.aliyuncs.com/lianxh%E5%91%BD%E4%BB%A4%E8%8C%83%E4%BE%8B003.png)
