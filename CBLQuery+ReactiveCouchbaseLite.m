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
    NSCAssert(self.rcl_isOnScheduler, @"not on correct scheduler");
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [self runAsync:^(CBLQueryEnumerator *queryEnumerator, NSError *error) {
            [self.database.rcl_scheduler rcl_runOrScheduleBlock:^{
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
    return [result setNameWithFormat:@"[%@ -rcl_run]", self];
}

- (RACSignal *)rcl_purgeDocuments {
    NSCAssert(self.rcl_isOnScheduler, @"not on correct scheduler");
    CBLDatabase *database = self.database;
    RACSignal *result = [[self rcl_run]
        flattenMap:^RACSignal *(CBLQueryEnumerator *queryEnumerator) {
            NSMutableArray *documentIDs = [NSMutableArray array];
            for (CBLQueryRow *row in queryEnumerator.allObjects) {
                [documentIDs addObject:row.documentID];
            }
            return [database rcl_purgeDocumentsWithIDs:documentIDs];
        }];
    return [result setNameWithFormat:@"[%@ -rcl_purgeDocuments]", self];
}

- (RACSignal *)rcl_flattenedRows {
    NSCAssert(self.rcl_isOnScheduler, @"not on correct scheduler");
    RACSignal *result = [[self rcl_run]
    flattenMap:^RACSignal *(CBLQueryEnumerator *queryEnumerator) {
        return queryEnumerator.rac_sequence.signal;
    }];
    return [result setNameWithFormat:@"[%@ -rcl_rows]", self];
}

- (RACScheduler *)rcl_scheduler {
    return self.database.rcl_scheduler;
}

- (BOOL)rcl_isOnScheduler {
    return self.database.rcl_isOnScheduler;
}

@end
