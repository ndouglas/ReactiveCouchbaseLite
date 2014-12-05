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
    _database = [_manager databaseNamed:@"rcl_test" error:&error];
    if (!_database) {
        XCTFail(@"Error creating database 'rcl_test': %@", error);
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
    [self expectNext:^(CBLManager *manager) {
        XCTAssertNotNil(manager);
    } signal:[CBLManager rcl_sharedInstance] timeout:5.0 description:@"sharedInstance is equal to sharedInstance"];
}

- (void)testIsOnScheduler {
    [self expectNext:^(CBLManager *manager) {
    } signal:[CBLManager rcl_sharedInstance]
    timeout:5.0 description:@"sharedInstance was delivered on a correct thread"];
    [self expectNext:^(CBLManager *manager) {
    } signal:[[CBLManager rcl_sharedInstance]
    deliverOn:_failScheduler]
    timeout:5.0 description:@"sharedInstance was delivered on an incorrect thread"];
}

@end

