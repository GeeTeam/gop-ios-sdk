//
//  GOPManager.h
//  GOPPhone
//
//  Created by NikoXu on 07/09/2017.
//  Copyright © 2017 geetest. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GTOPManagerDelegate;

typedef void(^GOPCompletion)(NSDictionary *dict);
typedef void(^GOPFailure)(NSError *error);

@interface GOPManager : NSObject

@property (nonatomic, weak) id<GTOPManagerDelegate> delegate;

/**
 Diagnosis current network status. If OnePass could work, `diagnosisStatus` return YES.
 */
@property (nonatomic, readonly, assign) BOOL diagnosisStatus;

/**
 Initializes and returns a newly allocated GOPManager
 object with the specified frame rectangle
 
 @discussion Register customID from `geetest.com`, and configure your
             configUrl/verifyUrl API base on Server SDK. Check Docs on `docs.geetest.com`. If OnePass fail, GOPManager will
             request SMS URL that you set.
 @param customID custom ID, nonull
 @param configUrl configuration URL, nonull
 @param verifyUrl verify URL, nonull
 @param timeout timeout interval
 @return A initialized GOPManager object.
 */
- (instancetype)initWithCustomID:(NSString *)customID configUrl:(NSString *)configUrl verifyUrl:(NSString *)verifyUrl timeout:(NSTimeInterval)timeout;

/**
 Bind GOPManager to ViewController.
 */
- (void)bind;

/**
 Verify phone number through OnePass.

 @param phoneNum phone number
 @param completion completion handler
 @param failure failure handler
 */
- (void)verifyPhoneNum:(NSString *)phoneNum completion:(GOPCompletion)completion failure:(GOPFailure)failure;

/**
 Unbind GOPManager.
 */
- (void)unbind;

@end

/**
 * Manager related to the operation of a verification that handle request
 * directly to the delegate.
 */
@protocol GTOPManagerDelegate <NSObject>

@optional

/**
 Replace config request

 @param manager GOPManager instance
 @param originalRequest original request
 @param replacedHandler return replaced request
 */
- (void)gtOnePass:(GOPManager *)manager willRequestConfig:(NSURLRequest *)originalRequest withReplacedHandler:(void (^)(NSURLRequest * request))replacedHandler;

/**
 Did receive data from config API, and parse dict callback
 
 @param manager GOPManager instance
 @param dict config data, NSDictionary format, nullable
 @param error error object, nullable
 @return return config parameters
 */
- (NSDictionary *)gtOnePass:(GOPManager *)manager didReceiveConfig:(NSDictionary *)dict withError:(NSError *)error;

/**
 Replace verify request
 
 @param manager GOPManager instance
 @param originalRequest original request
 @param replacedHandler return replaced request
 */
- (void)gtOnePass:(GOPManager *)manager willRequestVerify:(NSURLRequest *)originalRequest withReplacedHandler:(void (^)(NSURLRequest * request))replacedHandler;

/**
 Did receive data from verify API
 
 @param manager GOPManager instance
 @param data verify data, NSData format, nullable
 @param error error object, nullable
 */
- (void)gtOnePass:(GOPManager *)manager didReceiveVerify:(NSData *)data withError:(NSError *)error;

/**
 Asks the delegate if you shouldn't use default SMS API

 @param manager GOPManager instance
 @return return NO to disallow default SMS API. Default YES.
 */
- (BOOL)shouldUseDefaultSMSAPI:(GOPManager *)manager;

/**
 Replace SMS request
 
 @discussion
 Only call this delegate method when shouldUseDefaultSMSAPI: returns YES.
 
 @param manager GOPManager instance
 @param originalRequest original request
 @param replacedHandler return replaced request
 */
- (void)gtOnePass:(GOPManager *)manager willRequestSMS:(NSURLRequest *)originalRequest withReplacedHandler:(void (^)(NSURLRequest * request))replacedHandler;

/**
 Did receive data from SMS API
 
 @discussion
 Only call this delegate method when shouldUseDefaultSMSAPI: returns YES.
 
 @param manager GOPManager instance
 @param data SMS data, NSData format, nullable
 @param error error object, nullable
 */
- (void)gtOnePass:(GOPManager *)manager didReceiveSMS:(NSData *)data withError:(NSError *)error;

@end
