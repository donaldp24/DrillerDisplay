//
//  ViewController.m
//  DrillerDisplay
//
//  Created by Donald Pae on 2/28/14.
//  Copyright (c) 2014 Donald Pae. All rights reserved.
//

#import "ViewController.h"
#import "SettingsViewController.h"
#import "SettingsData.h"
#import <AudioToolbox/AudioToolbox.h>

NSString *serviceUUIDString = @"F926";
NSString *characteristicUUIDString = @"AAAE";

#define GAUGE_FONTCOLOR     [UIColor whiteColor]

@interface ViewController ()


@end

@implementation ViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.guage1.textLabel.text = @"TF - ";
	self.guage1.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-BoldItalic" size:10.0];
    self.guage1.textLabel.textColor = GAUGE_FONTCOLOR;
    
	self.guage1.lineWidth = 1.5;
	//self.guage1.minorTickLength = 15.0;
	self.guage1.needle.width = 3.0;
    //self.guage1.needle.length = self.guage1.needle.length;// + self.guage1.needle.length*.23;
	
    self.guage1.startAngle = M_PI * 1.5;
    self.guage1.arcLength = M_PI * 2.0;
    self.guage1.minNumber = 0;
    self.guage1.maxNumber = 360;
    
    self.guage1.increment = 45;
    
    
    self.guage2.textLabel.text = @"P1 - ";
	self.guage2.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-BoldItalic" size:8.0];
    self.guage2.textLabel.textColor = GAUGE_FONTCOLOR;
    
	self.guage2.lineWidth = 0.5;
	//self.guage1.minorTickLength = 15.0;
	self.guage2.needle.width = 1.0;
    //self.guage1.needle.length = self.guage1.needle.length;// + self.guage1.needle.length*.23;
	
    self.guage2.startAngle = M_PI * 1.5;
    self.guage2.arcLength = M_PI * 2.0;
    self.guage2.minNumber = 0;
    self.guage2.maxNumber = 360;
    
    self.guage2.increment = 90;
    
    
    self.guage3.textLabel.text = @"P2 - ";
	self.guage3.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-BoldItalic" size:8.0];
    self.guage3.textLabel.textColor = GAUGE_FONTCOLOR;
    
	self.guage3.lineWidth = 0.5;
	//self.guage1.minorTickLength = 15.0;
	self.guage3.needle.width = 1.0;
    //self.guage1.needle.length = self.guage1.needle.length;// + self.guage1.needle.length*.23;
	
    self.guage3.startAngle = M_PI * 1.5;
    self.guage3.arcLength = M_PI * 2.0;
    self.guage3.minNumber = 0;
    self.guage3.maxNumber = 360;
    
    self.guage3.increment = 90;
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNewValues:)
                                                 name:@"NewValues"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(doAlarm:)
                                                 name:@"doAlarm"
                                               object:nil];
    
    mNotifyStarted = NO;

    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"carbon_fibre"]]];
    
    
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    
    for (int i = 0; i < 4; i ++) {
        isShowAlert[i] = YES;
    }
    
    dataReceived = NO;
    
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    [self layoutSubviewsForOrientation:interfaceOrientation];
    
    SettingsData *data = [SettingsData sharedData];
    
    if (data.isBluetooth)
    {
        peripheralServer = [[PeripheralServer alloc] initWithDelegate:self];
        peripheralServer.serviceName = @"VMPeripheral";
        peripheralServer.serviceUUID = [CBUUID UUIDWithString:serviceUUIDString];
        peripheralServer.characteristicUUID = [CBUUID UUIDWithString:characteristicUUIDString];
        
        [peripheralServer startAdvertising];
        
        [self.lblStatus setText:@"Bluetooth - advertising..."];
        [self.indicator startAnimating];
    }
    else
    {
        [NSThread detachNewThreadSelector:@selector(runListener) toTarget:self withObject:nil];
        [self.lblStatus setText:@"wifi - listening..."];
        [self.indicator startAnimating];
    }
    
    timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(timerProc:) userInfo:nil repeats:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    SettingsData *data = [SettingsData sharedData];
    
    if (data.isBluetooth)
    {
        [peripheralServer stopAdvertising];
    }
    else
    {
        [self stopListen];
    }
    [timer invalidate];
    timer = nil;
}

#pragma mark - actions

- (IBAction)onBtnSend:(id)sender
{
    [self.txtSend resignFirstResponder];
    if (mNotifyStarted == NO)
        return;
    
    [peripheralServer sendToSubscribers:[self.txtSend.text dataUsingEncoding:NSUTF8StringEncoding]];
    [self.txtSend setText:@""];
    
}

