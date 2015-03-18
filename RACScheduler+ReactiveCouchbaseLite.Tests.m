//
//  RACScheduler+ReactiveCouchbaseLite.Tests.m
//  ReactiveCouchbaseLite
//
//  Created by Nathan Douglas on 1/22/15.
//  Released into the public domain.
//  See LICENSE for details.
//

#import <XCTest/XCTest.h>
#import "RCLTestDefinitions.h"

@interface RACScheduler_ReactiveCouchbaseLiteTests : RCLTestCase

@end

@implementation RACScheduler_ReactiveCouchbaseLiteTests

- (void)setUp {
	[super setUp];
}

- (void)tearDown {
	[super tearDown];
}

- (void)testRunOrScheduleBlock {
    XCTestExpectation *expectation = [self expectationWithDescription:@"block performed"];
    [[RACScheduler mainThreadScheduler] rcl_runOrScheduleBlock:^{
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

@end
