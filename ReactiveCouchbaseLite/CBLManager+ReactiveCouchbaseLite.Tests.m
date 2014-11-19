//
//  CBLManager+ReactiveCouchbaseLite.Tests.m
//  Sync
//
//  Created by Nathan Douglas on 11/19/14.
//  Copyright (c) 2013 DEVONtechnologies. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ReactiveCouchbaseLite.h"

typedef BOOL (^RCLObjectTesterBlock)(id);
typedef RCLObjectTesterBlock (^RCLObjectTesterGeneratorBlock)(id);

@interface CBLManager_ReactiveCouchbaseLiteTests : XCTestCase {
    CBLManager *_manager;
    CBLDatabase *_database;
}

@end

@implementation CBLManager_ReactiveCouchbaseLiteTests

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

- (BOOL)expect:(RCLObjectTesterBlock)block fromSignal:(RACSignal *)signal timeout:(NSTimeInterval)timeout description:(NSString *)description {
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

- (void)testSharedInstance {
    RACSignal *signal = [CBLManager rcl_sharedInstance];
    RCLObjectTesterBlock tester = ^BOOL (id inValue) {
        return [inValue isEqual:_manager];
    };
    XCTAssertTrue([self expect:tester fromSignal:signal timeout:5.0 description:@"sharedInstance is equal to sharedInstance"]);
    
}

@end

