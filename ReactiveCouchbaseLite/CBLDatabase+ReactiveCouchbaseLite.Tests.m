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

@interface CBLDatabase_ReactiveCouchbaseLiteTests : XCTestCase {
    CBLManager *_manager;
    NSString *_databaseName;
    NSString *_peerDatabaseName;
    RACScheduler *_failScheduler;
    CBLListener *_listener;
}

@end

@implementation CBLDatabase_ReactiveCouchbaseLiteTests

- (void)setUp {
	[super setUp];
    _manager = [CBLManager sharedInstance];
    _databaseName = [NSString stringWithFormat:@"test_%@", @([[[NSUUID UUID] UUIDString] hash])];
    _peerDatabaseName = [NSString stringWithFormat:@"test_%@", @([[[NSUUID UUID] UUIDString] hash])];
    _failScheduler = [[RACQueueScheduler alloc] initWithName:@"FailQueue" queue:dispatch_queue_create("FailQueue", DISPATCH_QUEUE_SERIAL)];
    _listener = [[CBLListener alloc] initWithManager:[CBLManager sharedInstance] port:2014];
    NSError *error = nil;
    XCTAssertTrue([_listener start:&error]);
}

- (void)tearDown {
    [_listener stop];
    NSError *error = nil;
    [[[CBLManager sharedInstance] databaseNamed:_databaseName error:&error] deleteDatabase:&error];
	[super tearDown];
}

- (void)updateDocument:(CBLDocument *)document withBlock:(BOOL (^)(CBLUnsavedRevision *newRevision))updater completionHandler:(void (^)(BOOL success, NSError *error))block {
    NSError *error = nil;
    BOOL success = [document update:updater error:&error] != nil;
    block(success, error);
}

- (void)triviallyUpdateDocument:(CBLDocument *)document times:(NSUInteger)times interval:(NSTimeInterval)interval {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(interval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self updateDocument:document withBlock:^BOOL(CBLUnsavedRevision *newRevision) {
            newRevision.properties[[[NSUUID UUID] UUIDString]] = [[NSUUID UUID] UUIDString];
            return YES;
        } completionHandler:^(BOOL success, NSError *error) {
            if (!success) {
                NSLog(@"Error: %@", error);
            }
            XCTAssertTrue(success);
            if (times > 0) {
                [self triviallyUpdateDocument:document times:times - 1 interval:interval];
            }
        }];
    });
}

- (void)testClose {
    CBLDatabase *database = [[CBLManager sharedInstance] databaseNamed:_databaseName error:NULL];
    dispatch_async(((RACQueueScheduler *)_failScheduler).queue, ^{
        [[database rcl_close]
        subscribeError:^(NSError *error) {
            XCTFail(@"Operation failed with error: %@", error);
        }
        completed:^{
            NSLog(@"Operation completed.");
        }];
    });
    sleep(1);
    [self rcl_expectCompletionFromSignal:[[[CBLManager sharedInstance] databaseNamed:_databaseName error:NULL] rcl_close]
    timeout:5.0 description:@"database closed successfully"];
    [self rcl_expectCompletionFromSignal:[[CBLManager rcl_databaseNamed:_databaseName]
    flattenMap:^RACSignal *(CBLDatabase *database) {
        return [database rcl_close];
    }]
    timeout:5.0 description:@"database closed successfully"];
}

- (void)testCompact {
    CBLDatabase *database = [[CBLManager sharedInstance] databaseNamed:_databaseName error:NULL];
    dispatch_async(((RACQueueScheduler *)_failScheduler).queue, ^{
        [[database rcl_compact]
        subscribeError:^(NSError *error) {
            XCTFail(@"Operation failed with error: %@", error);
        }
        completed:^{
            NSLog(@"Operation completed.");
        }];
    });
    sleep(1);
    [self rcl_expectCompletionFromSignal:[[[CBLManager sharedInstance] databaseNamed:_databaseName error:NULL] rcl_compact]
    timeout:5.0 description:@"database compacted successfully"];
    [self rcl_expectCompletionFromSignal:[[CBLManager rcl_databaseNamed:_databaseName]
    flattenMap:^RACSignal *(CBLDatabase *database) {
        return [database rcl_compact];
    }]
    timeout:5.0 description:@"database compacted successfully"];
}

