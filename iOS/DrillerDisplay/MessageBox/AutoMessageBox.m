//
//  AutoMessageBox.m
//  Showhand
//
//  Created by Lion User on 01/02/2013.
//  Copyright (c) 2013 AppDevCenter. All rights reserved.
//

#import "AutoMessageBox.h"

@interface AutoMessageBox ()

@end

@implementation AutoMessageBox

// Set visibility duration
static const CGFloat kDuration = 5;


// Static toastview queue variable
static NSMutableArray *toasts;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public

+ (CGSize)sizeOfString:(NSString *)string withFont:(id)font constraintWidth:(CGFloat)width
{
    NSAttributedString *attributedText =
    [[NSAttributedString alloc]
     initWithString:string
     attributes:@
     {
     NSFontAttributeName: font
     }];
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){width, CGFLOAT_MAX}
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    return rect.size;
}

+ (void)AutoMsgInView:(UIView *)parentView withText:(NSString *)text{
    // Add new instance to queue
    AutoMessageBox *viewCtrl = [[AutoMessageBox alloc] initWithNibName:@"AutoMessageBox" bundle:nil text:text];
    
    viewCtrl.parentView = parentView;
    
    if (toasts == nil) {
        toasts = [[NSMutableArray alloc] initWithCapacity:1];
        [toasts addObject:viewCtrl];
        [AutoMessageBox nextToastInView:parentView];
    }
    else {
        if (toasts.count <= 0)
            [toasts addObject:viewCtrl];
    }
    
    //[viewCtrl release];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private

- (void)fadeToastOut {
    
    // Fade in parent view
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionAllowUserInteraction
     
                     animations:^{
                         self.view.alpha = 0.f;
                     }
                     completion:^(BOOL finished){
                         UIView *parentView = self.view.superview;
                         [self.view removeFromSuperview];
                         
                         // Remove current view from array
                         [toasts removeObject:self];
                         if ([toasts count] == 0) {
                            ///[toasts release];
                             toasts = nil;
                         }
                         else
                             [AutoMessageBox nextToastInView:parentView];
                     }];
}

- (void)fadeToastOutWithoutAnimation {
    
    // Fade in parent view
    
     self.view.alpha = 0.f;

     UIView *parentView = self.view.superview;
     [self.view removeFromSuperview];
     
     // Remove current view from array
     [toasts removeObject:self];
     if ([toasts count] == 0) {
         ///[toasts release];
         toasts = nil;
     }
}

+ (void)fadeOutMsg
{
    if ([toasts count] > 0)
    {
        AutoMessageBox *msg = [toasts objectAtIndex:0];
        [msg fadeToastOut];
    }
}



+ (void)nextToastInView:(UIView *)parentView {
    if ([toasts count] > 0) {
        AutoMessageBox *viewCtrl = [toasts objectAtIndex:0];
        
        // Fade into parent view
        [parentView addSubview:viewCtrl.view];
        [UIView animateWithDuration:.5  delay:0 options:UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             viewCtrl.view.alpha = 1.0;
                         } completion:^(BOOL finished){}];
        
        // Start timer for fade out
        [viewCtrl performSelector:@selector(fadeToastOut) withObject:nil afterDelay:kDuration];
    }
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil text:(NSString *)text
{
    NSString *szXibName = nibNameOrNil;
    if ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPhone)
        szXibName = [NSString stringWithFormat:@"%@_ipad", nibNameOrNil];
	

	self = [super initWithNibName:szXibName bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        strMsg = text;
    }

    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.view.alpha = 0;

    self.lblMsg.text = strMsg;
    
    CGRect rtText = self.lblMsg.frame;
    CGSize szText = [AutoMessageBox sizeOfString:strMsg withFont:self.lblMsg.font constraintWidth:rtText.size.width];
    
    rtText.size.width = ceilf(szText.width);
    rtText.size.height = ceilf(szText.height);
    
    self.lblMsg.frame = rtText;
    self.lblMsg.numberOfLines = 0;
    
    self.view.frame = CGRectMake(0, 0, rtText.origin.x * 2 + rtText.size.width, rtText.origin.y * 2 + rtText.size.height);
    
    CGFloat lWidth =  self.view.frame.size.width;
    CGFloat lHeight = self.view.frame.size.height;
    
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    CGFloat pWidth = self.parentView.frame.size.width;
    CGFloat pHeight = self.parentView.frame.size.height;
    
    if (!UIInterfaceOrientationIsPortrait(interfaceOrientation))
    {
        pWidth = self.parentView.frame.size.height;
        pHeight = self.parentView.frame.size.width;
    }
    
    
    // Change toastview frame
    self.view.frame = CGRectMake((pWidth - lWidth) / 2., (pHeight - lHeight) - 10., lWidth, lHeight);
    self.view.alpha = 0.0f;
    
    ivBg.layer.cornerRadius = 5;

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortrait);
}

- (void)dealloc
{
}

#ifdef IOS6

#endif

@end