//
//  CBLReplication+ReactiveCouchbaseLite.Tests.m
//  ReactiveCouchbaseLite
//
//  Created by Nathan Douglas on 12/4/14.
//  Released into the public domain.
//  See LICENSE for details.
//

#import <XCTest/XCTest.h>
#import "RCLTestDefinitions.h"
#import <ReactiveCouchbaseLite/ReactiveCouchbaseLite.h>

@interface CBLReplication_ReactiveCouchbaseLiteTests : RCLTestCase

@end

@implementation CBLReplication_ReactiveCouchbaseLiteTests

- (void)setUp {
	[super setUp];
    [self rcl_setupEverything];
}

- (void)tearDown {
    [self rcl_tearDown];
	[super tearDown];
}

- (void)testPendingPushDocumentIDs {
	NSString *documentID = [[NSUUID UUID] UUIDString];
    [self rcl_triviallyUpdateDocument:[self.testDatabase documentWithID:documentID] times:1 interval:0.1];
    [self rcl_expectNexts:@[
        ^(NSString *pendingDocumentID) {
            XCTAssertTrue([pendingDocumentID isEqualToString:documentID]);
        },
    ] signal:[[self.pushReplication rcl_pendingPushDocumentIDs] take:1] timeout:5.0 description:@"pending push document IDs received correctly"];
}

- (void)testTransferredDocuments {
	NSString *documentID = [[NSUUID UUID] UUIDString];
    [self rcl_expectNexts:@[
        ^(NSDictionary *transferringDocument) {
            XCTAssertTrue([transferringDocument[@"_id"] isEqualToString:documentID]);
        },
        ^(NSDictionary *transferringDocument) {
            XCTAssertTrue([transferringDocument[@"_id"] isEqualToString:documentID]);
        },
        ^(NSDictionary *transferringDocument) {
            XCTAssertTrue([transferringDocument[@"_id"] isEqualToString:documentID]);
        },
    ] signal:[[[self.pushReplication rcl_transferredDocuments] take:3] logAll] initially:^{
        [self rcl_triviallyUpdateDocument:[self.testDatabase documentWithID:documentID] times:3 interval:0.1];
    } timeout:5.0 description:@"pending push document IDs received correctly"];
}

- (void)testDidStart {
    [[self.pushReplication.rcl_isRunning logAll] subscribeCompleted:^{ }];
    [self rcl_expectCompletionFromSignal:[self.pushReplication rcl_didStart] timeout:5.0 description:@"replication started 1"];
    [self.pushReplication stop];
    [self rcl_expectCompletionFromSignal:[self.pushReplication rcl_didStop] timeout:5.0 description:@"replication stopped 1"];
    [self rcl_expectCompletionFromSignal:[self.pushReplication rcl_didStart] initially:^(void) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.pushReplication start];
        });
    } timeout:5.0 description:@"replication started 2"];
    [self.pushReplication stop];
    [self rcl_expectCompletionFromSignal:[self.pushReplication rcl_didStop] timeout:5.0 description:@"replication stopped 2"];
    [self rcl_expectCompletionFromSignal:[self.pushReplication rcl_didStart] initially:^(void) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.pushReplication start];
        });
    } timeout:5.0 description:@"replication started 3"];
    [self.pushReplication stop];
    [self rcl_expectCompletionFromSignal:[self.pushReplication rcl_didStop] timeout:5.0 description:@"replication stopped 3"];
    [self rcl_expectCompletionFromSignal:[self.pushReplication rcl_didStart] initially:^(void) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.pushReplication start];
        });
    } timeout:5.0 description:@"replication started 4"];
    [self.pushReplication start];
}

- (void)testDidStop {
    [[self.pushReplication.rcl_isRunning logAll] subscribeCompleted:^{ }];
    [self rcl_expectCompletionFromSignal:[self.pushReplication rcl_didStop] initially:^(void) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.pushReplication stop];
        });
    } timeout:2.0 description:@"replication stopped"];
    [self.pushReplication stop];
    [self rcl_expectCompletionFromSignal:[self.pushReplication rcl_didStop] timeout:1.0 description:@"replication started"];
    [self.pushReplication start];
    [self rcl_expectCompletionFromSignal:[self.pushReplication rcl_didStop] initially:^(void) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.pushReplication stop];
        });
    } timeout:2.0 description:@"replication stopped"];
    [self.pushReplication stop];
    [self rcl_expectCompletionFromSignal:[self.pushReplication rcl_didStop] timeout:1.0 description:@"replication started"];
    [self.pushReplication start];
    [self rcl_expectCompletionFromSignal:[self.pushReplication rcl_didStop] initially:^(void) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.pushReplication stop];
        });
    } timeout:2.0 description:@"replication stopped"];
    [self.pushReplication stop];
    [self rcl_expectCompletionFromSignal:[self.pushReplication rcl_didStop] timeout:1.0 description:@"replication started"];
    [self.pushReplication start];
    [self rcl_expectCompletionFromSignal:[self.pushReplication rcl_didStop] initially:^(void) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.pushReplication stop];
        });
    } timeout:2.0 description:@"replication stopped"];
    [self.pushReplication stop];
    [self rcl_expectCompletionFromSignal:[self.pushReplication rcl_didStop] timeout:1.0 description:@"replication started"];
}

- (void)testControlSignal {
    [[RACObserve(self.pushReplication, running) logAll] subscribeCompleted:^{ }];
    [self.pushReplication stop];
    RACReplaySubject *subject = [RACReplaySubject replaySubjectWithCapacity:RACReplaySubjectUnlimitedCapacity];
    [self rcl_expectNexts:@[
        ^(NSNumber *next) {
            NSLog(@"next 01: %@", next);
        },
        ^(NSNumber *next) {
            NSLog(@"next 02: %@", next);
        },
        ^(NSNumber *next) {
            NSLog(@"next 03: %@", next);
        },
        ^(NSNumber *next) {
            NSLog(@"next 04: %@", next);
        },
        ^(NSNumber *next) {
            NSLog(@"next 05: %@", next);
        },
        ^(NSNumber *next) {
            NSLog(@"next 06: %@", next);
        },
        ^(NSNumber *next) {
            NSLog(@"next 07: %@", next);
        },
        ^(NSNumber *next) {
            NSLog(@"next 08: %@", next);
        },
        ^(NSNumber *next) {
            NSLog(@"next 09: %@", next);
        },
        ^(NSNumber *next) {
            NSLog(@"next 10: %@", next);
        },
    ] signal:[self.pushReplication rcl_controlSignal:subject] initially:^{
        [subject sendNext:@1];
        [self.pushReplication stop];
        [subject sendNext:@2];
        [subject sendNext:@3];
        [subject sendNext:@4];
        [self.pushReplication start];
        [subject sendNext:@5];
        [subject sendNext:@6];
        [subject sendNext:@7];
        [self.pushReplication stop];
        [subject sendNext:@8];
        [self.pushReplication start];
        [subject sendNext:@9];
        [subject sendNext:@10];
        [subject sendCompleted];
    } timeout:5.0 description:@"signal controlled"];
}

@end
