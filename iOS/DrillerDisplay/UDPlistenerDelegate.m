//
//  UDPlistenerDelegate.m
//  DrillerDisplay
//
//  Created by Charles Witherup on 3/29/12.
//  Copyright (c) 2012 Vector Magnetics LLC. All rights reserved.
//

#import "UDPlistenerDelegate.h"

@implementation UDPlistenerDelegate

- (void)dealloc
{
    [self->_echo stop];
    [self->_sendTimer invalidate];
}

@synthesize echo      = _echo;
@synthesize sendTimer = _sendTimer;
@synthesize sendCount = _sendCount;

- (BOOL)runServerOnPort:(NSUInteger)port
// One of two Objective-C 'mains' for this program.  This creates a UDPEcho 
// object and runs it in server mode.
{
    assert(self.echo == nil);
    
    self.echo = [[UDPEcho alloc] init];
    assert(self.echo != nil);
    
    self.echo.delegate = self;
    
    [self.echo startServerOnPort:port];
    
    while (self.echo != nil) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    
    // The loop above is supposed to run forever.  If it doesn't, something must 
    // have failed and we want main to return EXIT_FAILURE.
    
    return NO;
}

- (BOOL)runClientWithHost:(NSString *)host port:(NSUInteger)port
// One of two Objective-C 'mains' for this program.  This creates a UDPEcho 
// object in client mode, talking to the specified host and port, and then 
// periodically sends packets via that object.
{
    assert(host != nil);
    assert( (port > 0) && (port < 65536) );
    
    assert(self.echo == nil);
    
    self.echo = [[UDPEcho alloc] init];
    assert(self.echo != nil);
    
    self.echo.delegate = self;
    
    [self.echo startConnectedToHostName:host port:port];
    
    while (self.echo != nil) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    
    // The loop above is supposed to run forever.  If it doesn't, something must 
    // have failed and we want main to return EXIT_FAILURE.
    
    return NO;
}

- (void)sendPacket:(NSString *)stringData
// Called by the client code to send a UDP packet.  This is called immediately 
// after the client has 'connected', and periodically after that from the send 
// timer.
{
    NSData *    data;
    
    assert(self.echo != nil);
//    assert( ! self.echo.isServer );
    
//    data = [[NSString stringWithFormat:@"%zu bottles of beer on the wall", (99 - self.sendCount)] dataUsingEncoding:NSUTF8StringEncoding];
//    data = [[NSString stringWithFormat:@"%s",stringData] dataUsingEncoding:NSUTF8StringEncoding];
    data = [stringData dataUsingEncoding:NSUTF8StringEncoding];
    assert(data != nil);
    
    NSLog(@"UDPListenerDelegate sendPacket of %@ : %@", data, stringData);
    self.echo.outBoundData = data;
    self.echo.dataToSend = TRUE;
    //self.echo.sendStuff;
    
    //[self.echo sendData:data];
    
    self.sendCount += 1;
    if (self.sendCount > 99) {
        self.sendCount = 0;
    }
}

