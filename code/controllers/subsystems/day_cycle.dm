#define CHANNEL_WEATHER 1201
GLOBAL_LIST_EMPTY(auto_day_cycle_listeners)

SUBSYSTEM_DEF(day_cycle)
	name = "Day Cycle"
	wait = 1 SECONDS
	flags = SS_BACKGROUND
	runlevels = RUNLEVEL_GAME
	init_order = INIT_ORDER_DAY_CYCLE
	
	
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
	
	
	var/wetness = 0

/datum/controller/subsystem/day_cycle/Initialize()
	phases = list(
		new /datum/day_cycle_phase("#000000", 7 MINUTES,  "midnight"),
		new /datum/day_cycle_phase("#110500", 2 MINUTES,  "dawn_start"),
		new /datum/day_cycle_phase("#9e4f1b", 2 MINUTES,  "sunrise"),
		new /datum/day_cycle_phase("#a9b2c4", 7 MINUTES,  "noon"),
		new /datum/day_cycle_phase("#a35520", 2 MINUTES,  "sunset"),
		new /datum/day_cycle_phase("#110500", 2 MINUTES,  "dusk_end"),
	)
	
	for(var/datum/day_cycle_phase/P in phases)
		total_duration += P.duration
	
	setup_weather()
	setup_climates()
	
	last_process_time = world.time
	current_time = rand(0, total_duration)
	return ..()

/datum/controller/subsystem/day_cycle/fire()
	update_cycle()

/datum/controller/subsystem/day_cycle/proc/setup_weather()
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

/datum/controller/subsystem/day_cycle/proc/setup_climates()
	var/datum/climate/C
	
	C = new /datum/climate/temperate()
	climates[C.name] = C
	
	C = new /datum/climate/cold()
	climates[C.name] = C
	
	C = new /datum/climate/warm()
	climates[C.name] = C
	
	active_climate = climates["temperate"]

/datum/controller/subsystem/day_cycle/proc/update_cycle()
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

			for(var/O in GLOB.auto_day_cycle_listeners)
				var/atom/A = O
				A.on_day_phase_change(current_active_phase.output_channel)

			current_phase_index = found_index
		
		var/fraction = time_into_phase / current_phase.duration
		var/target_color = BlendRGB(current_phase.color, next_phase.color, fraction)
		
		if(!current_phase.ignore_color_modifiers)
			if(active_climate && active_climate.color_modifier)
				target_color = BlendRGB(target_color, active_climate.color_modifier, 0.35) 
			
			if(active_weather && active_weather.color_modifier)
				target_color = BlendRGB(target_color, active_weather.color_modifier, 0.75) 

		
		if(current_phase.output_channel == "midnight")
			if(active_weather?.name == "storming" || active_weather?.name == "snowstorm")
				target_color = "#000000"
			
		set_color(target_color, 10)
	
	process_weather(dt)
	update_weather_audio()

/datum/controller/subsystem/day_cycle/proc/update_weather_audio()
	var/sound_file = active_weather?.looping_sound
	
	for(var/P in GLOB.player_list)
		var/mob/M = P
		var/client/C = M.client
		if(!C)
			continue
			
		if(!sound_file)
			if(C.last_weather_sound)
				sound_to(C, sound(null, channel = CHANNEL_WEATHER))
				C.last_weather_sound = null
			continue
			
		var/turf/T = get_turf(M)
		if(!T)
			continue
			
		var/exposed = (locate(/obj/effect/map_entity/weather_mask) in T) && !(locate(/obj/effect/map_entity/environment_blocker) in T)
		var/target_volume = active_weather.looping_volume
		var/target_env = -1
		var/active_sound = sound_file

		if(!exposed)
			target_volume *= 0.6
			target_env = 1
			if(active_weather.indoor_looping_sound)
				active_sound = active_weather.indoor_looping_sound
			
		if(C.last_weather_sound != active_sound)
			var/sound/S = sound(active_sound)
			S.channel = CHANNEL_WEATHER
			S.repeat = 1
			S.wait = 0
			S.volume = target_volume
			S.environment = target_env
			sound_to(C, S)
			C.last_weather_sound = active_sound
			C.last_weather_volume = target_volume
			C.last_weather_precooked_env = target_env
		else if(C.last_weather_volume != target_volume || C.last_weather_precooked_env != target_env)
			var/sound/S = sound(active_sound)
			S.channel = CHANNEL_WEATHER
			S.status = SOUND_UPDATE
			S.volume = target_volume
			S.environment = target_env
			S.repeat = 1
			sound_to(C, S)
			C.last_weather_volume = target_volume
			C.last_weather_precooked_env = target_env

