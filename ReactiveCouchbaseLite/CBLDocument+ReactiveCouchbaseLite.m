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

CBLDocument *RCLCurrentOrNewDocument(CBLDocument *current) {
    __block CBLDocument *result = nil;
    if (!current.rcl_isOnScheduler) {
        result = [RCLCurrentOrNewDatabase(current.database) existingDocumentWithID:current.documentID];
    } else {
        result = current;
    }
    return result;
}

@implementation CBLDocument (ReactiveCouchbaseLite)

- (RACSignal *)rcl_delete {
    CBLDocument *document = RCLCurrentOrNewDocument(self);
    @weakify(document)
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(document)
        @weakify(document)
        [document.rcl_scheduler schedule:^{
            @strongify(document)
            NSCAssert(document.rcl_isOnScheduler, @"not on correct scheduler");
            NSError *error = nil;
            if (![document deleteDocument:&error]) {
                [subscriber sendError:error];
            }
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@] -rcl_delete", result.name];
}

- (RACSignal *)rcl_purge {
    CBLDocument *document = RCLCurrentOrNewDocument(self);
    @weakify(document)
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(document)
        @weakify(document)
        [document.rcl_scheduler schedule:^{
            @strongify(document)
            NSCAssert(document.rcl_isOnScheduler, @"not on correct scheduler");
            NSError *error = nil;
            if (![document purgeDocument:&error]) {
                [subscriber sendError:error];
            }
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@] -rcl_purge", result.name];
}

- (RACSignal *)rcl_documentChangeNotifications {
    CBLDocument *document = RCLCurrentOrNewDocument(self);
	RACSignal *result = [[[[[NSNotificationCenter defaultCenter]
    rac_addObserverForName:kCBLDocumentChangeNotification object:document]
    takeUntil:document.rac_willDeallocSignal]
    deliverOn:document.rcl_scheduler]
	map:^CBLDatabaseChange *(NSNotification *notification) {
        NSCAssert(document.rcl_isOnScheduler, @"not on correct scheduler");
		return (CBLDatabaseChange *)notification.userInfo[@"change"];
	}];
    return [result setNameWithFormat:@"[%@] -rcl_documentChangeNotifications", result.name];
}

- (RACSignal *)rcl_currentRevisionID {
    CBLDocument *document = RCLCurrentOrNewDocument(self);
    @weakify(document)
    RACSignal *result = [[[document rcl_documentChangeNotifications]
	map:^NSString *(CBLDatabaseChange *change) {
        @strongify(document)
        NSCAssert(document.rcl_isOnScheduler, @"not on correct scheduler");
		return change.revisionID;
	}]
    startWith:[document currentRevisionID]];
    return [result setNameWithFormat:@"[%@] -rcl_currentRevisionID", result.name];
}

- (RACSignal *)rcl_currentRevision {
    CBLDocument *document = RCLCurrentOrNewDocument(self);
    @weakify(document)
    RACSignal *result = [[[document rcl_currentRevisionID]
    ignore:nil]
	flattenMap:^RACSignal *(NSString *revisionID) {
        @strongify(document)
        NSCAssert(document.rcl_isOnScheduler, @"not on correct scheduler");
        return [document rcl_revisionWithID:revisionID];
    }];
    return [result setNameWithFormat:@"[%@] -rcl_currentRevision", result.name];
}

- (RACSignal *)rcl_revisionWithID:(NSString *)revisionID {
    CBLDocument *document = RCLCurrentOrNewDocument(self);
    @weakify(document)
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(document)
        @weakify(document)
        [document.rcl_scheduler schedule:^{
            @strongify(document)
            NSCAssert(document.rcl_isOnScheduler, @"not on correct scheduler");
            CBLRevision *revision = [document revisionWithID:revisionID];
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
    CBLDocument *document = RCLCurrentOrNewDocument(self);
    @weakify(document)
    RACSignal *result = [[[[[document rcl_currentRevision]
    ignore:nil]
    map:^RACSignal *(CBLRevision *revision) {
        @strongify(document)
        NSCAssert(document.rcl_isOnScheduler, @"not on correct scheduler");
        return [revision rcl_getRevisionHistory];
    }]
    switchToLatest]
    startWith:[document getRevisionHistory:NULL]];
    return [result setNameWithFormat:@"[%@] -rcl_getRevisionHistory", result.name];
}

- (RACSignal *)rcl_getRevisionHistoryFilteredWithBlock:(BOOL (^)(CBLSavedRevision *revision))block {
    CBLDocument *document = RCLCurrentOrNewDocument(self);
    @weakify(document)
    RACSignal *result = [[[document rcl_getRevisionHistory]
    map:^NSArray *(NSArray *revisionList) {
        @strongify(document)
        NSCAssert(document.database.manager.rcl_isOnScheduler, @"not on correct scheduler");
        return [[revisionList.rac_sequence filter:block] array];
    }]
    distinctUntilChanged];
    return [result setNameWithFormat:@"[%@] -rcl_getRevisionHistoryFilteredWithBlock: %@", result.name, block];
}

- (RACSignal *)rcl_getConflictingRevisions {
    CBLDocument *document = RCLCurrentOrNewDocument(self);
    @weakify(document)
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(document)
        @weakify(document)
        [document.rcl_scheduler schedule:^{
            @strongify(document)
            NSCAssert(document.rcl_isOnScheduler, @"not on correct scheduler");
            NSError *error = nil;
            NSArray *revisions = [document getConflictingRevisions:&error];
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
    CBLDocument *document = RCLCurrentOrNewDocument(self);
    @weakify(document)
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(document)
        @weakify(document)
        [document.rcl_scheduler schedule:^{
            @strongify(document)
            NSCAssert(document.rcl_isOnScheduler, @"not on correct scheduler");
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
    CBLDocument *document = RCLCurrentOrNewDocument(self);
    @weakify(document)
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(document)
        @weakify(document)
        [document.rcl_scheduler schedule:^{
            @strongify(document)
            NSCAssert(document.rcl_isOnScheduler, @"not on correct scheduler");
            [subscriber sendNext:[document newRevision]];
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@] -rcl_newRevision", result.name];
}

- (RACSignal *)rcl_properties {
    CBLDocument *document = RCLCurrentOrNewDocument(self);
    RACSignal *result = [[RACObserve(document, properties)
    takeUntil:document.rac_willDeallocSignal]
    sample:[document rcl_documentChangeNotifications]];
    return [result setNameWithFormat:@"[%@] -rcl_properties", result.name];
}

- (RACSignal *)rcl_userProperties {
    CBLDocument *document = RCLCurrentOrNewDocument(self);
    RACSignal *result = [[RACObserve(document, userProperties)
    takeUntil:document.rac_willDeallocSignal]
    sample:[document rcl_documentChangeNotifications]];
    return [result setNameWithFormat:@"[%@] -rcl_userProperties", result.name];
}

- (RACSignal *)rcl_putProperties:(NSDictionary *)properties {
    CBLDocument *document = RCLCurrentOrNewDocument(self);
    @weakify(document)
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(document)
        @weakify(document)
        [document.rcl_scheduler schedule:^{
            @strongify(document)
            NSCAssert(document.rcl_isOnScheduler, @"not on correct scheduler");
            NSError *error = nil;
            CBLSavedRevision *revision = [document putProperties:properties error:&error];
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
    CBLDocument *document = RCLCurrentOrNewDocument(self);
    @weakify(document)
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(document)
        @weakify(document)
        [document.rcl_scheduler schedule:^{
            @strongify(document)
            NSCAssert(document.rcl_isOnScheduler, @"not on correct scheduler");
            NSError *error = nil;
            CBLSavedRevision *revision = [document update:block error:&error];
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
