import
  std/[streams, times, monotimes, strutils, os],
  serialize, gametypes, slottables, entities,
  bingo, bingo/marshal_smartptrs, fusion/smartptrs

const
  SnapExt = ".bin"
  SnapVersion = 1
  cookie = [byte(0), byte('B'), byte('/'), byte('O'),
            byte(sizeof(int)*8), byte(cpuEndian), byte(0), byte(SnapVersion)]
  filename = "snapshot"
  # Used when loading snapshots
  maxRetries = 3
  expiration = initDuration(seconds = 20)

type
  SnapError = object of CatchableError

proc raiseSnapError(msg: string) {.noinline, noreturn.} =
  raise newException(SnapError, msg)

proc save(x: World; savefile: string) =
  var fs: FileStream
  try:
    fs = openFileStream(savefile, fmWrite)
    # Store header
    storeBin(fs, cookie)
    # Write time
    let time = getTime()
    write(fs, time.toUnix)
    # Serialize
    storeBin(fs, x)
  finally:
    if fs != nil: fs.close()

proc load(x: var World; savefile: string) =
  var fs: FileStream
  try:
    # Raise an exception if the file can't be opened
    fs = openFileStream(savefile)
    # Read header
    let header = binTo(fs, array[cookie.len, byte])
    if header != cookie:
      raiseSnapError("Invalid snapshot file: header mismatch")
    # Discard lastTime
    let unix = readInt64(fs)
    # Deserialize
    loadBin(fs, x)
  finally:
    if fs != nil: fs.close()

proc snapshotDir(): string =
  result = getAppDir() / "snapshots"
  if not dirExists(result):
    createDir(result)

proc snapExists*(snapshot: SnapHandler): bool =
  result = fileExists(snapshot.savefile)

proc initSnapHandler*(): SnapHandler =
  let savefile = snapshotDir() / filename & SnapExt
  result = SnapHandler(savefile: savefile, lastTime: getMonoTime())

proc persist*(game: var Game) =
  ## Write to a single save per application run. An expiration timer is used
  ## so that it doesn't constantly save to disk.
  let now = getMonoTime()
  if now - game.snapshot.lastTime >= expiration:
    try:
      # Reset expiration timer
      game.snapshot.lastTime = now
      # Save to a temporary file
      let tmp = snapshotDir() / filename & SnapExt & ".new"
      save(game.world, tmp)
      # Upon success overwrite previous snapshot
      moveFile(tmp, game.snapshot.savefile)
      # Reset retry counter
      game.snapshot.retries = 0
    except:
      if game.snapshot.retries >= maxRetries:
        quit("Persist failed, maximum retries exceeded." & getCurrentExceptionMsg())
      inc(game.snapshot.retries)

proc restore*(game: var Game) =
  ## Load the world from the savefile.
  try:
    load(game.world, game.snapshot.savefile)
    game.camera = toEntity(0, 1) #hack
  except:
    # Quit immedietely if the world can't be loaded
    quit("Restore failed: " & getCurrentExceptionMsg())
