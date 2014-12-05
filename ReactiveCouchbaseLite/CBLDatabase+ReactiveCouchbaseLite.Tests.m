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
    CBLDatabase *_database;
}

@end

@implementation CBLDatabase_ReactiveCouchbaseLiteTests

- (void)setUp {
	[super setUp];
    _manager = [CBLManager sharedInstance];
    NSError *error = nil;
    [self cleanupPreviousDatabaseInManager:_manager];
    _databaseName = [NSString stringWithFormat:@"test_%@", @([[[NSUUID UUID] UUIDString] hash])];
    _database = [_manager databaseNamed:_databaseName error:&error];
    if (!_database) {
        XCTFail(@"Error creating database '%@': %@", _databaseName, error);
    }
}

- (void)tearDown {
    NSError *error = nil;
    if (![_database deleteDatabase:&error]) {
        XCTFail(@"Error deleting database: %@", _database.name);
    }
	[super tearDown];
}

- (void)cleanupPreviousDatabaseInManager:(CBLManager *)aManager {
    NSError *error = nil;
    CBLDatabase *previousDatabase = [aManager existingDatabaseNamed:@"rcl_test" error:&error];
    if (previousDatabase) {
        if (![previousDatabase deleteDatabase:&error]) {
            XCTFail(@"Error deleting previous database: %@", _database.name);
        }
    }
}

- (void)testLastSequenceNumber {

    NSError *error = nil;
    RACSignal *signal = [_database rcl_lastSequenceNumber];
    RCLObjectTesterGeneratorBlock generator = ^(id testValue) {
        return ^(id inValue) {
            XCTAssertTrue((!inValue && !testValue) || [inValue isEqual:testValue], @"inValue %@ is not equal to testValue %@", inValue, testValue);
        };
    };
    [self expectNext:generator(@0) signal:signal timeout:5.0 description:@"last sequence number matches"];
    
    CBLDocument *document = [_database createDocument];
    XCTAssertTrue([document update:^BOOL(CBLUnsavedRevision *newRevision) {
        newRevision[@"name"] = [[NSUUID UUID] UUIDString];
        return YES;
    } error:&error], @"%@", error);
    [self expectNext:generator(@1) signal:signal timeout:5.0 description:@"last sequence number matches"];
    
    XCTAssertTrue([document update:^BOOL(CBLUnsavedRevision *newRevision) {
        newRevision[@"name"] = [[NSUUID UUID] UUIDString];
        return YES;
    } error:&error], @"%@", error);
    [self expectNext:generator(@2) signal:signal timeout:5.0 description:@"last sequence number matches"];
    
    NSLog(@"%@", _database);
}

- (void)testClose {
    [self expectCompletionFromSignal:[_database rcl_close] timeout:5.0 description:@"database closed successfully"];
}

- (void)testCompact {
    [self expectCompletionFromSignal:[_database rcl_compact] timeout:5.0 description:@"database compacted successfully"];
}

