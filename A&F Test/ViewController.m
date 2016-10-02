//
//  ViewController.m
//  A&F Test
//
//  Created by Conor Sweeney on 9/30/16.
//  Copyright © 2016 csweeney. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //set view frame programmatically
    //resizing the content mode does not work with constraints
    self.view.frame = [UIScreen mainScreen].bounds;
    self.myScrollView.frame = self.view.frame;
    // Do any additional setup after loading the view, typically from a nib.
    self.yIndex = 0;
    self.buttonTag = 0;
    self.buttonArray = [NSMutableArray new];
    self.cardInfoArray = [NSMutableArray new];
    [self downloadJSON];
    
    //add orientation change notification
    //only for ipad
    //disabled for iphone since the pictures grow far too large
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ){
        [[NSNotificationCenter defaultCenter]
         addObserver:self selector:@selector(changeOrientation)
         name:UIDeviceOrientationDidChangeNotification
         object:[UIDevice currentDevice]];
    }
}

-(void)downloadJSON{
    NSError *error;
    NSString *url_string = [NSString stringWithFormat: @"https://www.abercrombie.com/anf/nativeapp/qa/codetest/codeTest_exploreData.json"];
    NSData *data = [NSData dataWithContentsOfURL: [NSURL URLWithString:url_string]];
    NSMutableArray *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    int order = 0;
    for (NSDictionary *jsonDict in json) {
        NSLog(@"json: %@", jsonDict);
        
        //create a new card info object
        CardInfo *cardInfo = [[CardInfo alloc] init];
        cardInfo.content = [NSMutableArray new];
        
        //bottomDescription
        cardInfo.bottomDescription = [jsonDict valueForKey:@"bottomDescription"];
        
        //content
        NSArray *buttonArray = [jsonDict valueForKey:@"content"];
        for (NSDictionary* buttonDictionary in buttonArray) {
            ButtonInfo *buttonInfo = [ButtonInfo new];
            buttonInfo.target = [buttonDictionary valueForKey:@"target"];
            buttonInfo.title = [buttonDictionary valueForKey:@"title"];
            NSLog(@"%@",buttonDictionary);
            [cardInfo.content addObject:buttonInfo];
        }

        //promo message
        cardInfo.promoMessage = [jsonDict valueForKey:@"promoMessage"];

        //title
        cardInfo.title = [jsonDict valueForKey:@"title"];
        
        //topDescription
        cardInfo.topDescription = [jsonDict valueForKey:@"topDescription"];
        
        //get image url from dictionary and fetch it
        NSString *urlString = [jsonDict valueForKey:@"backgroundImage"];
        
        //add order
        cardInfo.order = order;
        order++;
 
        //check that url string exists
        if (![urlString isEqualToString:@""]) {
            //do not create card until the image is loaded
            //this may get the cards in a slightly sorted order however it will add them to the view as they load this way and is slightly simpler. If the task made order a priority I would add a order int property to the card info then load them after all cards were fully downloaded
            self.photoCount ++;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                           ^{
                               NSURL *imageUrl = [NSURL URLWithString:urlString];
                               NSData *data = [NSData dataWithContentsOfURL:imageUrl];
                               
                               //completion handler
                               dispatch_sync(dispatch_get_main_queue(), ^{
                                   //add card info to an array
                                   //this will be used to re create cards if the device is turned
                                   self.photoDownloadCount++;
                                   UIImage *cardImage = [[UIImage alloc] initWithData:data];
                                   cardInfo.backgroundImage = cardImage;
                                   if (self.photoDownloadCount == self.photoCount) {
                                       [self changeOrientation];
                                   }
                               });
                            
                           });
            
        }
        
        //else create the card view immediately
        // all cards at this json link do have photos but it is good to check
        //also checks that there is data in the card info and the json did not return an empty value
        if([cardInfo.bottomDescription length]==0 && [cardInfo.content count]==0 && [cardInfo.promoMessage length]==0 && [cardInfo.title length]==0 && [cardInfo.topDescription length]==0 &&[urlString length]==0){
            //do nothing
        }
        else{
            [self.cardInfoArray addObject:cardInfo];
        }

    }
}

