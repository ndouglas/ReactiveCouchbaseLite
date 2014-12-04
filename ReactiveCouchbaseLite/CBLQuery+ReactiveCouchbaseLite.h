//
//  CBLQuery+ReactiveCouchbaseLite.h
//  ReactiveCouchbaseLite
//
//  Created by Nathan Douglas on 12/4/14.
//  Released into the public domain.
//  See LICENSE for details.
//

#import "RCLDefinitions.h"

@interface CBLQuery (ReactiveCouchbaseLite)

/**
 Runs an asynchronous query and returns with the results.
 
 @return A signal with an CBLQueryEnumerator instance or an error if the query failed.
 */

- (RACSignal *)rcl_run;

@end
