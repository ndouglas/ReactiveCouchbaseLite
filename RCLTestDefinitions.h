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

#define RCL_DEFAULT_LISTENER_PORT 2028

@interface XCTestCase (ReactiveCouchbaseLite)

/**
 Subscribes to the signal and succeeds if the signal then sends a completion before the specified timeout.
 
 @param signal A signal to test.
 @param initialBlock A block performed as soon as the test is ready.
 @param timeout A timeout within which the signal must complete.
 @param description A description of this test.
 @discussion Any non-completion values are treated as failures.
 */

- (void)rcl_expectCompletionFromSignal:(RACSignal *)signal initially:(void (^)(void))initialBlock timeout:(NSTimeInterval)timeout description:(NSString *)description;

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
 @param initialBlock A block performed as soon as the test is ready.
 @param timeout A timeout within which the signal must complete.
 @param description A description of this test.
 @discussion Any non-next values are treated as failures.
 */

- (void)rcl_expectNext:(void (^)(id next))nextHandler signal:(RACSignal *)signal initially:(void (^)(void))initialBlock timeout:(NSTimeInterval)timeout description:(NSString *)description;

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
 @param initialBlock A block performed as soon as the test is ready.
 @param timeout A timeout within which the signal must complete.
 @param description A description of this test.
 @discussion Any non-next values are treated as failures.
 */

- (void)rcl_expectNexts:(NSArray *)nextHandlers signal:(RACSignal *)signal initially:(void (^)(void))initialBlock timeout:(NSTimeInterval)timeout description:(NSString *)description;

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
 @param initialBlock A block performed as soon as the test is ready.
 @param timeout A timeout within which the signal must send an error.
 @param description A description of this test.
 @discussion Any non-error values are treated as failures.
 */

- (void)rcl_expectError:(void (^)(NSError *error))errorHandler signal:(RACSignal *)signal initially:(void (^)(void))initialBlock timeout:(NSTimeInterval)timeout description:(NSString *)description;

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

@interface RCLTestCase : XCTestCase

/**
 The shared CBLManager instance.
 */

@property (strong, nonatomic, readwrite) CBLManager *manager;

/**
 The shared CBLListener instance, for replications.
 */

@property (strong, nonatomic, readwrite) CBLListener *listener;

/**
 The listener port.
 */

@property (copy, nonatomic, readwrite) NSNumber *port;

/**
 The test ID identifying this particular test.
 */

@property (copy, nonatomic, readwrite) NSNumber *testID;

/**
 The database name for this test.
 */

@property (copy, nonatomic, readwrite) NSString *testName;

/**
 The peer database name for this test.
 */

@property (copy, nonatomic, readwrite) NSString *peerName;

/**
 The database for this test.
 */

@property (strong, nonatomic, readwrite) CBLDatabase *testDatabase;

/**
 The peer database for this test.
 */

@property (strong, nonatomic, readwrite) CBLDatabase *peerDatabase;

/**
 The URL of the test database.
 */

@property (strong, nonatomic, readwrite) NSURL *testURL;

/**
 The URL of the peer database.
 */

@property (strong, nonatomic, readwrite) NSURL *peerURL;

/**
 The pull replication.
 */

@property (strong, nonatomic, readwrite) CBLReplication *pullReplication;

/**
 The push replication.
 */

@property (strong, nonatomic, readwrite) CBLReplication *pushReplication;

/**
 Sets up the manager property.
 */

- (void)rcl_setupManager;

/**
 Sets up the database property.
 @discussion Requires -rcl_setupManager.
 */

- (void)rcl_setupDatabase;

/**
 Sets up the peer database.
 @discussion Requires -rcl_setupDatabase.
 */

- (void)rcl_setupPeer;

/**
 Sets up the listener.
 @discussion Requires -rcl_setupPeer.
 @discussion Will listen on -port if non-nil.
 */

- (void)rcl_setupListener;

/**
 Sets up the push replication.
 @discussion Requires -rcl_setupListener.
 */

- (void)rcl_setupPushReplication;

/**
 Sets up the pull replication.
 @discussion Requires -rcl_setupListener.
 */

- (void)rcl_setupPullReplication;

/**
 Sets up the manager, test and peer databases, a listener, and push and pull replications.
 @discussion Requires -rcl_setupPushReplication and -rcl_setupPullReplication.
 */

- (void)rcl_setupEverything;

/**
 Takes care of all initialized things.
 */

- (void)rcl_tearDown;

@end

@interface CBLManager (RCLTestDefinitions)

/**
 Enables a lot of useful logging.
 */

+ (void)rcl_enableUsefulLogs;

@end
