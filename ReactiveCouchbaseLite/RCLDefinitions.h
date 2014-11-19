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
    RCLErrorCode_DocumentCouldNotBeFoundOrCreated,          // Couchbase-Lite couldn't find or create the document.
    RCLErrorCode_DocumentCouldNotBeFound,                   // Couchbase-Lite couldn't find the document.
    RCLErrorCode_DocumentCouldNotBeCreated,                 // Couchbase-Lite couldn't create the document.
    RCLErrorCode_LocalDocumentCouldNotBeFound,              // Couchbase-Lite couldn't find the local document.
} RCLErrorCodeType;

extern NSError *RCLErrorWithCode(RCLErrorCodeType code);
