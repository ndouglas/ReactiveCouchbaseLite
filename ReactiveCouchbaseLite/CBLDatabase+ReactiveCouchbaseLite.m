//
//  CBLDatabase+ReactiveCouchbaseLite.m
//  ReactiveCouchbaseLite
//
//  Created by Nathan Douglas on 11/18/14.
//  Released into the public domain.
//  See LICENSE for details.
//

#import "CBLDatabase+ReactiveCouchbaseLite.h"

@implementation CBLDatabase (ReactiveCouchbaseLite)

- (RACSignal *)rcl_lastSequenceNumber {
    RACSignal *result = [RACObserve(self, lastSequenceNumber)
    takeUntil:self.rac_willDeallocSignal];
    return [result setNameWithFormat:@"[%@] -rcl_lastSequenceNumber", result.name];
}

- (RACSignal *)rcl_close {
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSError *error = nil;
        if (![self close:&error]) {
            [subscriber sendError:error];
        }
        [subscriber sendCompleted];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@] -rcl_close", result.name];
}

- (RACSignal *)rcl_compact {
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSError *error = nil;
        if (![self compact:&error]) {
            [subscriber sendError:error];
        }
        [subscriber sendCompleted];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@] -rcl_compact", result.name];
}

- (RACSignal *)rcl_delete {
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSError *error = nil;
        if (![self deleteDatabase:&error]) {
            [subscriber sendError:error];
        }
        [subscriber sendCompleted];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@] -rcl_delete", result.name];
}

- (RACSignal *)rcl_documentWithID:(NSString *)documentID {
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        CBLDocument *document = [self documentWithID:documentID];
        if (document) {
            [subscriber sendNext:document];
        } else {
            [subscriber sendError:RCLErrorWithCode(RCLErrorCode_DocumentCouldNotBeFoundOrCreated)];
        }
        [subscriber sendCompleted];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@] -rcl_documentWithID: %@", result.name, documentID];
}

- (RACSignal *)rcl_existingDocumentWithID:(NSString *)documentID {
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        CBLDocument *document = [self existingDocumentWithID:documentID];
        if (document) {
            [subscriber sendNext:document];
        } else {
            [subscriber sendError:RCLErrorWithCode(RCLErrorCode_DocumentCouldNotBeFound)];
        }
        [subscriber sendCompleted];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@] -rcl_existingDocumentWithID: %@", result.name, documentID];
}

- (RACSignal *)rcl_createDocument {
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        CBLDocument *document = [self createDocument];
        if (document) {
            [subscriber sendNext:document];
        } else {
            [subscriber sendError:RCLErrorWithCode(RCLErrorCode_DocumentCouldNotBeCreated)];
        }
        [subscriber sendCompleted];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@] -rcl_createDocument", result.name];
}

- (RACSignal *)rcl_existingLocalDocumentWithID:(NSString *)documentID {
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSDictionary *dictionary = [self existingLocalDocumentWithID:documentID];
        if (dictionary) {
            [subscriber sendNext:dictionary];
        } else {
            [subscriber sendError:RCLErrorWithCode(RCLErrorCode_LocalDocumentCouldNotBeFound)];
        }
        [subscriber sendCompleted];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@] -rcl_existingLocalDocumentWithID: %@", result.name, documentID];
}

- (RACSignal *)rcl_putLocalDocumentWithProperties:(NSDictionary *)properties ID:(NSString *)documentID {
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSError *error = nil;
        if (![self putLocalDocument:properties withID:documentID error:&error]) {
            [subscriber sendError:error];
        }
        [subscriber sendCompleted];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@] -rcl_putLocalDocumentWithProperties:%@ ID: %@", result.name, properties, documentID];
}

- (RACSignal *)rcl_deleteLocalDocumentWithID:(NSString *)documentID {
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSError *error = nil;
        if (![self deleteLocalDocumentWithID:documentID error:&error]) {
            [subscriber sendError:error];
        }
        [subscriber sendCompleted];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@] -rcl_deleteLocalDocumentWithID: %@", result.name, documentID];
}

- (RACSignal *)rcl_allDocumentsQuery {
    RACSignal *result = [RACSignal return:[self createAllDocumentsQuery]];
    return [result setNameWithFormat:@"[%@] -rcl_allDocumentsQuery", result.name];
}

