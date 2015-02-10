//
//  CBLModel+ReactiveCouchbaseLite.Tests.m
//  ReactiveCouchbaseLite
//
//  Created by Nathan Douglas on 11/19/14.
//  Released into the public domain.
//  See LICENSE for details.
//

#import <XCTest/XCTest.h>
#import "ReactiveCouchbaseLite.h"
#import "RCLTestDefinitions.h"

@interface RCLTestModel : CBLModel
@property (copy, nonatomic, readwrite) NSString *keyA;
@property (copy, nonatomic, readwrite) NSString *keyB;
@end

@implementation RCLTestModel
@dynamic keyA;
@dynamic keyB;
- (void)didLoadFromDocument {
    NSLog(@"Received didLoadFromDocument with %@", @{
        @"keyA" : self.keyA ?: [NSNull null],
        @"keyB" : self.keyB ?: [NSNull null],
    });
}
@end

@interface CBLModel_ReactiveCouchbaseLiteTests : RCLTestCase
@property (copy, nonatomic, readwrite) NSString *testDocumentUUID;
@property (strong, nonatomic, readwrite) CBLDocument *testDocument;
@property (strong, nonatomic, readwrite) RCLTestModel *testModel;
@end

@implementation CBLModel_ReactiveCouchbaseLiteTests
@synthesize testDocumentUUID;
@synthesize testDocument;
@synthesize testModel;

- (void)setUp {
	[super setUp];
    [self rcl_setupDatabase];
    self.testDocumentUUID = [[NSUUID UUID] UUIDString];
    self.testDocument = [self.testDatabase documentWithID:self.testDocumentUUID];
    NSError *error = nil;
    BOOL success = [self.testDocument update:^BOOL(CBLUnsavedRevision *_unsavedRevision_) {
        _unsavedRevision_[[[NSUUID UUID] UUIDString]] = [[NSUUID UUID] UUIDString];
        return YES;
    } error:&error] != nil;
    XCTAssertTrue(success);
    self.testModel = [RCLTestModel modelForDocument:self.testDocument];
    self.testModel.autosaves = YES;
}

- (void)tearDown {
	[super tearDown];
}

- (void)testDidLoadFromDocument {
    NSString *testUUID = [[NSUUID UUID] UUIDString];
	[self rcl_expectNext:^(RCLTestModel *_model_) {
        XCTAssertNotNil(_model_);
        XCTAssertEqualObjects(_model_.keyA, testUUID);
    } signal:[[self.testModel rcl_didLoadFromDocument] take:1] initially:^{
        NSError *error = nil;
        BOOL success = [self.testDocument update:^BOOL(CBLUnsavedRevision *_unsavedRevision_) {
            _unsavedRevision_[@"keyA"] = testUUID;
            _unsavedRevision_[@"keyB"] = [[NSUUID UUID] UUIDString];
            _unsavedRevision_[[[NSUUID UUID] UUIDString]] = [[NSUUID UUID] UUIDString];
            return YES;
        } error:&error] != nil;
        XCTAssertTrue(success);
    } timeout:5.0 description:@"next received"];
}

@end
