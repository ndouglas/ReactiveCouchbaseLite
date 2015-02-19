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

@interface CBLReplication_ReactiveCouchbaseLiteTests : RCLTestCase

@end

@implementation CBLReplication_ReactiveCouchbaseLiteTests

- (void)setUp {
	[super setUp];
    [self rcl_setupEverything];
}

- (void)tearDown {
    [self rcl_tearDown];
	[super tearDown];
}

- (void)testPendingPushDocumentIDs {
	NSString *documentID = [[NSUUID UUID] UUIDString];
    [self rcl_triviallyUpdateDocument:[self.testDatabase documentWithID:documentID] times:1 interval:0.1];
    [self rcl_expectNexts:@[
        ^(NSString *pendingDocumentID) {
            XCTAssertTrue([pendingDocumentID isEqualToString:documentID]);
        },
    ] signal:[[self.pushReplication rcl_pendingPushDocumentIDs] take:1] timeout:5.0 description:@"pending push document IDs received correctly"];
}

- (void)testTransferredDocuments {
	NSString *documentID = [[NSUUID UUID] UUIDString];
    [self rcl_triviallyUpdateDocument:[self.testDatabase documentWithID:documentID] times:3 interval:0.1];
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
    ] signal:[[self.pushReplication rcl_transferredDocuments] take:3] timeout:5.0 description:@"pending push document IDs received correctly"];
}

@end
