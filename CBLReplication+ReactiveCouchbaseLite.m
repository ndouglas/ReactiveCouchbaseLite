//
//  CBLReplication+ReactiveCouchbaseLite.m
//  ReactiveCouchbaseLite
//
//  Created by Nathan Douglas on 12/4/14.
//  Released into the public domain.
//  See LICENSE for details.
//

#import "CBLReplication+ReactiveCouchbaseLite.h"
#import "ReactiveCouchbaseLite.h"

typedef NSDictionary *(^CBLPropertiesTransformationBlock)(NSDictionary *document);

@interface CBLReplication ()
@property (strong, nonatomic, readwrite) CBLPropertiesTransformationBlock propertiesTransformationBlock;
@end

@implementation CBLReplication (ReactiveCouchbaseLite)

- (RACSignal *)rcl_transferredDocuments {
    NSCAssert(!self.propertiesTransformationBlock, @"Only one properties transformation block can be used at a time.");
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [self setPropertiesTransformationBlock:^NSDictionary *(NSDictionary *document) {
            [subscriber sendNext:document];
            return document;
        }];
        [self restart];
        return [RACDisposable disposableWithBlock:^{
            [self setPropertiesTransformationBlock:nil];
            [self restart];
        }];
    }];
    return [result setNameWithFormat:@"[%@ -rcl_transferredDocuments]", self];
}

- (RACSignal *)rcl_lastError {
    RACSignal *result = [[RACObserve(self, lastError)
    ignore:nil]
    takeUntil:self.rac_willDeallocSignal];
    return [result setNameWithFormat:@"[%@ -rcl_lastError]", self];
}

- (RACSignal *)rcl_pendingPushDocumentIDs {
    NSCAssert(!self.pull, @"This method is unavailable on pull replications.");
    RACSignal *result = [[[[RACObserve(self, changesCount)
    map:^NSSet *(NSNumber *changesCount) {
        (void)changesCount;
        return [self pendingDocumentIDs];
    }]
    ignore:nil]
    combinePreviousWithStart:[NSSet set] reduce:^NSSet *(NSSet *previous, NSSet *current) {
        NSMutableSet *result = current.mutableCopy;
        [result minusSet:previous];
        return result;
    }]
    flattenMap:^RACSignal *(NSSet *newPendingDocumentIDs) {
        return newPendingDocumentIDs.rac_sequence.signal;
    }];
    return [result setNameWithFormat:@"[%@ -rcl_pendingPushDocumentIDs]", self];
}

- (RACSignal *)rcl_pendingPushDocuments {
    NSCAssert(!self.pull, @"This method is unavailable on pull replications.");
    RACSignal *result = [[self rcl_pendingPushDocumentIDs]
    flattenMap:^RACSignal *(NSString *pendingPushDocumentID) {
        return [self.localDatabase rcl_documentWithID:pendingPushDocumentID];
    }];
    return [result setNameWithFormat:@"[%@ -rcl_pendingPushDocuments]", self];
}

@end
