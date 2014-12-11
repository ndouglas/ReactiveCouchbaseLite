//
//  CBLQueryEnumerator+ReactiveCouchbaseLite.Tests.m
//  ReactiveCouchbaseLite
//
//  Created by Nathan Douglas on 12/4/14.
//  Released into the public domain.
//  See LICENSE for details.
//

#import <XCTest/XCTest.h>
#import "RCLTestDefinitions.h"
#import "RCLDefinitions.h"

@interface CBLQueryEnumerator_ReactiveCouchbaseLiteTests : XCTestCase {
    CBLManager *_manager;
    NSString *_databaseName;
    CBLDatabase *_database;
    CBLQueryEnumerator *_enumerator;
}

@end

@implementation CBLQueryEnumerator_ReactiveCouchbaseLiteTests

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

- (RACSignal *)createDocumentWithID:(NSString *)_ID properties:(NSDictionary *)_properties {
    return [[[[_database rcl_documentWithID:_ID]
    flattenMap:^RACSignal *(CBLDocument *document) {
        return [document rcl_newRevision];
    }]
    flattenMap:^RACSignal *(CBLUnsavedRevision *unsavedRevision) {
        [unsavedRevision.properties addEntriesFromDictionary:_properties];
        return [unsavedRevision rcl_save];
    }]
    flattenMap:^RACSignal *(CBLSavedRevision *savedRevision) {
        return [RACSignal empty];
    }];
}

- (RACSignal *)createRandomDocumentWithID:(NSString *)_ID {
    return [self createDocumentWithID:_ID properties:@{
        [[NSUUID UUID] UUIDString] : [[NSUUID UUID] UUIDString],
        [[NSUUID UUID] UUIDString] : [[NSUUID UUID] UUIDString],
        [[NSUUID UUID] UUIDString] : [[NSUUID UUID] UUIDString],
        [[NSUUID UUID] UUIDString] : [[NSUUID UUID] UUIDString],
        [[NSUUID UUID] UUIDString] : [[NSUUID UUID] UUIDString],
        [[NSUUID UUID] UUIDString] : [[NSUUID UUID] UUIDString],
        [[NSUUID UUID] UUIDString] : [[NSUUID UUID] UUIDString],
        [[NSUUID UUID] UUIDString] : [[NSUUID UUID] UUIDString],
        [[NSUUID UUID] UUIDString] : [[NSUUID UUID] UUIDString],
        [[NSUUID UUID] UUIDString] : [[NSUUID UUID] UUIDString],
        [[NSUUID UUID] UUIDString] : [[NSUUID UUID] UUIDString],
        [[NSUUID UUID] UUIDString] : [[NSUUID UUID] UUIDString],
        [[NSUUID UUID] UUIDString] : [[NSUUID UUID] UUIDString],
        [[NSUUID UUID] UUIDString] : [[NSUUID UUID] UUIDString],
        [[NSUUID UUID] UUIDString] : [[NSUUID UUID] UUIDString],
        [[NSUUID UUID] UUIDString] : [[NSUUID UUID] UUIDString],
        [[NSUUID UUID] UUIDString] : [[NSUUID UUID] UUIDString],
        [[NSUUID UUID] UUIDString] : [[NSUUID UUID] UUIDString],
    }];
}

- (void)testNextRow {
	NSString *ID = [[NSUUID UUID] UUIDString];
    [self rcl_expectCompletionFromSignal:[[self createRandomDocumentWithID:ID]
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
    timeout:5.0 description:@"nextRow is equivalent to created document"];
}

@end
