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

/**
 Updates the document with the specified block.
 
 @param document The document to update.
 @param updater The block executed on the document.
 @param block A block executed when the document has been updated.
 */

- (void)rcl_updateDocument:(CBLDocument *)document withBlock:(BOOL (^)(CBLUnsavedRevision *newRevision))updater completionHandler:(void (^)(BOOL success, NSError *error))block;

/**
 Repeatedly updates the document by adding a new property with a UUID name and giving it a new UUID as a value.
 
 @param document The document to update.
 @param times The number of times to update the document.
 @param interval The interval between updates.
 */

- (void)rcl_triviallyUpdateDocument:(CBLDocument *)document times:(NSUInteger)times interval:(NSTimeInterval)interval;

@end

@interface CBLManager (RCLTestDefinitions)

/**
 Enables a lot of useful logging.
 */

+ (void)rcl_enableUsefulLogs;

@end
