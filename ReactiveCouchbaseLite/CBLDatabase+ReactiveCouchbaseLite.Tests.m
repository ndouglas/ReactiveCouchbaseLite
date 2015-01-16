//
//  CBLDatabase+ReactiveCouchbaseLite.Tests.m
//  ReactiveCouchbaseLite
//
//  Created by Nathan Douglas on 11/18/14.
//  Released into the public domain.
//  See LICENSE for details.
//

#import <XCTest/XCTest.h>
#import "RCLTestDefinitions.h"
#import "ReactiveCouchbaseLite.h"

typedef void (^RCLObjectTesterBlock)(id);
typedef RCLObjectTesterBlock (^RCLObjectTesterGeneratorBlock)(id);

@interface CBLDatabase_ReactiveCouchbaseLiteTests : RCLTestCase

@end

@implementation CBLDatabase_ReactiveCouchbaseLiteTests

- (void)setUp {
	[super setUp];
    [self rcl_setupEverything];
}

- (void)tearDown {
    [self rcl_tearDown];
	[super tearDown];
}

- (void)testClose {
    [self rcl_expectCompletionFromSignal:[self.testDatabase rcl_close]
    timeout:5.0 description:@"database closed successfully"];
    [self rcl_expectCompletionFromSignal:[[CBLManager rcl_databaseNamed:self.testName]
    flattenMap:^RACSignal *(CBLDatabase *database) {
        return [database rcl_close];
    }]
    timeout:5.0 description:@"database closed successfully"];
}

- (void)testCompact {
    [self rcl_expectCompletionFromSignal:[self.testDatabase rcl_compact]
    timeout:5.0 description:@"database compacted successfully"];
    [self rcl_expectCompletionFromSignal:[[CBLManager rcl_databaseNamed:self.testName]
    flattenMap:^RACSignal *(CBLDatabase *database) {
        return [database rcl_compact];
    }]
    timeout:5.0 description:@"database compacted successfully"];
}

- (void)testDelete {
    [self rcl_expectCompletionFromSignal:[[self.testDatabase rcl_delete]
    then:^RACSignal *{
        return [[[[CBLManager rcl_existingDatabaseNamed:self.testName]
        doNext:^(CBLDatabase *database) {
            XCTFail(@"database '%@' was apparently not deleted", self.testName);
        }]
        doCompleted:^{
            XCTFail(@"database '%@' was apparently not deleted", self.testName);
        }]
        catchTo:[RACSignal empty]];
    }] timeout:5.0 description:@"database deleted successfully"];
    [self rcl_expectCompletionFromSignal:[[[CBLManager rcl_databaseNamed:self.testName]
    flattenMap:^RACSignal *(CBLDatabase *database) {
        return [database rcl_delete];
    }]
    then:^RACSignal *{
        return [[[[CBLManager rcl_existingDatabaseNamed:self.testName]
        doNext:^(CBLDatabase *database) {
            XCTFail(@"database '%@' was apparently not deleted", self.testName);
        }]
        doCompleted:^{
            XCTFail(@"database '%@' was apparently not deleted", self.testName);
        }]
        catchTo:[RACSignal empty]];
    }] timeout:5.0 description:@"database deleted successfully"];
    self.testDatabase = nil;
}

- (void)testDocumentWithID {
    NSString *ID = [[NSUUID UUID] UUIDString];
    [self rcl_expectNext:^(CBLDocument *document) {
        NSLog(@"Opened document %@", document);
    } signal:[self.testDatabase rcl_documentWithID:ID]
    timeout:5.0 description:@"document created/opened successfully"];
    [self rcl_expectNext:^(CBLDocument *document) {
        NSLog(@"Opened document %@", document);
    } signal:[[CBLManager rcl_databaseNamed:self.testName]
    flattenMap:^RACSignal *(CBLDatabase *database) {
        return [database rcl_documentWithID:ID];
    }]
    timeout:5.0 description:@"document created/opened successfully"];
}

- (void)testCreateDocument {
    [self rcl_expectNext:^(CBLDocument *document) {
        NSLog(@"Created document %@", document);
    } signal:[self.testDatabase rcl_createDocument]
    timeout:5.0 description:@"document created/opened successfully"];
    [self rcl_expectNext:^(CBLDocument *document) {
        NSLog(@"Created document %@", document);
    } signal:[[CBLManager rcl_databaseNamed:self.testName]
    flattenMap:^RACSignal *(CBLDatabase *database) {
        return [database rcl_createDocument];
    }]
    timeout:5.0 description:@"document created/opened successfully"];
}

