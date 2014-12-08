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

- (RACSignal *)rcl_nextRow {
    @weakify(self)
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        CBLQueryRow *row = self.nextRow;
        if (row) {
            [subscriber sendNext:row];
        } else {
            [subscriber sendError:RCLErrorWithCode(RCLErrorCode_QueryRowCouldNotBeFound)];
        }
        [subscriber sendCompleted];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@ -rcl_nextRow]", self.description];
}

- (RACSequence *)rcl_sequence {
    CBLQueryEnumerator *enumerator = [self copy];
    [enumerator reset];
    CBLQueryRow *row = [enumerator nextRow];
    return [RACSequence sequenceWithHeadBlock:^CBLQueryRow *{
        return row;
    } tailBlock:^RACSequence *{
        return [enumerator rcl_sequence];
    }];
}

@end
