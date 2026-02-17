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
	var/wet_ground_icon_state = "raintest"
	var/wet_reflection_icon_state = "raintest"

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
	wet_ground_icon_state = "whiteFull"
	wet_reflection_icon_state = "whiteFull"

/datum/weather_type/snowstorm
	name = "snowstorm"
	screenfilter_type = /obj/screenfilter/snowstorm
	looping_sound = 'sound/ambience/cold_outside2.ogg'
	indoor_looping_sound = 'sound/ambience/cold_outside.ogg'
	looping_volume = 90
	wet_ground_icon_state = "whiteFull"
	wet_reflection_icon_state = "whiteFull"

/datum/weather_modifier
	var/name = "generic_placeholder"
	var/display_name = "Generic Placeholder"
	var/screenfilter_type
	var/color_modifier
	var/looping_sound
	var/indoor_looping_sound
	var/looping_volume = 100

/datum/weather_modifier/proc/on_start()
	return

/datum/weather_modifier/proc/on_end()
	return

/datum/weather_modifier/generic_placeholder
	name = "generic_placeholder"
	display_name = "Generic Placeholder"

/datum/weather_modifier/foggy
	name = "foggy"
	display_name = "Foggy"

/datum/weather_modifier/weather_misc
	name = "weather_misc"
	display_name = "Weather Misc"

/obj/screen/weather_modifier/foggy
	name = "fog modifier overlay"
	icon = 'icons/mob/extra_overlays_fuck.dmi'
	icon_state = "fog"
	screen_loc = "CENTER-7,CENTER-7"
	mouse_opacity = 0
	plane = FOG_MASTER_PLANE
	blend_mode = BLEND_OVERLAY
	alpha = 0

/obj/screen/weather_modifier/foggy_cutout
	name = "fog modifier cutout"
	icon = 'icons/mob/evil96.dmi'
	icon_state = "fog_cutout"
	screen_loc = "CENTER-7,CENTER-7"
	mouse_opacity = 0
	plane = FOG_CUTOUT_PLANE
	alpha = 255

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
	set category = "Weather"
	
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

	if(!SSday_cycle.set_day_cycle_phase(chosen_name))
		to_chat(src, "Failed to set phase [chosen_name].")

/client/proc/debug_day_cycle_speed()
	set name = "Debug Day Cycle Speed"
	set category = "Weather"
	
	if(!SSday_cycle)
		return
		
	var/new_speed = input(src, "Set day cycle speed multiplier", "Debug Day Cycle Speed", SSday_cycle.speed) as num|null
	if(new_speed == null)
		return
		
	SSday_cycle.speed = new_speed

/client/proc/debug_set_weather()
	set name = "Debug Set Weather"
	set category = "Weather"
	
	if(!SSday_cycle)
		return
		
	var/chosen_weather = input(src, "Select weather", "Debug Weather") as null|anything in SSday_cycle.weather_types
	if(!chosen_weather)
		return
		
	if(!SSday_cycle.set_weather(chosen_weather))
		to_chat(src, "Failed to set weather (not allowed in current climate?)")

/client/proc/debug_set_climate()
	set name = "Debug Set Climate"
	set category = "Weather"
	
	if(!SSday_cycle)
		return
		
	var/chosen_climate = input(src, "Select climate", "Debug Climate") as null|anything in SSday_cycle.climates
	if(!chosen_climate)
		return
		
	SSday_cycle.active_climate = SSday_cycle.climates[chosen_climate]
	to_chat(src, "Climate set to [chosen_climate]")

/client/proc/debug_weather_info()
	set name = "Debug Weather Info"
	set category = "Weather"
	
	if(!SSday_cycle)
		return
		
	var/msg = "Current Weather: [SSday_cycle.active_weather ? SSday_cycle.active_weather.name : "None"]\n"
	msg += "Current Climate: [SSday_cycle.active_climate ? SSday_cycle.active_climate.name : "None"]\n"
	msg += "Current Color: [SSday_cycle.current_color]\n"
	msg += "Next Lightning: [SSday_cycle.next_lightning - world.time] ds\n"
	var/list/active_modifier_names = SSday_cycle.get_active_modifier_names()
	msg += "Active Modifiers: [active_modifier_names.len ? english_list(active_modifier_names) : "None"]\n"
	
	to_chat(src, msg)

/client/proc/debug_add_modifier()
	set name = "Debug Add Modifier"
	set category = "Weather"

	if(!SSday_cycle)
		return

	var/chosen_modifier = input(src, "Select modifier to add", "Debug Modifier") as null|anything in SSday_cycle.modifier_types
	if(!chosen_modifier)
		return

	if(!SSday_cycle.add_modifier(chosen_modifier))
		to_chat(src, "Failed to add modifier [chosen_modifier].")

