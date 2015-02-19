//
//  RCLDefinitions.m
//  ReactiveCouchbaseLite
//
//  Created by Nathan Douglas on 11/19/14.
//  Released into the public domain.
//  See LICENSE for details.
//

#import "RCLDefinitions.h"

NSString * const RCLErrorDomain = @"RCLErrorDomain";

extern NSError *RCLErrorWithCode(RCLErrorCodeType code) {
    NSString *description = nil;
    switch (code) {
        case RCLErrorCode_DocumentCouldNotBeFoundOrCreated:
            description = NSLocalizedString(@"Couchbase-Lite could not find or create the requested document.", @"RCLErrorCode_DocumentCouldNotBeFoundOrCreated");
            break;
        case RCLErrorCode_DocumentCouldNotBeFound:
            description = NSLocalizedString(@"Couchbase-Lite could not find the requested document.", @"RCLErrorCode_DocumentCouldNotBeFound");
            break;
        case RCLErrorCode_DocumentCouldNotBeCreated:
            description = NSLocalizedString(@"Couchbase-Lite could not create the requested document.", @"RCLErrorCode_DocumentCouldNotBeCreated");
            break;
        case RCLErrorCode_LocalDocumentCouldNotBeFound:
            description = NSLocalizedString(@"Couchbase-Lite could not find the requested local document.", @"RCLErrorCode_LocalDocumentCouldNotBeFound");
            break;
        case RCLErrorCode_ViewCouldNotBeFound:
            description = NSLocalizedString(@"Couchbase-Lite could not find the requested view.", @"RCLErrorCode_ViewCouldNotBeFound");
            break;
        case RCLErrorCode_ValidationCouldNotBeFound:
            description = NSLocalizedString(@"Couchbase-Lite could not find the requested validation.", @"RCLErrorCode_ValidationCouldNotBeFound");
            break;
        case RCLErrorCode_FilterCouldNotBeFound:
            description = NSLocalizedString(@"Couchbase-Lite could not find the requested filter.", @"RCLErrorCode_FilterCouldNotBeFound");
            break;
        case RCLErrorCode_TransactionWasNotCommitted:
            description = NSLocalizedString(@"Couchbase-Lite could not commit the transaction.", @"RCLErrorCode_TransactionWasNotCommitted");
            break;
        case RCLErrorCode_RevisionCouldNotBeFound:
            description = NSLocalizedString(@"Couchbase-Lite could not find the requested revision.", @"RCLErrorCode_RevisionCouldNotBeFound");
            break;
        case RCLErrorCode_AttachmentCouldNotBeFound:
            description = NSLocalizedString(@"Couchbase-Lite could not find the requested attachment.", @"RCLErrorCode_AttachmentCouldNotBeFound");
            break;
        case RCLErrorCode_QueryRowCouldNotBeFound:
            description = NSLocalizedString(@"Couchbase-Lite could not find the requested query row.", @"RCLErrorCode_QueryRowCouldNotBeFound");
            break;
        case RCLErrorCode_ViewCouldNotBeUpdated:
            description = NSLocalizedString(@"Couchbase-Lite could not update the map or reduce blocks for the row.", @"RCLErrorCode_ViewCouldNotBeUpdated");
            break;
    }
    return [NSError errorWithDomain:RCLErrorDomain code:code userInfo:@{
        NSLocalizedDescriptionKey : description,
    }];
}
