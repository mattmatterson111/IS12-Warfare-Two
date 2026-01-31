/obj/effect/map_entity/environment_blocker
	name = "environment_blocker"
	icon = 'icons/hammer/source.dmi'
	icon_state = "red"
	is_brush = TRUE
	alpha = 255
	mouse_opacity = 0
	plane = WEATHER_MASK_PLANE // Same as weather mask

/obj/effect/map_entity/environment_blocker/Initialize()
	. = ..()
	icon = 'icons/effects/lighting_overlay.dmi'
	icon_state = "white"
	color = "#FF0000"
	invisibility = 255

	var/turf/T = get_turf(src)
	if(T)
		for(var/obj/effect/lighting_dummy/daylight/D in T)
			qdel(D)
		for(var/obj/effect/map_entity/weather_mask/W in T)
			qdel(W)
