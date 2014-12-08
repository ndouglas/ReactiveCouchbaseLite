//
//  CBLQueryEnumerator+ReactiveCouchbaseLite.h
//  ReactiveCouchbaseLite
//
//  Created by Nathan Douglas on 12/4/14.
//  Released into the public domain.
//  See LICENSE for details.
//

@interface CBLQueryEnumerator (ReactiveCouchbaseLite)

/**
 A signal for the next row.
 
 @return A signal of the next row.
 */

- (RACSignal *)rcl_nextRow;

/**
 All of the rows as a sequence.
 
 @return A sequence of the rows.
 */

- (RACSequence *)rcl_sequence;

@end
