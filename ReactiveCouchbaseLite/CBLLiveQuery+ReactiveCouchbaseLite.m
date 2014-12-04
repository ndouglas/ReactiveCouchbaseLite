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
    RACSignal *result = RACObserve(self, rows);
    return [result setNameWithFormat:@"[%@] -rcl_rows", result.name];
}

@end
