//
//  CBLQuery+ReactiveCouchbaseLite.Tests.m
//  ReactiveCouchbaseLite
//
//  Created by Nathan Douglas on 12/4/14.
//  Released into the public domain.
//  See LICENSE for details.
//

#import <XCTest/XCTest.h>
#import "RCLTestDefinitions.h"
#import "RCLDefinitions.h"

@interface CBLQuery_ReactiveCouchbaseLiteTests : RCLTestCase

@end

@implementation CBLQuery_ReactiveCouchbaseLiteTests

- (void)setUp {
	[super setUp];
    [self rcl_setupDatabase];
}

- (void)tearDown {
    [self rcl_tearDown];
	[super tearDown];
}

- (void)testRun {
    NSError *error = nil;
    for (int i = 0; i < 500; i++) {
        [[self.testDatabase documentWithID:[[NSUUID UUID] UUIDString]] update:^BOOL(CBLUnsavedRevision *unsavedRevision) {
            unsavedRevision.properties[[[NSUUID UUID] UUIDString]] = [[NSUUID UUID] UUIDString];
            unsavedRevision.properties[[[NSUUID UUID] UUIDString]] = [[NSUUID UUID] UUIDString];
            return YES;
        } error:&error];
    }
    [self rcl_expectNext:^(CBLQueryEnumerator *queryEnumerator) {
        XCTAssertTrue(queryEnumerator.count == 500);
    } signal:[[self.testDatabase createAllDocumentsQuery] rcl_run]  timeout:5.0 description:@"query returned with appropriate number of results"];
}

- (void)testFlattenedRows {
    NSError *error = nil;
    for (int i = 0; i < 500; i++) {
        [[self.testDatabase documentWithID:[[NSUUID UUID] UUIDString]] update:^BOOL(CBLUnsavedRevision *unsavedRevision) {
            unsavedRevision.properties[[[NSUUID UUID] UUIDString]] = [[NSUUID UUID] UUIDString];
            unsavedRevision.properties[[[NSUUID UUID] UUIDString]] = [[NSUUID UUID] UUIDString];
            return YES;
        } error:&error];
    }
    [self rcl_expectCompletionFromSignal:[[[[self.testDatabase createAllDocumentsQuery] rcl_flattenedRows] take:500] ignoreValues] timeout:5.0 description:@"query returned with appropriate number of results"];
}

@end
