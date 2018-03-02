//
//  ResultViewController.m
//  GTMPhone
//
//  Created by NikoXu on 21/09/2017.
//  Copyright © 2017 geetest. All rights reserved.
//

#import "ResultViewController.h"

@interface UIView (Conveniences)

@property (nonatomic, readonly, assign) CGFloat height;
@property (nonatomic, readonly, assign) CGFloat width;

@property (nonatomic, readonly, assign) CGSize size;

@end

@implementation UIView (Conveniences)

- (CGSize)size {
    return self.bounds.size;
}

- (CGFloat)height {
    return self.bounds.size.height;
}

- (CGFloat)width {
    return self.bounds.size.width;
}

@end

@interface ResultViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *resultImageView;
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;

@end

@implementation ResultViewController

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        if (_delegate && [_delegate respondsToSelector:@selector(resultVCDidReturn)]) {
            [_delegate resultVCDidReturn];
        }
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.resultImageView.image = [UIImage imageNamed:@"center_purple"];
    
    if ([self.type isEqualToString:@"register"]) {
        self.resultLabel.text = @"注册成功";
    }
    
    if ([self.type isEqualToString:@"login"]) {
        self.resultLabel.text = @"登录成功";
    }
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    UIImageView *imageView1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"left_yellow"]];
    UIImageView *imageView2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"left_cyan"]];
    UIImageView *imageView3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"left_red"]];
    UIImageView *imageView4 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"right_yellow"]];
    UIImageView *imageView5 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"right_orange"]];
    UIImageView *imageView6 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"right_green"]];
    
    CGPoint origin = CGPointMake(self.view.center.x, self.view.center.y - 28 - 14 - self.resultImageView.height/2);
    
    imageView1.center = origin;
    imageView2.center = origin;
    imageView3.center = origin;
    imageView4.center = origin;
    imageView5.center = origin;
    imageView6.center = origin;
    
    [self.view addSubview:imageView1];
    [self.view addSubview:imageView2];
    [self.view addSubview:imageView3];
    [self.view addSubview:imageView4];
    [self.view addSubview:imageView5];
    [self.view addSubview:imageView6];
    
    [self.view bringSubviewToFront:self.resultImageView];
    
    // left
    CGPoint vector1 = CGPointMake(-self.resultImageView.width/2 - imageView1.width/2 - 42, -self.resultImageView.height/2 - imageView1.height/2 - 0);
    CGPoint vector2 = CGPointMake(-self.resultImageView.width/2 - imageView2.width/2 - 27, -self.resultImageView.height/2 + imageView2.height/2 + 16);
    CGPoint vector3 = CGPointMake(-self.resultImageView.width/2 - imageView3.width/2 - 8, -self.resultImageView.height/2 - imageView3.height/2 - 5);
    
    // right
    CGPoint vector4 = CGPointMake(self.resultImageView.width/2 - imageView4.width/2 + 2, -self.resultImageView.height/2 - imageView4.height/2 - 5);
    CGPoint vector5 = CGPointMake(self.resultImageView.width/2 - imageView5.width/2 + 18, -self.resultImageView.height/2 + imageView5.height/2 + 10);
    CGPoint vector6 = CGPointMake(self.resultImageView.width/2 - imageView6.width/2 + 39, -self.resultImageView.height/2 - imageView6.height/2 + 1);
    
    CGPoint destination1 = CGPointMake(origin.x + vector1.x, origin.y + vector1.y);
    CGPoint destination2 = CGPointMake(origin.x + vector2.x, origin.y + vector2.y);
    CGPoint destination3 = CGPointMake(origin.x + vector3.x, origin.y + vector3.y);
    CGPoint destination4 = CGPointMake(origin.x + vector4.x, origin.y + vector4.y);
    CGPoint destination5 = CGPointMake(origin.x + vector5.x, origin.y + vector5.y);
    CGPoint destination6 = CGPointMake(origin.x + vector6.x, origin.y + vector6.y);
    
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        imageView1.center = destination1;
        imageView2.center = destination2;
        imageView3.center = destination3;
        imageView4.center = destination4;
        imageView5.center = destination5;
        imageView6.center = destination6;
    } completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
