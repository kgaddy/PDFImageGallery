//
//  ViewController.h
//  PDFImages
//
//  Created by Kevin Gaddy on 12/31/15.
//  Copyright © 2015 Robert Gaddy LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (strong, nonatomic) UIWebView *pdfViewer;
@property (strong, nonatomic) NSString *selectedFile;
@property (strong, nonatomic) NSString *name;
@property (nonatomic, assign) CGSize pageSize;
@property (nonatomic, assign) float pageHeight;
- (id)initWithFileName:(NSString *)fileName title:(NSString *)title;
@end
