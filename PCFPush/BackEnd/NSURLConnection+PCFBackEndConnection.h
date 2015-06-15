//
//  Copyright (C) 2014 Pivotal Software, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^CompletionHandler)(NSURLResponse *response, NSData *data, NSError *connectionError);

@interface NSURLConnection (PCFBackEndConnection)

+ (void)pcf_sendAsynchronousRequest:(NSURLRequest *)request
                            success:(void (^)(NSURLResponse *, NSData *))success
                            failure:(void (^)(NSError *))failure;

+ (void)pcf_sendAsynchronousRequest:(NSURLRequest *)request
                              queue:(NSOperationQueue *)queue
                            success:(void (^)(NSURLResponse *, NSData *))success
                            failure:(void (^)(NSError *))failure;

+ (void)pcf_sendAsynchronousRequest_wrapper:(NSURLRequest *)request
                                      queue:(NSOperationQueue *)queue
                          completionHandler:(void (^)(NSURLResponse*, NSData*, NSError*))handler;

@end
