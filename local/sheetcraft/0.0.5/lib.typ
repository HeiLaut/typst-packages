/*
#import "Vorlage.typ": *

#show: project.with(
  titel: "",
  subject: "",
  klausur: false,
)

= Röntgenstrahlung
*/

#import "@preview/hydra:0.6.2": hydra

#let aufgabenzaehler = counter("aufgabe")
#let unterzaehler = counter("unteraufgabe")

#set page(header: context hydra(1))
// Ein State, um die Punktzahlen pro Aufgabe zu speichern
#let punkteliste = state("punkteliste", ())



#let project(
  titel: "",
  subject: "",
  klausur: false,
  examhead: "",
  size: "a4",
  insidemargin: 2cm,
  outsidemargin: 2.5cm,
  topmargin: 2.5cm,
  bottommargin: 2cm,
  textsize: 11pt,
  body,
) = {
  set quote(block: true)

  let datum = datetime.today().display("[day].[month].[year]")
  let info = [Heinrich Lauterbach · #datum · IGS.Halle Am Steintor · CC-BY-SA]

  set heading(numbering: (..nums) => {
    let n = nums.pos()
    if klausur {
      if n.len() == 1 {
        "Aufgabe " + str(n.at(0)) + " - "
      } else if n.len() == 2 {
        "Material " + str(n.at(1))
      }
    }
  })

  set ref(supplement: none)

  set text(lang: "de", font: "Liberation Sans", size: textsize)
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
      top: topmargin,
      bottom: bottommargin,
      inside: insidemargin,
      outside: outsidemargin,
    ),
    binding: left,

    header: context {
      let page-num = counter(page).get().at(0)
      if page-num == 1 and klausur == true {
        examhead
      } else {
        [
          #place(left, dx: -0.5cm, dy: topmargin - 1.4cm)[
            #rect(width: 100% - 2cm, height: 1cm)[#align(
              horizon,
            )[*#context hydra(1, skip-starting: false)*]]
          ]
          #place(right, dx: 0.5cm, dy: topmargin - 1.4cm)[
            #rect(width: 3cm, height: 1cm, fill: black, stroke: black)[#align(
              horizon,
            )[#text(white)[#subject]]]
          ]
        ]
      }
    },

    background: layout(size => context {
      let is-odd = calc.odd(here().page())
      let dx = if is-odd { insidemargin } else { outsidemargin }
      let margin = 0.5cm
      let text-width = size.width - insidemargin - outsidemargin
      let text-height = size.height - topmargin - bottommargin

      let info-x = if (is-odd and klausur) {
        insidemargin + text-width + 0.7cm
      } else if (klausur){
        outsidemargin - 0.9cm
      } else if is-odd{
          outsidemargin - 1.35cm
        }else{
          insidemargin + text-width + 1.15cm
        }

      place(
        dx: dx - margin,
        dy: -(text-height - topmargin + margin) / 2 - 1.15cm,
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


#let q(
  ..args,
  punkte: 0,
  optionen: (),
  type: "checkbox",
  layout: "vertical",
  body,
) = {
  let punkte = if args.pos().len() > 0 {
    args.pos().at(0)
  } else {
    punkte
  }

  aufgabenzaehler.step()
  unterzaehler.update(0)
  // Wir fügen eine neue Aufgabe mit ihrem Punktwert zur Liste hinzu
  punkteliste.update(liste => {
    liste.push(punkte)
    liste
  })

  context {
    let n = aufgabenzaehler.display()
    let label = text(weight: "bold")[#n.]
    let einzug = measure(label).width + 0.4em
    let symbol = if type == "checkbox" {
      box(width: 0.8em, height: 0.8em, stroke: 0.5pt)
    } else { box(width: 0.8em, height: 0.8em, radius: 50%, stroke: 0.5pt) }

    let optionen-block = if optionen.len() > 0 {
      if layout == "vertical" {
        stack(spacing: 0.5em, ..optionen.map(o => grid(
          columns: (1.2em, 1fr),
          gutter: 0.4em,
          align(horizon, symbol), align(horizon)[#o],
        )))
      } else {
        grid(columns: optionen.len(), gutter: 1.5em, ..optionen.map(o => grid(
            columns: (1.2em, 1fr),
            gutter: 0.4em,
            align(horizon, symbol), align(horizon)[#o],
          )))
      }
    }

    if punkte > 0 {
      place(right, dx: 1.4cm)[
        #text(size: 10pt, weight: "bold")[#punkte P.]
      ]
    }

    block(below: 1.2em)[
      #grid(
        columns: (einzug, 1fr),
        label,
        stack(spacing: 0.5em, body, if optionen.len() > 0 { optionen-block }),
      )
    ]
  }
}
//Unerfrage Subquestion
#let sq(
  ..args,
  punkte: 0,
  optionen: (),
  type: "checkbox",
  layout: "vertical",
  body,
) = {
  let punkte = if args.pos().len() > 0 {
    args.pos().at(0)
  } else {
    punkte
  }

  unterzaehler.step()

  // Wir addieren die Punkte der Unterfrage zum letzten Eintrag der Liste
  punkteliste.update(liste => {
    let last = liste.pop()
    liste.push(last + punkte)
    liste
  })

  context {
    let buchstabe = unterzaehler.display("a)")
    let label = text(weight: "bold")[#buchstabe]
    let einzug = measure(label).width + 0.4em
    let symbol = if type == "checkbox" {
      box(width: 0.8em, height: 0.8em, stroke: 0.5pt)
    } else { box(width: 0.8em, height: 0.8em, radius: 50%, stroke: 0.5pt) }

    let optionen-block = if optionen.len() > 0 {
      if layout == "vertical" {
        stack(spacing: 0.5em, ..optionen.map(o => grid(
          columns: (1.2em, 1fr),
          gutter: 0.4em,
          align(horizon, symbol), align(horizon)[#o],
        )))
      } else {
        grid(columns: optionen.len(), gutter: 1.5em, ..optionen.map(o => grid(
            columns: (1.2em, 1fr),
            gutter: 0.4em,
            align(horizon, symbol), align(horizon)[#o],
          )))
      }
    }

    if punkte > 0 {
      place(dx: 15cm)[#text(size: 10pt, weight: "bold")[#punkte P.]]
    }
    block(inset: (left: 1.5em), below: 1em)[
      #grid(
        columns: (einzug, 1fr),
        label,
        stack(spacing: 0.5em, body, if optionen.len() > 0 { optionen-block }),
      )
    ]
  }
}


#let punktetabelle() = context {
  let werte = punkteliste.final()
  let anzahl = werte.len()
  let summe = werte.sum()

  table(
    // Drei Spalten: Aufgabe, Max. Punkte, Erreichte Punkte
    columns: (2.5cm, 2cm, 2.5cm),
    rows: auto,
    align: center + horizon,
    stroke: 0.5pt + gray,
    inset: 6pt,

    // Kopfzeile
    [*Aufgabe*], [*Max.*], [*Pkt.*],

    // Dynamische Zeilen für jede Aufgabe
    ..for (i, p) in werte.enumerate() {
      (
        [* #(i + 1)*],
        [#p],
        [],
      )
    },

    // Abschlusszeile für die Summe
    fill: (x, y) => if y == anzahl + 1 { luma(240) },
    // Markiert die Summenzeile leicht grau
    [*Gesamt*], [*#summe*], [],
  )
}
#let notentabelle(total: 75) = context {
  if total == none {
    let total = punkteliste.final().sum()
  }

  // Schlüssel LSA (Oberstufe)
  let schluessel = (
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

  let fmt-np(n) = if n < 10 { "0" + str(n) } else { str(n) }

  table(
    // 17 Spalten (Beschriftung + 16 Notenwerte)
    columns: (0.75cm, ..array.range(16).map(_ => 0.85cm)),
    rows: (auto, auto),
    align: center + horizon,
    stroke: 0.5pt + gray,
    inset: 3pt,

    // Erste Zeile: Notenpunkte
    [*NP*], ..schluessel.map(s => text(size: 7.5pt)[*#fmt-np(s.p)*]),

    // Zweite Zeile: Punktegrenzen (Aufgerundet, keine Kommawerte)
    text(size: 7pt)[Pkt.],
    ..schluessel.map(s => text(size: 7.5pt)[#calc.ceil(total * s.m)]),
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
