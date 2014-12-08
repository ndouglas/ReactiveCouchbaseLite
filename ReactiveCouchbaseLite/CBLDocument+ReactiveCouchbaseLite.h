//
//  CBLDocument+ReactiveCouchbaseLite.h
//  ReactiveCouchbaseLite
//
//  Created by Nathan Douglas on 12/4/14.
//  Released into the public domain.
//  See LICENSE for details.
//

#import "RCLDefinitions.h"

extern CBLDocument *RCLCurrentOrNewDocument(CBLDocument *current);

/**
 Adds useful methods to CBLDocument.
 */

@interface CBLDocument (ReactiveCouchbaseLite)

/**
 Attempts to delete the document.
 
 @return A signal that completes when the document is deleted, or returns an error if the attempt was unsuccessful.
 */

- (RACSignal *)rcl_delete;

/**
 Attempts to purge the document.
 
 @return A signal that completes when the document is purged, or returns an error if the attempt was unsuccessful.
 @discussion This is more than deletion; the database forgets about the document entirely.
 @discussion This is not replicated.
 */

- (RACSignal *)rcl_purge;

/**
 The current revision ID.
 
 @return A signal containing a stream of the current revision ID.
 @discussion This works differently from -[CBLDocument currentRevisionID].
 */

- (RACSignal *)rcl_currentRevisionID;

/**
 The current revision.
 
 @return A signal containing a stream of the current revision.
 @discussion This works differently from -[CBLDocument currentRevision].
 */

- (RACSignal *)rcl_currentRevision;

/**
 Gets the revision with the specified ID.
 
 @return A signal containing the revision with the specified ID, or an error if it could not be found.
 */

- (RACSignal *)rcl_revisionWithID:(NSString *)revisionID;

/**
 The full revision history of the document.
 
 @return A signal streaming the full revision history of the document.
 */

- (RACSignal *)rcl_getRevisionHistory;

/**
 The full revision history of the document, filtered by the specified block.
 
 @block A block used to accept or reject individual revisions in the revision history.
 @return A signal streaming the filtered revision history of the document.
 */

- (RACSignal *)rcl_getRevisionHistoryFilteredWithBlock:(BOOL (^)(CBLSavedRevision *revision))block;

/**
 The conflicting revisions of the document.
 
 @return A signal that returns conflicting versions of the document or an error if the operation failed.
 */

- (RACSignal *)rcl_getConflictingRevisions;

/**
 All leaf revisions of the document.
 
 @return A signal that returns leaf versions of the document or an error if the operation failed.
 */

- (RACSignal *)rcl_getLeafRevisions;

/**
 A new, unsaved revision of the document whose parent is the current revision,
 or which will be the first revision for an unsaved document.
 
 @return A signal that returns a new revision of the document.
 */

- (RACSignal *)rcl_newRevision;

/**
 The properties of the document.
 
 @return A signal streaming the document properties.
 */

- (RACSignal *)rcl_properties;

/**
 The user properties of the document.
 
 @return A signal streaming the document user properties.
 */

- (RACSignal *)rcl_userProperties;

/**
 Saves a new revision.
 
 @return A signal that completes or returns an error if the operation fails.
 */

- (RACSignal *)rcl_putProperties:(NSDictionary *)properties;

/**
 Saves a new revision by letting the caller update the existing properties.
 
 @return A signal that completes or returns an error if the operation fails.
 */

- (RACSignal *)rcl_update:(BOOL(^)(CBLUnsavedRevision *))block;

/** 
 Notifications posted by CBLDocuments in response to a change.
 
 @return A signal streaming notifications of document changes.
 */

- (RACSignal *)rcl_documentChangeNotifications;

/**
 A scheduler for this document and descendant objects.
 
 @return A scheduler that will work for this document and its descendant objects.
 */

- (RACScheduler *)rcl_scheduler;

/**
 Returns whether we are operating on the scheduler devoted to this document.
 
 @return YES if the schedulers are the same, otherwise NO.
 */

- (BOOL)rcl_isOnScheduler;

@end