-(void)createCardView:(CardInfo *)cardInfo{
    //get width
    CGFloat screenWidth = self.view.frame.size.width;
    
    UIView *cardView = [[UIView alloc] init];
    
    //top bar
    UIView *topBar = [[UIView alloc] initWithFrame:CGRectMake(0,0, screenWidth, 10)];
    topBar.backgroundColor = [UIColor lightGrayColor];
    
    [cardView addSubview:topBar];
    
    //image
    
    UIImageView *backgroundImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, topBar.frame.size.height, screenWidth, 100)];
    
    //resize the image
    float oldWidth = cardInfo.backgroundImage.size.width;
    float scaleFactor = screenWidth / oldWidth;
    
    float newHeight = cardInfo.backgroundImage.size.height * scaleFactor;
    float newWidth = oldWidth * scaleFactor;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [cardInfo.backgroundImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    backgroundImage.image = newImage;
    backgroundImage.contentMode = UIViewContentModeScaleToFill;

    //resize the image view to the image
    [backgroundImage sizeToFit];
    [cardView addSubview:backgroundImage];
    
    //top description
 
    //check if card info exists if not set the frame to zero
    //this prevents adding 20 to the y origin axis
    UILabel *topDescription = [[UILabel alloc]init];
    
    if ([cardInfo.topDescription length]==0) {
        topDescription.frame = CGRectMake(0, backgroundImage.frame.size.height + backgroundImage.frame.origin.y, screenWidth, 0);
    }
    else{
        topDescription.frame = CGRectMake(0, backgroundImage.frame.size.height + backgroundImage.frame.origin.y + 20, screenWidth, 0);
        [topDescription setText:cardInfo.topDescription];
        [topDescription setFont:[UIFont fontWithName:@"Trebuchet MS" size:13]];
        [topDescription setTextColor:[UIColor blackColor]];//Set text color in label.
        [topDescription setTextAlignment:NSTextAlignmentCenter];//Set text alignment in label.
        [topDescription setBaselineAdjustment:UIBaselineAdjustmentAlignBaselines];//Set line adjustment.
        [topDescription setLineBreakMode:NSLineBreakByWordWrapping];//Set linebreaking mode..
        [topDescription setNumberOfLines:0];//Set number of lines in label.
        [topDescription setClipsToBounds:YES];//Set its to YES for Corner radius to work.
        [topDescription sizeToFit];
        topDescription.center = CGPointMake(self.view.center.x, topDescription.center.y);
    }
    [cardView addSubview:topDescription];
    
    //title does not need this checked since its y origin axis is not added to
    UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(0, topDescription.frame.size.height + topDescription.frame.origin.y, screenWidth, 0)];
    [title setText: cardInfo.title];
    [title setFont:[UIFont fontWithName:@"Trebuchet MS-Bold" size:17]];
    [title setTextColor:[UIColor blackColor]];//Set text color in label.
    [title setTextAlignment:NSTextAlignmentCenter];//Set text alignment in label.
    [title setBaselineAdjustment:UIBaselineAdjustmentAlignBaselines];//Set line adjustment.
    [title setLineBreakMode:NSLineBreakByWordWrapping];//Set linebreaking mode..
    [title setNumberOfLines:0];//Set number of lines in label.
    [title setClipsToBounds:YES];//Set its to YES for Corner radius to work.
    [title sizeToFit];
    title.center = CGPointMake(self.view.center.x, title.center.y);

    
    [cardView addSubview:title];
    
    //same for promo
    UILabel *promoMessage = [[UILabel alloc]initWithFrame:CGRectMake(0, title.frame.size.height + title.frame.origin.y, screenWidth, 0)];
    [promoMessage setText:cardInfo.promoMessage];
    [promoMessage setFont:[UIFont fontWithName:@"Trebuchet MS" size:11]];
    [promoMessage setTextColor:[UIColor darkGrayColor]];//Set text color in label.
    [promoMessage setTextAlignment:NSTextAlignmentCenter];//Set text alignment in label.
    [promoMessage setBaselineAdjustment:UIBaselineAdjustmentAlignBaselines];//Set line adjustment.
    [promoMessage setLineBreakMode:NSLineBreakByWordWrapping];//Set linebreaking mode..
    [promoMessage setNumberOfLines:0];//Set number of lines in label.
    [promoMessage setClipsToBounds:YES];//Set its to YES for Corner radius to work.
    [promoMessage sizeToFit];
    promoMessage.center = CGPointMake(self.view.center.x, promoMessage.center.y);

    
    [cardView addSubview:promoMessage];

    
    //check bottom
    UILabel *bottomDescription = [[UILabel alloc]init];
    if ([cardInfo.bottomDescription length]==0) {
        bottomDescription.frame = CGRectMake(0, promoMessage.frame.size.height + promoMessage.frame.origin.y, screenWidth, 0);
    }
    else{
        bottomDescription.frame = CGRectMake(0, promoMessage.frame.size.height + promoMessage.frame.origin.y + 20, screenWidth, 0);
        NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[cardInfo.bottomDescription dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
        [bottomDescription setAttributedText:attrStr];
        [bottomDescription setFont:[UIFont fontWithName:@"Trebuchet MS" size:17]];
        [bottomDescription setTextColor:[UIColor grayColor]];//Set text color in label.
        [bottomDescription setTextAlignment:NSTextAlignmentCenter];//Set text alignment in label.
        [bottomDescription setBaselineAdjustment:UIBaselineAdjustmentAlignBaselines];//Set line adjustment.
        [bottomDescription setLineBreakMode:NSLineBreakByWordWrapping];//Set linebreaking mode..
        [bottomDescription setNumberOfLines:0];//Set number of lines in label.
        [bottomDescription setClipsToBounds:YES];//Set its to YES for Corner radius to work.
        [bottomDescription sizeToFit];
        bottomDescription.center = CGPointMake(self.view.center.x, bottomDescription.center.y);
    }
    

    
    [cardView addSubview:bottomDescription];

    //create buttons to add to view
    //make buttons width smaller than the whole screen
    UIView *content = [[UIView alloc] init];
    CGFloat buttonWidth = screenWidth * .75;
    CGFloat buttonHeight = screenWidth/8;
    int heightMultiplier = 0;
    for (ButtonInfo *buttonInfo in cardInfo.content ) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.tag = self.buttonTag;
        [button addTarget:self
                   action:@selector(buttonPress:)
         forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:buttonInfo.title forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont fontWithName:@"Trebuchet MS" size:15]];
        [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        button.frame = CGRectMake(0 ,heightMultiplier* (buttonHeight+10), buttonWidth, buttonHeight);
        button.layer.borderColor = [UIColor darkGrayColor].CGColor;
        button.layer.borderWidth = 1.0000;
        heightMultiplier++;
        self.buttonTag++;
        [self.buttonArray addObject:buttonInfo.target];
        [content addSubview:button];
    }
    
    [self resizeToFitSubviews:content];
    content.center = CGPointMake(self.myScrollView.center.x, bottomDescription.frame.origin.y + bottomDescription.frame.size.height + content.frame.size.height/2 + 20);
    [cardView addSubview:content];
    
    
    cardView.frame = CGRectMake(0, self.yIndex, self.myScrollView.frame.size.width, 10);
    [self resizeToFitSubviews:cardView];
    self.yIndex = self.yIndex + cardView.frame.size.height + 30;
    NSLog(@"%f",self.yIndex);
    [self.myScrollView addSubview:cardView];
    [self resizeScrollView];
    
}
-(void)resizeToFitSubviews:(UIView*)resizedView{
    float w = 0;
    float h = 0;
    
    for (UIView *v in resizedView.subviews) {
        float fw = v.frame.origin.x + v.frame.size.width;
        float fh = v.frame.origin.y + v.frame.size.height;
        w = MAX(fw, w);
        h = MAX(fh, h);
    }
    [resizedView setFrame:CGRectMake(resizedView.frame.origin.x, resizedView.frame.origin.y, w, h)];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)resizeScrollView{
    CGRect contentRect = CGRectZero;
    for (UIView *view in self.myScrollView.subviews) {
        contentRect = CGRectUnion(contentRect, view.frame);
    }
    CGSize newSize = CGSizeMake(contentRect.size.width, contentRect.size.height + 30);
    self.myScrollView.contentSize = newSize;
}

