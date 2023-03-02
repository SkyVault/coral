import chroma

const BrightWhite* = color(1.0, 1.0, 1.0, 1.0)
const Transparent* = color(0.0, 0.0, 0.0, 0.0)

type
  Colors* = enum
    lightRed
    brightRed
    red
    darkRed
    lightTan
    brightTan
    tan
    darkTan
    lightBlue
    brightBlue
    blue
    darkBlue
    lightGreen
    brightGreen
    green
    darkGreen
    lightYellow
    brightYellow
    yellow
    darkYellow
    lightPurple
    brightPurple
    purple
    darkPurple
    black
    darkBlack
    white
    brightWhite

  Palette* = TableRef[Colors, Color]

proc loadPaletteFromImage*(path: string): Palette =
  result = newTable[Colors, Color]()
  let img = readImage(path)
  for i in low(Colors)..high(Colors):
    let c = img[i.int, 0]
    result[Colors(i)] = color(c.r.float / 255.0, c.g.float / 255.0, c.b.float /
        255.0, c.a.float / 255.0) #

proc exportPalette*(palette: Palette): string =
  result = "import chroma\n\nconst\n"

  for k in palette.keys:
    let col = palette[k]
    result &= &"  {($k).capitalizeAscii()}* = parseHex \"{col.toHex()}\"\n"

  writeFile("src/palette_colors.nim", result)
