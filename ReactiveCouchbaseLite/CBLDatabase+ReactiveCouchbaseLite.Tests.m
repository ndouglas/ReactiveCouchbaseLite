//
//  CBLDatabase+ReactiveCouchbaseLite.Tests.m
//  ReactiveCouchbaseLite
//
//  Created by Nathan Douglas on 11/18/14.
//  Released into the public domain.
//  See LICENSE for details.
//

#import <XCTest/XCTest.h>
#import "CBLDatabase+ReactiveCouchbaseLite.h"

typedef BOOL (^RCLObjectTesterBlock)(id);
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

- (BOOL)expect:(BOOL (^)(id value))block fromSignal:(RACSignal *)signal timeout:(NSTimeInterval)timeout description:(NSString *)description {
    __block BOOL result = NO;
    XCTestExpectation *expectation = [self expectationWithDescription:description];
    RACDisposable *disposable = [[signal
    take:1]
    subscribeNext:^(id inValue) {
        result = block(inValue);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:timeout handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Expectation '%@' failed with error: %@", description, error);
        }
        [disposable dispose];
    }];
    return result;
}

- (void)testLastSequenceNumber {
    NSError *error = nil;
    RACSignal *signal = [_database rcl_lastSequenceNumber];
    RCLObjectTesterGeneratorBlock generator = ^(id testValue) {
        return ^BOOL(id inValue) {
            return (!inValue && !testValue) || [inValue isEqual:testValue];
        };
    };
    XCTAssertTrue([self expect:generator(@0) fromSignal:signal timeout:5.0 description:@"last sequence number matches"]);
    
    CBLDocument *document = [_database createDocument];
    XCTAssertTrue([document update:^BOOL(CBLUnsavedRevision *newRevision) {
        newRevision[@"name"] = [[NSUUID UUID] UUIDString];
        return YES;
    } error:&error], @"%@", error);
    XCTAssertTrue([self expect:generator(@1) fromSignal:signal timeout:5.0 description:@"last sequence number matches"]);
    
    XCTAssertTrue([document update:^BOOL(CBLUnsavedRevision *newRevision) {
        newRevision[@"name"] = [[NSUUID UUID] UUIDString];
        return YES;
    } error:&error], @"%@", error);
    XCTAssertTrue([self expect:generator(@2) fromSignal:signal timeout:5.0 description:@"last sequence number matches"]);
}

@end

