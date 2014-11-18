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

@end
