/obj/effect/map_entity/weather_mask
	name = "weather_mask"
	icon = 'icons/hammer/source.dmi'
	icon_state = "noteam"
	plane = WEATHER_MASK_PLANE
	is_brush = TRUE
	alpha = 255
	mouse_opacity = 0

/obj/effect/map_entity/weather_mask/New()
	. = ..()
	icon = 'icons/effects/lighting_overlay.dmi'
	icon_state = "white"

/obj/effect/map_entity/weather_events
	name = "weather_events"
	icon_state = "round_events"

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
			GLOB.day_cycle_controller.set_weather(new_type)
		if("reset")
			GLOB.day_cycle_controller.set_weather("clear")
