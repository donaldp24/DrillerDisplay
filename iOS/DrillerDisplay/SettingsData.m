//
//  SettingsData.m
//  DrillerDisplay
//
//  Created by Donald Pae on 4/1/14.
//  Copyright (c) 2014 Donald Pae. All rights reserved.
//

#import "SettingsData.h"

static SettingsData *_instance = nil;

#define kDataBluetoothKey   @"bluetooth"
#define kDataAddressKey   @"address"
#define kDataPortKey   @"port"
#define kDataIsPipeHighKey   @"ispipehigh"
#define kDataPipeHighKey   @"pipehigh"
#define kDataIsPipeLowKey   @"ispipelow"
#define kDataPipeLowKey   @"pipelow"
#define kDataIsAnnHighKey   @"isannhigh"
#define kDataAnnHighKey   @"annhigh"
#define kDataIsAnnLowKey   @"isannlow"
#define kDataAnnLowKey   @"annlow"
#define kDataIsRpmHighKey   @"isrpmhigh"
#define kDataRpmHighKey     @"rpmhigh"
#define kDataIsShowPipe     @"isshowpipe"
#define kDataIsShowWob      @"isshowwob"
#define kDataIsShowAnn      @"isshowann"
#define kDataIsShowRpm      @"isshowrpm"


@implementation SettingsData

+ (SettingsData *)sharedData
{
    if (_instance == nil)
    {
        _instance = [[SettingsData alloc] init];
        [_instance loadData];
    }
    return _instance;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.isBluetooth = NO;
        self.ipAddress = @"255.255.255.255";
        self.port = 7123;
        self.isPipeHighLimit = YES;
        self.pipeHighLimit = 1000;
        self.isPipeLowLimit = YES;
        self.pipeLowLimit = 0;
        self.isAnnHighLimit = YES;
        self.annHighLimit = 100;
        self.isAnnLowLimit = YES;
        self.isAnnLowLimit = 0;
        self.isRpmHighLimit = NO;
        self.rpmHighLimit = 150;
        
        self.isShowPipe = YES;
        self.isShowWob = NO;
        self.isShowAnn = NO;
        self.isShowRpm = YES;
    }
    return self;
}

- (void)loadData
{
    NSUserDefaults *config = [NSUserDefaults standardUserDefaults];
    self.isBluetooth = [self readBoolEntry:config key:kDataBluetoothKey defaults:NO];
    self.ipAddress = [self readEntry:config key:kDataAddressKey defaults:@"255.255.255.255"];
    self.port = [self readIntEntry:config key:kDataPortKey defaults:7123];
    
    self.isPipeHighLimit = [self readBoolEntry:config key:kDataIsPipeHighKey defaults:NO];
    self.pipeHighLimit = [self readFloatEntry:config key:kDataPipeHighKey defaults:300.0];
    
    self.isPipeLowLimit = [self readBoolEntry:config key:kDataIsPipeLowKey defaults:NO];
    self.pipeLowLimit = [self readFloatEntry:config key:kDataPipeLowKey defaults:0.0];
    
    self.isAnnHighLimit = [self readBoolEntry:config key:kDataIsAnnHighKey defaults:NO];
    self.annHighLimit = [self readFloatEntry:config key:kDataAnnHighKey defaults:300.0];
    
    self.isAnnLowLimit = [self readBoolEntry:config key:kDataIsAnnLowKey defaults:NO];
    self.annLowLimit = [self readFloatEntry:config key:kDataAnnLowKey defaults:0.0];
    
    self.isRpmHighLimit = [self readBoolEntry:config key:kDataIsRpmHighKey defaults:NO];
    self.rpmHighLimit = [self readFloatEntry:config key:kDataRpmHighKey defaults:150];
    
    self.isShowPipe = [self readBoolEntry:config key:kDataIsShowPipe defaults:YES];
    self.isShowWob = [self readBoolEntry:config key:kDataIsShowWob defaults:NO];
    self.isShowAnn = [self readBoolEntry:config key:kDataIsShowAnn defaults:NO];
    self.isShowRpm = [self readBoolEntry:config key:kDataIsShowRpm defaults:YES];
}

- (void)saveData
{
    NSUserDefaults *config = [NSUserDefaults standardUserDefaults];
    [config setBool:self.isBluetooth forKey:kDataBluetoothKey];
    [config setValue:self.ipAddress forKey:kDataAddressKey];
    [config setInteger:self.port forKey:kDataPortKey];
    
    [config setBool:self.isPipeHighLimit forKey:kDataIsPipeHighKey];
    [config setFloat:self.pipeHighLimit forKey:kDataPipeHighKey];
    
    [config setBool:self.isPipeLowLimit forKey:kDataIsPipeLowKey];
    [config setFloat:self.pipeLowLimit forKey:kDataPipeLowKey];
    
    [config setBool:self.isAnnHighLimit forKey:kDataIsAnnHighKey];
    [config setFloat:self.annHighLimit forKey:kDataAnnHighKey];
    
    [config setBool:self.isAnnLowLimit forKey:kDataIsAnnLowKey];
    [config setFloat:self.annLowLimit forKey:kDataAnnLowKey];
    
    [config setBool:self.isRpmHighLimit forKey:kDataIsRpmHighKey];
    [config setFloat:self.rpmHighLimit forKey:kDataRpmHighKey];
    
    [config setBool:self.isShowPipe forKey:kDataIsShowPipe];
    [config setBool:self.isShowWob forKey:kDataIsShowWob];
    [config setBool:self.isShowAnn forKey:kDataIsShowAnn];
    [config setBool:self.isShowRpm forKey:kDataIsShowRpm];
    
    [config synchronize];
}

#pragma mark - Config Manager -
-(BOOL) readBoolEntry:(NSUserDefaults *)config key:(NSString *) key defaults:(BOOL)defaults
{
    if (key == nil)
        return defaults;
    
    NSString *str = [config objectForKey:key];
    
    if (str == nil) {
        return defaults;
    } else {
        return str.boolValue;
    }
    
    return defaults;
}

-(float) readFloatEntry:(NSUserDefaults *)config key:(NSString *) key defaults:(float)defaults
{
    if (key == nil)
        return defaults;
    
    NSString *str = [config objectForKey:key];
    
    if (str == nil) {
        return defaults;
    } else {
        return str.floatValue;
    }
    
    return defaults;
}

-(int) readIntEntry:(NSUserDefaults *)config key:(NSString *) key defaults:(int)defaults
{
    if (key == nil)
        return defaults;
    
    NSString *str = [config objectForKey:key];
    
    if (str == nil) {
        return defaults;
    } else {
        return str.intValue;
    }
    
    return defaults;
}

-(double) readDoubleEntry:(NSUserDefaults *)config key:(NSString *) key defaults:(double)defaults
{
    if (key == nil)
        return defaults;
    
    NSString *str = [config objectForKey:key];
    
    if (str == nil) {
        return defaults;
    } else {
        return str.doubleValue;
    }
    
    return defaults;
}

-(NSString *) readEntry:(NSUserDefaults *)config key:(NSString *) key defaults:(NSString *)defaults
{
    if (key == nil)
        return defaults;
    
    NSString *str = [config objectForKey:key];
    
    if (str == nil) {
        return defaults;
    } else {
        return str;
    }
    
    return defaults;
}



@end
