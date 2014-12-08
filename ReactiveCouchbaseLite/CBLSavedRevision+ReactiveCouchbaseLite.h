//
//  CBLSavedRevision+ReactiveCouchbaseLite.h
//  ReactiveCouchbaseLite
//
//  Created by Nathan Douglas on 12/4/14.
//  Released into the public domain.
//  See LICENSE for details.
//

#import "RCLDefinitions.h"
#import "CBLRevision+ReactiveCouchbaseLite.h"

@interface CBLSavedRevision (ReactiveCouchbaseLite)

/**
 Creates a new revision with properties and attachments identical to this one.
 
 @return A signal with a new unsaved revision.
 */

- (RACSignal *)rcl_createRevision;

/**
 Creates a new revision with the specified properties.
 
 @return A signal with a new saved revision, or an error if the operation failed.
 */

- (RACSignal *)rcl_createRevisionWithProperties:(NSDictionary *)properties;

/**
 Attempts to delete the document.
 
 @return A signal with a new deletion revision, or an error if the attempt was unsuccessful.
 */

- (RACSignal *)rcl_delete;

@end
