//
//  VerifySMSViewController.h
//  GTMPhone
//
//  Created by NikoXu on 21/09/2017.
//  Copyright © 2017 geetest. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SMSCodeDelegate;

@interface VerifySMSViewController : UIViewController

@property (nonatomic, weak) id<SMSCodeDelegate> delegate;

@property (nonatomic, strong) NSString *phoneNum;
@property (nonatomic, strong) NSString *processID;
@property (nonatomic, strong) NSString *messageID;
@property (nonatomic, strong) NSString *customID;

@end

@protocol SMSCodeDelegate <NSObject>

@required
- (void)smsVCDidSuccess:(NSDictionary *)dict;
- (void)smsVCWillResend;

@end
