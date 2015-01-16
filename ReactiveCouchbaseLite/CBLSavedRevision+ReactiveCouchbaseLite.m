//
//  CBLSavedRevision+ReactiveCouchbaseLite.m
//  ReactiveCouchbaseLite
//
//  Created by Nathan Douglas on 12/4/14.
//  Released into the public domain.
//  See LICENSE for details.
//

#import "CBLSavedRevision+ReactiveCouchbaseLite.h"
#import "ReactiveCouchbaseLite.h"

static inline CBLSavedRevision *RCLCurrentOrNewSavedRevision(CBLSavedRevision *current) {
    __block CBLSavedRevision *result = nil;
    if (!current.rcl_isOnScheduler) {
        result = [RCLCurrentOrNewDocument(current.document) revisionWithID:current.revisionID];
    } else {
        result = current;
    }
    return result;
}

@implementation CBLSavedRevision (ReactiveCouchbaseLite)

- (RACSignal *)rcl_getRevisionHistory {
    CBLSavedRevision *revision = RCLCurrentOrNewSavedRevision(self);
    @weakify(revision)
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(revision)
        @weakify(revision)
        [revision.rcl_scheduler schedule:^{
            @strongify(revision)
            NSCAssert(revision.rcl_isOnScheduler, @"not on correct scheduler");
            NSError *error = nil;
            NSArray *history = [revision getRevisionHistory:&error];
            if (history) {
                [subscriber sendNext:history];
            } else {
                [subscriber sendError:error];
            }
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@ -rcl_getRevisionHistory]", self];
}

- (RACSignal *)rcl_attachmentNamed:(NSString *)name {
    CBLSavedRevision *revision = RCLCurrentOrNewSavedRevision(self);
    @weakify(revision)
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(revision)
        @weakify(revision)
        [revision.rcl_scheduler schedule:^{
            @strongify(revision)
            NSCAssert(revision.rcl_isOnScheduler, @"not on correct scheduler");
            CBLAttachment *attachment = [revision attachmentNamed:name];
            if (attachment) {
                [subscriber sendNext:attachment];
            } else {
                [subscriber sendError:RCLErrorWithCode(RCLErrorCode_AttachmentCouldNotBeFound)];
            }
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@ -rcl_attachmentNamed: %@]", self, name];
}

- (RACSignal *)rcl_createRevision {
    CBLSavedRevision *revision = RCLCurrentOrNewSavedRevision(self);
    @weakify(revision)
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(revision)
        @weakify(revision)
        [revision.rcl_scheduler schedule:^{
            @strongify(revision)
            NSCAssert(revision.rcl_isOnScheduler, @"not on correct scheduler");
            [subscriber sendNext:[revision createRevision]];
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@ -rcl_createRevision]", self];
}

- (RACSignal *)rcl_createRevisionWithProperties:(NSDictionary *)properties {
    CBLSavedRevision *revision = RCLCurrentOrNewSavedRevision(self);
    @weakify(revision)
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(revision)
        @weakify(revision)
        [revision.rcl_scheduler schedule:^{
            @strongify(revision)
            NSCAssert(revision.rcl_isOnScheduler, @"not on correct scheduler");
            NSError *error = nil;
            CBLSavedRevision *newRevision = [revision createRevisionWithProperties:properties error:&error];
            if (newRevision) {
                [subscriber sendNext:newRevision];
            } else {
                [subscriber sendError:error];
            }
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@ -rcl_createRevisionWithProperties: %@]", self, properties];
}

- (RACSignal *)rcl_delete {
    CBLSavedRevision *revision = RCLCurrentOrNewSavedRevision(self);
    @weakify(revision)
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(revision)
        @weakify(revision)
        [revision.rcl_scheduler schedule:^{
            @strongify(revision)
            NSCAssert(revision.rcl_isOnScheduler, @"not on correct scheduler");
            NSError *error = nil;
            CBLSavedRevision *newRevision = [self deleteDocument:&error];
            if (newRevision) {
                [subscriber sendNext:newRevision];
            } else {
                [subscriber sendError:error];
            }
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@ -rcl_delete]", self];
}

@end
