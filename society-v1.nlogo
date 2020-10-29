globals[counter all-adults-home? all-adults-idle? all-grandparents-home? all-children-home? all-children-idle? adult-activity children-activity]

breed [adults adult]
breed [houses house]
breed [workplaces workplace]
breed [supermarkets supermarket]
breed [schools school]
breed [children child]
breed [grandparents grandparent]

houses-own[family-number]
workplaces-own[workplace-number building-status]
adults-own[family-number workplace-number supermarket-number diagnosis where-now? has-car? shopping tested? can-work? idle? infected-time activity]
children-own[family-number school-number diagnosis where-now? idle? tested? infected-time schooling? activity has-car?]
grandparents-own[family-number diagnosis where-now? tested? infected-time go-out? has-car?]
supermarkets-own[supermarket-number building-status]
schools-own[school-number building-status]
patches-own[status]

to setup
  clear-all
  build-houses
  build-supermarkets
  build-workplaces
  initialize-adults
  initialize-grandparents
  if (open-schools? = true)[
    build-schools
    initialize-children
  ]
  mark-sterile-zone
  identify-zones
  check-area-status
  reset-ticks
end

to go

  let people (turtle-set adults grandparents children)

  if all? people [diagnosis = "not-infected"] [
    stop
  ]

  ask people with [diagnosis = "infected" and tested? = true] [
    set infected-time infected-time + 1
  ]
  ;if schools closed
  ifelse (open-schools? = false) [
    (ifelse (all-adults-home? = true and all-grandparents-home? = true) [
      if (all-adults-idle? = true and all-adults-home? = true and all-grandparents-home? = true) [
        let get-lockdown-time lockdown-days * 2000
        ask adults with [infected-time >= get-lockdown-time] [
          set color white
          set diagnosis "not-infected"
          set tested? false
          set infected-time 0
          ask patches with [status != "not-contaminated"] in-radius 8 [
            set pcolor green - 4
            set status "not-contaminated"
          ]
          set can-work? true
        ]
        ask grandparents with [infected-time >= get-lockdown-time] [
          set color white
          set diagnosis "not-infected"
          set tested? false
          set infected-time 0
          ask patches with [status != "not-contaminated"] in-radius 8 [
            set pcolor green - 4
            set status "not-contaminated"
          ]
          set go-out? true
        ]
        ask adults with [infected-time > 0 and infected-time < get-lockdown-time] [
          draw-buffer-circle
          draw-contaminated-circle
        ]
        ask grandparents with [infected-time > 0 and infected-time < get-lockdown-time] [
          draw-buffer-circle
          draw-contaminated-circle
        ]
        test-adults
        test-grandparents
        identify-zones
        check-area-status
      ]
      move-to-workplace
      move-out-grandparents
      ask adults [
        set shopping random 100
      ]
      ]
      [
        move-from-workplace-to-home
        move-grandparents-home
    ])
  ]
  ;if schools open
  [
    if ((all-adults-home? = true or adult-activity = "going-work") and (all-children-home? = true or children-activity = "going-school") and all-grandparents-home? = true) [
      if (all-adults-idle? = true and all-adults-home? = true and all-children-idle? = true and all-children-home? = true and all-grandparents-home? = true) [
        let get-lockdown-time lockdown-days * 2000
        ask adults with [infected-time >= get-lockdown-time] [
          set can-work? true
          set color white
          set diagnosis "not-infected"
          set tested? false
          set infected-time 0
          ask patches with [status != "not-contaminated"] in-radius 8 [
            set pcolor green - 4
            set status "not-contaminated"
          ]
        ]
        ask children with [infected-time >= get-lockdown-time] [
          set schooling? true
          set color white
          set diagnosis "not-infected"
          set tested? false
          set infected-time 0
          ask patches with [status != "not-contaminated"] in-radius 8 [
            set pcolor green - 4
            set status "not-contaminated"
          ]
        ]
        ask grandparents with [infected-time >= get-lockdown-time] [
          set go-out? true
          set color white
          set diagnosis "not-infected"
          set tested? false
          set infected-time 0
          ask patches with [status != "not-contaminated"] in-radius 8 [
            set pcolor green - 4
            set status "not-contaminated"
          ]
        ]
        ask adults with [infected-time > 0 and infected-time < get-lockdown-time] [
          draw-buffer-circle
          draw-contaminated-circle
        ]
        ask grandparents with [infected-time > 0 and infected-time < get-lockdown-time] [
          draw-buffer-circle
          draw-contaminated-circle
        ]
        ask children with [infected-time > 0 and infected-time < get-lockdown-time] [
          draw-buffer-circle
          draw-contaminated-circle
        ]
        test-adults
        test-grandparents
        test-children
        identify-zones
        check-area-status
      ]
      move-to-workplace
      move-out-grandparents
      move-to-school
      ask adults [
        set shopping random 100
      ]
    ]
    if ((all-adults-home? = false or adult-activity = "going-home") and (all-children-home? = false or children-activity = "going-home")) [
      move-from-workplace-to-home
      move-grandparents-home
      move-from-school-to-home
    ]
  ]
  tick
