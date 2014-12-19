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
    RACSignal *result = [[[self rcl_rows]
    ignore:nil]
    flattenMap:^RACSignal *(CBLQueryEnumerator *enumerator) {
        NSAssert(self.rcl_isOnScheduler, @"not on correct scheduler");
        static UInt64 lastSequence = 0;
        UInt64 lastSequenceCopy = lastSequence;
        RACSequence *filteredSequence = [enumerator.rac_sequence filter:^BOOL (CBLQueryRow *row) {
            BOOL result = row.sequenceNumber >= lastSequenceCopy;
            return result;
        }];
        RACSignal *result = filteredSequence.signal;
        lastSequence = enumerator.sequenceNumber;
        return result;
    }];
    return [result setNameWithFormat:@"[%@] -rcl_changes", result.name];
}

@end
