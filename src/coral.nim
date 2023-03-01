import tables, strformat, sugar, os, options
import coral/[camera, palette_colors, renderer, memoize]

import pixie, boxy, opengl

from nim_tiled import Tileset, name

type
  ImageId = string

  Artist* = ref object
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

proc clear*(artist: Artist, color = color(0.0, 0.0, 0.0, 1.0)) =
  glClearColor(color.r.float32, color.g.float32, color.b.float32,
      color.a.float32)
  glClear(GL_COLOR_BUFFER_BIT)

proc loadImage*(artist: Artist, imagePath: string,
    imageId: string): Image {.discardable.} =
  if artist.bxy.contains(imageId):
    return artist.images[imageId]
  result = readImage(imagePath)
  artist.images[imageId] = result
  artist.bxy.addImage(imageId, result)

proc addTileset*(artist: Artist, ts: Tileset): Tileset {.discardable.} =
  let key = &"{ts.name}"
  if not artist.bxy.contains(key) and ts.image.isSome:
    let tsimage = ts.image.get()

    let path = getCurrentDir()
      .joinPath("res")
      .joinPath("maps")
      .joinPath("tilemaps")
      .joinPath(tsimage.source)

    let image = readImage(path)
    artist.bxy.addImage(key, image)
    artist.images[key] = image

template addImageIfNew(artist: Artist, key: string, renderFn: untyped) =
  if not artist.bxy.contains(key):
    artist.bxy.addImage(key, renderFn())

template beginDrawing*(artist: Artist, windowSize: IVec2, fn: untyped) =
  updateCamera(artist.camera, windowSize)

  beginFrame(artist.bxy, windowSize)
  saveTransform(artist.bxy)

  scale(artist.bxy, artist.camera.zoom)
  translate(artist.bxy, artist.camera.lookAt + artist.camera.size * 0.5 /
      artist.camera.zoom)

  artist.clear()
  fn()

  restoreTransform(artist.bxy)
  endFrame(artist.bxy)

template drawOrRender*(artist: Artist, imageId: string, x, y, w, h: float,
    body: untyped) =
  if not artist.bxy.contains(imageId):
    let image = newImage(w.int, h.int)
    let ctx {.inject.} = newContext(image)
    body
    artist.bxy.addImage(imageId, image)
  artist.bxy.drawImage(imageId, pos = vec2(x, y), BrightWhite)

template transform*(artist: Artist, pos, size: Vec2, rotation = 0.0,
    body: untyped) =
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
