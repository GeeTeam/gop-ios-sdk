//
//  PhoneNumViewController.m
//  GTMPhone
//
//  Created by NikoXu on 21/09/2017.
//  Copyright © 2017 geetest. All rights reserved.
//

#import "PhoneNumViewController.h"
#import "VerifySMSViewController.h"
#import "ResultViewController.h"

#import "UIButton+GTM.h"
#import "UIView+GTM.h"
#import "TipsView.h"

@import GTOnePass;

//网站主部署的用于OnePass注册的接口
#define config_url @"http://www.geetest.com/demo/gt/register-fullpage"
//网站主部署的ONEPASS的校验接口
#define verify_url @"http://onepass.geetest.com/check_gateway.php"

@interface PhoneNumViewController () <UITextFieldDelegate, SMSCodeDelegate, ResultVCDelegate>

@property (weak, nonatomic) IBOutlet UITextField *phoneNumTextField;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;

@property (nonatomic, strong) NSString *message_id;

@property (nonatomic, strong) GOPManager *manager;

@property (nonatomic, strong) UIAlertController *alertController;

@end

@implementation PhoneNumViewController

- (IBAction)back:(id)sender {
    if ([self.phoneNumTextField canResignFirstResponder]) {
        [self.phoneNumTextField resignFirstResponder];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)nextStep:(id)sender {
    [self verifyPhoneNum:self.phoneNumTextField.text];
    if ([self.phoneNumTextField canResignFirstResponder]) {
        [self.phoneNumTextField resignFirstResponder];
    }
}

- (GOPManager *)manager {
    if (!_manager) {
        _manager = [[GOPManager alloc] initWithCustomID:@"7591d0f44d4c265c8441e99c748d936b" configUrl:config_url verifyUrl:verify_url timeout:10.0];
        //"63289cec84eecde1076eb3fa0d70db77", "7591d0f44d4c265c8441e99c748d936b","19da67fb88d37a63ecf7eba9509a5083","fd2cf5e6589a7ceccbc1cc57f6b299a4"
    }
    
    return _manager;
}

- (void)dealloc {
    [self.manager unbind];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.manager bind];
    
    if ([self.type isEqualToString:@"login"]) {
        self.titleLabel.text = @"请登录";
    }
    
    if ([self.type isEqualToString:@"register"]) {
        self.titleLabel.text = @"请注册";
    }
    
    if ([self.phoneNumTextField canBecomeFirstResponder]) {
        [self.phoneNumTextField becomeFirstResponder];
    }
    self.phoneNumTextField.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.nextButton gtm_removeIndicator];
}

- (void)verifyPhoneNum:(NSString *)num {
    
    if (![self checkPhoneNumFormat:num]) {
        self.phoneNumTextField.text = nil;
        [self.phoneNumTextField gtm_shake:9 witheDelta:2.f speed:0.1 completion:nil];
        [TipsView showTipOnKeyWindow:@"不合法的手机号"];
        return;
    }
    
    if (!self.manager.diagnosisStatus) {
        [TipsView showTipOnKeyWindow:@"OnePass需要您的数据网络支持。如果确认已开启数据网络, 可能是您当前的网络不被支持。"];
        return;
    }
    
    [self.nextButton gtm_showIndicator];
    
    [self.manager verifyPhoneNum:num completion:^(NSDictionary *dict) {
        NSLog(@"completion: %@", dict.description);
        
        NSString *type = [dict objectForKey:@"type"];
        if ([type isEqualToString:@"onepass"]) {// No sense Success, onepass成功, 输入的手机号码和本机的sim一致
            [self.nextButton gtm_removeIndicator];
            
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            ResultViewController *vc = [sb instantiateViewControllerWithIdentifier:@"result"];
            vc.delegate = self;
            vc.type = self.type;
            [self presentViewController:vc animated:YES completion:nil];
        }
        else if ([type isEqualToString:@"sms"]) {// send sms code, onepass失败或发生网络错误
            NSString *code = [dict objectForKey:@"GOPCode"];
            if (code) {
                if (code.integerValue == -300) {
                    [TipsView showTipOnKeyWindow:@"OnePass需要您的数据网络支持。如果确认已开启数据网络, 可能是您当前的网络不被支持。"];
                }
            }
            
            NSString *message_id = [dict objectForKey:@"message_id"];
            NSString *process_id = [dict objectForKey:@"process_id"];
            NSString *custom_id = [dict objectForKey:@"custom_id"];
                
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            VerifySMSViewController *vc = [sb instantiateViewControllerWithIdentifier:@"verifySMS"];
            vc.messageID = message_id;
            vc.processID = process_id;
            vc.customID = custom_id;
            vc.phoneNum = num;
            vc.delegate = self;
            [self presentViewController:vc animated:YES completion:nil];
        }
        else {
            [self.nextButton gtm_removeIndicator];
            NSString *result = [NSString stringWithFormat:@"Onepass故障, 故障信息:\n%@", dict.description];
            [TipsView showTipOnKeyWindow:result fontSize:14.0];
            NSLog(@"error: %@", result);
        }
        
    } failure:^(NSError *error) {
        [self.nextButton gtm_removeIndicator];
        NSString *desc = [NSString stringWithFormat:@"错误信息:\n%@", error.description];
        if (error.code != -999) [TipsView showTipOnKeyWindow:desc fontSize:14.0];// ignore -999
        //发生了错误
        NSLog(@"error: %@", error);
    }];
}

- (BOOL)checkPhoneNumFormat:(NSString *)num {
    /**
     * 手机号码
     * 移动：134[0-8],135,136,137,138,139,147,150,151,152,157,158,159,178,182,183,184,187,188
     * 联通：130,131,132,152,155,156,176,185,186
     * 电信：133,1349,153,173,177,180,181,189
     */
    
    NSString * MOBILE = @"^1([3-8][0-9])\\d{8}$";
    
    /**
     * 中国移动：China Mobile
     * 134[0-8],135,136,137,138,139,147,150,151,152,157,158,159,178,182,183,184,187,188
     */
    
    NSString * CM = @"^1(34[0-8]|(3[5-9]|47|5[0-27-9]|78|8[2-478])\\d)\\d{7}$";
    
    /**
     * 中国联通：China Unicom
     * 130,131,132,152,155,156,176,185,186
     */
    
    NSString * CU = @"^1(3[0-2]|5[256]|76|8[56])\\d{8}$";
    
    /**
     * 中国电信：China Telecom
     * 133,1349,153,173,177,180,181,189
     */
    
    NSString * CT = @"^1((33|53|7[37]|8[019])[0-9]|349)\\d{7}$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    
    if (([regextestmobile evaluateWithObject:num] == YES) ||
        ([regextestcm evaluateWithObject:num] == YES) ||
        ([regextestct evaluateWithObject:num] == YES) ||
        ([regextestcu evaluateWithObject:num] == YES)) {
        return YES;
    }
    else return NO;
}

- (void)smsVCDidSuccess:(NSDictionary *)dict {
    [self.nextButton gtm_removeIndicator];
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ResultViewController *vc = [sb instantiateViewControllerWithIdentifier:@"result"];
    vc.delegate = self;
    vc.type = self.type;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)smsVCWillResend {
    [self verifyPhoneNum:self.phoneNumTextField.text];
}

- (void)resultVCDidReturn {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.text.length == 11) {
        [self verifyPhoneNum:self.phoneNumTextField.text];
        if ([textField canResignFirstResponder]) {
            [textField resignFirstResponder];
        }
        return YES;
    }
    else return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
