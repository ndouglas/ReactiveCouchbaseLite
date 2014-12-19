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
    NSAssert(self.rcl_isOnScheduler, @"not on correct scheduler");
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

- (RACSignal *)rcl_flattenedRows {
    NSCAssert(self.rcl_isOnScheduler, @"not on correct scheduler");
    RACSignal *result = [[self rcl_rows]
    flattenMap:^RACSignal *(CBLQueryEnumerator *queryEnumerator) {
        return queryEnumerator.rac_sequence.signal;
    }];
    return [result setNameWithFormat:@"[%@] -rcl_rows", result.name];
}

- (RACSignal *)rcl_changes {
    NSAssert(self.rcl_isOnScheduler, @"not on correct scheduler");
    RACSignal *result = [[[[self rcl_rows]
    ignore:nil]
    combinePreviousWithStart:nil reduce:^RACSignal *(CBLQueryEnumerator *previous, CBLQueryEnumerator *current) {
        UInt64 lastSequence = previous ? previous.sequenceNumber : 0;
        RACSequence *filteredSequence = [current.rac_sequence filter:^BOOL(CBLQueryRow *row) {
            BOOL result = row.sequenceNumber >= lastSequence;
            return result;
        }];
        RACSignal *result = filteredSequence.signal;
        return result;
    }]
    flatten];
    return [result setNameWithFormat:@"[%@] -rcl_changes", result.name];
}

@end
