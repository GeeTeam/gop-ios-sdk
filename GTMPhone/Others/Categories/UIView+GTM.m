//
//  UIView+GTM.m
//  GTMPhone
//
//  Created by NikoXu on 29/09/2017.
//  Copyright © 2017 geetest. All rights reserved.
//

#import "UIView+GTM.h"

@implementation UIView (GTM)

- (void)gtm_shake:(int)times witheDelta:(CGFloat)delta speed:(NSTimeInterval)interval completion:(void (^)(void))handler {
    [self gtm_shake:times direction:1 currentTimes:0 withDelta:delta speed:interval completion:handler];
}

- (void)gtm_shake:(int)times direction:(int)direction currentTimes:(int)current withDelta:(CGFloat)delta speed:(NSTimeInterval)interval completion:(void (^)(void))completionHandler {
    [UIView animateWithDuration:interval animations:^{
        self.layer.affineTransform = CGAffineTransformMakeTranslation(delta * direction, 0);
    } completion:^(BOOL finished) {
        if (current >= times) {
            [UIView animateWithDuration:interval delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.layer.affineTransform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                if (completionHandler) completionHandler();
            }];
            return ;
        }
        [self gtm_shake:times - 1
              direction:direction * -1
           currentTimes:current + 1
              withDelta:delta
                  speed:interval
             completion:completionHandler];
    }];
}

@end