+(UIImage*)imageWithImage: (UIImage*) sourceImage scaledToWidth: (float) i_width{
    
    float oldWidth = sourceImage.size.width;
    float scaleFactor = i_width / oldWidth;
    
    float newHeight = sourceImage.size.height * scaleFactor;
    float newWidth = oldWidth * scaleFactor;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

//change orientation
//remove all subviews from the scroll view then re-add them using the saved card info

-(void)changeOrientation{
    //close popover if open
    [self doneButtonPress];
    
    //reset view frame
    self.view.frame = [UIScreen mainScreen].bounds;
    self.myScrollView.frame = self.view.frame;
    self.yIndex = 0;
    self.buttonTag = 0;
    
    //remove all cards
    [self.myScrollView.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    for (CardInfo *cardInfo in self.cardInfoArray ) {
        [self createCardView:cardInfo];
    }
    
}

-(void)buttonPress:(id)sender{
    NSLog(@"Button Index: %ld",(long)[sender tag]);
    
    //retrieve url from array at index of button tag
    NSString *url = [self.buttonArray objectAtIndex:[sender tag]];
    
    //create popover view for url
    UIViewController *viewForPop = [[UIViewController alloc] init];
    viewForPop.view.frame = CGRectMake(10, 10, self.view.frame.size.width-20, self.view.frame.size.height-20);
    viewForPop.view.backgroundColor = [UIColor whiteColor];
    
    
    WKWebViewConfiguration *theConfiguration = [[WKWebViewConfiguration alloc] init];
    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 40, viewForPop.view.frame.size.width, viewForPop.view.frame.size.height-40) configuration:theConfiguration];
    // self.webView.navigationDelegate = self;
    NSURL *nsurl=[NSURL URLWithString:url];
    NSURLRequest *nsrequest=[NSURLRequest requestWithURL:nsurl];
    [self.webView loadRequest:nsrequest];
    [viewForPop.view addSubview:self.webView];
    
    
    //cancel button
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [doneButton addTarget:self action:@selector(doneButtonPress) forControlEvents:UIControlEventTouchUpInside];
    [doneButton setTitle:@"Close" forState:UIControlStateNormal];
    doneButton.frame = CGRectMake(0, 0, 160.0, 40.0);
    [doneButton sizeToFit];
    doneButton.center = CGPointMake(viewForPop.view.frame.size.width - doneButton.frame.size.width - 10, 25);
    [viewForPop.view addSubview:doneButton];
    
    //pop controller
    //sets the arrow direction to null so that there is no arrow
    viewForPop.modalPresentationStyle = UIModalPresentationPopover;
    viewForPop.preferredContentSize = viewForPop.view.frame.size;
    self.popPC = viewForPop.popoverPresentationController; // 14
    self.popPC.delegate= self;
    viewForPop.popoverPresentationController.sourceView = self.view; // 16
    self.popPC.permittedArrowDirections = NULL; // 17
    [self presentViewController:viewForPop  animated:YES completion:nil]; // 19
}

-(void)doneButtonPress{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller traitCollection:(UITraitCollection *)traitCollection {
    return UIModalPresentationNone;
}




@end
