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

- (void)expectation:(XCTestExpectation *)expectation signal:(RACSignal *)signal subscribeNext:(void (^)(id next))nextHandler error:(void (^)(NSError *error))errorHandler completion:(void (^)(void))completionHandler timeout:(NSTimeInterval)timeout {
    nextHandler = nextHandler ?: ^(id next) {
        XCTFail(@"Expectation '%@' received unexpected next: %@", expectation.description, next);
    };
    errorHandler = errorHandler ?: ^(NSError *error) {
        XCTFail(@"Expectation '%@' received unexpected error: %@", expectation.description, error);
    };
    completionHandler = completionHandler ?: ^{
        XCTFail(@"Expectation '%@' received unexpected completion.", expectation.description);
    };
    RACDisposable *disposable = [[signal
    take:1]
    subscribeNext:nextHandler error:errorHandler completed:completionHandler];
    [self waitForExpectationsWithTimeout:timeout handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Expectation '%@' failed with error: %@", expectation.description, error);
        }
        [disposable dispose];
    }];
}

- (void)expectation:(XCTestExpectation *)expectation signal:(RACSignal *)signal subscribeNext:(void (^)(id))nextHandler error:(void (^)(NSError *))errorHandler timeout:(NSTimeInterval)timeout {
    [self expectation:expectation signal:signal subscribeNext:nextHandler error:errorHandler completion:nil timeout:timeout];
}

- (void)expectation:(XCTestExpectation *)expectation signal:(RACSignal *)signal subscribeNext:(void (^)(id))nextHandler completion:(void (^)(void))completionHandler timeout:(NSTimeInterval)timeout {
    [self expectation:expectation signal:signal subscribeNext:nextHandler error:nil completion:completionHandler timeout:timeout];
}

- (void)expectation:(XCTestExpectation *)expectation signal:(RACSignal *)signal subscribeNext:(void (^)(id))nextHandler timeout:(NSTimeInterval)timeout {
    [self expectation:expectation signal:signal subscribeNext:nextHandler error:nil completion:nil timeout:timeout];
}

- (void)expectation:(XCTestExpectation *)expectation signal:(RACSignal *)signal subscribeError:(void (^)(NSError *))errorHandler completion:(void (^)(void))completionHandler timeout:(NSTimeInterval)timeout {
    [self expectation:expectation signal:signal subscribeNext:nil error:errorHandler completion:completionHandler timeout:timeout];
}

- (void)expectation:(XCTestExpectation *)expectation signal:(RACSignal *)signal subscribeError:(void (^)(NSError *))errorHandler timeout:(NSTimeInterval)timeout {
    [self expectation:expectation signal:signal subscribeNext:nil error:errorHandler completion:nil timeout:timeout];
}

- (void)expectation:(XCTestExpectation *)expectation signal:(RACSignal *)signal subscribeCompletion:(void (^)(void))completionHandler timeout:(NSTimeInterval)timeout {
    [self expectation:expectation signal:signal subscribeNext:nil error:nil completion:completionHandler timeout:timeout];
}

- (void)expectCompletionFromSignal:(RACSignal *)signal timeout:(NSTimeInterval)timeout description:(NSString *)description {
    XCTestExpectation *expectation = [self expectationWithDescription:description];
    [self expectation:expectation signal:signal subscribeCompletion:^{
        [expectation fulfill];
    } timeout:timeout];
}

- (void)expectNext:(void (^)(id next))nextHandler signal:(RACSignal *)signal timeout:(NSTimeInterval)timeout description:(NSString *)description {
    XCTestExpectation *expectation = [self expectationWithDescription:description];
    [self expectation:expectation signal:signal subscribeNext:^(id next) {
        nextHandler(next);
        [expectation fulfill];
    } timeout:timeout];
}

- (void)expectError:(void (^)(NSError *error))errorHandler signal:(RACSignal *)signal timeout:(NSTimeInterval)timeout description:(NSString *)description {
    XCTestExpectation *expectation = [self expectationWithDescription:description];
    [self expectation:expectation signal:signal subscribeError:^(NSError *error) {
        errorHandler(error);
        [expectation fulfill];
    } timeout:timeout];
}

@end
