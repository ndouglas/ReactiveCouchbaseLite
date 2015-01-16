//
//  CBLReplication+ReactiveCouchbaseLite.Tests.m
//  ReactiveCouchbaseLite
//
//  Created by Nathan Douglas on 12/4/14.
//  Released into the public domain.
//  See LICENSE for details.
//

#import <XCTest/XCTest.h>
#import "ReactiveCouchbaseLite.h"
#import "RCLTestDefinitions.h"

@interface CBLReplication_ReactiveCouchbaseLiteTests : XCTestCase {
    CBLManager *_manager;
    NSUInteger _port;
    NSNumber *_testID;
    NSString *_testName;
    NSString *_peerName;
    CBLDatabase *_testDatabase;
    CBLDatabase *_peerDatabase;
    CBLReplication *_pullReplication;
    CBLReplication *_pushReplication;
    CBLListener *_listener;
}

@end

@implementation CBLReplication_ReactiveCouchbaseLiteTests

- (void)setUp {
	[super setUp];
    _port = 2014;
    [CBLManager rcl_enableUsefulLogs];
    _manager = [CBLManager sharedInstance];
    _testID = @([[[NSUUID UUID] UUIDString] hash]);
    _testName = [NSString stringWithFormat:@"test_%@", _testID];
    _peerName = [NSString stringWithFormat:@"peer_%@", _testID];
    _listener = [[CBLListener alloc] initWithManager:_manager port:_port];
    NSError *error = nil;
    XCTAssertTrue([_listener start:&error], @"Error: %@", error);
    XCTAssertTrue(_testDatabase = [_manager databaseNamed:_testName error:&error], @"Error: %@", error);
    XCTAssertTrue(_peerDatabase = [_manager databaseNamed:_peerName error:&error], @"Error: %@", error);
    XCTAssertTrue(_pullReplication = [_testDatabase createPullReplication:[_peerDatabase internalURL]], @"Error: %@", error);
    _pullReplication.continuous = YES;
    [_pullReplication start];
    XCTAssertTrue(_pushReplication = [_testDatabase createPushReplication:[_peerDatabase internalURL]], @"Error: %@", error);
    _pushReplication.continuous = YES;
    [_pushReplication start];
}

- (void)tearDown {
    [_listener stop];
    NSError *error = nil;
    [_pushReplication stop];
    [_pullReplication stop];
    XCTAssertTrue([_testDatabase deleteDatabase:&error], @"Error: %@", error);
    XCTAssertTrue([_peerDatabase deleteDatabase:&error], @"Error: %@", error);
	[super tearDown];
}


- (void)test {
	/*
		Run a test here.
	*/
}

@end
