//
//  MainViewController.m
//  GTMPhone
//
//  Created by NikoXu on 21/09/2017.
//  Copyright © 2017 geetest. All rights reserved.
//

#import "MainViewController.h"
#import "PhoneNumViewController.h"

@interface MainViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *welcomeTitle;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@end

@implementation MainViewController

- (IBAction)login:(id)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PhoneNumViewController *vc = [sb instantiateViewControllerWithIdentifier:@"phoneNum"];
    vc.type = @"login";
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)registerAccount:(id)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PhoneNumViewController *vc = [sb instantiateViewControllerWithIdentifier:@"phoneNum"];
    vc.type = @"register";
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.welcomeTitle.layer.opacity = .0f;
    self.logoImageView.center = CGPointMake(self.view.center.x - 12, self.view.center.y - 12);
    self.backgroundImageView.frame = self.view.frame;
    
    CGFloat bias = 190 + 36;
    CGRect rect = CGRectMake(0, -bias, self.view.bounds.size.width, self.view.bounds.size.height);
    
    [UIView animateWithDuration:1.0 delay:0.7 usingSpringWithDamping:0.6 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.logoImageView.frame = CGRectMake(24, 32, 123, 31);
        self.backgroundImageView.frame = rect;
    } completion:nil];
    
    [UIView animateWithDuration:0.3 delay:1.2 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.welcomeTitle.layer.opacity = 1.f;
    } completion:nil];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