end

to build-houses
  set-default-shape houses "house"
  set counter 1
  create-houses number-of-houses[
    set size 1.5
    setxy (random 28 + 2) (random 30 - random 30)
    set family-number counter
    set counter counter + 1
    set color white - 1
  ]
end

to build-workplaces
  set-default-shape workplaces "house"
  set counter 1
  create-workplaces number-of-workplaces[
    set size 1.5
    setxy (random -28 - 2) (random 30 - random 30)
    set workplace-number counter
    set counter counter + 1
    set color yellow
  ]
end

to build-supermarkets
  set-default-shape supermarkets "house"
  set counter 1
  create-supermarkets number-of-supermarkets[
    set size 1.5
    setxy (random 28 + 2) (random 30 - random 30)
    set supermarket-number counter
    set counter counter + 1
    set color blue
  ]
end

to build-schools
  set-default-shape schools "house"
  set counter 1
  create-schools number-of-schools[
    set size 1.5
    setxy (random -28 - 2) (random 30 - random 30)
    set school-number counter
    set counter counter + 1
    set color orange
  ]
end

to initialize-adults
  set counter initial-infected
  set all-adults-home? true
  ask houses [
    hatch-adults adults-per-house [
      set shape "person"
      set size 1
      set family-number [family-number] of myself
      set workplace-number random number-of-workplaces + 1
      set where-now? "home"
      set infected-time 0
      set supermarket-number random number-of-supermarkets + 1
      set idle? true
      set activity "at-home"
      (ifelse (random 100 < use-of-private-transport)
        [set has-car? true]
        [set has-car? false])
      (ifelse (counter > 0)
        [
          set color red
          set diagnosis "infected"
        ]
        [
          set color white
          set diagnosis "not-infected"
      ])
      (ifelse (random 100 < test-rate)
        [set tested? true]
        [set tested? false])
      (ifelse (tested? = true and diagnosis = "infected")
        [set can-work? false]
        [set can-work? true])
      set counter counter - 1
    ]
  ]
end

to initialize-grandparents
  set all-grandparents-home? true
  ask houses [
    hatch-grandparents older-people-per-house [
      set shape "person"
      set size 1
      set has-car? false
      set family-number [family-number] of myself
      set where-now? "home"
      set infected-time 0
      set color white
      set diagnosis "not-infected"
      (ifelse (random 100 < test-rate)
        [set tested? true]
        [set tested? false])
      set go-out? true
    ]
  ]
end

to initialize-children
  set all-children-home? true
  ask houses [
    hatch-children children-per-house [
      set shape "person"
      set size 1
      set family-number [family-number] of myself
      set school-number random number-of-schools + 1
      set where-now? "home"
      set infected-time 0
      set idle? true
      set color white
      set activity "at-home"
      set diagnosis "not-infected"
      (ifelse (random 100 < use-of-private-transport)
        [set has-car? true]
        [set has-car? false])
      (ifelse (random 100 < test-rate)
        [set tested? true]
        [set tested? false])
      set schooling? true
    ]
  ]
