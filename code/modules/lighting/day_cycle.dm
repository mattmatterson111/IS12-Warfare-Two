GLOBAL_DATUM_INIT(day_cycle_controller, /datum/day_cycle_controller, new)


/datum/day_cycle_phase
	var/color
	var/duration
	var/output_channel

/datum/day_cycle_phase/New(color, duration, output_channel)
	src.color = color
	src.duration = duration
	src.output_channel = output_channel

/datum/day_cycle_phase/proc/on_cycle_start()
	if(output_channel)
		IO_output(output_channel, "Start", GLOB.day_cycle_controller)

/datum/day_cycle_phase/proc/on_cycle_end()
	if(output_channel)
		IO_output(output_channel, "End", GLOB.day_cycle_controller)

/datum/day_cycle_controller
	var/list/phases
	var/total_duration = 0
	var/current_phase_index = 0
	var/current_color = "#000000"
	var/datum/day_cycle_phase/current_active_phase
	
	
	var/datum/weather_type/active_weather
	var/list/weather_types = list()
	var/datum/climate/active_climate
	var/list/climates = list()
	var/list/active_weather_filters = list() 
	
	
	var/next_lightning = 0
	var/lightning_flashing = FALSE

	
	var/speed = 1
	var/current_time = 0
	var/last_process_time = 0

/datum/day_cycle_controller/New()
	..()
	phases = list(
		new /datum/day_cycle_phase("#000000", 200,      "midnight"),
		new /datum/day_cycle_phase("#110500", 100,      "dawn_start"),
		new /datum/day_cycle_phase("#9e4f1b", 200,      "sunrise"),
		new /datum/day_cycle_phase("#ddd6cc", 1000,     "noon"),
		new /datum/day_cycle_phase("#a35520", 200,      "sunset"),
		new /datum/day_cycle_phase("#110500", 100,      "dusk_end"),
	)
	
	for(var/datum/day_cycle_phase/P in phases)
		total_duration += P.duration
	
	setup_weather()
	setup_climates()
	
	last_process_time = world.time

/datum/day_cycle_controller/proc/setup_weather()
	var/datum/weather_type/W
	
	W = new /datum/weather_type/clear()
	weather_types[W.name] = W
	
	W = new /datum/weather_type/rainy()
	weather_types[W.name] = W
	
	W = new /datum/weather_type/storming()
	weather_types[W.name] = W
	
	W = new /datum/weather_type/snowing()
	weather_types[W.name] = W
	
	W = new /datum/weather_type/snowstorm()
	weather_types[W.name] = W
	
	
	active_weather = weather_types["clear"]

/datum/day_cycle_controller/proc/setup_climates()
	var/datum/climate/C
	
	C = new /datum/climate/temperate()
	climates[C.name] = C
	
	C = new /datum/climate/cold()
	climates[C.name] = C
	
	C = new /datum/climate/warm()
	climates[C.name] = C
	
	active_climate = climates["temperate"]

/datum/day_cycle_controller/proc/update_cycle()
	if(!total_duration) return

	
	var/dt = world.time - last_process_time
	last_process_time = world.time
	
	
	current_time = (current_time + dt * speed)
	
	
	if(current_time >= total_duration)
		current_time = current_time % total_duration
	if(current_time < 0) 
		current_time = total_duration + (current_time % total_duration)

	var/accumulated_time = 0
	var/found_index = 0
	var/datum/day_cycle_phase/current_phase
	var/datum/day_cycle_phase/next_phase
	var/time_into_phase = 0
	
	for(var/i = 1 to phases.len)
		var/datum/day_cycle_phase/P = phases[i]
		if(current_time < accumulated_time + P.duration)
			current_phase = P
			found_index = i
			time_into_phase = current_time - accumulated_time
			
			var/next_i = (i % phases.len) + 1
			next_phase = phases[next_i]
			break
		accumulated_time += P.duration
	
	if(current_phase)
		if(current_active_phase != current_phase)
			if(current_active_phase)
				current_active_phase.on_cycle_end()
				fire_day_event("OnPhaseEnd", current_active_phase.output_channel)
			
			current_active_phase = current_phase
			current_active_phase.on_cycle_start()
			fire_day_event("OnPhaseStart", current_active_phase.output_channel)
			fire_day_event("On[current_active_phase.output_channel]")
			current_phase_index = found_index
		
		var/fraction = time_into_phase / current_phase.duration
		var/target_color = BlendRGB(current_phase.color, next_phase.color, fraction)
		
		
		if(active_climate && active_climate.color_modifier)
			target_color = BlendRGB(target_color, active_climate.color_modifier, 0.35) 
		
		
		if(active_weather && active_weather.color_modifier)
			target_color = BlendRGB(target_color, active_weather.color_modifier, 0.75) 
			
		set_color(target_color, 10)
	
	process_weather(dt)

