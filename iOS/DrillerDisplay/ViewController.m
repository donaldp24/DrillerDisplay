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
#import "AppDelegate.h"
#import "AutoMessageBox.h"

#define RGB(r,g,b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]

#define UNIT_OF_MEASUREMENT_FONT [UIFont fontWithName:@"Helvetica" size:0.09]
#define SHOW_UNIT_OF_MEASUREMENT    YES
#define SCALE_DIVISIONS_WIDTH       0.008
#define SCALE_SUB_DIVISIONS_WIDTH   0.006
#define RANGE_LABELS_FONT_COLOR     [UIColor blackColor];
#define RANGE_LABELS_WIDTH          0.04
#define RANGE_LABELS_FONT           [UIFont fontWithName:@"Helvetica" size:0.04];

NSString *serviceUUIDString = @"F926";
NSString *characteristicUUIDString = @"AAAE";

#define GAUGE_FONTCOLOR     [UIColor whiteColor]

#define gaugeHs_MAXVALUE     360

@interface ViewController ()


@end

@implementation ViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
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
    
    AppDelegate *appDelegate = (AppDelegate *)([UIApplication sharedApplication].delegate);
    appDelegate.viewController = self;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initGauges
{
    
    UIColor *limitColor = RGB(231, 32, 43);
    UIColor *normalColor = RGB(255, 255, 255);
    
    _gaugeHs.maxValue = gaugeHs_MAXVALUE;
    _gaugeHs.scaleStartAngle = 0;
    _gaugeHs.scaleEndAngle = 360;
    
    _gaugeHs.showRangeLabels = NO;
    _gaugeHs.rangeValues = @[ @0,                  @gaugeHs_MAXVALUE];
    _gaugeHs.rangeColors = @[ RGB(255, 255, 255),    RGB(255, 255, 255)];
    _gaugeHs.rangeLabels = @[ @"VERY LOW",          @"LOW"];
    _gaugeHs.unitOfMeasurement = @"0.0";
    _gaugeHs.unitOfMeasurementFont = [UIFont fontWithName:@"Helvetica" size:0.1];
    _gaugeHs.showUnitOfMeasurement = YES;
    _gaugeHs.scaleDivisions = 8;
    _gaugeHs.scaleSubdivisions = 10;
    _gaugeHs.scaleDivisionsWidth = 0.008;
    _gaugeHs.scaleSubdivisionsWidth = 0.006;
    _gaugeHs.rangeLabelsFontColor = [UIColor blackColor];
    _gaugeHs.rangeLabelsWidth = 0.04;
    _gaugeHs.rangeLabelsFont = [UIFont fontWithName:@"Helvetica" size:0.04];
    [_gaugeHs setValue:0 animated:YES];
    
    SettingsData *data = [SettingsData sharedData];
    

    
    [self setGaugeRange:_gaugePipe preMin:data.pipeLowLimit preMax:data.pipeHighLimit];
    _gaugePipe.showRangeLabels = NO;
    
    _gaugePipe.rangeValues = @[ [NSNumber numberWithFloat:_gaugePipe.minValue], [NSNumber numberWithFloat:data.pipeLowLimit], [NSNumber numberWithFloat:data.pipeHighLimit], [NSNumber numberWithFloat:_gaugePipe.maxValue]];
    _gaugePipe.rangeColors = @[ limitColor, limitColor, normalColor, limitColor];

    _gaugePipe.unitOfMeasurement = @"0.0";
    _gaugePipe.unitOfMeasurementFont = [UIFont fontWithName:@"Helvetica" size:0.1];
    _gaugePipe.showUnitOfMeasurement = YES;
    
    _gaugePipe.scaleDivisionsWidth = 0.008;
    _gaugePipe.scaleSubdivisionsWidth = 0.006;
    _gaugePipe.rangeLabelsFontColor = [UIColor blackColor];
    _gaugePipe.rangeLabelsWidth = 0.04;
    _gaugePipe.rangeLabelsFont = [UIFont fontWithName:@"Helvetica" size:0.04];
    [_gaugePipe setValue:0 animated:YES];
    
    
    [self setGaugeRange:_gaugeAnn preMin:data.annLowLimit preMax:data.annHighLimit];
    
    _gaugeAnn.showRangeLabels = NO;
    
    _gaugeAnn.rangeValues = @[ [NSNumber numberWithFloat:_gaugeAnn.minValue], [NSNumber numberWithFloat:data.annLowLimit], [NSNumber numberWithFloat:data.annHighLimit], [NSNumber numberWithFloat:_gaugeAnn.maxValue]];
    _gaugeAnn.rangeColors = @[ limitColor, limitColor, normalColor, limitColor];
    

    _gaugeAnn.unitOfMeasurement = @"0.0";
    _gaugeAnn.unitOfMeasurementFont = [UIFont fontWithName:@"Helvetica" size:0.09];
    _gaugeAnn.showUnitOfMeasurement = YES;
    _gaugeAnn.scaleDivisionsWidth = 0.008;
    _gaugeAnn.scaleSubdivisionsWidth = 0.006;
    _gaugeAnn.rangeLabelsFontColor = [UIColor blackColor];
    _gaugeAnn.rangeLabelsWidth = 0.04;
    _gaugeAnn.rangeLabelsFont = [UIFont fontWithName:@"Helvetica" size:0.04];
    [_gaugeAnn setValue:0 animated:YES];
    
    
    ////////////////////////////////////////////////////
    //[self setGaugeRange:_gaugeWob preMin:0 preMax:150.0];
    CGFloat wobMin = 0.f;
    CGFloat wobMax = 150.f;
    _gaugeWob.minValue = wobMin;
    _gaugeWob.maxValue = wobMax;
    _gaugeWob.scaleDivisions = (int)((wobMax - wobMin) / 30);
    _gaugeWob.scaleSubdivisions = 6;
    
    _gaugeWob.showRangeLabels = NO;
    
    _gaugeWob.rangeValues = @[ [NSNumber numberWithFloat:_gaugeWob.minValue], [NSNumber numberWithFloat:150.0], [NSNumber numberWithFloat:_gaugeWob.maxValue]];
    _gaugeWob.rangeColors = @[ normalColor, normalColor, normalColor, normalColor];
    
    
    _gaugeWob.unitOfMeasurement = @"0.0";
    _gaugeWob.unitOfMeasurementFont = [UIFont fontWithName:@"Helvetica" size:0.09];
    _gaugeWob.showUnitOfMeasurement = YES;
    _gaugeWob.scaleDivisionsWidth = 0.008;
    _gaugeWob.scaleSubdivisionsWidth = 0.006;
    _gaugeWob.rangeLabelsFontColor = [UIColor blackColor];
    _gaugeWob.rangeLabelsWidth = 0.04;
    _gaugeWob.rangeLabelsFont = [UIFont fontWithName:@"Helvetica" size:0.04];
    [_gaugeWob setValue:0 animated:YES];
    
    ////////////////////////////////////////////////////
    //[self setGaugeRange:_gaugeWob preMin:0 preMax:150.0];
    CGFloat rpmMin = 0.f;
    CGFloat rpmMax = data.rpmHighLimit;
    _gaugeRpm.minValue = rpmMin;
    
    if (rpmMax < rpmMin)
        rpmMax = rpmMin;
    
    if (rpmMax <= 200)
        _gaugeRpm.maxValue = 200;
    else
        _gaugeRpm.maxValue = ((int)(rpmMax / 100) + 1) * 100;
    _gaugeRpm.scaleDivisions = 5;
    _gaugeRpm.scaleSubdivisions = 5;
    
    _gaugeRpm.showRangeLabels = NO;
    
    _gaugeRpm.rangeValues = @[ [NSNumber numberWithFloat:_gaugeRpm.minValue], [NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:data.rpmHighLimit], [NSNumber numberWithFloat:_gaugeRpm.maxValue]];
    _gaugeRpm.rangeColors = @[ limitColor, limitColor, normalColor, limitColor];
    
    _gaugeRpm.unitOfMeasurement = @"0.0";
    _gaugeRpm.unitOfMeasurementFont = UNIT_OF_MEASUREMENT_FONT;
    _gaugeRpm.showUnitOfMeasurement = SHOW_UNIT_OF_MEASUREMENT;
    _gaugeRpm.scaleDivisionsWidth = SCALE_DIVISIONS_WIDTH;
    _gaugeRpm.scaleSubdivisionsWidth = SCALE_SUB_DIVISIONS_WIDTH;
    _gaugeRpm.rangeLabelsFontColor = RANGE_LABELS_FONT_COLOR;
    _gaugeRpm.rangeLabelsWidth = RANGE_LABELS_WIDTH;
    _gaugeRpm.rangeLabelsFont = RANGE_LABELS_FONT;
    [_gaugeRpm setValue:0 animated:YES];
}

