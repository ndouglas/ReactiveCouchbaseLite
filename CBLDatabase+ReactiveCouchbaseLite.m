//
//  CBLDatabase+ReactiveCouchbaseLite.m
//  ReactiveCouchbaseLite
//
//  Created by Nathan Douglas on 11/18/14.
//  Released into the public domain.
//  See LICENSE for details.
//

#import "CBLDatabase+ReactiveCouchbaseLite.h"
#import "ReactiveCouchbaseLite.h"

CBLDatabase *RCLCurrentOrNewDatabase(CBLDatabase *current) {
    __block CBLDatabase *result = nil;
    if (!current.rcl_isOnScheduler) {
        result = [RCLSharedInstanceCurrentOrNewManager(current.manager) existingDatabaseNamed:current.name error:NULL];
    } else {
        result = current;
    }
    return result;
}

@implementation CBLDatabase (ReactiveCouchbaseLite)

#pragma mark - Operations

- (RACSignal *)rcl_close {
    CBLDatabase *database = RCLCurrentOrNewDatabase(self);
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [database.rcl_scheduler rcl_runOrScheduleBlock:^{
            NSCAssert(database.rcl_isOnScheduler, @"not on correct scheduler");
            NSError *error = nil;
            if (![database close:&error]) {
                [subscriber sendError:error];
            }
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@ -rcl_close", self];
}

- (RACSignal *)rcl_compact {
    CBLDatabase *database = RCLCurrentOrNewDatabase(self);
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [database.rcl_scheduler rcl_runOrScheduleBlock:^{
            NSCAssert(database.rcl_isOnScheduler, @"not on correct scheduler");
            NSError *error = nil;
            if (![database compact:&error]) {
                [subscriber sendError:error];
            }
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@ -rcl_compact", self];
}

- (RACSignal *)rcl_delete {
    CBLDatabase *database = RCLCurrentOrNewDatabase(self);
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [database.rcl_scheduler rcl_runOrScheduleBlock:^{
            NSCAssert(database.rcl_isOnScheduler, @"not on correct scheduler");
            NSError *error = nil;
            if (![database deleteDatabase:&error]) {
                [subscriber sendError:error];
            }
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@ -rcl_delete", self];
}

#pragma mark - Documents

- (RACSignal *)rcl_documentWithID:(NSString *)documentID {
    CBLDatabase *database = RCLCurrentOrNewDatabase(self);
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [database.rcl_scheduler rcl_runOrScheduleBlock:^{
            NSCAssert(database.rcl_isOnScheduler, @"not on correct scheduler");
            CBLDocument *document = [database documentWithID:documentID];
            if (document) {
                [subscriber sendNext:document];
            } else {
                [subscriber sendError:RCLErrorWithCode(RCLErrorCode_DocumentCouldNotBeFoundOrCreated)];
            }
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@ -rcl_documentWithID: %@]", self, documentID];
}

- (RACSignal *)rcl_existingDocumentWithID:(NSString *)documentID {
    CBLDatabase *database = RCLCurrentOrNewDatabase(self);
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [database.rcl_scheduler rcl_runOrScheduleBlock:^{
            NSCAssert(database.rcl_isOnScheduler, @"not on correct scheduler");
            CBLDocument *document = [database existingDocumentWithID:documentID];
            if (document) {
                [subscriber sendNext:document];
            } else {
                [subscriber sendError:RCLErrorWithCode(RCLErrorCode_DocumentCouldNotBeFound)];
            }
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@ -rcl_existingDocumentWithID: %@]", self, documentID];
}

- (RACSignal *)rcl_existingDocumentWithID:(NSString *)documentID defaultProperties:(NSDictionary *)defaultProperties {
    CBLDatabase *database = RCLCurrentOrNewDatabase(self);
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [database.rcl_scheduler rcl_runOrScheduleBlock:^{
            NSCAssert(database.rcl_isOnScheduler, @"not on correct scheduler");
            CBLDocument *document = [database existingDocumentWithID:documentID];
            if (document) {
                [subscriber sendNext:document];
            } else {
                document = [database documentWithID:documentID];
                NSError *error = nil;
                CBLSavedRevision *revision = [document update:^BOOL(CBLUnsavedRevision *unsavedRevision) {
                    [unsavedRevision.properties addEntriesFromDictionary:defaultProperties];
                    return YES;
                } error:&error];
                if (revision) {
                    [subscriber sendNext:revision.document];
                } else {
                    [subscriber sendError:error];
                }
            }
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@ -rcl_existingDocumentWithID: %@]", self, documentID];
}

- (RACSignal *)rcl_createDocument {
    CBLDatabase *database = RCLCurrentOrNewDatabase(self);
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [database.rcl_scheduler rcl_runOrScheduleBlock:^{
            NSCAssert(database.rcl_isOnScheduler, @"not on correct scheduler");
            CBLDocument *document = [database createDocument];
            if (document) {
                [subscriber sendNext:document];
            } else {
                [subscriber sendError:RCLErrorWithCode(RCLErrorCode_DocumentCouldNotBeCreated)];
            }
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@ -rcl_createDocument", self];
}

#pragma mark - Local Documents

- (RACSignal *)rcl_existingLocalDocumentWithID:(NSString *)documentID {
    CBLDatabase *database = RCLCurrentOrNewDatabase(self);
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [database.rcl_scheduler rcl_runOrScheduleBlock:^{
            NSCAssert(database.rcl_isOnScheduler, @"not on correct scheduler");
            NSDictionary *dictionary = [database existingLocalDocumentWithID:documentID];
            if (dictionary) {
                [subscriber sendNext:dictionary];
            } else {
                [subscriber sendError:RCLErrorWithCode(RCLErrorCode_LocalDocumentCouldNotBeFound)];
            }
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@ -rcl_existingLocalDocumentWithID: %@]", self, documentID];
}

- (RACSignal *)rcl_putLocalDocumentWithProperties:(NSDictionary *)properties ID:(NSString *)documentID {
    CBLDatabase *database = RCLCurrentOrNewDatabase(self);
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [database.rcl_scheduler rcl_runOrScheduleBlock:^{
            NSCAssert(database.rcl_isOnScheduler, @"not on correct scheduler");
            NSError *error = nil;
            if (![database putLocalDocument:properties withID:documentID error:&error]) {
                [subscriber sendError:error];
            }
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@ -rcl_putLocalDocumentWithProperties: %@ ID: %@]", self, properties, documentID];
}

- (RACSignal *)rcl_deleteLocalDocumentWithID:(NSString *)documentID {
    CBLDatabase *database = RCLCurrentOrNewDatabase(self);
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [database.rcl_scheduler rcl_runOrScheduleBlock:^{
            NSCAssert(database.rcl_isOnScheduler, @"not on correct scheduler");
            NSError *error = nil;
            if (![database deleteLocalDocumentWithID:documentID error:&error]) {
                [subscriber sendError:error];
            }
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@ -rcl_deleteLocalDocumentWithID: %@]", self, documentID];
}

#pragma mark - All Documents Queries

- (RACSignal *)rcl_allDocumentsQuery {
    CBLDatabase *database = RCLCurrentOrNewDatabase(self);
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [database.rcl_scheduler rcl_runOrScheduleBlock:^{
            NSCAssert(database.rcl_isOnScheduler, @"not on correct scheduler");
            [subscriber sendNext:[database createAllDocumentsQuery]];
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@ -rcl_allDocumentsQuery", self];
}

- (RACSignal *)rcl_allDocumentsQueryWithMode:(CBLAllDocsMode)mode {
    CBLDatabase *database = RCLCurrentOrNewDatabase(self);
    RACSignal *result = [[database rcl_allDocumentsQuery]
    map:^CBLQuery *(CBLQuery *query) {
        NSCAssert(database.rcl_isOnScheduler, @"not on correct scheduler");
        CBLQuery *result = query;
        result.allDocsMode = mode;
        return result;
    }];
    return [result setNameWithFormat:@"[%@ -rcl_allDocumentsQueryWithMode: %@]", self, @(mode)];
}

- (RACSignal *)rcl_allDocumentsQueryWithMode:(CBLAllDocsMode)mode indexUpdateMode:(CBLIndexUpdateMode)indexUpdateMode {
    CBLDatabase *database = RCLCurrentOrNewDatabase(self);
    RACSignal *result = [[database rcl_allDocumentsQuery]
    map:^CBLQuery *(CBLQuery *query) {
        NSCAssert(database.rcl_isOnScheduler, @"not on correct scheduler");
        CBLQuery *result = query;
        result.allDocsMode = mode;
        result.indexUpdateMode = indexUpdateMode;
        return result;
    }];
    return [result setNameWithFormat:@"[%@ -rcl_allDocumentsQueryWithMode: %@ indexUpdateMode: %@]", self, @(mode), @(indexUpdateMode)];
}

- (RACSignal *)rcl_allIncludingDeletedDocumentsQuery {
    return [self rcl_allDocumentsQueryWithMode:kCBLIncludeDeleted];
}

- (RACSignal *)rcl_allConflictingDocumentsQuery {
    return [self rcl_allDocumentsQueryWithMode:kCBLShowConflicts];
}

- (RACSignal *)rcl_slowQueryWithMap:(CBLMapBlock)block {
    CBLDatabase *database = RCLCurrentOrNewDatabase(self);
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [database.rcl_scheduler rcl_runOrScheduleBlock:^{
            NSCAssert(database.rcl_isOnScheduler, @"not on correct scheduler");
            [subscriber sendNext:[database slowQueryWithMap:block]];
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@ -rcl_slowQueryWithMap: %@]", self, block];
}

#pragma mark - Views

- (RACSignal *)rcl_viewNamed:(NSString *)name {
    CBLDatabase *database = RCLCurrentOrNewDatabase(self);
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [database.rcl_scheduler rcl_runOrScheduleBlock:^{
            NSCAssert(database.rcl_isOnScheduler, @"not on correct scheduler");
            [subscriber sendNext:[database viewNamed:name]];
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@ -rcl_viewNamed: %@]", self, name];
}

- (RACSignal *)rcl_existingViewNamed:(NSString *)name {
    CBLDatabase *database = RCLCurrentOrNewDatabase(self);
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [database.rcl_scheduler rcl_runOrScheduleBlock:^{
            NSCAssert(database.rcl_isOnScheduler, @"not on correct scheduler");
            CBLView *view = [database existingViewNamed:name];
            if (view) {
                [subscriber sendNext:view];
            } else {
                [subscriber sendError:RCLErrorWithCode(RCLErrorCode_ViewCouldNotBeFound)];
            }
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@ -rcl_existingViewNamed: %@]", self, name];
}

- (RACSignal *)rcl_viewNamed:(NSString *)name mapBlock:(CBLMapBlock)mapBlock version:(NSString *)version {
    return [self rcl_viewNamed:name mapBlock:mapBlock reduceBlock:nil version:version];
}

- (RACSignal *)rcl_viewNamed:(NSString *)name mapBlock:(CBLMapBlock)mapBlock reduceBlock:(CBLReduceBlock)reduceBlock version:(NSString *)version {
    CBLDatabase *database = RCLCurrentOrNewDatabase(self);
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [database.rcl_scheduler rcl_runOrScheduleBlock:^{
            NSCAssert(database.rcl_isOnScheduler, @"not on correct scheduler");
            CBLView *view = [database viewNamed:name];
            if (!view.mapBlock || (reduceBlock && !view.reduceBlock)) {
                if (![view setMapBlock:mapBlock reduceBlock:reduceBlock version:version]) {
                    [subscriber sendError:RCLErrorWithCode(RCLErrorCode_ViewCouldNotBeUpdated)];
                } else {
                    [subscriber sendNext:view];
                }
            } else {
                [subscriber sendNext:view];
            }
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@ -rcl_viewNamed: %@ mapBlock: %@ reduceBlock: %@ version: %@]", self, name, mapBlock, reduceBlock, version];
}

#pragma mark - Validation

- (RACSignal *)rcl_setValidationNamed:(NSString *)name asBlock:(CBLValidationBlock)block {
    CBLDatabase *database = RCLCurrentOrNewDatabase(self);
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [database.rcl_scheduler rcl_runOrScheduleBlock:^{
            NSCAssert(database.rcl_isOnScheduler, @"not on correct scheduler");
            [database setValidationNamed:name asBlock:block];
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@ -rcl_setValidationNamed: %@ asBlock: %@]", self, name, block];
}

- (RACSignal *)rcl_validationNamed:(NSString *)name {
    CBLDatabase *database = RCLCurrentOrNewDatabase(self);
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [database.rcl_scheduler rcl_runOrScheduleBlock:^{
            NSCAssert(database.rcl_isOnScheduler, @"not on correct scheduler");
            CBLValidationBlock block = [database validationNamed:name];
            if (block) {
                [subscriber sendNext:block];
            } else {
                [subscriber sendError:RCLErrorWithCode(RCLErrorCode_ValidationCouldNotBeFound)];
            }
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@ -rcl_validationNamed: %@]", self, name];
}

#pragma mark - Filters

- (RACSignal *)rcl_setFilterNamed:(NSString *)name asBlock:(CBLFilterBlock)block {
    CBLDatabase *database = RCLCurrentOrNewDatabase(self);
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [database.rcl_scheduler rcl_runOrScheduleBlock:^{
            NSCAssert(database.rcl_isOnScheduler, @"not on correct scheduler");
            [database setFilterNamed:name asBlock:block];
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@ -rcl_setFilterNamed: %@ asBlock: %@]", self, name, block];
}

- (RACSignal *)rcl_filterNamed:(NSString *)name {
    CBLDatabase *database = RCLCurrentOrNewDatabase(self);
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [database.rcl_scheduler rcl_runOrScheduleBlock:^{
            NSCAssert(database.rcl_isOnScheduler, @"not on correct scheduler");
            CBLFilterBlock block = [database filterNamed:name];
            if (block) {
                [subscriber sendNext:block];
            } else {
                [subscriber sendError:RCLErrorWithCode(RCLErrorCode_FilterCouldNotBeFound)];
            }
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@ -rcl_filterNamed: %@]", self, name];
}

#pragma mark - Transactions

- (RACSignal *)rcl_inTransaction:(BOOL (^)(CBLDatabase *database))block {
    CBLDatabase *database = RCLCurrentOrNewDatabase(self);
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [database.rcl_scheduler rcl_runOrScheduleBlock:^{
            NSCAssert(database.rcl_isOnScheduler, @"not on correct scheduler");
            if (![database inTransaction:^BOOL {
                return block(database);
            }]) {
                [subscriber sendError:RCLErrorWithCode(RCLErrorCode_TransactionWasNotCommitted)];
            }
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@ -rcl_inTransaction: %@]", self, block];
}

#pragma mark - Asynchronous Operations

- (RACSignal *)rcl_doAsync:(void (^)(void))block {
    CBLDatabase *database = RCLCurrentOrNewDatabase(self);
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [database.rcl_scheduler rcl_runOrScheduleBlock:^{
            NSCAssert(database.rcl_isOnScheduler, @"not on correct scheduler");
            [database doAsync:block];
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@ -rcl_doAsync: %@]", self, block];
}

#pragma mark - Replications

- (RACSignal *)rcl_createPushReplication:(NSURL *)URL {
    CBLDatabase *database = RCLCurrentOrNewDatabase(self);
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [database.rcl_scheduler rcl_runOrScheduleBlock:^{
            NSCAssert(database.rcl_isOnScheduler, @"not on correct scheduler");
            [subscriber sendNext:[database createPushReplication:URL]];
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@ -rcl_createPushReplication: %@]", self, URL];
}

- (RACSignal *)rcl_createPullReplication:(NSURL *)URL {
    CBLDatabase *database = RCLCurrentOrNewDatabase(self);
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [database.rcl_scheduler rcl_runOrScheduleBlock:^{
            NSCAssert(database.rcl_isOnScheduler, @"not on correct scheduler");
            [subscriber sendNext:[database createPullReplication:URL]];
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@ -rcl_createPullReplication: %@]", self, URL];
}

#pragma mark - Notifications

- (RACSignal *)rcl_databaseChangeNotifications {
    CBLDatabase *database = RCLCurrentOrNewDatabase(self);
	RACSignal *result = [[[NSNotificationCenter defaultCenter]
    rac_addObserverForName:kCBLDatabaseChangeNotification object:database]
	flattenMap:^RACSignal *(NSNotification *notification) {
		RACSignal *result = ((NSArray *)notification.userInfo[@"changes"]).rac_sequence.signal;
		return result;
	}];
    return [result setNameWithFormat:@"[%@ -rcl_databaseChangeNotifications", self];
}

#pragma mark - Document Operations

- (RACSignal *)rcl_deleteDocumentWithID:(NSString *)documentID {
    CBLDatabase *database = RCLCurrentOrNewDatabase(self);
    RACSignal *result = [[[database rcl_existingDocumentWithID:documentID]
    catchTo:[RACSignal empty]]
    flattenMap:^RACSignal *(CBLDocument *document) {
        return [document rcl_delete];
    }];
    return [result setNameWithFormat:@"[%@ -rcl_deleteDocumentWithID: %@]", self, documentID];
}

- (RACSignal *)rcl_deletePreservingPropertiesDocumentWithID:(NSString *)documentID {
    CBLDatabase *database = RCLCurrentOrNewDatabase(self);
    RACSignal *result = [[[database rcl_existingDocumentWithID:documentID]
    catchTo:[RACSignal empty]]
    flattenMap:^RACSignal *(CBLDocument *document) {
        return [document rcl_deletePreservingProperties];
    }];
    return [result setNameWithFormat:@"[%@ -rcl_deletePreservingPropertiesDocumentWithID: %@]", self, documentID];
}

- (RACSignal *)rcl_deleteDocumentWithID:(NSString *)documentID modifyingPropertiesWithBlock:(void(^)(CBLUnsavedRevision *proposedRevision))block {
    CBLDatabase *database = RCLCurrentOrNewDatabase(self);
    RACSignal *result = [[[database rcl_existingDocumentWithID:documentID]
    catchTo:[RACSignal empty]]
    flattenMap:^RACSignal *(CBLDocument *document) {
        return [document rcl_deleteModifyingPropertiesWithBlock:block];
    }];
    return [result setNameWithFormat:@"[%@ -rcl_deleteDocumentWithID: %@ modifyingPropertiesWithBlock: %@]", self, documentID, block];
}

- (RACSignal *)rcl_onDocumentWithID:(NSString *)ID performBlock:(void (^)(CBLDocument *document))block {
    CBLDatabase *database = RCLCurrentOrNewDatabase(self);
    block([database documentWithID:ID]);
    RACSignal *result = [RACSignal empty];
    return [result setNameWithFormat:@"[%@ -rcl_onDocumentWithID: %@ performBlock: %@]", self, ID, block];
}

- (RACSignal *)rcl_updateDocumentWithID:(NSString *)ID block:(BOOL(^)(CBLUnsavedRevision *unsavedRevision))block {
    CBLDatabase *database = RCLCurrentOrNewDatabase(self);
    RACSignal *result = [[database documentWithID:ID] rcl_update:block];
    return [result setNameWithFormat:@"[%@ -rcl_updateDocumentWithID: %@ block: %@]", self, ID, block];
}

#pragma mark - Local Document Operations

- (RACSignal *)rcl_updateLocalDocumentWithID:(NSString *)ID block:(NSDictionary *(^)(NSMutableDictionary *localDocument))block {
    CBLDatabase *database = RCLCurrentOrNewDatabase(self);
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [database.rcl_scheduler rcl_runOrScheduleBlock:^{
            NSMutableDictionary *localDocument = [[self existingLocalDocumentWithID:ID] ?: @{} mutableCopy];
            NSError *error = nil;
            BOOL success = [self putLocalDocument:block(localDocument) withID:ID error:&error];
            if (!success) {
                [subscriber sendError:error];
            }
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@ -rcl_updateLocalDocumentWithID: %@ block: %@]", self, ID, block];
}

#pragma mark - Conflict Resolution

- (RACSignal *)rcl_resolveConflictsWithBlock:(NSDictionary *(^)(NSArray *conflictingRevisions))block {
    CBLDatabase *database = RCLCurrentOrNewDatabase(self);
    RACSignal *result = [[[[database rcl_allConflictingDocumentsQuery]
    flattenMap:^RACSignal *(CBLQuery *allConflictingDocumentsQuery) {
        return [[allConflictingDocumentsQuery asLiveQuery]
        rcl_changes];
    }]
    flattenMap:^RACSignal *(CBLQueryRow *row) {
        return [database rcl_documentWithID:row.documentID];
    }]
    flattenMap:^RACSignal *(CBLDocument *document) {
        return [document rcl_resolveConflictsWithBlock:block];
    }];
    return [result setNameWithFormat:@"[%@ -rcl_resolveConflictsWithBlock: %@]", self, block];
}

#pragma mark - Scheduler

- (RACScheduler *)rcl_scheduler {
    return self.manager.rcl_scheduler;
}

- (BOOL)rcl_isOnScheduler {
    return self.manager.rcl_isOnScheduler;
}

@end