/datum/day_cycle_controller/proc/process_weather(dt)
	if(!active_weather) return
	
	if(active_weather.name == "storming")
		if(world.time >= next_lightning)
			strike_lightning()
			next_lightning = world.time + rand(20, 160) 

/datum/day_cycle_controller/proc/strike_lightning()
	lightning_flashing = TRUE
	var/old_color = current_color
	
	
	set_color("#FFFFFF", 0)
	sound_to(world, sound(get_sfx("rustle"), volume = 85))
	
	spawn(2)
		set_color(old_color, 3)
		if(prob(25))
			spawn(4)
				set_color("#FFFFFF", 1)
				sound_to(world, sound(get_sfx("rustle"), volume = 65))
				spawn(1)
					set_color(old_color, 2)
					lightning_flashing = FALSE
		else 
			lightning_flashing = FALSE

/datum/day_cycle_controller/proc/set_color(new_color, time = 10)
	if(lightning_flashing && new_color != "#FFFFFF") 
		current_color = new_color 
		return
		
	current_color = new_color
	for(var/obj/effect/lighting_dummy/daylight/D in GLOB.lighting_dummies)
		animate(D, color = current_color, time = time)

/datum/day_cycle_controller/proc/set_weather(weather_name)
	var/datum/weather_type/new_weather = weather_types[weather_name]
	if(!new_weather)
		new_weather = weather_types["clear"]
	
	if(new_weather == active_weather) return
	
	if(active_climate && !(new_weather.name in active_climate.allowed_weather))
		return FALSE

	if(active_weather)
		active_weather.on_end()
		fire_weather_event("OnWeatherEnd", active_weather.name)
		fade_out_filter(active_weather.screenfilter_type)
	
	active_weather = new_weather
	active_weather.on_start()
	
	fire_weather_event("OnWeatherStart", active_weather.name)
	fire_weather_event("On[capitalize(active_weather.name)]")
	fade_in_filter(active_weather.screenfilter_type)
	
	return TRUE

/datum/day_cycle_controller/proc/fade_in_filter(filter_type)
	if(!filter_type) return
	var/obj/screenfilter/F = active_weather_filters[filter_type]
	if(!F)
		F = new filter_type()
		F.plane = WEATHER_PLANE
		F.alpha = 0
		active_weather_filters[filter_type] = F
		for(var/client/C)
			C.screen += F
	
	animate(F, alpha = 255, time = 20)

/datum/day_cycle_controller/proc/fade_out_filter(filter_type)
	if(!filter_type) return
	var/obj/screenfilter/F = active_weather_filters[filter_type]
	if(!F) return
	
	animate(F, alpha = 0, time = 20)
	

/datum/day_cycle_controller/proc/fire_weather_event(output_name, param)
	for(var/obj/effect/map_entity/weather_events/E in GLOB.map_entities_by_name["weather_events"])
		E.fire_output(output_name, param, src)

/datum/day_cycle_controller/proc/fire_day_event(output_name, param)
	for(var/obj/effect/map_entity/day_events/E in GLOB.map_entities_by_name["day_events"])
		E.fire_output(output_name, param, src)


