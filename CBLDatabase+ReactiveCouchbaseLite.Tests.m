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
#import <ReactiveCouchbaseLite/ReactiveCouchbaseLite.h>
#import <libkern/OSAtomic.h>

typedef void (^RCLObjectTesterBlock)(id);
typedef RCLObjectTesterBlock (^RCLObjectTesterGeneratorBlock)(id);

@interface CBLDatabase_ReactiveCouchbaseLiteTests : RCLTestCase

@end

@implementation CBLDatabase_ReactiveCouchbaseLiteTests

- (void)setUp {
	[super setUp];
    [self rcl_setupListener];
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

typedef void (^RCLDocumentCreatorType)(void);

- (void)testCreateDocuments {
    __block volatile int32_t count = 0;
    NSUInteger limit = 1000;
    NSUInteger multiplier = 5;
    XCTestExpectation *expectation = [self expectationWithDescription:@"documents added"];
    RCLDocumentCreatorType (^RCLDocumentCreatorGenerator)(NSString *) = ^(NSString *queueIdentifier) {
        return ^{
            [[self.testDatabase rcl_createDocument]
                subscribeNext:^(NSDictionary *document) {
                    NSUInteger thisItem = OSAtomicAdd32(1, &count);
                    NSLog(@"[%@] Document (%@): %@", queueIdentifier, @(thisItem), document);
                    if (thisItem == (multiplier * limit)) {
                        [expectation fulfill];
                    }
                } error:^(NSError *error) {
                    XCTFail(@"Error: %@", error);
                }];
        };
    };
    for (int i = 0; i < limit; i++) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), RCLDocumentCreatorGenerator(@"Background"));
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), RCLDocumentCreatorGenerator(@"   Low    "));
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), RCLDocumentCreatorGenerator(@"  Default "));
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), RCLDocumentCreatorGenerator(@"   High   "));
        dispatch_async(dispatch_get_main_queue(), RCLDocumentCreatorGenerator(@"   Main   "));
    }
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}

