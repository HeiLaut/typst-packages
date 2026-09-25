#import "@preview/cetz:0.5.2"
#import "@preview/lilaq:0.6.0" as lq


#let schraube(x:0,y:0,ang:0deg) = {
    import cetz.draw: *
    group({
      translate(x:x,y:y)
      rotate(ang)
      rect((-0.05,0),(0.05,0.4),fill:gray,stroke:0pt);
    rect((-0.15,0.39),(0.15,0.65),radius:0.05,fill:gray,stroke:0pt);
    })
}  
 #let klemme(x:-0.75,y:0,flip:true) = {
     import cetz.draw: *
   group({
    translate(x:x,y:y,flip:true)
    schraube(x:0.25,y:0.1,ang:180deg)
    schraube(x:0.75,y:1,ang:-90deg)
    
    compound-path({
     rect((0,0),(1,2),radius:2pt)
    rect((0.0,0.5),(0.5,1.5))
   },fill:black,fill-rule:"even-odd",stroke:0pt)
})
  }

  #let haken(x:0,y:0,ang:0deg,size:(0.2,0.5),name:"haken") = {
      import cetz.draw: *
    group(name:name,{
    translate(x:x,y:-0.25+y)
    rotate(ang)
    rect((-size.at(0)/2,0),(size.at(0)/2,size.at(1)),radius:0.05,fill:black);
    line((0,0.0),(-0.04,-0.1),stroke:2pt)
    arc((0.0,-0.1),start:90deg,stop:330deg,stroke:(thickness:2pt,cap:"round"),radius:0.15)
  })
  }
  #let rod(l:4,ang:0deg,x:0,y:0,name:none) = {
      import cetz.draw: *
    group(name:"rod",
    {
      translate(x:x,y:y)
      rotate(ang)
      rect((-0.15,0),(0.15,l),name:name,fill:gradient.linear(white,gray,white,angle:ang))
    })
  }

  #let muffe(x:0,y:0,ang:0deg) = ({
      import cetz.draw: *
    group({
    translate(x:x - 0.75,y:y - 0.3)
    rotate(ang)

    
    schraube(x:0.4,y:0.3)

    rect((0,0),(1.5,0.6),fill:black,radius:0.1)
  circle((1.1,0.3),radius:0.16,fill:gray, stroke:none)
    })
  })

  #let feder(x:0,y:0,ang:0, n:5, l: 5,stroke:1pt,d:1,name:"feder",startlength :0.25, endlength:0.25)={
      import cetz.draw: *
    group(name:name,{
      translate(x:x,y:y)
      rotate(ang)
      for i in lq.arange(0,n){
        group({

          let s = l/n
          translate(y:i*s)
        line(
      stroke: (thickness: stroke, cap: "round", join: "round"),
          (0,0),(d/2,0.25*s),( - d/2, 0.75*s),(0,s)
    )
    })
    line((0,0),(0,-startlength),stroke:(thickness:stroke,cap: "round"),name:"start")
    line((0,l),(0,l+endlength),stroke:(thickness:stroke,cap: "round"),name:"end")
      }
  })
  }
   #let lineal(..args,l:15,name:"lineal", ang: 0deg,flip: false) = {
       import cetz.draw: *
     let pos= args.pos().at(0)
    group(name:name,{
      translate(x:pos.at(0),y:pos.at(1))
      rotate(ang)
      let flipy = 1
      if flip{flipy = -1}
      scale(x:1,y:flipy)
      rect((0,0),(l,1),fill:color.mix((black,20%),white))
      for v in lq.linspace(0, l,num:20+1) {
        if calc.rem(v,2) == 0{
          line((v,0),(v,0.75))
        }else{
        line((v,0),(v,0.5))
      }
    }
    })
  }
