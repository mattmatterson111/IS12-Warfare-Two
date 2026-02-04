/obj/effect/falling_crate
	name = "incoming supply drop"
	icon = null
	density = FALSE
	anchored = TRUE
	mouse_opacity = 0
	plane = EFFECTS_BELOW_LIGHTING_PLANE
	layer = 99

	var/atom/movable/payload
	var/fall_time = 1 SECOND

/obj/structure/closet/crate/war_metal
	icon = 'icons/obj/war_crates.dmi'
	icon_state = "metal01-mini"

/obj/structure/closet/crate/war_metal/New()
	. = ..()
	icon_state = "metal0[rand(1,5)]"
	if(prob(1))
		icon_state = "metal01-mini"
	icon_opened = "[icon_state]-open"
	icon_closed = icon_state


/obj/effect/falling_crate/Initialize(mapload, crate_type, list/contents_to_spawn)
	. = ..()
	if(!crate_type)
		crate_type = /obj/structure/closet/crate/wooden

	payload = new crate_type(src)
	if(!payload)
		return INITIALIZE_HINT_QDEL

	if(contents_to_spawn && length(contents_to_spawn))
		for(var/item_type in contents_to_spawn)
			var/count = contents_to_spawn[item_type]
			if(!count)
				count = 1
			for(var/i in 1 to count)
				new item_type(payload)
	
	payload.plane = src.plane

	vis_contents += payload

	payload.pixel_y = 300
	payload.layer = layer
	payload.mouse_opacity = 0

	animate(payload, pixel_y = 0, time = fall_time)

	addtimer(CALLBACK(src, PROC_REF(land)), fall_time)

/obj/effect/falling_crate/proc/land()
	var/turf/T = get_turf(src)
	if(!T || !payload)
		qdel(src)
		return
		
	payload.plane = initial(payload.plane)

	vis_contents -= payload

	payload.layer = initial(payload.layer)
	payload.mouse_opacity = initial(payload.mouse_opacity)

	payload.forceMove(T)

	playsound(T, 'sound/effects/grillehit.ogg', 60, TRUE)

	new /obj/effect/dust_cloud(T)

	payload = null
	qdel(src)

/obj/effect/dust_cloud
	name = "dust"
	icon = 'icons/effects/effects.dmi'
	icon_state = "smoke"
	plane = ABOVE_HUMAN_PLANE
	layer = ABOVE_HUMAN_LAYER
	mouse_opacity = 0
	anchored = TRUE

/obj/effect/dust_cloud/Initialize()
	. = ..()
	alpha = 200
	var/matrix/t = matrix(transform)
	t.Scale(2,2)
	animate(src, alpha = 0, transform = t, time = 15)
	QDEL_IN(src, 15)
