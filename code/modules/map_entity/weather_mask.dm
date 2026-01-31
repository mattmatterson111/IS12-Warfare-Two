/obj/effect/map_entity/weather_mask
	name = "weather_mask"
	icon = 'icons/hammer/source.dmi'
	icon_state = "noteam"
	plane = WEATHER_MASK_PLANE
	is_brush = TRUE
	alpha = 255
	mouse_opacity = 0

/obj/effect/map_entity/weather_mask/Initialize()
	. = ..()
	icon = 'icons/effects/lighting_overlay.dmi'
	icon_state = "white"
	var/turf/T = get_turf(src)
	if(T && !(locate(/obj/effect/lighting_dummy/daylight) in T) && !(locate(/obj/effect/map_entity/environment_blocker) in T))
		new /obj/effect/lighting_dummy/daylight(T)

/obj/effect/map_entity/weather_events
	name = "weather_events"
	icon_state = "round_events"
	targetname = "weather_events"

/obj/effect/map_entity/weather_events/auto_leaks
	name = "auto_leaks (auto-target env_leak)"
	targetname = "weather_events"
	connections = list(
		"OnRainy:env_leak:Enable",
		"OnStorming:env_leak:Enable",
		"OnClear:env_leak:Disable",
		"OnSnowing:env_leak:Disable",
		"OnSnowstorm:env_leak:Disable"
	)

/obj/effect/map_entity/day_events
	name = "day_events"
	icon_state = "round_events"

/obj/effect/map_entity/env_weather
	name = "env_weather"
	icon_state = "sun"
	var/weather_type = "clear"

/obj/effect/map_entity/env_weather/receive_input(input_name, atom/activator, atom/caller, list/params)
	. = ..()
	if(.)
		return TRUE
	switch(lowertext(input_name))
		if("setweather")
			var/new_type = weather_type
			if(params && params["weather_type"])
				new_type = params["weather_type"]
			SSday_cycle.set_weather(new_type)
		if("reset")
			SSday_cycle.set_weather("clear")
