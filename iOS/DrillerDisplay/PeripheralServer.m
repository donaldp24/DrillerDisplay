//
//  PeripheralServer.m
//  DrillerDisplay
//
//  Created by Donald Pae on 3/3/14.
//  Copyright (c) 2014 Donald Pae. All rights reserved.
//

#import "PeripheralServer.h"

#ifndef LXCBLog
# define LXCBLog NSLog
#endif

@interface PeripheralServer () <
CBPeripheralManagerDelegate,
UIAlertViewDelegate>

@property(nonatomic, strong) CBPeripheralManager *peripheral;
@property(nonatomic, strong) CBMutableCharacteristic *characteristic;
@property(nonatomic, assign) BOOL serviceRequiresRegistration;
@property(nonatomic, strong) CBMutableService *service;
@property(nonatomic, strong) NSData *pendingData;

@end


@implementation PeripheralServer


+ (BOOL)isBluetoothSupported {
    // Only for iOS 6.0
    if (NSClassFromString(@"CBPeripheralManager") == nil) {
        return NO;
    }
    
    // TODO: Make a check to see if the CBPeripheralManager is in unsupported state.
    return YES;
}


- (id)init {
    return [self initWithDelegate:nil];
}


- (id)initWithDelegate:(id<PeripheralServerDelegate>)delegate {
    self = [super init];
    if (self) {
        self.peripheral =
        [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
        self.delegate = delegate;
    }
    return self;
}

#pragma mark -

- (void)enableService {
    // If the service is already registered, we need to re-register it again.
    if (self.service) {
        [self.peripheral removeService:self.service];
    }
    
    // Create a BTLE Peripheral Service and set it to be the primary. If it
    // is not set to the primary, it will not be found when the app is in the
    // background.
    self.service = [[CBMutableService alloc]
                    initWithType:self.serviceUUID primary:YES];
    
    // Set up the characteristic in the service. This characteristic is only
    // readable through subscription (CBCharacteristicsPropertyNotify) and has
    // no default value set.
    //
    // There is no need to set the permission on characteristic.
    self.characteristic =
    [[CBMutableCharacteristic alloc]
     initWithType:self.characteristicUUID
     properties:CBCharacteristicPropertyNotify | CBCharacteristicPropertyWrite
     value:nil
     permissions:CBAttributePermissionsWriteable] ;
    
    // Assign the characteristic.
    self.service.characteristics =
    [NSArray arrayWithObject:self.characteristic];
    
    // Add the service to the peripheral manager.
    [self.peripheral addService:self.service];
}

- (void)disableService {
    [self.peripheral removeService:self.service];
    self.service = nil;
    [self stopAdvertising];
}


// Called when the BTLE advertisments should start. We don't take down
// the advertisments unless the user switches us off.
- (void)startAdvertising {
    if (self.peripheral.isAdvertising) {
        [self.peripheral stopAdvertising];
    }
    
    NSDictionary *advertisment = @{
                                   CBAdvertisementDataServiceUUIDsKey : @[self.serviceUUID],
                                   CBAdvertisementDataLocalNameKey: self.serviceName
                                   };
    [self.peripheral startAdvertising:advertisment];
}

- (void)stopAdvertising {
    [self.peripheral stopAdvertising];
}

- (BOOL)isAdvertising {
    return [self.peripheral isAdvertising];
}


#pragma mark -

- (void)sendToSubscribers:(NSData *)data {
    if (self.peripheral.state != CBPeripheralManagerStatePoweredOn) {
        LXCBLog(@"sendToSubscribers: peripheral not ready for sending state: %ld", (long)self.peripheral.state);
        return;
    }
    
    BOOL success = [self.peripheral updateValue:data
                              forCharacteristic:self.characteristic
                           onSubscribedCentrals:nil];
    if (!success) {
        LXCBLog(@"Failed to send data, buffering data for retry once ready.");
        self.pendingData = data;
        return;
    }
}

- (void)applicationDidEnterBackground {
    // Deliberately continue advertising so that it still remains discoverable.
}

- (void)applicationWillEnterForeground {
    NSLog(@"applicationWillEnterForeground.");
    // I once thought that it would be good to re-advertise and re-enable
    // the services when coming in the foreground, but it does more harm than
    // good. If we do that, then if there was a Central subscribing to a
    // characteristic, that would get reset.
    //
    // So here we deliberately avoid re-enabling or re-advertising the service.
}

#pragma mark - CBPeripheralManagerDelegate

- (void)peripheralManager:(CBPeripheralManager *)peripheral
            didAddService:(CBService *)service
                    error:(NSError *)error {
    // As soon as the service is added, we should start advertising.
    [self startAdvertising];
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    switch (peripheral.state) {
        case CBPeripheralManagerStatePoweredOn:
            NSLog(@"peripheralStateChange: Powered On");
            // As soon as the peripheral/bluetooth is turned on, start initializing
            // the service.
            [self enableService];
            break;
        case CBPeripheralManagerStatePoweredOff: {
            NSLog(@"peripheralStateChange: Powered Off");
            [self disableService];
            self.serviceRequiresRegistration = YES;
            break;
        }
        case CBPeripheralManagerStateResetting: {
            NSLog(@"peripheralStateChange: Resetting");
            self.serviceRequiresRegistration = YES;
            break;
        }
        case CBPeripheralManagerStateUnauthorized: {
            NSLog(@"peripheralStateChange: Deauthorized");
            [self disableService];
            self.serviceRequiresRegistration = YES;
            break;
        }
        case CBPeripheralManagerStateUnsupported: {
            NSLog(@"peripheralStateChange: Unsupported");
            self.serviceRequiresRegistration = YES;
            // TODO: Give user feedback that Bluetooth is not supported.
            break;
        }
        case CBPeripheralManagerStateUnknown:
            NSLog(@"peripheralStateChange: Unknown");
            break;
        default:
            break;
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral
                  central:(CBCentral *)central
didSubscribeToCharacteristic:(CBCharacteristic *)characteristic {
    LXCBLog(@"didSubscribe: %@", characteristic.UUID);
    if (self.delegate)
        [self.delegate peripheralServer:self centralDidSubscribe:central];
}

#if false
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request {
    
    self.characteristic.value = [@"Hello World" dataUsingEncoding:NSUTF8StringEncoding];
    
    if ([request.characteristic.UUID isEqual:self.characteristic.UUID]) {
        if (request.offset > self.characteristic.value.length) {
            [self.peripheral respondToRequest:request withResult:CBATTErrorInvalidOffset];
            return;
        }
        
        request.value = [self.characteristic.value subdataWithRange:NSMakeRange(request.offset, self.characteristic.value.length - request.offset)];
        [self.peripheral respondToRequest:request withResult:CBATTErrorSuccess];
    }
}
#endif

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray *)requests {
    for (CBATTRequest *request in requests) {
        self.characteristic.value = request.value;
        if (self.delegate)
            [self.delegate peripheralServer:self receiveValue:request.value];
    }
    if (requests != nil)
        if (requests.count > 0)
        [self.peripheral respondToRequest:[requests objectAtIndex:0]
                               withResult:CBATTErrorSuccess];
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral
                  central:(CBCentral *)central
didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic {
    if (self.delegate)
        [self.delegate peripheralServer:self centralDidUnsubscribe:central];
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral
                                       error:(NSError *)error {
    if (error) {
        LXCBLog(@"didStartAdvertising: Error: %@", error);
        return;
    }
    LXCBLog(@"didStartAdvertising");
}

- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral {
    LXCBLog(@"isReadyToUpdateSubscribers");
    if (self.pendingData) {
        NSData *data = [self.pendingData copy];
        self.pendingData = nil;
        [self sendToSubscribers:data];
    }
}

@end
