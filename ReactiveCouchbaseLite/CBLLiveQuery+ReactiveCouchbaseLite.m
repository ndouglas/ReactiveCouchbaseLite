//
//  CBLLiveQuery+ReactiveCouchbaseLite.m
//  ReactiveCouchbaseLite
//
//  Created by Nathan Douglas on 12/4/14.
//  Released into the public domain.
//  See LICENSE for details.
//

#import "CBLLiveQuery+ReactiveCouchbaseLite.h"
#import "ReactiveCouchbaseLite.h"

@implementation CBLLiveQuery (ReactiveCouchbaseLite)

- (RACSignal *)rcl_rows {
    RACSignal *result = [[[RACObserve(self, rows)
    ignore:nil]
    initially:^{
        [self.rcl_scheduler schedule:^{
            NSAssert(self.rcl_isOnScheduler, @"not on correct scheduler");
            [self start];
        }];
    }]
    deliverOn:self.rcl_scheduler];
    return [result setNameWithFormat:@"[%@] -rcl_rows", result.name];
}

- (RACSignal *)rcl_changes {
    RACSignal *result = [[[self rcl_rows]
    ignore:nil]
    flattenMap:^RACSignal *(CBLQueryEnumerator *enumerator) {
        NSAssert(self.rcl_isOnScheduler, @"not on correct scheduler");
        static UInt64 lastSequence = 0;
        RACSignal *result = enumerator.rcl_sequence.signal;
        lastSequence = enumerator.sequenceNumber;
        return result;
    }];
    return [result setNameWithFormat:@"[%@] -rcl_changes", result.name];
}

@end
