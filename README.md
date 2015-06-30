#corner

# 概述
这是概述内容

## 介绍
这是介绍内容

#API文档
[http://sinaweibosdk.github.io/weibo_ios_sdk/index.html](http://sinaweibosdk.github.io/weibo_ios_sdk/index.html)

#常见问题 FAQ
[https://github.com/sinaweibosdk/weibo_ios_sdk/blob/master/FAQ.md](https://github.com/sinaweibosdk/weibo_ios_sdk/blob/master/FAQ.md)

# 名词解释
| 名词        | 注解    | 
| --------    | :-----  | 
| AppKey      | 分配给每个第三方应用的 app key。用于鉴权身份，显示来源等功能。|
| RedirectURI | 应用回调页面，可在新浪微博开放平台->我的应用->应用信息->高级应用->授权设置->应用回调页中找到。|
| AccessToken | 表示用户身份的 token，用于微博 API 的调用。| 
| Expire in   | 过期时间，用于判断登录是否过期。| 

# 功能列表
### 1. 认证授权
为开发者提供 Oauth2.0 授权认证，并集成 SSO 登录功能。
### 2. 微博分享
从第三方应用分享信息到微博，目前只支持通过微博官方客户端进行分享。
### 3. 登入登出
微博登入按钮主要是简化用户进行 SSO 登陆，实际上，它内部是对 SSO 认证流程进行了简单的封装。  
微博登出按钮主要提供一键登出的功能，帮助开发者主动取消用户的授权。
### 4.OpenAPI通用调用
OpenAPI通用调用接口，帮助开发者访问开放平台open api(http://open.weibo.com/wiki/微博API)
此外，还提供了一系列封装了open api调用的接口，方便开发者使用。
### 5. 社会化评论服务、原生关注组件
提供社会化评论按钮和原生关注按钮，简化用户进行关注以及评论的流程。
# 适用范围
使用此SDK需满足以下条件:  

![simple1](https://cloud.githubusercontent.com/assets/5022872/5718203/39fcbaf6-9b46-11e4-8bf4-f17fd08fc551.png)

![simple2](https://cloud.githubusercontent.com/assets/5022872/5718202/39f8a7f4-9b46-11e4-9060-8c8fb0350389.png)

## 如何运行

1. 用XCode打开AVOSDemo.xcodeproj，选择运行的scheme和设备，点击运行按钮或菜单`Product`->`Run`或快捷键`Command(⌘)`+`r`就可以运行此示例

2. 如果你想获取最新发布的SDK，你也可以使用`cocoapods`,将`Frameworks`目录下的文件删除，然后在终端执行代码:

pod install

不出问题的话 1分钟即可完成所有设置, 并生成名为`AVOSDemo.xcworkspace`的Xcode工作空间，用Xcode打开它，按第1种介绍的方法运行即可

----

## 使用说明

### 替换 App 信息

示例使用的是公共的 app id 和 app key，您可以在`AppDelegate.m`修改成您自己的应用 id 和 key。

### 查看源码
您可以在Xcode中看到本项目的所有代码. 也可以在App运行和操作中更直观的查看.

1. 每一例子列表右上角都有`查看源码`的按钮, 可以直接查看本组例子的源码. 
2. 每一个例子运行界面也会直接显示当前列子的代码片段.  

![image](OtherSource/demorun.png)

### 编译警告
代码中有一些人为添加的编译,是为了引起您足够的重视, 如果觉得没问题可以删除掉该行

### 添加Demo

1. 新建一个继承`Demo`的类, 文件位置在项目的`AVOSDemo`文件夹
2. 在.m里的`@end`前加一句`MakeSourcePath` 用来在编译时生成返回这个文件的方法
3. 加一个demo方法. 方法必须以demo开头, 且必须是严格按照骆驼命名法, 否则方法名现实可能会有问题

----
## 其他

其他内容
