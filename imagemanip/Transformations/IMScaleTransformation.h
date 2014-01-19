//
//  IMScaleTransformation.h
//  ImageManip
//
//  Created by Alex Nichol on 1/17/14.
//
//

#import "IMTransformation.h"
#import "IMArguments.h"

@interface IMScaleTransformation : IMTransformation {
    NSString * widthSize;
    NSString * heightSize;
    NSString * style;
}

- (CGFloat)applySize:(NSString *)size toSize:(CGFloat)number;

@end
