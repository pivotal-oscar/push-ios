//
// Created by DX181-XL on 15-04-17.
// Copyright (c) 2015 Pivotal. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "PCFPushGeofenceLocationMap.h"
#import "PCFPushGeofenceData.h"
#import "PCFPushGeofenceLocation.h"
#import "PCFPushGeofenceDataList.h"
#import "PCFPushGeofenceUtil.h"

@interface PCFPushGeofenceLocationMap ()

@property (nonatomic) NSMutableDictionary *dict;

@end

@implementation PCFPushGeofenceLocationMap

+ (instancetype) map
{
    return [[PCFPushGeofenceLocationMap alloc] init];
}

+ (instancetype) mapWithGeofencesInList:(PCFPushGeofenceDataList *)list
{
    PCFPushGeofenceLocationMap *map = [[PCFPushGeofenceLocationMap alloc] init];
    [list enumerateKeysAndObjectsUsingBlock:^(int64_t id, PCFPushGeofenceData *geofence, BOOL *stop) {
        for (PCFPushGeofenceLocation *location in geofence.locations) {
            if (geofence.id >= 0 && location.id >= 0) {
                [map put:geofence location:location];
            }
        }
    }];
    return map;
}

- (instancetype) init
{
    self = [super init];
    if (self) {
        self.dict = [NSMutableDictionary dictionary];
    }
    return self;
}

- (BOOL)isEqual:(id)o
{
    if (![o isKindOfClass:[PCFPushGeofenceLocationMap class]]) {
        return NO;
    }
    PCFPushGeofenceLocationMap *other = (PCFPushGeofenceLocationMap *)o;
    return [other.dict isEqual:self.dict];
}

- (NSUInteger) count
{
    return self.dict.count;
}

- (void) put:(PCFPushGeofenceData*)geofence locationIndex:(NSUInteger)locationIndex
{
    PCFPushGeofenceLocation *location = geofence.locations[locationIndex];
    [self put:geofence location:location];
}

- (void) put:(PCFPushGeofenceData*)geofence location:(PCFPushGeofenceLocation*)location
{
    NSString *iosRequestId = pcfPushRequestIdWithGeofenceId(geofence.id, location.id);
    if (iosRequestId) {
        self.dict[iosRequestId] = location;
    }
}

- (id)objectForKeyedSubscript:(id <NSCopying>)key
{
    return self.dict[key];
}

- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key
{
    self.dict[key] = obj;
}

- (NSArray*)sortKeysByDistanceToLocation:(CLLocation*)deviceLocation
{
    NSArray *sortedKeys = [self.dict.allKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        PCFPushGeofenceLocation *geofenceLocation1 = self[obj1];
        PCFPushGeofenceLocation *geofenceLocation2 = self[obj2];
        CLLocation *location1 = [[CLLocation alloc] initWithLatitude:geofenceLocation1.latitude longitude:geofenceLocation1.longitude];
        CLLocation *location2 = [[CLLocation alloc] initWithLatitude:geofenceLocation2.latitude longitude:geofenceLocation2.longitude];
        NSNumber* dist1 = @([location1 distanceFromLocation:deviceLocation]);
        NSNumber* dist2 = @([location2 distanceFromLocation:deviceLocation]);
        return [dist1 compare:dist2];
    }];
    return sortedKeys;
}

- (void)enumerateKeysAndObjectsUsingBlock:(void (^)(NSString *requestId, PCFPushGeofenceLocation *location, BOOL *stop))block
{
    [self.dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        block(key, obj, stop);
    }];
}

@end