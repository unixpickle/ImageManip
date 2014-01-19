//
//  IMArguments.h
//  ImageManip
//
//  Created by Alex Nichol on 1/17/14.
//
//

#import <Foundation/Foundation.h>
#import "ANImageBitmapRep.h"

@interface IMArguments : NSObject

+ (BMPixel)parseColor:(NSString *)color;
+ (NSDictionary *)dictionaryForInput:(NSArray *)args flags:(NSArray *)specific regular:(NSArray *)regular;

@end