- (IBAction)onBtnBg:(id)sender
{
    [self.txtSend resignFirstResponder];
}

- (IBAction)onSettings:(id)sender
{
    SettingsViewController *ctrl = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingsViewController"];
    [self presentViewController:ctrl animated:NO completion:nil];
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
    
    CGRect rtBount = [[UIScreen mainScreen] bounds];
    CGRect rtAlarm = self.viewAlarm.frame;
    CGRect rtAlert = self.viewAlert.frame;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        CGFloat lblWidth = 42;
        CGFloat lblHeight = 21;
        CGFloat valueWidth = 57;
        CGFloat bigGaugeWidth = 214;
        CGFloat bigGaugeHeight = 214;
        CGFloat gaugeWidth = 109;
        CGFloat gaugeHeight = 109;
        
        
        
        if(orientation == UIInterfaceOrientationPortrait) {
            
            // gauges
            self.guage1.frame = CGRectMake(53, 64, bigGaugeWidth, bigGaugeHeight);
            self.guage2.frame = CGRectMake(30, 345, gaugeWidth, gaugeHeight);
            self.guage3.frame = CGRectMake(169, 345, gaugeWidth, gaugeHeight);
            
            // labels
            self.lblInc.frame = CGRectMake(9, 299, lblWidth, lblHeight);
            self.inclination.frame = CGRectMake(50, 299, valueWidth, lblHeight);
            self.lblAz.frame = CGRectMake(108, 299, lblWidth, lblHeight);
            self.azimuth.frame = CGRectMake(154, 299, valueWidth, lblHeight);
            self.lblMd.frame = CGRectMake(211, 299, lblWidth, lblHeight);
            self.measureDepth.frame = CGRectMake(261, 299, valueWidth, lblHeight);
            
            self.lblPipe.frame = CGRectMake(63, 462, 42, 21);
            self.lblAnn.frame = CGRectMake(210, 462, 42, 21);
            
            
            self.viewAlarm.frame = CGRectMake(rtBount.size.width / 2 - rtAlarm.size.width / 2, rtBount.size.height / 2 - rtAlarm.size.height, rtAlarm.size.width, rtAlarm.size.height);
            
            self.viewAlert.frame = CGRectMake(rtBount.size.width / 2 - rtAlert.size.width / 2, rtBount.size.height / 2, rtAlert.size.width, rtAlert.size.height);

        }
        else {
            // gauges
            self.guage1.frame = CGRectMake(33, 64, bigGaugeWidth, bigGaugeHeight);
            self.guage2.frame = CGRectMake(400, 36, gaugeWidth, gaugeHeight);
            self.guage3.frame = CGRectMake(400, 186, gaugeWidth, gaugeHeight);
            
            CGFloat lblLeft = 280;
            CGFloat valueLeft = 330;
            
            // labels
            self.lblInc.frame = CGRectMake(lblLeft, 93, lblWidth, lblHeight);
            self.inclination.frame = CGRectMake(valueLeft, 93, valueWidth, lblHeight);
            
            self.lblAz.frame = CGRectMake(lblLeft, 122, lblWidth, lblHeight);
            self.azimuth.frame = CGRectMake(valueLeft, 122, valueWidth, lblHeight);
            
            self.lblMd.frame = CGRectMake(lblLeft, 151, lblWidth, lblHeight);
            self.measureDepth.frame = CGRectMake(valueLeft, 151, valueWidth, lblHeight);
            
            self.lblPipe.frame = CGRectMake(433, 155, 42, 21);
            self.lblAnn.frame = CGRectMake(433, 296, 42, 21);
            
            self.viewAlarm.frame = CGRectMake(rtBount.size.height / 2 - rtAlarm.size.width / 2, rtBount.size.width / 2 - rtAlarm.size.height, rtAlarm.size.width, rtAlarm.size.height);
            
            self.viewAlert.frame = CGRectMake(rtBount.size.height / 2 - rtAlert.size.width / 2, rtBount.size.width / 2, rtAlert.size.width, rtAlert.size.height);
        }
        
        
    }
    else {
        CGFloat lblWidth = 42;
        CGFloat lblHeight = 21;
        CGFloat valueWidth = 57;
        CGFloat bigGaugeWidth = 360;
        CGFloat bigGaugeHeight = 360;
        CGFloat gaugeWidth = 168;
        CGFloat gaugeHeight = 168;
        
        if(orientation == UIInterfaceOrientationPortrait) {
            // gauges
            self.guage1.frame = CGRectMake(204, 56, bigGaugeWidth, bigGaugeHeight);
            self.guage2.frame = CGRectMake(129, 610, gaugeWidth, gaugeHeight);
            self.guage3.frame = CGRectMake(482, 610, gaugeWidth, gaugeHeight);
            
            // labels
            CGFloat lblTop = 501;
            self.lblInc.frame = CGRectMake(230, lblTop, lblWidth, lblHeight);
            self.inclination.frame = CGRectMake(271, lblTop, valueWidth, lblHeight);
            self.lblAz.frame = CGRectMake(329, lblTop, lblWidth, lblHeight);
            self.azimuth.frame = CGRectMake(375, lblTop, valueWidth, lblHeight);
            self.lblMd.frame = CGRectMake(432, lblTop, lblWidth, lblHeight);
            self.measureDepth.frame = CGRectMake(482, lblTop, valueWidth, lblHeight);
            
            self.lblPipe.frame = CGRectMake(192, 817, lblWidth, lblHeight);
            self.lblAnn.frame = CGRectMake(545, 817, lblWidth, lblHeight);
            
            self.viewAlarm.frame = CGRectMake(rtBount.size.width / 2 - rtAlarm.size.width / 2, rtBount.size.height / 2 - rtAlarm.size.height, rtAlarm.size.width, rtAlarm.size.height);
            
            self.viewAlert.frame = CGRectMake(rtBount.size.width / 2 - rtAlert.size.width / 2, rtBount.size.height / 2, rtAlert.size.width, rtAlert.size.height);
        }
        else {
            // gauges
            self.guage1.frame = CGRectMake(141, 211, bigGaugeWidth, bigGaugeHeight);
            self.guage2.frame = CGRectMake(737, 168, gaugeWidth, gaugeHeight);
            self.guage3.frame = CGRectMake(737, 431, gaugeWidth, gaugeHeight);
            
            CGFloat lblLeft = 573;
            CGFloat valueLeft = 614;
            
            // labels
            self.lblInc.frame = CGRectMake(lblLeft, 327, lblWidth, lblHeight);
            self.inclination.frame = CGRectMake(valueLeft, 327, valueWidth, lblHeight);
            
            self.lblAz.frame = CGRectMake(lblLeft, 362, lblWidth, lblHeight);
            self.azimuth.frame = CGRectMake(valueLeft, 362, valueWidth, lblHeight);
            
            self.lblMd.frame = CGRectMake(lblLeft, 401, lblWidth, lblHeight);
            self.measureDepth.frame = CGRectMake(valueLeft, 401, valueWidth, lblHeight);
            
            self.lblPipe.frame = CGRectMake(800, 357, 42, 21);
            self.lblAnn.frame = CGRectMake(800, 622, 42, 21);
            
            self.viewAlarm.frame = CGRectMake(rtBount.size.height / 2 - rtAlarm.size.width / 2, rtBount.size.width / 2 - rtAlarm.size.height, rtAlarm.size.width, rtAlarm.size.height);
            
            self.viewAlert.frame = CGRectMake(rtBount.size.height / 2 - rtAlert.size.width / 2, rtBount.size.width / 2, rtAlert.size.width, rtAlert.size.height);
        }
    }
    
}



