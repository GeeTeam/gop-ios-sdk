//
//  ButtonEX.h
//  gt-captcha3-ios-example
//
//  Created by NikoXu on 04/08/2017.
//  Copyright © 2017 Xniko. All rights reserved.
//

#import <UIKit/UIKit.h>

@import GT3Captcha;

@interface GT3CaptchaEX : NSObject

@property (nonatomic, strong) GT3CaptchaManager *manager;

@property (nonatomic, assign) GT3CaptchaState captchaState;

- (instancetype)initWithApi1:(NSString *)api1 api2:(NSString *)api2 timeout:(NSTimeInterval)timeout;

- (void)registerGT3Captcha;
- (void)startGT3Captcha;
- (void)stopGT3Captcha;
- (void)resetGT3Captcha;

@end
