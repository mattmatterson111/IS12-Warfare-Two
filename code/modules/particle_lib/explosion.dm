/obj/effect/temp_visual
	icon_state = "nothing"
	anchored = TRUE
	layer = ABOVE_HUMAN_LAYER
	plane = EFFECTS_ABOVE_LIGHTING_PLANE
	mouse_opacity = 0
	var/duration = 1 SECONDS
	var/randomdir = TRUE
	var/timerid


/obj/effect/temp_visual/Initialize(mapload)
	. = ..()
	if(randomdir)
		dir = pick(GLOB.cardinal)

	timerid = QDEL_IN(src, duration)


/obj/effect/temp_visual/Destroy()
	deltimer(timerid)
	return ..()


/obj/effect/temp_visual/ex_act()
	return


/obj/effect/temp_visual/dir_setting
	randomdir = FALSE


/obj/effect/temp_visual/dir_setting/Initialize(mapload, set_dir)
	if(set_dir)
		dir = set_dir
	return ..()

/particles/explosion_smoke
	icon = 'icons/effects/96x96.dmi'
	icon_state = "smoke3"
	width = 1000
	height = 1000
	count = 75
	spawning = 75
	gradient = list("#6d5f52", "#83664c", "#333333", "#808080", "#FFFFFF")
	lifespan = 20
	fade = 60
	color = generator(GEN_NUM, 0, 0.25)
	color_change = generator(GEN_NUM, 0.04, 0.05)
	velocity = generator(GEN_CIRCLE, 15, 15)
	drift = generator(GEN_CIRCLE, 0, 1, NORMAL_RAND)
	spin = generator(GEN_NUM, -20, 20)
	friction = generator(GEN_NUM, 0.1, 0.5)
	gravity = list(1, 2)
	scale = 0.25
	grow = 0.05

/particles/explosion_smoke/deva
	scale = 0.5
	velocity = generator(GEN_CIRCLE, 23, 23)

/particles/explosion_smoke/small
	count = 25
	spawning = 25
	scale = 0.25
	velocity = generator(GEN_CIRCLE, 10, 10)

/particles/explosion_water
	icon = 'icons/effects/96x96.dmi'
	icon_state = list("smoke4" = 1, "smoke5" = 1)
	width = 1000
	height = 1000
	count = 75
	spawning = 75
	lifespan = 20
	fade = 80
	velocity = generator(GEN_CIRCLE, 15, 15)
	drift = generator(GEN_CIRCLE, 0, 1, NORMAL_RAND)
	spin = generator(GEN_NUM, -20, 20)
	friction = generator(GEN_NUM, 0.1, 0.5)
	gravity = list(1, 2)
	scale = 0.15
	grow = 0.02

/particles/smoke_wave
	icon = 'icons/effects/96x96.dmi'
	icon_state = "smoke3"
	width = 750
	height = 750
	count = 75
	spawning = 75
	lifespan = 15
	fade = 70
	gradient = list("#796d56", "#808080", "#FFFFFF")
	color = generator(GEN_NUM, 0, 0.25)
	color_change = generator(GEN_NUM, 0.08, 0.07)
	velocity = generator(GEN_CIRCLE, 25, 25)
	rotation = generator(GEN_NUM, -45, 45)
	scale = 0.25
	grow = 0.05
	friction = 0.05

/particles/smoke_wave/small
	count = 45
	spawning = 45
	scale = 0.1

/particles/wave_water
	icon = 'icons/effects/96x96.dmi'
	icon_state = "smoke5"
	width = 750
	height = 750
	count = 75
	spawning = 75
	lifespan = 15
	fade = 25
	color_change = generator(GEN_NUM, 0.08, 0.07)
	velocity = generator(GEN_CIRCLE, 25, 25)
	rotation = generator(GEN_NUM, -45, 45)
	scale = 0.45
	grow = 0.05
	friction = 0.05

/particles/dirt_kickup
	icon = 'icons/effects/96x157.dmi'
	icon_state = "smoke"
	width = 500
	height = 500
	count = 80
	spawning = 10
	lifespan = 15
	fade = 10
	fadein = 3
	scale = generator(GEN_NUM, 0.18, 0.15)
	position = generator(GEN_SPHERE, 150, 150)
	color = COLOR_BROWN
	velocity = list(0, 12)
	grow = list(0, 0.01)
	gravity = list(0, -1.25)

/particles/water_splash
	icon = 'icons/effects/96x157.dmi'
	icon_state = "smoke2"
	width = 500
	height = 500
	count = 80
	spawning = 10
	lifespan = 15
	fade = 10
	fadein = 3
	scale = generator(GEN_NUM, 0.18, 0.15)
	position = generator(GEN_SPHERE, 150, 150)
	velocity = list(0, 12)
	grow = list(0, 0.01)
	gravity = list(0, -1.25)

