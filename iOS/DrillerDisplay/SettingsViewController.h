//
//  SettingsViewController.h
//  DrillerDisplay
//
//  Created by Donald Pae on 4/1/14.
//  Copyright (c) 2014 Donald Pae. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController<UITextFieldDelegate> {
    
    BOOL               keyboardVisible;
    
}

@property (nonatomic, retain) IBOutlet UIView *ctrlContainer;
@property (nonatomic, retain) IBOutlet UISwitch *switchBluetooth;
@property (nonatomic, retain) IBOutlet UITextField *txtLocalIp;
@property (nonatomic, retain) IBOutlet UITextField *txtLocalPort;
@property (nonatomic, retain) IBOutlet UISwitch *switchPipeHighLimit;
@property (nonatomic, retain) IBOutlet UITextField *txtPipeHighLimit;
@property (nonatomic, retain) IBOutlet UISwitch *switchPipeLowLimit;
@property (nonatomic, retain) IBOutlet UITextField *txtPipeLowLimit;
@property (nonatomic, retain) IBOutlet UISwitch *switchAnnHighLimit;
@property (nonatomic, retain) IBOutlet UITextField *txtAnnHighLimit;
@property (nonatomic, retain) IBOutlet UISwitch *switchAnnLowLimit;
@property (nonatomic, retain) IBOutlet UITextField *txtAnnLowLimit;

@property (nonatomic, retain) IBOutlet UISwitch *switchRpmHighLimit;
@property (nonatomic, retain) IBOutlet UITextField *txtRpmHighLimit;
@property (nonatomic, retain) IBOutlet UIButton *btnShowPipe;
@property (nonatomic, retain) IBOutlet UIButton *btnShowWob;
@property (nonatomic, retain) IBOutlet UIButton *btnShowAnn;
@property (nonatomic, retain) IBOutlet UIButton *btnShowRpm;


- (IBAction)BeginEditing:(UITextField *)sender;
- (IBAction)EndEditing:(UITextField *)sender;
//- (void)setViewMoveUp:(BOOL)moveUp height:(float)height;
- (void)keyboardWillShow:(NSNotification *)notification;
- (void)keyboardWillHide:(NSNotification *)notification;
- (void)viewWillAppear:(BOOL)animated;
- (void)viewWillDisappear:(BOOL)animated;
//- (IBAction)textFieldHideKeyboard:(id)sender;
- (IBAction)onBackClicked:(id)sender;
- (IBAction)btnBackgroundClicked:(id)sender;

@end
