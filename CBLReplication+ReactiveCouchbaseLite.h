//
//  CBLReplication+ReactiveCouchbaseLite.h
//  ReactiveCouchbaseLite
//
//  Created by Nathan Douglas on 12/4/14.
//  Released into the public domain.
//  See LICENSE for details.
//

#import "RCLDefinitions.h"

@interface CBLReplication (ReactiveCouchbaseLite)

/**
 Returns a dictionary of each transferred document's properties as it is transferred.
 
 @return A signal streaming transferred properties.
 */

- (RACSignal *)rcl_transferredDocuments;

/**
 The last error encountered by this replication.

 @return A signal streaming error objects.
 */

- (RACSignal *)rcl_lastError;

/**
 The document IDs that are pending upload to the server.
 
 @return A signal of individual document IDs, or error if an error occurs.
 @discussion Available only on push replications.
 @discussion This is not terribly useful for synchronous processing purposes.
 */

- (RACSignal *)rcl_pendingPushDocumentIDs;

/**
 The documents that are pending upload to the server.
 
 @return A signal of individual documents, or error if an error occurs.
 @discussion Available only on push replications.
 @discussion This is not terribly useful for synchronous processing purposes.
 */

- (RACSignal *)rcl_pendingPushDocuments;

@end