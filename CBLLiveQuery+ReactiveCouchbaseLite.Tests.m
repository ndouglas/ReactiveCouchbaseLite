//
//  CBLiveQuery+ReactiveCouchbaseLite.Tests.m
//  ReactiveCouchbaseLite
//
//  Created by Nathan Douglas on 12/4/14.
//  Released into the public domain.
//  See LICENSE for details.
//

#import <XCTest/XCTest.h>
#import "RCLTestDefinitions.h"
#import <ReactiveCouchbaseLite/ReactiveCouchbaseLite.h>

@interface CBLLiveQuery_ReactiveCouchbaseLiteTests : RCLTestCase

@end

@implementation CBLLiveQuery_ReactiveCouchbaseLiteTests

- (void)setUp {
	[super setUp];
    [self rcl_setupDatabase];
}

- (void)tearDown {
    [self rcl_tearDown];
	[super tearDown];
}

- (void)testRows {
    RACSignal *liveQuerySignal = [[[self.manager rcl_databaseNamed:self.testName]
    flattenMap:^RACSignal *(CBLDatabase *database) {
        return [database rcl_allDocumentsQuery];
    }]
    flattenMap:^RACSignal *(CBLQuery *query) {
        CBLLiveQuery *liveQuery = query.asLiveQuery;
        return [liveQuery rcl_rows];
    }];
    [self rcl_expectCompletionFromSignal:[[liveQuerySignal
    doCompleted:^{
        XCTFail(@"This signal is not supposed to complete.");
    }]
    takeUntilBlock:^BOOL (CBLQueryEnumerator *rows) {
        BOOL result = rows.allObjects.count == 0;
        NSLog(@"Filter condition %@matched for value %@ (%@).", result ? @"" : @"un", rows, rows.allObjects);
        return result;
    }]
    timeout:5.0 description:@"observed initial value for rows"];
    [self rcl_triviallyUpdateDocument:[self.testDatabase documentWithID:[[NSUUID UUID] UUIDString]] times:1 interval:0.1];
    [self rcl_expectCompletionFromSignal:[[[liveQuerySignal
    doCompleted:^{
        XCTFail(@"This signal is not supposed to complete.");
    }]
    skip:1]
    takeUntilBlock:^BOOL (CBLQueryEnumerator *rows) {
        BOOL result = rows.allObjects.count == 1;
        NSLog(@"Filter condition %@matched for value %@ (%@).", result ? @"" : @"un", rows, rows.allObjects);
        return result;
    }]
    timeout:5.0 description:@"observed initial value for rows"];
    [self rcl_triviallyUpdateDocument:[self.testDatabase documentWithID:[[NSUUID UUID] UUIDString]] times:1 interval:0.1];
    [self rcl_expectCompletionFromSignal:[[liveQuerySignal
    skip:1]
    takeUntilBlock:^BOOL (CBLQueryEnumerator *rows) {
        BOOL result = rows.allObjects.count == 2;
        NSLog(@"Filter condition %@matched for value %@ (%@).", result ? @"" : @"un", rows, rows.allObjects);
        return result;
    }]
    timeout:5.0 description:@"observed initial value for rows"];
}

- (void)testChanges1 {
    NSString *UUID1 = [[NSUUID UUID] UUIDString];
    [self rcl_triviallyUpdateDocument:[self.testDatabase documentWithID:UUID1] times:1 interval:0.1];
    [self rcl_expectCompletionFromSignal:[[[[self.testDatabase rcl_allDocumentsQuery]
        flattenMap:^RACSignal *(CBLQuery *query) {
            CBLLiveQuery *liveQuery = query.asLiveQuery;
            return [liveQuery rcl_changes];
        }]
        doCompleted:^{
            XCTFail(@"This signal is not supposed to complete.");
        }]
        takeUntilBlock:^BOOL (CBLQueryRow *row) {
            BOOL result = [row.key isEqualToString:UUID1];
            return result;
        }]
        timeout:5.0 description:@"observed first added row"];
}

