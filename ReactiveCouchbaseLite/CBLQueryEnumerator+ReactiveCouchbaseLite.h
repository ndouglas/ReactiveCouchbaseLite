//
//  CBLQueryEnumerator+ReactiveCouchbaseLite.h
//  ReactiveCouchbaseLite
//
//  Created by Nathan Douglas on 12/4/14.
//  Released into the public domain.
//  See LICENSE for details.
//

#import "RCLDefinitions.h"
#import "CBLQuery+ReactiveCouchbaseLite.h"

@interface CBLQueryEnumerator (ReactiveCouchbaseLite)

/**
 A signal for the next row.
 
 @return A signal of the next row.
 @discussion This is probably not threadsafe, and should be called from the owning thread.
 */

- (RACSignal *)rcl_nextRow;

@end
