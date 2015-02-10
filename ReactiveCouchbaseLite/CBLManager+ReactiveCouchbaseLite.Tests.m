//
//  CBLManager+ReactiveCouchbaseLite.Tests.m
//  ReactiveCouchbaseLite
//
//  Created by Nathan Douglas on 11/19/14.
//  Copyright (c) 2013 DEVONtechnologies. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RCLTestDefinitions.h"
#import "ReactiveCouchbaseLite.h"

@interface CBLManager_ReactiveCouchbaseLiteTests : RCLTestCase

@end

@implementation CBLManager_ReactiveCouchbaseLiteTests

- (void)setUp {
	[super setUp];
    [self rcl_setupEverything];
}

- (void)tearDown {
    [self rcl_tearDown];
	[super tearDown];
}

- (void)testSharedInstance {
    [self rcl_expectNext:^(CBLManager *manager) {
        XCTAssertNotNil(manager);
    } signal:[CBLManager rcl_manager] timeout:5.0 description:@"sharedInstance is equal to sharedInstance"];
}

- (void)testLog {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [CBLManager enableLogging:@"CBLDatabase"];
        [[self.testDatabase documentWithID:[[NSUUID UUID] UUIDString]] update:^BOOL(CBLUnsavedRevision *unsavedRevision) {
            unsavedRevision.properties[@"name"] = [[NSUUID UUID] UUIDString];
            return YES;
        } error:NULL];
    });
    [self rcl_expectNexts:@[
        ^(RACTuple *tuple) {
            XCTAssertNotNil(tuple);
        },
        ^(RACTuple *tuple) {
            XCTAssertNotNil(tuple);
        },
    ] signal:[[CBLManager rcl_log]
    take:2] timeout:5.0 description:@"log received"];
}

- (void)testDatabaseNamed {
    [self rcl_expectNext:^(CBLDatabase *database) {
        XCTAssertNotNil(database);
    } signal:[CBLManager rcl_databaseNamed:self.testName] timeout:5.0 description:@"database is not nil"];
    [self rcl_expectNext:^(CBLDatabase *database) {
        XCTAssertNotNil(database);
    } signal:[[CBLManager sharedInstance] rcl_databaseNamed:self.testName] timeout:5.0 description:@"database is not nil"];
}

- (void)testExistingDatabaseNamed {
    [self rcl_expectNext:^(CBLDatabase *database) {
        XCTAssertNotNil(database);
    } signal:[CBLManager rcl_existingDatabaseNamed:self.testName] timeout:5.0 description:@"existing database is not nil"];
    [self rcl_expectNext:^(CBLDatabase *database) {
        XCTAssertNotNil(database);
    } signal:[[CBLManager sharedInstance] rcl_existingDatabaseNamed:self.testName] timeout:5.0 description:@"existing database is not nil"];
}

- (void)testIsOnScheduler {
    [self rcl_expectNext:^(CBLManager *manager) {
    } signal:[CBLManager rcl_manager] timeout:5.0 description:@"sharedInstance was delivered on a correct thread"];
}

@end
