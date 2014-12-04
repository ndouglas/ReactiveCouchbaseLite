//
//  CBLDocument+ReactiveCouchbaseLite.Tests.m
//  ReactiveCouchbaseLite
//
//  Created by Nathan Douglas on 12/4/14.
//  Released into the public domain.
//  See LICENSE for details.
//

#import <XCTest/XCTest.h>
#import "RCLTestDefinitions.h"
#import "ReactiveCouchbaseLite.h"

@interface CBLDocument_ReactiveCouchbaseLiteTests : XCTestCase

@end

@implementation CBLDocument_ReactiveCouchbaseLiteTests

- (void)setUp {
	[super setUp];
}

- (void)tearDown {
	[super tearDown];
}

- (void)test {
	/*
		Run a test here.
	*/
}

@end

/**
- (RACSignal *)rcl_delete;
- (RACSignal *)rcl_purge;
- (RACSignal *)rcl_currentRevisionID;
- (RACSignal *)rcl_currentRevision;
- (RACSignal *)rcl_revisionWithID:(NSString *)revisionID;
- (RACSignal *)rcl_getRevisionHistory;
- (RACSignal *)rcl_getRevisionHistoryFilteredWithBlock:(BOOL (^)(CBLSavedRevision *revision))block;
- (RACSignal *)rcl_getConflictingRevisions;
- (RACSignal *)rcl_getLeafRevisions;
- (RACSignal *)rcl_newRevision;
- (RACSignal *)rcl_properties;
- (RACSignal *)rcl_userProperties;
- (RACSignal *)rcl_putProperties:(NSDictionary *)properties;
- (RACSignal *)rcl_update:(BOOL(^)(CBLUnsavedRevision *))block;
- (RACSignal *)rcl_documentChangeNotifications;
 */
