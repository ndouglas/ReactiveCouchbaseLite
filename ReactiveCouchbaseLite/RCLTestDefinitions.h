//
//  RCLTestDefinitions.h
//  ReactiveCouchbaseLite
//
//  Created by Nathan Douglas on 11/19/14.
//  Released into the public domain.
//  See LICENSE for details.
//

#import <XCTest/XCTest.h>
#import "ReactiveCouchbaseLite.h"

@interface XCTestCase (ReactiveCouchbaseLite)

/**
 Subscribes to the signal and succeeds if the signal then sends a completion before the specified timeout.
 
 @param signal A signal to test.
 @param timeout A timeout within which the signal must complete.
 @param description A description of this test.
 @discussion Any non-completion values are treated as failures.
 */

- (void)rcl_expectCompletionFromSignal:(RACSignal *)signal timeout:(NSTimeInterval)timeout description:(NSString *)description;

/**
 Subscribes to the signal and succeeds if the signal then sends a new value before the specified timeout.
 
 @param nextHandler A block that can test the next value further.
 @param signal A signal to test.
 @param timeout A timeout within which the signal must complete.
 @param description A description of this test.
 @discussion Any non-next values are treated as failures.
 */

- (void)rcl_expectNext:(void (^)(id next))nextHandler signal:(RACSignal *)signal timeout:(NSTimeInterval)timeout description:(NSString *)description;

/**
 Subscribes to the signal and succeeds if the signal then sends a new value before the specified timeout.
 
 @param nextHandlers A block that can test the next values further.
 @param signal A signal to test.
 @param timeout A timeout within which the signal must complete.
 @param description A description of this test.
 @discussion Any non-next values are treated as failures.
 */

- (void)rcl_expectNexts:(NSArray *)nextHandlers signal:(RACSignal *)signal timeout:(NSTimeInterval)timeout description:(NSString *)description;

/**
 Subscribes to the signal and succeeds if the signal then sends an error before the specified timeout.
 
 @param errorHandler A block that can test the error further.
 @param signal A signal to test.
 @param timeout A timeout within which the signal must send an error.
 @param description A description of this test.
 @discussion Any non-error values are treated as failures.
 */

- (void)rcl_expectError:(void (^)(NSError *error))errorHandler signal:(RACSignal *)signal timeout:(NSTimeInterval)timeout description:(NSString *)description;

@end
