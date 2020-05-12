import macros

blueprint(Ball):
   with Collide, ControlBall, Draw2d, Move

blueprint(Brick):
   with Collide, ControlBlock, Draw2d, Fade

blueprint(Explosion):
   children:
      blueprint:
         with Draw2d, Fade, Move

blueprint(Paddle):
   with Collide, ControlPaddle, Draw2d, Move
