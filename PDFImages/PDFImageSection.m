//
//  PDFImageSection.m
//  PDFImages
//
//  Created by Kevin Gaddy on 12/31/15.
//  Copyright © 2015 Robert Gaddy LLC. All rights reserved.
//

#import "PDFImageAttribute.h"
#import "PDFImageSection.h"

@interface PDFImageSection ()
@property (assign, nonatomic) NSUInteger shortestColumnIndex;
@property (assign, nonatomic) NSUInteger longestColumnIndex;
@property (assign, nonatomic) NSUInteger numberOfRows;
@property (assign, nonatomic) float idealHeight;
@property (strong, nonatomic) NSMutableArray *rows;
@property (strong, nonatomic) NSMutableArray *resizedImages;
@property (strong, nonatomic) NSMutableArray *imageWidths;
@end

#define kPadding 5
#define kPaddingHorz 20
#define kPageHeight 792
#define kHeightModule 40
@implementation PDFImageSection

- (id)initWithPhotoArray:(NSArray *)images startY:(float)startY startX:(float)startX sectionWidth:(float)sectionWidth sectionHeight:(float)sectionHeight padding:(float)padding {
    self = [super init];
    if (self) {
        _startY = startY;
        _startX = startX;
        _images = images;
        _sectionWidth = sectionWidth;
        _sectionHeight = sectionHeight;
        _padding = padding;
        [self prepareLayout];
    }
    return self;
}

- (void)prepareLayout {
    [self setInitialValues];
    [self resizeIdealHeightToFitSectionHeight];
    [self resizeImagesToIdealHeight];
    [self implementGreedySolution];
    [self setImageAttributes];
}

- (UIImage *)scaledToWidth:(float)scaledToWidth image:(UIImage *)image {
    float oldWidth = image.size.width;
    float scaleFactor = scaledToWidth / oldWidth;

    float newHeight = image.size.height * scaleFactor;
    float newWidth = oldWidth * scaleFactor;

    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));

    [image drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage *)scaledToHeight:(float)scaledToHeight image:(UIImage *)image {
    float oldHeight = image.size.height;
    float scaleFactor = scaledToHeight / oldHeight;

    float newWidth = image.size.width * scaleFactor;
    float newHeight = oldHeight * scaleFactor;

    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));

    [image drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage *)resizedImageWithPercent:(CGFloat)percent image:(UIImage *)image {
    double width = (percent * image.size.width) / 100;
    double height = (percent * image.size.height) / 100;
    CGSize size = CGSizeMake(width, height);
    UIGraphicsBeginImageContext(size);

    [image drawInRect:CGRectMake(0.0f, 0.0f, size.width, size.height)];

    // An autoreleased image
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    return newImage;
}

- (int)perfectRowNumberWidthHeight:(float)height sectionWidth:(float)sectionWidth images:(NSArray *)images {
    float totalWidth = 0;
    for (UIImage *image in images) {
        UIImage *img = [self scaledToHeight:height image:image];
        totalWidth = totalWidth + img.size.width;
    }
    int val = (sectionWidth + totalWidth - 1) / sectionWidth;
    if (val > images.count) {
        val = (int)images.count;
    }
    return val;
}

// get max value
- (float)maxValue:(NSArray *)arrValue {
    float maxValue = 0.0;
    for (NSString *value in arrValue) {
        float compareValue = [value floatValue];

        if (compareValue > maxValue) {
            maxValue = compareValue;
        }
    }

    return maxValue;
}

/*greedy solution*/
- (NSArray *)implementGreedySolution {
    int k = (int)self.numberOfRows;
    NSMutableArray *results = [[NSMutableArray alloc] init];
    NSMutableArray *resultsTotal = [[NSMutableArray alloc] init];

    NSSortDescriptor *sortOrder = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:NO];
    NSArray *sortedNumbers = [[self.imageWidths copy] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortOrder]];

    for (int i = 0; i < k; i++) {
        NSMutableArray *firstArray = [[NSMutableArray alloc] init];
        NSNumber *value = [sortedNumbers objectAtIndex:i];
        [firstArray addObject:value];
        [results addObject:firstArray];
        [resultsTotal addObject:value];
    }
    for (int i = k; i < sortedNumbers.count; i++) {
        NSNumber *value = [sortedNumbers objectAtIndex:i];
        NSNumber *insertIndex = [self getIndexOfSmallestRow:results];

        [[results objectAtIndex:[insertIndex intValue]] addObject:[NSNumber numberWithInt:[value intValue]]];
    }

    NSMutableArray *groupsByImage = [[NSMutableArray alloc] init];

    for (NSMutableArray *array in results) {
        NSMutableArray *images = [[NSMutableArray alloc] init];
        for (NSNumber *width in array) {
            UIImage *selectedImage;
            for (UIImage *img in self.resizedImages) {
                if (img.size.width == [width doubleValue]) {
                    selectedImage = img;
                    [images addObject:img];
                    break;
                }
            }
            [self.resizedImages removeObject:selectedImage];
        }
        [groupsByImage addObject:images];
    }

    self.resizedImages = groupsByImage;

    return [results copy];
}

