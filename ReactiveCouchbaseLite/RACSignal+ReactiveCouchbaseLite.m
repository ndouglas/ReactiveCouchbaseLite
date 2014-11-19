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
        return query;
    }]
    setNameWithFormat:@"%@ -rcl_updateQueryIndexMode: %@", self.name, @(mode)];
}

@end
