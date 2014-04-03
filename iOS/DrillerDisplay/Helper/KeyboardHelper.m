//
//  KeyboardHelper.m
//  Showhand
//
//  Created by GyongMin Om on 12. 10. 20..
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "KeyboardHelper.h"

UIView		*curTextField = nil;
bool		bTyping = false;

//---size of keyboard---
CGRect keyboardBounds;

//---size of application screen---
CGRect applicationFrame;


@implementation KeyboardHelper

+ (void)moveScrollView:(UIView*)theView scrollView:(UIScrollView*)scrollView {
    
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    applicationFrame = [[UIScreen mainScreen] applicationFrame];
    //---calculate how much the scrollview must scroll---
    CGFloat scrollAmount = 0;
	if (theView != nil)
	{
		//---get the y-coordinate of the view---
		CGFloat viewCenterY = theView.center.y;
        //if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight)
          //  viewCenterY = theView.center.x;
		
		//---calculate how much visible space is left---
		CGFloat freeSpaceHeight = applicationFrame.size.height - keyboardBounds.size.height;
        if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight)
            freeSpaceHeight = applicationFrame.size.width - keyboardBounds.size.height;
		
		scrollAmount = viewCenterY - freeSpaceHeight / 2.0;
	}
	
    if (scrollAmount < 0) scrollAmount = 0;
	if (scrollAmount > keyboardBounds.size.height) scrollAmount = keyboardBounds.size.height;
    
    //---set the new scrollView contentSize---
    //scrollView.contentSize = CGSizeMake(applicationFrame.size.height, applicationFrame.size.width + keyboardBounds.size.height);
    
    //---scroll the ScrollView---
    [scrollView setContentOffset:CGPointMake(0, scrollAmount) animated:YES];
	
}


@end
