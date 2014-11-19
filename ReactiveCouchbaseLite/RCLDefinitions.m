//
//  RCLDefinitions.m
//  ReactiveCouchbaseLite
//
//  Created by Nathan Douglas on 11/19/14.
//  Released into the public domain.
//  See LICENSE for details.
//

#import "RCLDefinitions.h"

#undef NDD_OPTION_BASE_DEBUG_TRACE_LOCAL
#define NDD_OPTION_BASE_DEBUG_TRACE_LOCAL										FALSE

NSString * const RCLErrorDomain = @"RCLErrorDomain";

extern NSError *RCLErrorWithCode(RCLErrorCodeType code) {
    NSString *description = nil;
    switch (code) {
        case RCLErrorCode_DocumentCouldNotBeFoundOrCreated:
            description = NSLocalizedString(@"Couchbase-Lite could not find or create the requested document.", #code);
            break;
        case RCLErrorCode_DocumentCouldNotBeFound:
            description = NSLocalizedString(@"Couchbase-Lite could not find the requested document.", #code);
            break;
        case RCLErrorCode_DocumentCouldNotBeCreated:
            description = NSLocalizedString(@"Couchbase-Lite could not create the requested document.", #code);
            break;
    }
    return [NSError errorWithDomain:RCLErrorDomain code:code userInfo:@{
        NSLocalizedDescriptionKey : description,
    }];
}
