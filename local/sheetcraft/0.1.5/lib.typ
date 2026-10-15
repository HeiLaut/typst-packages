#import "@preview/hydra:0.6.2": hydra

#let task-counter = counter("task")
#let subtask-counter = counter("subtask")

#set page(header: context hydra(1))
#let points-list = state("points-list", ())

#let _solutions = state("solution", false)

#let project(
  title: "",
  subject: "",
  exam: false,
  exam-head: "",
  size: "a4",
  inside-margin: 2cm,
  outside-margin: 2.5cm,
  top-margin: 2.5cm,
  bottom-margin: 2cm,
  text-size: 11pt,
  solutions: false, 
  info: "",

  body,
) = {
 _solutions.update(solutions)
  set quote(block: true)

  
  set heading(numbering: (..nums) => {
    let n = nums.pos()
    if exam {
      if n.len() == 1 {
        "Aufgabe " + str(n.at(0)) + " - "
      } else if n.len() == 2 {
        "Material " + str(n.at(1))
      }
    }
  })

  set ref(supplement: none)

  set text(lang: "de", font: "Liberation Sans", size: text-size)
  show heading: it => {
    set text(weight: "bold")
    let spacing = if it.level == 1 { 1em } else { 0.75em }
    block(above: spacing, below: spacing)[
      #if it.numbering != none {
        numbering(it.numbering, ..counter(heading).get())
        h(0.3em, weak: true)
      }
      #it.body
    ]
  }
  set par(justify: true)

  set page(
    size,
    margin: (
      top: top-margin,
      bottom: bottom-margin,
      inside: inside-margin,
      outside: outside-margin,
    ),
    binding: left,

    header: context {
      let page-num = counter(page).get().at(0)
      if page-num == 1 and exam == true {
        exam-head
      } else {
        [
          #place(left, dx: -0.5cm, dy: top-margin - 1.4cm)[
            #rect(width: 100% - 2cm, height: 1cm)[#align(
              horizon,
            )[*#context hydra(1, skip-starting: false)*]]
          ]
          #place(right, dx: 0.5cm, dy: top-margin - 1.4cm)[
            #rect(width: 3cm, height: 1cm, fill: black, stroke: black)[#align(
              horizon,
            )[#text(white)[#subject]]]
          ]
        ]
      }
    },

    background: layout(size => context {
      let is-odd = calc.odd(here().page())
      let dx = if is-odd { inside-margin } else { outside-margin }
      let margin = 0.5cm
      let text-width = size.width - inside-margin - outside-margin
      let text-height = size.height - top-margin - bottom-margin

      let info-x = if (is-odd and exam) {
        inside-margin + text-width + 0.7cm
      } else if (exam){
        outside-margin - 0.9cm
      } else if is-odd{
          outside-margin - 1.35cm
        }else{
          inside-margin + text-width + 1.15cm
        }

      place(
        dx: dx - margin,
        dy: -(text-height - top-margin + margin) / 2 - 1.15cm,
      )[
        #rect(
          width: text-width + 2 * margin,
          height: text-height + margin,
          stroke: 1pt + black,
        )
      ]
      place(horizon, dx: info-x, dy: text-height / 2 - 4cm)[
        #rotate(-90deg, reflow: true)[
          #text(size: 7pt, fill: black)[#info]
        ]
      ]
    }),
    footer: context {
      let current = counter(page).display()
      let total = counter(page).final().at(0)
      align(center)[
        #text(size: 9pt, fill: luma(60))[Seite #current / #total]
      ]
    },
  )

  body
}



#let _choice(correct, radius: 0pt) = context {
  box(width: 0.8em, height: 0.8em, radius: radius, stroke: 0.5pt)[
#if correct and _solutions.get() {
      place(center + horizon, dx: 0.1em, dy: -0.15em)[#text(1.2em)[#sym.checkmark]]
    }
  ]
}

#let cb  = _choice(false)
#let cbx = _choice(true)
#let rb  = _choice(false, radius: 50%)
#let rbx = _choice(true, radius: 50%)

#let _points-tag(points) = if points > 0 {
  place(right, dx: 1.4cm)[#text(size: 10pt, weight: "bold")[#points P.]]
}