- (void)testDelete {
    CBLDatabase *database = [[CBLManager sharedInstance] databaseNamed:_databaseName error:NULL];
    dispatch_async(((RACQueueScheduler *)_failScheduler).queue, ^{
        [[database rcl_delete]
        subscribeError:^(NSError *error) {
            XCTFail(@"Operation failed with error: %@", error);
        }
        completed:^{
            NSLog(@"Operation completed.");
        }];
    });
    sleep(1);
    [self rcl_expectCompletionFromSignal:[[[[CBLManager sharedInstance] databaseNamed:_databaseName error:NULL] rcl_delete]
    then:^RACSignal *{
        return [[[[CBLManager rcl_existingDatabaseNamed:_databaseName]
        doNext:^(CBLDatabase *database) {
            XCTFail(@"database '%@' was apparently not deleted", _databaseName);
        }]
        doCompleted:^{
            XCTFail(@"database '%@' was apparently not deleted", _databaseName);
        }]
        catchTo:[RACSignal empty]];
    }] timeout:5.0 description:@"database deleted successfully"];
    [self rcl_expectCompletionFromSignal:[[[CBLManager rcl_databaseNamed:_databaseName]
    flattenMap:^RACSignal *(CBLDatabase *database) {
        return [database rcl_delete];
    }]
    then:^RACSignal *{
        return [[[[CBLManager rcl_existingDatabaseNamed:_databaseName]
        doNext:^(CBLDatabase *database) {
            XCTFail(@"database '%@' was apparently not deleted", _databaseName);
        }]
        doCompleted:^{
            XCTFail(@"database '%@' was apparently not deleted", _databaseName);
        }]
        catchTo:[RACSignal empty]];
    }] timeout:5.0 description:@"database deleted successfully"];
}

- (void)testDocumentWithID {
    NSString *ID = [[NSUUID UUID] UUIDString];
    [self rcl_expectNext:^(CBLDocument *document) {
        NSLog(@"Opened document %@", document);
    } signal:[[[CBLManager sharedInstance] databaseNamed:_databaseName error:NULL] rcl_documentWithID:ID]
    timeout:5.0 description:@"document created/opened successfully"];
    [self rcl_expectNext:^(CBLDocument *document) {
        NSLog(@"Opened document %@", document);
    } signal:[[CBLManager rcl_databaseNamed:_databaseName]
    flattenMap:^RACSignal *(CBLDatabase *database) {
        return [database rcl_documentWithID:ID];
    }]
    timeout:5.0 description:@"document created/opened successfully"];
}

- (void)testCreateDocument {
    [self rcl_expectNext:^(CBLDocument *document) {
        NSLog(@"Created document %@", document);
    } signal:[[[CBLManager sharedInstance] databaseNamed:_databaseName error:NULL] rcl_createDocument]
    timeout:5.0 description:@"document created/opened successfully"];
    [self rcl_expectNext:^(CBLDocument *document) {
        NSLog(@"Created document %@", document);
    } signal:[[CBLManager rcl_databaseNamed:_databaseName]
    flattenMap:^RACSignal *(CBLDatabase *database) {
        return [database rcl_createDocument];
    }]
    timeout:5.0 description:@"document created/opened successfully"];
}

