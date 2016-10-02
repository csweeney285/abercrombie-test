//
//  ViewController.h
//  A&F Test
//
//  Created by Conor Sweeney on 9/30/16.
//  Copyright © 2016 csweeney. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardInfo.h"
#import <QuartzCore/QuartzCore.h>
#import <WebKit/WebKit.h>

@interface ViewController : UIViewController <UIPopoverPresentationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *myScrollView;
@property float yIndex;
@property (strong, nonatomic) NSMutableArray *cardInfoArray;

//button info
//store button url in array here and tag the button with the index
@property int buttonTag;
@property (strong, nonatomic) NSMutableArray *buttonArray;

-(void)downloadJSON;
-(void)createCardView: (CardInfo*)cardInfo;
-(void)resizeToFitSubviews:(UIView*)resizedView;
+(UIImage*)imageWithImage: (UIImage*) sourceImage scaledToWidth: (float) i_width;

//popover pc for webviews
@property (strong,nonatomic) UIPopoverPresentationController *popPC;
@property (strong, nonatomic)WKWebView *webView;

//photo count
@property int photoCount;
@property int photoDownloadCount;



@end

