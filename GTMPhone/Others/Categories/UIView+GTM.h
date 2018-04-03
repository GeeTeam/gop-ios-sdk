//
//  UIView+GTM.h
//  GTMPhone
//
//  Created by NikoXu on 29/09/2017.
//  Copyright © 2017 geetest. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (GTM)

- (void)gtm_shake:(int)times witheDelta:(CGFloat)delta speed:(NSTimeInterval)interval completion:(void (^)(void))handler;

@end
