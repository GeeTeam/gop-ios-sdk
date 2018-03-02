//
//  ResultViewController.h
//  GTMPhone
//
//  Created by NikoXu on 21/09/2017.
//  Copyright © 2017 geetest. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ResultVCDelegate;

@interface ResultViewController : UIViewController

@property (nonatomic, weak) id<ResultVCDelegate> delegate;

@property (nonatomic, strong) NSString *type;

@end

@protocol ResultVCDelegate <NSObject>

@required
- (void)resultVCDidReturn;

@end
