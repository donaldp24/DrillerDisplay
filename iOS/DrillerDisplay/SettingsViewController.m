//
//  SettingsViewController.m
//  DrillerDisplay
//
//  Created by Donald Pae on 4/1/14.
//  Copyright (c) 2014 Donald Pae. All rights reserved.
//

#import "SettingsViewController.h"
#import "SettingsData.h"
#import "KeyboardHelper.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"carbon_fibre"]]];
    
    SettingsData *data = [SettingsData sharedData];
    
    self.switchBluetooth.on = data.isBluetooth;
    self.txtLocalIp.text = data.ipAddress;
    self.txtLocalPort.text = [NSString stringWithFormat:@"%d", data.port];
    self.switchPipeHighLimit.on = data.isPipeHighLimit;
    self.txtPipeHighLimit.text = [NSString stringWithFormat:@"%.1f", data.pipeHighLimit];
    self.switchPipeLowLimit.on = data.isPipeLowLimit;
    self.txtPipeLowLimit.text = [NSString stringWithFormat:@"%.1f", data.pipeLowLimit];
    self.switchAnnHighLimit.on = data.isAnnHighLimit;
    self.txtAnnHighLimit.text = [NSString stringWithFormat:@"%.1f", data.annHighLimit];
    self.switchAnnLowLimit.on = data.isAnnLowLimit;
    self.txtAnnLowLimit.text = [NSString stringWithFormat:@"%.1f", data.annLowLimit];
    self.switchRpmHighLimit.on = data.isRpmHighLimit;
    self.txtRpmHighLimit.text = [NSString stringWithFormat:@"%.1f", data.rpmHighLimit];
    
    [self.btnShowPipe setSelected:data.isShowPipe];
    [self.btnShowWob setSelected:data.isShowWob];
    [self.btnShowAnn setSelected:data.isShowAnn];
    [self.btnShowRpm setSelected:data.isShowRpm];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
    
        [(UIScrollView *)self.view setContentSize:CGSizeMake(self.view.frame.size.width, 870)];
    }
    else
    {
        [(UIScrollView *)self.view setContentSize:CGSizeMake(self.view.frame.size.width, 818)];
    }
    
    keyboardVisible = false;
    curTextField = nil;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTap:)];
    [self.view addGestureRecognizer:tap];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    [self layoutSubviewsForOrientation:interfaceOrientation];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:self.view.window];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:self.view.window];
}

#pragma mark - orientation

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
        toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        NSLog(@"Change to custom UI for landscape");
    }
    else if (toInterfaceOrientation == UIInterfaceOrientationPortrait ||
             toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        NSLog(@"Change to custom UI for portrait");
        
    }
    [self layoutSubviewsForOrientation:toInterfaceOrientation];
}

-(void)layoutSubviewsForOrientation:(UIInterfaceOrientation) orientation {
    

    CGRect rtContainer = self.ctrlContainer.frame;
    CGRect rtScreen = [[UIScreen mainScreen] bounds];
    
    if(orientation == UIInterfaceOrientationPortrait) {
        //rtMain = CGRectMake(0, 50, rtScreen.size.width, rtScreen.size.height - 50);
        rtContainer = CGRectMake(0, rtContainer.origin.y, rtScreen.size.width, rtContainer.size.height);
        //self.viewMain.frame = rtMain;
        self.ctrlContainer.frame = rtContainer;
        
        
    }
    else {
        //rtMain = CGRectMake(0, 50, rtScreen.size.height, rtScreen.size.width - 50);
        rtContainer = CGRectMake(rtScreen.size.height / 2 - rtContainer.size.width / 2, rtContainer.origin.y, rtContainer.size.width, rtContainer.size.height);
        //self.viewMain.frame = rtMain;
        self.ctrlContainer.frame = rtContainer;

    }
    
}

#pragma mark - Actions

