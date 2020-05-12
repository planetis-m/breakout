import sdl2, game

proc worldMain(game: var Game) =
   let columnCount = 10
   let rowCount = 10
   let blockWidth = 50
   let blockHeight = 15
   let margin = 5
   let gridWidth = blockWidth * columnCount + margin * (columnCount - 1)
   let startingX = (game.windowWidth - gridWidth) / 2
   let startingY = 50

   var camera = Blueprint(
      with: @[Shake(duration: 0.0, strength: 20.0)])

   var gameElements = @[
      getPaddle(float32(game.windowWidth / 2), float32(game.windowHeight - 30)),
      getBall(float32(game.windowWidth / 2), float32(game.windowHeight - 60))]

   for row in 0..<rowCount:
      let y = startingY + row * (blockHeight + margin) + blockHeight / 2
      for col in 0..<columnCount:
         let x = startingX + col * (blockWidth + margin) + blockWidth / 2
         gameElements.add(getBlock(x.float32, y.float32, blockWidth, blockHeight))

   camera.children = gameElements
   game.camera = game.add(camera)

