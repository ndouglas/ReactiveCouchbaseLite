//
//  CBLUnsavedRevision+ReactiveCouchbaseLite.m
//  ReactiveCouchbaseLite
//
//  Created by Nathan Douglas on 12/4/14.
//  Released into the public domain.
//  See LICENSE for details.
//

#import "CBLUnsavedRevision+ReactiveCouchbaseLite.h"
#import "ReactiveCouchbaseLite.h"

@implementation CBLUnsavedRevision (ReactiveCouchbaseLite)

- (RACSignal *)rcl_save {
    @weakify(self)
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        NSError *error = nil;
        CBLSavedRevision *revision = [self save:&error];
        if (revision) {
            [subscriber sendNext:revision];
        } else {
            [subscriber sendError:error];
        }
        [subscriber sendCompleted];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@] -rcl_save", result.name];
}

- (RACSignal *)rcl_saveAllowingConflict {
    @weakify(self)
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        NSError *error = nil;
        CBLSavedRevision *revision = [self saveAllowingConflict:&error];
        if (revision) {
            [subscriber sendNext:revision];
        } else {
            [subscriber sendError:error];
        }
        [subscriber sendCompleted];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@] -rcl_saveAllowingConflict", result.name];
}

- (RACSignal *)rcl_setAttachmentNamed:(NSString *)name withContentType:(NSString *)mimeType content:(NSData *)content {
    [self setAttachmentNamed:name withContentType:mimeType content:content];
    RACSignal *result = [RACSignal empty];
    return [result setNameWithFormat:@"[%@] -rcl_setAttachmentNamed: %@ withContentType: %@ content: %@", result.name, name, mimeType, content];
}

- (RACSignal *)rcl_setAttachmentNamed:(NSString *)name withContentType:(NSString *)mimeType contentURL:(NSURL *)fileURL {
    [self setAttachmentNamed:name withContentType:mimeType contentURL:fileURL];
    RACSignal *result = [RACSignal empty];
    return [result setNameWithFormat:@"[%@] -rcl_setAttachmentNamed: %@ withContentType: %@ contentURL: %@", result.name, name, mimeType, fileURL];
}

- (RACSignal *)rcl_removeAttachmentNamed:(NSString *)name {
    [self removeAttachmentNamed:name];
    RACSignal *result = [RACSignal empty];
    return [result setNameWithFormat:@"[%@] -rcl_removeAttachmentNamed: %@", result.name, name];
}

@end
