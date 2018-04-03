//
//  ButtonEX.m
//  GOPPhone
//
//  Created by NikoXu on 04/08/2017.
//  Copyright © 2017 Xniko. All rights reserved.
//

#import "GT3CaptchaEX.h"

@implementation GT3CaptchaEX

- (GT3CaptchaState)captchaState {
    return self.manager.captchaState;
}

- (instancetype)initWithApi1:(NSString *)api1 api2:(NSString *)api2 timeout:(NSTimeInterval)timeout {
    self = [super init];
    
    if (self) {
        _manager = [[GT3CaptchaManager alloc] initWithAPI1:api1 API2:api2 timeout:timeout];
#ifdef DEBUG
        [_manager disableSecurityAuthentication:YES];
#endif
        [_manager useVisualViewWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
        
//        [self registerGT3Captcha];
    }
    
    return self;
}

- (void)registerGT3Captcha {
    [self.manager registerCaptcha:nil];
}

- (void)startGT3Captcha {
    [self.manager startGTCaptchaWithAnimated:YES];
}

- (void)stopGT3Captcha {
    [self.manager stopGTCaptcha];
}

- (void)resetGT3Captcha {
    [self.manager resetGTCaptcha];
}

@end
