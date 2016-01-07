//
//  PDFImageColumn.h
//  PDFImages
//
//  Created by Kevin Gaddy on 1/3/16.
//  Copyright © 2016 Robert Gaddy LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImageAttribute.h"
@interface PDFColumnAttributes : NSObject
@property (assign, nonatomic) float columnHeight;
@property (strong, nonatomic) NSMutableArray *imageAttributes;
@property (assign, nonatomic) float highestSize;
@end
