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

@interface CBLReplication (Transformation)
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
        return nil;
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
    RACSignal *result = [[[[[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kCBLReplicationChangeNotification object:self]
    map:^NSSet *(NSNotification *_notification_) {
        (void)_notification_;
        return [self pendingDocumentIDs];
    }]
    ignore:[NSSet set]]
    distinctUntilChanged]
    combinePreviousWithStart:[NSSet set] reduce:^NSSet *(NSSet *previous, NSSet *current) {
        NSMutableSet *result = current.mutableCopy;
        [result minusSet:previous];
        return result;
    }]
    ignore:[NSSet set]]
    flattenMap:^RACSignal *(NSSet *newPendingDocumentIDs) {
        return newPendingDocumentIDs.rac_sequence.signal;
    }];
    return [result setNameWithFormat:@"[%@ -rcl_pendingDocumentIDs]", self];
}

@end
