//
//  PDFImageColumn.m
//  PDFImages
//
//  Created by Kevin Gaddy on 1/3/16.
//  Copyright © 2016 Robert Gaddy LLC. All rights reserved.
//

#import "PDFColumnAttributes.h"

@implementation PDFColumnAttributes

- (NSMutableArray *)imageAttributes {
    if (!_imageAttributes) {
        _imageAttributes = [[NSMutableArray alloc] init];
    }
    return _imageAttributes;
}

@end
