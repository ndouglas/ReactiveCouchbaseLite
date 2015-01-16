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
    NSURL *_peerURL;
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
    [_testDatabase createAllDocumentsQuery];
    XCTAssertTrue(_peerDatabase = [_manager databaseNamed:_peerName error:&error], @"Error: %@", error);
    [_peerDatabase createAllDocumentsQuery];
    _peerURL = [_listener.URL URLByAppendingPathComponent:_peerDatabase.name];
    XCTAssertTrue(_pullReplication = [_testDatabase createPullReplication:_peerURL], @"Error: %@", error);
    _pullReplication.continuous = YES;
    [_pullReplication start];
    XCTAssertTrue(_pushReplication = [_testDatabase createPushReplication:_peerURL], @"Error: %@", error);
    _pushReplication.continuous = YES;
    [_pushReplication start];
}

- (void)tearDown {
    NSError *error = nil;
    [_pushReplication stop];
    _pushReplication = nil;
    [_pullReplication stop];
    _pullReplication = nil;
    [_listener stop];
    _listener = nil;
    XCTAssertTrue([_testDatabase deleteDatabase:&error], @"Error: %@", error);
    _testDatabase = nil;
    XCTAssertTrue([_peerDatabase deleteDatabase:&error], @"Error: %@", error);
    _peerDatabase = nil;
    _manager = nil;
	[super tearDown];
}

- (void)testPendingPushDocumentIDs {
	NSString *documentID = [[NSUUID UUID] UUIDString];
    [self rcl_triviallyUpdateDocument:[_testDatabase documentWithID:documentID] times:1 interval:1];
    [self rcl_expectNexts:@[
        ^(NSString *pendingDocumentID) {
            XCTAssertTrue([pendingDocumentID isEqualToString:documentID]);
        },
    ] signal:[[_pushReplication rcl_pendingPushDocumentIDs] take:1] timeout:5.0 description:@"pending push document IDs received correctly"];
}

- (void)testTransferredDocuments {
	NSString *documentID = [[NSUUID UUID] UUIDString];
    [self rcl_triviallyUpdateDocument:[_testDatabase documentWithID:documentID] times:3 interval:1];
    [self rcl_expectNexts:@[
        ^(NSDictionary *transferringDocument) {
            XCTAssertTrue([transferringDocument[@"_id"] isEqualToString:documentID]);
        },
        ^(NSDictionary *transferringDocument) {
            XCTAssertTrue([transferringDocument[@"_id"] isEqualToString:documentID]);
        },
        ^(NSDictionary *transferringDocument) {
            XCTAssertTrue([transferringDocument[@"_id"] isEqualToString:documentID]);
        },
    ] signal:[[_pushReplication rcl_transferredDocuments] take:3] timeout:5.0 description:@"pending push document IDs received correctly"];
}

@end
