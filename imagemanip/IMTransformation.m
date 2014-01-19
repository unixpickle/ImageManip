//
//  IMTransformation.m
//  ImageManip
//
//  Created by Alex Nichol on 1/17/14.
//
//

#import "IMTransformation.h"

@implementation IMTransformation

+ (NSString *)commandName {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

+ (NSString *)summary {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

+ (NSString *)fullUsage {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)initWithImage:(ANImageBitmapRep *)image arguments:(NSArray *)args {
    if ((self = [super init])) {
        self.image = image;
    }
    return self;
}

- (void)perform {
}

@end
