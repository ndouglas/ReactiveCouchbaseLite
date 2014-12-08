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

@implementation CBLDatabase (ReactiveCouchbaseLite)

- (RACSignal *)rcl_lastSequenceNumber {
    RACSignal *result = RACObserve(self, lastSequenceNumber);
    return [result setNameWithFormat:@"[%@] -rcl_lastSequenceNumber", result.name];
}

- (RACSignal *)rcl_close {
    @weakify(self)
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        @weakify(self)
        [self.manager.rcl_scheduler schedule:^{
            @strongify(self)
            NSError *error = nil;
            if (![self close:&error]) {
                [subscriber sendError:error];
            }
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@] -rcl_close", result.name];
}

- (RACSignal *)rcl_compact {
    @weakify(self)
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        @weakify(self)
        [self.manager.rcl_scheduler schedule:^{
            @strongify(self)
            NSError *error = nil;
            if (![self compact:&error]) {
                [subscriber sendError:error];
            }
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@] -rcl_compact", result.name];
}

- (RACSignal *)rcl_delete {
    @weakify(self)
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        @weakify(self)
        [self.manager.rcl_scheduler schedule:^{
            @strongify(self)
            NSError *error = nil;
            if (![self deleteDatabase:&error]) {
                [subscriber sendError:error];
            }
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@] -rcl_delete", result.name];
}

- (RACSignal *)rcl_documentWithID:(NSString *)documentID {
    @weakify(self)
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        @weakify(self)
        [self.manager.rcl_scheduler schedule:^{
            @strongify(self)
            CBLDocument *document = [self documentWithID:documentID];
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
    @weakify(self)
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        @weakify(self)
        [self.manager.rcl_scheduler schedule:^{
            @strongify(self)
            CBLDocument *document = [self existingDocumentWithID:documentID];
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

- (RACSignal *)rcl_createDocument {
    @weakify(self)
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        @weakify(self)
        [self.manager.rcl_scheduler schedule:^{
            @strongify(self)
            CBLDocument *document = [self createDocument];
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
    @weakify(self)
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        @weakify(self)
        [self.manager.rcl_scheduler schedule:^{
            @strongify(self)
            NSDictionary *dictionary = [self existingLocalDocumentWithID:documentID];
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
    @weakify(self)
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        [self.manager.rcl_scheduler schedule:^{
            NSError *error = nil;
            if (![self putLocalDocument:properties withID:documentID error:&error]) {
                [subscriber sendError:error];
            }
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@] -rcl_putLocalDocumentWithProperties:%@ ID: %@", result.name, properties, documentID];
}

- (RACSignal *)rcl_deleteLocalDocumentWithID:(NSString *)documentID {
    @weakify(self)
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        @weakify(self)
        [self.manager.rcl_scheduler schedule:^{
            @strongify(self)
            NSError *error = nil;
            if (![self deleteLocalDocumentWithID:documentID error:&error]) {
                [subscriber sendError:error];
            }
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@] -rcl_deleteLocalDocumentWithID: %@", result.name, documentID];
}

- (RACSignal *)rcl_allDocumentsQuery {
    @weakify(self)
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        @weakify(self)
        [self.manager.rcl_scheduler schedule:^{
            @strongify(self)
            //NSCAssert(self.manager.rcl_isOnScheduler, @"not on correct scheduler");
            [subscriber sendNext:[self createAllDocumentsQuery]];
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@] -rcl_allDocumentsQuery", result.name];
}

- (RACSignal *)rcl_allDocumentsQueryWithMode:(CBLAllDocsMode)mode {
    @weakify(self)
    RACSignal *result = [[self rcl_allDocumentsQuery]
    map:^CBLQuery *(CBLQuery *query) {
        @strongify(self)
        NSCAssert(self.manager.rcl_isOnScheduler, @"not on correct scheduler");
        CBLQuery *result = query;
        result.allDocsMode = mode;
        return result;
    }];
    return [result setNameWithFormat:@"[%@] -rcl_allDocumentsQueryWithMode: %@", result.name, @(mode)];
}

- (RACSignal *)rcl_allDocumentsQueryWithMode:(CBLAllDocsMode)mode indexUpdateMode:(CBLIndexUpdateMode)indexUpdateMode {
    @weakify(self)
    RACSignal *result = [[self rcl_allDocumentsQuery]
    map:^CBLQuery *(CBLQuery *query) {
        @strongify(self)
        NSCAssert(self.manager.rcl_isOnScheduler, @"not on correct scheduler");
        CBLQuery *result = query;
        result.allDocsMode = mode;
        result.indexUpdateMode = indexUpdateMode;
        return result;
    }];
    return [result setNameWithFormat:@"[%@] -rcl_allDocumentsQueryWithMode: %@ indexUpdateMode: %@", result.name, @(mode), @(indexUpdateMode)];
}

- (RACSignal *)rcl_slowQueryWithMap:(CBLMapBlock)block {
    @weakify(self)
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        @weakify(self)
        [self.manager.rcl_scheduler schedule:^{
            @strongify(self)
            [subscriber sendNext:[self slowQueryWithMap:block]];
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@] -rcl_slowQueryWithMap: %@", result.name, block];
}

- (RACSignal *)rcl_viewNamed:(NSString *)name {
    @weakify(self)
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        @weakify(self)
        [self.manager.rcl_scheduler schedule:^{
            @strongify(self)
            [subscriber sendNext:[self viewNamed:name]];
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@] -rcl_viewNamed: %@", result.name, name];
}

- (RACSignal *)rcl_existingViewNamed:(NSString *)name {
    @weakify(self)
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        @weakify(self)
        [self.manager.rcl_scheduler schedule:^{
            @strongify(self)
            NSCAssert(self.manager.rcl_isOnScheduler, @"not on correct scheduler");
            CBLView *view = [self existingViewNamed:name];
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

- (RACSignal *)rcl_setValidationNamed:(NSString *)name asBlock:(CBLValidationBlock)block {
    @weakify(self)
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        @weakify(self)
        [self.manager.rcl_scheduler schedule:^{
            @strongify(self)
            NSCAssert(self.manager.rcl_isOnScheduler, @"not on correct scheduler");
            [self setValidationNamed:name asBlock:block];
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@] -rcl_setValidationNamed: %@ asBlock: %@", result.name, name, block];
}

- (RACSignal *)rcl_validationNamed:(NSString *)name {
    @weakify(self)
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        @weakify(self)
        [self.manager.rcl_scheduler schedule:^{
            @strongify(self)
            NSCAssert(self.manager.rcl_isOnScheduler, @"not on correct scheduler");
            CBLValidationBlock block = [self validationNamed:name];
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
    @weakify(self)
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        @weakify(self)
        [self.manager.rcl_scheduler schedule:^{
            @strongify(self)
            NSCAssert(self.manager.rcl_isOnScheduler, @"not on correct scheduler");
            [self setFilterNamed:name asBlock:block];
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@] -rcl_setFilterNamed: %@ asBlock: %@", result.name, name, block];
}

- (RACSignal *)rcl_filterNamed:(NSString *)name {
    @weakify(self)
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        @weakify(self)
        [self.manager.rcl_scheduler schedule:^{
            @strongify(self)
            NSCAssert(self.manager.rcl_isOnScheduler, @"not on correct scheduler");
            CBLFilterBlock block = [self filterNamed:name];
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

- (RACSignal *)rcl_inTransaction:(BOOL (^)(void))block {
    @weakify(self)
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        @weakify(self)
        [self.manager.rcl_scheduler schedule:^{
            @strongify(self)
            NSCAssert(self.manager.rcl_isOnScheduler, @"not on correct scheduler");
            if (![self inTransaction:block]) {
                [subscriber sendError:RCLErrorWithCode(RCLErrorCode_TransactionWasNotCommitted)];
            }
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@] -rcl_inTransaction: %@", result.name, block];
}

- (RACSignal *)rcl_doAsync:(void (^)(void))block {
    @weakify(self)
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        @weakify(self)
        [self.manager.rcl_scheduler schedule:^{
            @strongify(self)
            NSCAssert(self.manager.rcl_isOnScheduler, @"not on correct scheduler");
            [self doAsync:block];
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
    @weakify(self)
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        @weakify(self)
        [self.manager.rcl_scheduler schedule:^{
            @strongify(self)
            NSCAssert(self.manager.rcl_isOnScheduler, @"not on correct scheduler");
            [subscriber sendNext:[self createPushReplication:URL]];
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@] -rcl_createPushReplication: %@", result.name, URL];
}

- (RACSignal *)rcl_createPullReplication:(NSURL *)URL {
    @weakify(self)
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        @weakify(self)
        [self.manager.rcl_scheduler schedule:^{
            @strongify(self)
            NSCAssert(self.manager.rcl_isOnScheduler, @"not on correct scheduler");
            [subscriber sendNext:[self createPullReplication:URL]];
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@] -rcl_createPullReplication: %@", result.name, URL];
}

- (RACSignal *)rcl_databaseChangeNotifications {
	RACSignal *result = [[[[[NSNotificationCenter defaultCenter]
    rac_addObserverForName:kCBLDatabaseChangeNotification object:self]
    takeUntil:self.rac_willDeallocSignal]
	map:^RACSignal *(NSNotification *notification) {
		RACSignal *result = ((NSArray *)notification.userInfo[@"changes"]).rac_sequence.signal;
		return result;
	}]
	flatten];
    return [result setNameWithFormat:@"[%@] -rcl_databaseChangeNotifications", result.name];
}

@end
