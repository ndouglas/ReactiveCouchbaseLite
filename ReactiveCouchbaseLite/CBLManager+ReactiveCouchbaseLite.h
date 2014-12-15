//
//  CBLManager+ReactiveCouchbaseLite.h
//  Sync
//
//  Created by Nathan Douglas on 11/19/14.
//  Released into the public domain.
//  See LICENSE for details.
//

#import <CouchbaseLite/CouchbaseLite.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "RCLDefinitions.h"

extern CBLManager *RCLSharedInstanceCurrentOrNewManager(CBLManager *current);

@interface CBLManager (ReactiveCouchbaseLite)

/**
 A copy of the shared instance of CBLManager.
 
 @return A signal containing a copy of the shared instance of CBLManager.
 */

+ (RACSignal *)rcl_manager;

/**
 A copy of the specified database.
 
 @param name The name of the database.
 @return A signal containing a copy of the specified database, or an error.
 @discussion The database will be created if it doesn't already exist.
 */

+ (RACSignal *)rcl_databaseNamed:(NSString *)name;

/**
 A copy of the specified database.
 
 @param name The name of the database.
 @return A signal containing a copy of the specified database, or an error.
 @discussion The database will not be created if it doesn't already exist.
 */

+ (RACSignal *)rcl_existingDatabaseNamed:(NSString *)name;

/**
 A copy of the specified database.
 
 @param name The name of the database.
 @return A signal containing a copy of the specified database, or an error.
 @discussion The database will be created if it doesn't already exist.
 */

- (RACSignal *)rcl_databaseNamed:(NSString *)name;

/**
 A copy of the specified database.
 
 @return A signal containing a copy of the specified database, or an error.
 @discussion The database will not be created if it doesn't already exist.
 */

- (RACSignal *)rcl_existingDatabaseNamed:(NSString *)name;

/**
 A scheduler for this manager and descendant objects.
 
 @return A scheduler that will work for this manager and its descendant objects.
 */

- (RACScheduler *)rcl_scheduler;

/**
 Sets a scheduler for this manager and descendant objects.
 
 @param scheduler A scheduler that will work for this manager and its descendant objects.
 */

- (void)rcl_setScheduler:(RACScheduler *)scheduler;

/**
 Returns whether we are operating on the scheduler devoted to this instance of the manager.
 
 @return YES if the queues have the same label, otherwise NO.
 */

- (BOOL)rcl_isOnScheduler;

@end
