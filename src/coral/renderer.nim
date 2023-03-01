import pixie, boxy, chroma

import palette_colors

proc renderSprite*(
  source: Image,
  region: Rect
): Image =
  result = newImage(region.w.int, region.h.int)
  let ctx = newContext(result)
  ctx.fillStyle = BrightWhite
  ctx.drawImage(source, region, rect(vec2(), vec2(region.w, region.h)))

proc renderRect*(size: Vec2, cornerRadius = 0.0): Image =
  result = newImage(size.x.int, size.y.int)
  let ctx = newContext(result)
  ctx.fillStyle = BrightWhite
  if cornerRadius == 0.0: ctx.fillRect(0.0, 0.0, size.x, size.y)
  else: ctx.fillRoundedRect(rect(0.0, 0.0, size.x, size.y), cornerRadius)

proc renderLineRect*(size: Vec2, cornerRadius = 0.0): Image =
  result = newImage(size.x.int, size.y.int)
  let ctx = newContext(result)
  ctx.strokeStyle = BrightWhite
  if cornerRadius == 0.0: ctx.strokeRect(0.0, 0.0, size.x, size.y)
  else: ctx.strokeRoundedRect(rect(0.0, 0.0, size.x, size.y), cornerRadius)
