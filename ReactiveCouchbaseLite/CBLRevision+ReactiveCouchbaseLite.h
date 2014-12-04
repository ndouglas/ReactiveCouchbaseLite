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
 */

- (RACSignal *)rcl_getRevisionHistory;

/**
 Gets the attachment with the specified name.
 
 @return A signal with the specified attachment, or an error if it could not be found.
 */

- (RACSignal *)rcl_attachmentNamed:(NSString *)name;

@end
