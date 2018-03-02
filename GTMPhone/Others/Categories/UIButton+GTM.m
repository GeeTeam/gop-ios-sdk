//
//  UIButton+GTM.m
//  GTMPhone
//
//  Created by NikoXu on 22/09/2017.
//  Copyright © 2017 geetest. All rights reserved.
//

#import "UIButton+GTM.h"

@implementation UIButton (GTM)

- (void)gtm_showIndicator {
    [self setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[UIActivityIndicatorView class]]) {
            [obj removeFromSuperview];
        }
    }];
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [indicatorView setHidesWhenStopped:YES];
    [indicatorView stopAnimating];
    [indicatorView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:indicatorView];
    
    NSLayoutConstraint *constraintX = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:indicatorView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    NSLayoutConstraint *constraintY = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:indicatorView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    [self addConstraints:@[constraintX, constraintY]];
    
    [indicatorView startAnimating];
}

- (void)gtm_removeIndicator {
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.titleLabel setHidden:NO];
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[UIActivityIndicatorView class]]) {
            UIActivityIndicatorView *indicator = (UIActivityIndicatorView *)obj;
            [indicator stopAnimating];
            [indicator removeFromSuperview];
        }
    }];
}

@end
