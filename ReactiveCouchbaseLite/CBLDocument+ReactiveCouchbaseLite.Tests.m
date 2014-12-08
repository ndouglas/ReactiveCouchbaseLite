//
//  CBLDocument+ReactiveCouchbaseLite.Tests.m
//  ReactiveCouchbaseLite
//
//  Created by Nathan Douglas on 12/4/14.
//  Released into the public domain.
//  See LICENSE for details.
//

#import <XCTest/XCTest.h>
#import "RCLTestDefinitions.h"
#import "ReactiveCouchbaseLite.h"

@interface CBLDocument_ReactiveCouchbaseLiteTests : XCTestCase {
    CBLManager *_manager;
    NSString *_databaseName;
    RACScheduler *_failScheduler;
}

@end

@implementation CBLDocument_ReactiveCouchbaseLiteTests

- (void)setUp {
	[super setUp];
    _manager = [CBLManager sharedInstance];
    _databaseName = [NSString stringWithFormat:@"test_%@", @([[[NSUUID UUID] UUIDString] hash])];
    _failScheduler = [[RACQueueScheduler alloc] initWithName:@"FailQueue" queue:dispatch_queue_create("FailQueue", DISPATCH_QUEUE_SERIAL)];
}

- (void)tearDown {
	[super tearDown];
}

- (void)testDelete {
    NSString *ID = [[NSUUID UUID] UUIDString];
    [self expectCompletionFromSignal:[[[[CBLManager rcl_databaseNamed:_databaseName]
    flattenMap:^RACSignal *(CBLDatabase *database) {
        return [database rcl_documentWithID:ID];
    }]
    flattenMap:^RACSignal *(CBLDocument *document) {
        return [document rcl_putProperties:@{}];
    }]
    then:^RACSignal *{
        return [[[CBLManager rcl_databaseNamed:_databaseName]
        flattenMap:^RACSignal *(CBLDatabase *database) {
            return [database rcl_documentWithID:ID];
        }]
        flattenMap:^RACSignal *(CBLDocument *document) {
            return [document rcl_delete];
        }];
    }]
    timeout:5.0 description:@"document updated and then deleted successfully"];
}

- (void)testPurge {
    NSString *ID = [[NSUUID UUID] UUIDString];
    [self expectCompletionFromSignal:[[[[CBLManager rcl_databaseNamed:_databaseName]
    flattenMap:^RACSignal *(CBLDatabase *database) {
        return [database rcl_documentWithID:ID];
    }]
    flattenMap:^RACSignal *(CBLDocument *document) {
        return [document rcl_putProperties:@{}];
    }]
    then:^RACSignal *{
        return [[[CBLManager rcl_databaseNamed:_databaseName]
        flattenMap:^RACSignal *(CBLDatabase *database) {
            return [database rcl_documentWithID:ID];
        }]
        flattenMap:^RACSignal *(CBLDocument *document) {
            return [document rcl_purge];
        }];
    }]
    timeout:5.0 description:@"document updated and then purged successfully"];
}

- (void)asynchronouslyPostTrivialChangeToDocumentWithID:(NSString *)ID {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [[[[CBLManager sharedInstance] databaseNamed:_databaseName error:NULL] documentWithID:ID] putProperties:@{} error:NULL];
    });
}

- (void)testDocumentChangeNotifications {
    NSString *ID = [[NSUUID UUID] UUIDString];
    [self asynchronouslyPostTrivialChangeToDocumentWithID:ID];
    [self expectCompletionFromSignal:[[[[[CBLManager rcl_databaseNamed:_databaseName]
    flattenMap:^RACSignal *(CBLDatabase *database) {
        return [database rcl_documentWithID:ID];
    }]
    flattenMap:^RACSignal *(CBLDocument *document) {
        RACSignal *result = [document rcl_documentChangeNotifications];
        return result;
    }]
    take:1]
    flattenMap:^RACSignal *(CBLDatabaseChange *databaseChange) {
        XCTAssertEqualObjects(ID, databaseChange.documentID);
        return [RACSignal empty];
    }]
    timeout:5.0 description:@"document change observed successfully"];
}

- (void)testCurrentRevisionID {
    NSString *ID = [[NSUUID UUID] UUIDString];
    [self asynchronouslyPostTrivialChangeToDocumentWithID:ID];
    [self expectCompletionFromSignal:[[[[[[CBLManager rcl_databaseNamed:_databaseName]
    flattenMap:^RACSignal *(CBLDatabase *database) {
        return [database rcl_documentWithID:ID];
    }]
    flattenMap:^RACSignal *(CBLDocument *document) {
        RACSignal *result = [document rcl_currentRevisionID];
        return result;
    }]
    take:2]
    ignore:nil]
    flattenMap:^RACSignal *(NSString *currentRevisionID) {
        XCTAssertNotNil(currentRevisionID);
        return [RACSignal empty];
    }]
    timeout:5.0 description:@"revision id observed successfully"];
}

