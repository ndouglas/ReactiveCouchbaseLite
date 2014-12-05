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
    __block CBLManager *manager = nil;
    if ([NSThread isMainThread]) {
        manager = [[CBLManager sharedInstance] copy];
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            manager = [[CBLManager sharedInstance] copy];
        });
    }
    manager.dispatchQueue = dispatch_queue_create(manager.description.UTF8String, DISPATCH_QUEUE_SERIAL);
    return [[[RACSignal return:manager]
    deliverOn:[manager rcl_scheduler]]
    setNameWithFormat:@"%@ +rcl_sharedInstance", self];
}

+ (RACSignal *)rcl_databaseNamed:(NSString *)_name {
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        RACDisposable *disposable = [[self rcl_sharedInstance]
        subscribeNext:^(CBLManager *manager) {
            NSCAssert(manager.rcl_isOnScheduler, @"not on correct scheduler");
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
            NSCAssert(manager.rcl_isOnScheduler, @"not on correct scheduler");
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

- (BOOL)rcl_isOnScheduler {
    BOOL result = YES;
    result = result && [self rcl_scheduler];
    result = result && [[RACQueueScheduler currentScheduler] isKindOfClass:[RACQueueScheduler class]];
    RACQueueScheduler *queueScheduler = (RACQueueScheduler *)[RACQueueScheduler currentScheduler];
    dispatch_queue_t schedulerQueue = [queueScheduler queue];
    NSString *schedulerQueueLabel = @(dispatch_queue_get_label(schedulerQueue));
    result = result && [schedulerQueueLabel isEqualToString:self.description];
    return result;
}

@end
