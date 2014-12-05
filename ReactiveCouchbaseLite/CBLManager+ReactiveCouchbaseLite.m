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
    return [[RACSignal return:rcl_copy]
    setNameWithFormat:@"%@ +rcl_sharedInstance", self];
}

+ (RACSignal *)rcl_databaseNamed:(NSString *)_name {
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        RACDisposable *disposable = [[self rcl_sharedInstance]
        subscribeNext:^(CBLManager *manager) {
            NSError *error = nil;
            CBLDatabase *database = [manager databaseNamed:_name error:&error];
            if (database) {
                [subscriber sendNext:database];
            } else {
                [subscriber sendError:error];
            }
            [subscriber sendCompleted];
        } error:^(NSError *error) {
            [subscriber sendError:error];
        } completed:^{
            [subscriber sendCompleted];
        }];
        return disposable;
    }]
    setNameWithFormat:@"%@ +rcl_databaseNamed: %@", self, _name];
}

+ (RACSignal *)rcl_existingDatabaseNamed:(NSString *)_name {
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        RACDisposable *disposable = [[self rcl_sharedInstance]
        subscribeNext:^(CBLManager *manager) {
            NSError *error = nil;
            CBLDatabase *database = [manager existingDatabaseNamed:_name error:&error];
            if (database) {
                [subscriber sendNext:database];
            } else {
                [subscriber sendError:error];
            }
        } error:^(NSError *error) {
            [subscriber sendError:error];
        } completed:^{
            [subscriber sendCompleted];
        }];
        return disposable;
    }]
    setNameWithFormat:@"%@ +rcl_existingDatabaseNamed: %@", self, _name];
}

- (RACScheduler *)rcl_scheduler {
    return [[RACQueueScheduler alloc] initWithName:self.description queue:self.dispatchQueue];
}

@end
