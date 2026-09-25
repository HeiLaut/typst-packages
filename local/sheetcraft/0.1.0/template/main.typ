    #import "../lib.typ": *

    #show: project.with(
      title: "Worksheet",
      subject: "physics",
    )

    #q(2)[
      Does acceleration change during the free movement of a thrown ball?
      
      #grid-paper(15cm,2cm)
    ]

    #q(2,  type: "checkbox",layout:"horizontal",options:($F = m dot a$,$F = m dot Delta v$))[Choose the correct formula.]

    #sq(1)[Add something to the false formula, that it becomes correct.\
            #grid-paper(12cm,1cm)
    ]

    #points-table()
