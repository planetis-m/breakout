
# sysHandleInput
writes: [InputState]

# sysControlBall
reads: [Collide]
writes: [Transform2d, Move, Shake]

# sysControlBrick
reads: [Collide]
writes: [Fade]

# sysControlPaddle
reads: [InputState]
writes: [Move]

# sysShake
writes: [Transform2d, Shake]

# sysFade
reads: [Fade]
writes: [Transform2d, Draw2d]

# sysMove
reads: [Move]
writes: [Transform2d]

# sysTransform2d
reads: [Hierarchy]
writes: [Transform2d, Previous]

# sysCollide
reads: [Transform2d]
writes: [Collide]
