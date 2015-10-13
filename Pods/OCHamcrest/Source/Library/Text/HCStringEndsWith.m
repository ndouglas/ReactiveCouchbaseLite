//  OCHamcrest by Jon Reid, http://qualitycoding.org/about/
//  Copyright 2015 hamcrest.org. See LICENSE.txt

#import "HCStringEndsWith.h"


@implementation HCStringEndsWith

+ (instancetype)stringEndsWith:(NSString *)substring
{
    return [[self alloc] initWithSubstring:substring];
}

- (BOOL)matches:(id)item
{
    if (![item respondsToSelector:@selector(hasSuffix:)])
        return NO;

    return [item hasSuffix:self.substring];
}

- (NSString *)relationship
{
    return @"ending with";
}

@end


id HC_endsWith(NSString *suffix)
{
    return [HCStringEndsWith stringEndsWith:suffix];
}
