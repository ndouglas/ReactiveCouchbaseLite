//
//  CBLQueryEnumerator+ReactiveCouchbaseLite.m
//  ReactiveCouchbaseLite
//
//  Created by Nathan Douglas on 12/4/14.
//  Released into the public domain.
//  See LICENSE for details.
//

#import "CBLQueryEnumerator+ReactiveCouchbaseLite.h"
#import "ReactiveCouchbaseLite.h"

@implementation CBLQueryEnumerator (ReactiveCouchbaseLite)

- (RACSignal *)rcl_flattenedRows {
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        CBLQueryRow *row = nil;
        while ((row = self.nextRow)) {
            [subscriber sendNext:row];
        }
        [subscriber sendCompleted];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@ -rcl_flattenedRows]", self.description];
}

@end
