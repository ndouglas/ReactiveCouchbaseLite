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
    return [[[[RACObserve(self, rows)
        ignore:nil]
        initially:^{
            [self.rcl_scheduler rcl_runOrScheduleBlock:^{
                NSAssert(self.rcl_isOnScheduler, @"not on correct scheduler");
                [self start];
            }];
        }]
        deliverOn:self.rcl_scheduler]
        setNameWithFormat:@"[%@ -rcl_rows]", self];
}

- (RACSignal *)rcl_flattenedRows {
    NSCAssert(self.rcl_isOnScheduler, @"not on correct scheduler");
    return [[[[self rcl_rows]
        flattenMap:^RACSignal *(CBLQueryEnumerator *queryEnumerator) {
            return queryEnumerator.rac_sequence.signal;
        }]
        deliverOn:self.rcl_scheduler]
        setNameWithFormat:@"[%@ -rcl_rows]", self];
}

- (RACSignal *)rcl_changes {
    NSAssert(self.rcl_isOnScheduler, @"not on correct scheduler");
    return [[[[[[self rcl_rows]
        ignore:nil]
        combinePreviousWithStart:nil reduce:^RACSignal *(CBLQueryEnumerator *previous, CBLQueryEnumerator *current) {
            return [current rcl_rowsSinceSequenceNumber:previous ? previous.sequenceNumber : 0];
        }]
        flatten]
        deliverOn:self.rcl_scheduler]
        setNameWithFormat:@"[%@ -rcl_changes]", self];
}

@end