- (void)setGaugeRange:(WMGaugeView *)gauge preMin:(float)preMin preMax:(float)preMax
{
    // min and max value
    int subDivision = 1;
    float scale = 1;
    float dist = preMax - preMin;
    while (true)
    {
        if (dist <= 10)
        {
            if (dist >=7 &&  dist <= 10)
            {
                dist = dist / 2.0;
                scale = scale * 2.0;
                if (scale >= 10)
                    subDivision = 10;
            }
            else if (dist >= 4 && dist <= 6)
            {
                dist = dist;
                scale = scale;
                if (scale >= 10)
                    subDivision = 10;
            }
            else
            {
                dist = dist * 2;
                scale = scale / 2.0;
                if (scale >= 5)
                    subDivision = 5;
            }
            break;
        }
        dist = dist / 10.0;
        scale = scale * 10.0;
    }
    
    float minValue = 0;
    float maxValue = 0;
    
    float start = ((int)preMin / (int)scale) * scale;
    while (true)
    {
        if (start < preMin && (preMin - start) > scale / 2.0)
            break;
        start = start - scale;
    }
    
    minValue = start;
    
    start = ((int)preMax / (int)scale) * scale;
    while (true) {
        if (start > preMax && (start - preMax) > scale / 2.0)
            break;
        start = start + scale;
    }
    
    maxValue = start;
    
    gauge.minValue = minValue;
    gauge.maxValue = maxValue;
    
    
    gauge.scaleDivisions = (int)((maxValue - minValue) / scale);
    gauge.scaleSubdivisions = subDivision;
}

