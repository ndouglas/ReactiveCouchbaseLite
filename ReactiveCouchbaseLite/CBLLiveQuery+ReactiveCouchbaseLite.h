//
//  CBLLiveQuery+ReactiveCouchbaseLite.h
//  ReactiveCouchbaseLite
//
//  Created by Nathan Douglas on 12/4/14.
//  Released into the public domain.
//  See LICENSE for details.
//

#import "RCLDefinitions.h"

@interface CBLLiveQuery (ReactiveCouchbaseLite)

/**
 The query results.
 
 @return A signal containing the rows of the database matching the query as the contents of the database change.
 */

- (RACSignal *)rcl_rows;

@end
