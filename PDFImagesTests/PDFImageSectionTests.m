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
    NSMutableArray *mImageArray = [[NSMutableArray alloc] init];
    UIImage *imgOne = [UIImage imageNamed:@"one"];
    UIImage *imgTwo = [UIImage imageNamed:@"two"];
    UIImage *imgThree = [UIImage imageNamed:@"three"];
    UIImage *imgFour = [UIImage imageNamed:@"four"];
    UIImage *imgFive = [UIImage imageNamed:@"5"];
    UIImage *imgSix = [UIImage imageNamed:@"6"];
    [mImageArray addObject:imgOne];
    [mImageArray addObject:imgTwo];
    [mImageArray addObject:imgThree];
    [mImageArray addObject:imgFour];
    [mImageArray addObject:imgFive];
    [mImageArray addObject:imgSix];
    self.sut = [[PDFImageSection alloc] initWithPhotoArray:mImageArray startY:20 startX:20 sectionWidth:400 sectionHeight:400 padding:2];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testgetSumOfWidthsFromArray {
    NSMutableArray *mImageArray = [[NSMutableArray alloc] init];
    UIImage *imgOne = [UIImage imageNamed:@"one"];
    UIImage *imgTwo = [UIImage imageNamed:@"two"];
    [mImageArray addObject:imgOne];
    [mImageArray addObject:imgTwo];
    CGFloat answer = [self.sut getSumOfWidthsFromArray:[mImageArray copy]];
    XCTAssertTrue(answer == 4173);
}

- (void)testPerfectRowNumber {
    NSMutableArray *mImageArray = [[NSMutableArray alloc] init];
    UIImage *imgOne = [UIImage imageNamed:@"one"];
    UIImage *imgTwo = [UIImage imageNamed:@"two"];
    UIImage *imgThree = [UIImage imageNamed:@"three"];
    UIImage *imgFour = [UIImage imageNamed:@"four"];
    UIImage *imgFive = [UIImage imageNamed:@"5"];
    UIImage *imgSix = [UIImage imageNamed:@"6"];
    [mImageArray addObject:imgOne];
    [mImageArray addObject:imgTwo];
    [mImageArray addObject:imgThree];
    [mImageArray addObject:imgFour];
    [mImageArray addObject:imgFive];
    [mImageArray addObject:imgSix];
    int answer = [self.sut perfectRowNumberWidthHeight:200 sectionWidth:300 images:[mImageArray copy]];
    XCTAssertTrue(answer == 6);
}

@end