/particles/dirt_kickup_large
	icon = 'icons/effects/96x157.dmi'
	icon_state = "smoke"
	width = 750
	height = 750
	gradient = list("#5f4328", "#8f5824", "#333333", "#808080", "#FFFFFF")
	count = 3
	spawning = 3
	lifespan = 20
	fade = 10
	fadein = 3
	scale = generator(GEN_NUM, 0.5, 1)
	position = generator(GEN_BOX, list(-12, 32), list(12, 48), NORMAL_RAND)
	color = generator(GEN_NUM, 0, 0.25)
	color_change = generator(GEN_NUM, 0.04, 0.05)
	velocity = list(0, 12)
	grow = list(0, 0.025)
	gravity = list(0, -1)

/particles/dirt_kickup_large/deva
	velocity = list(0, 25)
	scale = generator(GEN_NUM, 1, 1.25)
	grow = list(0, 0.03)
	gravity = list(0, -2)
	fade = 10

/particles/water_splash_large
	icon = 'icons/effects/96x157.dmi'
	icon_state = "smoke2"
	width = 750
	height = 750
	count = 3
	spawning = 3
	lifespan = 20
	fade = 10
	fadein = 3
	scale = generator(GEN_NUM, 1, 1.25)
	position = generator(GEN_BOX, list(-12, 32), list(12, 48), NORMAL_RAND)
	velocity = list(0, 12)
	grow = list(0, 0.05)
	gravity = list(0, -1)

/particles/falling_debris
	icon = 'icons/effects/particles/generic_particles.dmi'
	icon_state = "rock"
	width = 750
	height = 750
	count = 75
	spawning = 75
	lifespan = 20
	fade = 5
	position = generator(GEN_SPHERE, 16, 16)
	color = COLOR_DARK_BROWN
	velocity = list(0, 26)
	scale = generator(GEN_NUM, 1, 2)
	gravity = list(0, -3)
	friction = 0.02
	drift = generator(GEN_CIRCLE, 0, 1.5)

/particles/falling_debris/small
	count = 40
	spawning = 40

/particles/water_falling
	icon = 'icons/effects/particles/generic_particles.dmi'
	icon_state = "cross"
	width = 750
	height = 750
	count = 75
	spawning = 75
	lifespan = 20
	fade = 5
	position = generator(GEN_SPHERE, 16, 16)
	velocity = list(0, 26)
	scale = generator(GEN_NUM, 1, 2)
	gravity = list(0, -3)
	friction = 0.02
	drift = generator(GEN_CIRCLE, 0, 1.5)

/particles/sparks_outwards
	icon = 'icons/effects/64x64.dmi'
	icon_state = "flare"
	width = 750
	height = 750
	count = 40
	spawning = 20
	lifespan = 15
	fade = 15
	position = generator(GEN_SPHERE, 8, 8)
	velocity = generator(GEN_CIRCLE, 30, 30)
	scale = 0.1
	friction = 0.1

/particles/water_outwards
	icon = 'icons/effects/particles/generic_particles.dmi'
	icon_state = "cross"
	width = 750
	height = 750
	count = 40
	spawning = 20
	lifespan = 15
	fade = 15
	position = generator(GEN_SPHERE, 8, 8)
	velocity = generator(GEN_CIRCLE, 30, 30)
	scale = 1.25
	friction = 0.1

/obj/effect/temp_visual/explosion
	name = "boom"
	icon = 'icons/effects/96x96.dmi'
	icon_state = "explosion"
	duration = 25
	plane = EFFECTS_BELOW_LIGHTING_PLANE
	layer = 100
	///smoke wave particle holder
	var/obj/effect/abstract/particle_holder/smoke_wave
	///explosion smoke particle holder
	var/obj/effect/abstract/particle_holder/explosion_smoke
	///debris dirt kickup particle holder
	var/obj/effect/abstract/particle_holder/dirt_kickup
	///falling debris particle holder
	var/obj/effect/abstract/particle_holder/falling_debris
	///sparks particle holder
	var/obj/effect/abstract/particle_holder/sparks
	///large dirt kickup particle holder
	var/obj/effect/abstract/particle_holder/large_kickup

/obj/effect/temp_visual/explosion/Initialize(mapload, radius, color, small = FALSE, large = FALSE)
	. = ..()
	set_light(radius, radius, color)
	generate_particles(radius, small, large)
	if(iswater(get_turf(src)))
		icon_state = null
		return
	var/image/I = image(icon, src, icon_state, 10, -32, -32)
	var/matrix/rotate = matrix()
	rotate.Turn(rand(0, 359))
	I.transform = rotate
	overlays += I //we use an overlay so the explosion and light source are both in the correct location plus so the particles don't rotate with the explosion
	icon_state = null