- (void)testCurrentRevision {
    NSString *ID = [[NSUUID UUID] UUIDString];
    [self asynchronouslyPostTrivialChangeToDocumentWithID:ID];
    [self expectCompletionFromSignal:[[[[[CBLManager rcl_databaseNamed:_databaseName]
    flattenMap:^RACSignal *(CBLDatabase *database) {
        return [database rcl_documentWithID:ID];
    }]
    flattenMap:^RACSignal *(CBLDocument *document) {
        RACSignal *result = [document rcl_currentRevision];
        return result;
    }]
    take:1]
    flattenMap:^RACSignal *(CBLSavedRevision *currentRevision) {
        XCTAssertNotNil(currentRevision);
        return [RACSignal empty];
    }]
    timeout:5.0 description:@"revision observed successfully"];
}

- (void)testRevisionWithID {
    NSString *ID = [[NSUUID UUID] UUIDString];
    [self asynchronouslyPostTrivialChangeToDocumentWithID:ID];
    [self expectCompletionFromSignal:[[[[[[[CBLManager rcl_databaseNamed:_databaseName]
    flattenMap:^RACSignal *(CBLDatabase *database) {
        return [database rcl_documentWithID:ID];
    }]
    flattenMap:^RACSignal *(CBLDocument *document) {
        RACSignal *result = [document rcl_currentRevisionID];
        return result;
    }]
    take:2]
    ignore:nil]
    flattenMap:^RACSignal *(NSString *currentRevisionID) {
        return [[[CBLManager rcl_databaseNamed:_databaseName]
        flattenMap:^RACSignal *(CBLDatabase *database) {
            return [database rcl_documentWithID:ID];
        }]
        flattenMap:^RACSignal *(CBLDocument *document) {
            return [document rcl_revisionWithID:currentRevisionID];
        }];
    }]
    flattenMap:^RACSignal *(CBLSavedRevision *revision) {
        XCTAssertNotNil(revision);
        return [RACSignal empty];
    }]
    timeout:5.0 description:@"revision fetched successfully"];
}

- (void)testGetRevisionHistory {
    NSString *ID = [[NSUUID UUID] UUIDString];
    [self asynchronouslyPostTrivialChangeToDocumentWithID:ID];
    [self expectCompletionFromSignal:[[[[[[CBLManager rcl_databaseNamed:_databaseName]
    flattenMap:^RACSignal *(CBLDatabase *database) {
        return [database rcl_documentWithID:ID];
    }]
    flattenMap:^RACSignal *(CBLDocument *document) {
        RACSignal *result = [document rcl_getRevisionHistory];
        return result;
    }]
    ignore:nil]
    take:1]
    flattenMap:^RACSignal *(NSArray *revisionHistory) {
        XCTAssertNotNil(revisionHistory);
        return [RACSignal empty];
    }]
    timeout:5.0 description:@"revision history fetched successfully"];
}

- (void)testGetRevisionHistoryFilteredWithBlock {
    NSString *ID = [[NSUUID UUID] UUIDString];
    [self asynchronouslyPostTrivialChangeToDocumentWithID:ID];
    [self expectCompletionFromSignal:[[[[[[CBLManager rcl_databaseNamed:_databaseName]
    flattenMap:^RACSignal *(CBLDatabase *database) {
        return [database rcl_documentWithID:ID];
    }]
    flattenMap:^RACSignal *(CBLDocument *document) {
        RACSignal *result = [document rcl_getRevisionHistoryFilteredWithBlock:^BOOL(CBLSavedRevision *revision) {
            return revision != nil;
        }];
        return result;
    }]
    ignore:nil]
    take:1]
    flattenMap:^RACSignal *(NSArray *revisionHistory) {
        XCTAssertNotNil(revisionHistory);
        return [RACSignal empty];
    }]
    timeout:5.0 description:@"revision history fetched successfully"];
}

@end

/**
- (RACSignal *)rcl_getConflictingRevisions;
- (RACSignal *)rcl_getLeafRevisions;
- (RACSignal *)rcl_newRevision;
- (RACSignal *)rcl_properties;
- (RACSignal *)rcl_userProperties;
- (RACSignal *)rcl_putProperties:(NSDictionary *)properties;
- (RACSignal *)rcl_update:(BOOL(^)(CBLUnsavedRevision *))block;
 */
