//
//  OmniaRegistrationSpecHelper.mm
//  OmniaPushSDK
//
//  Created by Rob Szumlakowski on 2014-01-27.
//  Copyright (c) 2014 Omnia. All rights reserved.
//

#import "OmniaRegistrationSpecHelper.h"
#import "OmniaPushRegistrationEngine.h"
#import "OmniaSpecHelper.h"
#import "OmniaPushPersistentStorage.h"
#import "OmniaFakeOperationQueue.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

#define verifyState(stateField, stateResult) \
    if ((stateResult) == BE_TRUE) { \
        (stateField) should be_truthy; \
    } else if ((stateResult) == BE_FALSE) { \
        (stateField) should_not be_truthy; \
    } else if ((stateResult) == BE_NIL) { \
        (stateField) should be_nil; \
    }

#define verifyValue(stateField, expectedValue) \
    if ((expectedValue) == nil) { \
        (stateField) should be_nil; \
    } else { \
        (stateField) should equal((expectedValue)); \
    }

@implementation OmniaRegistrationSpecHelper

#pragma mark - Helper lifecycle

- (instancetype) initWithSpecHelper:(OmniaSpecHelper*)helper
{
    self = [super init];
    if (self) {
        self.helper = helper;
    }
    return self;
}

- (void) setup
{
    self.applicationMessages = [NSMutableArray array];
    self.applicationDelegateMessages = [NSMutableArray array];
    [self.helper setupApplication];
    [self.helper setupApplicationDelegate];
    [self.helper setupParametersWithNotificationTypes:TEST_NOTIFICATION_TYPES];
}

- (void) reset
{
    if (self.helper) {
        [self.helper reset];
        self.helper = nil;
    }
}

#pragma mark - Test setup helpers

- (void) setupApplicationForSuccessfulRegistrationWithNotificationTypes:(UIRemoteNotificationType)notificationTypes
{
    [self.applicationMessages addObject:@"registerForRemoteNotificationTypes:"];
    [self.applicationDelegateMessages addObject:@"application:didRegisterForRemoteNotificationsWithDeviceToken:"];
    [self.helper setupApplicationForSuccessfulRegistrationWithNotificationTypes:TEST_NOTIFICATION_TYPES];
    [self.helper setupApplicationDelegateForSuccessfulRegistration];
}

- (void) setupApplicationForFailedRegistrationWithNotificationTypes:(UIRemoteNotificationType)notificationTypes
                                                              error:(NSError *)error
{
    [self.applicationMessages addObject:@"registerForRemoteNotificationTypes:"];
    [self.applicationDelegateMessages addObject:@"application:didFailToRegisterForRemoteNotificationsWithError:"];
    [self.helper setupApplicationForFailedRegistrationWithNotificationTypes:TEST_NOTIFICATION_TYPES error:error];
    [self.helper setupApplicationDelegateForFailedRegistrationWithError:error];
}

#pragma mark - Test running helpers

- (void) startRegistration
{
    [self.helper.registrationEngine startRegistration:self.helper.params];
    [self.helper.workerQueue drain];
}

#pragma mark - Verification helpers

- (void) verifyDidStartRegistration:(RegistrationStateResult)stateDidStartRegistration
           didStartAPNSRegistration:(RegistrationStateResult)stateDidStartAPNSRegistration
          didFinishAPNSRegistration:(RegistrationStateResult)stateDidFinishAPNSRegistration
         didAPNSRegistrationSucceed:(RegistrationStateResult)stateDidAPNSRegistrationSucceed
            didAPNSRegistrationFail:(RegistrationStateResult)stateDidAPNSRegistrationFail
      didStartBackendUnregistration:(RegistrationStateResult)stateDidStartBackendUnregistration
     didFinishBackendUnregistration:(RegistrationStateResult)stateDidFinishBackendUnregistration
        didStartBackendRegistration:(RegistrationStateResult)stateDidStartBackendRegistration
       didFinishBackendRegistration:(RegistrationStateResult)stateDidFinishBackendRegistration
             didRegistrationSucceed:(RegistrationStateResult)stateDidRegistrationSucceed
                didRegistrationFail:(RegistrationStateResult)stateDidRegistrationFail
              resultAPNSDeviceToken:(NSData*)resultApnsDeviceToken
        resultAPNSRegistrationError:(NSError*)resultApnsRegistrationError
{
    verifyState(self.helper.registrationEngine.didStartRegistration, stateDidStartRegistration);
    verifyState(self.helper.registrationEngine.didStartAPNSRegistration, stateDidStartAPNSRegistration);
    verifyState(self.helper.registrationEngine.didFinishAPNSRegistration, stateDidFinishAPNSRegistration);
    verifyState(self.helper.registrationEngine.didAPNSRegistrationSucceed, stateDidAPNSRegistrationSucceed);
    verifyState(self.helper.registrationEngine.didAPNSRegistrationFail, stateDidAPNSRegistrationFail);
    verifyState(self.helper.registrationEngine.didStartBackendUnregistration, stateDidStartBackendUnregistration);
    verifyState(self.helper.registrationEngine.didFinishBackendUnregistration, stateDidFinishBackendUnregistration);
    verifyState(self.helper.registrationEngine.didStartBackendRegistration, stateDidStartBackendRegistration);
    verifyState(self.helper.registrationEngine.didFinishBackendRegistration, stateDidFinishBackendRegistration);
    verifyState(self.helper.registrationEngine.didRegistrationSucceed, stateDidRegistrationSucceed);
    verifyState(self.helper.registrationEngine.didRegistrationFail, stateDidRegistrationFail);
    verifyValue(self.helper.registrationEngine.apnsDeviceToken, resultApnsDeviceToken);
    verifyValue(self.helper.registrationEngine.apnsRegistrationError, resultApnsRegistrationError);
    verifyValue([self.helper.storage loadAPNSDeviceToken], resultApnsDeviceToken);
}

- (void) verifyQueueCompletedOperations:(NSArray*)completedOperations
                 notCompletedOperations:(NSArray*)notCompletedOperations;
{
    for (Class classOfOperation : completedOperations) {
        [self.helper.workerQueue didFinishOperation:classOfOperation] should be_truthy;
    }
    for (Class classOfOperation : notCompletedOperations) {
        [self.helper.workerQueue didFinishOperation:classOfOperation] should_not be_truthy;
    }
}

- (void) verifyMessages
{
    for (NSString *message in self.applicationMessages) {
        self.helper.application should have_received([message cStringUsingEncoding:NSUTF8StringEncoding]);
    }
    for (NSString *message in self.applicationDelegateMessages) {
        self.helper.applicationDelegate should have_received([message cStringUsingEncoding:NSUTF8StringEncoding]);
    }
}

@end