- (void)testExistingDocumentWithID {
    NSString *ID = [[NSUUID UUID] UUIDString];
    [self rcl_expectCompletionFromSignal:[[[[[[self.testDatabase documentWithID:ID] newRevision] rcl_save]
    ignoreValues]
    then:^RACSignal *{
        return [[self.testDatabase existingDocumentWithID:ID] rcl_delete];
    }]
    then:^RACSignal *{
        return [[self.testDatabase rcl_existingDocumentWithID:ID]
        catchTo:[RACSignal empty]];
    }]
    timeout:5.0 description:@"document created/opened/deleted successfully"];
    ID = [[NSUUID UUID] UUIDString];
    [self rcl_expectCompletionFromSignal:[[[[[[[[[[[CBLManager rcl_databaseNamed:self.testName]
    flattenMap:^RACSignal *(CBLDatabase *database) {
        return [database rcl_documentWithID:ID];
    }]
    flattenMap:^RACSignal *(CBLDocument *document) {
        return [document rcl_newRevision];
    }]
    flattenMap:^RACSignal *(CBLUnsavedRevision *unsavedRevision) {
        return [unsavedRevision rcl_save];
    }]
    doNext:^(id _next_) {
        NSLog(@"Next");
    }]
    doError:^(NSError *error) {
        NSLog(@"Error");
    }]
    doCompleted:^{
        NSLog(@"Completed");
    }]
    then:^RACSignal *{
        return [[CBLManager rcl_databaseNamed:self.testName]
        flattenMap:^RACSignal *(CBLDatabase *database) {
            return [database rcl_existingDocumentWithID:ID];
        }];
    }]
    flattenMap:^RACSignal *(CBLDocument *document) {
        return [document rcl_delete];
    }]
    then:^RACSignal *{
        return [[CBLManager rcl_databaseNamed:self.testName]
        flattenMap:^RACSignal *(CBLDatabase *database) {
            return [database rcl_existingDocumentWithID:ID];
        }];
    }]
    catchTo:[RACSignal empty]]
    timeout:5.0 description:@"document created/opened/deleted successfully"];
}

- (void)testExistingLocalDocumentWithID {
    NSString *ID = [[NSUUID UUID] UUIDString];
    [self rcl_expectCompletionFromSignal:[[[[[[self.testDatabase rcl_existingLocalDocumentWithID:ID]
    doNext:^(NSDictionary *localDocument){
        XCTFail(@"Should not have found a local document: %@ !", localDocument);
    }]
    doCompleted:^{
        XCTFail(@"Should not have completed!");
    }]
    catchTo:[RACSignal empty]]
    then:^RACSignal *{
        return [self.testDatabase rcl_putLocalDocumentWithProperties:@{} ID:ID];
    }]
    then:^RACSignal *{
        return [[self.testDatabase rcl_existingLocalDocumentWithID:ID]
        flattenMap:^RACSignal *(NSDictionary *localDocument) {
            return [RACSignal empty];
        }];
    }] timeout:5.0 description:@"local document created"];
    ID = [[NSUUID UUID] UUIDString];
    [self rcl_expectCompletionFromSignal:[[[[[[[CBLManager rcl_databaseNamed:self.testName]
    flattenMap:^RACSignal *(CBLDatabase *database) {
        return [database rcl_existingLocalDocumentWithID:ID];
    }]
    doNext:^(NSDictionary *localDocument){
        XCTFail(@"Should not have found a local document: %@ !", localDocument);
    }]
    doCompleted:^{
        XCTFail(@"Should not have completed!");
    }]
    catchTo:[RACSignal empty]]
    then:^RACSignal *{
        return [[CBLManager rcl_databaseNamed:self.testName]
        flattenMap:^RACSignal *(CBLDatabase *database) {
            return [database rcl_putLocalDocumentWithProperties:@{} ID:ID];
        }];
    }]
    then:^RACSignal *{
        return [[[CBLManager rcl_databaseNamed:self.testName]
        flattenMap:^RACSignal *(CBLDatabase *database) {
            return [database rcl_existingLocalDocumentWithID:ID];
        }]
        flattenMap:^RACSignal *(NSDictionary *localDocument) {
            return [RACSignal empty];
        }];
    }] timeout:5.0 description:@"local document created"];
}

