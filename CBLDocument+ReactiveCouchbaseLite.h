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
 Attempts to delete the document, preserving its properties.
 
 @return A signal that completes when the document is deleted, or returns an error if the attempt was unsuccessful.
 */

- (RACSignal *)rcl_deletePreservingProperties;

/**
 Attempts to delete the document with additional modifications performed on the properties.
 
 @param block A block executed on the proposed deletion revision to modify its properties.
 @return A signal that completes when the document is deleted, or returns an error if the attempt was unsuccessful.
 @discussion The block may be executed multiple times.
 */

- (RACSignal *)rcl_deleteModifyingPropertiesWithBlock:(void(^)(CBLUnsavedRevision *proposedRevision))block;

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
 Resolves any conflicts in this document with the specified block.
 
 @return A signal streaming winning revisions and errors in conflict resolution.
 */

- (RACSignal *)rcl_resolveConflictsWithBlock:(NSDictionary *(^)(NSArray *conflictingRevisions))block;

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
