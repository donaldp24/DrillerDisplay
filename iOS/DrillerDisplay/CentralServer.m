//
//  CentralServer.m
//  DrillerDisplay
//
//  Created by Donald Pae on 3/3/14.
//  Copyright (c) 2014 Donald Pae. All rights reserved.
//

#import "CentralServer.h"

@implementation CentralServer


#if false
#pragma mark - peripheral

- (void)discoverServices
{
    
    if (_connected_peripheral == nil)
        return;
    
    NSArray *keys = [NSArray arrayWithObjects:
                     [CBUUID UUIDWithString:@"180A"],
                     [CBUUID UUIDWithString:@"F9266FD7-EF07-45D6-8EB6-BD74F13620F9"],
                     nil];
    NSArray *objects = [NSArray arrayWithObjects:
                        @"Device Information",
                        @"BLE Shield Service",
                        nil];
    
    NSDictionary *serviceNames = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    
    [_connected_peripheral setDelegate:self];
    [_connected_peripheral discoverServices:[serviceNames allKeys]];
    
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if([_connected_peripheral.services count] < 2)
        return;
    
    CBService   *ser;
    NSEnumerator *e = [_connected_peripheral.services objectEnumerator];
    
    while((ser=[e nextObject])) {
        
        if([ser.UUID isEqual:[CBUUID UUIDWithString:@"F9266FD7-EF07-45D6-8EB6-BD74F13620F9"]])
        {
            [self connectService:ser];
        }
    }
}

