/obj/effect/crater_cover
	name = "shell crater"
	desc = "A deep hole in the ground. Provides cover when crouching."
	icon = null
	anchored = TRUE
	density = FALSE
	mouse_opacity = 0
	var/cover_strength = 40
	var/list/shifted_mobs = list()
	var/list/auto_crouched_mobs = list()

/obj/effect/crater_cover/Initialize()
	. = ..()
	for(var/mob/living/L in loc)
		if(L.stat != DEAD)
			L.pixel_y -= 8
			shifted_mobs += L
			if(!L.crouching)
				L.toggle_crouch()
				auto_crouched_mobs += L

/obj/effect/crater_cover/Crossed(atom/movable/AM)
	if(isliving(AM))
		var/mob/living/L = AM
		if(L.stat != DEAD)
			L.pixel_y -= 8
			shifted_mobs += L
			if(!L.crouching)
				L.toggle_crouch()
				auto_crouched_mobs += L
	return ..()

/obj/effect/crater_cover/Uncrossed(atom/movable/AM)
	if(isliving(AM))
		var/mob/living/L = AM
		if(L in shifted_mobs)
			L.pixel_y += 8
			shifted_mobs -= L
		if(L in auto_crouched_mobs)
			if(L.crouching)
				L.toggle_crouch()
			auto_crouched_mobs -= L
	return ..()

/obj/effect/crater_cover/Destroy()
	for(var/mob/living/L in shifted_mobs)
		L.pixel_y += 8
	for(var/mob/living/L in auto_crouched_mobs)
		if(L.crouching)
			L.toggle_crouch()
	shifted_mobs.Cut()
	auto_crouched_mobs.Cut()
	. = ..()

/obj/effect/crater_cover/CanPass(atom/movable/mover, turf/target)
	if(istype(mover, /obj/item/projectile))
		var/obj/item/projectile/P = mover
		return check_projectile_blocking(P)
	return ..()

/obj/effect/crater_cover/proc/check_projectile_blocking(obj/item/projectile/P)
	for(var/mob/living/L in loc)
		if(L.stat == DEAD)
			continue
		if(!L.lying && !L.crouching)
			continue
		if(get_dist(P.starting, loc) <= 1)
			continue
		if(prob(cover_strength))
			visible_message("<span class='warning'>The shot hits the crater's edge!</span>")
			return FALSE
	return TRUE

/obj/effect/lingering_haze
	name = "dust haze"
	desc = "A cloud of dust and debris kicked up by an explosion."
	icon = 'icons/effects/effects.dmi'
	icon_state = "smoke"
	plane = ABOVE_HUMAN_PLANE
	layer = ABOVE_HUMAN_LAYER + 1
	anchored = TRUE
	mouse_opacity = 0
	alpha = 0

/obj/effect/lingering_haze/Initialize(mapload, duration = 20)
	. = ..()
	pixel_x = rand(-32, 32)
	pixel_y = rand(-32, 32)
	transform = matrix() * rand(2.0, 4.0)
	
	animate(src, alpha = 180, time = 10)
	
	addtimer(CALLBACK(src, PROC_REF(fade_out), duration), 30)

/obj/effect/lingering_haze/proc/fade_out(duration)
	animate(src, alpha = 0, time = duration)
	QDEL_IN(src, duration)
