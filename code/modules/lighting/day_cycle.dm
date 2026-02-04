/datum/day_cycle_phase
	var/color
	var/duration
	var/output_channel
	var/ignore_color_modifiers = FALSE

/datum/day_cycle_phase/New(color, duration, output_channel, ignore_color_modifiers = FALSE)
	src.color = color
	src.duration = duration
	src.output_channel = output_channel
	src.ignore_color_modifiers = ignore_color_modifiers

/datum/day_cycle_phase/proc/on_cycle_start()
	if(output_channel)
		IO_output(output_channel, "Start", SSday_cycle)

/datum/day_cycle_phase/proc/on_cycle_end()
	if(output_channel)
		IO_output(output_channel, "End", SSday_cycle)

/datum/weather_type
	var/name = "clear"
	var/screenfilter_type
	var/color_modifier
	var/looping_sound
	var/indoor_looping_sound
	var/looping_volume = 100

/datum/weather_type/proc/on_start()
	return

/datum/weather_type/proc/on_end()
	return

/datum/weather_type/clear
	name = "clear"

/datum/weather_type/rainy
	name = "rainy"
	screenfilter_type = /obj/screenfilter/rain
	looping_sound = 'sound/weather/rainloop.ogg'
	indoor_looping_sound = 'sound/weather/rainloop_inside.ogg'
	looping_volume = 62

/datum/weather_type/rainy/on_start()
	IO_output("env_leak:Enable", null, SSday_cycle)

/datum/weather_type/rainy/on_end()
	IO_output("env_leak:Disable", null, SSday_cycle)

/datum/weather_type/storming
	name = "storming"
	screenfilter_type = /obj/screenfilter/storm
	color_modifier = "#111122" 
	looping_sound = 'sound/weather/stormloop.ogg'
	indoor_looping_sound = 'sound/weather/stormindoors.ogg'
	looping_volume = 80

/datum/weather_type/storming/on_start()
	IO_output("env_leak:Enable", null, SSday_cycle)

/datum/weather_type/storming/on_end()
	IO_output("env_leak:Disable", null, SSday_cycle)

/datum/weather_type/snowing
	name = "snowing"
	screenfilter_type = /obj/screenfilter/snow
	looping_volume = 50

/datum/weather_type/snowstorm
	name = "snowstorm"
	screenfilter_type = /obj/screenfilter/snowstorm
	looping_volume = 90

/datum/climate
	var/name = "temperate"
	var/color_modifier
	var/list/allowed_weather = list("clear", "rainy", "storming", "snowing", "snowstorm")

/datum/climate/temperate
	name = "temperate"
	allowed_weather = list("clear", "rainy", "storming")

/datum/climate/cold
	name = "cold"
	color_modifier = "#ccddff"
	allowed_weather = list("clear", "snowing", "snowstorm")

/datum/climate/warm
	name = "warm"
	color_modifier = "#ffeecc"
	allowed_weather = list("clear", "rainy", "storming")


/client/proc/debug_day_cycle_phase()
	set name = "Debug Day Cycle Phase"
	set category = "Debug"
	
	if(!SSday_cycle)
		return
	
	var/list/phase_names = list()
	for(var/datum/day_cycle_phase/P in SSday_cycle.phases)
		if(P.output_channel)
			phase_names[P.output_channel] = P
		else
			phase_names["[P.color]"] = P
			
	var/chosen_name = input(src, "Select phase to jump to", "Debug Day Cycle") as null|anything in phase_names
	if(!chosen_name)
		return
		
	var/datum/day_cycle_phase/chosen_phase = phase_names[chosen_name]
	
	var/accumulated_time = 0
	for(var/datum/day_cycle_phase/P in SSday_cycle.phases)
		if(P == chosen_phase)
			break
		accumulated_time += P.duration
		
	SSday_cycle.current_time = accumulated_time
	SSday_cycle.last_process_time = world.time 
	SSday_cycle.update_cycle() 

