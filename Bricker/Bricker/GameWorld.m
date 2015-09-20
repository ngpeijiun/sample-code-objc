//
//  GameWorld.m
//  Bricker
//
//  Created by Ng Pei Jiun on 1/5/15.
//  Copyright (c) 2015 SampleCode. All rights reserved.
//

#import "GameWorld.h"

@interface GameWorld ()

@end

@implementation GameWorld

#pragma mark Factory

- (id)initWithSize:(CGSize)size {
    self = [super init];

    if (self) {
        self.size = size;
        self.gameState = GameStateInit;
    }

    return self;
}

- (void)newGame {
    self.lives = 3;
    self.score = 0;

    [self initBricks];
    [self initBallAndPaddle];
}

- (void)continueGame {
    [self initBallAndPaddle];
}

- (void)initBallAndPaddle {
    self.ball = [self makeBall];
    self.paddle = [self makePaddle];

    float velocityX = 0.5 + arc4random() % 100 / 100.0;
    float velocityY = sqrtf(4 - pow(velocityX, 2));

    ballVelocity = CGPointMake(velocityX, velocityY);
    paddleX = self.paddle.origin.x;
}

- (void)initBricks {
    for (int i = 0; i < GAME_BRICKS_NUM; ++i) {
        bricks[i] = [self makeBrick:i];
    }
}

- (Brick)makeBrick:(int)index {
    int w = self.size.width / 5;

    CGFloat x = index % 5 * w;
    CGFloat y = 25 + index / 5 * 20;
    CGFloat width = w;
    CGFloat height = 20;

    Brick brick = { CGRectMake(x, y, width, height), 1, NO };

    return brick;
}

- (CGRect)makeBall {
    CGFloat x = (self.size.width - 16) * 0.5;
    CGFloat y = (self.size.height - 16) * 0.5;
    CGFloat width = 16;
    CGFloat height = 16;

    return CGRectMake(x, y, width, height);
}

- (CGRect)makePaddle {
    CGFloat x = (self.size.width - 60) * 0.5;
    CGFloat y = (self.size.height - 16) * 0.8;
    CGFloat width = 60;
    CGFloat height = 16;

    return CGRectMake(x, y, width, height);
}

#pragma mark Properties

- (Brick)brickAtIndex:(int)index {
    return bricks[index];
}

#pragma mark Time

