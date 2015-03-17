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
        result = [RCLCurrentOrNewDatabase(current.database) documentWithID:current.documentID];
    } else {
        result = current;
    }
    return result;
}

@implementation CBLDocument (ReactiveCouchbaseLite)

- (RACSignal *)rcl_delete {
    CBLDocument *document = RCLCurrentOrNewDocument(self);
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [document.rcl_scheduler rcl_runOrScheduleBlock:^{
            NSCAssert(document.rcl_isOnScheduler, @"not on correct scheduler");
            NSError *error = nil;
            NSDictionary *properties = document.properties;
            if (![document deleteDocument:&error]) {
                [subscriber sendError:error];
            } else {
                [subscriber sendNext:properties];
            }
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@ -rcl_delete]", self];
}

- (RACSignal *)rcl_deletePreservingProperties {
    CBLDocument *document = RCLCurrentOrNewDocument(self);
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [document.rcl_scheduler rcl_runOrScheduleBlock:^{
            NSCAssert(document.rcl_isOnScheduler, @"not on correct scheduler");
            NSError *error = nil;
            CBLSavedRevision *savedDeletionRevision = [document update:^BOOL(CBLUnsavedRevision *deletionRevision) {
                deletionRevision.isDeletion = YES;
                return YES;
            } error:&error];
            if (savedDeletionRevision == nil) {
                [subscriber sendError:error];
            } else {
                [subscriber sendNext:savedDeletionRevision.properties];
            }
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@ -rcl_deletePreservingProperties]", self];
}

- (RACSignal *)rcl_deleteModifyingPropertiesWithBlock:(void(^)(CBLUnsavedRevision *proposedRevision))block {
    CBLDocument *document = RCLCurrentOrNewDocument(self);
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [document.rcl_scheduler rcl_runOrScheduleBlock:^{
            NSCAssert(document.rcl_isOnScheduler, @"not on correct scheduler");
            NSError *error = nil;
            CBLSavedRevision *savedDeletionRevision = [document update:^BOOL(CBLUnsavedRevision *deletionRevision) {
                block(deletionRevision);
                deletionRevision.isDeletion = YES;
                return YES;
            } error:&error];
            if (savedDeletionRevision == nil) {
                [subscriber sendError:error];
            } else {
                [subscriber sendNext:savedDeletionRevision.properties];
            }
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@ -rcl_deleteModifyingPropertiesWithBlock: %@]", self, block];
}

- (RACSignal *)rcl_purge {
    CBLDocument *document = RCLCurrentOrNewDocument(self);
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [document.rcl_scheduler rcl_runOrScheduleBlock:^{
            NSCAssert(document.rcl_isOnScheduler, @"not on correct scheduler");
            NSError *error = nil;
            if (![document purgeDocument:&error]) {
                [subscriber sendError:error];
            }
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@ -rcl_purge]", self];
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
    return [result setNameWithFormat:@"[%@ -rcl_documentChangeNotifications]", self];
}

- (RACSignal *)rcl_currentRevisionID {
    CBLDocument *document = RCLCurrentOrNewDocument(self);
    RACSignal *result = [[[document rcl_documentChangeNotifications]
	map:^NSString *(CBLDatabaseChange *change) {
        NSCAssert(document.rcl_isOnScheduler, @"not on correct scheduler");
		return change.revisionID;
	}]
    startWith:[document currentRevisionID]];
    return [result setNameWithFormat:@"[%@ -rcl_currentRevisionID]", self];
}

- (RACSignal *)rcl_currentRevision {
    CBLDocument *document = RCLCurrentOrNewDocument(self);
    RACSignal *result = [[[document rcl_currentRevisionID]
    ignore:nil]
	flattenMap:^RACSignal *(NSString *revisionID) {
        NSCAssert(document.rcl_isOnScheduler, @"not on correct scheduler");
        return [document rcl_revisionWithID:revisionID];
    }];
    return [result setNameWithFormat:@"[%@ -rcl_currentRevision]", self];
}

- (RACSignal *)rcl_revisionWithID:(NSString *)revisionID {
    CBLDocument *document = RCLCurrentOrNewDocument(self);
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [document.rcl_scheduler rcl_runOrScheduleBlock:^{
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
    return [result setNameWithFormat:@"[%@ -rcl_revisionWithID: %@]", self, revisionID];
}

- (RACSignal *)rcl_properties {
    CBLDocument *document = RCLCurrentOrNewDocument(self);
    RACSignal *result = [[RACObserve(document, properties)
    takeUntil:document.rac_willDeallocSignal]
    sample:[document rcl_documentChangeNotifications]];
    return [result setNameWithFormat:@"[%@ -rcl_properties]", self];
}

- (RACSignal *)rcl_userProperties {
    CBLDocument *document = RCLCurrentOrNewDocument(self);
    RACSignal *result = [[RACObserve(document, userProperties)
    takeUntil:document.rac_willDeallocSignal]
    sample:[document rcl_documentChangeNotifications]];
    return [result setNameWithFormat:@"[%@ -rcl_userProperties]", self];
}

- (RACSignal *)rcl_putProperties:(NSDictionary *)properties {
    CBLDocument *document = RCLCurrentOrNewDocument(self);
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [document.rcl_scheduler rcl_runOrScheduleBlock:^{
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
    return [result setNameWithFormat:@"[%@ -rcl_putProperties: %@]", self, properties];
}

- (RACSignal *)rcl_update:(BOOL(^)(CBLUnsavedRevision *))block {
    CBLDocument *document = RCLCurrentOrNewDocument(self);
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [document.rcl_scheduler rcl_runOrScheduleBlock:^{
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
    return [result setNameWithFormat:@"[%@ -rcl_update: %@]", self, block];
}

- (RACSignal *)rcl_resolveConflictsWithBlock:(NSDictionary *(^)(NSArray *conflictingRevisions))block {
    CBLDocument *document = RCLCurrentOrNewDocument(self);
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [document.rcl_scheduler rcl_runOrScheduleBlock:^{
            NSCAssert(document.rcl_isOnScheduler, @"not on correct scheduler");
            __block NSError *error = nil;
            __block NSDictionary *next = nil;
            BOOL success = [document.database inTransaction:^BOOL{
                NSArray *revisions = [document getConflictingRevisions:&error];
                BOOL result = YES;
                if (revisions.count > 1) {
                    NSDictionary *mergedProperties = block(revisions);
                    NSCAssert(mergedProperties, @"invalid merged properties");
                    CBLSavedRevision *currentRevision = document.currentRevision;
                    for (CBLSavedRevision *savedRevision in revisions) {
                        if (result) {
                            CBLUnsavedRevision *newRevision = [savedRevision createRevision];
                            if ([savedRevision isEqual:currentRevision]) {
                                newRevision.properties = mergedProperties.mutableCopy;
                            } else {
                                newRevision.isDeletion = YES;
                            }
                            CBLSavedRevision *savedRevision = [newRevision saveAllowingConflict:&error];
                            result = savedRevision != nil;
                            if (result) {
                                next = savedRevision.properties;
                            }
                        }
                    }
                }
                return result;
            }];
            if (!success) {
                [subscriber sendError:error];
            } else {
                [subscriber sendNext:next];
            }
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@ -rcl_resolveConflictsWithBlock: %@]", self, block];
}

- (RACScheduler *)rcl_scheduler {
    return self.database.rcl_scheduler;
}

- (BOOL)rcl_isOnScheduler {
    return self.database.rcl_isOnScheduler;
}

@end
