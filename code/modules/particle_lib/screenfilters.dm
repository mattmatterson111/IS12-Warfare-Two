/obj/screenfilter
	plane = EFFECTS_ABOVE_LIGHTING_PLANE
	layer = EFFECTS_LAYER

/obj/screenfilter/snow
	mouse_opacity = 0
	screen_loc = "CENTER"
	particles = new/particles/snow

/obj/screenfilter/snow/Fade()
	animate(src, alpha=0, time=10) //let's pretend there is no better way to do this shit
	..()

/obj/screenfilter/snowstorm
	mouse_opacity = 0
	screen_loc = "CENTER"
	particles = new/particles/snowstorm

/obj/screenfilter/snowstorm/Fade()
	animate(src, alpha=0, time=10) //let's pretend there is no better way to do this shit
	..()

/obj/screenfilter/dust
	mouse_opacity = 0
	screen_loc = "CENTER"
	particles = new/particles/dust

/obj/screenfilter/dust/Fade()
	animate(src, alpha=0, time=10) //let's pretend there is no better way to do this shit
	..()


/obj/screenfilter/rain
	mouse_opacity = 0
	screen_loc = "CENTER"
	particles = new/particles/rain

/obj/screenfilter/rain/Fade()
	animate(src, alpha=0, time=10) //let's pretend there is no better way to do this shit
	..()

/obj/screenfilter/storm
	mouse_opacity = 0
	screen_loc = "CENTER"
	particles = new/particles/storm

/obj/screenfilter/storm/Fade()
	animate(src, alpha=0, time=10)
	..()

/obj/screenfilter/raindrop
	mouse_opacity = 0
	screen_loc = "CENTER"
	particles = new/particles/raindrop

/obj/screenfilter/raindrop/Fade()
	animate(src, alpha=0, time=10)
	..()

/obj/screenfilter/proc/Fade() //cool fading effect
	qdel(src)

// NOTE: DELETE THIS AND PROPERLY MAKE IT ALL EMITTERS!!

/obj/emitter/smoke
	layer = FIRE_LAYER
	particles = new/particles/smoke

/obj/emitter/smoke/Initialize(mapload, time, _color)
	. = ..()
	filters = filter(type="blur", size=1.5)