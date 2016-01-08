//
//  ImageAttribute.h
//  PDFImages
//
//  Created by Kevin Gaddy on 12/31/15.
//  Copyright © 2015 Robert Gaddy LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PDFImageAttribute : NSObject
@property (assign, nonatomic) CGRect frame;
@property (strong, nonatomic) UIImage *image;
@property (assign, nonatomic) NSUInteger columnIndex;
@end
