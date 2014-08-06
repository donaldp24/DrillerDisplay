//
//  AutoMessageBox.h
//  Showhand
//
//  Created by Lion User on 01/02/2013.
//  Copyright (c) 2013 AppDevCenter. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AutoMessageBox : UIViewController{
    
    IBOutlet UIImageView *ivBg;
    NSString *strMsg;
    
}

@property(nonatomic, retain) IBOutlet UILabel *lblMsg;
@property(nonatomic, retain) UIView *parentView;


+ (void)AutoMsgInView:(UIView *)parentView withText:(NSString *)text;
+ (void)fadeOutMsg;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil text:(NSString *)text;
@end
