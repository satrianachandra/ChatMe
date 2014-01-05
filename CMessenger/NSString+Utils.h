//
//  NSString+Utils.h
//  CMessenger
//
//  Created by Eueung Mulyana on 2/11/12.
//  Copyright (c) 2012 ITB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Utils)

+ (NSString *) getCurrentTime;
- (NSString *) substituteEmoticons;
+ (NSString *) removeLeadingZeros:(NSString *)number;
+ (NSString *) removeSpaces:(NSString *)theString;
@end
