//
//  RCLTestDefinitions.m
//  ReactiveCouchbaseLite
//
//  Created by Nathan Douglas on 11/19/14.
//  Released into the public domain.
//  See LICENSE for details.
//

#import "RCLTestDefinitions.h"
#import "ReactiveCouchbaseLite.h"

@implementation XCTestCase (ReactiveCouchbaseLite)

- (void)rcl_expectation:(XCTestExpectation *)expectation signal:(RACSignal *)signal subscribeNext:(void (^)(id next))nextHandler error:(void (^)(NSError *error))errorHandler completion:(void (^)(void))completionHandler timeout:(NSTimeInterval)timeout {
    __block BOOL nextEncountered = NO;
    nextHandler = nextHandler ?: ^(id next) {
        XCTFail(@"Expectation '%@' for signal '%@' received unexpected next: %@", expectation.description, signal, next);
    };
    errorHandler = errorHandler ?: ^(NSError *error) {
        XCTFail(@"Expectation '%@' for signal '%@' received unexpected error: %@", expectation.description, signal, error);
    };
    completionHandler = completionHandler ?: ^{
        XCTFail(@"Expectation '%@' for signal '%@' received unexpected completion.", expectation.description, signal);
    };
    RACDisposable *disposable = [signal
    subscribeNext:^(id next) {
        if (!nextEncountered) {
            nextEncountered = YES;
        }
        nextHandler(next);
    } error:^(NSError *error) {
        if (!nextEncountered) {
            errorHandler(error);
        } else {
            NSLog(@"Ignoring post-test error '%@' for expectation '%@' for signal '%@'.", error.localizedDescription, expectation.description, signal);
        }
    } completed:^{
        if (!nextEncountered) {
            completionHandler();
        } else {
            NSLog(@"Ignoring post-test completion for expectation '%@' for signal '%@'.", expectation.description, signal);
        }
    }];
    [self waitForExpectationsWithTimeout:timeout handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Expectation '%@' for signal '%@' failed with error: %@", expectation.description, signal, error);
        }
        [disposable dispose];
    }];
}

- (void)rcl_expectation:(XCTestExpectation *)expectation signal:(RACSignal *)signal subscribeNext:(void (^)(id))nextHandler error:(void (^)(NSError *))errorHandler timeout:(NSTimeInterval)timeout {
    [self rcl_expectation:expectation signal:[signal take:1] subscribeNext:nextHandler error:errorHandler completion:nil timeout:timeout];
}

- (void)rcl_expectation:(XCTestExpectation *)expectation signal:(RACSignal *)signal subscribeNext:(void (^)(id))nextHandler completion:(void (^)(void))completionHandler timeout:(NSTimeInterval)timeout {
    [self rcl_expectation:expectation signal:[signal take:1] subscribeNext:nextHandler error:nil completion:completionHandler timeout:timeout];
}

- (void)rcl_expectation:(XCTestExpectation *)expectation signal:(RACSignal *)signal subscribeNext:(void (^)(id))nextHandler timeout:(NSTimeInterval)timeout {
    [self rcl_expectation:expectation signal:[signal take:1] subscribeNext:nextHandler error:nil completion:nil timeout:timeout];
}

- (void)rcl_expectation:(XCTestExpectation *)expectation signal:(RACSignal *)signal subscribeError:(void (^)(NSError *))errorHandler completion:(void (^)(void))completionHandler timeout:(NSTimeInterval)timeout {
    [self rcl_expectation:expectation signal:[signal take:1] subscribeNext:nil error:errorHandler completion:completionHandler timeout:timeout];
}

- (void)rcl_expectation:(XCTestExpectation *)expectation signal:(RACSignal *)signal subscribeError:(void (^)(NSError *))errorHandler timeout:(NSTimeInterval)timeout {
    [self rcl_expectation:expectation signal:[signal take:1] subscribeNext:nil error:errorHandler completion:nil timeout:timeout];
}