- (void)testExistingDocumentWithID {
    NSString *ID = [[NSUUID UUID] UUIDString];
    NSError *error = nil;
    [[self.testDatabase documentWithID:ID] update:^BOOL(CBLUnsavedRevision *unsavedRevision) {
        unsavedRevision[[[NSUUID UUID] UUIDString]] = [[NSUUID UUID] UUIDString];
        return YES;
    } error:&error];
    [self rcl_expectCompletionFromSignal:[[[self.testDatabase existingDocumentWithID:ID] rcl_delete]
    then:^RACSignal *{
        return [[self.testDatabase rcl_existingDocumentWithID:ID]
        catchTo:[RACSignal empty]];
    }]
    timeout:5.0 description:@"document created/opened/deleted successfully"];
    
    ID = [[NSUUID UUID] UUIDString];
    [self rcl_expectCompletionFromSignal:[[[[[[RACSignal empty]
    then:^RACSignal *{
        return [RACSignal empty];
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

- (void)testExistingDocumentWithIDDefaultProperties {
    NSString *ID = [[NSUUID UUID] UUIDString];
    [self rcl_expectCompletionFromSignal:[[[[[CBLManager rcl_databaseNamed:self.testName]
    flattenMap:^RACSignal *(CBLDatabase *database) {
        return [database rcl_existingDocumentWithID:ID defaultProperties:@{
            @"UUID" : ID,
        }];
    }]
    flattenMap:^RACSignal *(CBLDocument *document) {
        XCTAssertTrue([document.properties[@"UUID"] isEqualToString:ID]);
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
        }]
        timeout:5.0 description:@"local document created"];
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
        }]
        timeout:5.0 description:@"local document created"];
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
    [self rcl_expectCompletionFromSignal:[[[[CBLManager rcl_databaseNamed:self.testName]
    flattenMap:^RACSignal *(CBLDatabase *database) {
        return [database rcl_documentWithID:ID];
    }]
    flattenMap:^RACSignal *(CBLDocument *document) {
        [[document newRevision] save:NULL];
        return [RACSignal empty];
    }]
    then:^RACSignal *{
        return [[[[CBLManager rcl_databaseNamed:self.testName]
        flattenMap:^RACSignal *(CBLDatabase *database) {
            return [database rcl_slowQueryWithMap:^(NSDictionary *document, CBLMapEmitBlock emit) {
                emit(document[@"_id"], document);
            }];
        }]
        flattenMap:^RACSignal *(CBLQuery *query) {
            return [query rcl_run];
        }]
        flattenMap:^RACSignal *(CBLQueryEnumerator *enumerator) {
            XCTAssertEqualObjects([[enumerator nextRow] documentID], ID);
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
    [self rcl_triviallyUpdateDocument:document times:3 interval:0.1];
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
    ] signal:[[self.testDatabase rcl_databaseChangeNotifications] take:3] timeout:5.0 description:@"received database change notifications"];
}

- (void)testDeleteDocumentWithID {
    NSString *documentID = [[NSUUID UUID] UUIDString];
    [[self.testDatabase documentWithID:documentID] update:^BOOL(CBLUnsavedRevision *unsavedRevision) {
        unsavedRevision.properties[@"name"] = [[NSUUID UUID] UUIDString];
        return YES;
    } error:NULL];
    [self rcl_expectCompletionFromSignal:[[self.testDatabase rcl_deleteDocumentWithID:documentID] ignoreValues] timeout:5.0 description:@"document deleted"];
}

- (void)testDeletePreservingPropertiesDocumentWithID {
    NSString *documentID = [[NSUUID UUID] UUIDString];
    [[self.testDatabase documentWithID:documentID] update:^BOOL(CBLUnsavedRevision *unsavedRevision) {
        unsavedRevision.properties[@"name"] = [[NSUUID UUID] UUIDString];
        return YES;
    } error:NULL];
    [self rcl_expectCompletionFromSignal:[[self.testDatabase rcl_deletePreservingPropertiesDocumentWithID:documentID] ignoreValues] timeout:5.0 description:@"document deleted"];
}

- (void)testDeleteDocumentWithIDModifyingPropertiesWithBlock {
    NSString *documentID = [[NSUUID UUID] UUIDString];
    [[self.testDatabase documentWithID:documentID] update:^BOOL(CBLUnsavedRevision *unsavedRevision) {
        unsavedRevision.properties[@"name"] = [[NSUUID UUID] UUIDString];
        return YES;
    } error:NULL];
    [self rcl_expectCompletionFromSignal:[[self.testDatabase rcl_deleteDocumentWithID:documentID modifyingPropertiesWithBlock:^(CBLUnsavedRevision *proposedRevision) {
        proposedRevision.properties[@"name"] = [[NSUUID UUID] UUIDString];
    }] ignoreValues] timeout:5.0 description:@"document deleted"];
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

- (void)testMultipleSimultaneousReplications {
    self.pushReplication = [self.testDatabase createPushReplication:self.peerURL];
    self.pullReplication = [self.testDatabase createPullReplication:self.peerURL];
    self.pushReplication.continuous = YES;
    self.pullReplication.continuous = YES;
    [self.pushReplication start];
    [self.pullReplication start];
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
    [self.testDatabase setFilterNamed:@"MyFilterName" asBlock:^BOOL(CBLSavedRevision* revision, NSDictionary* params) {
        return YES;
    }];
    [self.testDatabase setFilterNamed:@"MyFilterName2" asBlock:^BOOL(CBLSavedRevision* revision, NSDictionary* params) {
        return YES;
    }];
    CBLReplication *pushReplicationDuplicate = [self.testDatabase createPushReplication:self.peerURL];
    CBLReplication *pullReplicationDuplicate = [self.testDatabase createPullReplication:self.peerURL];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.pushReplication.continuous = self.pullReplication.continuous = YES;
        [[[RACObserve(self.pushReplication, status)
            setNameWithFormat:@"pushReplication"]
            logAll]
            subscribeCompleted:^{ }];
        [[[RACObserve(self.pullReplication, status)
            setNameWithFormat:@"pullReplication"]
            logAll]
            subscribeCompleted:^{ }];
        self.pushReplication.filter = @"MyFilterName";
        self.pushReplication.filterParams = @{
            @"A" : @"B"
        };
        self.pullReplication.filter = @"MyFilterName";
        self.pullReplication.filterParams = @{
            @"A" : @"B"
        };
        [self.pushReplication start];
        [self.pullReplication start];
        [[[RACObserve(pushReplicationDuplicate, status)
            setNameWithFormat:@"pushReplicationDuplicate"]
            logAll]
            subscribeCompleted:^{ }];
        [[[RACObserve(pullReplicationDuplicate, status)
            setNameWithFormat:@"pullReplicationDuplicate"]
            logAll]
            subscribeCompleted:^{ }];
        pushReplicationDuplicate.filter = @"MyFilterName2";
        pushReplicationDuplicate.filterParams = @{
            @"A" : @"C"
        };
        pullReplicationDuplicate.filter = @"MyFilterName2";
        pullReplicationDuplicate.filterParams = @{
            @"A" : @"C"
        };
        [pushReplicationDuplicate start];
        [pullReplicationDuplicate start];
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
        //[self.pushReplication stop];
        //[self.pullReplication stop];
        [disposable dispose];
    }];
    //[pushReplicationDuplicate stop];
    //[pullReplicationDuplicate stop];
}

- (void)testMultipleSimultaneousReplications2 {
    // self.testDatabase is an open, valid database.
    // self.peerURL is the URL of a listener with an appended database name (so: valid for replication).
    CBLReplication *pushReplication1 = [self.testDatabase createPushReplication:self.peerURL];
    pushReplication1.continuous = YES;
    CBLReplication *pullReplication1 = [self.testDatabase createPullReplication:self.peerURL];
    pullReplication1.continuous = YES;
    CBLReplication *pushReplication2 = [self.testDatabase createPushReplication:self.peerURL];
    pushReplication2.continuous = YES;
    CBLReplication *pullReplication2 = [self.testDatabase createPullReplication:self.peerURL];
    pullReplication2.continuous = YES;
    
    NSString *propertyKey1 = @"propertyKey1";
    NSString *paramsCondition1 = @"paramsCondition1";
    NSString *UUID1 = @"UUID1";
    NSString *UUID2 = @"UUID2";
    
    // Add a filter to the database.
    [self.testDatabase setFilterNamed:@"MyFilterName" asBlock:^BOOL(CBLSavedRevision* revision, NSDictionary* params) {
        NSDictionary *properties = revision.properties;
        BOOL result = [params[paramsCondition1] isEqualToString:properties[propertyKey1]];
        NSLog(@"Test filter (%@ == %@) %@ properties: %@", params[paramsCondition1], properties[propertyKey1], result ? @"accepted" : @"rejected", properties);
        return result;
    }];
    [self.peerDatabase setFilterNamed:@"MyFilterName" asBlock:^BOOL(CBLSavedRevision* revision, NSDictionary* params) {
        NSDictionary *properties = revision.properties;
        BOOL result = [params[paramsCondition1] isEqualToString:properties[propertyKey1]];
        NSLog(@"Peer filter (%@ == %@) %@ properties: %@", params[paramsCondition1], properties[propertyKey1], result ? @"accepted" : @"rejected", properties);
        return result;
    }];
    
    // Enable filters on the replications.
    pushReplication1.filter = @"MyFilterName";
    pushReplication1.filterParams = @{
        paramsCondition1 : UUID1,
    };
    
    pullReplication1.filter = @"MyFilterName";
    pullReplication1.filterParams =  @{
        paramsCondition1 : UUID1,
    };

    pushReplication2.filter = @"MyFilterName";
    pushReplication2.filterParams =  @{
        paramsCondition1 : UUID2,
    };

    pullReplication2.filter = @"MyFilterName";
    pullReplication2.filterParams =  @{
        paramsCondition1 : UUID2,
    };
    
    // Let's create some random documents.
    for (int i = 0; i < 50; i++) {
        [[self.testDatabase documentWithID:[[NSUUID UUID] UUIDString]] update:^BOOL(CBLUnsavedRevision *unsavedRevision) {
            unsavedRevision.properties[@"name"] = [[NSUUID UUID] UUIDString];
            unsavedRevision.properties[[[NSUUID UUID] UUIDString]] = [[NSUUID UUID] UUIDString];
            if (i % 2 == 0) {
                unsavedRevision.properties[propertyKey1] = UUID1;
            } else if (i % 2 == 1) {
                unsavedRevision.properties[propertyKey1] = UUID2;
            }
            return YES;
        } error:NULL];
    }
    
    // Let's log the statuses of the replications as they change.
    [[[RACObserve(pushReplication1, status)
        setNameWithFormat:@"pushReplication1"]
        logAll]
        subscribeCompleted:^{ }];
    [[[RACObserve(pullReplication1, status)
        setNameWithFormat:@"pullReplication1"]
        logAll]
        subscribeCompleted:^{ }];
    [[[RACObserve(pushReplication2, status)
        setNameWithFormat:@"pushReplication2"]
        logAll]
        subscribeCompleted:^{ }];
    [[[RACObserve(pullReplication2, status)
        setNameWithFormat:@"pullReplication2"]
        logAll]
        subscribeCompleted:^{ }];
    
    // Start some replications now.
    [pushReplication1 start];
    [pullReplication1 start];

    // Simulate a delayed start for a couple of other replications.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [pushReplication2 start];
        [pushReplication2 start];
    });
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Just wait for a while"];
    [self waitForExpectationsWithTimeout:500 handler:nil];
    [expectation fulfill];
}

- (void)testSomeOtherStuff {
    NSArray *array = @[@"A", @"B", @"C"];
    RACSequence *sequence = array.rac_sequence;
    RACSignal *signal = sequence.signal;
    [signal logAll];
}

@end