- (void)connectService:(CBService *)service
{
    _connected_peripheral = service.peripheral;
    //speed_characteristic = nil;
    //heartrate_characteristic = nil;
    //resistance_characteristic = nil;
    _characteristic = nil;
    
    [_connected_peripheral setDelegate:self];
    
    //deviceAddressUUID = [CBUUID UUIDWithString:@"38117F3C-28AB-4718-AB95-172B363F2AE0"];
    //speedUUID = [CBUUID UUIDWithString:@"4585C102-7784-40B4-88E1-3CB5C4FD37A3"];
    //heartrateUUID = [CBUUID UUIDWithString:@"11846C20-6630-11E1-B86C-0800200C9A66"];
    //resistanceUUID = [CBUUID UUIDWithString:@"DAF75440-6EBA-11E1-B0C4-0800200C9A66"];
    /*
     NSArray *keys = [NSArray arrayWithObjects:
     deviceAddressUUID,
     speedUUID,
     heartrateUUID,
     //resistanceUUID,
     nil];
     */
    NSArray *keys = [NSArray arrayWithObjects:
                     [CBUUID UUIDWithString:deviceUUIDString],
                     [CBUUID UUIDWithString:speedUUIDString],
                     [CBUUID UUIDWithString:heartrateUUIDString],
                     nil];
    
    [_connected_peripheral discoverCharacteristics:keys forService:service];
    
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if(error != nil)
    {
        //TODO: handle error
        return;
    }
    
    CBCharacteristic    *tmpCharacteristic;
    NSString            *logString1, *logString2, *logString3, *logString4;
    
    CBUUID *deviceAddressUUID = [CBUUID UUIDWithString:deviceUUIDString];
    CBUUID *speedUUID = [CBUUID UUIDWithString:speedUUIDString];
    CBUUID *heartrateUUID = [CBUUID UUIDWithString:heartrateUUIDString];
    
    //speedUUID = [CBUUID UUIDWithString:@"4585C102-7784-40B4-88E1-3CB5C4FD37A3"];
    //heartrateUUID = [CBUUID UUIDWithString:@"11846C20-6630-11E1-B86C-0800200C9A66"];
    //resistanceUUID = [CBUUID UUIDWithString:@"DAF75440-6EBA-11E1-B0C4-0800200C9A66"];
    
    logString1 = nil;
    logString2 = nil;
    logString3 = nil;
    logString4 = nil;
    
    NSEnumerator *e = [service.characteristics objectEnumerator];
    
    while((tmpCharacteristic = [e nextObject])) {
        /*
         if ([[tmpCharacteristic UUID] isEqual:deviceAddressUUID]) {
         device_address_characteristic = tmpCharacteristic;
         //[_peripheral setNotifyValue:YES forCharacteristic:tmpCharacteristic];
         logString1 = [NSString stringWithFormat:@"device address characteristic is discovered"];
         }
         else if ([[tmpCharacteristic UUID] isEqual:speedUUID]) {
         speed_characteristic = tmpCharacteristic;
         [connected_peripheral setNotifyValue:YES forCharacteristic:tmpCharacteristic];
         logString2 = [NSString stringWithFormat:@"speed characteristic is discovered"];
         }
         else if ([[tmpCharacteristic UUID] isEqual:heartrateUUID]) {
         heartrate_characteristic = tmpCharacteristic;
         [connected_peripheral setNotifyValue:YES forCharacteristic:tmpCharacteristic];
         logString3 = [NSString stringWithFormat:@"heart rate characteristic is discovered"];
         }
         else if ([[tmpCharacteristic UUID] isEqual:resistanceUUID]) {
         resistance_characteristic = tmpCharacteristic;
         //[_peripheral setNotifyValue:YES forCharacteristic:tmpCharacteristic];
         logString4 = [NSString stringWithFormat:@"resistance level characteristic is discovered"];
         }
         */
        if ([[tmpCharacteristic UUID] isEqual:deviceAddressUUID]) {
            logString1 = [NSString stringWithFormat:@"device address characteristic is discovered"];
            [_connected_peripheral setNotifyValue:YES forCharacteristic:tmpCharacteristic];
        }
        else if ([[tmpCharacteristic UUID] isEqual:speedUUID])
        {
            _characteristic = tmpCharacteristic;
            [_connected_peripheral setNotifyValue:YES forCharacteristic:tmpCharacteristic];
            logString2 = [NSString stringWithFormat:@"speed characteristic is discovered"];
        }
        else if ([[tmpCharacteristic UUID] isEqual:heartrateUUID])
        {
            logString3 = [NSString stringWithFormat:@"heart rate characteristic is discovered"];
            [_connected_peripheral setNotifyValue:YES forCharacteristic:tmpCharacteristic];
        }
	}
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"foundCharacteristics"
                                                    message:[NSString stringWithFormat:@"%@ \n%@ \n%@ \n%@",
                                                             logString1,
                                                             logString2,
                                                             logString3,
                                                             logString4]
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles: nil];
    
    [alert show];
    
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if(error != nil)
        return;
    /*
     deviceAddressUUID = [CBUUID UUIDWithString:@"38117F3C-28AB-4718-AB95-172B363F2AE0"];
     speedUUID = [CBUUID UUIDWithString:@"4585C102-7784-40B4-88E1-3CB5C4FD37A3"];
     heartrateUUID = [CBUUID UUIDWithString:@"11846C20-6630-11E1-B86C-0800200C9A66"];
     resistanceUUID = [CBUUID UUIDWithString:@"DAF75440-6EBA-11E1-B0C4-0800200C9A66"];
     
     if([characteristic.UUID isEqual:speedUUID]) {
     [self speedPulseIsReceived];
     }
     if([characteristic.UUID isEqual:heartrateUUID]) {
     [self heartbeatPulseIsReceived];
     }
     */
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    
    //[_peripheral readValueForCharacteristic:characteristic];
    
}

-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    
}


- (NSMutableString*)uuidToString:(CBUUID*) tmpUUID {
    NSData *data = [tmpUUID data];
    NSUInteger bytesToConvert = [data length];
    const unsigned char *uuidBytes = [data bytes];
    NSMutableString *outputString = [NSMutableString stringWithCapacity:16];
    
    for (NSUInteger currentByteIndex = 0; currentByteIndex < bytesToConvert; currentByteIndex++)
    {
        switch (currentByteIndex)
        {
            case 3:
            case 5:
            case 7:
            case 9:[outputString appendFormat:@"%02x-", uuidBytes[currentByteIndex]]; break;
            default:[outputString appendFormat:@"%02x", uuidBytes[currentByteIndex]];
        }
        
    }
    
    return outputString;
}

#endif

@end
