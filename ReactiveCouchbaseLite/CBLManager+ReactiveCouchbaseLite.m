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
    NSString *description = manager.description;
    manager.dispatchQueue = dispatch_queue_create(description.UTF8String, DISPATCH_QUEUE_SERIAL);
    RACScheduler *scheduler = [[RACQueueScheduler alloc] initWithName:description queue:manager.dispatchQueue];
    objc_setAssociatedObject(manager, &CBLManagerAssociatedSchedulerKey, scheduler, OBJC_ASSOCIATION_RETAIN);
    return [[[RACSignal return:manager]
    deliverOn:scheduler]
    setNameWithFormat:@"%@ +rcl_sharedInstance", self];
}

+ (RACSignal *)rcl_databaseNamed:(NSString *)name {
    return [[self rcl_sharedInstance]
    flattenMap:^RACSignal *(CBLManager *manager) {
        NSCAssert(manager.rcl_isOnScheduler, @"not on correct scheduler");
        return [manager rcl_databaseNamed:name];
    }];
}

+ (RACSignal *)rcl_existingDatabaseNamed:(NSString *)name {
    return [[self rcl_sharedInstance]
    flattenMap:^RACSignal *(CBLManager *manager) {
        NSCAssert(manager.rcl_isOnScheduler, @"not on correct scheduler");
        return [manager rcl_existingDatabaseNamed:name];
    }];
}

- (RACSignal *)rcl_databaseNamed:(NSString *)name {
    @weakify(self)
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        [self.rcl_scheduler schedule:^{
            @strongify(self)
            NSError *error = nil;
            CBLDatabase *database = [self databaseNamed:name error:&error];
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
    @weakify(self)
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        [self.rcl_scheduler schedule:^{
            @strongify(self)
            NSError *error = nil;
            CBLDatabase *database = [self existingDatabaseNamed:name error:&error];
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

- (RACScheduler *)rcl_scheduler {
    RACScheduler *result = (RACScheduler *)objc_getAssociatedObject(self, &CBLManagerAssociatedSchedulerKey);
    NSCAssert(result != nil, @"manager does not have scheduler property set");
    return result;
}

- (BOOL)rcl_isOnScheduler {
    return [self.rcl_scheduler isEqual:[RACScheduler currentScheduler]];
}

@end