- (void)echo:(UDPEcho *)echo didReceiveData:(NSData *)data fromAddress:(NSData *)addr
// This UDPEcho delegate method is called after successfully receiving data.
{
    assert(echo == self.echo);
#pragma unused(echo)
    assert(data != nil);
    assert(addr != nil);
    NSDictionary *userInfo;  
    
    NSString *convertedString = [ [NSString alloc]initWithData:data encoding:NSASCIIStringEncoding];
    NSString *secretCode = [[convertedString substringToIndex:(3)] lowercaseString];
    
    if ([secretCode  isEqualToString:@"ala"])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"doAlarm" object:nil userInfo:nil]; 
    }
    else 
    {
        
        NSString *theStrValue = [convertedString substringWithRange:NSMakeRange(3, [convertedString length] - 3)];
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

- (void)echo:(UDPEcho *)echo didReceiveError:(NSError *)error
// This UDPEcho delegate method is called after a failure to receive data.
{
    assert(echo == self.echo);
#pragma unused(echo)
    assert(error != nil);
    //NSLog(@"received error: %@", DisplayErrorFromError(error));
}

- (void)echo:(UDPEcho *)echo didSendData:(NSData *)data toAddress:(NSData *)addr
    // This UDPEcho delegate method is called after successfully sending data.
{
    assert(echo == self.echo);
    #pragma unused(echo)
    assert(data != nil);
    assert(addr != nil);
    NSLog(@"    sent %@ (%@) to   %@ (%@)", data, DisplayStringFromData(data), addr, DisplayAddressForAddress(addr));
}

- (void)echo:(UDPEcho *)echo didFailToSendData:(NSData *)data toAddress:(NSData *)addr error:(NSError *)error
    // This UDPEcho delegate method is called after a failure to send data.
{
    assert(echo == self.echo);
    #pragma unused(echo)
    assert(data != nil);
    assert(addr != nil);
    assert(error != nil);
    NSLog(@"Fail of sending %@ (%@) to   %@, error: %@", DisplayStringFromData(data), data, DisplayAddressForAddress(addr), error);
}

static NSString * DisplayAddressForAddress(NSData * address)
// Returns a dotted decimal string for the specified address (a (struct sockaddr) 
// within the address NSData).
{
    int         err;
    NSString *  result;
    char        hostStr[NI_MAXHOST];
    char        servStr[NI_MAXSERV];
    
    result = nil;
    
    if (address != nil) {
        
        // If it's a IPv4 address embedded in an IPv6 address, just bring it as an IPv4 
        // address.  Remember, this is about display, not functionality, and users don't 
        // want to see mapped addresses.
        
        if ([address length] >= sizeof(struct sockaddr_in6)) {
            const struct sockaddr_in6 * addr6Ptr;
            
            addr6Ptr = [address bytes];
            if (addr6Ptr->sin6_family == AF_INET6) {
                if ( IN6_IS_ADDR_V4MAPPED(&addr6Ptr->sin6_addr) || IN6_IS_ADDR_V4COMPAT(&addr6Ptr->sin6_addr) ) {
                    struct sockaddr_in  addr4;
                    
                    memset(&addr4, 0, sizeof(addr4));
                    addr4.sin_len         = sizeof(addr4);
                    addr4.sin_family      = AF_INET;
                    addr4.sin_port        = addr6Ptr->sin6_port;
                    addr4.sin_addr.s_addr = addr6Ptr->sin6_addr.__u6_addr.__u6_addr32[3];
                    address = [NSData dataWithBytes:&addr4 length:sizeof(addr4)];
                    assert(address != nil);
                }
            }
        }
        err = getnameinfo([address bytes], (socklen_t) [address length], hostStr, sizeof(hostStr), servStr, sizeof(servStr), NI_NUMERICHOST | NI_NUMERICSERV);
        if (err == 0) {
            result = [NSString stringWithFormat:@"%s:%s", hostStr, servStr];
            assert(result != nil);
        }
    }
    
    return result;
}

static NSString * DisplayStringFromData(NSData *data)
// Returns a human readable string for the given data.
{
    NSMutableString *   result;
    NSUInteger          dataLength;
    NSUInteger          dataIndex;
    const uint8_t *     dataBytes;
    
    assert(data != nil);
    
    dataLength = [data length];
    dataBytes  = [data bytes];
    
    result = [NSMutableString stringWithCapacity:dataLength];
    assert(result != nil);
    
    [result appendString:@"\""];
    for (dataIndex = 0; dataIndex < dataLength; dataIndex++) {
        uint8_t     ch;
        
        ch = dataBytes[dataIndex];
        if (ch == 10) {
            [result appendString:@"\n"];
        } else if (ch == 13) {
            [result appendString:@"\r"];
        } else if (ch == '"') {
            [result appendString:@"\\\""];
        } else if (ch == '\\') {
            [result appendString:@"\\\\"];
        } else if ( (ch >= ' ') && (ch < 127) ) {
            [result appendFormat:@"%c", (int) ch];
        } else {
            [result appendFormat:@"\\x%02x", (unsigned int) ch];
        }
    }
    [result appendString:@"\""];
    
    return result;
}

- (void)echo:(UDPEcho *)echo didStartWithAddress:(NSData *)address
// This UDPEcho delegate method is called after the object has successfully started up.
{
}

- (void)echo:(UDPEcho *)echo didStopWithError:(NSError *)error
// This UDPEcho delegate method is called  after the object stops spontaneously.
{
}

@end

//int mainto(int argc, char **argv)
//{
//#pragma unused(argc)
//#pragma unused(argv)
//    int                 retVal;
//    BOOL                success;
//    UDPlistenerDelegate *mainObj;
//    int                 port;
//    
//    
//    retVal = EXIT_FAILURE;
//    success = YES;
//    if ( (argc >= 2) && (argc <= 3) ) {
//        if (argc == 3) {
//            port = atoi(argv[2]);
//        } else {
//            port = 7;
//        }
//        if ( (port > 0) && (port < 65536) ) {
//            if (strcmp(argv[1], "-l") == 0) {
//                retVal = EXIT_SUCCESS;
//                
//                // server mode
//                
//                mainObj = [[UDPlistenerDelegate alloc] init];
//                assert(mainObj != nil);
//                
//                success = [mainObj runServerOnPort:port];
//            } else {
//                NSString *  hostName;
//                
//                hostName = [NSString stringWithUTF8String:argv[1]];
//                if (hostName == nil) {
//                    fprintf(stderr, "%s: invalid host host: %s\n", getprogname(), argv[1]);
//                } else {
//                    retVal = EXIT_SUCCESS;
//                    
//                    // client mode
//                    
//                    mainObj = [[UDPlistenerDelegate alloc] init];
//                    assert(mainObj != nil);
//                    
//                    success = [mainObj runClientWithHost:hostName port:port];
//                }
//            }
//        }
//    }
//    
//    if (success) {
//        if (retVal == EXIT_FAILURE) {
//            fprintf(stderr, "usage: %s -l [port]\n",   getprogname());
//            fprintf(stderr, "       %s host [port]\n", getprogname());
//        }
//    } else {
//        retVal = EXIT_FAILURE;
//    }
//    
//    return retVal;
//}