/client/proc/debug_day_cycle_speed()
	set name = "Debug Day Cycle Speed"
	set category = "Debug"
	
	if(!SSday_cycle)
		return
		
	var/new_speed = input(src, "Set day cycle speed multiplier", "Debug Day Cycle Speed", SSday_cycle.speed) as num|null
	if(new_speed == null)
		return
		
	SSday_cycle.speed = new_speed

/client/proc/debug_set_weather()
	set name = "Debug Set Weather"
	set category = "Debug"
	
	if(!SSday_cycle)
		return
		
	var/chosen_weather = input(src, "Select weather", "Debug Weather") as null|anything in SSday_cycle.weather_types
	if(!chosen_weather)
		return
		
	if(!SSday_cycle.set_weather(chosen_weather))
		to_chat(src, "Failed to set weather (not allowed in current climate?)")

/client/proc/debug_set_climate()
	set name = "Debug Set Climate"
	set category = "Debug"
	
	if(!SSday_cycle)
		return
		
	var/chosen_climate = input(src, "Select climate", "Debug Climate") as null|anything in SSday_cycle.climates
	if(!chosen_climate)
		return
		
	SSday_cycle.active_climate = SSday_cycle.climates[chosen_climate]
	to_chat(src, "Climate set to [chosen_climate]")

/client/proc/debug_weather_info()
	set name = "Debug Weather Info"
	set category = "Debug"
	
	if(!SSday_cycle)
		return
		
	var/msg = "Current Weather: [SSday_cycle.active_weather ? SSday_cycle.active_weather.name : "None"]\n"
	msg += "Current Climate: [SSday_cycle.active_climate ? SSday_cycle.active_climate.name : "None"]\n"
	msg += "Current Color: [SSday_cycle.current_color]\n"
	msg += "Next Lightning: [SSday_cycle.next_lightning - world.time] ds\n"
	
	to_chat(src, msg)

/client/proc/debug_set_weather_blend_mode()
	set name = "Debug Set Weather Blend Mode"
	set category = "Debug"

	if(!SSday_cycle)
		return

	var/list/modes = list(
		"Normal" = 0,
		"Overlay" = 1,
		"Add" = 2,
		"Subtract" = 3,
		"Multiply" = 4
	)

	var/chosen = input(src, "Select Blend Mode", "Debug") as null|anything in modes
	if(!chosen)
		return

	var/mode_val = modes[chosen]

	var/target = input(src, "Apply to what?", "Debug") as null|anything in list("Weather Filters", "Ground Wetness Overlay", "Reflection Wetness Overlay", "All")
	if(!target)
		return

	if(target == "Weather Filters" || target == "All")
		for(var/filter_type in SSday_cycle.active_weather_filters)
			var/obj/screenfilter/F = SSday_cycle.active_weather_filters[filter_type]
			F.blend_mode = mode_val
			to_chat(src, "Set [filter_type] blend_mode to [chosen]")

	if(target == "Ground Wetness Overlay" || target == "All")
		for(var/client/C in GLOB.clients)
			if(C.mob?.wet_overlay)
				C.mob.wet_overlay.blend_mode = mode_val
		to_chat(src, "Set all clients' ground wetness blend_mode to [chosen]")

	if(target == "Reflection Wetness Overlay" || target == "All")
		for(var/client/C in GLOB.clients)
			if(C.mob?.reflection_wet_overlay)
				C.mob.reflection_wet_overlay.blend_mode = mode_val
		to_chat(src, "Set all clients' reflection wetness blend_mode to [chosen]")

/client/proc/debug_set_wetness()
	set name = "Debug Set Wetness"
	set category = "Debug"
	if(!SSday_cycle) return
	var/W = input(src, "Set wetness (0-255)", "Debug", SSday_cycle.wetness) as num|null
	if(W != null)
		SSday_cycle.wetness = W
		to_chat(src, "Wetness set to [W]")