#pragma mark - data delegation

- (void) doAlarm:(NSNotification *) notification
{
    /*
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
    alarmView.hidden = NO;
    
    //	// Also issue visual alert
    //	UIAlertView *alert = [[UIAlertView alloc]
    //                          initWithTitle:@"Alarm received from RivCross!"
    //                          message:nil
    //                          delegate:nil
    //                          cancelButtonTitle:nil
    //                          otherButtonTitles:@"OK", nil];
    //	[alert show];
     */
    
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    [self showAlarm];
}

- (void) receiveNewValues:(NSNotification *) notification
{
    
    if ([[notification name] isEqualToString:@"NewValues"]){
        NSDictionary *dictionary = [notification userInfo];
        
        SettingsData *settingData = [SettingsData sharedData];
        if ([dictionary objectForKey:@"NewTF"]){
            float tf = [[[notification userInfo] valueForKey:@"NewTF"] floatValue];
            [self.guage1 setValue:tf];
        }
        if ([dictionary objectForKey:@"NewP1"]){
            float fp1 = [[[notification userInfo] valueForKey:@"NewP1"] floatValue];
            [self.guage2 setValue:fp1];
            
            if (settingData.isPipeHighLimit)
            {
                if (settingData.pipeHighLimit < fp1 && isShowAlert[0] == YES)
                {
                    isShowAlert[0] = NO;
                    [self performSelectorOnMainThread:@selector(showPipeHighLimitAlert:) withObject:(id)[NSNumber numberWithFloat:fp1] waitUntilDone:NO];
                    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(alertTimerProc:) userInfo:(id)[NSNumber numberWithInteger:0] repeats:NO];
                }
            }
            if (settingData.isPipeLowLimit)
            {
                if (settingData.pipeLowLimit > fp1 && isShowAlert[1] == YES)
                {
                    isShowAlert[1] = NO;
                    [self performSelectorOnMainThread:@selector(showPipeLowLimitAlert:) withObject:[NSNumber numberWithFloat:fp1] waitUntilDone:NO];
                    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(alertTimerProc:) userInfo:[NSNumber numberWithInteger:1] repeats:NO];
                }
            }
        }
        if ([dictionary objectForKey:@"NewP2"]){
            float fp2 = [[[notification userInfo] valueForKey:@"NewP2"] floatValue];
            [self.guage3 setValue:fp2];
            
            if (settingData.isAnnHighLimit)
            {
                if (settingData.annHighLimit < fp2 && isShowAlert[2] == YES)
                {
                    isShowAlert[2] = NO;
                    [self performSelectorOnMainThread:@selector(showAnnHighLimitAlert:) withObject:(id)[NSNumber numberWithFloat:fp2] waitUntilDone:NO];
                    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(alertTimerProc:) userInfo:(id)[NSNumber numberWithInteger:2] repeats:NO];
                }
            }
            if (settingData.isAnnLowLimit)
            {
                if (settingData.annLowLimit > fp2 && isShowAlert[3] == YES)
                {
                    isShowAlert[3] = NO;
                    [self performSelectorOnMainThread:@selector(showAnnLowLimitAlert:) withObject:[NSNumber numberWithFloat:fp2] waitUntilDone:NO];
                    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(alertTimerProc:) userInfo:[NSNumber numberWithInteger:3] repeats:NO];
                }
            }
        }
        
        if ([dictionary objectForKey:@"NewAZ"]){
            float az = [[[notification userInfo] valueForKey:@"NewAZ"] floatValue];
            [self.azimuth setText:[NSString stringWithFormat:@"%1.1f", az]];
        }
        if ([dictionary objectForKey:@"NewIN"]){
            float inc = [[[notification userInfo] valueForKey:@"NewIN"] floatValue];
            [self.inclination setText:[NSString stringWithFormat:@"%1.1f", inc]];
        }
        if ([dictionary objectForKey:@"NewMD"]){
            float fmd = [[[notification userInfo] valueForKey:@"NewMD"] floatValue];
            [self.measureDepth setText:[NSString stringWithFormat:@"%1.1f", fmd]];
        }
        if ([dictionary objectForKey:@"NewMsg"]){
            NSString *msg = [[notification userInfo] valueForKey:@"NewMsg"];
            [self performSelectorOnMainThread:@selector(addReceivedText:)withObject:msg waitUntilDone:NO];
        }
        if ([dictionary objectForKey:@"NewRPM"]){
            //float rpm = [[[notification userInfo] valueForKey:@"NewRPM"] floatValue];
            //[self.rpm setText:[NSString stringWithFormat:@"%1.0f", rpm]];
        }
        //dataIn.hidden = ! dataIn.hidden;
        
        dataReceived = YES;
        self.lblStatus.text = @"Data receiving...";
    }
}

