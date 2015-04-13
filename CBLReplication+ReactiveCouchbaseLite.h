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

/**
 The status of the replication.
 
 @return A signal of the replication's status.
 */

- (RACSignal *)rcl_status;

/**
 Whether the replication is running.
 
 @return A signal of the replication's running status.
 */

- (RACSignal *)rcl_isRunning;

/**
 Completes when the replication starts.
 
 @return A signal that completes when the replication starts, or if it is already active.
 */

- (RACSignal *)rcl_didStart;

/**
 Completes when the replication stops.
 
 @return A signal that completes when the replication stops, or if it is already stopped.
 */

- (RACSignal *)rcl_didStop;

/**
 Resumes the signal when the replication starts, and stops it when the replication stops.
 
 @param signal The signal to control.
 @return A signal that starts and stops the signal according to how the replication behaves.
 */

- (RACSignal *)rcl_controlSignal:(RACSignal *)signal;

@end
