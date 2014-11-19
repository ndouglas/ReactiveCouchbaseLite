//
//  CBLDatabase+ReactiveCouchbaseLite.m
//  ReactiveCouchbaseLite
//
//  Created by Nathan Douglas on 11/18/14.
//  Released into the public domain.
//  See LICENSE for details.
//

#import "CBLDatabase+ReactiveCouchbaseLite.h"
#import "RACSignal+ReactiveCouchbaseLite.h"

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
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:[self createAllDocumentsQuery]];
        [subscriber sendCompleted];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@] -rcl_allDocumentsQuery", result.name];
}

- (RACSignal *)rcl_allDocumentsQueryWithMode:(CBLAllDocsMode)mode {
    RACSignal *result = [[self rcl_allDocumentsQuery]
    map:^CBLQuery *(CBLQuery *query) {
        query.allDocsMode = mode;
        return query;
    }];
    return [result setNameWithFormat:@"[%@] -rcl_allDocumentsQueryWithMode: %@", result.name, @(mode)];
}

- (RACSignal *)rcl_allDocumentsQueryWithMode:(CBLAllDocsMode)mode updateMode:(CBLIndexUpdateMode)updateMode {
    RACSignal *result = [[[self rcl_allDocumentsQuery]
    map:^CBLQuery *(CBLQuery *query) {
        query.allDocsMode = mode;
        return query;
    }]
    rcl_updateQueryIndexMode:updateMode];
    return [result setNameWithFormat:@"[%@] -rcl_allDocumentsQueryWithMode: %@ updateMode: %@", result.name, @(mode), @(updateMode)];
}

@end
