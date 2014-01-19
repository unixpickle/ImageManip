//
//  IMArguments.m
//  ImageManip
//
//  Created by Alex Nichol on 1/17/14.
//
//

#import "IMArguments.h"

@interface IMArguments (Private)

+ (void)raiseInvalidColor:(NSString *)color;
+ (void)parseRGBComponents:(NSArray *)list output:(CGFloat *)colors color:(NSString *)color;
+ (int)parseHexDigit:(NSString *)digit color:(NSString *)color;
+ (CGFloat)parseHexByte:(NSString *)pair color:(NSString *)color;

@end

@implementation IMArguments

+ (BMPixel)parseColor:(NSString *)color {
    if ([color hasPrefix:@"rgba("] && [color hasSuffix:@")"]) {
        NSString * body = [color substringWithRange:NSMakeRange(5, color.length - 6)];
        NSArray * comps = [body componentsSeparatedByString:@","];
        if (comps.count != 4) [self raiseInvalidColor:color];
        CGFloat colors[3];
        [self parseRGBComponents:comps output:colors color:color];
        NSCharacterSet * whitespace = [NSCharacterSet whitespaceCharacterSet];
        
        double alpha = [[comps[3] stringByTrimmingCharactersInSet:whitespace] doubleValue];
        return BMPixelMake(colors[0], colors[1], colors[2], alpha);
    } else if ([color hasPrefix:@"rgb("] && [color hasSuffix:@")"]) {
        NSString * body = [color substringWithRange:NSMakeRange(4, color.length - 5)];
        NSArray * comps = [body componentsSeparatedByString:@","];
        if (comps.count != 3) [self raiseInvalidColor:color];
        CGFloat colors[3];
        [self parseRGBComponents:comps output:colors color:color];
        return BMPixelMake(colors[0], colors[1], colors[2], 1);
    } else if ([color hasPrefix:@"#"]) {
        if (color.length == 7) {
            CGFloat red = [self parseHexByte:[color substringWithRange:NSMakeRange(1, 2)] color:color];
            CGFloat green = [self parseHexByte:[color substringWithRange:NSMakeRange(3, 2)] color:color];
            CGFloat blue = [self parseHexByte:[color substringWithRange:NSMakeRange(5, 2)] color:color];
            return BMPixelMake(red, green, blue, 1);
        } else if (color.length == 4) {
            CGFloat red = (CGFloat)[self parseHexDigit:[color substringWithRange:NSMakeRange(1, 1)] color:color] / 16.0;
            CGFloat green = (CGFloat)[self parseHexDigit:[color substringWithRange:NSMakeRange(2, 1)] color:color] / 16.0;
            CGFloat blue = (CGFloat)[self parseHexDigit:[color substringWithRange:NSMakeRange(3, 1)] color:color] / 16.0;
            return BMPixelMake(red, green, blue, 1);
        } else [self raiseInvalidColor:color];
    }
    
    [self raiseInvalidColor:color];
    return BMPixelMake(0, 0, 0, 0);
}

+ (NSDictionary *)dictionaryForInput:(NSArray *)args flags:(NSArray *)specific regular:(NSArray *)regular {
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    for (NSInteger i = 0; i < args.count; i++) {
        NSString * argument = args[i];
        if (![argument hasPrefix:@"--"]) {
            @throw [NSException exceptionWithName:@"IMInvalidArgument"
                                           reason:[NSString stringWithFormat:@"invalid argument: %@", argument]
                                         userInfo:nil];
        }
        argument = [argument substringFromIndex:2];
        if (dict[argument]) {
            @throw [NSException exceptionWithName:@"IMRepeatedArgument"
                                           reason:[NSString stringWithFormat:@"repeated argument: --%@", argument]
                                         userInfo:nil];
        }
        if ([specific containsObject:argument]) {
            dict[argument] = [NSNumber numberWithBool:YES];
        } else if ([regular containsObject:argument]) {
            if (i == args.count - 1) {
                @throw [NSException exceptionWithName:@"IMMissingArgument"
                                               reason:[NSString stringWithFormat:@"missing argument after --%@", argument]
                                             userInfo:nil];
            }
            dict[argument] = args[++i];
        } else {
            @throw [NSException exceptionWithName:@"IMUnknownArgument"
                                           reason:[NSString stringWithFormat:@"unknown argument: --%@", argument]
                                         userInfo:nil];
        }
    }
    return [dict copy];
}

#pragma mark - Private -

+ (void)raiseInvalidColor:(NSString *)color {
    @throw [NSException exceptionWithName:@"IMInvalidColor"
                                   reason:[NSString stringWithFormat:@"invalid color: %@", color]
                                 userInfo:nil];
}

+ (void)parseRGBComponents:(NSArray *)comps output:(CGFloat *)colors color:(NSString *)color {
    NSCharacterSet * whitespace = [NSCharacterSet whitespaceCharacterSet];
    for (int i = 0; i < 3; i++) {
        NSString * comp = [comps[i] stringByTrimmingCharactersInSet:whitespace];
        NSInteger value = [comp integerValue];
        if (!value && ![comp isEqualToString:@"0"]) {
            [self raiseInvalidColor:color];
        }
        if (value < 0 || value > 255) [self raiseInvalidColor:color];
        colors[i] = (CGFloat)value / 255.0;
    }
}

+ (int)parseHexDigit:(NSString *)digit color:(NSString *)color {
    NSArray * chars = @[@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9",
                        @"a", @"b", @"c", @"d", @"e", @"f"];
    if (![chars containsObject:digit.lowercaseString]) {
        [self raiseInvalidColor:color];
    }
    return (int)[chars indexOfObject:digit.lowercaseString];
}

+ (CGFloat)parseHexByte:(NSString *)pair color:(NSString *)color {
    int dig1 = [self parseHexDigit:[pair substringToIndex:1] color:color];
    int dig2 = [self parseHexDigit:[pair substringFromIndex:1] color:color];
    return (CGFloat)(dig1 * 16 + dig2) / 255.0;
}

@end
