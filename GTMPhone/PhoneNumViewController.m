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

#import "TipsView.h"

#import "GT3CaptchaEX.h"

#import "UIButton+GTM.h"
#import "UIView+GTM.h"

@import GTOnePass;

//网站主部署的用于test-Button的register接口
#define API1 @"http://www.geetest.com/demo/gt/register-test"
//网站主部署的用于test-Button的validate接口
#define API2 @"http://www.geetest.com/demo/gt/validate-test"

//网站主部署的ONEPASS的校验接口
#define verify_url @"http://onepass.geetest.com/check_gateway.php"

@interface PhoneNumViewController () <UITextFieldDelegate, SMSCodeDelegate, ResultVCDelegate, GOPManagerDelegate, GT3CaptchaManagerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *phoneNumTextField;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;

@property (nonatomic, strong) NSString *message_id;

@property (nonatomic, strong) GT3CaptchaEX *captchaEx;
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
    [self verifyPhoneNum];
    if ([self.phoneNumTextField canResignFirstResponder]) {
        [self.phoneNumTextField resignFirstResponder];
    }
}

- (GOPManager *)manager {
    if (!_manager) {
        _manager = [[GOPManager alloc] initWithCustomID:@"7591d0f44d4c265c8441e99c748d936b" verifyUrl:verify_url timeout:10.0];
        _manager.delegate = self;
    }
    
    return _manager;
}

- (void)dealloc {
    [self.captchaEx stopGT3Captcha];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.captchaEx = [[GT3CaptchaEX alloc] initWithApi1:API1 api2:API2 timeout:1.0];
    self.captchaEx.manager.delegate = self;
    [self.captchaEx registerGT3Captcha];
    
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

// 校验手机号格式及国别
- (void)verifyPhoneNum {
    
    NSString *num = self.phoneNumTextField.text;
    
    if (![self checkPhoneNumFormat:num]) {
        self.phoneNumTextField.text = nil;
        [self.phoneNumTextField gtm_shake:9 witheDelta:2.f speed:0.1 completion:nil];
        [TipsView showTipOnKeyWindow:@"不合法的手机号"];
        return;
    }
    
    [self startCaptcha];
}

// 进行人机验证
- (void)startCaptcha {
    [self.nextButton gtm_showIndicator];
    [self.captchaEx startGT3Captcha];
}

// 获取人机验证的validate后, 进行onepass手机号码校验
- (void)startOnePass:(NSString *)validate {
    NSString *num = self.phoneNumTextField.text;
    
    if (![self checkPhoneNumFormat:num]) {// check phone num, country code
        self.phoneNumTextField.text = nil;
        [self.phoneNumTextField gtm_shake:9 witheDelta:2.f speed:0.1 completion:nil];
        [TipsView showTipOnKeyWindow:@"不合法的手机号"];
        return;
    }
    
    if (!self.manager.diagnosisStatus) {// check onepass network
        [TipsView showTipOnKeyWindow:@"OnePass需要您的数据网络支持。如果确认已开启数据网络, 可能是您当前的网络不被支持。"];
        return;
    }
    
    [self.manager verifyPhoneNum:num withCaptchaValidate:validate completion:^(NSDictionary *dict) {
        NSLog(@"completion: %@", dict.description);
        
        NSString *type = [dict objectForKey:@"type"];
        NSNumber *result = [dict objectForKey:@"result"];
        if ([type isEqualToString:@"onepass"] && [result isEqualToNumber:@(0)]) {// onepass成功, 输入的手机号码和本机的sim一致
            
            [self.nextButton gtm_removeIndicator];
            
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            ResultViewController *vc = [sb instantiateViewControllerWithIdentifier:@"result"];
            vc.delegate = self;
            vc.type = self.type;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self presentViewController:vc animated:YES completion:nil];
            });
        }
        else if ([type isEqualToString:@"onepass"] && ![result isEqualToNumber:@(0)]) {// onepass失败且没有购买极验的短信验证服务。一般后续处理为, 调用自己的短信验证码服务。
            
            [TipsView showTipOnKeyWindow:@"OnePass未通过" fontSize:14.0];
        }
        else if ([type isEqualToString:@"sms"]) {//  onepass失败且购买了极验的短信服务, 极验短信验证码已发送成功后收到此结果。下面需要创建UI来处理用户输入的短信验证码。c
            
            NSString *desc = [NSString stringWithFormat:@"短信原因:\n%@", dict.description];
            [TipsView showTipOnKeyWindow:desc fontSize:14.0];
            
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
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self presentViewController:vc animated:YES completion:nil];
            });
        }
        else {
            [self.nextButton gtm_removeIndicator];
            
            NSString *result = [NSString stringWithFormat:@"Onepass故障, 故障信息:\n%@", dict.description];
            [TipsView showTipOnKeyWindow:result fontSize:14.0];
            NSLog(@"error: %@", result);
        }
        
    } failure:^(NSError *error) {
        NSString *desc = [NSString stringWithFormat:@"错误信息:\n%@", error.description];
        if (error.code != -999) [TipsView showTipOnKeyWindow:desc fontSize:14.0];// ignore -999
        //发生了错误
        NSLog(@"error: %@", error);
        [self.nextButton gtm_removeIndicator];
    }];
}

