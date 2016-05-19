//
//  ViewController.h
//  FriendKeeper
//
//  Created by Natalia Estrella on 5/18/16.
//  Copyright © 2016 Natalia Estrella. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LGSideMenuController.h"

@interface ViewController : UIViewController

- (void)setLeftViewEnabledWithWidth:(CGFloat)width
                  presentationStyle:(LGSideMenuPresentationStyle)presentationStyle
               alwaysVisibleOptions:(LGSideMenuAlwaysVisibleOptions)alwaysVisibleOptions;   // for example you can make view always visible on ipad landscape orientation



@end

