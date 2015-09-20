//
//  GameViewController.h
//  Bricker
//
//  Created by Ng Pei Jiun on 1/5/15.
//  Copyright (c) 2015 SampleCode. All rights reserved.
//

#import <UIKIt/UIKit.h>
#import "GameWorld.h"

@interface GameViewController : UIViewController <GameWorldGraphicsDelegate> {
    UIView *bricks[GAME_BRICKS_NUM];

    float touchOffset;
}

@property (strong, nonatomic) GameWorld *gameWorld;

@property (strong, nonatomic) UILabel *livesTextLabel;
@property (strong, nonatomic) UILabel *livesValueLabel;

@property (strong, nonatomic) UILabel *scoreTextLabel;
@property (strong, nonatomic) UILabel *scoreValueLabel;

@property (strong, nonatomic) UIView *ballView;
@property (strong, nonatomic) UIView *paddleView;

@property (strong, nonatomic) UILabel *messageLabel;

@end