// 检测手机号码格式的参考示范
- (BOOL)checkPhoneNumFormat:(NSString *)num {
    /**
     * 手机号码
     * 移动：134[0-8],135,136,137,138,139,147,148,150,151,152,157,158,159,178,182,183,184,187,188, 198
     * 联通：130,131,132,145,146,152,155,156,166,171,175,176,185,186
     * 电信：133,1349,153,173,174,177,180,181,189,199
     */
    
    /**
     * 宽泛的手机号过滤规则
     */
    NSString * MOBILE = @"^1([3-9])\\d{9}$";
    
    /**
     * 虚拟运营商: Virtual Network Operator
     * 不支持
     */
    NSString * VNO = @"^170\\d{8}$";
    
    /**
     * 中国移动：China Mobile
     * 134[0-8],135,136,137,138,139,147,150,151,152,157,158,159,178,182,183,184,187,188
     */
    
    NSString * CM = @"^1(34[0-8]|(3[5-9]|4[78]|5[0-27-9]|78|8[2-478]|98)\\d)\\d{7}$";
    
    /**
     * 中国联通：China Unicom
     * 130,131,132,152,155,156,176,185,186
     */
    
    NSString * CU = @"^1(3[0-2]|45|5[256]|7[156]|8[56])\\d{8}$";
    
    /**
     * 中国电信：China Telecom
     * 133,1349,153,173,177,180,181,189
     */
    
    NSString * CT = @"^1((33|53|7[347]|8[019]|99)[0-9]|349)\\d{7}$";
    
    NSPredicate *regexTestMobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    
    NSPredicate *regexTestVNO = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", VNO];
    
    NSPredicate *regexTestCM = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    
    NSPredicate *regexTestCU = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    
    NSPredicate *regexTestCT = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    
    if ([regexTestMobile evaluateWithObject:num] == YES &&
        (([regexTestCM evaluateWithObject:num] == YES) ||
         ([regexTestCT evaluateWithObject:num] == YES) ||
         ([regexTestCU evaluateWithObject:num] == YES)) &&
        [regexTestVNO evaluateWithObject:num] == NO) {
        return YES;
    }
    else return NO;
}

#pragma mark GT3CaptchaManager

- (void)gtCaptchaUserDidCloseGTView:(GT3CaptchaManager *)manager {
    [self.nextButton gtm_removeIndicator];
    [TipsView showTipOnKeyWindow:@"用户取消了人机验证"];
}

- (void)gtCaptcha:(GT3CaptchaManager *)manager errorHandler:(GT3Error *)error {
    [self.nextButton gtm_removeIndicator];
    [TipsView showTipOnKeyWindow:error.description];
}

// disable secondary validate when using OnePass
- (BOOL)shouldUseDefaultSecondaryValidate:(GT3CaptchaManager *)manager {
    return NO;
}

- (void)gtCaptcha:(GT3CaptchaManager *)manager didReceiveSecondaryCaptchaData:(NSData *)data response:(NSURLResponse *)response error:(GT3Error *)error decisionHandler:(void (^)(GT3SecondaryCaptchaPolicy))decisionHandler {
    // If `shouldUseDefaultSecondaryValidate:` return NO, do nothing here
    
}

// put captcha result into OnePass
- (void)gtCaptcha:(GT3CaptchaManager *)manager didReceiveCaptchaCode:(NSString *)code result:(NSDictionary *)result message:(NSString *)message {
    
    if (![code isEqualToString:@"1"]) return;
    
    NSString *validate = [result objectForKey:@"geetest_validate"];
    
    if (!validate || validate.length != 32) return;
    
    [self startOnePass:validate];
}

- (void)gtCaptcha:(GT3CaptchaManager *)manager willSendRequestAPI1:(NSURLRequest *)originalRequest withReplacedHandler:(void (^)(NSURLRequest *))replacedHandler {
    // add timestamp to api1
    NSMutableURLRequest *mRequest = [originalRequest mutableCopy];
    
    NSURLComponents *comp = [[NSURLComponents alloc] initWithString:mRequest.URL.absoluteString];
    NSMutableArray *items = [comp.queryItems mutableCopy];
    [items enumerateObjectsUsingBlock:^(NSURLQueryItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSURLQueryItem *item = (NSURLQueryItem *)obj;
        if (item.name && [item.name isEqualToString:@"t"]) {
            NSString *time = [NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970] * 1000];
            [items removeObject:obj];
            NSURLQueryItem *new = [[NSURLQueryItem alloc] initWithName:@"t" value:time];
            [items addObject:new];
        }
    }];
    comp.queryItems = items;
    mRequest.URL = comp.URL;
    
    replacedHandler(mRequest);
}

#pragma mark DEMO Delegate

- (void)smsVCDidSuccess:(NSDictionary *)dict {
    
    [self.nextButton gtm_removeIndicator];
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ResultViewController *vc = [sb instantiateViewControllerWithIdentifier:@"result"];
    vc.delegate = self;
    vc.type = self.type;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)smsVCWillResend {
    [self verifyPhoneNum];
}

- (void)resultVCDidReturn {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.text.length == 11) {
        [self verifyPhoneNum];
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
