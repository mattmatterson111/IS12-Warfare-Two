/obj/effect/incendiary_zone
	name = "burning ground"
	icon = 'icons/effects/fire.dmi'
	icon_state = "red_3"
	layer = BELOW_OBJ_LAYER
	anchored = TRUE
	mouse_opacity = 0

	var/radius = 2
	var/duration = 20 SECONDS
	var/burn_damage = 15
	var/fire_stacks = 5
	var/time_remaining
	var/list/affected_turfs = list()
	var/list/fire_overlays = list()

/obj/effect/incendiary_zone/Initialize(mapload, override_radius, override_duration)
	. = ..()
	if(override_radius)
		radius = override_radius
	if(override_duration)
		duration = override_duration

	time_remaining = duration

	for(var/turf/T in range(radius, src))
		if(T.density)
			continue
		affected_turfs += T
		var/obj/effect/overlay/fire_overlay/F = new(T)
		F.incendiary_parent = src
		fire_overlays += F

	set_light(6, l_color = "#E38F46")
	START_PROCESSING(SSobj, src)

/obj/effect/incendiary_zone/Process()
	var/drain = 10
	var/turf/curr_T = get_turf(src)
	if(SSday_cycle.active_weather?.name == "storming")
		if(curr_T && (locate(/obj/effect/map_entity/weather_mask) in curr_T) && !(locate(/obj/effect/map_entity/environment_blocker) in curr_T))
			drain = 20
	time_remaining -= drain

	if(time_remaining <= 0)
		qdel(src)
		return

	for(var/turf/T in affected_turfs)
		for(var/mob/living/M in T)
			if(M.stat == DEAD)
				continue

			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				if(istype(H.wear_suit, /obj/item/clothing/suit/fire))
					H.adjustFireLoss(burn_damage * 0.25)
					continue

			M.adjust_fire_stacks(fire_stacks)
			if(prob(50))
				M.IgniteMob()
			M.adjustFireLoss(burn_damage)
			to_chat(M, "<span class='danger'>You are burned by the flames!</span>")

	update_visuals()

/obj/effect/incendiary_zone/proc/update_visuals()
	var/fraction = time_remaining / duration
	var/new_state
	var/new_light

	if(fraction < 0.33)
		new_state = "red_1"
		new_light = 2
	else if(fraction < 0.66)
		new_state = "red_2"
		new_light = 4
	else
		new_state = "red_3"
		new_light = 6

	if(icon_state != new_state)
		icon_state = new_state
		set_light(new_light, l_color = "#E38F46")
		for(var/obj/effect/overlay/fire_overlay/F in fire_overlays)
			F.icon_state = new_state

/obj/effect/incendiary_zone/Destroy()
	set_light(0)
	STOP_PROCESSING(SSobj, src)
	for(var/obj/effect/overlay/fire_overlay/F in fire_overlays)
		qdel(F)
	fire_overlays = null
	affected_turfs = null
	. = ..()

/obj/effect/overlay/fire_overlay
	icon = 'icons/effects/fire.dmi'
	icon_state = "red_3"
	layer = BELOW_OBJ_LAYER
	mouse_opacity = 0
	var/obj/effect/incendiary_zone/incendiary_parent

/obj/effect/overlay/fire_overlay/Destroy()
	incendiary_parent = null
	. = ..()

/obj/mortar/smoke
	name = "smoke mortar"

/obj/mortar/smoke/New()
	..()
	var/datum/effect/effect/system/smoke_spread/S = new()
	S.attach(loc)
	S.set_up(null, 50, 0, loc)
	spawn(0)
		S.start()
	qdel(src)

/obj/mortar/incendiary
	name = "incendiary mortar"

/obj/mortar/incendiary/New()
	..()
	new /obj/effect/incendiary_zone(loc, 2, 20 SECONDS)
	qdel(src)

/obj/mortar/cluster
	name = "cluster mortar"

/obj/mortar/cluster/New()
	..()
	var/turf/T = get_turf(src)
	var/num_bomblets = rand(5, 7)

	for(var/i in 1 to num_bomblets)
		var/offset_x = rand(-2, 2)
		var/offset_y = rand(-2, 2)
		var/turf/target = locate(T.x + offset_x, T.y + offset_y, T.z)
		if(target)
			spawn(rand(0, 5))
				explosion(target, 0, 0, 1, 1, particles = TRUE, autosize = FALSE, sizeofboom = 0.5, large = FALSE)
				add_crater(target, 0.3)
	qdel(src)

/obj/mortar/concussion
	name = "concussion mortar"

/obj/mortar/concussion/New()
	..()
	var/turf/T = get_turf(src)

	explosion(T, 0, 0, 1, 3, particles = TRUE, autosize = FALSE, sizeofboom = 1, large = FALSE)

	for(var/mob/living/M in range(4, T))
		var/dist = get_dist(M, T)
		var/weakness_duration = max(1, 4 - dist)

		M.Weaken(weakness_duration)
		if(M.ear_damage != null)
			M.ear_damage += rand(3, 8)
		shake_camera(M, 10, 2)
		to_chat(M, "<span class='danger'>The blast knocks you off your feet!</span>")

	qdel(src)

/obj/mortar/ballistic
	name = "ballistic mortar"

/obj/mortar/ballistic/New()
	..()
	var/turf/T = get_turf(src)
	
	explosion(T, 2, 3, 4, 5, particles = TRUE, autosize = FALSE, sizeofboom = 3, large = TRUE)
	
	for(var/mob/living/M in range(7, T))
		if(M.stat == DEAD)
			continue
		shake_camera(M, 25, 4)
		if(M.ear_damage != null)
			M.ear_damage += rand(15, 30)
		to_chat(M, "<span class='danger'>A massive impact shakes the earth!</span>")
		
		var/dist = get_dist(M, T)
		if(dist <= 3)
			M.Weaken(5)
		else if(dist <= 5)
			M.Weaken(2)

	qdel(src)
