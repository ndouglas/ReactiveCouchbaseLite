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
    return [RACObserve(self, lastSequenceNumber)
    takeUntil:self.rac_willDeallocSignal];
}

- (RACSignal *)rcl_close {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSError *error = nil;
        if (![self close:&error]) {
            [subscriber sendError:error];
        }
        [subscriber sendCompleted];
        return nil;
    }];
}

- (RACSignal *)rcl_compact {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSError *error = nil;
        if (![self compact:&error]) {
            [subscriber sendError:error];
        }
        [subscriber sendCompleted];
        return nil;
    }];
}

- (RACSignal *)rcl_delete {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSError *error = nil;
        if (![self deleteDatabase:&error]) {
            [subscriber sendError:error];
        }
        [subscriber sendCompleted];
        return nil;
    }];
}

- (RACSignal *)rcl_documentWithID:(NSString *)documentID {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        CBLDocument *document = [self documentWithID:documentID];
        if (document) {
            [subscriber sendNext:document];
        } else {
            [subscriber sendError:RCLErrorWithCode(RCLErrorCode_DocumentCouldNotBeFoundOrCreated)];
        }
        [subscriber sendCompleted];
        return nil;
    }];
}

- (RACSignal *)rcl_existingDocumentWithID:(NSString *)documentID {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        CBLDocument *document = [self existingDocumentWithID:documentID];
        if (document) {
            [subscriber sendNext:document];
        } else {
            [subscriber sendError:RCLErrorWithCode(RCLErrorCode_DocumentCouldNotBeFound)];
        }
        [subscriber sendCompleted];
        return nil;
    }];
}

- (RACSignal *)rcl_createDocument {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        CBLDocument *document = [self createDocument];
        if (document) {
            [subscriber sendNext:document];
        } else {
            [subscriber sendError:RCLErrorWithCode(RCLErrorCode_DocumentCouldNotBeCreated)];
        }
        [subscriber sendCompleted];
        return nil;
    }];
}

- (RACSignal *)rcl_existingLocalDocumentWithID:(NSString *)documentID {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSDictionary *dictionary = [self existingLocalDocumentWithID:documentID];
        if (dictionary) {
            [subscriber sendNext:dictionary];
        } else {
            [subscriber sendError:RCLErrorWithCode(RCLErrorCode_LocalDocumentCouldNotBeFound)];
        }
        [subscriber sendCompleted];
        return nil;
    }];
}

- (RACSignal *)rcl_putLocalDocumentWithProperties:(NSDictionary *)properties ID:(NSString *)documentID {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSError *error = nil;
        if (![self putLocalDocument:properties withID:documentID error:&error]) {
            [subscriber sendError:error];
        }
        [subscriber sendCompleted];
        return nil;
    }];
}


@end
