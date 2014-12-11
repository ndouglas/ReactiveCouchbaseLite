//
//  CBLQuery+ReactiveCouchbaseLite.m
//  ReactiveCouchbaseLite
//
//  Created by Nathan Douglas on 12/4/14.
//  Released into the public domain.
//  See LICENSE for details.
//

#import "CBLQuery+ReactiveCouchbaseLite.h"
#import "ReactiveCouchbaseLite.h"

@implementation CBLQuery (ReactiveCouchbaseLite)

- (RACSignal *)rcl_run {
    @weakify(self)
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        @weakify(self)
        [self runAsync:^(CBLQueryEnumerator *queryEnumerator, NSError *error) {
            @strongify(self)
            @weakify(self)
            [self.database.rcl_scheduler schedule:^{
                @strongify(self)
                NSCAssert(self.rcl_isOnScheduler, @"not on correct scheduler");
                if (queryEnumerator) {
                    [subscriber sendNext:queryEnumerator];
                } else {
                    [subscriber sendError:error];
                }
                [subscriber sendCompleted];
            }];
        }];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@] -rcl_run", result.name];
}

- (RACSignal *)rcl_signal {
    NSCAssert(self.rcl_isOnScheduler, @"not on correct scheduler");
    RACSignal *result = [[self rcl_run]
    flattenMap:^RACSignal *(CBLQueryEnumerator *queryEnumerator) {
        return queryEnumerator.rac_sequence.signal;
    }];
    return [result setNameWithFormat:@"[%@] -rcl_sequence", result.name];
}

- (RACScheduler *)rcl_scheduler {
    return self.database.rcl_scheduler;
}

- (BOOL)rcl_isOnScheduler {
    return self.database.rcl_isOnScheduler;
}

@end