end

to test-adults
  ask adults with [tested? != true or diagnosis != "infected"] [   ;de morgan
    (ifelse (random 100 < test-rate)
      [set tested? true]
      [set tested? false])
  ]
  ask adults [
    (ifelse (color = red)
      [set diagnosis "infected"]
      [set diagnosis "not-infected"])
    (ifelse (tested? = true and diagnosis = "infected")
      [set can-work? false]
      [set can-work? true])
  ]
end

to test-grandparents
  ask grandparents with [tested? != true or diagnosis != "infected"] [
    (ifelse (random 100 < test-rate)
      [set tested? true]
      [set tested? false])
  ]
  ask grandparents [
    (ifelse (color = red)
      [set diagnosis "infected"]
      [set diagnosis "not-infected"])
    (ifelse (tested? = true and diagnosis = "infected")
      [set go-out? false]
      [set go-out? true])
  ]
end

to test-children
  ask children with [tested? != true or diagnosis != "infected"] [
    (ifelse (random 100 < test-rate)
      [set tested? true]
      [set tested? false])
  ]
  ask children [
    (ifelse (color = red)
      [set diagnosis "infected"]
      [set diagnosis "not-infected"])
    (ifelse (tested? = true and diagnosis = "infected")
      [set schooling? false]
      [set schooling? true])
  ]
end

to move-to-workplace
  ask adults [
    set all-adults-idle? false
    let adult-workplace one-of workplaces with [workplace-number = [workplace-number] of myself]
    if ( [building-status] of adult-workplace = "contaminated" ) [
      set can-work? false
    ]
    if (can-work? = true) [
      face adult-workplace
      (ifelse
        any? workplaces with [workplace-number = [workplace-number] of myself] in-radius 1 [
          set where-now? "workplace"
          set activity "at-work"
          stop
        ]
        [
          set idle? false
          set activity "going-work"
          forward 0.05
      ])
      spread-disease
    ]
    if any? adults with [activity = "going-work"] [
      set adult-activity "going-work"
    ]
  ]
  if all? adults [where-now? = "workplace" or can-work? = false] [
    set all-adults-home? false
  ]
end

to move-out-grandparents
  ask grandparents with [go-out? = true] [
    set where-now? "out"
    rt random 10
    lt random 10
    forward 0.005
    spread-disease
  ]
end

to move-to-school
  ask children [
    set all-children-idle? false
    let child-school one-of schools with [school-number = [school-number] of myself]
    if ( [building-status] of child-school = "contaminated" ) [
      set schooling? false
    ]
    if (schooling? = true) [
      face child-school
      (ifelse
        any? schools with [school-number = [school-number] of myself] in-radius 1 [
          set where-now? "school"
          set activity "at-school"
          stop
        ]
        [
          set activity "going-school"
          set idle? false
          forward 0.05
      ])
      spread-disease
    ]
    if any? children with [activity = "going-school"] [
      set children-activity "going-school"
    ]
  ]
  if all? children [where-now? = "school" or schooling? = false] [
    set all-children-home? false
  ]
end

to move-from-workplace-to-home
  ask adults [
    if (shopping < go-shopping and where-now? = "workplace")
      [move-to-market]
    if ((shopping >= go-shopping and where-now? = "workplace") or (shopping < go-shopping and where-now? = "supermarket")) [
      let family-place one-of houses with [family-number = [family-number] of myself]
      face family-place
      (ifelse any? houses with [family-number = [family-number] of myself] in-radius 1 [
        set where-now? "home"
        set idle? true
        set activity "at-home"
        stop
        ]
        [
          set activity "going-home"
          forward 0.05
      ])
      spread-disease
    ]
    if any? adults with [activity = "going-home"] [
      set adult-activity "going-home"
    ]
  ]
  if all? adults [where-now? = "home"] [
    set all-adults-home? true
  ]
  if all? adults [idle? = true] [
    set all-adults-idle? true
  ]
