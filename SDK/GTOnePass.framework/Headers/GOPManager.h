//
//  GOPManager.h
//  GOPPhone
//
//  Created by NikoXu on 07/09/2017.
//  Copyright © 2017 geetest. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GOPManagerDelegate;

typedef NS_ENUM(NSInteger, GOPPhoneNumEncryptOption) {
    GOPPhoneNumEncryptOptionNone = 0,   // none
    GOPPhoneNumEncryptOptionSha256      // sha256
};

typedef void(^GOPCompletion)(NSDictionary *dict);
typedef void(^GOPFailure)(NSError *error);

@interface GOPManager : NSObject

@property (nonatomic, weak) id<GOPManagerDelegate> delegate;

/**
 Diagnosis current network status.
 If OnePass could work, `diagnosisStatus` return YES.
 
 @discussion
 In the extreme situation, `diagnosisStatus` isn't reliable.
 */
@property (nonatomic, readonly, assign) BOOL diagnosisStatus;

/**
 Return current phone number.
 If encrypted, return encrypted phone number.
 
 @discussion
 Before OnePass callback, `currentPhoneNum` return
 original phone number.
 */
@property (nonatomic, readonly, copy) NSString *currentPhoneNum;

/**
 Phone number Encryption Option.
 If encrypted, it will be hard to debug. We recommend developers not to use this option.
 If you want use this option, you should register this feature through us first.
 */
@property (nonatomic, assign) GOPPhoneNumEncryptOption phoneNumEncryptOption;

/**
 Initializes and returns a newly allocated GOPManager object.
 
 @discussion Register customID from `geetest.com`, and configure your verifyUrl
             API base on Server SDK. Check Docs on `docs.geetest.com`. If OnePass
             fail, GOPManager will request SMS URL that you set.
 @param customID custom ID, nonull
 @param verifyUrl verify URL, nonull
 @param timeout timeout interval
 @return A initialized GOPManager object.
 */
- (instancetype)initWithCustomID:(NSString *)customID verifyUrl:(NSString *)verifyUrl timeout:(NSTimeInterval)timeout;

/**
 Verify phone number through OnePass.
 See a sample result from `https://github.com/GeeTeam/gop-ios-sdk/blob/master/SDK/gop-ios-dev-doc.md#verifyphonenumcompletionfailure`
 
 @discussion Country Code `+86` Only. Regex rule `^1([3-9])\\d{9}$`.
             If you don't want to use validate, you should modify customID configuration
             by contacting geetest stuff first.
             QQ:2314321393 or E-mail: contact@geetest.com

 @param phoneNum phone number, nonull
 @param validate GT3Captcha validate, get this value from result[@"geetest_validate"]
 @param completion completion handler
 @param failure failure handler
 */
- (void)verifyPhoneNum:(NSString *)phoneNum withCaptchaValidate:(NSString *)validate completion:(GOPCompletion)completion failure:(GOPFailure)failure;

@end

/**
 Manager related to the operation of a verification that handle request
 directly to the delegate.
 */
@protocol GOPManagerDelegate <NSObject>

@optional

/**
 Replace verify request.
 
 @param manager GOPManager instance
 @param originalRequest original request
 @param replacedHandler return replaced request
 */
- (void)gtOnePass:(GOPManager *)manager willRequestVerify:(NSURLRequest *)originalRequest withReplacedHandler:(void (^)(NSURLRequest * request))replacedHandler;

/**
 Did receive data from verify API.
 
 @param manager GOPManager instance
 @param data verify data, NSData format, nullable
 @param error error object, nullable
 
 @discussion
 If use this delegate method, you will not be able to use
 the completion and the failure of `verifyPhoneNum:withCaptchaValidate:completion:failure:`
 */
- (void)gtOnePass:(GOPManager *)manager didReceiveVerify:(NSData *)data withError:(NSError *)error;

/**
 Asks the delegate if you shouldn't use default SMS API

 @param manager GOPManager instance
 @return return NO to disallow default SMS API. Default YES.
 */
- (BOOL)shouldUseDefaultSMSAPI:(GOPManager *)manager;

/**
 Replace SMS request.
 
 @discussion
 Only call this delegate method when shouldUseDefaultSMSAPI: returns YES.
 
 @param manager GOPManager instance
 @param originalRequest original request
 @param replacedHandler return replaced request
 */
- (void)gtOnePass:(GOPManager *)manager willRequestSMS:(NSURLRequest *)originalRequest withReplacedHandler:(void (^)(NSURLRequest * request))replacedHandler;

/**
 Did receive data from SMS API.
 
 @discussion
 Only call this delegate method when shouldUseDefaultSMSAPI: returns YES.
 
 @param manager GOPManager instance
 @param data SMS data, NSData format, nullable
 @param error error object, nullable
 */
- (void)gtOnePass:(GOPManager *)manager didReceiveSMS:(NSData *)data withError:(NSError *)error;

@end
