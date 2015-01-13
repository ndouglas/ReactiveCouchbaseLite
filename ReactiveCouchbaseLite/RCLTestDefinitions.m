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
            nextHandler(next);
        } else {
            NSLog(@"Ignoring post-test next '%@' for expectation '%@' for signal '%@'.", next, expectation.description, signal);
        }
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
    [self rcl_expectation:expectation signal:signal subscribeNext:nextHandler error:errorHandler completion:nil timeout:timeout];
}

- (void)rcl_expectation:(XCTestExpectation *)expectation signal:(RACSignal *)signal subscribeNext:(void (^)(id))nextHandler completion:(void (^)(void))completionHandler timeout:(NSTimeInterval)timeout {
    [self rcl_expectation:expectation signal:signal subscribeNext:nextHandler error:nil completion:completionHandler timeout:timeout];
}

- (void)rcl_expectation:(XCTestExpectation *)expectation signal:(RACSignal *)signal subscribeNext:(void (^)(id))nextHandler timeout:(NSTimeInterval)timeout {
    [self rcl_expectation:expectation signal:signal subscribeNext:nextHandler error:nil completion:nil timeout:timeout];
}

- (void)rcl_expectation:(XCTestExpectation *)expectation signal:(RACSignal *)signal subscribeError:(void (^)(NSError *))errorHandler completion:(void (^)(void))completionHandler timeout:(NSTimeInterval)timeout {
    [self rcl_expectation:expectation signal:signal subscribeNext:nil error:errorHandler completion:completionHandler timeout:timeout];
}

- (void)rcl_expectation:(XCTestExpectation *)expectation signal:(RACSignal *)signal subscribeError:(void (^)(NSError *))errorHandler timeout:(NSTimeInterval)timeout {
    [self rcl_expectation:expectation signal:signal subscribeNext:nil error:errorHandler completion:nil timeout:timeout];
}

- (void)rcl_expectation:(XCTestExpectation *)expectation signal:(RACSignal *)signal subscribeCompletion:(void (^)(void))completionHandler timeout:(NSTimeInterval)timeout {
    [self rcl_expectation:expectation signal:signal subscribeNext:nil error:nil completion:completionHandler timeout:timeout];
}

- (void)rcl_expectCompletionFromSignal:(RACSignal *)signal timeout:(NSTimeInterval)timeout description:(NSString *)description {
    XCTestExpectation *expectation = [self expectationWithDescription:description];
    [self rcl_expectation:expectation signal:signal subscribeCompletion:^{
        [expectation fulfill];
    } timeout:timeout];
}

- (void)rcl_expectNext:(void (^)(id next))nextHandler signal:(RACSignal *)signal timeout:(NSTimeInterval)timeout description:(NSString *)description {
    XCTestExpectation *expectation = [self expectationWithDescription:description];
    [self rcl_expectation:expectation signal:signal subscribeNext:^(id next) {
        nextHandler(next);
        [expectation fulfill];
    } timeout:timeout];
}

- (void)rcl_expectNexts:(NSArray *)nextHandlers signal:(RACSignal *)signal timeout:(NSTimeInterval)timeout description:(NSString *)description {
    XCTestExpectation *expectation = [self expectationWithDescription:description];
    XCTestExpectation *expectation2 = [self expectationWithDescription:@"all next handlers executed"];
    
    [self rcl_expectation:expectation signal:signal subscribeNext:^(id next) {
        static NSUInteger step = 0;
        XCTAssertTrue(nextHandlers.count - 1 >= step, @"insufficient number of next handlers provided");
        @synchronized (self) {
            void (^nextHandler)(id next) = nextHandlers[step];
            nextHandler(next);
            if (step == nextHandlers.count) {
                [expectation fulfill];
                [expectation2 fulfill];
            } else {
                NSLog(@"Step: %@ -> %@", @(step), @(step+1));
                step++;
            }
        }
    } timeout:timeout];
}

- (void)rcl_expectError:(void (^)(NSError *error))errorHandler signal:(RACSignal *)signal timeout:(NSTimeInterval)timeout description:(NSString *)description {
    XCTestExpectation *expectation = [self expectationWithDescription:description];
    [self rcl_expectation:expectation signal:signal subscribeError:^(NSError *error) {
        errorHandler(error);
        [expectation fulfill];
    } timeout:timeout];
}

@end