#let q(..args, points: 0, body) = {
  let points = args.pos().at(0, default: points)

  task-counter.step()
  subtask-counter.update(0)
  points-list.update(entries => {
    entries.push(points)
    entries
  })

  context {
    let label = text(weight: "bold")[#task-counter.display().]
    let indent = measure(label).width + 0.4em

    _points-tag(points)
    block(below: 1.2em, grid(columns: (indent, 1fr), label, body))
  }
}

// Unteraufgabe
#let sq(..args, points: 0, body) = {
  let points = args.pos().at(0, default: points)

  subtask-counter.step()
  points-list.update(entries => {
    let last = entries.pop()
    entries.push(last + points)
    entries
  })

  context {
    let label = text(weight: "bold")[#subtask-counter.display("a)")]
    let indent = measure(label).width + 0.4em

    _points-tag(points)
    block(
      inset: (left: 1.5em),
      below: 1em,
      grid(columns: (indent, 1fr), label, body),
    )
  }
}


#let points-table() = context {
  let values = points-list.final()
  let count = values.len()
  let sum = values.sum()

  table(
    // Drei Spalten: Aufgabe, Max. Punkte, Erreichte Punkte
    columns: (2.5cm, 2cm, 2.5cm),
    rows: auto,
    align: center + horizon,
    stroke: 0.5pt + gray,
    inset: 6pt,

    // table head
    [*Aufgabe*], [*Max.*], [*Pkt.*],

    //dynamic row for every question
    ..for (i, p) in values.enumerate() {
      (
        [* #(i + 1)*],
        [#p],
        [],
      )
    },

    // Last row: sum
    fill: (x, y) => if y == count + 1 { luma(240) },
    [*Gesamt*], [*#sum*], [],
  )
}
#let grade-table(total: 75) = context {
  if total == none {
    let total = points-list.final().sum()
  }

  // Schlüssel LSA (Oberstufe)
  let grade-key = (
    (p: 15, m: 0.95),
    (p: 14, m: 0.90),
    (p: 13, m: 0.85),
    (p: 12, m: 0.80),
    (p: 11, m: 0.75),
    (p: 10, m: 0.70),
    (p: 09, m: 0.65),
    (p: 08, m: 0.60),
    (p: 07, m: 0.55),
    (p: 06, m: 0.50),
    (p: 05, m: 0.45),
    (p: 04, m: 0.40),
    (p: 03, m: 0.33),
    (p: 02, m: 0.27),
    (p: 01, m: 0.20),
    (p: 00, m: 0.00),
  )

  let fmt-score(n) = if n < 10 { "0" + str(n) } else { str(n) }

  table(
    // 17 Spalten (Beschriftung + 16 Notenwerte)
    columns: (0.75cm, ..array.range(16).map(_ => 0.85cm)),
    rows: (auto, auto),
    align: center + horizon,
    stroke: 0.5pt + gray,
    inset: 3pt,

    // Erste Zeile: Notenpunkte
    [*NP*], ..grade-key.map(s => text(size: 7.5pt)[*#fmt-score(s.p)*]),

    // Zweite Zeile: Punktegrenzen (Aufgerundet, keine Kommawerte)
    text(size: 7pt)[Pkt.],
    ..grade-key.map(s => text(size: 7.5pt)[#calc.ceil(total * s.m)]),
  )
}
#let grid-paper(width, height, cell: 5mm) = {
  let cols = int(width.mm() / cell.mm())
  let rows = int(height.mm() / cell.mm())
  box(
    width: cols * cell,
    height: rows * cell,
    clip: true,
    stroke: gray.darken(30%),
    {
      for i in range(cols + 1) {
        place(line(
          stroke: gray.darken(30%),
          start: (i * cell, 0pt),
          end: (i * cell, rows * cell),
        ))
      }
      for j in range(rows + 1) {
        place(line(
          stroke: gray.darken(30%),
          start: (0pt, j * cell),
          end: (cols * cell, j * cell),
        ))
      }
    },
  )
}

#let line-paper(width, height, spacing: 7mm) = {
  let lines = int(height / spacing)

  stack(
    spacing: spacing - 0.4pt,
    v(spacing / 2),
    ..range(lines).map(_ => line(
      stroke: gray.darken(40%),
      length: width,
    )),
  )
}


