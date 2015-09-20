//
//  GameViewController.m
//  Bricker
//
//  Created by Ng Pei Jiun on 1/5/15.
//  Copyright (c) 2015 SampleCode. All rights reserved.
//

#import "GameViewController.h"

@interface GameViewController ()

@end

@implementation GameViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.frame = [self viewFrame];

    // Game World

    self.gameWorld = [[GameWorld alloc] initWithSize:self.view.frame.size];
    self.gameWorld.graphicsDelegate = self;

    // Graphics

    [self initBricks];

    self.livesTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 45, 20)];
    self.livesTextLabel.font = [UIFont systemFontOfSize:14];
    self.livesTextLabel.text = @"Lives";

    self.livesValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(55, 0, 40, 20)];
    self.livesValueLabel.font = [UIFont systemFontOfSize:14];

    self.scoreTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(220, 0, 50, 20)];
    self.scoreTextLabel.font = [UIFont systemFontOfSize:14];
    self.scoreTextLabel.text = @"Score";

    self.scoreValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(270, 0, 40, 20)];
    self.scoreValueLabel.font = [UIFont systemFontOfSize:14];

    self.ballView = [[UIView alloc] init];
    self.ballView.backgroundColor = [UIColor blueColor];
    self.ballView.layer.cornerRadius = 8;

    self.paddleView = [[UIView alloc] init];
    self.paddleView.backgroundColor = [UIColor grayColor];
    self.paddleView.layer.cornerRadius = 8;

    self.messageLabel = [[UILabel alloc] initWithFrame:[self messageLabelFrame]];
    self.messageLabel.font = [UIFont systemFontOfSize:24];
    self.messageLabel.textAlignment = NSTextAlignmentCenter;

    [self.view addSubview:self.livesTextLabel];
    [self.view addSubview:self.livesValueLabel];
    [self.view addSubview:self.scoreTextLabel];
    [self.view addSubview:self.scoreValueLabel];
    [self.view addSubview:self.ballView];
    [self.view addSubview:self.paddleView];
    [self.view addSubview:self.messageLabel];

    // Time

    [self.gameWorld start];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Factory

- (void)initBricks {
    UIColor *colors[7];

    colors[0] = [UIColor colorWithRed:255.0 / 255 green:160.0 / 255 blue:255.0 / 255 alpha:1];
    colors[1] = [UIColor colorWithRed:255.0 / 255 green:230.0 / 255 blue:80 / 255 alpha:1];
    colors[2] = [UIColor colorWithRed:255.0 / 255 green:255.0 / 255 blue:136.0 / 255 alpha:1];
    colors[3] = [UIColor colorWithRed:136.0 / 255 green:255.0 / 255 blue:160.0 / 255 alpha:1];
    colors[4] = [UIColor colorWithRed:112.0 / 255 green:230.0 / 255 blue:255.0 / 255 alpha:1];
    colors[5] = [UIColor colorWithRed:220.0 / 255 green:220.0 / 255 blue:220.0 / 255 alpha:1];
    colors[6] = [UIColor colorWithRed:200.0 / 255 green:200.0 / 255 blue:180.0 / 255 alpha:1];

    for (int i = 0; i < GAME_BRICKS_NUM; ++i) {
        bricks[i] = [[UIView alloc] init];
        bricks[i].backgroundColor = colors[i % 7];
        [self.view addSubview:bricks[i]];
    }
}

- (CGRect)viewFrame {
    CGRect bounds = [UIScreen mainScreen].bounds;

    CGFloat x = 0;
    CGFloat y = [self statusBarHeight];
    CGFloat width = bounds.size.width;
    CGFloat height = bounds.size.height - y;

    return CGRectMake(x, y, width, height);
}

- (CGRect)messageLabelFrame {
    CGFloat x = (self.view.frame.size.width - 300) * 0.5;
    CGFloat y = (self.view.frame.size.height - 40) * 0.6;
    CGFloat width = 300;
    CGFloat height = 40;

    return CGRectMake(x, y, width, height);
}

- (CGFloat)statusBarHeight {
    return [UIApplication sharedApplication].statusBarFrame.size.height;
}

#pragma mark Input

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.gameWorld.gameState == GameStateRunning) {
        UITouch *touch = [[event allTouches] anyObject];
        touchOffset = [touch locationInView:touch.view].x - self.gameWorld.paddle.origin.x;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.gameWorld.gameState == GameStateRunning) {
        UITouch *touch = [[event allTouches] anyObject];
        float distancedMoved = [touch locationInView:touch.view].x  - self.gameWorld.paddle.origin.x - touchOffset;
        [self.gameWorld movePaddleByX:distancedMoved];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.gameWorld.gameState == GameStateWin) {
        self.gameWorld.gameState = GameStateInit;
    } else if (self.gameWorld.gameState != GameStateRunning) {
        self.messageLabel.text = @"";
        [self.gameWorld start];
    }
}

#pragma mark Graphics

- (void)render {
    self.livesValueLabel.text = [NSString stringWithFormat:@"%d", self.gameWorld.lives];
    self.scoreValueLabel.text = [NSString stringWithFormat:@"%05d", self.gameWorld.score];

    for (int i = 0; i < GAME_BRICKS_NUM; ++i) {
        Brick brickObj = [self.gameWorld brickAtIndex:i];
        bricks[i].frame = brickObj.frame;
        bricks[i].alpha = brickObj.alpha;
    }

    self.ballView.frame = self.gameWorld.ball;
    self.paddleView.frame = self.gameWorld.paddle;

    switch (self.gameWorld.gameState) {
        case GameStateBegin:
            self.messageLabel.text = @"New Game";
            break;

        case GameStateContinue:
            self.messageLabel.text = @"Continue";
            break;

        case GameStateReady:
            self.messageLabel.text = @"Ready";
            break;

        case GameStateLost:
            self.messageLabel.text = @"You Lose";
            break;

        case GameStateOver:
            self.messageLabel.text = @"Game Over";
            break;

        case GameStateWin:
            self.messageLabel.text = @"You Win!";
            break;

        default:
            break;
    }
}

@end
