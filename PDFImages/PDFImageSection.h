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
@property (strong, nonatomic) NSArray *images;
@property (readonly, nonatomic) float sectionHeight;
@property (assign, nonatomic) float sectionWidth;
@property (assign, nonatomic) float startY;
@property (assign, nonatomic) float startX;
@property (assign, nonatomic) int numberOfColumns;
@property (assign, nonatomic) float columnWidth;
@property (strong, nonatomic) NSMutableArray *columnsAttributes;
@property (strong, nonatomic) NSMutableArray *rowAttributes;
@property (nonatomic, assign) float pageHeight;
@property (strong, nonatomic) NSMutableArray *imageAttributes;
- (id)initWithPhotoArray:(NSArray *)images startY:(float)startY startX:(float)startX numberOfColumns:(int)numberOfColumns sectionWidth:(float)sectionWidth sectionHeight:(float)sectionHeight;
- (float)pixelsToTrimOffEachImageWithTotalImageHeight:(float)totalImageHeight numberOfImages:(int)numberOfImages areaHeight:(float)areaHeight;
@end
