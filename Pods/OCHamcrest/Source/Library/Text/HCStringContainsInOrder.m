//  OCHamcrest by Jon Reid, http://qualitycoding.org/about/
//  Copyright 2015 hamcrest.org. See LICENSE.txt

#import "HCStringContainsInOrder.h"

#import "HCCollect.h"


static void requireElementsToBeStrings(NSArray *array)
{
    for (id element in array)
    {
        if (![element isKindOfClass:[NSString class]])
        {
            @throw [NSException exceptionWithName:@"NotAString"
                                           reason:@"Arguments must be strings"
                                         userInfo:nil];
        }
    }
}


@interface HCStringContainsInOrder ()
@property (nonatomic, copy, readonly) NSArray *substrings;
@end

@implementation HCStringContainsInOrder

+ (instancetype)containsInOrder:(NSArray *)substrings
{
    return [[self alloc] initWithSubstrings:substrings];
}

- (instancetype)initWithSubstrings:(NSArray *)substrings
{
    self = [super init];
    if (self)
    {
        requireElementsToBeStrings(substrings);
        _substrings = [substrings copy];
    }
    return self;
}

- (BOOL)matches:(id)item
{
    if (![item isKindOfClass:[NSString class]])
        return NO;

    NSRange searchRange = NSMakeRange(0, [item length]);
    for (NSString *substring in self.substrings)
    {
        NSRange substringRange = [item rangeOfString:substring options:0 range:searchRange];
        if (substringRange.location == NSNotFound)
            return NO;
        searchRange.location = substringRange.location + substringRange.length;
        searchRange.length = [item length] - searchRange.location;
    }
    return YES;
}

- (void)describeTo:(id <HCDescription>)description
{
    [description appendList:self.substrings start:@"a string containing " separator:@", " end:@" in order"];
}

@end


id HC_stringContainsInOrder(NSString *substrings, ...)
{
    va_list args;
    va_start(args, substrings);
    NSArray *strings = HCCollectItems(substrings, args);
    va_end(args);

    return [HCStringContainsInOrder containsInOrder:strings];
}