-(IBAction)onBackClicked:(id)sender
{
    SettingsData *data = [SettingsData sharedData];
    
    data.isBluetooth = self.switchBluetooth.on;
    data.ipAddress = self.txtLocalIp.text;
    data.port = [self.txtLocalPort.text intValue];
    
    data.isPipeHighLimit = self.switchPipeHighLimit.on;
    data.pipeHighLimit = [self.txtPipeHighLimit.text floatValue];
    data.isPipeLowLimit = self.switchPipeLowLimit.on;
    data.pipeLowLimit = [self.txtPipeLowLimit.text floatValue];
    
    data.isAnnHighLimit = self.switchAnnHighLimit.on;
    data.annHighLimit = [self.txtAnnHighLimit.text floatValue];
    data.isAnnLowLimit = self.switchAnnLowLimit.on;
    data.annLowLimit = [self.txtAnnLowLimit.text floatValue];
    
    data.isRpmHighLimit = self.switchRpmHighLimit.on;
    data.rpmHighLimit = [self.txtRpmHighLimit.text floatValue];
    
    data.isShowPipe = self.btnShowPipe.selected;
    data.isShowWob = self.btnShowWob.selected;
    data.isShowAnn = self.btnShowAnn.selected;
    data.isShowRpm = self.btnShowRpm.selected;
    
    [data saveData];
    
    if (curTextField != nil)
        [curTextField resignFirstResponder];
    
    [self dismissViewControllerAnimated:NO completion:nil];
}

///////////////////////////////////////////////////////////////////
#pragma mark - Scroll When Keyboard Focus
- (IBAction)BeginEditing:(UITextField *)sender
{
    curTextField = sender;
    if (keyboardVisible)
        [KeyboardHelper moveScrollView:curTextField scrollView:(UIScrollView*)self.view];
}

- (IBAction)EndEditing:(UITextField *)sender
{
    curTextField = nil;
    [sender resignFirstResponder];
}


- (void)keyboardWillShow:(NSNotification *)notification
{
    //---gets the size of the keyboard---
    NSDictionary *userInfo = [notification userInfo];
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardBounds];
    
	[KeyboardHelper moveScrollView:curTextField scrollView:(UIScrollView*)self.view];
    
    keyboardVisible = true;
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    //---gets the size of the keyboard---
    NSDictionary *userInfo = [notification userInfo];
    //NSValue *keyboardValue = [userInfo objectForKey:UIKeyboardBoundsUserInfoKey];
    //[keyboardValue getValue:&keyboardBounds];
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardBounds];
    
    [KeyboardHelper moveScrollView:nil scrollView:(UIScrollView*)self.view];
    
    keyboardVisible = false;
    
    curTextField = nil;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (IBAction)btnBackgroundClicked:(id)sender
{
    if (curTextField != nil)
        [curTextField resignFirstResponder];
}

- (IBAction)onBtnShowPipeClicked:(id)sender
{
    self.btnShowPipe.selected = !self.btnShowPipe.selected;
    
    if (self.btnShowPipe.selected )
    {
        self.btnShowWob.selected = NO;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            if (self.btnShowAnn.selected && self.btnShowRpm.selected)
                self.btnShowRpm.selected = NO;
        }
    }
    
}

- (IBAction)onBtnShowWobClicked:(id)sender
{
    self.btnShowWob.selected = !self.btnShowWob.selected;
    
    if (self.btnShowWob.selected)
    {
        self.btnShowPipe.selected = NO;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            if (self.btnShowAnn.selected && self.btnShowRpm.selected)
                self.btnShowRpm.selected = NO;
        }
    }
}

- (IBAction)onBtnShowAnnClicked:(id)sender
{
    self.btnShowAnn.selected = !self.btnShowAnn.selected;
    
    if (self.btnShowAnn.selected)
    {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            if ((self.btnShowPipe.selected || self.btnShowWob.selected) && self.btnShowRpm.selected)
                self.btnShowRpm.selected = NO;
        }
    }
}

- (IBAction)onBtnShowRpmClicked:(id)sender
{
    self.btnShowRpm.selected = !self.btnShowRpm.selected;
    if (self.btnShowRpm.selected)
    {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            if ((self.btnShowPipe.selected || self.btnShowWob.selected) && self.btnShowAnn.selected)
                self.btnShowAnn.selected = NO;
        }
    }
}

# pragma mark Gesture selector
- (void)backgroundTap:(UITapGestureRecognizer *)backgroundTap {
    if(curTextField){
        [curTextField resignFirstResponder];
    }
}

@end