- (void)testDeleteLocalDocumentWithID {
    NSString *ID = [[NSUUID UUID] UUIDString];
    [self rcl_expectError:^(NSError *error) {
        NSLog(@"Received error: %@", error);
    } signal:[[CBLManager rcl_databaseNamed:self.testName]
    flattenMap:^RACSignal *(CBLDatabase *database) {
        return [database rcl_existingLocalDocumentWithID:ID];
    }] timeout:5.0 description:@"local document not found"];
    [self rcl_expectCompletionFromSignal:[[[CBLManager rcl_databaseNamed:self.testName]
    flattenMap:^RACSignal *(CBLDatabase *database) {
        return [database rcl_putLocalDocumentWithProperties:@{} ID:ID];
    }]
    then:^RACSignal *{
        return [[[CBLManager rcl_databaseNamed:self.testName]
        flattenMap:^RACSignal *(CBLDatabase *database) {
            return [database rcl_deleteLocalDocumentWithID:ID];
        }]
        then:^RACSignal *{
            return [[[[CBLManager rcl_databaseNamed:self.testName]
            flattenMap:^RACSignal *(CBLDatabase *database) {
                return [database rcl_existingLocalDocumentWithID:ID];
            }]
            doCompleted:^{
                XCTFail(@"Local document '%@' was apparently not deleted", ID);
            }]
            catchTo:[RACSignal empty]];
        }];
    }] timeout:5.0 description:@"local document deleted"];
}

- (void)testAllDocumentsQuery {
    [self rcl_expectNext:^(CBLQuery *query) {
        XCTAssertTrue([query isKindOfClass:[CBLQuery class]]);
    } signal:[[CBLManager rcl_databaseNamed:self.testName]
    flattenMap:^RACSignal *(CBLDatabase *database) {
        return [database rcl_allDocumentsQuery];
    }] timeout:5.0 description:@"all documents query created"];
}

- (void)testAllDocumentsQueryWithMode {
    [self rcl_expectNext:^(CBLQuery *query) {
        XCTAssertTrue([query isKindOfClass:[CBLQuery class]]);
        XCTAssertEqual(kCBLOnlyConflicts, query.allDocsMode);
    } signal:[[CBLManager rcl_databaseNamed:self.testName]
    flattenMap:^RACSignal *(CBLDatabase *database) {
        return [database rcl_allDocumentsQueryWithMode:kCBLOnlyConflicts];
    }] timeout:5.0 description:@"all documents query created"];
}

- (void)testAllDocumentsQueryWithModeIndexUpdateMode {
    [self rcl_expectNext:^(CBLQuery *query) {
        XCTAssertTrue([query isKindOfClass:[CBLQuery class]]);
        XCTAssertEqual(kCBLOnlyConflicts, query.allDocsMode);
        XCTAssertEqual(kCBLUpdateIndexAfter, query.indexUpdateMode);
    } signal:[[CBLManager rcl_databaseNamed:self.testName]
    flattenMap:^RACSignal *(CBLDatabase *database) {
        return [database rcl_allDocumentsQueryWithMode:kCBLOnlyConflicts indexUpdateMode:kCBLUpdateIndexAfter];
    }] timeout:5.0 description:@"all documents query created"];
}

- (void)testSlowQueryWithMap {
    NSString *ID = [[NSUUID UUID] UUIDString];
    [self rcl_expectCompletionFromSignal:[[[[[CBLManager rcl_databaseNamed:self.testName]
    flattenMap:^RACSignal *(CBLDatabase *database) {
        return [database rcl_documentWithID:ID];
    }]
    flattenMap:^RACSignal *(CBLDocument *document) {
        return [document rcl_newRevision];
    }]
    flattenMap:^RACSignal *(CBLUnsavedRevision *unsavedRevision) {
        return [unsavedRevision rcl_save];
    }]
    then:^RACSignal *{
        return [[[[[CBLManager rcl_databaseNamed:self.testName]
        flattenMap:^RACSignal *(CBLDatabase *database) {
            return [database rcl_slowQueryWithMap:^(NSDictionary *document, CBLMapEmitBlock emit) {
                emit(document[@"_id"], document);
            }];
        }]
        flattenMap:^RACSignal *(CBLQuery *query) {
            return [query rcl_run];
        }]
        flattenMap:^RACSignal *(CBLQueryEnumerator *enumerator) {
            return [enumerator rcl_nextRow];
        }]
        flattenMap:^RACStream *(CBLQueryRow *row) {
            XCTAssertEqualObjects(row.documentID, ID);
            return [RACSignal empty];
        }];
    }]
    timeout:5.0 description:@"slow query created"];
}

