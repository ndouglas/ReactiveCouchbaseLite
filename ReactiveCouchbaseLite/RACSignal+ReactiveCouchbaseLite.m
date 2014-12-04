//
//  RACSignal+ReactiveCouchbaseLite.m
//  ReactiveCouchbaseLite
//
//  Created by Nathan Douglas on 11/19/14.
//  Released into the public domain.
//  See LICENSE for details.
//

#import "RACSignal+ReactiveCouchbaseLite.h"

@implementation RACSignal (ReactiveCouchbaseLite)

- (RACSignal *)rcl_updateQueryIndexUpdateMode:(CBLIndexUpdateMode)mode {
    return [[self
    map:^CBLQuery *(CBLQuery *query) {
        CBLQuery *result = query;
        if (query.indexUpdateMode != mode) {
            result = query.copy;
            result.indexUpdateMode = mode;
        }
        return result;
    }]
    setNameWithFormat:@"%@ -rcl_updateQueryIndexMode: %@", self.name, @(mode)];
}

- (RACSignal *)rcl_updateQueryIndexBeforeQuerying {
    return [[self rcl_updateQueryIndexUpdateMode:kCBLUpdateIndexBefore]
    setNameWithFormat:@"%@ -rcl_updateQueryIndexBeforeQuerying", self.name];
}

- (RACSignal *)rcl_updateQueryIndexAfterQuerying {
    return [[self rcl_updateQueryIndexUpdateMode:kCBLUpdateIndexAfter]
    setNameWithFormat:@"%@ -rcl_updateQueryIndexAfterQuerying", self.name];
}

- (RACSignal *)rcl_neverUpdateQueryIndex {
    return [[self rcl_updateQueryIndexUpdateMode:kCBLUpdateIndexNever]
    setNameWithFormat:@"%@ -rcl_neverUpdateQueryIndex", self.name];
}

@end
