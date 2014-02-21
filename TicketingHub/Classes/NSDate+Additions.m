//
//  NSDate+Additions.m
//  TicketingHub
//
//  Created by Bartek Hugo Trzcinski on 20/02/14.
//  Copyright (c) 2014 TicketingHub. All rights reserved.
//

#import "NSDate+Additions.h"

@implementation NSDate (Additions)

- (NSDate*)dateByAddingMonths:(NSInteger)months
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setMonth:months];
    
    NSDate *newDate = [calendar dateByAddingComponents:dateComponents toDate:self options:0];
    
    return newDate;
}

+ (NSDateFormatter *)isoDateFormatter {
    
    static NSDateFormatter *_isoDateFormatter;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _isoDateFormatter = [NSDateFormatter new];
        [_isoDateFormatter setDateFormat:@"yyyy-MM-dd"];
    });
    
    return _isoDateFormatter;
}

- (NSString *)isoDateString
{
    return [[[self class] isoDateFormatter] stringFromDate:self];
}


@end