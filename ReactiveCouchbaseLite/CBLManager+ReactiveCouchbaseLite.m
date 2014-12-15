//
//  CBLManager+ReactiveCouchbaseLite.m
//  Sync
//
//  Created by Nathan Douglas on 11/19/14.
//  Released into the public domain.
//  See LICENSE for details.
//

#import "CBLManager+ReactiveCouchbaseLite.h"
#import <objc/runtime.h>

static char CBLManagerAssociatedSchedulerKey;

CBLManager *RCLSharedInstanceCurrentOrNewManager(CBLManager *current) {
    __block CBLManager *result = nil;
    if ([NSThread isMainThread]) {
        result = [CBLManager sharedInstance];
        if (![result rcl_scheduler]) {
            [result rcl_setScheduler:[RACScheduler mainThreadScheduler]];
        }
    } else {
        if (!current || !current.rcl_isOnScheduler) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                result = [[CBLManager sharedInstance] copy];
            });
            NSString *description = result.description;
            dispatch_queue_t queue = dispatch_queue_create(description.UTF8String, DISPATCH_QUEUE_SERIAL);
            result.dispatchQueue = queue;
            RACScheduler *scheduler = [[RACQueueScheduler alloc] initWithName:description queue:queue];
            [result rcl_setScheduler:scheduler];
        } else {
            result = current;
        }
    }
    return result;
}

@implementation CBLManager (ReactiveCouchbaseLite)

+ (RACSignal *)rcl_manager {
    __block CBLManager *manager = RCLSharedInstanceCurrentOrNewManager(nil);
    return [[[RACSignal return:manager]
    deliverOn:manager.rcl_scheduler]
    setNameWithFormat:@"%@ +rcl_sharedInstance", self];
}

+ (RACSignal *)rcl_databaseNamed:(NSString *)name {
    return [[self rcl_manager]
    flattenMap:^RACSignal *(CBLManager *manager) {
        NSCAssert(manager.rcl_isOnScheduler, @"not on correct scheduler");
        return [manager rcl_databaseNamed:name];
    }];
}

+ (RACSignal *)rcl_existingDatabaseNamed:(NSString *)name {
    return [[self rcl_manager]
    flattenMap:^RACSignal *(CBLManager *manager) {
        NSCAssert(manager.rcl_isOnScheduler, @"not on correct scheduler");
        return [manager rcl_existingDatabaseNamed:name];
    }];
}

- (RACSignal *)rcl_databaseNamed:(NSString *)name {
    CBLManager *manager = RCLSharedInstanceCurrentOrNewManager(self);
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [manager.rcl_scheduler schedule:^{
            NSCAssert(manager.rcl_isOnScheduler, @"not on correct scheduler");
            NSError *error = nil;
            CBLDatabase *database = [manager databaseNamed:name error:&error];
            if (database) {
                [subscriber sendNext:database];
            } else {
                [subscriber sendError:error];
            }
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    return [result setNameWithFormat:@"%@ -rcl_databaseNamed: %@", result.name, name];
}

- (RACSignal *)rcl_existingDatabaseNamed:(NSString *)name {
    CBLManager *manager = RCLSharedInstanceCurrentOrNewManager(self);
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [manager.rcl_scheduler schedule:^{
            NSCAssert(manager.rcl_isOnScheduler, @"not on correct scheduler");
            NSError *error = nil;
            CBLDatabase *database = [manager existingDatabaseNamed:name error:&error];
            if (database) {
                [subscriber sendNext:database];
            } else {
                [subscriber sendError:error];
            }
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    return [result setNameWithFormat:@"%@ -rcl_existingDatabaseNamed: %@", result.name, name];
}

- (void)rcl_setScheduler:(RACScheduler *)scheduler {
    @synchronized (self) {
        objc_setAssociatedObject(self, &CBLManagerAssociatedSchedulerKey, scheduler, OBJC_ASSOCIATION_RETAIN);
    }
}

- (RACScheduler *)rcl_scheduler {
    RACScheduler *result = nil;
    @synchronized (self) {
        result = (RACScheduler *)objc_getAssociatedObject(self, &CBLManagerAssociatedSchedulerKey);
        if (!result && [NSThread isMainThread]) {
            result = [RACScheduler mainThreadScheduler];
            [self rcl_setScheduler:[RACScheduler mainThreadScheduler]];
        }
    }
    return result;
}

- (BOOL)rcl_isOnScheduler {
    BOOL result = NO;
    @synchronized (self) {
        result = [self.rcl_scheduler isEqual:[RACScheduler currentScheduler]];
    }
    return result;
}

@end
