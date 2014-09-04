//
//  PeripheralServer.h
//  DrillerDisplay
//
//  Created by Donald Pae on 3/3/14.
//  Copyright (c) 2014 Donald Pae. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>


@protocol PeripheralServerDelegate;

@interface PeripheralServer : NSObject

@property(nonatomic, assign) id<PeripheralServerDelegate> delegate;

@property(nonatomic, strong) NSString *serviceName;
@property(nonatomic, strong) CBUUID *serviceUUID;
@property(nonatomic, strong) CBUUID *characteristicUUID;



// Returns YES if Bluetooth 4 LE is supported on this operation system.
+ (BOOL)isBluetoothSupported;

- (id)initWithDelegate:(id<PeripheralServerDelegate>)delegate;

- (void)sendToSubscribers:(NSData *)data;

// Called by the application if it enters the background.
- (void)applicationDidEnterBackground;

// Called by the application if it enters the foregroud.
- (void)applicationWillEnterForeground;

// Allows turning on or off the advertisments.
- (void)startAdvertising;
- (void)stopAdvertising;
- (BOOL)isAdvertising;


@end


// Simplified protocol to respond to subscribers.
@protocol PeripheralServerDelegate <NSObject>

// Called when the peripheral receives a new subscriber.
- (void)peripheralServer:(PeripheralServer *)peripheral centralDidSubscribe:(CBCentral *)central;

- (void)peripheralServer:(PeripheralServer *)peripheral centralDidUnsubscribe:(CBCentral *)central;

- (void)peripheralServer:(PeripheralServer *)peripheral receiveValue:(NSData *)data;

@end