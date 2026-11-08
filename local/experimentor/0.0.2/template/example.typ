#import "@local/experimentor:0.0.2": *
#import "@preview/cetz:0.5.1"


#cetz.canvas({
  import cetz.draw: *
  rod((0, -2), rot: 0deg, name: "rod", l: 7)
  rod((-0.5, 4), l: 10, rot: -90deg)
  joint((0, 4))
  mass((2.5, 1), rot: 0deg, name: "masse", h: 0.5, d: 0.3)
  hook((0, 0), name: "haken2", rot: 90deg, flip: true)
  hook((1, 4), name: "haken")
  hook((4, 4), name: "haken3")
  line("haken3.load", "masse.top", "haken.load", "haken2.load", stroke: (
    paint: red,
    thickness: 1.5pt,
    cap: "round",
    join: "round",
  ))
  rect((-1, -1), (10, -1.2), fill: red.lighten(20%))
  clamp((0, -1), screwpos: 0.2)
  hook((6, 4), flip: true, name: "haken4")
  coil("haken4.load", rot: 180deg, name: "feder1")
  mass("feder1.end")
  mass("masse.bottom", d: 0.2, h: 0.2)
  hook((8, 4), flip: false, name: "haken5")
  coil(
    "haken5.load",
    rot: 180deg,
    l: 1.5,
    name: "feder2",
    stroke: 1pt + green.darken(20%),
  )
  mass("feder2.end")
})


