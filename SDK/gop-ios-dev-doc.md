[TOC]

**GTOnePass iOS API Document**

2017 11.29 edited

# GOPManager

GTOnePass的主要外部调用接口

## Property

### delegate

OnePass代理

**Declaration**

```
@property (nonatomic, weak) id<GOPManagerDelegate> delegate;
```

### diagnosisStatus

诊断当前网络OnePass是否可用。如果可用返回`YES`,否则`NO`。

**Declaration**

```
@property (nonatomic, readonly, assign) BOOL diagnosisStatus;
```

## Method

### initWithCustomID:verifyUrl:timeout:

初始化并返回一个新的`GOPManager`实例对象

**Declaration**

```
- (instancetype)initWithCustomID:(NSString *)customID verifyUrl:(NSString *)verifyUrl timeout:(NSTimeInterval)timeout;
```

**Parameters**

Param		|Description
----------|---------------	
customID 	|产品id, 请在官网注册获取
verifyUrl	|onepass校验接口地址, 网站主使用onepass的服务端sdk搭建
timeout	|本地各请求的超时时间

**Return Value**

一个新的`GOPManager`实例对象

**Seealso**

[OnePass注册](http://account.geetest.com/)

[OnePass文档](http://docs.geetest.com/onepass/)

### verifyPhoneNum:withCaptchaValidate:completion:failure:

初始化并返回一个新的规定了尺寸的`GOPManager`实例对象

**Declaration**

```
- (void)verifyPhoneNum:(NSString *)phoneNum withCaptchaValidate:(NSString *)validate completion:(GOPCompletion)completion failure:(GOPFailure)failure;
```

**Discussion**

OnePass需要设备的数据网络支持。如果OnePass失败, 会使用短信进行补充当前的场景。极验提供默认的短信服务, 开发者也可通过接口关闭默认的短信行为, 切换为自己的短信系统。

目前仅支持大陆地区的手机号。SDK内部默认正则规则为`'^1([3-9])\\d{9}$'`。

**Parameters**

Param		|Description
----------|---------------	
phoneNum 	|手机号码, 11位字符串, 仅支持大陆三大运营商的手机号
validate	|32位字符串, 验证`test-button`中返回的结果, 为`gtCaptcha:didReceiveCaptchaCode:result:message:`代理方法返回的`result`中的`geetest_validate`键值
completion|OnePass结果回调, 通过`@“type”`返回结果的状态, 具体返回实例见下方示例
failure	|OnePass失败回调, 返回网络层面或者业务层面的错误

- completion示例

	1. OnePass成功
	
		```
		{
		    content = 4730e454f19be6970f9bbb951479cad7;//校验数据
		    duration = "2.581";//onepass耗时
		    "process_id" = 59a4aa4e1402caca858f7ed950edbcdc;//流水号
		    result = 0;//校验结果, 0为成功
		    type = onepass;//校验类型, 可为onepass或sms, 如果为sms者需要通过短信进行补充
		}
		```
	2. OnePass失败, 使用备用的短信进行验证
	
		```
		{
		    GOPCode = "-500";//错误码
		    GOPDescription = ...//走短信的详细描述
		    content = success;// 短信发送成功
		    "custom_id" = 7591d0f44d4c265c8441e99c748d936b;//当前的产品id
		    "message_id" = 151158023459762289;//message_id
		    "process_id" = 54bfe09afc80b834fb13b34234564017;//流水号
		    result = 0;//成功状态, 0为成功
		    type = sms;//校验类型, 可为onepass或sms, 如果为sms者需要通过短信进行补充
		}
		```

**Seealso**

`- (BOOL)shouldUseDefaultSMSAPI:(GOPManager *)manager;`

[Error Code清单](#errorcode)

# Protocol

## GOPManagerDelegate

`GOPManager`相关操作, 操作验证过程中的请求行为

### gtOnePass:willRequestConfig:withReplacedHandler:

修改OnePass的configURL上的请求

**Declaration**

```
- (void)gtOnePass:(GOPManager *)manager willRequestConfig:(NSURLRequest *)originalRequest withReplacedHandler:(void (^)(NSURLRequest * request))replacedHandler;
```

**Discussion**

不支持在子线程操作

**Parameters**

Param		|Description	
----------|------------	
manager 	|验证管理器		
originalRequest|原始请求
replacedHandler|返回修改后请求回调

### gtOnePass:didReceiveConfig:withError;

处理从configURL收到的返回, 并作自定义解析

**Declaration**

```
- (NSDictionary *)gtOnePass:(GOPManager *)manager didReceiveConfig:(NSDictionary *)dict withError:(NSError *)error;
```

**Discussion**

不支持在子线程操作

**Parameters**

Param		|Description	
----------|------------	
manager 	|验证管理器		
dict		|接收到的返回数据, 以JSON格式解析
error		|请求中的错误

#### gtOnePass:willRequestVerify:withReplacedHandler:

修改OnePass结果校验的请求

**Declaration**

```
- (void)gtOnePass:(GOPManager *)manager willRequestVerify:(NSURLRequest *)originalRequest withReplacedHandler:(void (^)(NSURLRequest * request))replacedHandler;
```

**Discussion**

不支持在子线程操作

**Parameters**

Param		|Description	
----------|------------	
manager 	|验证管理器		
originalRequest|原始请求
replacedHandler|返回修改后请求回调

### gtOnePass:didReceiveVerify:withError:

处理OnePass校验结果

**Declaration**

```
- (void)gtOnePass:(GOPManager *)manager didReceiveVerify:(NSData *)data withError:(NSError *)error;
```

**Parameters**

Param		|Description	
----------|------------	
manager 	|验证管理器		
data		|接收到的返回数据
error		|请求中的错误

### shouldUseDefaultSMSAPI:

通知代理是否使用默认的短信接口

**Declaration**

```
- (BOOL)shouldUseDefaultSMSAPI:(GOPManager *)manager;
```

**Parameters**

Param		|Description	
----------|------------	
manager 	|验证管理器

### gtOnePass:willRequestSMS:withReplacedHandler:

修改默认发送短信的请求

**Declaration**

```
- (void)gtOnePass:(GOPManager *)manager willRequestSMS:(NSURLRequest *)originalRequest withReplacedHandler:(void (^)(NSURLRequest * request))replacedHandler;
```

**Discussion**

只有当`shouldUseDefaultSMSAPI:`返回`YES`后, 此方法才会被调用

**Parameters**

Param		|Description	
----------|------------	
manager 	|验证管理器		
originalRequest|原始请求
replacedHandler|返回修改后请求回调

### gtOnePass:didReceiveSMS:withError:

处理发送短信验证接口的返回

**Declaration**

```
- (void)gtOnePass:(GOPManager *)manager didReceiveSMS:(NSData *)data withError:(NSError *)error;
```

**Discussion**

只有当`shouldUseDefaultSMSAPI:`返回`YES`后, 此方法才会被调用

**Parameters**

Param		|Description	
----------|------------	
manager 	|验证管理器		
data		|接收到的返回数据
error		|请求中的错误

# ErrorCode

## OnePass

`OnePass`产品的业务错误代码

ErrorCode	|Description	
----------|------------	
-200 		|客户端错误		
-300		|网络连接中的错误
-500		|客户端错误

## test-Button

`test-Button`产品的业务错误代码

ErrorCode	|Description	
----------|------------	
-10 		|验证被封禁		
-20			|尝试过多
-30			|验证配置, 传入的参数不合法或为空, challenge只能使用一次
-40			|配置问题, 传入的参数不合法或为空
-50			|极验服务器响应异常, gettype.php
-51			|极验服务器响应异常, get.php
-52			|极验服务器响应异常, ajax.php
-70			|接口调用错误, 未配置参数或设置代理方法
-71			|缺失`GT3Captcha.bundle`文件
-80			|接口调用错误, 未设置`GT3CaptcaManagerDelegate`代理方法

## Cocoa Error

可能遇见的有

### NSURLErrorDomain

ErrorCode	|Description	
----------|------------	
-999		|`NSURLErrorCancelled`用户操作导致的请求中断, 一般忽略处理
-1000		|`NSURLErrorBadURL`URL异常
-1001 		|`NSURLErrorTimedOut`请求超时	
-1002		|`NSURLErrorUnsupportedURL `不支持的URL
-1003		|`NSURLErrorCannotFindHost `无法找到主机
-1004		|`NSURLErrorCannotConnectToHost `无法连接到服务器
-1005		|`NSURLErrorNetworkConnectionLost `网络丢失, 一般弱网或者网络突然中断导致
-1006		|`NSURLErrorDNSLookupFailed `DNS查询失败
-1007		|`NSURLErrorHTTPTooManyRedirects `过多的请求跳转, 服务器返回过多的302
-1008		|`NSURLErrorResourceUnavailable `访问的资源不可用
-1009		|`NSURLErrorNotConnectedToInternet `未连接到互联网
-1010		|`NSURLErrorRedirectToNonExistentLocation `重定向到不存在的地址
-1011		|`NSURLErrorBadServerResponse `服务器无响应
-1012		|`NSURLErrorUserCancelledAuthentication `客户端取消了安全认证, 或者证书不匹配或服务端不支持ssl和tls
-1013		|`NSURLErrorUserAuthenticationRequired `客户端要求安全认证, 服务端不支持ssl或tls
-1102		|`NSURLErrorNoPermissionsToReadFile `无资源访问权限, 一般为`challenge`等参数有误, `challenge`只可被用来请求一次, 失效后可能会遇到该问题
-1200		|`NSURLErrorSecureConnectionFailed `创建安全连接失败
-1201		|`NSURLErrorServerCertificateHasBadDate `服务端证书异常
-1202		|`NSURLErrorServerCertificateUntrusted `服务端证书不可信
-1203		|`NSURLErrorServerCertificateHasUnknownRoot `服务端使用未知的根证书

### Other

ErrorCode	|Description	
----------|------------	
3840		|JSON解析故障, 请检查返回的是否为合法的JSON格式

>更多详情请访问[URL Loading System Error Codes](https://developer.apple.com/documentation/foundation/1508628-url_loading_system_error_codes)文档及相关苹果官方文档