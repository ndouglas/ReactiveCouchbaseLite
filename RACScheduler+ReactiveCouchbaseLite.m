//
//  RACScheduler+ReactiveCouchbaseLite.m
//  ReactiveCouchbaseLite
//
//  Created by Nathan Douglas on 1/22/15.
//  Released into the public domain.
//  See LICENSE for details.
//

#import "RACScheduler+ReactiveCouchbaseLite.h"
#import "ReactiveCouchbaseLite.h"

@implementation RACScheduler (ReactiveCouchbaseLite)

- (void)rcl_runOrScheduleBlock:(void (^)(void))block {
    if ([self isEqual:[RACScheduler currentScheduler]]) {
        block();
    } else {
        [self schedule:block];
    }
}

@end