- (void)addReceivedText:(NSString *)str
{
    /*
    NSString *msg;
    if (self.receivedText.text.length == 0)
        msg = [NSString stringWithFormat:@"%@", str];
    else
        msg = [NSString stringWithFormat:@"%@\n%@", self.receivedText.text, str];
    [self.receivedText setText:msg];
    NSRange range = NSMakeRange(self.receivedText.text.length - 1, 1);
    [self.receivedText scrollRangeToVisible:range];
     */
}




#pragma mark - PeripheralServerDelegate

- (void)peripheralServer:(PeripheralServer *)peripheral centralDidSubscribe:(CBCentral *)central {
    [peripheralServer sendToSubscribers:[@"Hello" dataUsingEncoding:NSUTF8StringEncoding]];
    //[self.viewController centralDidConnect];
    mNotifyStarted = YES;
}

- (void)peripheralServer:(PeripheralServer *)peripheral centralDidUnsubscribe:(CBCentral *)central {
    //[self.viewController centralDidDisconnect];
    mNotifyStarted = FALSE;
}

- (void)peripheralServer:(PeripheralServer *)peripheral receiveValue:(NSData *)data {
    //
    NSString *strReceived = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSString *secretCode = [[strReceived substringToIndex:(3)] lowercaseString];
    NSDictionary *userInfo;
    
    if ([secretCode  isEqualToString:@"ala"])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"doAlarm" object:nil userInfo:nil];
    }
    else
    {
        NSString *theStrValue = [strReceived substringWithRange:NSMakeRange(3, [strReceived length] - 3)];
        if ([secretCode isEqualToString: @"mg="])
        {
            userInfo = [NSDictionary dictionaryWithObject:theStrValue forKey:@"NewMsg"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NewValues" object:nil userInfo:userInfo];
        }
        else
        {
            float theFloatValue = [theStrValue floatValue];
            
            NSString *forKeyName;
            
            if ([secretCode isEqualToString: @"tf="])
            {
                forKeyName = @"NewTF";
            }
            else if ([secretCode isEqualToString: @"az="])
            {
                forKeyName = @"NewAZ";
            }
            else if ([secretCode isEqualToString: @"in="])
            {
                forKeyName = @"NewIN";
            }
            else if ([secretCode isEqualToString: @"md="])
            {
                forKeyName = @"NewMD";
            }
            else if ([secretCode isEqualToString: @"p1="])
            {
                forKeyName = @"NewP1";
            }
            else if ([secretCode isEqualToString: @"p2="])
            {
                forKeyName = @"NewP2";
            }
            else if ([secretCode isEqualToString: @"rp="])
            {
                forKeyName = @"NewRPM";
            }
            userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:theFloatValue] forKey:forKeyName];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NewValues" object:nil userInfo:userInfo];
        }
    }
}

