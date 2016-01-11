//
//  PDFImageSection.h
//  PDFImages
//
//  Created by Kevin Gaddy on 12/31/15.
//  Copyright © 2015 Robert Gaddy LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PDFImageSection : NSObject
@property (assign, nonatomic) float idealHeight;
@property (strong, nonatomic) NSArray *images;
@property (readonly, nonatomic) float padding;
@property (readonly, nonatomic) float sectionHeight;
@property (assign, nonatomic) float sectionWidth;
@property (assign, nonatomic) float startY;
@property (assign, nonatomic) float startX;
@property (nonatomic, assign) float pageHeight;
@property (assign, nonatomic) NSUInteger numberOfRows;
@property (strong, nonatomic) NSMutableArray *imageAttributes;
@property (strong, nonatomic) NSMutableArray *imageAttributesByRows;
@property (assign, nonatomic) float renderedSectionHeight;
@property (assign, nonatomic) BOOL resizeImageFitEven;
- (id)initWithPhotoArray:(NSArray *)images startY:(float)startY startX:(float)startX sectionWidth:(float)sectionWidth sectionHeight:(float)sectionHeight padding:(float)padding resizeImageFitEven:(BOOL)resizeImageFitEven;
- (CGFloat)getSumOfWidthsFromArray:(NSArray *)array;
- (int)perfectRowNumberWidthHeight:(float)height sectionWidth:(float)sectionWidth images:(NSArray *)images;
@end
