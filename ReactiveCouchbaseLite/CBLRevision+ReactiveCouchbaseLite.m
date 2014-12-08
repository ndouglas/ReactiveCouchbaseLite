//
//  CBLRevision+ReactiveCouchbaseLite.m
//  ReactiveCouchbaseLite
//
//  Created by Nathan Douglas on 12/4/14.
//  Released into the public domain.
//  See LICENSE for details.
//

#import "CBLRevision+ReactiveCouchbaseLite.h"
#import "ReactiveCouchbaseLite.h"

@implementation CBLRevision (ReactiveCouchbaseLite)

- (RACSignal *)rcl_getRevisionHistory {
    @weakify(self)
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        NSError *error = nil;
        NSArray *history = [self getRevisionHistory:&error];
        if (history) {
            [subscriber sendNext:history];
        } else {
            [subscriber sendError:error];
        }
        [subscriber sendCompleted];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@] -rcl_getRevisionHistory", result.name];
}

- (RACSignal *)rcl_attachmentNamed:(NSString *)name {
    @weakify(self)
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        CBLAttachment *attachment = [self attachmentNamed:name];
        if (attachment) {
            [subscriber sendNext:attachment];
        } else {
            [subscriber sendError:RCLErrorWithCode(RCLErrorCode_AttachmentCouldNotBeFound)];
        }
        [subscriber sendCompleted];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@] -rcl_attachmentNamed: %@", result.name, name];
}

- (RACScheduler *)rcl_scheduler {
    return self.document.rcl_scheduler;
}

- (BOOL)rcl_isOnScheduler {
    return self.document.rcl_isOnScheduler;
}

@end
