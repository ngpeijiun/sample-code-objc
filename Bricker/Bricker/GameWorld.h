//
//  GameWorld.h
//  Bricker
//
//  Created by Ng Pei Jiun on 1/5/15.
//  Copyright (c) 2015 SampleCode. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CGGeometry.h>
#import <QuartzCore/CADisplayLink.h>

static const int GAME_BRICKS_NUM = 5 * 10;

enum GameState {
    GameStateInit,
    GameStateBegin,
    GameStateContinue,
    GameStateReady,
    GameStateRunning,
    GameStateLost,
    GameStateOver,
    GameStateWin
};
typedef enum GameState GameState;

struct Brick {
    CGRect frame;
    CGFloat alpha;
    BOOL hit;
};
typedef struct Brick Brick;

static inline int signum(int n);

static inline BOOL BrickIsSolid(Brick brick);

static inline int signum(int n) {
    return (n < 0) ? -1 : +1;
}

static inline BOOL BrickIsSolid(Brick brick) {
    return brick.alpha == 1;
}

@protocol GameWorldGraphicsDelegate <NSObject>

- (void)render;

@end

@interface GameWorld : NSObject {
    Brick bricks[GAME_BRICKS_NUM];

    CGPoint ballVelocity;
    CGFloat paddleX;

    CADisplayLink *timer;
}

@property (nonatomic) id <GameWorldGraphicsDelegate> graphicsDelegate;

@property (nonatomic) CGSize size;

@property (nonatomic) GameState gameState;

@property (nonatomic) int lives;
@property (nonatomic) int score;

@property (nonatomic) CGRect ball;
@property (nonatomic) CGRect paddle;

- (id)initWithSize:(CGSize)size;

- (Brick)brickAtIndex:(int)index;

- (void)start;

- (void)pause;

- (void)movePaddleByX:(CGFloat)x;

@end
