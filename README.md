# imagemanip

The purpose of `imagemanip` is to provide an easy-to-use batch image modification service. In simpler terms, you can use it to do the same thing to a whole lot of images at once.

## Usage

The `imagemanip` command takes three initial arguments: *command*, *input*, and *output*. The *command* specifies what you would like to do to each image. The *input* should be a file path to either a single image file, or to a directory of images. When the *command* is applied to a file indicated by *input*, the result is written to *output* in one of two ways: if *input* was a directory, *output* will be created as a directory containing the resultant images; if *input* was a file, *output* will be a file with the resultant image.

### The `scale` command

Resizing images in batch can sometimes be necessary for an app or web developer. The `scale` command allows you to specify either relative or absolute dimensions. To scale images absolutely, use the `px` suffix:

    imagemanip scale input/ output/ --width 100px --height 150px
    imagemanip scale input/ output/ --both 100px

To scale images relative to their existing size, use the `%` suffix:

    imagemanip scale input/ output/ --width 100% --height 150%

### The `color` command

It is common to use an image mask to represent a particular shape. The color command makes it easy to take image masks like this and change their color. Under the hood, the command simply preserves the transparency of each pixel while changing its color.

There are two ways to specify color to `color`. My personal preference is to use `rgba(red,green,blue,alpha)`, where *red*, *green*, and *blue* are integers from 0 to 255 and *alpha* is a float from 0 to 1. The other option is to use an HTML-style hex color code.

    imagemanip color input/ output/ \#FF0000
    imagemanip color input/ output/ rgba\(128,128,0,1\)

# Creating New Commands

You can implement your own commands with ease! Just subclass the `IMTransformation` class and implement the following methods:

	// initialize or throw an exception if you don't like the args
	- (id)initWithImage:(ANImageBitmapRep *)image
	          arguments:(NSArray *)args;
    
	// perform your operation on self.image or throw an exception
	- (void)perform;
	
	+ (NSString *)commandName; // pretty straightforward
	+ (NSString *)summary; // description for help screen
	+ (NSString *)fullUsage; // for `imagemanip help commandName`

Then, in `main.m`, import `YourClass.h` and add `[YourClass class]` to the `classes` array.
