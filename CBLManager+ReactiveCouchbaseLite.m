//
//  CBLManager+ReactiveCouchbaseLite.m
//  ReactiveCouchbaseLite
//
//  Created by Nathan Douglas on 11/19/14.
//  Released into the public domain.
//  See LICENSE for details.
//

#import "CBLManager+ReactiveCouchbaseLite.h"
#import "ReactiveCouchbaseLite.h"
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
        static CBLManager *backgroundManager = nil;
        static dispatch_once_t predicate = 0;
        dispatch_once(&predicate, ^{
            backgroundManager = [[CBLManager sharedInstance] copy];
            NSString *description = result.description;
            dispatch_queue_t queue = dispatch_queue_create(description.UTF8String, DISPATCH_QUEUE_SERIAL);
            backgroundManager.dispatchQueue = queue;
            RACScheduler *scheduler = [[RACQueueScheduler alloc] initWithName:description queue:queue];
            [backgroundManager rcl_setScheduler:scheduler];
        });
        if (!current || !current.rcl_isOnScheduler) {
            result = backgroundManager;
        } else {
            result = current;
        }
    }
    return result;
}

@implementation CBLManager (ReactiveCouchbaseLite)

+ (RACSignal *)rcl_manager {
    __block CBLManager *manager = RCLSharedInstanceCurrentOrNewManager(nil);
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [manager.rcl_scheduler rcl_runOrScheduleBlock:^{
                [subscriber sendNext:manager];
                [subscriber sendCompleted];
            }];
            return nil;
        }]
        setNameWithFormat:@"[%@ +rcl_sharedInstance]", self];
}

+ (RACSignal *)rcl_log {
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [self redirectLogging:^(NSString *type, NSString *message) {
            [subscriber sendNext:RACTuplePack(type, message)];
        }];
        return [RACDisposable disposableWithBlock:^{
            [self redirectLogging:nil];
        }];
    }];
    return [result setNameWithFormat:@"[%@ +rcl_logSignal]", self];
}

+ (RACSignal *)rcl_databaseNamed:(NSString *)name {
    RACSignal *result = [[self rcl_manager]
    flattenMap:^RACSignal *(CBLManager *manager) {
        NSCAssert(manager.rcl_isOnScheduler, @"not on correct scheduler");
        return [manager rcl_databaseNamed:name];
    }];
    return [result setNameWithFormat:@"[%@ +rcl_databaseNamed: %@]", self, name];
}

+ (RACSignal *)rcl_existingDatabaseNamed:(NSString *)name {
    RACSignal *result = [[self rcl_manager]
    flattenMap:^RACSignal *(CBLManager *manager) {
        NSCAssert(manager.rcl_isOnScheduler, @"not on correct scheduler");
        return [manager rcl_existingDatabaseNamed:name];
    }];
    return [result setNameWithFormat:@"[%@ +rcl_existingDatabaseNamed: %@]", self, name];
}

- (RACSignal *)rcl_databaseNamed:(NSString *)name {
    CBLManager *manager = RCLSharedInstanceCurrentOrNewManager(self);
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [manager.rcl_scheduler rcl_runOrScheduleBlock:^{
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
    return [result setNameWithFormat:@"[%@ -rcl_databaseNamed: %@]", self, name];
}

- (RACSignal *)rcl_existingDatabaseNamed:(NSString *)name {
    CBLManager *manager = RCLSharedInstanceCurrentOrNewManager(self);
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [manager.rcl_scheduler rcl_runOrScheduleBlock:^{
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
    return [result setNameWithFormat:@"[%@ -rcl_existingDatabaseNamed: %@]", self, name];
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
