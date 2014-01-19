//
//  IMTintTransformation.h
//  ImageManip
//
//  Created by Alex Nichol on 1/19/14.
//
//

#import "IMTransformation.h"
#import "IMArguments.h"

@interface IMColorTransformation : IMTransformation {
    BMPixel tintColor;
}

@end
