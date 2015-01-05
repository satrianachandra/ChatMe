//
//  NSString+Utils.h
//  CMessenger
//
//  Created by Chandra Satriana on 2/11/12.
//  Copyright (c) 2012 Chandra Satriana.
//

#import <Foundation/Foundation.h>

@interface NSString (Utils)

+ (NSString *) getCurrentTime;
- (NSString *) substituteEmoticons;
+ (NSString *) removeLeadingZeros:(NSString *)number;
+ (NSString *) removeSpaces:(NSString *)theString;
@end
