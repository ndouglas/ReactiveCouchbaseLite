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
@property (strong) CBLPropertiesTransformationBlock propertiesTransformationBlock;
@end

@implementation CBLReplication (ReactiveCouchbaseLite)

- (RACSignal *)rcl_transferredDocuments {
    RACSignal *result = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [self setPropertiesTransformationBlock:^NSDictionary *(NSDictionary *document) {
            [subscriber sendNext:document];
            return document;
        }];
        return nil;
    }];
    return [result setNameWithFormat:@"[%@] -rcl_transferredDocuments", result.name];
}

- (RACSignal *)rcl_lastError {
    RACSignal *result = [[RACObserve(self, lastError)
    ignore:nil]
    takeUntil:self.rac_willDeallocSignal];
    return [result setNameWithFormat:@"[%@] -rcl_lastError", result.name];    
}

@end
