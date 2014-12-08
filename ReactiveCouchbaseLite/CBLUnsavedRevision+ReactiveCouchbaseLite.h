//
//  CBLUnsavedRevision+ReactiveCouchbaseLite.h
//  ReactiveCouchbaseLite
//
//  Created by Nathan Douglas on 12/4/14.
//  Released into the public domain.
//  See LICENSE for details.
//

#import "RCLDefinitions.h"
#import "CBLRevision+ReactiveCouchbaseLite.h"

@interface CBLUnsavedRevision (ReactiveCouchbaseLite)

/**
 Saves this revision to the database.
 
 @return A signal completing or returning an error if the operation fails.
 @discussion This is not likely to be thread-safe.
 */

- (RACSignal *)rcl_save;

/**
 Saves this revision to the database regardless of whether it is current.
 
 @return A signal completing or returning an error if the operation fails.
 @discussion This is not likely to be thread-safe.
 */

- (RACSignal *)rcl_saveAllowingConflict;

/**
 Sets an attachment for the revision.
 
 @param name The attachment name.
 @param mimeType The MIME type of the content.
 @param content The body of the attachment.
 @return A signal that completes when the operation is finished.
 @discussion This is not likely to be thread-safe.
 */

- (RACSignal *)rcl_setAttachmentNamed:(NSString *)name withContentType:(NSString *)mimeType content:(NSData *)content;

/**
 Sets an attachment for the revision.
 
 @param name The attachment name.
 @param mimeType The MIME type of the content.
 @param fileURL The URL to the body of the attachment.
 @return A signal that completes when the operation is finished.
 @discussion This is not likely to be thread-safe.
 */

- (RACSignal *)rcl_setAttachmentNamed:(NSString *)name withContentType:(NSString *)mimeType contentURL:(NSURL *)fileURL;

/**
 Removes the attachment with the given name.
 
 @param name The attachment name.
 @return A signal that completes when the operation is finished.
 @discussion This is not likely to be thread-safe.
 */

- (RACSignal *)rcl_removeAttachmentNamed:(NSString *)name;

@end