- (void)testDelete {
    [self expectCompletionFromSignal:[[_database rcl_delete]
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
    [self expectNext:^(CBLDocument *document) {
        NSLog(@"Opened document %@", document);
    } signal:[_database rcl_documentWithID:ID] timeout:5.0 description:@"document created/opened successfully"];
}

- (void)testCreateDocument {
    [self expectNext:^(CBLDocument *document) {
        NSLog(@"Created document %@", document);
    } signal:[_database rcl_createDocument] timeout:5.0 description:@"document created/opened successfully"];
}

- (void)testExistingDocumentWithID {
    NSString *ID = [[NSUUID UUID] UUIDString];
    [self expectCompletionFromSignal:[[[[[[[_database rcl_documentWithID:ID]
    flattenMap:^RACSignal *(CBLDocument *document) {
        return [document rcl_newRevision];
    }]
    flattenMap:^RACSignal *(CBLUnsavedRevision *unsavedRevision) {
        return [unsavedRevision rcl_save];
    }]
    ignoreValues]
    then:^RACSignal *{
        return [_database rcl_existingDocumentWithID:ID];
    }]
    flattenMap:^RACSignal *(CBLDocument *document) {
        return [document rcl_delete];
    }]
    then:^RACSignal *{
        return [[[_database rcl_existingDocumentWithID:ID]
        doNext:^(CBLDocument *document) {
            XCTFail(@"document '%@' apparently not deleted.", ID);
        }]
        catchTo:[RACSignal empty]];
    }]
    timeout:5.0 description:@"document created/opened successfully"];
}

- (void)testExistingLocalDocumentWithID {
    NSString *ID = [[NSUUID UUID] UUIDString];
    [self expectError:^(NSError *error) {
        NSLog(@"Received error: %@", error);
    } signal:[_database rcl_existingLocalDocumentWithID:ID] timeout:5.0 description:@"local document not found"];
    [self expectCompletionFromSignal:[_database rcl_putLocalDocumentWithProperties:@{} ID:ID] timeout:5.0 description:@"local document created"];
}

- (void)testDeleteLocalDocumentWithID {
    NSString *ID = [[NSUUID UUID] UUIDString];
    [self expectError:^(NSError *error) {
        NSLog(@"Received error: %@", error);
    } signal:[_database rcl_existingLocalDocumentWithID:ID] timeout:5.0 description:@"local document not found"];
    [self expectCompletionFromSignal:[[_database rcl_putLocalDocumentWithProperties:@{} ID:ID]
    then:^RACSignal *{
        return [[_database rcl_deleteLocalDocumentWithID:ID]
        then:^RACSignal *{
            return [[[_database rcl_existingLocalDocumentWithID:ID]
            doCompleted:^{
                XCTFail(@"Local document '%@' was apparently not deleted", ID);
            }]
            catchTo:[RACSignal empty]];
        }];
    }] timeout:5.0 description:@"local document created"];
}

- (void)testAllDocumentsQuery {
    [self expectNext:^(CBLQuery *query) {
        XCTAssertTrue([query isKindOfClass:[CBLQuery class]]);
    } signal:[_database rcl_allDocumentsQuery] timeout:5.0 description:@"all documents query created"];
}

- (void)testAllDocumentsQueryWithMode {
    [self expectNext:^(CBLQuery *query) {
        XCTAssertTrue([query isKindOfClass:[CBLQuery class]]);
        XCTAssertEqual(kCBLOnlyConflicts, query.allDocsMode);
    } signal:[_database rcl_allDocumentsQueryWithMode:kCBLOnlyConflicts] timeout:5.0 description:@"all documents query created"];
}

- (void)testAllDocumentsQueryWithModeIndexUpdateMode {
    [self expectNext:^(CBLQuery *query) {
        XCTAssertTrue([query isKindOfClass:[CBLQuery class]]);
        XCTAssertEqual(kCBLOnlyConflicts, query.allDocsMode);
        XCTAssertEqual(kCBLUpdateIndexAfter, query.indexUpdateMode);
    } signal:[_database rcl_allDocumentsQueryWithMode:kCBLOnlyConflicts indexUpdateMode:kCBLUpdateIndexAfter] timeout:5.0 description:@"all documents query created"];
}

- (void)testSlowQueryWithMap {
    NSString *ID = [[NSUUID UUID] UUIDString];
    [self expectCompletionFromSignal:[[[[_database rcl_documentWithID:ID]
    flattenMap:^RACSignal *(CBLDocument *document) {
        return [document rcl_newRevision];
    }]
    flattenMap:^RACSignal *(CBLUnsavedRevision *unsavedRevision) {
        return [unsavedRevision rcl_save];
    }]
    then:^RACSignal *{
        return [[[[_database rcl_slowQueryWithMap:^(NSDictionary *document, CBLMapEmitBlock emit) {
            emit(document[@"_id"], document);
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

@end

/**
- (RACSignal *)rcl_viewNamed:(NSString *)name;
- (RACSignal *)rcl_existingViewNamed:(NSString *)name;
- (RACSignal *)rcl_setValidationNamed:(NSString *)name asBlock:(CBLValidationBlock)block;
- (RACSignal *)rcl_validationNamed:(NSString *)name;
- (RACSignal *)rcl_setFilterNamed:(NSString *)name asBlock:(CBLFilterBlock)block;
- (RACSignal *)rcl_filterNamed:(NSString *)name;
- (RACSignal *)rcl_inTransaction:(BOOL (^)(void))block;
- (RACSignal *)rcl_doAsync:(void (^)(void))block;
- (RACSignal *)rcl_doSync:(void (^)(void))block;
- (RACSignal *)rcl_allReplications;
- (RACSignal *)rcl_createPushReplication:(NSURL *)URL;
- (RACSignal *)rcl_createPullReplication:(NSURL *)URL;
- (RACSignal *)rcl_databaseChangeNotifications;
*/

