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
    RACScheduler *_failScheduler;
}

@end

@implementation CBLDatabase_ReactiveCouchbaseLiteTests

- (void)setUp {
	[super setUp];
    _manager = [CBLManager sharedInstance];
    _databaseName = [NSString stringWithFormat:@"test_%@", @([[[NSUUID UUID] UUIDString] hash])];
    _failScheduler = [[RACQueueScheduler alloc] initWithName:@"FailQueue" queue:dispatch_queue_create("FailQueue", DISPATCH_QUEUE_SERIAL)];
}

- (void)tearDown {
	[super tearDown];
}

- (void)testLastSequenceNumber {
    NSError *error = nil;
    RACSignal *signal = [[CBLManager rcl_databaseNamed:_databaseName]
    flattenMap:^RACSignal *(CBLDatabase *database) {
        return [database rcl_lastSequenceNumber];
    }];
    RCLObjectTesterGeneratorBlock generator = ^(id testValue) {
        return ^(id inValue) {
            XCTAssertTrue((!inValue && !testValue) || [inValue isEqual:testValue], @"inValue %@ is not equal to testValue %@", inValue, testValue);
        };
    };
    [self rcl_expectNext:generator(@0) signal:signal timeout:5.0 description:@"last sequence number matches"];
    
    CBLDocument *document = [[_manager databaseNamed:_databaseName error:&error] createDocument];
    XCTAssertTrue([document update:^BOOL(CBLUnsavedRevision *newRevision) {
        newRevision[@"name"] = [[NSUUID UUID] UUIDString];
        return YES;
    } error:&error], @"%@", error);
    [self rcl_expectNext:generator(@1) signal:signal timeout:5.0 description:@"last sequence number matches"];
    
    XCTAssertTrue([document update:^BOOL(CBLUnsavedRevision *newRevision) {
        newRevision[@"name"] = [[NSUUID UUID] UUIDString];
        return YES;
    } error:&error], @"%@", error);
    [self rcl_expectNext:generator(@2) signal:signal timeout:5.0 description:@"last sequence number matches"];
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

@end

/**
- (RACSignal *)rcl_allReplications;
- (RACSignal *)rcl_createPushReplication:(NSURL *)URL;
- (RACSignal *)rcl_createPullReplication:(NSURL *)URL;
- (RACSignal *)rcl_databaseChangeNotifications;
- (RACSignal *)rcl_deleteDocumentWithID:(NSString *)documentID;
- (RACSignal *)rcl_deletePreservingPropertiesDocumentWithID:(NSString *)documentID;
- (RACSignal *)rcl_deleteDocumentWithID:(NSString *)documentID modifyingPropertiesWithBlock:(void(^)(CBLUnsavedRevision *proposedRevision))block;
- (RACSignal *)rcl_onDocumentWithID:(NSString *)documentID performBlock:(void (^)(CBLDocument *document))block;
- (RACSignal *)rcl_updateDocumentWithID:(NSString *)documentID block:(BOOL(^)(CBLUnsavedRevision *unsavedRevision))block;
- (RACSignal *)rcl_updateLocalDocumentWithID:(NSString *)documentID block:(NSDictionary *(^)(NSMutableDictionary *localDocument))block;
- (RACSignal *)rcl_resolveConflictsWithBlock:(NSDictionary *(^)(NSArray *conflictingRevisions))block;
*/