/client/proc/debug_remove_modifier()
	set name = "Debug Remove Modifier"
	set category = "Weather"

	if(!SSday_cycle)
		return

	var/list/active = SSday_cycle.get_active_modifier_names()
	if(!active || !active.len)
		to_chat(src, "No active modifiers to remove.")
		return

	var/chosen_modifier = input(src, "Select active modifier to remove", "Debug Modifier") as null|anything in active
	if(!chosen_modifier)
		return

	if(!SSday_cycle.remove_modifier(chosen_modifier))
		to_chat(src, "Failed to remove modifier [chosen_modifier].")

/client/proc/debug_toggle_modifier()
	set name = "Debug Toggle Modifier"
	set category = "Weather"

	if(!SSday_cycle)
		return

	var/chosen_modifier = input(src, "Select modifier to toggle", "Debug Modifier") as null|anything in SSday_cycle.modifier_types
	if(!chosen_modifier)
		return

	if(!SSday_cycle.toggle_modifier(chosen_modifier))
		to_chat(src, "Failed to toggle modifier [chosen_modifier].")

/client/proc/debug_clear_modifiers()
	set name = "Debug Clear Modifiers"
	set category = "Weather"

	if(!SSday_cycle)
		return

	SSday_cycle.clear_modifiers()
	to_chat(src, "Cleared all active modifiers.")

/client/proc/debug_modifier_info()
	set name = "Debug Modifier Info"
	set category = "Weather"

	if(!SSday_cycle)
		return

	var/list/registered_modifier_names = SSday_cycle.get_modifier_type_names()
	var/list/active_modifier_names = SSday_cycle.get_active_modifier_names()
	var/msg = "Registered Modifiers: [registered_modifier_names.len ? english_list(registered_modifier_names) : "None"]\n"
	msg += "Active Modifiers: [active_modifier_names.len ? english_list(active_modifier_names) : "None"]\n"
	var/list/foggy_params = SSday_cycle.get_modifier_params("foggy")
	if(foggy_params)
		msg += "Foggy Params: blur_size=[foggy_params["blur_size"]], fog_scale=[foggy_params["fog_scale"]], fog_alpha=[foggy_params["fog_alpha"]]\n"
	var/list/weather_misc_params = SSday_cycle.get_modifier_params("weather_misc")
	if(weather_misc_params)
		msg += "Weather Misc Params: base_alpha=[weather_misc_params["base_alpha"]]\n"
	to_chat(src, msg)

/client/proc/debug_edit_modifier_params()
	set name = "Debug Edit Modifier Params"
	set category = "Weather"

	if(!SSday_cycle)
		return

	var/chosen_modifier = input(src, "Select modifier", "Debug Modifier Params") as null|anything in SSday_cycle.modifier_types
	if(!chosen_modifier)
		return

	var/list/editable_params = SSday_cycle.get_editable_modifier_param_names(chosen_modifier)
	if(!editable_params || !editable_params.len)
		to_chat(src, "[chosen_modifier] has no editable params.")
		return

	var/chosen_param = input(src, "Select parameter", "Debug Modifier Params") as null|anything in editable_params
	if(!chosen_param)
		return

	var/current_value = SSday_cycle.get_modifier_param(chosen_modifier, chosen_param, 0)
	var/new_value = input(src, "Set [chosen_modifier].[chosen_param]", "Debug Modifier Params", current_value) as num|null
	if(new_value == null)
		return

	if(!SSday_cycle.set_modifier_param(chosen_modifier, chosen_param, new_value))
		to_chat(src, "Failed to set [chosen_modifier].[chosen_param].")
		return

	to_chat(src, "Set [chosen_modifier].[chosen_param] = [new_value].")

/client/proc/debug_set_weather_blend_mode()
	set name = "Debug Set Weather Blend Mode"
	set category = "Weather"

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
		for(var/client/C in GLOB.clients)
			for(var/filter_type in C.weather_screenfilters)
				var/obj/screenfilter/F = C.weather_screenfilters[filter_type]
				if(F)
					F.blend_mode = mode_val
		to_chat(src, "Set cached weather filter blend_mode to [chosen] for all clients.")

	if(target == "Ground Wetness Overlay" || target == "All")
		for(var/client/C in GLOB.clients)
			if(!C || !C.weather_wet_overlays)
				continue
			var/obj/screen/wet_overlay/W = C.weather_wet_overlays["ground"]
			if(W)
				W.blend_mode = mode_val
		to_chat(src, "Set all clients' ground wetness blend_mode to [chosen]")

	if(target == "Reflection Wetness Overlay" || target == "All")
		for(var/client/C in GLOB.clients)
			if(!C || !C.weather_wet_overlays)
				continue
			var/obj/screen/wet_overlay/W = C.weather_wet_overlays["reflection"]
			if(W)
				W.blend_mode = mode_val
		to_chat(src, "Set all clients' reflection wetness blend_mode to [chosen]")

/client/proc/debug_set_wetness()
	set name = "Debug Set Wetness"
	set category = "Weather"
	if(!SSday_cycle) return
	var/W = input(src, "Set wetness (0-255)", "Debug", SSday_cycle.wetness) as num|null
	if(W != null)
		SSday_cycle.wetness = W
		to_chat(src, "Wetness set to [W]")
