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

/**
 Runs an asynchronous query and purges the results.
 
 @return A signal that completes or returns an error if one occurred.
 @discussion No, seriously, this purges the documents returned by the query.
 */

- (RACSignal *)rcl_purgeDocuments;

/**
 All of the rows as a signal.
 
 @return A signal of the rows.
 @discussion Will run the query.
 */

- (RACSignal *)rcl_flattenedRows;

/**
 A scheduler for this database and descendant objects.
 
 @return A scheduler that will work for this database and its descendant objects.
 */

- (RACScheduler *)rcl_scheduler;

/**
 Returns whether we are operating on the scheduler devoted to this database's instance of the manager.
 
 @return YES if the queues have the same label, otherwise NO.
 */

- (BOOL)rcl_isOnScheduler;

@end
