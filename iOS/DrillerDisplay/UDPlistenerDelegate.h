//
//  UDPlistenerDelegate.h
//  DrillerDisplay
//
//  Created by Charles Witherup on 3/29/12.
//  Copyright (c) 2012 Vector Magnetics LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UDPEcho.h"
#include <netdb.h>

@interface UDPlistenerDelegate : NSObject <UDPEchoDelegate>
{
    UDPEcho *       _echo;
    NSTimer *       _sendTimer;
    NSUInteger      _sendCount;
}
- (BOOL)runServerOnPort:(NSUInteger)port;
- (BOOL)runClientWithHost:(NSString *)host port:(NSUInteger)port;
- (void)sendPacket:(NSString *)stringData;
@end

@interface UDPlistenerDelegate ()

@property (nonatomic, retain, readwrite) UDPEcho *      echo;
@property (nonatomic, retain, readwrite) NSTimer *      sendTimer;
@property (nonatomic, assign, readwrite) NSUInteger     sendCount;
@end

