import vmath, bumpy

type
  Camera* = object
    lookAt*: Vec2
    zoom*: float = 1.0
    size*: Vec2
    resized = false

proc follow*(camera: var Camera, point: Vec2, dt: float) =
  camera.lookAt = mix(camera.lookAt, -point, dt)

proc zoomIn*(camera: var Camera, scale: float) =
  camera.zoom *= scale

proc zoomOut*(camera: var Camera, scale: float) =
  camera.zoom /= scale

proc left*(camera: Camera): float =
  camera.lookAt.x - (camera.size.x * 0.5)

proc right*(camera: Camera): float =
  camera.lookAt.x + (camera.size.x * 0.5)

proc top*(camera: Camera): float =
  camera.lookAt.y - camera.size.y * 0.5

proc bottom*(camera: Camera): float =
  camera.lookAt.y + camera.size.y * 0.5

proc bounds*(camera: Camera): Rect =
  result = rect(camera.left(), camera.top(), camera.size.x, camera.size.y)

proc withinView*(camera: Camera, r: Rect): bool =
  r.overlaps(camera.bounds)

proc update*(camera: var Camera, windowSize: IVec2) =
  if vec2(windowSize) != camera.size:
    camera.size = vec2(windowSize.x.float, windowSize.y.float)
    camera.resized = true

  if camera.resized:
    camera.resized = false
    camera.lookAt.x = -windowSize.x.float / 2.0
    camera.lookAt.y = -windowSize.y.float / 2.0

  # if mouseWheelScrollDelta().y != 0:
  #   if mouseWheelScrollDelta().y > 0: 
  #     camera.zoomIn(1.1)
  #   else: 
  #     camera.zoomOut(1.1)