/datum/controller/subsystem/day_cycle/proc/process_weather(dt)
	if(!active_weather) return
	
	if(active_weather.name == "storming")
		if(world.time >= next_lightning)
			strike_lightning()
			next_lightning = world.time + rand(20, 160) 
	
	var/target_wetness = 0
	if(active_weather?.name in list("storming", "rainy"))
		target_wetness = 200
	else if(active_weather?.name in list("snowing", "snowstorm"))
		target_wetness = 100
	
	if(wetness < target_wetness)
		wetness = min(wetness + dt * 0.1, target_wetness)
	else if(wetness > target_wetness)
		wetness = max(wetness - dt * 0.05, target_wetness)
	
	for(var/client/C in GLOB.clients)
		if(C.mob?.wet_overlay)
			C.mob.wet_overlay.alpha = wetness/3
		if(C.mob?.reflection_wet_overlay)
			C.mob.reflection_wet_overlay.alpha = wetness/2

/datum/controller/subsystem/day_cycle/proc/strike_lightning()
	lightning_flashing = TRUE

	var/is_close = prob(25)
	var/close_sound = pick('sound/weather/storm_close1.ogg', 'sound/weather/storm_close2.ogg', 'sound/weather/stormclose_3.ogg', 'sound/weather/stormclose_4.ogg')
	var/distant_sound = pick('sound/weather/storm_distant1.ogg', 'sound/weather/storm_distant2.ogg', 'sound/weather/storm_distant3.ogg')
	var/base_vol = rand(45, 100)

	for(var/P in GLOB.player_list)
		var/mob/M = P
		var/client/C = M.client
		if(!C) continue
		
		var/turf/T = get_turf(M)
		var/exposed = T && (locate(/obj/effect/map_entity/weather_mask) in T) && !(locate(/obj/effect/map_entity/environment_blocker) in T)
		
		var/sound_file = (is_close && exposed) ? close_sound : distant_sound
		var/sound/S = sound(sound_file)
		S.volume = base_vol
		S.environment = -1
		
		if(!exposed)
			S.volume *=0.5
			S.environment = 1
			
		sound_to(C, S)

	if(is_close)
		var/old_color = current_color
		set_color("#FFFFFF", 0)
		spawn(2)
			set_color(old_color, 3)
			lightning_flashing = FALSE
	else
		lightning_flashing = FALSE
		
/datum/controller/subsystem/day_cycle/proc/set_color(new_color, time = 10)
	if(lightning_flashing && new_color != "#FFFFFF") 
		current_color = new_color 
		return
		
	current_color = new_color
	for(var/obj/effect/lighting_dummy/daylight/D in GLOB.lighting_dummies)
		animate(D, color = current_color, time = time)

/datum/controller/subsystem/day_cycle/proc/set_weather(weather_name)
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
	update_weather_audio()
	
	for(var/O in GLOB.auto_day_cycle_listeners)
		var/atom/A = O
		A.on_day_phase_change(SSday_cycle.current_active_phase?.output_channel)

	return TRUE

/datum/controller/subsystem/day_cycle/proc/fade_in_filter(filter_type)
	if(!filter_type) return
	var/obj/screenfilter/F = active_weather_filters[filter_type]
	if(!F)
		F = new filter_type()
		F.plane = WEATHER_PLANE
		F.alpha = 0
		active_weather_filters[filter_type] = F
		for(var/client/C in GLOB.clients)
			C.screen += F
	
	animate(F, alpha = 255, time = 20)

/datum/controller/subsystem/day_cycle/proc/fade_out_filter(filter_type)
	if(!filter_type) return
	var/obj/screenfilter/F = active_weather_filters[filter_type]
	if(!F) return
	
	animate(F, alpha = 0, time = 20)
	

/datum/controller/subsystem/day_cycle/proc/fire_weather_event(output_name, param)
	for(var/obj/effect/map_entity/weather_events/E in GLOB.map_entities_by_name["weather_events"])
		E.fire_output(output_name, param, src)

/datum/controller/subsystem/day_cycle/proc/fire_day_event(output_name, param)
	for(var/obj/effect/map_entity/day_events/E in GLOB.map_entities_by_name["day_events"])
		E.fire_output(output_name, param, src)

/atom/proc/on_day_phase_change(phase_name)
	return
