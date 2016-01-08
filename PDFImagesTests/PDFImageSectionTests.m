//
//  PDFImageSectionTests.m
//  PDFImages
//
//  Created by Kevin Gaddy on 1/2/16.
//  Copyright © 2016 Robert Gaddy LLC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PDFImageSection.h"
@interface PDFImageSectionTests : XCTestCase
@property (strong, nonatomic) PDFImageSection *sut;
@end

@implementation PDFImageSectionTests

- (void)setUp {
    [super setUp];
    self.sut = [[PDFImageSection alloc] init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

@end
