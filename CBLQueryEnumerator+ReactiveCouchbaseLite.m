//
//  CBLQueryEnumerator+ReactiveCouchbaseLite.m
//  ReactiveCouchbaseLite
//
//  Created by Nathan Douglas on 3/23/15.
//  Copyright (c) 2015 DEVONtechnologies. All rights reserved.
//

#import "CBLQueryEnumerator+ReactiveCouchbaseLite.h"
#import "ReactiveCouchbaseLite.h"

@implementation CBLQueryEnumerator (ReactiveCouchbaseLite)
#undef __CLASS__
#define __CLASS__ "CBLQueryEnumerator"

- (RACSignal *)rcl_rowsSinceSequenceNumber:(UInt64)sequenceNumber {
    return [[self.allObjects.rac_sequence.signal
        filter:^BOOL(CBLQueryRow *row) {
            return row.sequenceNumber >= sequenceNumber;
        }]
        setNameWithFormat:@"[%@ -rcl_rowsSinceSequenceNumber: %@]", self, @(sequenceNumber)];
}

#undef __CLASS__
@end
