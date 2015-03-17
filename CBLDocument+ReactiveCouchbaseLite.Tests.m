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

@interface CBLDocument_ReactiveCouchbaseLiteTests : RCLTestCase
@end

@implementation CBLDocument_ReactiveCouchbaseLiteTests

- (void)setUp {
	[super setUp];
    [self rcl_setupEverything];
}

- (void)tearDown {
    [self rcl_tearDown];
	[super tearDown];
}

- (void)testDelete {
    NSString *ID = [[NSUUID UUID] UUIDString];
    [self rcl_expectCompletionFromSignal:[[[[CBLManager rcl_databaseNamed:self.testName]
    flattenMap:^RACSignal *(CBLDatabase *database) {
        return [database rcl_documentWithID:ID];
    }]
    flattenMap:^RACSignal *(CBLDocument *document) {
        return [document rcl_putProperties:@{}];
    }]
    then:^RACSignal *{
        return [[[CBLManager rcl_databaseNamed:self.testName]
        flattenMap:^RACSignal *(CBLDatabase *database) {
            return [database rcl_documentWithID:ID];
        }]
        flattenMap:^RACSignal *(CBLDocument *document) {
            return [[document rcl_delete]
                ignoreValues];
        }];
    }]
    timeout:5.0 description:@"document updated and then deleted successfully"];
}

- (void)testPurge {
    NSString *ID = [[NSUUID UUID] UUIDString];
    [self rcl_expectCompletionFromSignal:[[[[CBLManager rcl_databaseNamed:self.testName]
    flattenMap:^RACSignal *(CBLDatabase *database) {
        return [database rcl_documentWithID:ID];
    }]
    flattenMap:^RACSignal *(CBLDocument *document) {
        return [document rcl_putProperties:@{}];
    }]
    then:^RACSignal *{
        return [[[CBLManager rcl_databaseNamed:self.testName]
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
        [[[[CBLManager sharedInstance] databaseNamed:self.testName error:NULL] documentWithID:ID] putProperties:@{} error:NULL];
    });
}

- (void)testDocumentChangeNotifications {
    NSString *ID = [[NSUUID UUID] UUIDString];
    [self asynchronouslyPostTrivialChangeToDocumentWithID:ID];
    [self rcl_expectCompletionFromSignal:[[[[[CBLManager rcl_databaseNamed:self.testName]
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
    [self rcl_expectCompletionFromSignal:[[[[[[CBLManager rcl_databaseNamed:self.testName]
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
    [self rcl_expectCompletionFromSignal:[[[[[CBLManager rcl_databaseNamed:self.testName]
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
    [self rcl_expectCompletionFromSignal:[[[[[[[CBLManager rcl_databaseNamed:self.testName]
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
        return [[[CBLManager rcl_databaseNamed:self.testName]
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


- (void)testNewRevision {
    sleep(1);
}

- (void)testProperties {
    sleep(1);
}

- (void)testUserProperties {
    sleep(1);
}

- (void)testPutProperties {
    sleep(1);
}

- (void)testResolveConflictsWithBlock {
    NSString *documentID = [[NSUUID UUID] UUIDString];
    [[self.testDatabase documentWithID:documentID] update:^BOOL(CBLUnsavedRevision *unsavedRevision) {
        unsavedRevision.properties[@"name"] = [[NSUUID UUID] UUIDString];
        unsavedRevision.properties[[[NSUUID UUID] UUIDString]] = [[NSUUID UUID] UUIDString];
        return YES;
    } error:NULL];
    [[self.peerDatabase documentWithID:documentID] update:^BOOL(CBLUnsavedRevision *unsavedRevision) {
        unsavedRevision.properties[@"name"] = [[NSUUID UUID] UUIDString];
        unsavedRevision.properties[[[NSUUID UUID] UUIDString]] = [[NSUUID UUID] UUIDString];
        return YES;
    } error:NULL];
    XCTAssertNotNil([self.testDatabase documentWithID:documentID]);
    XCTAssertNotNil([self.peerDatabase documentWithID:documentID]);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.pushReplication.continuous = self.pullReplication.continuous = YES;
        [self.pushReplication start];
        [self.pullReplication start];
    });
    XCTestExpectation *expectation = [self expectationWithDescription:@"conflict resolved"];
    RACDisposable *disposable = [[self.testDatabase rcl_resolveConflictsWithBlock:^NSDictionary *(NSArray *conflictingRevisions) {
        NSLog(@"conflicting revisions: %@", conflictingRevisions);
        return [[[conflictingRevisions[0] document] currentRevision] properties];
    }]
    subscribeNext:^(id x) {
        NSLog(@"signal received next: %@", x);
        [expectation fulfill];
    } error:^(NSError *error) {
        XCTFail(@"signal not supposed to error: %@", error);
    } completed:^{
        XCTFail(@"signal not supposed to complete");
    }];
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Encountered error: %@", error);
        }
        [self.pushReplication stop];
        [self.pullReplication stop];
        [disposable dispose];
    }];
}

@end
