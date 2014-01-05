//
//  NSString+Utils.m
//  CMessenger
//
//  Created by Eueung Mulyana on 2/11/12.
//  Copyright (c) 2012 ITB. All rights reserved.
//

#import "NSString+Utils.h"

@implementation NSString (Utils)

+ (NSString *) getCurrentTime {
    NSDate *nowUTC = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    return [dateFormatter stringFromDate:nowUTC];
    //return [[[dateFormatter stringFromDate:nowUTC]componentsSeparatedByString:@" "]objectAtIndex:2];
}

- (NSString *) substituteEmoticons {
	
	//See http://www.easyapns.com/iphone-emoji-alerts for a list of emoticons available
	
	NSString *res = [self stringByReplacingOccurrencesOfString:@":)" withString:@"\ue415"];	
	res = [res stringByReplacingOccurrencesOfString:@":(" withString:@"\ue403"];
	res = [res stringByReplacingOccurrencesOfString:@";-)" withString:@"\ue405"];
	res = [res stringByReplacingOccurrencesOfString:@":-x" withString:@"\ue418"];
	
	return res;
	
}

+ (NSString *) removeLeadingZeros:(NSString *)number{
    //NSString *num = [number copy];
    BOOL stop = NO;
    int index = 0;
    while (!stop && index<[number length]){
        if ([number characterAtIndex:index]!='0' ){
            stop = YES;
        }else{
            index++;
        }
    }
    
    if (stop){
        return [number substringFromIndex:index];
    }
    return nil;
    
}

+ (NSString *) removeSpaces:(NSString *)theString{
    NSMutableString *s = [[NSMutableString alloc]init ];
    NSArray *sArray = [theString componentsSeparatedByString:@" "];
    if([sArray count]<1){
        return theString;
    }
    
    for (int i=0;i<[sArray count];i++){
        [s appendString:[sArray objectAtIndex:i]];
    }
   
    return s;
}


@end
