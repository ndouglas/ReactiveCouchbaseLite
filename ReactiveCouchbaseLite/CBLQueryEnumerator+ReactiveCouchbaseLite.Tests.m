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
    [self expectCompletionFromSignal:[[self createRandomDocumentWithID:ID]
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

- (void)testSequence {
	NSString *ID = [[NSUUID UUID] UUIDString];
    [self expectCompletionFromSignal:[[[[[[self createRandomDocumentWithID:ID]
    then:^RACSignal *{
        return [self createRandomDocumentWithID:ID];
    }]
    then:^RACSignal *{
        return [self createRandomDocumentWithID:ID];
    }]
    then:^RACSignal *{
        return [self createRandomDocumentWithID:ID];
    }]
    then:^RACSignal *{
        return [self createRandomDocumentWithID:ID];
    }]
    then:^RACSignal *{
        return [[[_database rcl_slowQueryWithMap:^(NSDictionary *document, CBLMapEmitBlock emit) {
            emit(document[@"_id"], document);
        }]
        flattenMap:^RACSignal *(CBLQuery *query) {
            return [query rcl_run];
        }]
        flattenMap:^RACSignal *(CBLQueryEnumerator *enumerator) {
            CBLQueryEnumerator *enumerator2 = enumerator.copy;
            CBLQueryEnumerator *enumerator3 = enumerator.copy;
            RACSequence *sequence = enumerator.rcl_sequence;
            RACSequence *sequence2 = enumerator2.rcl_sequence;
            [enumerator3 nextRow];
            RACSequence *sequence3 = enumerator3.rcl_sequence;
            [enumerator3 nextRow];
            RACSequence *sequence4 = enumerator3.rcl_sequence;
            XCTAssertEqualObjects(sequence.head, sequence2.head);
            XCTAssertEqualObjects(sequence.head, sequence3.head);
            XCTAssertEqualObjects(sequence.head, sequence4.head);
            RACSequence *sequence5 = sequence.tail;
            RACSequence *sequence6 = sequence2.tail;
            RACSequence *sequence7 = sequence3.tail;
            RACSequence *sequence8 = sequence7.tail;
            RACSequence *sequence9 = sequence8.tail;
            XCTAssertEqualObjects(sequence5.head, sequence6.head);
            XCTAssertEqualObjects(sequence5.head, sequence7.head);
            XCTAssertEqualObjects(sequence5.tail.head, sequence8.head);
            XCTAssertEqualObjects(sequence5.tail.tail.head, sequence9.head);
            return [RACSignal empty];
        }];
    }]
    timeout:5.0 description:@"nextRow is equivalent to created document"];
}

@end