- (void)testExistingDocumentWithID {
    NSString *ID = [[NSUUID UUID] UUIDString];
    [self rcl_expectCompletionFromSignal:[[[[[[[[CBLManager sharedInstance] databaseNamed:_databaseName error:NULL] documentWithID:ID] newRevision] rcl_save]
    ignoreValues]
    then:^RACSignal *{
        return [[[[CBLManager sharedInstance] databaseNamed:_databaseName error:NULL] existingDocumentWithID:ID] rcl_delete];
    }]
    then:^RACSignal *{
        return [[[[CBLManager sharedInstance] databaseNamed:_databaseName error:NULL] rcl_existingDocumentWithID:ID]
        catchTo:[RACSignal empty]];
    }]
    timeout:5.0 description:@"document created/opened/deleted successfully"];
    ID = [[NSUUID UUID] UUIDString];
    [self rcl_expectCompletionFromSignal:[[[[[[[[[[[CBLManager rcl_databaseNamed:_databaseName]
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
        return [[CBLManager rcl_databaseNamed:_databaseName]
        flattenMap:^RACSignal *(CBLDatabase *database) {
            return [database rcl_existingDocumentWithID:ID];
        }];
    }]
    flattenMap:^RACSignal *(CBLDocument *document) {
        return [document rcl_delete];
    }]
    then:^RACSignal *{
        return [[CBLManager rcl_databaseNamed:_databaseName]
        flattenMap:^RACSignal *(CBLDatabase *database) {
            return [database rcl_existingDocumentWithID:ID];
        }];
    }]
    catchTo:[RACSignal empty]]
    timeout:5.0 description:@"document created/opened/deleted successfully"];
}

- (void)testExistingLocalDocumentWithID {
    NSString *ID = [[NSUUID UUID] UUIDString];
    [self rcl_expectCompletionFromSignal:[[[[[[[[CBLManager sharedInstance] databaseNamed:_databaseName error:NULL] rcl_existingLocalDocumentWithID:ID]
    doNext:^(NSDictionary *localDocument){
        XCTFail(@"Should not have found a local document: %@ !", localDocument);
    }]
    doCompleted:^{
        XCTFail(@"Should not have completed!");
    }]
    catchTo:[RACSignal empty]]
    then:^RACSignal *{
        return [[[CBLManager sharedInstance] databaseNamed:_databaseName error:NULL] rcl_putLocalDocumentWithProperties:@{} ID:ID];
    }]
    then:^RACSignal *{
        return [[[[CBLManager sharedInstance] databaseNamed:_databaseName error:NULL] rcl_existingLocalDocumentWithID:ID]
        flattenMap:^RACSignal *(NSDictionary *localDocument) {
            return [RACSignal empty];
        }];
    }] timeout:5.0 description:@"local document created"];
    ID = [[NSUUID UUID] UUIDString];
    [self rcl_expectCompletionFromSignal:[[[[[[[CBLManager rcl_databaseNamed:_databaseName]
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
        return [[CBLManager rcl_databaseNamed:_databaseName]
        flattenMap:^RACSignal *(CBLDatabase *database) {
            return [database rcl_putLocalDocumentWithProperties:@{} ID:ID];
        }];
    }]
    then:^RACSignal *{
        return [[[CBLManager rcl_databaseNamed:_databaseName]
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
    } signal:[[CBLManager rcl_databaseNamed:_databaseName]
    flattenMap:^RACSignal *(CBLDatabase *database) {
        return [database rcl_existingLocalDocumentWithID:ID];
    }] timeout:5.0 description:@"local document not found"];
    [self rcl_expectCompletionFromSignal:[[[CBLManager rcl_databaseNamed:_databaseName]
    flattenMap:^RACSignal *(CBLDatabase *database) {
        return [database rcl_putLocalDocumentWithProperties:@{} ID:ID];
    }]
    then:^RACSignal *{
        return [[[CBLManager rcl_databaseNamed:_databaseName]
        flattenMap:^RACSignal *(CBLDatabase *database) {
            return [database rcl_deleteLocalDocumentWithID:ID];
        }]
        then:^RACSignal *{
            return [[[[CBLManager rcl_databaseNamed:_databaseName]
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
    } signal:[[CBLManager rcl_databaseNamed:_databaseName]
    flattenMap:^RACSignal *(CBLDatabase *database) {
        return [database rcl_allDocumentsQuery];
    }] timeout:5.0 description:@"all documents query created"];
}

- (void)testAllDocumentsQueryWithMode {
    [self rcl_expectNext:^(CBLQuery *query) {
        XCTAssertTrue([query isKindOfClass:[CBLQuery class]]);
        XCTAssertEqual(kCBLOnlyConflicts, query.allDocsMode);
    } signal:[[CBLManager rcl_databaseNamed:_databaseName]
    flattenMap:^RACSignal *(CBLDatabase *database) {
        return [database rcl_allDocumentsQueryWithMode:kCBLOnlyConflicts];
    }] timeout:5.0 description:@"all documents query created"];
}

- (void)testAllDocumentsQueryWithModeIndexUpdateMode {
    [self rcl_expectNext:^(CBLQuery *query) {
        XCTAssertTrue([query isKindOfClass:[CBLQuery class]]);
        XCTAssertEqual(kCBLOnlyConflicts, query.allDocsMode);
        XCTAssertEqual(kCBLUpdateIndexAfter, query.indexUpdateMode);
    } signal:[[CBLManager rcl_databaseNamed:_databaseName]
    flattenMap:^RACSignal *(CBLDatabase *database) {
        return [database rcl_allDocumentsQueryWithMode:kCBLOnlyConflicts indexUpdateMode:kCBLUpdateIndexAfter];
    }] timeout:5.0 description:@"all documents query created"];
}

- (void)testSlowQueryWithMap {
    NSString *ID = [[NSUUID UUID] UUIDString];
    [self rcl_expectCompletionFromSignal:[[[[[CBLManager rcl_databaseNamed:_databaseName]
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
        return [[[[[CBLManager rcl_databaseNamed:_databaseName]
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
    } signal:[[CBLManager rcl_databaseNamed:_databaseName]
    flattenMap:^RACSignal *(CBLDatabase *database) {
        return [database rcl_viewNamed:ID];
    }] timeout:5.0 description:@"view opened"];
}

- (void)testExistingViewNamed {
    NSString *ID = [[NSUUID UUID] UUIDString];
    [self rcl_expectCompletionFromSignal:[[[[[[[CBLManager rcl_databaseNamed:_databaseName]
    flattenMap:^RACSignal *(CBLDatabase *database) {
        return [database rcl_existingViewNamed:ID];
    }]
    catch:^RACSignal *(NSError *error) {
        return [[CBLManager rcl_databaseNamed:_databaseName]
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
        return [[CBLManager rcl_databaseNamed:_databaseName]
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
    [self rcl_expectCompletionFromSignal:[[CBLManager rcl_databaseNamed:_databaseName]
    flattenMap:^RACSignal *(CBLDatabase *database) {
        return [database rcl_setValidationNamed:ID asBlock:^(CBLRevision *newRevision, id<CBLValidationContext> context) {
        }];
    }] timeout:5.0 description:@"correctly sets validation block"];
}

- (void)testValidationNamed {
    NSString *ID = [[NSUUID UUID] UUIDString];
    [self rcl_expectNext:^(id block) {
        XCTAssertTrue([block isKindOfClass:[NSObject class]]);
    } signal:[[[[CBLManager rcl_databaseNamed:_databaseName]
    flattenMap:^RACSignal *(CBLDatabase *database) {
        return [database rcl_validationNamed:ID];
    }]
    catch:^RACSignal *(NSError *error) {
        return [[CBLManager rcl_databaseNamed:_databaseName]
        flattenMap:^RACSignal *(CBLDatabase *database) {
            return [database rcl_setValidationNamed:ID asBlock:^(CBLRevision *newRevision, id<CBLValidationContext> context) {
            }];
        }];
    }]
    then:^RACSignal *{
        return [[CBLManager rcl_databaseNamed:_databaseName]
        flattenMap:^RACSignal *(CBLDatabase *database) {
            return [database rcl_validationNamed:ID];
        }];
    }] timeout:5.0 description:@"correctly sets validation block"];
}

- (void)testSetFilterNamedAsBlock {
    NSString *ID = [[NSUUID UUID] UUIDString];
    [self rcl_expectCompletionFromSignal:[[CBLManager rcl_databaseNamed:_databaseName]
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
    } signal:[[[[CBLManager rcl_databaseNamed:_databaseName]
    flattenMap:^RACSignal *(CBLDatabase *database) {
        return [database rcl_filterNamed:ID];
    }]
    catch:^RACSignal *(NSError *error) {
        return [[CBLManager rcl_databaseNamed:_databaseName]
        flattenMap:^RACSignal *(CBLDatabase *database) {
            return [database rcl_setFilterNamed:ID asBlock:^BOOL(CBLSavedRevision *revision, NSDictionary *params) {
                return YES;
            }];
        }];
    }]
    then:^RACSignal *{
        return [[CBLManager rcl_databaseNamed:_databaseName]
        flattenMap:^RACSignal *(CBLDatabase *database) {
            return [database rcl_filterNamed:ID];
        }];
    }] timeout:5.0 description:@"correctly sets filter block"];
}

- (void)testInTransaction {
    __block BOOL completed = NO;
    [[[[CBLManager sharedInstance] databaseNamed:_databaseName error:NULL]
    rcl_inTransaction:^BOOL(CBLDatabase *database) {
        XCTAssertTrue(database.rcl_isOnScheduler);
        return YES;
    }]
    subscribeCompleted:^{
        NSLog(@"Wheeee!");
    }];
    [self rcl_expectCompletionFromSignal:[[CBLManager rcl_databaseNamed:_databaseName]
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
    [self rcl_expectCompletionFromSignal:[[[[[CBLManager rcl_databaseNamed:_databaseName]
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

- (CBLDatabase *)replicationTarget {
    NSError *error = nil;
    CBLDatabase *result = [[CBLManager sharedInstance] databaseNamed:[NSString stringWithFormat:@"replication_%@", _databaseName] error:&error];
    XCTAssertNotNil(result);
    return result;
}

- (RACSignal *)createPushReplicationWithDatabase:(CBLDatabase *)targetDatabase {
    return [[[CBLManager rcl_databaseNamed:_databaseName]
    flattenMap:^RACSignal *(CBLDatabase *database) {
        return [database rcl_createPushReplication:targetDatabase.internalURL];
    }]
    doNext:^(CBLReplication *replication) {
        [replication start];
    }];
}

- (RACSignal *)createPullReplicationWithDatabase:(CBLDatabase *)targetDatabase {
    return [[[CBLManager rcl_databaseNamed:_databaseName]
    flattenMap:^RACSignal *(CBLDatabase *database) {
        return [database rcl_createPullReplication:targetDatabase.internalURL];
    }]
    doNext:^(CBLReplication *replication) {
        [replication start];
    }];
}

- (void)testCreatePushReplicationWithURL {
    [self rcl_expectNext:^(CBLReplication *replication) {
        XCTAssertNotNil(replication);
        XCTAssertTrue(!replication.pull);
    } signal:[self createPushReplicationWithDatabase:[self replicationTarget]]
     timeout:5.0 description:@"replication created"];
}

- (void)testCreatePullReplicationWithURL {
    [self rcl_expectNext:^(CBLReplication *replication) {
        XCTAssertNotNil(replication);
        XCTAssertTrue(replication.pull);
    } signal:[self createPullReplicationWithDatabase:[self replicationTarget]]
     timeout:5.0 description:@"replication created"];
}

- (void)testDatabaseChangeNotifications {
    CBLDatabase *database = [[CBLManager sharedInstance] databaseNamed:_databaseName error:NULL];
    NSString *documentID = [[NSUUID UUID] UUIDString];
    CBLDocument *document = [database documentWithID:documentID];
    [self triviallyUpdateDocument:document times:2 interval:0.1];
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
    ] signal:[database rcl_databaseChangeNotifications] timeout:5.0 description:@"received database change notifications"];
}

- (void)testDeleteDocumentWithID {
    CBLDatabase *database = [[CBLManager sharedInstance] databaseNamed:_databaseName error:NULL];
    NSString *documentID = [[NSUUID UUID] UUIDString];
    [[database documentWithID:documentID] update:^BOOL(CBLUnsavedRevision *unsavedRevision) {
        unsavedRevision.properties[@"name"] = [[NSUUID UUID] UUIDString];
        return YES;
    } error:NULL];
    [self rcl_expectCompletionFromSignal:[database rcl_deleteDocumentWithID:documentID] timeout:5.0 description:@"document deleted"];
}

- (void)testDeletePreservingPropertiesDocumentWithID {
    CBLDatabase *database = [[CBLManager sharedInstance] databaseNamed:_databaseName error:NULL];
    NSString *documentID = [[NSUUID UUID] UUIDString];
    [[database documentWithID:documentID] update:^BOOL(CBLUnsavedRevision *unsavedRevision) {
        unsavedRevision.properties[@"name"] = [[NSUUID UUID] UUIDString];
        return YES;
    } error:NULL];
    [self rcl_expectCompletionFromSignal:[database rcl_deletePreservingPropertiesDocumentWithID:documentID] timeout:5.0 description:@"document deleted"];
}

- (void)testDeleteDocumentWithIDModifyingPropertiesWithBlock {
    CBLDatabase *database = [[CBLManager sharedInstance] databaseNamed:_databaseName error:NULL];
    NSString *documentID = [[NSUUID UUID] UUIDString];
    [[database documentWithID:documentID] update:^BOOL(CBLUnsavedRevision *unsavedRevision) {
        unsavedRevision.properties[@"name"] = [[NSUUID UUID] UUIDString];
        return YES;
    } error:NULL];
    [self rcl_expectCompletionFromSignal:[database rcl_deleteDocumentWithID:documentID modifyingPropertiesWithBlock:^(CBLUnsavedRevision *proposedRevision) {
        proposedRevision.properties[@"name"] = [[NSUUID UUID] UUIDString];
    }] timeout:5.0 description:@"document deleted"];
}

- (void)testOnDocumentWithIDPerformBlock {
    __block BOOL complete = NO;
    CBLDatabase *database = [[CBLManager sharedInstance] databaseNamed:_databaseName error:NULL];
    NSString *documentID = [[NSUUID UUID] UUIDString];
    NSString *UUID = [[NSUUID UUID] UUIDString];
    [[database documentWithID:documentID] update:^BOOL(CBLUnsavedRevision *unsavedRevision) {
        unsavedRevision.properties[@"name"] = UUID;
        return YES;
    } error:NULL];
    [self rcl_expectCompletionFromSignal:[database rcl_onDocumentWithID:documentID performBlock:^(CBLDocument *document) {
        XCTAssertTrue([document.properties[@"name"] isEqualToString:UUID]);
        complete = YES;
    }] timeout:5.0 description:@"document deleted"];
    XCTAssertTrue(complete);
}

- (void)testUpdateDocumentWithIDBlock {
    CBLDatabase *database = [[CBLManager sharedInstance] databaseNamed:_databaseName error:NULL];
    NSString *documentID = [[NSUUID UUID] UUIDString];
    NSString *UUID = [[NSUUID UUID] UUIDString];
    [[database documentWithID:documentID] update:^BOOL(CBLUnsavedRevision *unsavedRevision) {
        unsavedRevision.properties[@"name"] = UUID;
        return YES;
    } error:NULL];
    [self rcl_expectCompletionFromSignal:[[database rcl_updateDocumentWithID:documentID block:^BOOL(CBLUnsavedRevision *unsavedRevision) {
        unsavedRevision.properties[@"UUID"] = unsavedRevision.properties[@"name"];
        return YES;
    }]
    then:^RACSignal *{
        return [RACSignal empty];
    }] timeout:5.0 description:@"document deleted"];
    CBLDocument *document = [database documentWithID:documentID];
    XCTAssertTrue([document.properties[@"UUID"] isEqualToString:UUID]);
}

- (void)testUpdateLocalDocumentWithIDBlock {
    CBLDatabase *database = [[CBLManager sharedInstance] databaseNamed:_databaseName error:NULL];
    NSString *documentID = [[NSUUID UUID] UUIDString];
    NSString *UUID = [[NSUUID UUID] UUIDString];
    [database putLocalDocument:@{
        @"name" : UUID,
    } withID:documentID error:NULL];
    [self rcl_expectCompletionFromSignal:[[database rcl_updateLocalDocumentWithID:documentID block:^NSDictionary *(NSMutableDictionary *localDocument) {
        localDocument[@"UUID"] = localDocument[@"name"];
        return localDocument;
    }]
    then:^RACSignal *{
        return [RACSignal empty];
    }] timeout:5.0 description:@"document deleted"];
    NSDictionary *localDocument = [database existingLocalDocumentWithID:documentID];
    XCTAssertTrue([localDocument[@"UUID"] isEqualToString:UUID]);
}

- (void)testResolveConflictsWithBlock {
    CBLDatabase *database = [[CBLManager sharedInstance] databaseNamed:_databaseName error:NULL];
    CBLDatabase *peerDatabase = [[CBLManager sharedInstance] databaseNamed:_peerDatabaseName error:NULL];
    NSString *documentID = [[NSUUID UUID] UUIDString];
    XCTAssertTrue([[database documentWithID:documentID] update:^BOOL(CBLUnsavedRevision *unsavedRevision) {
        unsavedRevision.properties[@"name"] = [[NSUUID UUID] UUIDString];
        return YES;
    } error:NULL]);
    XCTAssertTrue([[peerDatabase documentWithID:documentID] update:^BOOL(CBLUnsavedRevision *unsavedRevision) {
        unsavedRevision.properties[@"name"] = [[NSUUID UUID] UUIDString];
        return YES;
    } error:NULL]);
    CBLReplication *replication = [database createPushReplication:peerDatabase.internalURL];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [replication start];
    });
    [self rcl_expectCompletionFromSignal:[[database rcl_resolveConflictsWithBlock:^NSDictionary *(NSArray *conflictingRevisions) {

        return @{};
    }]
    take:1] timeout:5.0 description:@"conflict resolved"];
}

@end

/**
// TODO:
- (RACSignal *)rcl_resolveConflictsWithBlock:(NSDictionary *(^)(NSArray *conflictingRevisions))block;
*/

