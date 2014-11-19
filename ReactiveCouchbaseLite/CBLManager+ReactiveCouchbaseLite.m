//
//  CBLManager+ReactiveCouchbaseLite.m
//  Sync
//
//  Created by Nathan Douglas on 11/19/14.
//  Released into the public domain.
//  See LICENSE for details.
//

#import "CBLManager+ReactiveCouchbaseLite.h"

@implementation CBLManager (ReactiveCouchbaseLite)

+ (RACSignal *)rcl_sharedInstance {
    static CBLManager *rcl_copy = nil;
    static dispatch_once_t predicate = 0;
    dispatch_once(&predicate, ^{
        if ([NSThread isMainThread]) {
            rcl_copy = [[CBLManager sharedInstance] copy];
        } else {
            dispatch_sync(dispatch_get_main_queue(), ^{
                rcl_copy = [[CBLManager sharedInstance] copy];
            });
        }
    });
    return [RACSignal return:rcl_copy];
}

@end
