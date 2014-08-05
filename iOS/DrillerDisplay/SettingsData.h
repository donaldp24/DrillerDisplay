//
//  SettingsData.h
//  DrillerDisplay
//
//  Created by Donald Pae on 4/1/14.
//  Copyright (c) 2014 Donald Pae. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SettingsData : NSObject

@property (nonatomic) BOOL isBluetooth;
@property (nonatomic, retain) NSString *ipAddress;
@property (nonatomic) int port;
@property (nonatomic) BOOL isPipeHighLimit;
@property (nonatomic) float pipeHighLimit;
@property (nonatomic) BOOL isPipeLowLimit;
@property (nonatomic) float pipeLowLimit;
@property (nonatomic) BOOL isAnnHighLimit;
@property (nonatomic) float annHighLimit;
@property (nonatomic) BOOL isAnnLowLimit;
@property (nonatomic) float annLowLimit;
@property (nonatomic) BOOL isRpmHighLimit;
@property (nonatomic) float rpmHighLimit;
@property (nonatomic) BOOL isShowPipe;
@property (nonatomic) BOOL isShowWob;
@property (nonatomic) BOOL isShowAnn;
@property (nonatomic) BOOL isShowRpm;

+ (SettingsData *)sharedData;

- (void)loadData;
- (void)saveData;


-(BOOL) readBoolEntry:(NSUserDefaults *)config key:(NSString *) key defaults:(BOOL)defaults;
-(float) readFloatEntry:(NSUserDefaults *)config key:(NSString *) key defaults:(float)defaults;
-(int) readIntEntry:(NSUserDefaults *)config key:(NSString *) key defaults:(int)defaults;
-(double) readDoubleEntry:(NSUserDefaults *)config key:(NSString *) key defaults:(double)defaults;
-(NSString *) readEntry:(NSUserDefaults *)config key:(NSString *) key defaults:(NSString *)defaults;

@end