- (void)rcl_expectation:(XCTestExpectation *)expectation signal:(RACSignal *)signal subscribeCompletion:(void (^)(void))completionHandler timeout:(NSTimeInterval)timeout {
    [self rcl_expectation:expectation signal:[signal take:1] subscribeNext:nil error:nil completion:completionHandler timeout:timeout];
}

- (void)rcl_expectCompletionFromSignal:(RACSignal *)signal timeout:(NSTimeInterval)timeout description:(NSString *)description {
    XCTestExpectation *expectation = [self expectationWithDescription:description];
    [self rcl_expectation:expectation signal:[signal take:1] subscribeCompletion:^{
        [expectation fulfill];
    } timeout:timeout];
}

- (void)rcl_expectNext:(void (^)(id next))nextHandler signal:(RACSignal *)signal timeout:(NSTimeInterval)timeout description:(NSString *)description {
    XCTestExpectation *expectation = [self expectationWithDescription:description];
    [self rcl_expectation:expectation signal:[signal take:1] subscribeNext:^(id next) {
        nextHandler(next);
        [expectation fulfill];
    } timeout:timeout];
}

- (void)rcl_expectNexts:(NSArray *)nextHandlers signal:(RACSignal *)signal timeout:(NSTimeInterval)timeout description:(NSString *)description {
    XCTestExpectation *expectation = [self expectationWithDescription:description];
    XCTestExpectation *expectation2 = [self expectationWithDescription:@"all next handlers executed"];
    __block NSUInteger step = 0;
    [self rcl_expectation:expectation signal:signal subscribeNext:^(id next) {
        XCTAssertTrue(nextHandlers.count > step, @"insufficient number of next handlers provided");
        @synchronized (self) {
            void (^nextHandler)(id next) = nil;
            @try {
                nextHandler = nextHandlers[step];
                nextHandler(next);
                if (step == nextHandlers.count - 1) {
                    [expectation fulfill];
                    [expectation2 fulfill];
                }
                step++;
            } @catch (NSException *exception) {
                NSLog(@"Exception: %@", exception);
            }
        }
    } error:^(NSError *error) {
        XCTFail(@"Encountered error: %@", error);
    } completion:^{
        XCTAssertTrue(step == nextHandlers.count, @"not all next handlers invoked");
    } timeout:timeout];
}

- (void)rcl_expectError:(void (^)(NSError *error))errorHandler signal:(RACSignal *)signal timeout:(NSTimeInterval)timeout description:(NSString *)description {
    XCTestExpectation *expectation = [self expectationWithDescription:description];
    [self rcl_expectation:expectation signal:[signal take:1] subscribeError:^(NSError *error) {
        errorHandler(error);
        [expectation fulfill];
    } timeout:timeout];
}

- (void)rcl_updateDocument:(CBLDocument *)document withBlock:(BOOL (^)(CBLUnsavedRevision *newRevision))updater completionHandler:(void (^)(BOOL success, NSError *error))block {
    NSError *error = nil;
    BOOL success = [document update:updater error:&error] != nil;
    block(success, error);
}

- (void)rcl_triviallyUpdateDocument:(CBLDocument *)document times:(NSUInteger)times interval:(NSTimeInterval)interval {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(interval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self rcl_updateDocument:document withBlock:^BOOL(CBLUnsavedRevision *newRevision) {
            newRevision.properties[[[NSUUID UUID] UUIDString]] = [[NSUUID UUID] UUIDString];
            return YES;
        } completionHandler:^(BOOL success, NSError *error) {
            if (!success) {
                NSLog(@"Error: %@", error);
            }
            XCTAssertTrue(success);
            if (times > 0) {
                [self rcl_triviallyUpdateDocument:document times:times - 1 interval:interval];
            }
        }];
    });
}

@end

@implementation RCLTestCase
@synthesize manager;
@synthesize listener;
@synthesize port;
@synthesize testID;
@synthesize testName;
@synthesize peerName;
@synthesize testDatabase;
@synthesize peerDatabase;
@synthesize peerURL;
@synthesize pullReplication;
@synthesize pushReplication;