- (void)testViewNamed {
    NSString *ID = [[NSUUID UUID] UUIDString];
    [self rcl_expectNext:^(CBLView *view) {
        XCTAssertTrue([view isKindOfClass:[CBLView class]]);
    } signal:[[CBLManager rcl_databaseNamed:self.testName]
    flattenMap:^RACSignal *(CBLDatabase *database) {
        return [database rcl_viewNamed:ID];
    }] timeout:5.0 description:@"view opened"];
}

- (void)testExistingViewNamed {
    NSString *ID = [[NSUUID UUID] UUIDString];
    [self rcl_expectCompletionFromSignal:[[[[[[[CBLManager rcl_databaseNamed:self.testName]
    flattenMap:^RACSignal *(CBLDatabase *database) {
        return [database rcl_existingViewNamed:ID];
    }]
    catch:^RACSignal *(NSError *error) {
        return [[CBLManager rcl_databaseNamed:self.testName]
        flattenMap:^RACSignal *(CBLDatabase *database) {
            return [database rcl_viewNamed:ID];
        }];
    }]
    flattenMap:^RACSignal *(CBLView *view) {
        [view setMapBlock:^(NSDictionary *document, CBLMapEmitBlock emit) {
            emit(document[@"_id"], document);
        } version:ID];
        return [RACSignal return:view];
    }]
    flattenMap:^RACSignal *(CBLView *view) {
        return [RACSignal empty];
    }]
    then:^RACSignal * {
        return [[CBLManager rcl_databaseNamed:self.testName]
        flattenMap:^RACSignal *(CBLDatabase *database) {
            return [database rcl_existingViewNamed:ID];
        }];
    }]
    flattenMap:^RACSignal *(CBLView *view) {
        return [RACSignal empty];
    }]
    timeout:5.0 description:@"returns only existing views"];
}

- (void)testSetValidationNamedAsBlock {
    NSString *ID = [[NSUUID UUID] UUIDString];
    [self rcl_expectCompletionFromSignal:[[CBLManager rcl_databaseNamed:self.testName]
    flattenMap:^RACSignal *(CBLDatabase *database) {
        return [database rcl_setValidationNamed:ID asBlock:^(CBLRevision *newRevision, id<CBLValidationContext> context) {
        }];
    }] timeout:5.0 description:@"correctly sets validation block"];
}

- (void)testValidationNamed {
    NSString *ID = [[NSUUID UUID] UUIDString];
    [self rcl_expectNext:^(id block) {
        XCTAssertTrue([block isKindOfClass:[NSObject class]]);
    } signal:[[[[CBLManager rcl_databaseNamed:self.testName]
    flattenMap:^RACSignal *(CBLDatabase *database) {
        return [database rcl_validationNamed:ID];
    }]
    catch:^RACSignal *(NSError *error) {
        return [[CBLManager rcl_databaseNamed:self.testName]
        flattenMap:^RACSignal *(CBLDatabase *database) {
            return [database rcl_setValidationNamed:ID asBlock:^(CBLRevision *newRevision, id<CBLValidationContext> context) {
            }];
        }];
    }]
    then:^RACSignal *{
        return [[CBLManager rcl_databaseNamed:self.testName]
        flattenMap:^RACSignal *(CBLDatabase *database) {
            return [database rcl_validationNamed:ID];
        }];
    }] timeout:5.0 description:@"correctly sets validation block"];
}

- (void)testSetFilterNamedAsBlock {
    NSString *ID = [[NSUUID UUID] UUIDString];
    [self rcl_expectCompletionFromSignal:[[CBLManager rcl_databaseNamed:self.testName]
    flattenMap:^RACSignal *(CBLDatabase *database) {
        return [database rcl_setFilterNamed:ID asBlock:^BOOL(CBLSavedRevision *revision, NSDictionary *params) {
            return YES;
        }];
    }]
    timeout:5.0 description:@"correctly sets filter block"];
}

