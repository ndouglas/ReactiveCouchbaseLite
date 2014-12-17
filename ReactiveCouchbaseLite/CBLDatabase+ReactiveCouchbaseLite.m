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

- (RACSignal *)rcl_lastSequenceNumber {
    RACSignal *result = RACObserve(self, lastSequenceNumber);
    return [result setNameWithFormat:@"[%@] -rcl_lastSequenceNumber", result.name];
}

- (RACSignal *)rcl_close {
    CBLDatabase *database = RCLCurrentOrNewDatabase(self);
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [database.rcl_scheduler schedule:^{
            NSCAssert(database.rcl_isOnScheduler, @"not on correct scheduler");
            NSError *error = nil;
            if (![database close:&error]) {
                [subscriber sendError:error];
            }
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@] -rcl_close", result.name];
}

- (RACSignal *)rcl_compact {
    CBLDatabase *database = RCLCurrentOrNewDatabase(self);
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [database.rcl_scheduler schedule:^{
            NSCAssert(database.rcl_isOnScheduler, @"not on correct scheduler");
            NSError *error = nil;
            if (![database compact:&error]) {
                [subscriber sendError:error];
            }
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@] -rcl_compact", result.name];
}

- (RACSignal *)rcl_delete {
    CBLDatabase *database = RCLCurrentOrNewDatabase(self);
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [database.rcl_scheduler schedule:^{
            NSCAssert(database.rcl_isOnScheduler, @"not on correct scheduler");
            NSError *error = nil;
            if (![database deleteDatabase:&error]) {
                [subscriber sendError:error];
            }
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@] -rcl_delete", result.name];
}

- (RACSignal *)rcl_documentWithID:(NSString *)documentID {
    CBLDatabase *database = RCLCurrentOrNewDatabase(self);
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [database.rcl_scheduler schedule:^{
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
    return [result setNameWithFormat:@"[%@] -rcl_documentWithID: %@", result.name, documentID];
}

- (RACSignal *)rcl_existingDocumentWithID:(NSString *)documentID {
    CBLDatabase *database = RCLCurrentOrNewDatabase(self);
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [database.rcl_scheduler schedule:^{
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
    return [result setNameWithFormat:@"[%@] -rcl_existingDocumentWithID: %@", result.name, documentID];
}

- (RACSignal *)rcl_existingDocumentWithID:(NSString *)documentID defaultProperties:(NSDictionary *)defaultProperties {
    CBLDatabase *database = RCLCurrentOrNewDatabase(self);
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [database.rcl_scheduler schedule:^{
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
    return [result setNameWithFormat:@"[%@] -rcl_existingDocumentWithID: %@", result.name, documentID];
}

- (RACSignal *)rcl_createDocument {
    CBLDatabase *database = RCLCurrentOrNewDatabase(self);
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [database.rcl_scheduler schedule:^{
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
    return [result setNameWithFormat:@"[%@] -rcl_createDocument", result.name];
}

- (RACSignal *)rcl_existingLocalDocumentWithID:(NSString *)documentID {
    CBLDatabase *database = RCLCurrentOrNewDatabase(self);
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [database.rcl_scheduler schedule:^{
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
    return [result setNameWithFormat:@"[%@] -rcl_existingLocalDocumentWithID: %@", result.name, documentID];
}

- (RACSignal *)rcl_putLocalDocumentWithProperties:(NSDictionary *)properties ID:(NSString *)documentID {
    CBLDatabase *database = RCLCurrentOrNewDatabase(self);
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [database.rcl_scheduler schedule:^{
            NSCAssert(database.rcl_isOnScheduler, @"not on correct scheduler");
            NSError *error = nil;
            if (![database putLocalDocument:properties withID:documentID error:&error]) {
                [subscriber sendError:error];
            }
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@] -rcl_putLocalDocumentWithProperties:%@ ID: %@", result.name, properties, documentID];
}

- (RACSignal *)rcl_deleteLocalDocumentWithID:(NSString *)documentID {
    CBLDatabase *database = RCLCurrentOrNewDatabase(self);
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [database.rcl_scheduler schedule:^{
            NSCAssert(database.rcl_isOnScheduler, @"not on correct scheduler");
            NSError *error = nil;
            if (![database deleteLocalDocumentWithID:documentID error:&error]) {
                [subscriber sendError:error];
            }
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@] -rcl_deleteLocalDocumentWithID: %@", result.name, documentID];
}

- (RACSignal *)rcl_allDocumentsQuery {
    CBLDatabase *database = RCLCurrentOrNewDatabase(self);
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [database.rcl_scheduler schedule:^{
            NSCAssert(database.rcl_isOnScheduler, @"not on correct scheduler");
            [subscriber sendNext:[database createAllDocumentsQuery]];
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@] -rcl_allDocumentsQuery", result.name];
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
    return [result setNameWithFormat:@"[%@] -rcl_allDocumentsQueryWithMode: %@", result.name, @(mode)];
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
    return [result setNameWithFormat:@"[%@] -rcl_allDocumentsQueryWithMode: %@ indexUpdateMode: %@", result.name, @(mode), @(indexUpdateMode)];
}

- (RACSignal *)rcl_allIncludingDeletedDocumentsQuery {
    return [self rcl_allDocumentsQueryWithMode:kCBLIncludeDeleted];
}

- (RACSignal *)rcl_slowQueryWithMap:(CBLMapBlock)block {
    CBLDatabase *database = RCLCurrentOrNewDatabase(self);
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [database.rcl_scheduler schedule:^{
            NSCAssert(database.rcl_isOnScheduler, @"not on correct scheduler");
            [subscriber sendNext:[database slowQueryWithMap:block]];
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@] -rcl_slowQueryWithMap: %@", result.name, block];
}

- (RACSignal *)rcl_viewNamed:(NSString *)name {
    CBLDatabase *database = RCLCurrentOrNewDatabase(self);
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [database.rcl_scheduler schedule:^{
            NSCAssert(database.rcl_isOnScheduler, @"not on correct scheduler");
            [subscriber sendNext:[database viewNamed:name]];
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@] -rcl_viewNamed: %@", result.name, name];
}

- (RACSignal *)rcl_existingViewNamed:(NSString *)name {
    CBLDatabase *database = RCLCurrentOrNewDatabase(self);
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [database.rcl_scheduler schedule:^{
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
    return [result setNameWithFormat:@"[%@] -rcl_existingViewNamed: %@", result.name, name];
}

- (RACSignal *)rcl_viewNamed:(NSString *)name mapBlock:(CBLMapBlock)mapBlock version:(NSString *)version {
    return [self rcl_viewNamed:name mapBlock:mapBlock reduceBlock:nil version:version];
}

- (RACSignal *)rcl_viewNamed:(NSString *)name mapBlock:(CBLMapBlock)mapBlock reduceBlock:(CBLReduceBlock)reduceBlock version:(NSString *)version {
    CBLDatabase *database = RCLCurrentOrNewDatabase(self);
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [database.rcl_scheduler schedule:^{
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
    return [result setNameWithFormat:@"[%@] -rcl_viewNamed: %@ mapBlock: %@ reduceBlock: %@ version: %@", result.name, name, mapBlock, reduceBlock, version];
}

- (RACSignal *)rcl_setValidationNamed:(NSString *)name asBlock:(CBLValidationBlock)block {
    CBLDatabase *database = RCLCurrentOrNewDatabase(self);
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [database.rcl_scheduler schedule:^{
            NSCAssert(database.rcl_isOnScheduler, @"not on correct scheduler");
            [database setValidationNamed:name asBlock:block];
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@] -rcl_setValidationNamed: %@ asBlock: %@", result.name, name, block];
}

- (RACSignal *)rcl_validationNamed:(NSString *)name {
    CBLDatabase *database = RCLCurrentOrNewDatabase(self);
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [database.rcl_scheduler schedule:^{
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
    return [result setNameWithFormat:@"[%@] -rcl_validationNamed: %@", result.name, name];
}

- (RACSignal *)rcl_setFilterNamed:(NSString *)name asBlock:(CBLFilterBlock)block {
    CBLDatabase *database = RCLCurrentOrNewDatabase(self);
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [database.rcl_scheduler schedule:^{
            NSCAssert(database.rcl_isOnScheduler, @"not on correct scheduler");
            [database setFilterNamed:name asBlock:block];
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@] -rcl_setFilterNamed: %@ asBlock: %@", result.name, name, block];
}

- (RACSignal *)rcl_filterNamed:(NSString *)name {
    CBLDatabase *database = RCLCurrentOrNewDatabase(self);
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [database.rcl_scheduler schedule:^{
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
    return [result setNameWithFormat:@"[%@] -rcl_filterNamed: %@", result.name, name];
}

- (RACSignal *)rcl_inTransaction:(BOOL (^)(CBLDatabase *database))block {
    CBLDatabase *database = RCLCurrentOrNewDatabase(self);
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [database.rcl_scheduler schedule:^{
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
    return [result setNameWithFormat:@"[%@] -rcl_inTransaction: %@", result.name, block];
}

- (RACSignal *)rcl_doAsync:(void (^)(void))block {
    CBLDatabase *database = RCLCurrentOrNewDatabase(self);
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [database.rcl_scheduler schedule:^{
            NSCAssert(database.rcl_isOnScheduler, @"not on correct scheduler");
            [database doAsync:block];
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@] -rcl_doAsync: %@ ", result.name, block];
}

- (RACSignal *)rcl_allReplications {
    RACSignal *result = [RACObserve(self, allReplications)
    takeUntil:self.rac_willDeallocSignal];
    return [result setNameWithFormat:@"[%@] -rcl_allReplications", result.name];
}

- (RACSignal *)rcl_createPushReplication:(NSURL *)URL {
    CBLDatabase *database = RCLCurrentOrNewDatabase(self);
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [database.rcl_scheduler schedule:^{
            NSCAssert(database.rcl_isOnScheduler, @"not on correct scheduler");
            [subscriber sendNext:[database createPushReplication:URL]];
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@] -rcl_createPushReplication: %@", result.name, URL];
}

- (RACSignal *)rcl_createPullReplication:(NSURL *)URL {
    CBLDatabase *database = RCLCurrentOrNewDatabase(self);
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [database.rcl_scheduler schedule:^{
            NSCAssert(database.rcl_isOnScheduler, @"not on correct scheduler");
            [subscriber sendNext:[database createPullReplication:URL]];
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@] -rcl_createPullReplication: %@", result.name, URL];
}

- (RACSignal *)rcl_databaseChangeNotifications {
    CBLDatabase *database = RCLCurrentOrNewDatabase(self);
	RACSignal *result = [[[[[NSNotificationCenter defaultCenter]
    rac_addObserverForName:kCBLDatabaseChangeNotification object:database]
    takeUntil:database.rac_willDeallocSignal]
	map:^RACSignal *(NSNotification *notification) {
		RACSignal *result = ((NSArray *)notification.userInfo[@"changes"]).rac_sequence.signal;
		return result;
	}]
	flatten];
    return [result setNameWithFormat:@"[%@] -rcl_databaseChangeNotifications", result.name];
}

- (RACSignal *)rcl_deleteDocumentWithID:(NSString *)documentID {
    CBLDatabase *database = RCLCurrentOrNewDatabase(self);
    RACSignal *result = [[[database rcl_existingDocumentWithID:documentID]
    catchTo:[RACSignal empty]]
    flattenMap:^RACSignal *(CBLDocument *document) {
        return [document rcl_delete];
    }];
    return [result setNameWithFormat:@"[%@] -rcl_deleteDocumentWithID: %@", result.name, documentID];
}

- (RACSignal *)rcl_markAsDeletedDocumentWithID:(NSString *)documentID {
    CBLDatabase *database = RCLCurrentOrNewDatabase(self);
    RACSignal *result = [[[database rcl_existingDocumentWithID:documentID]
    catchTo:[RACSignal empty]]
    flattenMap:^RACSignal *(CBLDocument *document) {
        return [document rcl_update:^BOOL(CBLUnsavedRevision *unsavedRevision) {
            unsavedRevision.properties[@"_deleted"] = @YES;
            return YES;
        }];
    }];
    return [result setNameWithFormat:@"[%@] -rcl_markAsDeletedDocumentWithID: %@", result.name, documentID];
}

- (RACSignal *)rcl_markAsDeletedDocumentWithID:(NSString *)documentID additionalProperties:(NSDictionary *)additionalProperties {
    CBLDatabase *database = RCLCurrentOrNewDatabase(self);
    RACSignal *result = [[[database rcl_existingDocumentWithID:documentID]
    catchTo:[RACSignal empty]]
    flattenMap:^RACSignal *(CBLDocument *document) {
        return [document rcl_update:^BOOL(CBLUnsavedRevision *unsavedRevision) {
            unsavedRevision.properties[@"_deleted"] = @YES;
            [unsavedRevision.properties addEntriesFromDictionary:additionalProperties];
            return YES;
        }];
    }];
    return [result setNameWithFormat:@"[%@] -rcl_markAsDeletedDocumentWithID: %@ additionalProperties: %@", result.name, documentID, additionalProperties];
}

- (RACSignal *)rcl_onDocumentWithID:(NSString *)ID performBlock:(void (^)(CBLDocument *document))block {
    CBLDatabase *database = RCLCurrentOrNewDatabase(self);
    block([database documentWithID:ID]);
    RACSignal *result = [RACSignal empty];
    return [result setNameWithFormat:@"[%@] -rcl_onDocumentWithID: %@ performBlock: %@", result.name, ID, block];
}

- (RACSignal *)rcl_updateDocumentWithID:(NSString *)ID block:(BOOL(^)(CBLUnsavedRevision *unsavedRevision))block {
    CBLDatabase *database = RCLCurrentOrNewDatabase(self);
    RACSignal *result = [[database documentWithID:ID] rcl_update:block];
    return [result setNameWithFormat:@"[%@] -rcl_updateDocumentWithID: %@ block: %@", result.name, ID, block];
}

- (RACSignal *)rcl_updateLocalDocumentWithID:(NSString *)ID block:(NSDictionary *(^)(NSMutableDictionary *localDocument))block {
    CBLDatabase *database = RCLCurrentOrNewDatabase(self);
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [database.rcl_scheduler schedule:^{
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
    return [result setNameWithFormat:@"[%@] -rcl_updateLocalDocumentWithID: %@ block: %@", result.name, ID, block];
}

- (RACScheduler *)rcl_scheduler {
    return self.manager.rcl_scheduler;
}

- (BOOL)rcl_isOnScheduler {
    return self.manager.rcl_isOnScheduler;
}

@end
