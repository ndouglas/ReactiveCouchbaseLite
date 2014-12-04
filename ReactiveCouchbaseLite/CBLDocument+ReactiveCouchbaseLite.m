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
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSError *error = nil;
        if (![self deleteDocument:&error]) {
            [subscriber sendError:error];
        }
        [subscriber sendCompleted];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@] -rcl_delete", result.name];
}

- (RACSignal *)rcl_purge {
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSError *error = nil;
        if (![self purgeDocument:&error]) {
            [subscriber sendError:error];
        }
        [subscriber sendCompleted];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@] -rcl_purge", result.name];
}

- (RACSignal *)rcl_documentChangeNotifications {
	RACSignal *result = [[[[NSNotificationCenter defaultCenter]
    rac_addObserverForName:kCBLDocumentChangeNotification object:self]
    takeUntil:self.rac_willDeallocSignal]
	map:^CBLDatabaseChange *(NSNotification *notification) {
		return (CBLDatabaseChange *)notification.userInfo[@"change"];
	}];
    return [result setNameWithFormat:@"[%@] -rcl_documentChangeNotifications", result.name];
}

- (RACSignal *)rcl_currentRevisionID {
    RACSignal *result = [[[self rcl_documentChangeNotifications]
	map:^NSString *(CBLDatabaseChange *change) {
		return change.revisionID;
	}]
    startWith:[self currentRevisionID]];
    return [result setNameWithFormat:@"[%@] -rcl_currentRevisionID", result.name];
}

- (RACSignal *)rcl_currentRevision {
    RACSignal *result = [[[self rcl_currentRevisionID]
	map:^RACSignal *(NSString *revisionID) {
        return [self rcl_revisionWithID:revisionID];
    }]
    switchToLatest];
    return [result setNameWithFormat:@"[%@] -rcl_currentRevision", result.name];
}

- (RACSignal *)rcl_revisionWithID:(NSString *)revisionID {
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        CBLRevision *revision = [self revisionWithID:revisionID];
        if (revision) {
            [subscriber sendNext:revision];
        } else {
            [subscriber sendError:RCLErrorWithCode(RCLErrorCode_RevisionCouldNotBeFound)];
        }
        [subscriber sendCompleted];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@] -rcl_revisionWithID: %@", result.name, revisionID];
}

- (RACSignal *)rcl_getRevisionHistory {
    RACSignal *result = [[self rcl_currentRevision]
    map:^RACSignal *(CBLRevision *revision) {
        return [revision rcl_getRevisionHistory];
    }];
    return [result setNameWithFormat:@"[%@] -rcl_getRevisionHistory", result.name];
}

- (RACSignal *)rcl_getRevisionHistoryFilteredWithBlock:(BOOL (^)(CBLSavedRevision *revision))block {
    RACSignal *result = [[[self rcl_getRevisionHistory]
    map:^NSArray *(NSArray *revisionList) {
        return [[revisionList.rac_sequence filter:block] array];
    }]
    distinctUntilChanged];
    return [result setNameWithFormat:@"[%@] -rcl_getRevisionHistoryFilteredWithBlock: %@", result.name, block];
}

- (RACSignal *)rcl_getConflictingRevisions {
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSError *error = nil;
        NSArray *revisions = [self getConflictingRevisions:&error];
        if (revisions) {
            [subscriber sendNext:revisions];
        } else {
            [subscriber sendError:error];
        }
        [subscriber sendCompleted];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@] -rcl_getConflictingRevisions", result.name];
}

- (RACSignal *)rcl_getLeafRevisions {
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSError *error = nil;
        NSArray *revisions = [self getLeafRevisions:&error];
        if (revisions) {
            [subscriber sendNext:revisions];
        } else {
            [subscriber sendError:error];
        }
        [subscriber sendCompleted];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@] -rcl_getLeafRevisions", result.name];
}

- (RACSignal *)rcl_newRevision {
    RACSignal *result = [RACSignal return:[self newRevision]];
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
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSError *error = nil;
        CBLSavedRevision *revision = [self putProperties:properties error:&error];
        if (revision) {
            [subscriber sendNext:revision];
        } else {
            [subscriber sendError:error];
        }
        [subscriber sendCompleted];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@] -rcl_putProperties: %@", result.name, properties];
}

- (RACSignal *)rcl_update:(BOOL(^)(CBLUnsavedRevision *))block {
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSError *error = nil;
        CBLSavedRevision *revision = [self update:block error:&error];
        if (revision) {
            [subscriber sendNext:revision];
        } else {
            [subscriber sendError:error];
        }
        [subscriber sendCompleted];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@] -rcl_update: %@", result.name, block];
}

@end
