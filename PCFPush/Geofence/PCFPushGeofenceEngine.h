//
// Created by DX181-XL on 15-04-15.
// Copyright (c) 2015 Pivotal. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PCFPushGeofenceResponseData;
@class PCFPushGeofenceRegistrar;
@class PCFPushGeofencePersistentStore;
@class PCFPushGeofenceLocationMap;
@class CLLocationManager;
@class CLLocation;

@interface PCFPushGeofenceEngine : NSObject

- (id) initWithRegistrar:(PCFPushGeofenceRegistrar *)registrar store:(PCFPushGeofencePersistentStore *)store locationManager:(CLLocationManager *)locationManager;
- (void) processResponseData:(PCFPushGeofenceResponseData*)responseData withTimestamp:(int64_t)timestamp;
- (void) clearLocations:(PCFPushGeofenceLocationMap *)locationsToClear;
- (void) reregisterAllGeofencesWithCurrentLocation:(CLLocation *)currentLocation;

@end