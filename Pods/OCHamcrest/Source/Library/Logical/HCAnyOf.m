//  OCHamcrest by Jon Reid, http://qualitycoding.org/about/
//  Copyright 2015 hamcrest.org. See LICENSE.txt

#import "HCAnyOf.h"

#import "HCCollect.h"


@interface HCAnyOf ()
@property (nonatomic, copy, readonly) NSArray *matchers;
@end

@implementation HCAnyOf

+ (instancetype)anyOf:(NSArray *)matchers
{
    return [[self alloc] initWithMatchers:matchers];
}

- (instancetype)initWithMatchers:(NSArray *)matchers
{
    self = [super init];
    if (self)
        _matchers = [matchers copy];
    return self;
}

- (BOOL)matches:(id)item
{
    for (id <HCMatcher> oneMatcher in self.matchers)
        if ([oneMatcher matches:item])
            return YES;
    return NO;
}

- (void)describeTo:(id <HCDescription>)description
{
    [description appendList:self.matchers start:@"(" separator:@" or " end:@")"];
}

@end


id HC_anyOf(id matchers, ...)
{
    va_list args;
    va_start(args, matchers);
    NSArray *matcherList = HCCollectMatchers(matchers, args);
    va_end(args);

    return [HCAnyOf anyOf:matcherList];
}
