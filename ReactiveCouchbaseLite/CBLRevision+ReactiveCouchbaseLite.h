//
//  CBLRevision+ReactiveCouchbaseLite.h
//  ReactiveCouchbaseLite
//
//  Created by Nathan Douglas on 12/4/14.
//  Released into the public domain.
//  See LICENSE for details.
//

#import "RCLDefinitions.h"

@interface CBLRevision (ReactiveCouchbaseLite)

/**
 The full revision history of the document.
 
 @return A signal streaming the full revision history of the document.
 @discussion This is not likely to be thread-safe, except when called on a CBLSavedRevision.
 */

- (RACSignal *)rcl_getRevisionHistory;

/**
 Gets the attachment with the specified name.
 
 @return A signal with the specified attachment, or an error if it could not be found.
 @discussion This is not likely to be thread-safe, except when called on a CBLSavedRevision.
 */

- (RACSignal *)rcl_attachmentNamed:(NSString *)name;

/**
 A scheduler for this revision and descendant objects.
 
 @return A scheduler that will work for this revision and its descendant objects.
 */

- (RACScheduler *)rcl_scheduler;

/**
 Returns whether we are operating on the scheduler devoted to this revision.
 
 @return YES if the schedulers are the same, otherwise NO.
 */

- (BOOL)rcl_isOnScheduler;

@end