- (void)rcl_setupManager {
    [CBLManager rcl_enableUsefulLogs];
    self.manager = [CBLManager sharedInstance];
}

- (void)rcl_setupDatabase {
    if (!self.manager) {
        [self rcl_setupManager];
    }
    self.testID = @([[[NSUUID UUID] UUIDString] hash]);
    self.testName = [NSString stringWithFormat:@"test_%@", self.testID];
    NSError *error = nil;
    XCTAssertTrue(self.testDatabase = [self.manager databaseNamed:self.testName error:&error], @"Error: %@", error);
}

- (void)rcl_setupPeer {
    if (!self.testDatabase) {
        [self rcl_setupDatabase];
    }
    self.peerName = [NSString stringWithFormat:@"peer_%@", self.testID ?: self.testName ?: self.testDatabase.name ?: @([[[NSUUID UUID] UUIDString] hash])];
    NSError *error = nil;
    XCTAssertTrue(self.peerDatabase = [self.manager databaseNamed:self.peerName error:&error], @"Error: %@", error);
}

- (void)rcl_setupListener {
    if (!self.peerDatabase) {
        [self rcl_setupPeer];
    }
    self.listener = [[CBLListener alloc] initWithManager:self.manager port:self.port ? self.port.unsignedIntegerValue : RCL_DEFAULT_LISTENER_PORT];
    NSError *error = nil;
    XCTAssertTrue([self.listener start:&error], @"Error: %@", error);
    self.port = @(self.listener.port);
    self.peerURL = [self.listener.URL URLByAppendingPathComponent:self.peerDatabase.name];
}

- (void)rcl_setupPushReplication {
    if (!self.listener) {
        [self rcl_setupListener];
    }
    NSError *error = nil;
    XCTAssertTrue(self.pushReplication = [self.testDatabase createPushReplication:self.peerURL], @"Error: %@", error);
    self.pushReplication.continuous = YES;
    [self.pushReplication start];
}

- (void)rcl_setupPullReplication {
    if (!self.listener) {
        [self rcl_setupListener];
    }
    NSError *error = nil;
    XCTAssertTrue(self.pullReplication = [self.testDatabase createPullReplication:self.peerURL], @"Error: %@", error);
    self.pullReplication.continuous = YES;
    [self.pullReplication start];
}

- (void)rcl_setupEverything {
    [self rcl_setupPushReplication];
    [self rcl_setupPullReplication];
}

- (void)rcl_tearDown {
    NSError *error = nil;
    if (self.pushReplication) {
        [self.pushReplication stop];
        self.pushReplication = nil;
    }
    if (self.pullReplication) {
        [self.pullReplication stop];
        self.pullReplication = nil;
    }
    if (self.listener) {
        [self.listener stop];
        self.listener = nil;
    }
    if (self.testDatabase) {
        XCTAssertTrue([self.testDatabase deleteDatabase:&error], @"Error: %@", error);
        self.testDatabase = nil;
    }
    if (self.peerDatabase) {
        XCTAssertTrue([self.peerDatabase deleteDatabase:&error], @"Error: %@", error);
        self.peerDatabase = nil;
    }
    if (self.manager) {
        self.manager = nil;
    }
}

- (void)tearDown {
	[super tearDown];
}


@end


@implementation CBLManager (RCLTestDefinitions)

+ (void)rcl_enableUsefulLogs {
    [CBLManager enableLogging:@"TDRouter"];
    [CBLManager enableLogging:@"Sync"];
    [CBLManager enableLogging:@"SyncVerbose"];
    [CBLManager enableLogging:@"RemoteRequest"];
    [CBLManager enableLogging:@"ChangeTracker"];
    [CBLManager enableLogging:@"Query"];
    [CBLManager enableLogging:@"CBLDatabase"];
    [CBLManager enableLogging:@"CBLListener"];
}

@end