- (void)testFilterNamed {
    NSString *ID = [[NSUUID UUID] UUIDString];
    [self rcl_expectNext:^(id block) {
        XCTAssertTrue([block isKindOfClass:[NSObject class]]);
    } signal:[[[[CBLManager rcl_databaseNamed:self.testName]
    flattenMap:^RACSignal *(CBLDatabase *database) {
        return [database rcl_filterNamed:ID];
    }]
    catch:^RACSignal *(NSError *error) {
        return [[CBLManager rcl_databaseNamed:self.testName]
        flattenMap:^RACSignal *(CBLDatabase *database) {
            return [database rcl_setFilterNamed:ID asBlock:^BOOL(CBLSavedRevision *revision, NSDictionary *params) {
                return YES;
            }];
        }];
    }]
    then:^RACSignal *{
        return [[CBLManager rcl_databaseNamed:self.testName]
        flattenMap:^RACSignal *(CBLDatabase *database) {
            return [database rcl_filterNamed:ID];
        }];
    }] timeout:5.0 description:@"correctly sets filter block"];
}

- (void)testInTransaction {
    __block BOOL completed = NO;
    [[self.testDatabase
    rcl_inTransaction:^BOOL(CBLDatabase *database) {
        XCTAssertTrue(database.rcl_isOnScheduler);
        return YES;
    }]
    subscribeCompleted:^{
        NSLog(@"Wheeee!");
    }];
    [self rcl_expectCompletionFromSignal:[[CBLManager rcl_databaseNamed:self.testName]
    flattenMap:^RACSignal *(CBLDatabase *database) {
        return [database rcl_inTransaction:^BOOL (CBLDatabase *database) {
            XCTAssertTrue(database.rcl_isOnScheduler);
            completed = !completed;
            return YES;
        }];
    }] timeout:5.0 description:@"correctly commits transaction."];
    XCTAssertTrue(completed);
}

- (void)testDoAsync {
    __block BOOL completed = NO;
    [self rcl_expectCompletionFromSignal:[[[[[CBLManager rcl_databaseNamed:self.testName]
    flattenMap:^RACSignal *(CBLDatabase *database) {
        return [database rcl_doAsync:^{
            sleep(1);
            completed = YES;
        }];
    }]
    then:^RACSignal *{
        return [RACSignal error:[NSError errorWithDomain:NSStringFromClass([self class]) code:(0+completed) userInfo:@{}]];
    }]
    catch:^RACSignal *(NSError *error) {
        XCTAssertNotNil(error);
        XCTAssertTrue(error.code == 0);
        return [[RACSignal empty] delay:1.1];
    }]
    then:^RACSignal *{
        XCTAssertTrue(completed);
        return [RACSignal empty];
    }] timeout:5.0 description:@"correctly asynchronously invokes block."];
}

- (void)testDatabaseChangeNotifications {
    NSString *documentID = [[NSUUID UUID] UUIDString];
    CBLDocument *document = [self.testDatabase documentWithID:documentID];
    [self rcl_triviallyUpdateDocument:document times:2 interval:0.1];
    [self rcl_expectNexts:@[
        ^(CBLDatabaseChange *databaseChange) {
            XCTAssertTrue([databaseChange.revisionID characterAtIndex:0] == '1');
        },
        ^(CBLDatabaseChange *databaseChange) {
            XCTAssertTrue([databaseChange.revisionID characterAtIndex:0] == '2');
        },
        ^(CBLDatabaseChange *databaseChange) {
             XCTAssertTrue([databaseChange.revisionID characterAtIndex:0] == '3');
        },
    ] signal:[self.testDatabase rcl_databaseChangeNotifications] timeout:5.0 description:@"received database change notifications"];
}

- (void)testDeleteDocumentWithID {
    NSString *documentID = [[NSUUID UUID] UUIDString];
    [[self.testDatabase documentWithID:documentID] update:^BOOL(CBLUnsavedRevision *unsavedRevision) {
        unsavedRevision.properties[@"name"] = [[NSUUID UUID] UUIDString];
        return YES;
    } error:NULL];
    [self rcl_expectCompletionFromSignal:[self.testDatabase rcl_deleteDocumentWithID:documentID] timeout:5.0 description:@"document deleted"];
}

