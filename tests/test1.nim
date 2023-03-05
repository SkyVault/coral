# This is just an example to get you started. You may wish to put all of your
# tests into a single file, or separate them into multiple `test1`, `test2`
# etc. files (better names are recommended, just make sure the name starts with
# the letter 't').
#
# To run these tests, simply execute `nimble test`.

import unittest, windy, opengl, chroma, vmath, tables, bumpy

import coral/[artist, palette, palette_colors, resources, camera]
import coral

test "can draw cool stuff":
  let window = newWindow("Hello", ivec2(512, 512))
  makeContextCurrent(window)
  loadExtensions()

  let
    artist = newArtist(initResourcePackDef())
    ww = 256.0 * 0.75
    hh = 256.0 * 0.75

  var
    counter = 0.0
    camera = artist.getCamera()

  while window.closeRequested == false:
    beginDrawing(artist, ivec2(512, 512)) do ():
      const M = 30.0
      for i in 1..30:
        artist.drawRect(
          vec2(40 + i.float/2.0, i.float + cos(counter / 20.0 * (i.float / M) *
              0.25) * (i.float / M) * 20.0 + 100),
          vec2(128-i.float, 128-i.float), cornerRadius = 8,
              tint = LightGreen.darken((i.float/M) * 0.35), rotation = counter * 0.01)

      artist.drawLineRect(vec2(-16.0), vec2(32.0))
      artist.drawLineRect(vec2(-ww / 2.0, -hh / 2.0), vec2(ww, hh))
      artist.drawLineRect(vec2(-ww / 2.0 - 10, -hh / 2.0 - 10), vec2(5, 5))

    camera.follow(vec2(0.0, 0.0), 0.016)

    if camera.withinView(rect(-ww / 2.0 - 10, -hh / 2.0 - 10, 5, 5)):
      echo "WITHIN VIEW", counter

    camera.zoom = (cos(counter / 100.0) * 0.5 + 1.0) * 4.0

    counter += 1.0

    camera.updateCamera(ivec2(512, 512))

    pollEvents()
    swapBuffers(window)
