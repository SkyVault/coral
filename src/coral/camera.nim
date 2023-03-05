import vmath, bumpy

type
  Camera* = ref object
    lookAt*: Vec2
    zoom*: float = 1.0
    size*: Vec2
    resized = false

proc follow*(camera: Camera, point: Vec2, dt: float) =
  camera.lookAt = mix(camera.lookAt, -point, dt)

proc zoomIn*(camera: Camera, scale: float) =
  camera.zoom *= scale

proc zoomOut*(camera: Camera, scale: float) =
  camera.zoom /= scale

proc left*(camera: Camera): float = -camera.lookAt.x - (camera.size.x / 2.0) / camera.zoom
proc right*(camera: Camera): float = -camera.lookAt.x + (camera.size.x / 2.0) / camera.zoom

proc top*(camera: Camera): float = -camera.lookAt.y - (camera.size.y / 2.0) / camera.zoom
proc bottom*(camera: Camera): float = -camera.lookAt.y + (camera.size.y / 2.0) / camera.zoom

proc bounds*(camera: Camera): Rect =
  result = rect(camera.left(), camera.top(), camera.size.x / camera.zoom,
      camera.size.y / camera.zoom)

proc withinView*(camera: Camera, r: Rect): bool =
  r.overlaps(camera.bounds)

proc updateCamera*(camera: Camera, windowSize: IVec2) =
  if vec2(windowSize) != camera.size:
    camera.size = vec2(windowSize.x.float, windowSize.y.float)
    camera.lookAt = -camera.size / 2.0
