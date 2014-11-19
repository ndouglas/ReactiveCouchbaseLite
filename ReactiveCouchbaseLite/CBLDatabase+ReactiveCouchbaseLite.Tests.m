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
    CBLDatabase *_database;
}

@end

@implementation CBLDatabase_ReactiveCouchbaseLiteTests

- (void)setUp {
	[super setUp];
    _manager = [CBLManager sharedInstance];
    NSError *error = nil;
    [self cleanupPreviousDatabaseInManager:_manager];
    _database = [_manager databaseNamed:@"rcl_test" error:&error];
    if (!_database) {
        XCTFail(@"Error creating database 'rcl_test': %@", error);
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

/**
- (void)expectCompletionFromSignal:(RACSignal *)signal timeout:(NSTimeInterval)timeout description:(NSString *)description {
    XCTestExpectation *expectation = [self expectationWithDescription:description];
    [self expectation:expectation signal:signal subscribeCompletion:^{
        [expectation fulfill];
    } timeout:timeout];
}

- (void)expectNext:(void (^)(id next))nextHandler signal:(RACSignal *)signal timeout:(NSTimeInterval)timeout description:(NSString *)description {
    XCTestExpectation *expectation = [self expectationWithDescription:description];
    [self expectation:expectation signal:signal subscribeNext:^(id next) {
        nextHandler(next);
        [expectation fulfill];
    } timeout:timeout];
}

- (void)expectError:(void (^)(NSError *error))errorHandler signal:(RACSignal *)signal timeout:(NSTimeInterval)timeout description:(NSString *)description {
    XCTestExpectation *expectation = [self expectationWithDescription:description];
    [self expectation:expectation signal:signal subscribeError:^(NSError *error) {
        errorHandler(error);
        [expectation fulfill];
    } timeout:timeout];
}
*/

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

@end

/**
- (RACSignal *)rcl_close;
- (RACSignal *)rcl_compact;
- (RACSignal *)rcl_delete;
- (RACSignal *)rcl_documentWithID:(NSString *)documentID;
- (RACSignal *)rcl_existingDocumentWithID:(NSString *)documentID;
- (RACSignal *)rcl_createDocument;
- (RACSignal *)rcl_existingLocalDocumentWithID:(NSString *)documentID;
- (RACSignal *)rcl_putLocalDocumentWithProperties:(NSDictionary *)properties ID:(NSString *)documentID;
- (RACSignal *)rcl_deleteLocalDocumentWithID:(NSString *)documentID;
- (RACSignal *)rcl_allDocumentsQuery;
- (RACSignal *)rcl_allDocumentsQueryWithMode:(CBLAllDocsMode)mode;
- (RACSignal *)rcl_allDocumentsQueryWithMode:(CBLAllDocsMode)mode updateMode:(CBLIndexUpdateMode)updateMode;
*/

