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
@property (readonly, nonatomic) float padding;
@property (readonly, nonatomic) float sectionHeight;
@property (assign, nonatomic) float sectionWidth;
@property (assign, nonatomic) float startY;
@property (assign, nonatomic) float startX;
@property (strong, nonatomic) NSMutableArray *columnsAttributes;
@property (strong, nonatomic) NSMutableArray *rowAttributes;
@property (nonatomic, assign) float pageHeight;
@property (strong, nonatomic) NSMutableArray *imageAttributes;
- (id)initWithPhotoArray:(NSArray *)images startY:(float)startY startX:(float)startX sectionWidth:(float)sectionWidth sectionHeight:(float)sectionHeight padding:(float)padding;
@end
