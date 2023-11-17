 
> `lianxh` 命令：在 Stata 里看推文 (**update:** `2023/11/17 23:20`)

[English Version]()

## 1. 简介

`lianxh` 命令可以帮助用户便捷地在 Stata 中检索相关推文，同时，也可以列出常用的 Stata 资源链接。

## 2. 安装

在 Stata 命令窗口中贴入如下命令即可安装：

```stata
net install lianxh, from("https://gitee.com/arlionn/lianxh/raw/master/src/") replace  
```

查看帮助文件：
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

