//
//  CBLDatabase+ReactiveCouchbaseLite.h
//  ReactiveCouchbaseLite
//
//  Created by Nathan Douglas on 11/18/14.
//  Released into the public domain.
//  See LICENSE for details.
//

#import <CouchbaseLite/CouchbaseLite.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "RCLDefinitions.h"

extern CBLDatabase *RCLCurrentOrNewDatabase(CBLDatabase *current);

/**
 Adds useful methods to CBLDatabase.
 */

@interface CBLDatabase (ReactiveCouchbaseLite)

/**
  When a new revision is added to the database, it receives a new sequence number; 
  this can be used to check whether the database has changed between two points 
  in time.
  
  @return A signal of NSNumber instances containing the last sequence number.
 */

- (RACSignal *)rcl_lastSequenceNumber;

/**
  Closes this database.
  
  @return A signal indicating whether the database closed with an error or not.
 */

- (RACSignal *)rcl_close;

/**
  Compacts this database.
  
  @return A signal indicating whether the database compacted with an error or not.
 */

- (RACSignal *)rcl_compact;

/**
  Deletes this database.
  
  @return A signal indicating whether the database deleted with an error or not.
 */

- (RACSignal *)rcl_delete;

/**
 Creates or opens the document with the specified ID.
 
 @param documentID The unique identifier of the document.
 @return A signal with the document or an error if the document could not be created or found.
 @discussion The document will be created if it can't be found.
 */

- (RACSignal *)rcl_documentWithID:(NSString *)documentID;

/**
 Opens the document with the specified ID.
 
 @param documentID The unique identifier of the document.
 @return A signal with the document or an error if the document could not be found.
 */

- (RACSignal *)rcl_existingDocumentWithID:(NSString *)documentID;

/**
 Opens the document with the specified ID.
 
 @param documentID The unique identifier of the document.
 @param defaultProperties Properties assigned to this document if it had to be newly created.
 @return A signal with the document or an error if the document could not be created.
 */

- (RACSignal *)rcl_existingDocumentWithID:(NSString *)documentID defaultProperties:(NSDictionary *)defaultProperties;

/**
 Creates a new document with a random UUID.
 
 @return A signal with the document or an error if the document could not be created.
 */

- (RACSignal *)rcl_createDocument;

/**
 Opens the local document with the specified ID.
 
 @param documentID The unique identifier of the document.
 @return A signal with the dictionary representing the document or an error if the document could not be found.
 */

- (RACSignal *)rcl_existingLocalDocumentWithID:(NSString *)documentID;

/**
 Updates the local document with the specified ID.
 
 @param properties The properties to apply to the document.
 @param documentID The unique identifier of the document.
 @return A signal containing either a completion or an error, if one occurred.
 */

- (RACSignal *)rcl_putLocalDocumentWithProperties:(NSDictionary *)properties ID:(NSString *)documentID;

/**
 Deletes the local document with the specified ID.
 
 @param documentID The unique identifier of the document.
 @return A signal containing either a completion or an error, if one occurred.
 */

- (RACSignal *)rcl_deleteLocalDocumentWithID:(NSString *)documentID;

/**
 Creates an all documents query.
 
 @return A signal containing an all documents query.
 */

- (RACSignal *)rcl_allDocumentsQuery;

/**
 Creates an all documents query with a specified mode.
 
 @param mode The mode of the query.
 @return A signal containing an all documents query with the specified mode.
 */

- (RACSignal *)rcl_allDocumentsQueryWithMode:(CBLAllDocsMode)mode;

/**
 Creates an all documents query with a specified mode.
 
 @param mode The mode of the query.
 @param indexUpdateMode The indexUpdateMode of the query.
 @return A signal containing an all documents query with the specified mode.
 */

- (RACSignal *)rcl_allDocumentsQueryWithMode:(CBLAllDocsMode)mode indexUpdateMode:(CBLIndexUpdateMode)indexUpdateMode;

/**
 Creates an all (including deleted) documents query.
 
 @param block A block used for filtering the results.
 @return A signal containing an all (including deleted) documents query.
 */

- (RACSignal *)rcl_allIncludingDeletedDocumentsQuery;

/** 
 Creates a one-shot query with the given map block.
 
 @param block The map block that will be used to query the database.
 @return A signal containing the slow query.
 @discussion This is inefficient but useful for development. See -[CBLDatabase slowQueryWithMap:] for more information.
 */

- (RACSignal *)rcl_slowQueryWithMap:(CBLMapBlock)block;

/**
 Retrieves the view with the given name.
 
 @param name The name of the view.
 @return A signal containing the view (which may not necessarily exist in the database, if it hasn't been assigned a
 map function).
 */

- (RACSignal *)rcl_viewNamed:(NSString *)name;

/**
 Retrieves the view with the given name.
 
 @param name The name of the view.
 @return A signal containing the view, or an error if it could not be found.
 */

- (RACSignal *)rcl_existingViewNamed:(NSString *)name;

/**
 Retrieves the view with the given name.
 
 @param name The name of the view.
 @param mapBlock The map block, which will be set if it hasn't already been set.
 @param version The version of the view.
 @return A signal containing the view (which may not necessarily exist in the database, if it hasn't been assigned a
 map function).
 */