- (NSNumber *)getIndexOfSmallestRow:(NSArray *)array {
    NSNumber *index = [NSNumber numberWithInt:0];
    NSNumber *small = [NSNumber numberWithInt:0];
    for (int i = 0; i < array.count; i++) {
        NSArray *smallArray = [array objectAtIndex:i];
        NSNumber *temp = 0;
        for (int j = 0; j < smallArray.count; j++) {
            temp = [NSNumber numberWithFloat:[temp floatValue] + [[smallArray objectAtIndex:j] floatValue]];
        }
        if (temp < small || i == 0) {
            small = temp;
            index = [NSNumber numberWithInt:i];
        }
    }

    return index;
}

- (CGFloat)getSumOfWidthsFromArray:(NSArray *)array {
    CGFloat width = 0.0;

    for (int i = 0; i < array.count; i++) {
        UIImage *img = [array objectAtIndex:i];
        width = width + img.size.width;
    }

    return width;
}

- (UIImage *)addPaddingAroundImage:(UIImage *)image padding:(float)padding {
    // Setup a new context with the correct size
    CGFloat width = image.size.width + (self.padding * 4);
    CGFloat height = image.size.height + (self.padding * 4);
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, height), NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(context);

    // Now we can draw anything we want into this new context.
    CGPoint origin = CGPointMake((width - image.size.width) / 2.0f,
                                 (height - image.size.height) / 2.0f);
    [image drawAtPoint:origin];

    // Clean up and get the new image.
    UIGraphicsPopContext();
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return newImage;
}

- (void)setInitialValues {
    self.idealHeight = self.sectionHeight / 2;
    self.resizedImages = [[NSMutableArray alloc] init];
    self.imageWidths = [[NSMutableArray alloc] init];
    self.numberOfRows = [self perfectRowNumberWidthHeight:self.idealHeight sectionWidth:self.sectionWidth images:[self.images copy]];
}

- (void)resizeIdealHeightToFitSectionHeight {
    if (self.numberOfRows * self.idealHeight > self.sectionHeight) {
        self.idealHeight = self.sectionHeight / self.numberOfRows;
    }
}

- (void)resizeImagesToIdealHeight {
    for (UIImage *image in self.images) {
        if (image.size.height != self.idealHeight) {
            UIImage *img = [self scaledToHeight:self.idealHeight image:[self addPaddingAroundImage:image padding:self.padding]];
            [self.imageWidths addObject:[NSNumber numberWithInt:(int)img.size.width]];
            [self.resizedImages addObject:img];
        }
    }
}

- (void)setImageAttributes {
    self.imageAttributes = [[NSMutableArray alloc] init];
    int rowNumber = 0;
    CGFloat rowWidth = self.startX;
    CGFloat height = self.idealHeight;
    CGFloat startY = 0.0;
    for (NSMutableArray *array in self.resizedImages) {
        NSMutableArray *workingArray = array;
        //check width
        CGFloat width = [self getSumOfWidthsFromArray:workingArray];

        NSMutableArray *resizedArray = [[NSMutableArray alloc] init];
        float precentage = (100 * self.sectionWidth) / width;
        for (UIImage *img in workingArray) {
            UIImage *newImage = [self resizedImageWithPercent:precentage image:img];
            [resizedArray addObject:newImage];
        }
        workingArray = resizedArray;

        for (UIImage *img in workingArray) {
            PDFImageAttribute *ia = [[PDFImageAttribute alloc] init];
            ia.image = img;

            CGRect frame = CGRectMake(rowWidth, startY, img.size.width, img.size.height);
            height = img.size.height;
            ia.frame = frame;
            [self.imageAttributes addObject:ia];
            rowWidth = rowWidth + img.size.width;
        }
        startY = startY + height;
        rowWidth = self.startX;

        rowNumber++;
    }
}

@end