/datum/weather_type
	var/name = "clear"
	var/screenfilter_type
	var/color_modifier

/datum/weather_type/proc/on_start()
	return

/datum/weather_type/proc/on_end()
	return

/datum/weather_type/clear
	name = "clear"

/datum/weather_type/rainy
	name = "rainy"
	screenfilter_type = /obj/screenfilter/rain

/datum/weather_type/storming
	name = "storming"
	screenfilter_type = /obj/screenfilter/storm
	color_modifier = "#111122" 

/datum/weather_type/snowing
	name = "snowing"
	screenfilter_type = /obj/screenfilter/snow

/datum/weather_type/snowstorm
	name = "snowstorm"
	screenfilter_type = /obj/screenfilter/snowstorm


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
	
	if(!GLOB.day_cycle_controller)
		return
	
	var/list/phase_names = list()
	for(var/datum/day_cycle_phase/P in GLOB.day_cycle_controller.phases)
		if(P.output_channel)
			phase_names[P.output_channel] = P
		else
			phase_names["[P.color]"] = P
			
	var/chosen_name = input(src, "Select phase to jump to", "Debug Day Cycle") as null|anything in phase_names
	if(!chosen_name)
		return
		
	var/datum/day_cycle_phase/chosen_phase = phase_names[chosen_name]
	
	
	var/accumulated_time = 0
	for(var/datum/day_cycle_phase/P in GLOB.day_cycle_controller.phases)
		if(P == chosen_phase)
			break
		accumulated_time += P.duration
		
	GLOB.day_cycle_controller.current_time = accumulated_time
	GLOB.day_cycle_controller.last_process_time = world.time 
	GLOB.day_cycle_controller.update_cycle() 

/client/proc/debug_day_cycle_speed()
	set name = "Debug Day Cycle Speed"
	set category = "Debug"
	
	if(!GLOB.day_cycle_controller)
		return
		
	var/new_speed = input(src, "Set day cycle speed multiplier", "Debug Day Cycle Speed", GLOB.day_cycle_controller.speed) as num|null
	if(new_speed == null)
		return
		
	GLOB.day_cycle_controller.speed = new_speed


/client/proc/debug_set_weather()
	set name = "Debug Set Weather"
	set category = "Debug"
	
	if(!GLOB.day_cycle_controller)
		return
		
	var/chosen_weather = input(src, "Select weather", "Debug Weather") as null|anything in GLOB.day_cycle_controller.weather_types
	if(!chosen_weather)
		return
		
	if(!GLOB.day_cycle_controller.set_weather(chosen_weather))
		to_chat(src, "Failed to set weather (not allowed in current climate?)")

/client/proc/debug_set_climate()
	set name = "Debug Set Climate"
	set category = "Debug"
	
	if(!GLOB.day_cycle_controller)
		return
		
	var/chosen_climate = input(src, "Select climate", "Debug Climate") as null|anything in GLOB.day_cycle_controller.climates
	if(!chosen_climate)
		return
		
	GLOB.day_cycle_controller.active_climate = GLOB.day_cycle_controller.climates[chosen_climate]
	to_chat(src, "Climate set to [chosen_climate]")

/client/proc/debug_weather_info()
	set name = "Debug Weather Info"
	set category = "Debug"
	
	if(!GLOB.day_cycle_controller)
		return
		
	var/msg = "Current Weather: [GLOB.day_cycle_controller.active_weather ? GLOB.day_cycle_controller.active_weather.name : "None"]\n"
	msg += "Current Climate: [GLOB.day_cycle_controller.active_climate ? GLOB.day_cycle_controller.active_climate.name : "None"]\n"
	msg += "Current Color: [GLOB.day_cycle_controller.current_color]\n"
	msg += "Next Lightning: [GLOB.day_cycle_controller.next_lightning - world.time] ds\n"
	
	to_chat(src, msg)