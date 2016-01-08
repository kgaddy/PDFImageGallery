//
//  ViewController.m
//  PDFImages
//
//  Created by Kevin Gaddy on 12/31/15.
//  Copyright © 2015 Robert Gaddy LLC. All rights reserved.
//

#import "ImageAttribute.h"
#import "PDFImageSection.h"
#import "ViewController.h"
@interface ViewController ()

@end
#define kPageWidth 612
#define kPageHeight 792
@implementation ViewController

- (id)initWithFileName:(NSString *)fileName title:(NSString *)title {
    self = [super init];
    if (self) {
        _selectedFile = fileName;
        _name = title;
        _pdfViewer = ({
            UIWebView *view = [[UIWebView alloc] init];
            [view setTranslatesAutoresizingMaskIntoConstraints:NO];

            view;
        });

        [self.view addSubview:_pdfViewer];
        [self addConstraints];
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createPDF];
}

- (void)createPDF {
    self.pageSize = CGSizeMake(kPageWidth, kPageHeight);

    NSString *newPDFName = [NSString stringWithFormat:@"%@.pdf", @"test"];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];

    NSString *pdfPath = [documentsDirectory stringByAppendingPathComponent:newPDFName];

    UIGraphicsBeginPDFContextToFile(pdfPath, CGRectZero, nil);
    UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, self.pageSize.width, self.pageSize.height), nil);

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

    CGRect textRect = [self addText:@"Test" withFrame:CGRectMake(10, 20, 400, 100) fontSize:16];
    CGRect boundingRect = CGRectMake(10, textRect.origin.y + textRect.size.height + 20, kPageWidth - 20, 400);
    [self addLineWithFrame:boundingRect withColor:[UIColor redColor]];

    PDFImageSection *pdfSection = [[PDFImageSection alloc] initWithPhotoArray:[mImageArray copy] startY:boundingRect.origin.y startX:boundingRect.origin.x sectionWidth:boundingRect.size.width sectionHeight:boundingRect.size.height padding:4];

    for (ImageAttribute *ia in pdfSection.imageAttributes) {
        [self addImage:ia.image atPoint:CGPointMake(ia.frame.origin.x, ia.frame.origin.y)];
    }

    [self addText:@"Test" withFrame:CGRectMake(10, 20, 400, 100) fontSize:16];
    UIGraphicsEndPDFContext();

    NSArray *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);

    //Define new path for database in the documents directory because data cannot be written in the resource folder.
    NSString *pdfDocPath = [[docPath objectAtIndex:0] stringByAppendingPathComponent:@"test.pdf"];
    NSURL *pdfURL = [[NSURL alloc] initFileURLWithPath:pdfDocPath];
    NSURLRequest *pdfReq = [[NSURLRequest alloc] initWithURL:pdfURL];
    [self.pdfViewer loadRequest:pdfReq];
}

- (CGRect)addImage:(UIImage *)image atPoint:(CGPoint)point {
    CGRect imageFrame = CGRectMake(point.x, point.y, image.size.width, image.size.height);
    [image drawInRect:imageFrame];
    return imageFrame;
}

- (void)viewDidUnload {
    [self setPdfViewer:nil];

    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)addConstraints {
    id views = @{ @"pdfViewer": self.pdfViewer };
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-64-[pdfViewer]-|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[pdfViewer]|" options:0 metrics:nil views:views]];
}

- (CGRect)addText:(NSString *)text withFrame:(CGRect)frame fontSize:(float)fontSize {
    UIFont *font = [UIFont systemFontOfSize:fontSize];

    CGSize size = [text sizeWithAttributes:
                            @{NSFontAttributeName: font}];

    // Values are fractional -- you should take the ceilf to get equivalent values
    CGSize stringSize = CGSizeMake(ceilf(size.width), ceilf(size.height));

    float textWidth = frame.size.width;

    if (textWidth < stringSize.width)
        textWidth = stringSize.width;
    if (textWidth > self.pageSize.width)
        textWidth = self.pageSize.width - frame.origin.x;

    CGRect renderingRect = CGRectMake(frame.origin.x, frame.origin.y, textWidth, stringSize.height);

    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    /// Set line break mode
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    /// Set text alignment
    paragraphStyle.alignment = NSTextAlignmentLeft;

    NSDictionary *attributes = @{NSFontAttributeName: font,
                                 NSParagraphStyleAttributeName: paragraphStyle};

    [text drawInRect:renderingRect withAttributes:attributes];

    frame = CGRectMake(frame.origin.x, frame.origin.y, textWidth, stringSize.height);
    return frame;
}

- (CGRect)addLineWithFrame:(CGRect)frame withColor:(UIColor *)color {
    CGContextRef currentContext = UIGraphicsGetCurrentContext();

    CGContextSetStrokeColorWithColor(currentContext, color.CGColor);

    // this is the thickness of the line
    CGContextSetLineWidth(currentContext, frame.size.height);

    //CGPoint startPoint = frame.origin;
    CGPoint startPoint = CGPointMake(frame.origin.x, frame.origin.y + 200);
    CGPoint endPoint = CGPointMake(frame.origin.x + frame.size.width, frame.origin.y + 200);

    CGContextBeginPath(currentContext);
    CGContextMoveToPoint(currentContext, startPoint.x, startPoint.y);
    CGContextAddLineToPoint(currentContext, endPoint.x, endPoint.y);

    CGContextClosePath(currentContext);
    CGContextDrawPath(currentContext, kCGPathFillStroke);

    return frame;
}

@end
