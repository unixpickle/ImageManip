//
//  main.m
//  imagemanip
//
//  Created by Alex Nichol on 1/17/14.
//
//

#import <Foundation/Foundation.h>
#import "IMScaleTransformation.h"
#import "IMColorTransformation.h"

void printUsage(NSArray * classes);
int printDetailed(NSArray * classes, NSString * token);
int runTransformation(NSString * input, NSString * output,
                      Class class, NSArray * args);
void executeTransformation(NSString * path, NSString * outPath,
                           Class class, NSArray * args);

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // here goes the list of transformations
        NSArray * classes = @[[IMScaleTransformation class], [IMColorTransformation class]];
        
        // turn the arguments into NSArray
        NSMutableArray * arguments = [NSMutableArray array];
        for (int i = 0; i < argc; i++) {
            [arguments addObject:[NSString stringWithUTF8String:argv[i]]];
        }
        
        // print help if necessary
        if (arguments.count > 1) {
            if ([arguments[1] isEqualToString:@"help"]) {
                if (arguments.count == 2) {
                    printUsage(classes);
                    return 0;
                } else {
                    return printDetailed(classes, arguments[2]);
                }
            }
        }
        if (arguments.count < 4) {
            printUsage(classes);
            return 1;
        }
        
        // load the command
        Class command = Nil;
        for (Class c in classes) {
            if ([[c commandName] isEqualToString:arguments[1]]) {
                command = c;
                break;
            }
        }
        if (command == Nil) {
            fprintf(stderr, "unknown command: %s\n", [arguments[1] UTF8String]);
            return 1;
        }
        
        // execute the command
        @try {
            NSArray * args = [arguments subarrayWithRange:NSMakeRange(4, arguments.count - 4)];
            return runTransformation([arguments[2] stringByStandardizingPath],
                                     [arguments[3] stringByStandardizingPath],
                                     command, args);
        } @catch (NSException * e) {
            fprintf(stderr, "error: %s\n", e.reason.UTF8String);
            return 1;
        }
    }
    return 0;
}

void printUsage(NSArray * classes) {
    fprintf(stderr, "Usage: imagemanip <command> <input> <output> args...\n");
    fprintf(stderr, "\navailable commands:\n\n");
    fprintf(stderr, "  help            show help for a command\n");
    for (Class class in classes) {
        NSString * summary = [class summary];
        NSString * name = [class commandName];
        fprintf(stderr, "  %s", name.UTF8String);
        for (int i = 0; i < 16 - name.length; i++) {
            fprintf(stderr, " ");
        }
        fprintf(stderr, "%s\n", summary.UTF8String);
    }
    fprintf(stderr, "\n");
}

int printDetailed(NSArray * classes, NSString * token) {
    for (Class class in classes) {
        if ([[class commandName] isEqualToString:token]) {
            printf("Usage: %s <input> <output> %s\n", token.UTF8String,
                   [class fullUsage].UTF8String);
            return 0;
        }
    }
    fprintf(stderr, "unknown command: %s\n", token.UTF8String);
    return 1;
}

int runTransformation(NSString * input, NSString * output,
                      Class class, NSArray * args) {
    BOOL isDirectory = NO;
    if (![[NSFileManager defaultManager] fileExistsAtPath:input isDirectory:&isDirectory]) {
        fprintf(stderr, "input file does not exist: %s\n", input.UTF8String);
        return 1;
    }
    if (isDirectory) {
        // read the directory, create output directory, do each file
        if ([[NSFileManager defaultManager] fileExistsAtPath:output isDirectory:&isDirectory]) {
            if (!isDirectory) {
                fprintf(stderr, "output name already used: %s\n", output.UTF8String);
                return 1;
            }
        } else {
            BOOL result = [[NSFileManager defaultManager] createDirectoryAtPath:output
                                                    withIntermediateDirectories:NO
                                                                     attributes:nil
                                                                          error:nil];
            if (!result) {
                fprintf(stderr, "failed to create output directory: %s\n", output.UTF8String);
                return 1;
            }
        }
        NSArray * listing = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:input error:nil];
        for (NSString * file in listing) {
            if ([file hasPrefix:@"."]) continue;
            NSString * fullInput = [input stringByAppendingPathComponent:file];
            NSString * fullOutput = [output stringByAppendingPathComponent:file];
            fullOutput = [[fullOutput stringByDeletingPathExtension] stringByAppendingPathExtension:@"png"];
            executeTransformation(fullInput, fullOutput, class, args);
        }
    } else {
        // do one file
        executeTransformation(input, output, class, args);
    }
    return 0;
}

void executeTransformation(NSString * path, NSString * outPath,
                           Class class, NSArray * args) {
    printf("Applying to %s\n", path.lastPathComponent.UTF8String);
    NSImage * image = [[NSImage alloc] initWithContentsOfFile:path];
    if (!image) {
        fprintf(stderr, "error: failed to read image.\n");
        return;
    }
    ANImageBitmapRep * irep = [[ANImageBitmapRep alloc] initWithImage:image];
    IMTransformation * trans = [(IMTransformation *)[class alloc] initWithImage:irep arguments:args];
    [trans perform];
    
    CGImageRef cgImage = trans.image.CGImage;
    NSBitmapImageRep * newRep = [[NSBitmapImageRep alloc] initWithCGImage:cgImage];
    [newRep setSize:[image size]];
    NSData * pngData = [newRep representationUsingType:NSPNGFileType properties:nil];
    BOOL result = [pngData writeToFile:outPath atomically:YES];
    if (!result) {
        @throw [NSException exceptionWithName:@"IMWrite"
                                       reason:[NSString stringWithFormat:@"could not write to %@", outPath]
                                     userInfo:nil];
    }
}