- (void)testDeletePreservingPropertiesDocumentWithID {
    NSString *documentID = [[NSUUID UUID] UUIDString];
    [[self.testDatabase documentWithID:documentID] update:^BOOL(CBLUnsavedRevision *unsavedRevision) {
        unsavedRevision.properties[@"name"] = [[NSUUID UUID] UUIDString];
        return YES;
    } error:NULL];
    [self rcl_expectCompletionFromSignal:[self.testDatabase rcl_deletePreservingPropertiesDocumentWithID:documentID] timeout:5.0 description:@"document deleted"];
}

- (void)testDeleteDocumentWithIDModifyingPropertiesWithBlock {
    NSString *documentID = [[NSUUID UUID] UUIDString];
    [[self.testDatabase documentWithID:documentID] update:^BOOL(CBLUnsavedRevision *unsavedRevision) {
        unsavedRevision.properties[@"name"] = [[NSUUID UUID] UUIDString];
        return YES;
    } error:NULL];
    [self rcl_expectCompletionFromSignal:[self.testDatabase rcl_deleteDocumentWithID:documentID modifyingPropertiesWithBlock:^(CBLUnsavedRevision *proposedRevision) {
        proposedRevision.properties[@"name"] = [[NSUUID UUID] UUIDString];
    }] timeout:5.0 description:@"document deleted"];
}

- (void)testOnDocumentWithIDPerformBlock {
    __block BOOL complete = NO;
    NSString *documentID = [[NSUUID UUID] UUIDString];
    NSString *UUID = [[NSUUID UUID] UUIDString];
    [[self.testDatabase documentWithID:documentID] update:^BOOL(CBLUnsavedRevision *unsavedRevision) {
        unsavedRevision.properties[@"name"] = UUID;
        return YES;
    } error:NULL];
    [self rcl_expectCompletionFromSignal:[self.testDatabase rcl_onDocumentWithID:documentID performBlock:^(CBLDocument *document) {
        XCTAssertTrue([document.properties[@"name"] isEqualToString:UUID]);
        complete = YES;
    }] timeout:5.0 description:@"document deleted"];
    XCTAssertTrue(complete);
}

- (void)testUpdateDocumentWithIDBlock {
    NSString *documentID = [[NSUUID UUID] UUIDString];
    NSString *UUID = [[NSUUID UUID] UUIDString];
    [[self.testDatabase documentWithID:documentID] update:^BOOL(CBLUnsavedRevision *unsavedRevision) {
        unsavedRevision.properties[@"name"] = UUID;
        return YES;
    } error:NULL];
    [self rcl_expectCompletionFromSignal:[[self.testDatabase rcl_updateDocumentWithID:documentID block:^BOOL(CBLUnsavedRevision *unsavedRevision) {
        unsavedRevision.properties[@"UUID"] = unsavedRevision.properties[@"name"];
        return YES;
    }]
    then:^RACSignal *{
        return [RACSignal empty];
    }] timeout:5.0 description:@"document deleted"];
    CBLDocument *document = [self.testDatabase documentWithID:documentID];
    XCTAssertTrue([document.properties[@"UUID"] isEqualToString:UUID]);
}

- (void)testUpdateLocalDocumentWithIDBlock {
    NSString *documentID = [[NSUUID UUID] UUIDString];
    NSString *UUID = [[NSUUID UUID] UUIDString];
    [self.testDatabase putLocalDocument:@{
        @"name" : UUID,
    } withID:documentID error:NULL];
    [self rcl_expectCompletionFromSignal:[[self.testDatabase rcl_updateLocalDocumentWithID:documentID block:^NSDictionary *(NSMutableDictionary *localDocument) {
        localDocument[@"UUID"] = localDocument[@"name"];
        return localDocument;
    }]
    then:^RACSignal *{
        return [RACSignal empty];
    }] timeout:5.0 description:@"document deleted"];
    NSDictionary *localDocument = [self.testDatabase existingLocalDocumentWithID:documentID];
    XCTAssertTrue([localDocument[@"UUID"] isEqualToString:UUID]);
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
        [expectation fulfill];
        return [[[conflictingRevisions[0] document] currentRevision] properties];
    }]
    subscribeNext:^(id x) {
        XCTFail(@"signal not supposed to next: %@", x);
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
