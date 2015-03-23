//
//  CBLQueryEnumerator+ReactiveCouchbaseLite.h
//  ReactiveCouchbaseLite
//
//  Created by Nathan Douglas on 3/23/15.
//  Copyright (c) 2015 DEVONtechnologies. All rights reserved.
//

#import "RCLDefinitions.h"

/**
 Adds useful methods to CBLQueryEnumerator.
 */

@interface CBLQueryEnumerator (ReactiveCouchbaseLite)

/**
 Extracts the rows created since the specified sequence number.
 
 @param sequenceNumber The sequence number.
 @return A signal of rows.
 */

- (RACSignal *)rcl_rowsSinceSequenceNumber:(UInt64)sequenceNumber;

@end
