//  OCHamcrest by Jon Reid, http://qualitycoding.org/about/
//  Copyright 2015 hamcrest.org. See LICENSE.txt

#import "HCHasCount.h"

#import "HCIsEqual.h"


@interface HCHasCount ()
@property (nonatomic, strong, readonly) id <HCMatcher> countMatcher;
@end

@implementation HCHasCount

+ (instancetype)hasCount:(id <HCMatcher>)countMatcher
{
    return [[self alloc] initWithCount:countMatcher];
}

- (instancetype)initWithCount:(id <HCMatcher>)countMatcher
{
    self = [super init];
    if (self)
        _countMatcher = countMatcher;
    return self;
}

- (BOOL)matches:(id)item
{
    if (![self itemHasCount:item])
        return NO;

    NSNumber *count = @([item count]);
    return [self.countMatcher matches:count];
}

- (BOOL)itemHasCount:(id)item
{
    return [item respondsToSelector:@selector(count)];
}

- (void)describeMismatchOf:(id)item to:(id <HCDescription>)mismatchDescription
{
    [mismatchDescription appendText:@"was "];
    if ([self itemHasCount:item])
    {
        [[[mismatchDescription appendText:@"count of "]
                               appendDescriptionOf:@([item count])]
                               appendText:@" with "];
    }
    [mismatchDescription appendDescriptionOf:item];
}

- (void)describeTo:(id <HCDescription>)description
{
    [[description appendText:@"a collection with count of "] appendDescriptionOf:self.countMatcher];
}

@end


id HC_hasCount(id <HCMatcher> countMatcher)
{
    return [HCHasCount hasCount:countMatcher];
}

id HC_hasCountOf(NSUInteger value)
{
    return HC_hasCount(HC_equalTo(@(value)));
}