end

to move-to-market
  let market-place one-of supermarkets with [supermarket-number = [supermarket-number] of myself]
  (ifelse [building-status] of market-place != "contaminated" [
    face market-place
    (ifelse any? supermarkets with [supermarket-number = [supermarket-number] of myself] in-radius 1 [
      set where-now? "supermarket"
      stop
      ]
      [
        forward 0.05
    ])
    spread-disease
    ]
    [set where-now? "supermarket"])
end

to move-grandparents-home
  ask grandparents with [where-now? != "home"] [
    let family-place one-of houses with [family-number = [family-number] of myself]
    face family-place
    (ifelse any? houses with [family-number = [family-number] of myself] in-radius 1 [
      set where-now? "home"
      stop
      ]
      [
        forward 0.005
    ])
    spread-disease
  ]
  if all? grandparents [where-now? = "home"] [
    set all-grandparents-home? true
  ]
end

to move-from-school-to-home
  ask children [
    if (where-now? = "school") [
      let family-place one-of houses with [family-number = [family-number] of myself]
      face family-place
      (ifelse any? houses with [family-number = [family-number] of myself] in-radius 1 [
        set where-now? "home"
        set idle? true
        set activity "at-home"
        stop
        ]
        [
          set activity "going-home"
          forward 0.05
      ])
      spread-disease
    ]
    if any? children with [activity = "going-home"] [
      set children-activity "going-home"
    ]
  ]
  if all? children [where-now? = "home"] [
    set all-children-home? true
  ]
  if all? children [idle? = true] [
    set all-children-idle? true
  ]
end

to spread-disease
  let people (turtle-set adults grandparents children)
  if any? people with [color = red and shape = "person" and tested? = false and diagnosis = "infected"] in-radius 0.2 [
    ;Different probabilities of spread when using private and public trnsportation
    (ifelse
      has-car? = false and random 100 < public-transport-spread-rate * 100 [
        set color red
        set diagnosis "infected"
      ]
      has-car? = true and random 100 < private-transport-spread-rate * 100 [
        set color red
        set diagnosis "infected"
    ])
  ]
end

to mark-sterile-zone
  ask patches [
    set pcolor green - 4
    set status "not-contaminated"
  ]
end

to draw-buffer-circle
  ask patches with [status != "contaminated"] in-radius 8 [
    set pcolor yellow - 3
    set status "buffer"
  ]
end

to mark-buffer-zone
  let people (turtle-set adults grandparents children)
  ask people with [tested? = true and diagnosis = "infected" and where-now? = "home"] [
    draw-buffer-circle
  ]
end

to draw-contaminated-circle
  ask patches in-radius 4 [
    set pcolor red - 3
    set status "contaminated"
  ]
  ; when an infected person is identified, his/her all relatives are tested.
  let people (turtle-set adults grandparents children)
  ask people [
    if ([pcolor] of one-of patches in-radius 1 = red - 3 ) [
      set tested? true
    ]
  ]
end

to mark-contaminated-zone
  let people (turtle-set adults grandparents children)
  ask people with [tested? = true and diagnosis = "infected" and where-now? = "home"] [
    draw-contaminated-circle
  ]
end

to identify-zones
  mark-buffer-zone
  mark-contaminated-zone
end