- (RACSignal *)rcl_allDocumentsQueryWithMode:(CBLAllDocsMode)mode {
    RACSignal *result = [[self rcl_allDocumentsQuery]
    map:^CBLQuery *(CBLQuery *query) {
        CBLQuery *result = query.copy;
        result.allDocsMode = mode;
        return result;
    }];
    return [result setNameWithFormat:@"[%@] -rcl_allDocumentsQueryWithMode: %@", result.name, @(mode)];
}

- (RACSignal *)rcl_allDocumentsQueryWithMode:(CBLAllDocsMode)mode updateMode:(CBLIndexUpdateMode)updateMode {
    RACSignal *result = [[self rcl_allDocumentsQuery]
    map:^CBLQuery *(CBLQuery *query) {
        CBLQuery *result = query.copy;
        result.allDocsMode = mode;
        result.indexUpdateMode = updateMode;
        return result;
    }];
    return [result setNameWithFormat:@"[%@] -rcl_allDocumentsQueryWithMode: %@ updateMode: %@", result.name, @(mode), @(updateMode)];
}

- (RACSignal *)rcl_slowQueryWithMap:(CBLMapBlock)block {
    RACSignal *result = [RACSignal return:[self slowQueryWithMap:block]];
    return [result setNameWithFormat:@"[%@] -rcl_slowQueryWithMap: %@", result.name, block];
}

- (RACSignal *)rcl_viewNamed:(NSString *)name {
    RACSignal *result = [RACSignal return:[self viewNamed:name]];
    return [result setNameWithFormat:@"[%@] -rcl_viewNamed: %@", result.name, name];
}

- (RACSignal *)rcl_existingViewNamed:(NSString *)name {
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        CBLView *view = [self existingViewNamed:name];
        if (view) {
            [subscriber sendNext:view];
        } else {
            [subscriber sendError:RCLErrorWithCode(RCLErrorCode_ViewCouldNotBeFound)];
        }
        [subscriber sendCompleted];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@] -rcl_existingViewNamed: %@", result.name, name];
}

- (RACSignal *)rcl_setValidationNamed:(NSString *)name asBlock:(CBLValidationBlock)block {
    [self setValidationNamed:name asBlock:block];
    RACSignal *result = [RACSignal empty];
    return [result setNameWithFormat:@"[%@] -rcl_setValidationNamed: %@ asBlock: %@", result.name, name, block];
}

- (RACSignal *)rcl_validationNamed:(NSString *)name {
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        CBLValidationBlock block = [self validationNamed:name];
        if (block) {
            [subscriber sendNext:block];
        } else {
            [subscriber sendError:RCLErrorWithCode(RCLErrorCode_ValidationCouldNotBeFound)];
        }
        [subscriber sendCompleted];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@] -rcl_validationNamed: %@", result.name, name];
}

- (RACSignal *)rcl_setFilterNamed:(NSString *)name asBlock:(CBLFilterBlock)block {
    [self setFilterNamed:name asBlock:block];
    RACSignal *result = [RACSignal empty];
    return [result setNameWithFormat:@"[%@] -rcl_setFilterNamed: %@ asBlock: %@", result.name, name, block];
}

- (RACSignal *)rcl_filterNamed:(NSString *)name {
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        CBLFilterBlock block = [self filterNamed:name];
        if (block) {
            [subscriber sendNext:block];
        } else {
            [subscriber sendError:RCLErrorWithCode(RCLErrorCode_FilterCouldNotBeFound)];
        }
        [subscriber sendCompleted];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@] -rcl_filterNamed: %@", result.name, name];
}

- (RACSignal *)rcl_inTransaction:(BOOL (^)(void))block {
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        if (![self inTransaction:block]) {
            [subscriber sendError:RCLErrorWithCode(RCLErrorCode_TransactionWasNotCommitted)];
        }
        [subscriber sendCompleted];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@] -rcl_inTransaction: %@", result.name, block];
}

- (RACSignal *)rcl_doAsync:(void (^)(void))block {
    [self doAsync:block];
    RACSignal *result = [RACSignal empty];
    return [result setNameWithFormat:@"[%@] -rcl_doAsync: %@ ", result.name, block];
}

- (RACSignal *)rcl_doSync:(void (^)(void))block {
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [self doSync:block];
        [subscriber sendCompleted];
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
    RACSignal *result = [RACSignal return:[self createPushReplication:URL]];
    return [result setNameWithFormat:@"[%@] -rcl_createPushReplication: %@", result.name, URL];
}

- (RACSignal *)rcl_createPullReplication:(NSURL *)URL {
    RACSignal *result = [RACSignal return:[self createPullReplication:URL]];
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
