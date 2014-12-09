//
//  CBLManager+ReactiveCouchbaseLite.Tests.m
//  Sync
//
//  Created by Nathan Douglas on 11/19/14.
//  Copyright (c) 2013 DEVONtechnologies. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RCLTestDefinitions.h"
#import "ReactiveCouchbaseLite.h"

@interface CBLManager_ReactiveCouchbaseLiteTests : XCTestCase {
    CBLManager *_manager;
    NSString *_databaseName;
    CBLDatabase *_database;
    RACScheduler *_failScheduler;
}

@end

@implementation CBLManager_ReactiveCouchbaseLiteTests

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
    _failScheduler = [[RACQueueScheduler alloc] initWithName:@"FailQueue" queue:dispatch_queue_create("FailQueue", DISPATCH_QUEUE_SERIAL)];
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

- (void)testSharedInstance {
    [self rcl_expectNext:^(CBLManager *manager) {
        XCTAssertNotNil(manager);
    } signal:[CBLManager rcl_manager] timeout:5.0 description:@"sharedInstance is equal to sharedInstance"];
}

- (void)testDatabaseNamed {
    [self rcl_expectNext:^(CBLDatabase *database) {
        XCTAssertNotNil(database);
    } signal:[CBLManager rcl_databaseNamed:_databaseName] timeout:5.0 description:@"database is not nil"];
    [self rcl_expectNext:^(CBLDatabase *database) {
        XCTAssertNotNil(database);
    } signal:[[CBLManager sharedInstance] rcl_databaseNamed:_databaseName] timeout:5.0 description:@"database is not nil"];
}

- (void)testExistingDatabaseNamed {
    [self rcl_expectNext:^(CBLDatabase *database) {
        XCTAssertNotNil(database);
    } signal:[CBLManager rcl_existingDatabaseNamed:_databaseName] timeout:5.0 description:@"existing database is not nil"];
    [self rcl_expectNext:^(CBLDatabase *database) {
        XCTAssertNotNil(database);
    } signal:[[CBLManager sharedInstance] rcl_existingDatabaseNamed:_databaseName] timeout:5.0 description:@"existing database is not nil"];
}

- (void)testIsOnScheduler {
    [self rcl_expectNext:^(CBLManager *manager) {
    } signal:[CBLManager rcl_manager]
    timeout:5.0 description:@"sharedInstance was delivered on a correct thread"];
    [self rcl_expectNext:^(CBLManager *manager) {
    } signal:[[CBLManager rcl_manager]
    deliverOn:_failScheduler]
    timeout:5.0 description:@"sharedInstance was delivered on an incorrect thread"];
}

@end

