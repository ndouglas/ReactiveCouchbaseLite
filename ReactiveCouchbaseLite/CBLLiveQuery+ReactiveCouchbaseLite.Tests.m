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
#import "RCLDefinitions.h"

@interface CBLLiveQuery_ReactiveCouchbaseLiteTests : XCTestCase {
    CBLManager *_manager;
    NSString *_databaseName;
}

@end

@implementation CBLLiveQuery_ReactiveCouchbaseLiteTests

- (void)setUp {
	[super setUp];
    _manager = [CBLManager sharedInstance];
    _databaseName = [NSString stringWithFormat:@"test_%@", @([[[NSUUID UUID] UUIDString] hash])];
}

- (void)tearDown {
    [[_manager databaseNamed:_databaseName error:NULL] deleteDatabase:NULL];
	[super tearDown];
}

- (void)asynchronouslyPostTrivialChangeToDocumentWithID:(NSString *)ID {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [[[[CBLManager sharedInstance] databaseNamed:_databaseName error:NULL] documentWithID:ID] putProperties:@{} error:NULL];
        });
    });
}

- (void)testRows {
    RACSignal *liveQuerySignal = [[[_manager rcl_databaseNamed:_databaseName]
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
    [self asynchronouslyPostTrivialChangeToDocumentWithID:[[NSUUID UUID] UUIDString]];
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
    [self asynchronouslyPostTrivialChangeToDocumentWithID:[[NSUUID UUID] UUIDString]];
    [self rcl_expectCompletionFromSignal:[[liveQuerySignal
    skip:1]
    takeUntilBlock:^BOOL (CBLQueryEnumerator *rows) {
        BOOL result = rows.allObjects.count == 2;
        NSLog(@"Filter condition %@matched for value %@ (%@).", result ? @"" : @"un", rows, rows.allObjects);
        return result;
    }]
    timeout:5.0 description:@"observed initial value for rows"];
    NSLog(@"%@", liveQuerySignal);
}

- (void)testChanges {
    RACSignal *liveQuerySignal = [[[_manager rcl_databaseNamed:_databaseName]
    flattenMap:^RACSignal *(CBLDatabase *database) {
        return [database rcl_allDocumentsQuery];
    }]
    flattenMap:^RACSignal *(CBLQuery *query) {
        CBLLiveQuery *liveQuery = query.asLiveQuery;
        return [liveQuery rcl_changes];
    }];
    NSString *UUID1 = [[NSUUID UUID] UUIDString];
    [self asynchronouslyPostTrivialChangeToDocumentWithID:UUID1];
    [self rcl_expectCompletionFromSignal:[[liveQuerySignal
    doCompleted:^{
        XCTFail(@"This signal is not supposed to complete.");
    }]
    takeUntilBlock:^BOOL (CBLQueryRow *row) {
        BOOL result = [row.key isEqualToString:UUID1];
        return result;
    }]
    timeout:5.0 description:@"observed first added row"];
    NSString *UUID2 = [[NSUUID UUID] UUIDString];
    [self asynchronouslyPostTrivialChangeToDocumentWithID:UUID2];
    [self rcl_expectCompletionFromSignal:[[[liveQuerySignal
    doCompleted:^{
        XCTFail(@"This signal is not supposed to complete.");
    }]
    takeUntilBlock:^BOOL (CBLQueryRow *row) {
        BOOL result = [row.key isEqualToString:UUID2];
        return result;
    }]
    ignoreValues]
    timeout:5.0 description:@"observed second added row"];
    NSString *UUID3 = [[NSUUID UUID] UUIDString];
    [self asynchronouslyPostTrivialChangeToDocumentWithID:UUID3];
    [self rcl_expectCompletionFromSignal:[[liveQuerySignal
    takeUntilBlock:^BOOL (CBLQueryRow *row) {
        BOOL result = [row.key isEqualToString:UUID3];
        return result;
    }]
    ignoreValues]
    timeout:5.0 description:@"observed third added row"];
    NSLog(@"%@", liveQuerySignal);
}

- (void)testMultipleChanges {
    RACSignal *liveQuerySignal = [[[_manager rcl_databaseNamed:_databaseName]
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
    [self asynchronouslyPostTrivialChangeToDocumentWithID:UUID1];
    [self asynchronouslyPostTrivialChangeToDocumentWithID:UUID2];
    [self asynchronouslyPostTrivialChangeToDocumentWithID:UUID3];
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
