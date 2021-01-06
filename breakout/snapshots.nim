import
  std/[streams, times, monotimes, strutils, os],
  serialize, gametypes, slottables,
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
    fs = openFileStream(savefile, fmReadWrite)
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

proc snapshotsDir(): string =
  result = getAppDir() / "snapshots"
  if not dirExists(result):
    createDir(result)

type
  SnapHandler* = object
    savefile*: string
    lastTime: MonoTime
    retries: int

proc initSnapHandler*(): SnapHandler =
  let savefile = snapshotsDir() / filename & SnapExt
  result = SnapHandler(savefile: savefile, lastTime: getMonoTime())

proc persist*(game: Game; handler: var SnapHandler) =
  ## Write to a single save per application run. An expiration timer is used
  ## so that it doesn't constantly save to disk.
  let now = getMonoTime()
  if now - handler.lastTime >= expiration:
    try:
      # Save to a temporary file
      let tmp = snapshotsDir() / filename & SnapExt & ".new"
      save(game.world, tmp)
      # Upon success overwrite previous snapshot
      moveFile(tmp, handler.savefile)
      # Reset retry counter and expiration timer
      handler.lastTime = now
      handler.retries = 0
    except:
      # If still failing after `maxRetries`, independently of the time past
      if handler.retries >= maxRetries:
        quit("Persist failed, maximum retries exceeded." & getCurrentExceptionMsg())
      handler.retries.inc

proc restore*(game: var Game; handler: SnapHandler) =
  ## Load the database from the savefile.
  try:
    load(game.world, handler.savefile)
  except:
    # Quit immedietely if the database can't be loaded
    quit("Restore failed: " & getCurrentExceptionMsg())
