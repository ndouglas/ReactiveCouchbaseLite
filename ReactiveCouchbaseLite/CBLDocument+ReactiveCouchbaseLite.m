//
//  CBLDocument+ReactiveCouchbaseLite.m
//  ReactiveCouchbaseLite
//
//  Created by Nathan Douglas on 12/4/14.
//  Released into the public domain.
//  See LICENSE for details.
//

#import "CBLDocument+ReactiveCouchbaseLite.h"
#import "ReactiveCouchbaseLite.h"

@implementation CBLDocument (ReactiveCouchbaseLite)

- (RACSignal *)rcl_delete {
    @weakify(self)
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        @weakify(self)
        [self.rcl_scheduler schedule:^{
            @strongify(self)
            NSCAssert(self.rcl_isOnScheduler, @"not on correct scheduler");
            NSError *error = nil;
            if (![self deleteDocument:&error]) {
                [subscriber sendError:error];
            }
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@] -rcl_delete", result.name];
}

- (RACSignal *)rcl_purge {
    @weakify(self)
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        @weakify(self)
        [self.rcl_scheduler schedule:^{
            @strongify(self)
            NSCAssert(self.rcl_isOnScheduler, @"not on correct scheduler");
            NSError *error = nil;
            if (![self purgeDocument:&error]) {
                [subscriber sendError:error];
            }
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@] -rcl_purge", result.name];
}

- (RACSignal *)rcl_documentChangeNotifications {
	RACSignal *result = [[[[[NSNotificationCenter defaultCenter]
    rac_addObserverForName:kCBLDocumentChangeNotification object:self]
    takeUntil:self.rac_willDeallocSignal]
    deliverOn:self.rcl_scheduler]
	map:^CBLDatabaseChange *(NSNotification *notification) {
        NSCAssert(self.rcl_isOnScheduler, @"not on correct scheduler");
		return (CBLDatabaseChange *)notification.userInfo[@"change"];
	}];
    return [result setNameWithFormat:@"[%@] -rcl_documentChangeNotifications", result.name];
}

- (RACSignal *)rcl_currentRevisionID {
    RACSignal *result = [[[self rcl_documentChangeNotifications]
	map:^NSString *(CBLDatabaseChange *change) {
        NSCAssert(self.rcl_isOnScheduler, @"not on correct scheduler");
		return change.revisionID;
	}]
    startWith:[self currentRevisionID]];
    return [result setNameWithFormat:@"[%@] -rcl_currentRevisionID", result.name];
}

- (RACSignal *)rcl_currentRevision {
    RACSignal *result = [[[self rcl_currentRevisionID]
    ignore:nil]
	flattenMap:^RACSignal *(NSString *revisionID) {
        NSCAssert(self.rcl_isOnScheduler, @"not on correct scheduler");
        return [self rcl_revisionWithID:revisionID];
    }];
    return [result setNameWithFormat:@"[%@] -rcl_currentRevision", result.name];
}

- (RACSignal *)rcl_revisionWithID:(NSString *)revisionID {
    @weakify(self)
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        @weakify(self)
        [self.rcl_scheduler schedule:^{
            @strongify(self)
            NSCAssert(self.rcl_isOnScheduler, @"not on correct scheduler");
            CBLRevision *revision = [self revisionWithID:revisionID];
            if (revision) {
                [subscriber sendNext:revision];
            } else {
                [subscriber sendError:RCLErrorWithCode(RCLErrorCode_RevisionCouldNotBeFound)];
            }
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@] -rcl_revisionWithID: %@", result.name, revisionID];
}

- (RACSignal *)rcl_getRevisionHistory {
    RACSignal *result = [[[[[self rcl_currentRevision]
    ignore:nil]
    map:^RACSignal *(CBLRevision *revision) {
        NSCAssert(self.rcl_isOnScheduler, @"not on correct scheduler");
        return [revision rcl_getRevisionHistory];
    }]
    switchToLatest]
    startWith:[self getRevisionHistory:NULL]];
    return [result setNameWithFormat:@"[%@] -rcl_getRevisionHistory", result.name];
}

- (RACSignal *)rcl_getRevisionHistoryFilteredWithBlock:(BOOL (^)(CBLSavedRevision *revision))block {
    RACSignal *result = [[[self rcl_getRevisionHistory]
    map:^NSArray *(NSArray *revisionList) {
        NSCAssert(self.database.manager.rcl_isOnScheduler, @"not on correct scheduler");
        return [[revisionList.rac_sequence filter:block] array];
    }]
    distinctUntilChanged];
    return [result setNameWithFormat:@"[%@] -rcl_getRevisionHistoryFilteredWithBlock: %@", result.name, block];
}

- (RACSignal *)rcl_getConflictingRevisions {
    @weakify(self)
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        @weakify(self)
        [self.rcl_scheduler schedule:^{
            @strongify(self)
            NSCAssert(self.rcl_isOnScheduler, @"not on correct scheduler");
            NSError *error = nil;
            NSArray *revisions = [self getConflictingRevisions:&error];
            if (revisions) {
                [subscriber sendNext:revisions];
            } else {
                [subscriber sendError:error];
            }
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@] -rcl_getConflictingRevisions", result.name];
}

- (RACSignal *)rcl_getLeafRevisions {
    @weakify(self)
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        @weakify(self)
        [self.rcl_scheduler schedule:^{
            @strongify(self)
            NSCAssert(self.rcl_isOnScheduler, @"not on correct scheduler");
            NSError *error = nil;
            NSArray *revisions = [self getLeafRevisions:&error];
            if (revisions) {
                [subscriber sendNext:revisions];
            } else {
                [subscriber sendError:error];
            }
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@] -rcl_getLeafRevisions", result.name];
}

- (RACSignal *)rcl_newRevision {
    @weakify(self)
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        @weakify(self)
        [self.rcl_scheduler schedule:^{
            @strongify(self)
            NSCAssert(self.rcl_isOnScheduler, @"not on correct scheduler");
            [subscriber sendNext:[self newRevision]];
        }];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@] -rcl_newRevision", result.name];
}

- (RACSignal *)rcl_properties {
    RACSignal *result = [[RACObserve(self, properties)
    takeUntil:self.rac_willDeallocSignal]
    sample:[self rcl_documentChangeNotifications]];
    return [result setNameWithFormat:@"[%@] -rcl_properties", result.name];
}

- (RACSignal *)rcl_userProperties {
    RACSignal *result = [[RACObserve(self, userProperties)
    takeUntil:self.rac_willDeallocSignal]
    sample:[self rcl_documentChangeNotifications]];
    return [result setNameWithFormat:@"[%@] -rcl_userProperties", result.name];
}

- (RACSignal *)rcl_putProperties:(NSDictionary *)properties {
    @weakify(self)
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        @weakify(self)
        [self.rcl_scheduler schedule:^{
            @strongify(self)
            NSCAssert(self.rcl_isOnScheduler, @"not on correct scheduler");
            NSError *error = nil;
            CBLSavedRevision *revision = [self putProperties:properties error:&error];
            if (revision) {
                [subscriber sendNext:revision];
            } else {
                [subscriber sendError:error];
            }
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@] -rcl_putProperties: %@", result.name, properties];
}

- (RACSignal *)rcl_update:(BOOL(^)(CBLUnsavedRevision *))block {
    @weakify(self)
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        @weakify(self)
        [self.rcl_scheduler schedule:^{
            @strongify(self)
            NSCAssert(self.rcl_isOnScheduler, @"not on correct scheduler");
            NSError *error = nil;
            CBLSavedRevision *revision = [self update:block error:&error];
            if (revision) {
                [subscriber sendNext:revision];
            } else {
                [subscriber sendError:error];
            }
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@] -rcl_update: %@", result.name, block];
}

- (RACScheduler *)rcl_scheduler {
    return self.database.rcl_scheduler;
}

- (BOOL)rcl_isOnScheduler {
    return self.database.rcl_isOnScheduler;
}

@end
