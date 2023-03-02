import tables, sequtils, sugar

import pixie

type
  ResourcePath* = string
  ResourceId* = string

  ResourceKind* = enum
    # for now just an image
    image

  Resource* = object
    id*: ResourceId
    path*: ResourcePath
    case kind*: ResourceKind
      of image:
        image*: Image

  ResourcePack* = Table[ResourceId, Resource]
  ResourcePackDef* = Table[ResourceId, (ResourceKind, ResourcePath)]

proc initResourcePack*(): ResourcePack =
  result = initTable[ResourceId, Resource]()

proc initResourcePackDef*(): ResourcePackDef =
  initTable[ResourceId, (ResourceKind, ResourcePath)]()

proc loadImageResource*(id: ResourceId, path: string): Resource =
  result.path = path
  result.id = id
  result.image = readImage(path)

proc loadResource*(kind: ResourceKind, id: ResourceId, path: string): Resource =
  case kind
    of image: loadImageResource(id, path)

proc loadResourcePack*(pack: ResourcePackDef): ResourcePack =
  collect(for k in pack.keys: (k, loadResource(pack[k][0], k, pack[k][1]))).toTable
