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
 All of the rows, sent sequentially.
 
 @return A signal of every result row.
 */

- (RACSignal *)rcl_flattenedRows;

@end