- (RACSignal *)rcl_viewNamed:(NSString *)name mapBlock:(CBLMapBlock)mapBlock version:(NSString *)version;

/**
 Retrieves the view with the given name.
 
 @param name The name of the view.
 @param mapBlock The map block, which will be set if it hasn't already been set.
 @param reduceBlock The reduce block, which will be set if it hasn't already been set.
 @param version The version of the view.
 @return A signal containing the view (which may not necessarily exist in the database, if it hasn't been assigned a
 map function).
 */

- (RACSignal *)rcl_viewNamed:(NSString *)name mapBlock:(CBLMapBlock)mapBlock reduceBlock:(CBLReduceBlock)reduceBlock version:(NSString *)version;

/**
 Sets a validation function on the database.
 
 @param name The name of the validation function.
 @param block The validation function.
 @return A signal that completes when the validation function is set.
 */

- (RACSignal *)rcl_setValidationNamed:(NSString *)name asBlock:(CBLValidationBlock)block;

/**
 Retrieves the validation block with the given name.
 
 @param name The name of the validation block.
 @return A signal containing the validation block or an error if it could not be found.
 */

- (RACSignal *)rcl_validationNamed:(NSString *)name;

/**
 Sets a filter function on the database.
 
 @param name The name of the filter function.
 @param block The filter function.
 @return A signal that completes when the filter function is set.
 */

- (RACSignal *)rcl_setFilterNamed:(NSString *)name asBlock:(CBLFilterBlock)block;

/**
 Retrieves the filter block with the given name.
 
 @param name The name of the filter block.
 @return A signal containing the filter block or an error if it could not be found.
 */

- (RACSignal *)rcl_filterNamed:(NSString *)name;

/**
 Runs the specified block in a transaction. 
 
 @param block The block to execute.
 @return A signal that completes if the transaction was completed successfully, otherwise returns an error.
 */

- (RACSignal *)rcl_inTransaction:(BOOL (^)(CBLDatabase *database))block;

/**
 Runs the specified block asynchronously on the database's dispatch queue or thread.
 
 @param block The block to execute.
 @return A signal that completes immediately.
 */

- (RACSignal *)rcl_doAsync:(void (^)(void))block;

/**
 All current, running CBLReplications involving this database.
 
 @return A signal of NSArray objects containing the replications involving this database.
 */

- (RACSignal *)rcl_allReplications;

/**
 Creates a push replication.
 
 @param URL The URL to which we should push changes.
 @return A signal that contains a push replication and completes afterward.
 */

- (RACSignal *)rcl_createPushReplication:(NSURL *)URL;

/**
 Creates a pull replication.
 
 @param URL The URL from which we should pull changes.
 @return A signal that contains a pull replication and completes afterward.
 */

- (RACSignal *)rcl_createPullReplication:(NSURL *)URL;

/**
 Observes changes in the database.
 
 @return A signal containing CBLDatabaseChange objects.
 */

- (RACSignal *)rcl_databaseChangeNotifications;

/**
 Deletes the document with the specified ID.
 
 @param documentID The document ID.
 @return A signal that completes when the document is deleted.
 */

- (RACSignal *)rcl_deleteDocumentWithID:(NSString *)documentID;

/**
 Marks as deleted the document with the specified ID.
 
 @param documentID The document ID.
 @return A signal that completes when the document is deleted.
 @discussion This is similar to -[CBLDatabase (ReactiveCouchbaseLite) rcl_deleteDocumentWithID:] in that it marks the
 document as deleted.  However, it retains all existing properties.
 */

- (RACSignal *)rcl_markAsDeletedDocumentWithID:(NSString *)documentID;

/**
 Marks as deleted the document with the specified ID.
 
 @param documentID The document ID.
 @param additionalProperties Additional properties applied to the document.
 @return A signal that completes when the document is deleted.
 @discussion This is similar to -[CBLDatabase (ReactiveCouchbaseLite) rcl_deleteDocumentWithID:] in that it marks the
 document as deleted.  However, it retains all existing properties.
 */

- (RACSignal *)rcl_markAsDeletedDocumentWithID:(NSString *)documentID additionalProperties:(NSDictionary *)additionalProperties;

/**
 Performs the block with the specified document.
 
 @param documentID The ID of the document.
 @param block The block performed on the document.
 @return A signal that completes when the block has been executed.
 */

- (RACSignal *)rcl_onDocumentWithID:(NSString *)documentID performBlock:(void (^)(CBLDocument *document))block;

/**
 Updates the document using the specified block.
 
 @param documentID The ID of the document.
 @param block The block used to update the document.
 @return A signal that completes when the document has been updated or returns an error if it fails.
 */

- (RACSignal *)rcl_updateDocumentWithID:(NSString *)documentID block:(BOOL(^)(CBLUnsavedRevision *unsavedRevision))block;

/**
 Updates the local document using the specified block.
 
 @param documentID The ID of the document.
 @param block The block used to update the local document.
 @return A signal that completes when the local document has been updated or returns an error if it fails.
 */

- (RACSignal *)rcl_updateLocalDocumentWithID:(NSString *)documentID block:(NSDictionary *(^)(NSMutableDictionary *localDocument))block;

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
