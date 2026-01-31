// FOG

/obj/screen/weather/fog
	alpha = 75
	icon = 'icons/mob/screen_full.dmi'
	icon_state	= "phog1"
	screen_loc = "1,1"
	mouse_opacity = 0
	plane = EFFECTS_BELOW_LIGHTING_PLANE

/obj/screen/weather/fog/New(client/C)
	. = ..()
	var/mutable_appearance/fog = image(icon, icon_state = "phog2")
	var/mutable_appearance/softfog = image(icon, icon_state = "smok")
	var/mutable_appearance/softfog2 = image(icon, icon_state = "smok")
	fog.pixel_x = 480

	softfog2.pixel_x = 480
	softfog.alpha = 30
	softfog2.alpha = 30
	add_overlay(fog)
	add_overlay(softfog)
	add_overlay(softfog2)

	var/matrix/M = matrix()
	M.Translate(-480,0)
	animate(src, transform = M, time = 500, loop = -1) // Have an odd number, haha
	animate(transform = null, time = 0)


// PARTICLES FOR WEATHER








particles




	snow
		icon		= 'icons/effects/particles/weather.dmi'
		icon_state	= list("snow1"=5, "snow2"=6, "snow3"=5)



		width 		= 5000
		height 		= 5000
		count 		= 10
		spawning 	= 0.5
		lifespan 	= 100
		fade 		= 50
		fadein		= 20
		// spawn within a certain x,y,z space
		position 	= generator("box", list(-500,-500,0), list(500,500,50))
		// control how the snow falls
		gravity 	= list(0, -1)
		friction 	= 0.1
		drift 		= generator("circle", 1)




	rain
		icon		= 'icons/effects/particles/weather2.dmi'
		icon_state	= list("rain1"=5, "rain2"=6, "rain3"=5)
		//icon_state = "rain1.old"


		width 		= 5000
		height 		= 5000
		count 		= 500
		spawning 	= 25
		lifespan 	= 20
		fade 		= 2
		fadein		= 3

		scale		= list(2,2)
		grow		= list(-0.15, -0.15)

		position 	= generator("box", list(-500,-500,0), list(500,500,0))
		gravity 	= list(0.2, -6)
		drift 		= generator("circle", 1)




	storm
		icon		= 'icons/effects/particles/weather2.dmi'
		icon_state	= list("rain1"=5, "rain2"=6, "rain3"=5)
		//icon_state = "rain1.old"


		width 		= 5000
		height 		= 5000
		count 		= 1000
		spawning 	= 75
		lifespan 	= 20
		fade 		= 2
		fadein		= 3

		position 	= generator("box", list(-500,-500,0), list(500,500,0))
		gravity 	= list(-1, -6)
		drift 		= generator("circle", 1)



	raindrop
		icon		= 'icons/effects/particles/weather2.dmi'
		icon_state	= "rainland"
		//icon_state = "rainland.old"


		width 		= 5000
		height 		= 5000
		count 		= 200
		spawning 	= 2
		lifespan 	= 3
		fade 		= 1
		fadein		= 2
		position 	= generator("box", list(-500,-500,0), list(500,500,0))




	leaves
		icon		= 'icons/effects/particles/weather.dmi'
		icon_state	= list("leaf1"=5, "leaf2"=6, "leaf3"=5)



		width 		= 5000
		height 		= 5000
		count 		= 2
		spawning 	= 1
		lifespan 	= 100
		fade 		= 5
		fadein		= 10
		spin		= 8
		position 	= generator("box", list(-600,-600,0), list(600,600,0))
		gravity 	= list(0, -1)
		friction 	= 0.2
		drift 		= generator("circle", 1)





	blizzard
		icon		= 'icons/effects/particles/weather.dmi'
		icon_state	= list("snow1"=5, "snow2"=6, "snow3"=5)



		width 		= 5000
		height 		= 5000
		count 		= 200
		spawning 	= 4
		lifespan 	= 100
		fade 		= 50
		fadein		= 10
		position 	= generator("box", list(-500,-500,0), list(500,500,0))
		gravity 	= list(2, -2)
		drift 		= generator("circle", 1)















/obj/effect/abstract/particle_holder/weather
	appearance_flags	= PIXEL_SCALE

	snow
		particles 	= new/particles/snow
		plane		= EFFECTS_BELOW_LIGHTING_PLANE
	rain
		particles 	= new/particles/rain
		plane		= EFFECTS_BELOW_LIGHTING_PLANE
	//	alpha		= 142
	storm
		particles 	= new/particles/storm
		plane		= EFFECTS_BELOW_LIGHTING_PLANE
	//	alpha		= 142
	raindrop
		particles 	= new/particles/raindrop
		plane		= EFFECTS_BELOW_LIGHTING_PLANE
	//	alpha		= 100
	leaves
		particles 	= new/particles/leaves
		plane		= EFFECTS_BELOW_LIGHTING_PLANE


	blizzard
		particles 	= new/particles/blizzard
		plane		= EFFECTS_BELOW_LIGHTING_PLANE
