import tables, strformat, sugar
import coral/[artist, camera, palette_colors, renderer, memoize]

import pixie, boxy

type
  ImageId = string

  Artist = ref object
    bxy: Boxy
    camera: Camera
    images: Table[ImageId, Image]

proc newArtist*(): Artist =
  result = Artist(
    bxy: newBoxy(),
    camera: Camera(),
    images: Table[ImageId, Image](),
  )

proc spriteKey(i: ImageId, r: Rect): string {.inline.} = &"{i}{r.x}{r.y}{r.w}{r.h}"
proc rectKey*(size: Vec2): string {.inline.} = &"rect{size.x}{size.y}"

template addImageIfNew(artist: Artist, key: string, renderFn: untyped) =
  if not artist.bxy.contains(key):
    artist.bxy.addImage(key, renderFn())

template beginDrawing*(artist: Artist, size: IVec2, fn: untyped) =
  beginFrame(artist.bxy, size)
  fn()
  endFrame(artist.bxy)

template transform*(artist: Artist, pos, size: Vec2, rotation = 0.0, body: untyped) =
  if rotation != 0.0:
    artist.bxy.saveTransform()

    artist.bxy.translate(pos + size.x / 2.0)
    artist.bxy.rotate(rotation)
    artist.bxy.translate(-pos - size.x / 2.0)

  body

  if rotation != 0.0:
    artist.bxy.restoreTransform()

proc drawSprite*(artist: Artist, pos: Vec2, imageId: string, region: Rect,
    tint = BrightWhite, rotation = 0.0) =
  let key = spriteKey(imageId, region)
  addImageIfNew(artist, key, () => renderSprite(artist.images[imageId], region))
  artist.bxy.drawImage(key, pos = pos, tint)

proc drawRect*(artist: Artist, pos, size: Vec2, tint = BrightWhite,
    rotation = 0.0, cornerRadius = 0.0) =
  let key = rectKey(size)
  addImageIfNew(artist, key, () => renderRect(size, cornerRadius))
  transform(artist, pos, size, rotation):
    artist.bxy.drawImage(key, pos = pos, tint)