///Generate the particles
/obj/effect/temp_visual/explosion/proc/generate_particles(radius, small = FALSE, large = FALSE)
	var/turf/turf_type = get_turf(src)


	if(iswater(turf_type))
		smoke_wave = new(src.loc, /particles/wave_water)
		explosion_smoke = new(src.loc, /particles/explosion_water)
		dirt_kickup = new(src.loc, /particles/water_splash)
		falling_debris = new(src.loc, /particles/water_falling)
		sparks = new(src.loc, /particles/water_outwards)
		large_kickup = new(src.loc, /particles/water_splash_large)
	else
		if(small)
			smoke_wave = new(src.loc, /particles/smoke_wave/small)
		else
			smoke_wave = new(src.loc, /particles/smoke_wave)



		if(large)
			explosion_smoke = new(src.loc, /particles/explosion_smoke/deva)
		else if(small)
			explosion_smoke = new(src.loc, /particles/explosion_smoke/small)
		else
			explosion_smoke = new(src.loc, /particles/explosion_smoke)

		dirt_kickup = new(src.loc, /particles/dirt_kickup)
		if(small)
			falling_debris = new(src.loc, /particles/falling_debris/small)
		else
			falling_debris = new(src.loc, /particles/falling_debris)
		sparks = new(src.loc, /particles/sparks_outwards)

		if(large)
			large_kickup = new(src.loc, /particles/dirt_kickup_large/deva)
		else
			large_kickup = new(src.loc, /particles/dirt_kickup_large)

	if(large)
		smoke_wave.particles.velocity = generator(GEN_CIRCLE, 6 * radius, 6 * radius)
	else if(small)
		smoke_wave.particles.velocity = generator(GEN_CIRCLE, 3 * radius, 3 * radius)
	else
		smoke_wave.particles.velocity = generator(GEN_CIRCLE, 5 * radius, 5 * radius)
	explosion_smoke.layer = layer + 0.1
	sparks.particles.velocity = generator(GEN_CIRCLE, 8 * radius, 8 * radius)

	smoke_wave.particles.velocity = generator(GEN_CIRCLE, 6 * radius, 6 * radius)
	explosion_smoke.layer = layer + 0.1
	sparks.particles.velocity = generator(GEN_CIRCLE, 8 * radius, 8 * radius)
	addtimer(CALLBACK(src, PROC_REF(set_count_short)), 5)
	addtimer(CALLBACK(src, PROC_REF(set_count_long)), 10)

/obj/effect/temp_visual/explosion/proc/set_count_short()
	smoke_wave.particles.count = 0
	explosion_smoke.particles.count = 0
	sparks.particles.count = 0
	large_kickup.particles.count = 0
	falling_debris.particles.count = 0

/obj/effect/temp_visual/explosion/proc/set_count_long()
	dirt_kickup.particles.count = 0

/obj/effect/temp_visual/explosion/Destroy()
	QDEL_NULL(smoke_wave)
	QDEL_NULL(explosion_smoke)
	QDEL_NULL(sparks)
	QDEL_NULL(large_kickup)
	QDEL_NULL(falling_debris)
	QDEL_NULL(dirt_kickup)
	return ..()

/particles/smokescreen
	icon = 'icons/effects/particles/smokes_updated.dmi'
	//icon_state = list("testsmoke" = 3, "smoke" = 2)
	icon_state = "smokkum"
	width = 750
	height = 750
	gradient = list("#dedadb", "#ededed")
	count = 60
	spawning = 6
	//lifespan = generator(GEN_NUM, 1, 2.98, NORMAL_RAND)
	lifespan = generator(GEN_NUM, 5, 10.98, NORMAL_RAND)
	fade = 4
	fadein = 3
	//scale = generator(GEN_NUM, 1.5, 2, NORMAL_RAND)
	position = generator(GEN_SPHERE, 16, 16)
	color = generator(GEN_NUM, 0, 0.25)
	rotation = generator(GEN_NUM, 0, 360, NORMAL_RAND)
	spin = generator(GEN_NUM, 0.5, 1, NORMAL_RAND)
	color_change = generator(GEN_NUM, 0.04, 0.05)
	grow = generator(GEN_NUM, -0.01, -0.03, NORMAL_RAND)
	//gravity = list(0, -1)

/obj/effect/abstract/particle_holder/test
	particles = new/particles/smokescreen
	blend_mode = BLEND_OVERLAY