- (void) stopListen
{
    [self.listener.echo stop];
    self.listener.echo = nil;
    //listener = nil;
}


- (void) runListener
{
    SettingsData *data = [SettingsData sharedData];
    
    self.listener = [[UDPlistenerDelegate alloc] init];
    assert(self.listener != nil);
    [self.listener runServerOnPort:data.port];
    
}

- (void)sendPacket:(NSString *)stringData
{
    NSLog(@"AppDelegate sendPacket of %@", stringData);
    [self.listener sendPacket:stringData];
    
}

#pragma mark - timer

- (void)timerProc:(NSTimer *)thisTimer
{
    if (dataReceived == YES)
    {
        dataReceived = NO;
    }
    else
    {
        SettingsData *data = [SettingsData sharedData];
        if (data.isBluetooth)
            self.lblStatus.text = @"bluetooth - advertising...";
        else
            self.lblStatus.text = @"wifi - listening...";
    }
}

#pragma mark - alarm
- (void)showAlarm
{
    self.viewAlarm.hidden = NO;
}

- (void)hideAlarm
{
    self.viewAlarm.hidden = YES;
}

- (IBAction)onDismissAlarm:(id)sender
{
    [self hideAlarm];
}

#pragma mark - alert
- (void)showAlert:(NSString *)title limit:(float)limit value:(float)value
{
    self.viewAlert.hidden = NO;
    self.lblAlertTitle.text = title;
    self.lblAlertLimitValue.text = [NSString stringWithFormat:@"Limit value: %.1f", limit];
    self.lblAlertCurrValue.text = [NSString stringWithFormat:@"Current value: %.1f", value];
}

- (void)hideAlert
{
    self.viewAlert.hidden = YES;
}

- (IBAction)onDismissAlert:(id)sender
{
    [self hideAlert];
}

- (void)alertTimerProc:(NSTimer *)theTimer
{
    NSNumber *number = theTimer.userInfo;
    int index = [number intValue];
    isShowAlert[index] = YES;
}

- (void)showPipeHighLimitAlert:(NSNumber *)value
{
    NSString *strTitle = @"Pipe high limit alert";
    [self showAlert:strTitle limit:[SettingsData sharedData].pipeHighLimit value:[value floatValue]];
}

- (void)showPipeLowLimitAlert:(NSNumber *)value
{
    NSString *strTitle = @"Pipe low limit alert";
    [self showAlert:strTitle limit:[SettingsData sharedData].pipeLowLimit value:[value floatValue]];
}

- (void)showAnnHighLimitAlert:(NSNumber *)value
{
    NSString *strTitle = @"Annular high limit alert";
    [self showAlert:strTitle limit:[SettingsData sharedData].annHighLimit value:[value floatValue]];
}

- (void)showAnnLowLimitAlert:(NSNumber *)value
{
    NSString *strTitle = @"Annular low limit alert";
    [self showAlert:strTitle limit:[SettingsData sharedData].annLowLimit value:[value floatValue]];
}

@end
