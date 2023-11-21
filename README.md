> `lianxh` Command: Viewing Tweets of [lianxh.cn](https://www.lianxh.cn) in Stata (**update:** `2023/11/17 23:20`)

[中文版](https://github.com/arlionn/lianxh/blob/main/readme_cn.md)

## 1. Introduction

`lianxh` allows users to conveniently search for tweets published on the LianXiang homepage from the Stata window using keywords. Additionally, it can list commonly used Stata resource links, including the Stata official website, Stata official [FAQs](https://www.stata.com/support/faqs/), the Stata forum ([Statalist](https://www.statalist.org/forums/)), [Stata Journal](https://www.lianxh.cn/news/12ffe67d8d8fb.html); [Stata Tutorials](https://www.lianxh.cn/search.html?s=%E6%95%99%E7%A8%8B), [Reproducible Paper Data](https://www.lianxh.cn/news/e87e5976686d5.html), and more.

## 2. Installation

```stata
ssc install lianxh, replace
```
Your can type `which lianxh` to check if the newest version is installed:
```stata
. which lianxh
D:\stata\plus\l\lianxh.ado
*! version 1.2  16nov2023  
*! version 1.1  11apr2021
*! Yujun Lian  arlionn@163.com
```


### Help documents
There are many examples in help file:
```stata
. help lianxh     // English version
. help lianxh_cn  // Chinese version
```

## 3. Some common examples 

```stata
. lianxh DID    // Display tweets containing the keyword 'DID'

. lianxh DID, hot(10)   // Tweets containing the keyword 'DID,' top 10 by views

. lianxh DID 倍分 双差分 // Multiple keyword query (union)

. lianxh DID+多期        // Multiple keyword query (intersection)

. lianxh DID, md        // Output text in Markdown format

. lianxh, links         // Display Stata resource links and common URLs
```