- (void)viewDidAppear:(BOOL)animated
{
    
    for (int i = 0; i < 5; i ++) {
        isShowAlert[i] = YES;
    }
    
    dataReceived = NO;
    
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    [self layoutSubviewsForOrientation:interfaceOrientation];
    
    SettingsData *data = [SettingsData sharedData];
    
    if (data.isBluetooth)
    {
        // start advertising
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
        // start listen
        [NSThread detachNewThreadSelector:@selector(runListener) toTarget:self withObject:nil];
        
        [self.lblStatus setText:@"wifi - listening..."];
        [self.indicator startAnimating];
    }
    
    timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(timerProc:) userInfo:nil repeats:YES];
    
    
    [self initGauges];
    
    [self setStatusImageGray];
    
    
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

- (void)setStatusImageGray
{
    self.ivStatus.image = [UIImage imageNamed:@"status_gray"];
}

- (void)setStatusImageGreen
{
    self.ivStatus.image = [UIImage imageNamed:@"status_green"];
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
    [AutoMessageBox fadeOutMsg];
    
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
    SettingsData *data = [SettingsData sharedData];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        CGFloat lblWidth = 42;
        CGFloat lblHeight = 21;
        CGFloat valueWidth = 57;
        CGFloat bigGaugeWidth = 214;
        CGFloat bigGaugeHeight = 214;
        CGFloat gaugeWidth = 109;
        CGFloat gaugeHeight = 109;
        
        WMGaugeView *gauge1 = nil;
        WMGaugeView *gauge2 = nil;
        UILabel *label1 = nil;
        UILabel *label2 = nil;
        
        
        self.gaugePipe.hidden = self.lblPipe.hidden = YES;
        self.gaugeWob.hidden = self.lblWob.hidden = YES;
        self.gaugeAnn.hidden = self.lblAnn.hidden = YES;
        self.gaugeRpm.hidden = self.lblRpm.hidden = YES;
        
        
        BOOL showTwoGauges = NO;
        if (data.isShowPipe)
        {
            gauge1 = self.gaugePipe;
            label1 = self.lblPipe;
            
        }
        else if (data.isShowWob)
        {
            gauge1 = self.gaugeWob;
            label1 = self.lblWob;
        }
        
        if (data.isShowAnn)
        {
            if (gauge1 == nil)
            {
                gauge1 = self.gaugeAnn;
                label1 = self.lblAnn;
            }
            else
            {
                gauge2 = self.gaugeAnn;
                label2 = self.lblAnn;
                
                showTwoGauges = YES;
            }
        }
        
        if (data.isShowRpm)
        {
            if (gauge1 != nil)
            {
                gauge2 = self.gaugeRpm;
                label2 = self.lblRpm;
                
                showTwoGauges = YES;
            }
            else
            {
                gauge1 = self.gaugeRpm;
                label1 = self.lblRpm;
                
                showTwoGauges = NO;
            }
        }

        
        if(orientation == UIInterfaceOrientationPortrait) {
            
            // gauges
            self.gaugeHs.frame = CGRectMake(53, 64, bigGaugeWidth, bigGaugeHeight);
            
            if (showTwoGauges)
            {
                gauge1.hidden = gauge2.hidden = label1.hidden = label2.hidden = NO;
                
                gauge1.frame = CGRectMake(30, 345, gaugeWidth, gaugeHeight);
                gauge2.frame = CGRectMake(169, 345, gaugeWidth, gaugeHeight);
                
                // gauge labels
                label1.frame = CGRectMake(63, 462, 42, 21);
                label2.frame = CGRectMake(210, 462, 42, 21);
                
            }
            else
            {
                gauge1.hidden = label1.hidden = NO;
                
                gauge1.frame = CGRectMake(100, 345, gaugeWidth, gaugeHeight);
                label1.frame = CGRectMake(133, 462, 42, 21);
            }
            
            // labels
            self.lblInc.frame = CGRectMake(9, 299, lblWidth, lblHeight);
            self.inclination.frame = CGRectMake(50, 299, valueWidth, lblHeight);
            self.lblAz.frame = CGRectMake(108, 299, lblWidth, lblHeight);
            self.azimuth.frame = CGRectMake(154, 299, valueWidth, lblHeight);
            self.lblMd.frame = CGRectMake(211, 299, lblWidth, lblHeight);
            self.measureDepth.frame = CGRectMake(261, 299, valueWidth, lblHeight);

            // alarm, alert
            self.viewAlarm.frame = CGRectMake(rtBount.size.width / 2 - rtAlarm.size.width / 2, rtBount.size.height / 2 - rtAlarm.size.height, rtAlarm.size.width, rtAlarm.size.height);
            
            self.viewAlert.frame = CGRectMake(rtBount.size.width / 2 - rtAlert.size.width / 2, rtBount.size.height / 2, rtAlert.size.width, rtAlert.size.height);

        }
        else {
            
            self.gaugeHs.frame = CGRectMake(33, 64, bigGaugeWidth, bigGaugeHeight);
            
            // gauges
            if (showTwoGauges)
            {
                gauge1.hidden = gauge2.hidden = label1.hidden = label2.hidden = NO;
                
                gauge1.frame = CGRectMake(400, 36, gaugeWidth, gaugeHeight);
                gauge2.frame = CGRectMake(400, 186, gaugeWidth, gaugeHeight);
                
                label1.frame = CGRectMake(433, 155, 42, 21);
                label2.frame = CGRectMake(433, 296, 42, 21);
            }
            else
            {
                gauge1.hidden = label1.hidden = NO;
                
                gauge1.frame = CGRectMake(400, 111, gaugeWidth, gaugeHeight);
                label1.frame = CGRectMake(433, 230, 42, 21);
            }
            
            CGFloat lblLeft = 280;
            CGFloat valueLeft = 330;
            
            // labels
            self.lblInc.frame = CGRectMake(lblLeft, 93, lblWidth, lblHeight);
            self.inclination.frame = CGRectMake(valueLeft, 93, valueWidth, lblHeight);
            
            self.lblAz.frame = CGRectMake(lblLeft, 122, lblWidth, lblHeight);
            self.azimuth.frame = CGRectMake(valueLeft, 122, valueWidth, lblHeight);
            
            self.lblMd.frame = CGRectMake(lblLeft, 151, lblWidth, lblHeight);
            self.measureDepth.frame = CGRectMake(valueLeft, 151, valueWidth, lblHeight);
            
            
            
            self.viewAlarm.frame = CGRectMake(rtBount.size.height / 2 - rtAlarm.size.width / 2, rtBount.size.width / 2 - rtAlarm.size.height, rtAlarm.size.width, rtAlarm.size.height);
            
            self.viewAlert.frame = CGRectMake(rtBount.size.height / 2 - rtAlert.size.width / 2, rtBount.size.width / 2, rtAlert.size.width, rtAlert.size.height);
        }
        
        
    }
    else {
        CGFloat lblWidth = 42;
        CGFloat lblHeight = 21;
        CGFloat valueWidth = 57;
        CGFloat bigGaugeWidth = 428;
        CGFloat bigGaugeHeight = 428;
        CGFloat gaugeWidth = 191;
        CGFloat gaugeHeight = 191;
        
        WMGaugeView *gauge1 = nil;
        WMGaugeView *gauge2 = nil;
        WMGaugeView *gauge3 = nil;
        
        UILabel *label1 = nil;
        UILabel *label2 = nil;
        UILabel *label3 = nil;
        
        self.gaugePipe.hidden = self.lblPipe.hidden = YES;
        self.gaugeWob.hidden = self.lblWob.hidden = YES;
        self.gaugeAnn.hidden = self.lblAnn.hidden = YES;
        self.gaugeRpm.hidden = self.lblRpm.hidden = YES;
        
        if (data.isShowPipe) {
            gauge1 = self.gaugePipe;
            label1 = self.lblPipe;
        }
        else if (data.isShowWob)
        {
            gauge1 = self.gaugeWob;
            label1 = self.lblWob;
        }
        
        if (data.isShowAnn)
        {
            if (gauge1 == nil)
            {
                gauge1 = self.gaugeAnn;
                label1 = self.lblAnn;
            }
            else
            {
                gauge2 = self.gaugeAnn;
                label2 = self.lblAnn;
            }
        }
        
        if (data.isShowRpm)
        {
            if (gauge1 == nil)
            {
                gauge1 = self.gaugeRpm;
                label1 = self.lblRpm;
            }
            else if (gauge2 == nil)
            {
                gauge2 = self.gaugeRpm;
                label2 = self.lblRpm;
            }
            else
            {
                gauge3 = self.gaugeRpm;
                label3 = self.lblRpm;
            }
        }
        
        if(orientation == UIInterfaceOrientationPortrait) {
            // gauges
            self.gaugeHs.frame = CGRectMake(170, 56, bigGaugeWidth, bigGaugeHeight);
            
            
            if (gauge3 != nil)
            {
                gauge1.hidden = label1.hidden = NO;
                gauge2.hidden = label2.hidden = NO;
                gauge3.hidden = label3.hidden = NO;
                
                gauge1.frame = CGRectMake(50, 610, gaugeWidth, gaugeHeight);
                gauge2.frame = CGRectMake(290, 610, gaugeWidth, gaugeHeight);
                gauge3.frame = CGRectMake(530, 610, gaugeWidth, gaugeHeight);
                
                label1.frame = CGRectMake(124, 815, lblWidth, lblHeight);
                label2.frame = CGRectMake(364, 815, lblWidth, lblHeight);
                label3.frame = CGRectMake(604, 815, lblWidth, lblHeight);
            }
            else if (gauge2 != nil)
            {
                gauge1.hidden = label1.hidden = NO;
                gauge2.hidden = label2.hidden = NO;
               
                gauge1.frame = CGRectMake(118, 610, gaugeWidth, gaugeHeight);
                gauge2.frame = CGRectMake(471, 610, gaugeWidth, gaugeHeight);
                
                label1.frame = CGRectMake(192, 815, lblWidth, lblHeight);
                label2.frame = CGRectMake(545, 815, lblWidth, lblHeight);
            }
            else if (gauge1 != nil)
            {
                gauge1.hidden = label1.hidden = NO;
                
                gauge1.frame = CGRectMake(290, 610, gaugeWidth, gaugeHeight);
                label1.frame = CGRectMake(364, 815, lblWidth, lblHeight);
            }
            
            // labels
            CGFloat lblTop = 501;
            self.lblInc.frame = CGRectMake(230, lblTop, lblWidth, lblHeight);
            self.inclination.frame = CGRectMake(271, lblTop, valueWidth, lblHeight);
            self.lblAz.frame = CGRectMake(329, lblTop, lblWidth, lblHeight);
            self.azimuth.frame = CGRectMake(375, lblTop, valueWidth, lblHeight);
            self.lblMd.frame = CGRectMake(432, lblTop, lblWidth, lblHeight);
            self.measureDepth.frame = CGRectMake(482, lblTop, valueWidth, lblHeight);
            
            
            
            self.viewAlarm.frame = CGRectMake(rtBount.size.width / 2 - rtAlarm.size.width / 2, rtBount.size.height / 2 - rtAlarm.size.height, rtAlarm.size.width, rtAlarm.size.height);
            
            self.viewAlert.frame = CGRectMake(rtBount.size.width / 2 - rtAlert.size.width / 2, rtBount.size.height / 2, rtAlert.size.width, rtAlert.size.height);
        }
        else {
            // gauges
            self.gaugeHs.frame = CGRectMake(111, 180, bigGaugeWidth, bigGaugeHeight);
            
            if (gauge3 != nil)
            {
                gauge1.hidden = label1.hidden = NO;
                gauge2.hidden = label2.hidden = NO;
                gauge3.hidden = label3.hidden = NO;
                
                gauge1.frame = CGRectMake(730, 40, gaugeWidth, gaugeHeight);
                gauge2.frame = CGRectMake(730, 285, gaugeWidth, gaugeHeight);
                gauge3.frame = CGRectMake(730, 530, gaugeWidth, gaugeHeight);
                
                label1.frame = CGRectMake(800, 240, 42, 21);
                label2.frame = CGRectMake(800, 485, 42, 21);
                label3.frame = CGRectMake(800, 730, 42, 21);
            }
            else if (gauge2 != nil)
            {
                gauge1.hidden = label1.hidden = NO;
                gauge2.hidden = label2.hidden = NO;

                gauge1.frame = CGRectMake(730, 148, gaugeWidth, gaugeHeight);
                gauge2.frame = CGRectMake(730, 411, gaugeWidth, gaugeHeight);
                
                label1.frame = CGRectMake(800, 348, 42, 21);
                label2.frame = CGRectMake(800, 611, 42, 21);
            }
            else if (gauge1 != nil)
            {
                gauge1.hidden = label1.hidden = NO;
                
                gauge1.frame = CGRectMake(730, 290, gaugeWidth, gaugeHeight);
                label1.frame = CGRectMake(800, 490, 42, 21);
            }
            
            CGFloat lblLeft = 573;
            CGFloat valueLeft = 614;
            
            // labels
            self.lblInc.frame = CGRectMake(lblLeft, 327, lblWidth, lblHeight);
            self.inclination.frame = CGRectMake(valueLeft, 327, valueWidth, lblHeight);
            
            self.lblAz.frame = CGRectMake(lblLeft, 362, lblWidth, lblHeight);
            self.azimuth.frame = CGRectMake(valueLeft, 362, valueWidth, lblHeight);
            
            self.lblMd.frame = CGRectMake(lblLeft, 401, lblWidth, lblHeight);
            self.measureDepth.frame = CGRectMake(valueLeft, 401, valueWidth, lblHeight);
            
            
            
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
            [self.gaugeHs setValue:tf];
        }
        if ([dictionary objectForKey:@"NewP1"]){
            
            
            if (settingData.isShowPipe)
            {
                float fp1 = [[[notification userInfo] valueForKey:@"NewP1"] floatValue];
                [self.gaugePipe setValue:fp1];
                
                if (settingData.isPipeHighLimit)
                {
                    if (settingData.pipeHighLimit < fp1 && isShowAlert[0] == YES)
                    {
                        isShowAlert[0] = NO;
                        [self performSelectorOnMainThread:@selector(showPipeHighLimitAlert:) withObject:(id)[NSNumber numberWithFloat:fp1] waitUntilDone:NO];
                        /* NSTimer *timer = */ [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(alertTimerProc:) userInfo:(id)[NSNumber numberWithInteger:0] repeats:NO];
                    }
                }
                if (settingData.isPipeLowLimit)
                {
                    if (settingData.pipeLowLimit > fp1 && isShowAlert[1] == YES)
                    {
                        isShowAlert[1] = NO;
                        [self performSelectorOnMainThread:@selector(showPipeLowLimitAlert:) withObject:[NSNumber numberWithFloat:fp1] waitUntilDone:NO];
                        /* NSTimer *timer = */ [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(alertTimerProc:) userInfo:[NSNumber numberWithInteger:1] repeats:NO];
                    }
                }
            }
        }
        if ([dictionary objectForKey:@"NewP2"]){
            
            if (settingData.isShowAnn)
            {
                float fp2 = [[[notification userInfo] valueForKey:@"NewP2"] floatValue];
                [self.gaugeAnn setValue:fp2];
                
                if (settingData.isAnnHighLimit)
                {
                    if (settingData.annHighLimit < fp2 && isShowAlert[2] == YES)
                    {
                        isShowAlert[2] = NO;
                        [self performSelectorOnMainThread:@selector(showAnnHighLimitAlert:) withObject:(id)[NSNumber numberWithFloat:fp2] waitUntilDone:NO];
                        /* NSTimer *timer = */ [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(alertTimerProc:) userInfo:(id)[NSNumber numberWithInteger:2] repeats:NO];
                    }
                }
                if (settingData.isAnnLowLimit)
                {
                    if (settingData.annLowLimit > fp2 && isShowAlert[3] == YES)
                    {
                        isShowAlert[3] = NO;
                        [self performSelectorOnMainThread:@selector(showAnnLowLimitAlert:) withObject:[NSNumber numberWithFloat:fp2] waitUntilDone:NO];
                        /* NSTimer *timer = */ [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(alertTimerProc:) userInfo:[NSNumber numberWithInteger:3] repeats:NO];
                    }
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
            
            if (settingData.isShowRpm)
            {
                float rpm = [[[notification userInfo] valueForKey:@"NewRPM"] floatValue];
                [self.gaugeRpm setValue:rpm];
                
                if (settingData.isRpmHighLimit)
                {
                    if (settingData.rpmHighLimit < rpm && isShowAlert[4] == YES)
                    {
                        isShowAlert[4] = NO;
                        [self performSelectorOnMainThread:@selector(showRpmHighLimitAlert:) withObject:[NSNumber numberWithFloat:rpm] waitUntilDone:NO];
                        /* NSTimer *timer = */ [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(alertTimerProc:) userInfo:[NSNumber numberWithInteger:3] repeats:NO];
                    }
                }
            }
        }
        if ([dictionary objectForKey:@"NewWOB"]){
            
            if (settingData.isShowWob)
            {
                float wob = [[[notification userInfo] valueForKey:@"NewWOB"] floatValue];
                [self.gaugeWob setValue:wob];
            }
        }
        //dataIn.hidden = ! dataIn.hidden;
        
        dataReceived = YES;
        self.lblStatus.text = @"Data receiving...";
        [self setStatusImageGreen];
        [self performSelector:@selector(setStatusImageGray) withObject:nil afterDelay:1.0];
    }
}

- (void)addReceivedText:(NSString *)str
{
    if (str != nil && ![str isEqualToString:@""] && ![str isEqualToString:@"no msg"])
    {
        // show message box       
        [AutoMessageBox AutoMsgInView:self.view withText:str];
    }
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
            NSString *stringWithoutColons = [theStrValue stringByReplacingOccurrencesOfString:@"," withString:@""];
            float theFloatValue = [stringWithoutColons floatValue];
            
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
            else if ([secretCode isEqualToString:@"wb="])
            {
                forKeyName = @"NewWOB";
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
    self.listener = nil;
}


- (void) runListener
{
    SettingsData *data = [SettingsData sharedData];
    
    self.listener = [[UDPlistenerDelegate alloc] init];
    [self.listener runServerOnPort:data.port];
    
}

- (void)restartWifiListening
{
    SettingsData *data = [SettingsData sharedData];
    
    if (data.isBluetooth == NO && self.listener != nil)
    {
        [self stopListen];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [NSThread detachNewThreadSelector:@selector(runListener) toTarget:self withObject:nil];
        });
    }
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

- (void)showRpmHighLimitAlert:(NSNumber *)value
{
    NSString *strTitle = @"RPM high limit alert";
    [self showAlert:strTitle limit:[SettingsData sharedData].rpmHighLimit value:[value floatValue]];
}

@end
