//
//  IMScaleTransformation.m
//  ImageManip
//
//  Created by Alex Nichol on 1/17/14.
//
//

#import "IMScaleTransformation.h"

@implementation IMScaleTransformation

+ (NSString *)commandName {
    return @"scale";
}

+ (NSString *)fullUsage {
    return @"[--style stretch|fit|fill] ...\n"
           @" ...   --width x --height y |or| --both x\n"
           @"       (sizes must either be #px or #% just like CSS)";
}

+ (NSString *)summary {
    return @"resize image(s)";
}

- (id)initWithImage:(ANImageBitmapRep *)image arguments:(NSArray *)args {
    if ((self = [super initWithImage:image arguments:args])) {
        NSDictionary * parsed = [IMArguments dictionaryForInput:args
                                                          flags:nil
                                                        regular:@[@"width", @"height", @"both", @"style"]];
        if (parsed[@"both"]) {
            widthSize = parsed[@"both"];
            heightSize = widthSize;
        } else if (parsed[@"width"] && parsed[@"height"]) {
            widthSize = parsed[@"width"];
            heightSize = parsed[@"height"];
        } else {
            @throw [NSException exceptionWithName:@"IMArguments"
                                           reason:@"missing --width --height or --both arguments."
                                         userInfo:nil];
        }
        style = parsed[@"style"];
    }
    return self;
}

- (void)perform {
    CGSize newSize = CGSizeMake(self.image.bitmapSize.x, self.image.bitmapSize.y);
    newSize.width = [self applySize:widthSize toSize:newSize.width];
    newSize.height = [self applySize:heightSize toSize:newSize.height];
    if (!style || [style isEqualToString:@"stretch"]) {
        [self.image setSize:BMPointFromSize(newSize)];
    } else if ([style isEqualToString:@"fill"]) {
        [self.image setSizeFillingFrame:BMPointFromSize(newSize)];
    } else if ([style isEqualToString:@"fit"]) {
        [self.image setSizeFittingFrame:BMPointFromSize(newSize)];
    } else {
        @throw [NSException exceptionWithName:@"IMArguments"
                                       reason:[NSString stringWithFormat:@"unknown style: %@", style]
                                     userInfo:nil];
    }
}

- (CGFloat)applySize:(NSString *)size toSize:(CGFloat)number {
    if ([size hasSuffix:@"px"]) {
        NSString * dim = [size substringWithRange:NSMakeRange(0, size.length - 2)];
        CGFloat value = (CGFloat)[dim doubleValue];
        if (value == 0) {
            @throw [NSException exceptionWithName:@"IMScaleInvalid"
                                           reason:[NSString stringWithFormat:@"invalid size parameter: %@", size]
                                         userInfo:nil];
        }
        return value;
    } else if ([size hasSuffix:@"%"]) {
        NSString * dim = [size substringWithRange:NSMakeRange(0, size.length - 1)];
        CGFloat value = (CGFloat)[dim doubleValue];
        if (value == 0) {
            @throw [NSException exceptionWithName:@"IMScaleInvalid"
                                           reason:[NSString stringWithFormat:@"invalid size parameter: %@", size]
                                         userInfo:nil];
        }
        return value * number / 100.0;
    } else {
        return [self applySize:[NSString stringWithFormat:@"%@px", size] toSize:number];
    }
}

@end
