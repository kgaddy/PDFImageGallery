//
//  PDFImageSection.m
//  PDFImages
//
//  Created by Kevin Gaddy on 12/31/15.
//  Copyright © 2015 Robert Gaddy LLC. All rights reserved.
//

#import "ImageAttribute.h"
#import "PDFColumnAttributes.h"
#import "PDFImageSection.h"
#import "PDFRowAttributes.h"

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

- (id)initWithPhotoArray:(NSArray *)images startY:(float)startY startX:(float)startX numberOfColumns:(int)numberOfColumns sectionWidth:(float)sectionWidth sectionHeight:(float)sectionHeight {
    self = [super init];
    if (self) {
        _startY = startY;
        _startX = startX;
        _images = images;
        _numberOfColumns = numberOfColumns;
        _sectionWidth = sectionWidth;
        _sectionHeight = sectionHeight;
        [self prepareLayout];
    }
    return self;
}

- (NSUInteger)shortestColumnIndex {
    NSUInteger retVal = 0;
    CGFloat shortestValue = MAXFLOAT;

    NSUInteger i = 0;
    for (PDFColumnAttributes *col in self.columnsAttributes) {
        float heightValue = col.columnHeight;
        if (heightValue < shortestValue) {
            shortestValue = heightValue;
            retVal = i;
        }
        i++;
    }
    return retVal;
}

- (NSUInteger)longestColumnIndex {
    NSUInteger retVal = 0;
    CGFloat longestValue = 0;

    NSUInteger i = 0;
    //  for (NSNumber *heightValue in self.columns) {
    for (PDFColumnAttributes *col in self.columnsAttributes) {
        float heightValue = col.columnHeight;
        if (heightValue > longestValue) {
            longestValue = heightValue;
            retVal = i;
        }
        i++;
    }
    return retVal;
}

- (float)columnWidth {
    float retVal = self.sectionWidth / self.numberOfColumns;
    retVal = roundf(retVal);
    return retVal;
}

- (float)imageRelativeHeight:(UIImage *)image {
    //  Base relative height for simple layout type. This is 1.0 (height equals to width)
    float retVal = 1.0;

    BOOL isDoubleColumn = NO;
    //[self collectionView:collectionView isDoubleColumnAtIndexPath:indexPath];
    if (isDoubleColumn) {
        //  Base relative height for double layout type. This is 0.75 (height equals to 75% width)
        retVal = 0.75;
    }

    /*  Relative height random modifier. The max height of relative height is 25% more than
         *  the base relative height */

    float extraRandomHeight = arc4random() % 25;
    retVal = retVal + (extraRandomHeight / 100);
    return retVal;
}

