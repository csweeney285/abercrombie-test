//
//  CardInfo.h
//  A&F Test
//
//  Created by Conor Sweeney on 9/30/16.
//  Copyright © 2016 csweeney. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ButtonInfo.h"

@interface CardInfo : NSObject

@property int order;
@property (nonatomic,strong)UIImage *backgroundImage;
@property (nonatomic,strong)NSString *title;
@property (nonatomic,strong)NSString *topDescription;
@property (nonatomic,strong)NSString *promoMessage;
@property (nonatomic,strong)NSString *bottomDescription;
@property (nonatomic,strong)NSMutableArray *content;

@end