to check-area-status
  ask adults [
    if ([pcolor] of one-of patches in-radius 1 = red - 3 )
      [set can-work? false]
  ]
  ask grandparents [
    if ([pcolor] of one-of patches in-radius 1 = red - 3 )
      [set go-out? false]
  ]
  ask children [
    if ([pcolor] of one-of patches in-radius 1 = red - 3 )
      [set schooling? false]
  ]
  let buildings (turtle-set workplaces supermarkets schools)
  ask buildings [
    ifelse ([pcolor] of one-of patches in-radius 1 = red - 3 )
      [set building-status "contaminated"]
    [set building-status "not-contaminated"]
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
454
12
1058
617
-1
-1
9.7705
1
10
1
1
1
0
0
0
1
-30
30
-30
30
1
1
1
ticks
30.0

BUTTON
30
16
98
71
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
31
81
98
135
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
237
185
439
218
number-of-workplaces
number-of-workplaces
1
100
30.0
1
1
NIL
HORIZONTAL

SLIDER
28
145
227
178
number-of-houses
number-of-houses
1
500
50.0
1
1
NIL
HORIZONTAL

SLIDER
27
187
228
220
adults-per-house
adults-per-house
1
4
2.0
1
1
NIL
HORIZONTAL

PLOT
25
357
436
508
Diagnosis
time
count
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"infected" 1.0 0 -2674135 true "" "let people (turtle-set adults grandparents children)\nplot (count people with [color = red])"
"not-infected" 1.0 0 -10899396 true "" "let people (turtle-set adults grandparents children)\nplot (count people with [color = white])"

MONITOR
116
515
212
560
infected count
count turtles with [shape = \"person\" and color = red]
0
1
11

MONITOR
228
516
346
561
not-infected count
count turtles with [shape = \"person\" and color = white]
0
1
11

INPUTBOX
110
16
223
94
initial-infected
5.0
1
0
Number

SLIDER
238
230
441
263
number-of-supermarkets
number-of-supermarkets
1
100
25.0
1
1
NIL
HORIZONTAL

MONITOR
361
517
445
562
infected %
count turtles with [shape = \"person\" and color = red] / (count turtles with [shape = \"person\"]) * 100
2
1
11

SLIDER
239
142
439
175
use-of-private-transport
use-of-private-transport
0
100
40.0
1
1
%
HORIZONTAL

SLIDER
237
273
437
306
go-shopping
go-shopping
0
100
40.0
1
1
%
HORIZONTAL

SLIDER
237
17
436
50
test-rate
test-rate
0
100
40.0
1
1
%
HORIZONTAL

MONITOR
24
514
98
559
total
count turtles with [shape = \"person\"]
17
1
11

SLIDER
239
101
438
134
number-of-schools
number-of-schools
1
5
2.0
1
1
NIL
HORIZONTAL

SLIDER
27
229
228
262
children-per-house
children-per-house
0
5
1.0
1
1
NIL
HORIZONTAL

SWITCH
106
102
224
135
open-schools?
open-schools?
1
1
-1000

SLIDER
237
59
438
92
lockdown-days
lockdown-days
1
20
1.0
1
1
NIL
HORIZONTAL

SLIDER
26
272
229
305
older-people-per-house
older-people-per-house
0
4
1.0
1
1
NIL
HORIZONTAL

TEXTBOX
64
329
214
347
NIL
11
0.0
1

SLIDER
28
312
229
345
private-transport-spread-rate
private-transport-spread-rate
0
1
0.3
0.1
1
NIL
HORIZONTAL

SLIDER
237
313
437
346
public-transport-spread-rate
public-transport-spread-rate
0
1
0.06
0.01
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

;;Randomly place the houses in the area based on input 'number-of-houses'
;;Randomly place work-places in the area based on input 'number-of-workplaces'
;;We can change the number of employees per house using 'employees-per-house'
;;
;;We can set the initial infected count using 'initial-infected'
;;We can change the spread rate using 'spread-rate'
;;
;;Currently model works for only one iteration : goto workplace and go back home.
;;
;;Total number of employees will be based on employees per house and number
;;of houses. Currently all the employees including infected and non infected
;;employees leave the houses and goto work. Then come back to the same home
;;assigned. The infection is spread when a non-infected person meets a
;;infected person. And it may depend on the spread-rate and the distance of
;;infected person with the non infected person.

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.1.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