- (void)start {
    if (timer == nil) {
        timer = [CADisplayLink displayLinkWithTarget:self selector:@selector(update:)];
        timer.frameInterval = 1;
        [timer addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    }
}

- (void)pause {
    [timer invalidate];
    timer = nil;
}

#pragma mark Input

- (void)movePaddleByX:(CGFloat)x {
    paddleX += x;
    paddleX = MAX(0, paddleX);
    paddleX = MIN(self.size.width - self.paddle.size.width, paddleX);
}

#pragma mark Game Loop

- (void)update:(NSTimer *)timer {
    [self processGameLogic];

    if (self.gameState == GameStateInit || self.gameState == GameStateRunning || self.gameState == GameStateWin) {
        [self simulatePhysics];
    } else {
        [self pause];
    }

    [self.graphicsDelegate render];
}

#pragma mark Game Logic

- (void)processGameLogic {
    [self processGameState];

    if (self.gameState == GameStateRunning) {
        [self processGameScore];
        [self processGameOver];
        [self processGameWin];
    }
}

- (void)processGameState {
    switch (self.gameState) {
        case GameStateInit:
            [self newGame];
            self.gameState = GameStateBegin;
            break;

        case GameStateBegin:
            self.gameState = GameStateReady;
            break;

        case GameStateContinue:
            self.gameState = GameStateReady;
            break;

        case GameStateReady:
            self.gameState = GameStateRunning;
            break;

        case GameStateLost:
            if (self.lives) {
                self.lives--;
                [self continueGame];
                self.gameState = GameStateContinue;
            } else {
                self.gameState = GameStateOver;
            }
            break;

        case GameStateOver:
            self.gameState = GameStateInit;
            break;

        default:
            break;
    }
}

- (void)processGameScore {
    for (int i = 0; i < GAME_BRICKS_NUM; ++i) {
        if (BrickIsSolid(bricks[i]) && bricks[i].hit) {
            self.score += 10;
        }
    }
}

- (void)processGameOver {
    if (self.ball.origin.y + self.ball.size.height > self.size.height - 10) {
        self.gameState = GameStateLost;
    }
}

- (void)processGameWin {
    for (int i = 0; i < GAME_BRICKS_NUM; ++i) {
        if (BrickIsSolid(bricks[i])) {
            return;
        }
    }

    self.gameState = GameStateWin;
}

#pragma mark Physics

- (void)simulatePhysics {
    [self simulateBall];
    [self simulatePaddle];
    [self simulateCollision];
}

- (void)simulateBall {
    CGFloat x = self.ball.origin.x + ballVelocity.x;
    CGFloat y = self.ball.origin.y + ballVelocity.y;
    CGFloat width = self.ball.size.width;
    CGFloat height = self.ball.size.height;

    self.ball = CGRectMake(x, y, width, height);
}

- (void)simulatePaddle {
    CGFloat x = paddleX;
    CGFloat y = self.paddle.origin.y;
    CGFloat width = self.paddle.size.width;
    CGFloat height = self.paddle.size.height;

    self.paddle = CGRectMake(x, y, width, height);
}

- (void)simulateCollision {
    [self simulateWallCollision];
    [self simulateBrickCollision];
    [self simulatePaddleCollision];
}

- (void)simulateWallCollision {
    if (self.ball.origin.x + self.ball.size.width > self.size.width - 10 || self.ball.origin.x < 10) {
        ballVelocity.x = -ballVelocity.x;
    }
    if (self.ball.origin.y + self.ball.size.height > self.size.height - 10 || self.ball.origin.y < 10) {
        ballVelocity.y = -ballVelocity.y;
    }
}

- (void)simulateBrickCollision {
    BOOL collided = NO;
    for (int i = 0; i < GAME_BRICKS_NUM; ++i) {
        if (bricks[i].hit) {
            bricks[i].alpha -= 0.01;
        } else if (!collided && BrickIsSolid(bricks[i]) && CGRectIntersectsRect(self.ball, bricks[i].frame)) {
            bricks[i].hit = YES;
            collided = YES;
            [self simulateBrickCollisionWith:bricks[i]];
        }
    }
}

- (void)simulateBrickCollisionWith:(Brick)brick {
    float distanceX = ballVelocity.x > 0 ? brick.frame.origin.x - (self.ball.origin.x + self.ball.size.width) : self.ball.origin.x - (brick.frame.origin.x + brick.frame.size.width);
    float distanceY = ballVelocity.y > 0 ? brick.frame.origin.y - (self.ball.origin.y + self.ball.size.height) : self.ball.origin.y - (brick.frame.origin.y + brick.frame.size.height);

    if (distanceY <= distanceX) {
        ballVelocity.x = -ballVelocity.x;
    }
    if (distanceX <= distanceY) {
        ballVelocity.y = -ballVelocity.y;
    }
}

- (void)simulatePaddleCollision {
    if (CGRectIntersectsRect(self.ball, self.paddle)) {
        float distanceX = ballVelocity.x > 0 ? self.paddle.origin.x - (self.ball.origin.x + self.ball.size.width) : self.ball.origin.x - (self.paddle.origin.x + self.paddle.size.width);
        float distanceY = ballVelocity.y > 0 ? self.paddle.origin.y - (self.ball.origin.y + self.ball.size.height) : self.ball.origin.y - (self.paddle.origin.y + self.paddle.size.height);

        CGFloat x = self.ball.origin.x;
        CGFloat y = self.ball.origin.y;
        CGFloat width = self.ball.size.width;
        CGFloat height = self.ball.size.height;

        if (distanceY <= distanceX) {
            x = ballVelocity.x > 0 ? self.paddle.origin.x - self.ball.size.width : self.paddle.origin.x + self.paddle.size.width;
        }
        if (distanceX <= distanceY) {
            y = ballVelocity.y > 0 ? self.paddle.origin.y - self.ball.size.height : self.paddle.origin.y + self.paddle.size.height;
        }

        self.ball = CGRectMake(x, y, width, height);

        if (distanceY <= distanceX) {
            ballVelocity.x = -ballVelocity.x;
        }
        if (distanceX <= distanceY) {
            ballVelocity.y = -ballVelocity.y;
        }
    }
}

@end
