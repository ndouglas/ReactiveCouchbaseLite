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
 @return A document, or an error if it could not be created or found.
 @discussion The document will be created if it can't be found.
 */

- (RACSignal *)rcl_documentWithID:(NSString *)documentID;

/**
 Opens the document with the specified ID.
 
 @param documentID The unique identifier of the document.
 @return A document, or an error if it could not be found.
 */

- (RACSignal *)rcl_existingDocumentWithID:(NSString *)documentID;

@end
