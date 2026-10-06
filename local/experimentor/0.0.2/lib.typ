#import "@preview/cetz:0.5.1"
/*
#let FORM(pos, name: none, ..style) = {
  import cetz.draw: *
  group(name: name, {
    set-origin(pos)

    // --- Geometrie: hier kommen deine Pfade/Primitive hin ---
    merge-path(..style, {
      // line(...), arc(...), ...
    })

    // --- Anker (lokale Koordinaten) ---
    anchor("a", (0, 0))
  })
}
*/
#let joint(pos, name: none, ..style) = {
  import cetz.draw: *
  group(name: name, {
    set-origin(pos)
    merge-path(fill:gray,fill-rule: "even-odd",..style, {
      compound-path({
        circle((0,0),radius:0.1+0.03)
        circle((0,0),radius:0.22)
        })
    })
  })
}

#let clamp(pos, screwpos:0.3, name: none, ..style) = {
  import cetz.draw: *
  group(name: name, {
      set-origin(pos)
      rect((0.35,-screwpos),(rel:(0.12,-0.8)),fill:gray.lighten(40%),stroke:0.5pt)
      rect((rel:(-0.2,0)),(rel:(0.28,-0.15)),fill:gray.lighten(10%),stroke:0.7pt)
      merge-path(fill: gray,
      {
      boolean(
        {rect((-0.2,0.3),(rel:(0.8,-1.2)),radius:2pt)},
        {rect((0.17,0),(rel:(0.7,-0.6)))
        //{circle((0,-0.3),radius:0.12)}
      },
        op: "difference",
      )
    })
     anchor("a", (0, 0))
  })
}

#let hook(pos, name: none,rot:0deg,flip:false, ..style) = {
  import cetz.draw: *
  group(name: name, {
    set-origin(pos)
      rotate(rot)
      rect((-0.11,-0.22),(rel:(0.22,0.44)),fill:gray,radius:0.02)
      line((0,-0.22),(0,-0.4),stroke:1.5pt)
      if(flip){
         arc((0,-0.4),start:90deg,stop:-150deg,stroke:(thickness:0.05,cap:"round"),radius:0.1)
      }else{
        arc((0,-0.4),start:90deg,stop:330deg,stroke:(thickness:0.05,cap:"round"),radius:0.1)
      }
      anchor("load", (0, -0.61))
  })
}

    
#let rod(pos, name: none, l: 1, dia:0.2,rot: 0deg, ..style) = {
  import cetz.draw: *
  group(name: name, {
    set-origin(pos)
    merge-path(fill: gradient.linear(black.lighten(20%), white,black.lighten(20%),angle:- rot),..style, {
      rotate(rot)
      rect((-dia/2,0),(rel:(dia,l)),radius:0.02)
      anchor("end", (0, l))
      anchor("start", (0, 0))
    })
  })
}
#let mass(pos, name: none,d:0.48,h:0.6,rot: 0deg, ..style) = {
  import cetz.draw: *
  group(name: name, {
      set-origin(pos)
      rotate(rot)
      arc((0,-0.15),start:-90deg,stop:180deg,stroke:(thickness:0.05,cap:"round"),radius:0.07)
      line((0,-0.15),(rel:(0,-0.1)),stroke:1.5pt)
      rect((rel:(-d/2,0)),(rel:(d,-h)),radius:0.02,fill: gradient.linear(black.lighten(20%), white,black.lighten(20%),angle:- rot))
      anchor("bottom", (0,-h - 0.25))
      anchor("top", (0,0))
  })
}

#let coil(pos, name: none, rot: 0deg, n: 10, l: 2, d: 0.3,
          startlength: 0.1, endlength: 0.1, thickness: 1.5pt, ..style) = {
  import cetz.draw: *
  let s = l / n
  let base = (stroke: (thickness: thickness, cap: "round", join: "round"))

  group(name: name, {
    set-origin(pos)
    rotate(rot)

    for i in range(n) {
      group({
        translate(y: i * s+startlength)
        line((0, 0), (d / 2, 0.25 * s), (-d / 2, 0.75 * s), (0, s),
             ..base, ..style)
      })
    }
    line((0, 0), (0, startlength), ..base, ..style)
    line((0, l+startlength), (rel:(0, endlength)), ..base, ..style)

    anchor("start", (0,0))
    anchor("end",   (0, l + endlength+startlength))
  })
}

