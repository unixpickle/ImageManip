//
//  IMTintTransformation.m
//  ImageManip
//
//  Created by Alex Nichol on 1/19/14.
//
//

#import "IMColorTransformation.h"

@implementation IMColorTransformation

+ (NSString *)commandName {
    return @"color";
}

+ (NSString *)fullUsage {
    return @"rgba(x,y,z,w) |or| #XXYYZZ";
}

+ (NSString *)summary {
    return @"color an image mask";
}

- (id)initWithImage:(ANImageBitmapRep *)image arguments:(NSArray *)args {
    if ((self = [super initWithImage:image arguments:args])) {
        if (args.count != 1) {
            @throw [NSException exceptionWithName:@"IMTintArguments"
                                           reason:@"invalid number of arguments"
                                         userInfo:nil];
        }
        tintColor = [IMArguments parseColor:args[0]];
    }
    return self;
}

- (void)perform {
    for (int x = 0; x < self.image.bitmapSize.x; x++) {
        for (int y = 0; y < self.image.bitmapSize.y; y++) {
            BMPoint point = BMPointMake(x, y);
            BMPixel color = [self.image getPixelAtPoint:point];
            BMPixel newColor = BMPixelMake(tintColor.red,
                                           tintColor.green,
                                           tintColor.blue,
                                           tintColor.alpha * color.alpha);
            [self.image setPixel:newColor atPoint:point];
        }
    }
    [self.image setNeedsUpdate:YES];
}

@end
