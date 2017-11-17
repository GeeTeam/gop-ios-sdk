# GTOnePass iOS SDK

了解产品: [www.geetest.com](www.geetest.com)

需要拖入仓库`SDK`路径下的`GTOnePass.framework`, `GT3Captcha.framework`, `GT3Captcha.bundle`, `TYRENoUISDK.framework` 4个文件

需要同时集成`test-Button`产品

# 概述及资源

## 环境需求

条目	|资源 			
------	|------------	
开发目标|兼容iOS7, 推荐iOS8+		
开发环境|Xcode 8.0	
系统依赖|`Webkit.framework`, `JavascriptCore.framework`
产品依赖|[test-Button](http://docs.geetest.com/install/overview/)
sdk三方依赖|无		

## 资源下载

条目|资源|
-------------	|--------------
SDK下载			|[gop-ios-sdk](http://github.com/GeeTeam/gop-ios-sdk)
错误码			|[Error Code](http://github.com/GeeTeam/gop-ios-sdk/blob/master/SDK/gop-ios-dev-doc.md#errorcode)
产品结构流程  	|[通讯流程](http://docs.geetest.com/onepass/overview/#通讯流程)

# 安装

## 获取SDK

### 下载获取

```
git clone https://github.com/GeeTeam/gop-ios-sdk.git
```
或

```
git clone git@github.com:GeeTeam/gop-ios-sdk.git
```

## 导入SDK并配置环境

1. 如果您是手动添加SDK, 将下载获取的`GTOnePass.framework`, `TYRZNoUISDK.framework`,`GT3Captcha.framework`及`GT3Captcha.bunele`4个文件拖拽到工程中, 确保`Copy items if needed`已被勾选。

	![import](./img/import.png)
	
	请使用`Linked Frameworks and Libraries`方式导入framework。在拖入`GTOnePass.framework`,`TYRZNoUISDK.framework`和`GT3Captcha.framework`到工程时后, 请检查`.framework`是否被添加到`PROJECT -> Build Phases -> Linked Frameworks and Libraries`, 以确保正常编译。
	
	![linkedlibraries](./img/linkedlibraries.png)

2. 针对静态库中的`Category`, 需要在对应target的`Build Settings`->`Other Linker Flags`添加`-ObjC`编译选项。如果依然有问题，再添加`-all_load`。

	![linkerflags](./img/linkerflags.png)

## 配置接口

开发者集成客户端sdk前, 必须先在您的服务器上搭建相应的**服务端SDK**，并配置从[极验后台](https://account.geetest.com/login)获取的`id`和`key`, 并且将配置的用户获取配置的接口`API1`和`API2`放入客户端的初始化方法中。

集成用户需要使用iOS SDK完成提供的以下接口:

1. 配置并初始化
2. 调用校验接口
3. 处理结果
4. 处理错误

>集成代码参考下方的**代码示例**

## 编译并运行你的工程

编译你的工程, 体验全新的极验onepass产品！

![build](./img/build.png)

轻轻点击集成的验证按钮, 如此自然, 如此传神。

# 代码示例

## 初始化与校验

在工程中的文件头部倒入静态库态库`GTOnePass.framework`

```objc
#import <GTOnePass/GOPManager.h>
#import <GT3Captcha/GT3Captcha.h>
```

### 初始化
	
初始化验证管理器`GOPManager`的实例, 在相应的控制页初始化方法中对`GOPManager `实例调用注册方法以获得注册数据:
	
```objc
//网站主部署的用于ONEPASS的register接口
#define config_url @"***"
//网站主部署的ONEPASS的校验接口
#define verify_url @"***"
...
	
- (GOPManager *)manager {
    if (!_manager) {
        _manager = [[GOPManager alloc] initWithCustomID:@"<---我应该为32位哟--->" configUrl:config_url verifyUrl:verify_url timeout:10.0];
    }
    
    return _manager;
}
	
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self.manager bind];
    }
    return self;
}
```
	
### 进行onepass校验
	
初始化和注册完成后, 自定义方法`verifyPhoneNum:`来进行对本机号码校验:
	
```objc
- (void)verifyPhoneNum:(NSString *)num {
    
    //自定义规则检测输入的手机号码的合法性
    if (![self checkPhoneNumFormat:num]) return;
    
    // TODO UI相关操作
    
    // TODO 调用onepass校验接口
	[self.manager verifyPhoneNum:num completion:^(NSDictionary *dict) {
        ...
    } failure:^(NSError *error) {
        ...
    }];
}
```

## 处理校验结果以及错误

onepass在校验成功后, 返回的onepass结果, 如果失败通过短信验证码作为补充

```objc
[self.manager verifyPhoneNum:num completion:^(NSDictionary *dict) {
    NSString *type = [dict objectForKey:@"type"];
    if ([type isEqualToString:@"gw"]) {// No sense Success
        // TODO onepass成功
    }
    else {
        // TODO onepass失败, 使用短信验证作为补充
        
    }
} failure:^(NSError *error) {
    [self.nextButton gtm_removeIndicator];
    if (error.code != -999) {// 忽略-999
      // TODO 处理错误
    }
    NSLog(@"error: %@", error);
}];
```

>更加完整的示例代码请参考`GTMPhone`工程