- (void)testChanges2 {
    NSString *UUID2 = [[NSUUID UUID] UUIDString];
    [self rcl_triviallyUpdateDocument:[self.testDatabase documentWithID:UUID2] times:1 interval:0.1];
    [self rcl_expectCompletionFromSignal:[[[[[self.testDatabase rcl_allDocumentsQuery]
        flattenMap:^RACSignal *(CBLQuery *query) {
            CBLLiveQuery *liveQuery = query.asLiveQuery;
            return [liveQuery rcl_changes];
        }]
        doCompleted:^{
            XCTFail(@"This signal is not supposed to complete.");
        }]
        takeUntilBlock:^BOOL (CBLQueryRow *row) {
            BOOL result = [row.key isEqualToString:UUID2];
            return result;
        }]
        ignoreValues]
        timeout:5.0 description:@"observed second added row"];
}

- (void)testChanges3 {
    NSString *UUID3 = [[NSUUID UUID] UUIDString];
    [self rcl_expectNexts:@[
        ^(CBLQueryRow *_row_) {
            NSLog(@"Row: %@", _row_);
            XCTAssertNotNil(_row_);
            [self rcl_triviallyUpdateDocument:[self.testDatabase documentWithID:UUID3] times:1 interval:0.1];
        },
        ^(CBLQueryRow *_row_) {
            NSLog(@"Row: %@", _row_);
            XCTAssertNotNil(_row_);
            [self rcl_triviallyUpdateDocument:[self.testDatabase documentWithID:UUID3] times:1 interval:0.1];
        },
        ^(CBLQueryRow *_row_) {
            NSLog(@"Row: %@", _row_);
            XCTAssertNotNil(_row_);
            [self rcl_triviallyUpdateDocument:[self.testDatabase documentWithID:UUID3] times:1 interval:0.1];
        },
        ^(CBLQueryRow *_row_) {
            NSLog(@"Row: %@", _row_);
            XCTAssertNotNil(_row_);
            [self rcl_triviallyUpdateDocument:[self.testDatabase documentWithID:UUID3] times:1 interval:0.1];
        },
        ^(CBLQueryRow *_row_) {
            NSLog(@"Row: %@", _row_);
            XCTAssertNotNil(_row_);
            [self rcl_triviallyUpdateDocument:[self.testDatabase documentWithID:UUID3] times:1 interval:0.1];
        },
        ^(CBLQueryRow *_row_) {
            NSLog(@"Row: %@", _row_);
            XCTAssertNotNil(_row_);
        },
    ] signal:[[[self.testDatabase rcl_allDocumentsQuery]
        flattenMap:^RACSignal *(CBLQuery *query) {
            CBLLiveQuery *liveQuery = query.asLiveQuery;
            return [liveQuery rcl_changes];
        }]
        take:6]
    initially:^{
        [self rcl_triviallyUpdateDocument:[self.testDatabase documentWithID:UUID3] times:1 interval:0.1];
    } timeout:5.0 description:@"all updates received"];
}

- (void)testMultipleChanges {
    RACSignal *liveQuerySignal = [[[self.manager rcl_databaseNamed:self.testName]
    flattenMap:^RACSignal *(CBLDatabase *database) {
        return [database rcl_allDocumentsQuery];
    }]
    flattenMap:^RACSignal *(CBLQuery *query) {
        CBLLiveQuery *liveQuery = query.asLiveQuery;
        return [liveQuery rcl_changes];
    }];
    NSString *UUID1 = [[NSUUID UUID] UUIDString];
    NSString *UUID2 = [[NSUUID UUID] UUIDString];
    NSString *UUID3 = [[NSUUID UUID] UUIDString];
    [self rcl_triviallyUpdateDocument:[self.testDatabase documentWithID:UUID1] times:1 interval:0.1];
    [self rcl_triviallyUpdateDocument:[self.testDatabase documentWithID:UUID2] times:1 interval:0.1];
    [self rcl_triviallyUpdateDocument:[self.testDatabase documentWithID:UUID3] times:1 interval:0.1];
    __block BOOL result1 = NO;
    __block BOOL result2 = NO;
    __block BOOL result3 = NO;
    [self rcl_expectCompletionFromSignal:[[[liveQuerySignal
        doCompleted:^{
            XCTFail(@"This signal is not supposed to complete.");
        }]
        takeUntilBlock:^BOOL (CBLQueryRow *row) {
            result1 = result1 || [row.key isEqualToString:UUID1];
            result2 = result2 || [row.key isEqualToString:UUID2];
            result3 = result3 || [row.key isEqualToString:UUID3];
            BOOL result = result1 && result2 && result3;
            return result;
        }]
        ignoreValues]
        timeout:5.0 description:@"observed first added row"];
}

@end
