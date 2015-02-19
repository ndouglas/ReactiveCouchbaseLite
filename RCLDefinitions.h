//
//  RCLDefinitions.h
//  ReactiveCouchbaseLite
//
//  Created by Nathan Douglas on 11/19/14.
//  Released into the public domain.
//  See LICENSE for details.
//

#import <CouchbaseLite/CouchbaseLite.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

extern NSString * const RCLErrorDomain;

typedef enum {
    RCLErrorCode_DocumentCouldNotBeFoundOrCreated,          // Couldn't find or create the document.
    RCLErrorCode_DocumentCouldNotBeFound,                   // Couldn't find the document.
    RCLErrorCode_DocumentCouldNotBeCreated,                 // Couldn't create the document.
    RCLErrorCode_LocalDocumentCouldNotBeFound,              // Couldn't find the local document.
    RCLErrorCode_ViewCouldNotBeFound,                       // Couldn't find the view.
    RCLErrorCode_ValidationCouldNotBeFound,                 // Couldn't find the validation.
    RCLErrorCode_FilterCouldNotBeFound,                     // Couldn't find the filter.
    RCLErrorCode_TransactionWasNotCommitted,                // Couldn't commit the transaction.
    RCLErrorCode_RevisionCouldNotBeFound,                   // Couldn't find the revision.
    RCLErrorCode_AttachmentCouldNotBeFound,                 // Couldn't find the attachment.
    RCLErrorCode_QueryRowCouldNotBeFound,                   // Couldn't find the query row.
    RCLErrorCode_ViewCouldNotBeUpdated,                     // Couldn't update the view.
} RCLErrorCodeType;

extern NSError *RCLErrorWithCode(RCLErrorCodeType code);
