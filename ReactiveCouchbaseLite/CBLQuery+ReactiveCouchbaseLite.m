//
//  CBLQuery+ReactiveCouchbaseLite.m
//  ReactiveCouchbaseLite
//
//  Created by Nathan Douglas on 12/4/14.
//  Released into the public domain.
//  See LICENSE for details.
//

#import "CBLQuery+ReactiveCouchbaseLite.h"

@implementation CBLQuery (ReactiveCouchbaseLite)

- (RACSignal *)rcl_run {
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [self runAsync:^(CBLQueryEnumerator *queryEnumerator, NSError *error) {
            if (queryEnumerator) {
                [subscriber sendNext:queryEnumerator];
            } else {
                [subscriber sendError:error];
            }
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@] -rcl_run", result.name];
}

@end