- (void)prepareLayout {
    self.idealHeight = self.sectionHeight / 2;
    self.resizedImages = [[NSMutableArray alloc] init];
    self.imageWidths = [[NSMutableArray alloc] init];
    self.numberOfRows = [self perfectRowNumber];
    for (UIImage *image in self.images) {
        UIImage *img = [self scaledToHeight:self.idealHeight image:image];
        [self.imageWidths addObject:[NSNumber numberWithInt:(int)img.size.width]];
        [self.resizedImages addObject:img];
    }
    // NSArray *array = [self linearPartition];
    NSArray *array = [self greedySolution];

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

- (float)pixelsToTrimOffEachImageWithTotalImageHeight:(float)totalImageHeight numberOfImages:(int)numberOfImages areaHeight:(float)areaHeight {
    float overflow = totalImageHeight - areaHeight;
    if (overflow > 0) {
        float pixelsToRemove = overflow / numberOfImages;
        return pixelsToRemove;
    } else {
        return 0;
    }
}

- (float)pixelsHeightOverflow:(float)totalImageHeight areaHeight:(float)areaHeight {
    float overflow = totalImageHeight - areaHeight;
    if (overflow > 0) {
        float pixelsToRemove = overflow;
        return pixelsToRemove;
    } else {
        return 0;
    }
}

- (float)calculateAreaWithImages:(NSArray *)images {
    float area = 0;
    for (UIImage *img in images) {
        area = area + (img.size.height * img.size.width);
    }
    return area;
}

- (float)getimagePercentOdAreaWithImageArea:(float)imageArea boundingArea:(float)boundingArea {
    return (boundingArea / imageArea) * 100;
}

- (int)perfectRowNumber {
    self.idealHeight = self.sectionHeight / 2;
    float totalWidth = 0;
    for (UIImage *image in self.images) {
        UIImage *img = [self scaledToHeight:self.idealHeight image:image];
        totalWidth = totalWidth + img.size.width;
    }
    int val = (self.sectionWidth + totalWidth - 1) / self.sectionWidth;
    return val;
}

/**
 * Example: linear_partition([9,2,6,3,8,5,8,1,7,3,4], 3) => [[9,2,6,3],[8,5,8],[1,7,3,4]]
 * @param NSarray seq
 * @param int k
 * @return NSarray
 */
- (NSArray *)linearPartition {
    //prep
    int k = (int)self.numberOfRows;
    NSArray *seq = [self.imageWidths copy];
    /*
    if ($k <= 0) {
        return array();
    }

     */
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    if (k <= 0) {
        return [returnArray copy];
    }

    //$n = count($seq) - 1;
    int n = (int)seq.count - 1;

    /*
     if ($k > $n) {
        return array_map(function ($x) {
        return array($x);
        }, $seq);
     }
     */

    if (k > n) {
        for (NSNumber *value in seq) {
            NSMutableArray *array = [[NSMutableArray alloc] init];
            [array addObject:value];
            [returnArray addObject:array];
        }
        return [returnArray copy];
    }

    /*
     list($table, $solution) = $this->linear_partition_table($seq, $k);
     $k = $k - 2;
     $ans = array();
     */

    NSArray *tables = [self linearPartitionTable:k seq:seq];

    NSMutableArray *table = [tables objectAtIndex:0];
    NSMutableArray *solution = [tables objectAtIndex:1];
    k = k - 2;
    NSMutableArray *ans = [[NSMutableArray alloc] init];

    /*
     while ($k >= 0) {
        $ans = array_merge(array(array_slice($seq, $solution[$n - 1][$k] + 1, $n - $solution[$n - 1][$k])), $ans);
        $n = $solution[$n - 1][$k];
        $k = $k - 1;
     }
     */

    while (k >= 0) {
        int startIndex = (int)[[solution objectAtIndex:n - 1] objectAtIndex:k + 1];
        int endIndex = n - (int)[[solution objectAtIndex:n - 1] objectAtIndex:k];
        NSArray *arrayOne = [seq subarrayWithRange:NSMakeRange(startIndex, endIndex)];
        [ans addObjectsFromArray:arrayOne];
        k--;
    }

    //return array_merge(array(array_slice($seq, 0, $n + 1)), $ans);
    NSArray *arrayOne = [seq subarrayWithRange:NSMakeRange(0, n + 1)];
    [ans addObject:arrayOne];
    //[ans addObjectsFromArray:arrayOne];
    return [ans copy];
}

//http://stackoverflow.com/questions/7938809/dynamic-programming-linear-partitioning-please-help-grok/7942946#7942946
- (NSArray *)linearPartitionTable:(int)k seq:(NSArray *)seq {
    // $n = count($seq);
    int n = (int)seq.count;

    //$table = array_fill(0, $n, array_fill(0, $k, 0));
    NSMutableArray *table = [[NSMutableArray alloc] init];
    for (int i = 0; i <= n; i++) {
        NSMutableArray *arry = [[NSMutableArray alloc] init];
        for (int ii = 0; ii <= k; ii++) {
            [arry addObject:[NSNumber numberWithInt:0]];
        }
        [table addObject:arry];
    }

    //$solution = array_fill(0, $n - 1, array_fill(0, $k - 1, 0));
    NSMutableArray *solution = [[NSMutableArray alloc] init];
    for (int i = 0; i <= n - 1; i++) {
        NSMutableArray *arry = [[NSMutableArray alloc] init];
        for (int ii = 0; ii <= k - 1; ii++) {
            [arry addObject:[NSNumber numberWithInt:0]];
        }
        [solution addObject:arry];
    }

    /*
     for ($i = 0; $i < $n; $i++) {
        $table[$i][0] = $seq[$i] + ($i ? $table[$i - 1][0] : 0);
     }
     */
    for (int i = 0; i < n; i++) {
        float val = 0;
        if (i == 0) {
            val = (int)[seq objectAtIndex:i];
            [[table objectAtIndex:i] replaceObjectAtIndex:0 withObject:[NSNumber numberWithInt:val]];

        } else {
            NSArray *previousArray = [table objectAtIndex:i - 1];
            val = [[seq objectAtIndex:i] floatValue] + [[previousArray objectAtIndex:0] floatValue];
            [[table objectAtIndex:i] replaceObjectAtIndex:0 withObject:[NSNumber numberWithInt:val]];
        }
    }

    /*
     for ($j = 0; $j < $k; $j++) {
        $table[0][$j] = $seq[0];
     }
     */
    NSMutableArray *firstTableArray = [[NSMutableArray alloc] init];
    for (int j = 0; j < k + 1; j++) {
        [firstTableArray addObject:[NSNumber numberWithInt:(int)[seq objectAtIndex:0]]];
        // [[table objectAtIndex:0] replaceObjectAtIndex:j withObject:[NSNumber numberWithInt:(int)[seq objectAtIndex:0]]];
    }
    [table replaceObjectAtIndex:0 withObject:firstTableArray];
    /*
     for ($i = 1; $i < $n; $i++) {
        for ($j = 1; $j < $k; $j++) {
            $current_min = null;
            $minx = PHP_INT_MAX;
 
            for ($x = 0; $x < $i; $x++) {
                $cost = max($table[$x][$j - 1], $table[$i][0] - $table[$x][0]);
                if ($current_min === null || $cost < $current_min) {
                    $current_min = $cost;
                    $minx = $x;
                }
            }
 
            $table[$i][$j] = $current_min;
            $solution[$i - 1][$j - 1] = $minx;
     }
 }
 */

    // NSMutableArray *tableTemp = [[NSMutableArray alloc]init];
    for (int i = 1; i < n; i++) {
        for (int j = 1; j < k; j++) {
            float current_min = 0;
            int minx = 2147483647;

            for (int x = 0; x < i; x++) {
                //cost = max($table[$x][$j - 1], $table[$i][0] - $table[$x][0]);
                NSNumber *valueOne = [[table objectAtIndex:x] objectAtIndex:j + 1];
                NSNumber *valueTwo = [[table objectAtIndex:i] objectAtIndex:0];
                NSNumber *valueThree = [[table objectAtIndex:x] objectAtIndex:0];
                NSArray *values = [NSArray arrayWithObjects:valueOne, valueTwo, valueThree, nil];
                float cost = [self maxValue:values];
                if (cost < current_min) {
                    current_min = cost;
                    minx = x;
                }
            }

            //[tableTemp addObject:[NSNumber numberWithFloat:current_min]];
            NSArray *tempArray = [[table objectAtIndex:i] copy];
            if (tempArray.count - 1 >= j) { //check to see if its here if not add
                [[table objectAtIndex:i] replaceObjectAtIndex:j withObject:[NSNumber numberWithFloat:current_min]];
            } else {
                [table addObject:[NSNumber numberWithFloat:current_min]];
            }

            // [[table objectAtIndex:i] replaceObjectAtIndex:j withObject:[NSNumber numberWithFloat:current_min]];
            NSArray *tempSolArray = [[solution objectAtIndex:i - 1] copy];
            if (tempSolArray.count - 1 >= j - 1) {
                [[solution objectAtIndex:i - 1] replaceObjectAtIndex:j - 1 withObject:[NSNumber numberWithFloat:minx]];
            } else {
                [solution addObject:[NSNumber numberWithFloat:minx]];
            }
        }
    }

    NSArray *tables = [NSArray arrayWithObjects:table, solution, nil];

    return tables;
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
- (NSArray *)greedySolution {
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

@end
