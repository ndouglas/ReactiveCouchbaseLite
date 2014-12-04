//
//  CBLSavedRevision+ReactiveCouchbaseLite.m
//  ReactiveCouchbaseLite
//
//  Created by Nathan Douglas on 12/4/14.
//  Released into the public domain.
//  See LICENSE for details.
//

#import "CBLSavedRevision+ReactiveCouchbaseLite.h"

@implementation CBLSavedRevision (ReactiveCouchbaseLite)

- (RACSignal *)rcl_createRevision {
    RACSignal *result = [RACSignal return:[self createRevision]];
    return [result setNameWithFormat:@"[%@] -rcl_createRevision", result.name];
}

- (RACSignal *)rcl_createRevisionWithProperties:(NSDictionary *)properties {
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSError *error = nil;
        CBLSavedRevision *revision = [self createRevisionWithProperties:properties error:&error];
        if (revision) {
            [subscriber sendNext:revision];
        } else {
            [subscriber sendError:error];
        }
        [subscriber sendCompleted];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@] -rcl_createRevisionWithProperties: %@", result.name, properties];
}

- (RACSignal *)rcl_delete {
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSError *error = nil;
        CBLSavedRevision *revision = [self deleteDocument:&error];
        if (revision) {
            [subscriber sendNext:revision];
        } else {
            [subscriber sendError:error];
        }
        [subscriber sendCompleted];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@] -rcl_delete", result.name];
}

@end
