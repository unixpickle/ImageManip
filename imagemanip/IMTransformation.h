//
//  IMTransformation.h
//  ImageManip
//
//  Created by Alex Nichol on 1/17/14.
//
//

#import <Foundation/Foundation.h>
#import "ANImageBitmapRep.h"

@interface IMTransformation : NSObject {
}

@property (nonatomic, retain) ANImageBitmapRep * image;

- (id)initWithImage:(ANImageBitmapRep *)image arguments:(NSArray *)args;
- (void)perform;

+ (NSString *)commandName;
+ (NSString *)summary;
+ (NSString *)fullUsage;

@end
