//
//  ViewController.h
//  DrillerDisplay
//
//  Created by Donald Pae on 2/28/14.
//  Copyright (c) 2014 Donald Pae. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MeterView.h"
#import "PeripheralServer.h"
#import "UDPlistenerDelegate.h"

#define     MODE_BLECENTRAL     0
#define     MODE_BLEPERIPHERAL  1
#define     MODE_WIFI           2

@interface ViewController : UIViewController <PeripheralServerDelegate> {
    PeripheralServer *peripheralServer;
    BOOL    mNotifyStarted;
    BOOL    dataReceived;
    
    NSTimer *timer;
    BOOL   isShowAlert[4];
}

@property (nonatomic, retain, readwrite) UDPlistenerDelegate *listener;

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *indicator;
@property (nonatomic, retain) IBOutlet UILabel *lblStatus;

@property (nonatomic, retain) IBOutlet UIView *viewAlarm;

@property (nonatomic, retain) IBOutlet UIView *viewAlert;
@property (nonatomic, retain) IBOutlet UILabel *lblAlertTitle;
@property (nonatomic, retain) IBOutlet UILabel *lblAlertLimitValue;
@property (nonatomic, retain) IBOutlet UILabel *lblAlertCurrValue;

@property (nonatomic, retain) IBOutlet MeterView *guage1;
@property (nonatomic, retain) IBOutlet MeterView *guage2;
@property (nonatomic, retain) IBOutlet MeterView *guage3;

@property (nonatomic, retain) IBOutlet UILabel *lblMd;
@property (nonatomic, retain) IBOutlet UILabel *measureDepth;       //md

@property (nonatomic, retain) IBOutlet UILabel *lblInc;
@property (nonatomic, retain) IBOutlet UILabel *inclination;        //inc

@property (nonatomic, retain) IBOutlet UILabel *lblAz;
@property (nonatomic, retain) IBOutlet UILabel *azimuth;            //az
//@property (nonatomic, retain) IBOutlet UITextView *receivedText;    //received msg
@property (nonatomic, retain) IBOutlet UITextField *txtSend;

@property (nonatomic, retain) IBOutlet UILabel *lblPipe;
@property (nonatomic, retain) IBOutlet UILabel *lblAnn;

@property (nonatomic, retain) IBOutlet UIImageView *imgBg;


- (void) runListener;
- (void)sendPacket:(NSString *)stringData;

@end
