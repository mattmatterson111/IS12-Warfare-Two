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
	var/list/modifier_types = list()
	var/list/active_modifiers = list()
	var/list/modifier_params = list()
	var/datum/climate/active_climate
	var/list/climates = list()
	var/list/active_weather_filter_types = list()
	var/wet_overlays_active = FALSE
	var/weather_misc_visibility = 0
	
	
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
	setup_modifiers()
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

/datum/controller/subsystem/day_cycle/proc/setup_modifiers()
	var/datum/weather_modifier/M

	modifier_types = list()
	active_modifiers = list()
	modifier_params = list()

	M = new /datum/weather_modifier/generic_placeholder()
	modifier_types[M.name] = M

	M = new /datum/weather_modifier/foggy()
	modifier_types[M.name] = M
	modifier_params[M.name] = list(
		"blur_size" = 20,
		"fog_scale" = 1.5,
		"fog_alpha" = 115
	)

	M = new /datum/weather_modifier/weather_misc()
	modifier_types[M.name] = M
	modifier_params[M.name] = list(
		"base_alpha" = 40
	)

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
				var/midnight_darkening = 1 - abs((fraction * 2) - 1)
				target_color = BlendRGB(target_color, "#000000", 0.9 * midnight_darkening)
			
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

	ensure_weather_filters_attached()
	sync_weather_driven_modifiers()
	update_weather_misc_visibility(dt)
	
	if(active_weather.name == "storming")
		if(world.time >= next_lightning)
			strike_lightning()
			next_lightning = world.time + rand(20, 160) 
	
	var/target_wetness = 0
	if(active_weather?.name in list("storming", "rainy"))
		target_wetness = 200
	else if(active_weather?.name == "snowstorm")
		target_wetness = 90
	else if(active_weather?.name == "snowing")
		target_wetness = 80
	
	if(wetness < target_wetness)
		var/wetness_rise_rate = 0.1
		if(active_weather?.name in list("snowing", "snowstorm"))
			wetness_rise_rate = 0.03
		wetness = min(wetness + dt * wetness_rise_rate, target_wetness)
	else if(wetness > target_wetness)
		wetness = max(wetness - dt * 0.05, target_wetness)

	var/ground_icon_state = active_weather.wet_ground_icon_state
	var/reflection_icon_state = active_weather.wet_reflection_icon_state
	var/wet_ground_alpha_cap = null
	var/wet_reflection_alpha_cap = null
	if(active_weather?.name in list("snowing", "snowstorm"))
		ground_icon_state = "whiteFull"
		reflection_icon_state = "whiteFull"
		wet_ground_alpha_cap = 20
		wet_reflection_alpha_cap = 35
	if(!ground_icon_state)
		ground_icon_state = "raintest"
	if(!reflection_icon_state)
		reflection_icon_state = "raintest"

	if(wetness > 0)
		if(!wet_overlays_active)
			wet_overlays_active = TRUE
		for(var/client/C in GLOB.clients)
			var/obj/screen/wet_overlay/ground/G = get_client_wet_overlay(C, "ground")
			var/obj/screen/wet_overlay/reflection/R = get_client_wet_overlay(C, "reflection")
			if(!G || !R)
				continue

			G.icon_state = ground_icon_state
			R.icon_state = reflection_icon_state
			G.alpha = wetness/3
			R.alpha = wetness/2
			if(wet_ground_alpha_cap != null)
				G.alpha = min(G.alpha, wet_ground_alpha_cap)
			if(wet_reflection_alpha_cap != null)
				R.alpha = min(R.alpha, wet_reflection_alpha_cap)

			C.screen += G
			C.screen += R
	else if(wet_overlays_active)
		wet_overlays_active = FALSE
		for(var/client/C in GLOB.clients)
			if(!C || !C.weather_wet_overlays)
				continue

			var/obj/screen/wet_overlay/ground/G = C.weather_wet_overlays["ground"]
			var/obj/screen/wet_overlay/reflection/R = C.weather_wet_overlays["reflection"]

			if(G)
				animate(G, alpha = 0, time = 20, easing = SINE_EASING)
			if(R)
				animate(R, alpha = 0, time = 20, easing = SINE_EASING)

			spawn(20)
				if(!C)
					return
				if(wet_overlays_active)
					return
				if(G)
					C.screen -= G
				if(R)
					C.screen -= R

	if(has_modifier("weather_misc"))
		apply_weather_misc_alpha()

/datum/controller/subsystem/day_cycle/proc/ensure_weather_filters_attached()
	if(!active_weather_filter_types || !active_weather_filter_types.len)
		return

	for(var/client/C in GLOB.clients)
		if(!C)
			continue
		for(var/filter_type in active_weather_filter_types)
			var/obj/screenfilter/F = get_client_weather_filter(C, filter_type)
			if(!F)
				continue
			if(!(F in C.screen))
				C.screen += F
			if(F.alpha <= 0)
				F.alpha = 255

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

/datum/controller/subsystem/day_cycle/proc/sync_weather_driven_modifiers()
	if(active_weather?.name in list("snowing", "snowstorm"))
		add_modifier("weather_misc")
	else if(weather_misc_visibility <= 0)
		remove_modifier("weather_misc")

	if(active_weather?.name == "snowstorm")
		add_modifier("foggy")

/datum/controller/subsystem/day_cycle/proc/apply_weather_driven_fog_profile()
	if(active_weather?.name == "snowstorm")
		set_modifier_param_if_changed("foggy", "fog_alpha", 170)
		set_modifier_param_if_changed("foggy", "blur_size", 38)
		set_modifier_param_if_changed("foggy", "fog_scale", 2)
		return

	if(active_weather?.name == "snowing")
		set_modifier_param_if_changed("foggy", "fog_alpha", 75)
		set_modifier_param_if_changed("foggy", "blur_size", 38)
		set_modifier_param_if_changed("foggy", "fog_scale", 2)
		return

	set_modifier_param_if_changed("foggy", "fog_alpha", 115)
	set_modifier_param_if_changed("foggy", "blur_size", 20)
	set_modifier_param_if_changed("foggy", "fog_scale", 1.5)

/datum/controller/subsystem/day_cycle/proc/set_modifier_param_if_changed(modifier_name, param_name, value)
	var/current = get_modifier_param(modifier_name, param_name, null)
	if(isnum(current) && isnum(value))
		if(abs(current - value) < 0.0001)
			return TRUE
	else if("[current]" == "[value]")
		return TRUE
	return set_modifier_param(modifier_name, param_name, value)

/datum/controller/subsystem/day_cycle/proc/update_weather_misc_visibility(dt)
	if(dt <= 0)
		return

	var/base_alpha = get_modifier_param("weather_misc", "base_alpha", 40)
	if(isnull(base_alpha))
		base_alpha = 40
	base_alpha = min(max(base_alpha, 0), 255)

	var/target_visibility = 0
	var/ramp_rate = 255 / (5 MINUTES)

	if(active_weather?.name == "snowstorm")
		target_visibility = max(base_alpha, 150)
		ramp_rate = 150 / (3 MINUTES)
	else if(active_weather?.name == "snowing")
		target_visibility = max(base_alpha, 100)
		ramp_rate = 100 / (5 MINUTES)

	if(weather_misc_visibility < target_visibility)
		weather_misc_visibility = min(target_visibility, weather_misc_visibility + (dt * ramp_rate))
	else if(weather_misc_visibility > target_visibility)
		weather_misc_visibility = max(target_visibility, weather_misc_visibility - (dt * ramp_rate))
		
/datum/controller/subsystem/day_cycle/proc/set_color(new_color, time = 10)
	if(lightning_flashing && new_color != "#FFFFFF") 
		current_color = new_color 
		return
		
	current_color = new_color
	for(var/obj/effect/lighting_dummy/daylight/D in GLOB.lighting_dummies)
		animate(D, color = current_color, time = time, easing = SINE_EASING)

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
	apply_weather_driven_fog_profile()
	active_weather.on_start()
	
	fire_weather_event("OnWeatherStart", active_weather.name)
	fire_weather_event("On[capitalize(active_weather.name)]")
	fade_in_filter(active_weather.screenfilter_type)
	update_weather_audio()
	
	for(var/O in GLOB.auto_day_cycle_listeners)
		var/atom/A = O
		A.on_day_phase_change(SSday_cycle.current_active_phase?.output_channel)

	return TRUE

/datum/controller/subsystem/day_cycle/proc/set_day_cycle_phase(phase_name)
	if(!phase_name || !phases || !phases.len)
		return FALSE

	var/accumulated_time = 0
	for(var/datum/day_cycle_phase/P in phases)
		var/matches_name = (P.output_channel && P.output_channel == phase_name)
		var/matches_color = ("[P.color]" == "[phase_name]")
		if(matches_name || matches_color)
			current_time = accumulated_time
			last_process_time = world.time
			update_cycle()
			return TRUE
		accumulated_time += P.duration

	return FALSE

/datum/controller/subsystem/day_cycle/proc/has_modifier(modifier_name)
	if(!modifier_name)
		return FALSE
	return !!active_modifiers[modifier_name]

/datum/controller/subsystem/day_cycle/proc/add_modifier(modifier_name)
	if(!modifier_name)
		return FALSE

	var/datum/weather_modifier/new_modifier = modifier_types[modifier_name]
	var/output_safe_modifier = replacetext(lowertext("[modifier_name]"), " ", "_")
	if(!new_modifier)
		return FALSE

	if(has_modifier(modifier_name))
		return TRUE

	active_modifiers[modifier_name] = new_modifier
	new_modifier.on_start()
	apply_modifier_visuals_start(modifier_name)

	fire_weather_event("OnModifierStart", modifier_name)
	fire_weather_event("OnModifierAdded", modifier_name)
	fire_weather_event("OnModifierAdded_[output_safe_modifier]")

	return TRUE

/datum/controller/subsystem/day_cycle/proc/remove_modifier(modifier_name)
	if(!modifier_name)
		return FALSE

	var/datum/weather_modifier/active_modifier = active_modifiers[modifier_name]
	var/output_safe_modifier = replacetext(lowertext("[modifier_name]"), " ", "_")
	if(!active_modifier)
		return FALSE

	active_modifiers -= modifier_name
	active_modifier.on_end()
	apply_modifier_visuals_end(modifier_name)

	fire_weather_event("OnModifierEnd", modifier_name)
	fire_weather_event("OnModifierRemoved", modifier_name)
	fire_weather_event("OnModifierRemoved_[output_safe_modifier]")

	return TRUE

/datum/controller/subsystem/day_cycle/proc/toggle_modifier(modifier_name)
	if(has_modifier(modifier_name))
		return remove_modifier(modifier_name)
	return add_modifier(modifier_name)

/datum/controller/subsystem/day_cycle/proc/clear_modifiers()
	if(!active_modifiers || !active_modifiers.len)
		return

	var/list/removed_modifiers = active_modifiers.Copy()
	for(var/modifier_name in removed_modifiers)
		remove_modifier(modifier_name)

	fire_weather_event("OnModifierEnd", "all")
	fire_weather_event("OnModifierRemoved", "all")

/datum/controller/subsystem/day_cycle/proc/get_modifier_type_names()
	var/list/names = list()
	for(var/modifier_name in modifier_types)
		names += modifier_name
	return names

/datum/controller/subsystem/day_cycle/proc/get_active_modifier_names()
	var/list/names = list()
	for(var/modifier_name in active_modifiers)
		names += modifier_name
	return names

/datum/controller/subsystem/day_cycle/proc/get_modifier_params(modifier_name)
	if(!modifier_name)
		return null
	var/list/params = modifier_params[modifier_name]
	if(!params)
		params = list()
		modifier_params[modifier_name] = params
	return params

/datum/controller/subsystem/day_cycle/proc/get_modifier_param(modifier_name, param_name, default_value = null)
	if(!modifier_name || !param_name)
		return default_value
	var/list/params = get_modifier_params(modifier_name)
	if(!params)
		return default_value
	if(!(param_name in params))
		return default_value
	return params[param_name]

/datum/controller/subsystem/day_cycle/proc/get_editable_modifier_param_names(modifier_name)
	var/list/names = list()
	if(!modifier_name)
		return names
	switch(modifier_name)
		if("foggy")
			names += "blur_size"
			names += "fog_scale"
			names += "fog_alpha"
		if("weather_misc")
			names += "base_alpha"
	return names

/datum/controller/subsystem/day_cycle/proc/set_modifier_param(modifier_name, param_name, value)
	if(!modifier_name || !param_name)
		return FALSE
	if(!(modifier_name in modifier_types))
		return FALSE

	var/list/params = get_modifier_params(modifier_name)
	if(!params)
		return FALSE

	switch(modifier_name)
		if("foggy")
			if(param_name == "blur_size")
				var/num_value = text2num("[value]")
				if(isnull(num_value))
					return FALSE
				num_value = min(max(num_value, 0), 64)
				params[param_name] = num_value
				apply_foggy_modifier_params()
				return TRUE
			if(param_name == "fog_scale")
				var/num_value = text2num("[value]")
				if(isnull(num_value))
					return FALSE
				num_value = min(max(num_value, 0.1), 4)
				params[param_name] = num_value
				apply_foggy_modifier_params()
				return TRUE
			if(param_name == "fog_alpha")
				var/num_value = text2num("[value]")
				if(isnull(num_value))
					return FALSE
				num_value = min(max(num_value, 0), 255)
				params[param_name] = num_value
				apply_fog_overlay_alpha()
				return TRUE
		if("weather_misc")
			if(param_name == "base_alpha")
				var/num_value = text2num("[value]")
				if(isnull(num_value))
					return FALSE
				num_value = min(max(num_value, 0), 255)
				params[param_name] = num_value
				weather_misc_visibility = num_value
				apply_weather_misc_alpha(null, FALSE)
				return TRUE

	return FALSE

/datum/controller/subsystem/day_cycle/proc/fade_in_filter(filter_type)
	if(!filter_type) return
	if(!(filter_type in active_weather_filter_types))
		active_weather_filter_types += filter_type

	for(var/client/C in GLOB.clients)
		var/obj/screenfilter/F = get_client_weather_filter(C, filter_type)
		if(!F)
			continue
		C.screen += F
		animate(F, alpha = 255, time = 20, easing = SINE_EASING)

/datum/controller/subsystem/day_cycle/proc/fade_out_filter(filter_type)
	if(!filter_type) return
	active_weather_filter_types -= filter_type

	for(var/client/C in GLOB.clients)
		if(!C || !C.weather_screenfilters)
			continue

		var/obj/screenfilter/F = C.weather_screenfilters[filter_type]
		if(!F)
			continue

		animate(F, alpha = 0, time = 20, easing = SINE_EASING)
		spawn(20)
			if(!C)
				return
			if(filter_type in active_weather_filter_types)
				return
			C.screen -= F
	

/datum/controller/subsystem/day_cycle/proc/fire_weather_event(output_name, param)
	for(var/obj/effect/map_entity/weather_events/E in GLOB.map_entities_by_name["weather_events"])
		E.fire_output(output_name, param, src)

/datum/controller/subsystem/day_cycle/proc/fire_day_event(output_name, param)
	for(var/obj/effect/map_entity/day_events/E in GLOB.map_entities_by_name["day_events"])
		E.fire_output(output_name, param, src)

/datum/controller/subsystem/day_cycle/proc/on_client_login(client/C)
	for(var/filter_type in active_weather_filter_types)
		var/obj/screenfilter/F = get_client_weather_filter(C, filter_type)
		if(!F)
			continue
		F.alpha = 255
		C.screen += F

	if(wet_overlays_active && C)
		var/ground_icon_state = active_weather?.wet_ground_icon_state || "raintest"
		var/reflection_icon_state = active_weather?.wet_reflection_icon_state || "raintest"
		var/wet_ground_alpha_cap = null
		var/wet_reflection_alpha_cap = null
		if(active_weather?.name in list("snowing", "snowstorm"))
			ground_icon_state = "whiteFull"
			reflection_icon_state = "whiteFull"
			wet_ground_alpha_cap = 20
			wet_reflection_alpha_cap = 35

		var/obj/screen/wet_overlay/ground/G = get_client_wet_overlay(C, "ground")
		var/obj/screen/wet_overlay/reflection/R = get_client_wet_overlay(C, "reflection")
		if(G && R)
			G.icon_state = ground_icon_state
			R.icon_state = reflection_icon_state
			G.alpha = wetness/3
			R.alpha = wetness/2
			if(wet_ground_alpha_cap != null)
				G.alpha = min(G.alpha, wet_ground_alpha_cap)
			if(wet_reflection_alpha_cap != null)
				R.alpha = min(R.alpha, wet_reflection_alpha_cap)
			C.screen += G
			C.screen += R

	for(var/modifier_name in active_modifiers)
		apply_modifier_visuals_start(modifier_name, C, FALSE)

/datum/controller/subsystem/day_cycle/proc/get_client_weather_filter(client/C, filter_type)
	if(!C || !filter_type)
		return null

	if(!C.weather_screenfilters)
		C.weather_screenfilters = list()

	var/obj/screenfilter/F = C.weather_screenfilters[filter_type]
	if(!F)
		F = new filter_type()
		F.plane = WEATHER_PLANE
		F.alpha = 0
		C.weather_screenfilters[filter_type] = F

	return F

/datum/controller/subsystem/day_cycle/proc/get_client_wet_overlay(client/C, overlay_key)
	if(!C || !overlay_key)
		return null

	if(!C.weather_wet_overlays)
		C.weather_wet_overlays = list()

	var/obj/screen/wet_overlay/W = C.weather_wet_overlays[overlay_key]
	if(W)
		return W

	switch(overlay_key)
		if("ground")
			W = new /obj/screen/wet_overlay/ground
		if("reflection")
			W = new /obj/screen/wet_overlay/reflection
		else
			return null

	W.alpha = 0
	C.weather_wet_overlays[overlay_key] = W
	return W

/datum/controller/subsystem/day_cycle/proc/get_client_modifier_overlay(client/C, overlay_key, icon_file, icon_state, overlay_plane)
	if(!C || !overlay_key || !icon_file || !icon_state)
		return null

	if(!C.weather_modifier_overlays)
		C.weather_modifier_overlays = list()

	var/image/O = C.weather_modifier_overlays[overlay_key]
	if(O)
		O.loc = C.mob
		return O

	O = image(icon = icon_file, loc = C.mob, icon_state = icon_state)
	O.alpha = 0
	O.plane = overlay_plane
	O.mouse_opacity = 0
	O.appearance_flags = RESET_COLOR|RESET_ALPHA|RESET_TRANSFORM|NO_CLIENT_COLOR
	O.layer = 20
	C.weather_modifier_overlays[overlay_key] = O
	return O

/datum/controller/subsystem/day_cycle/proc/get_client_modifier_screen_overlay(client/C, overlay_key, overlay_type)
	if(!C || !overlay_key || !overlay_type)
		return null

	if(!C.weather_modifier_overlays)
		C.weather_modifier_overlays = list()

	var/obj/screen/O = C.weather_modifier_overlays[overlay_key]
	if(O)
		return O

	O = new overlay_type()
	O.alpha = 0
	C.weather_modifier_overlays[overlay_key] = O
	return O

/datum/controller/subsystem/day_cycle/proc/get_client_fog_cutout_plane_master(client/C)
	if(!C)
		return null
	for(var/obj/screen/plane_master/fog_cutout/PM in C.screen)
		return PM
	return null

/datum/controller/subsystem/day_cycle/proc/get_client_weather_misc_planes(client/C)
	if(!C)
		return list()

	var/list/planes = list()
	for(var/obj/screen/plane_master/PM in C.screen)
		if(
			istype(PM, /obj/screen/plane_master/weather_misc) \
			|| istype(PM, /obj/screen/plane_master/weather_misc_obj) \
			|| istype(PM, /obj/screen/plane_master/weather_misc_above_obj) \
			|| istype(PM, /obj/screen/plane_master/weather_misc_above_human)
		)
			planes += PM

	return planes

/datum/controller/subsystem/day_cycle/proc/get_client_fog_overlay(client/C)
	if(!C || !C.weather_modifier_overlays)
		return null
	return C.weather_modifier_overlays["foggy_overlay"]

/datum/controller/subsystem/day_cycle/proc/get_client_fog_cutout_overlay(client/C)
	if(!C || !C.weather_modifier_overlays)
		return null
	return C.weather_modifier_overlays["foggy_cutout"]

/datum/controller/subsystem/day_cycle/proc/get_or_create_fog_cutout_blur_filter(obj/screen/plane_master/fog_cutout/PM)
	if(!PM)
		return null

	if(!PM.filters || !PM.filters.len)
		PM.filters = list(filter(type = "blur", size = 1))
		return PM.filters[1]

	// Keep a single blur filter on this plane master so runtime blur changes animate predictably.
	if(PM.filters.len > 1)
		PM.filters = list(PM.filters[1])

	return PM.filters[1]

/datum/controller/subsystem/day_cycle/proc/get_weather_misc_target_alpha()
	if(!has_modifier("weather_misc"))
		return 0
	return round(min(max(weather_misc_visibility, 0), 255))

/datum/controller/subsystem/day_cycle/proc/apply_weather_misc_alpha(client/target_client = null, use_animation = FALSE, anim_time = 20)
	var/target_alpha = get_weather_misc_target_alpha()

	if(target_client)
		for(var/obj/screen/plane_master/PM in get_client_weather_misc_planes(target_client))
			if(use_animation)
				animate(PM, alpha = target_alpha, time = anim_time, easing = SINE_EASING)
			else
				PM.alpha = target_alpha
		return

	for(var/client/C in GLOB.clients)
		for(var/obj/screen/plane_master/PM in get_client_weather_misc_planes(C))
			if(use_animation)
				animate(PM, alpha = target_alpha, time = anim_time, easing = SINE_EASING)
			else
				PM.alpha = target_alpha

/datum/controller/subsystem/day_cycle/proc/apply_foggy_modifier_params(client/target_client = null)
	apply_fog_cutout_blur(target_client)
	apply_fog_cutout_scale(target_client)

/datum/controller/subsystem/day_cycle/proc/apply_fog_overlay_alpha(client/target_client = null, time = 20)
	var/fog_alpha = get_modifier_param("foggy", "fog_alpha", 25)
	if(isnull(fog_alpha))
		fog_alpha = 25
	fog_alpha = min(max(fog_alpha, 0), 255)

	if(target_client)
		var/obj/screen/weather_modifier/foggy/F = get_client_fog_overlay(target_client)
		if(F)
			animate(F, alpha = fog_alpha, time = time, easing = SINE_EASING)
		return

	for(var/client/C in GLOB.clients)
		var/obj/screen/weather_modifier/foggy/F = get_client_fog_overlay(C)
		if(!F)
			continue
		animate(F, alpha = fog_alpha, time = time, easing = SINE_EASING)

/datum/controller/subsystem/day_cycle/proc/apply_fog_cutout_blur(client/target_client = null)
	var/blur_size = get_modifier_param("foggy", "blur_size", 1)
	if(isnull(blur_size))
		blur_size = 1
	blur_size = max(0, blur_size)
	var/anim_time = 10 SECONDS

	if(target_client)
		var/obj/screen/plane_master/fog_cutout/PM = get_client_fog_cutout_plane_master(target_client)
		if(PM)
			var/blur_filter = get_or_create_fog_cutout_blur_filter(PM)
			if(blur_filter)
				animate(blur_filter, size = blur_size, time = anim_time, easing = SINE_EASING)
		return

	for(var/client/C in GLOB.clients)
		var/obj/screen/plane_master/fog_cutout/PM = get_client_fog_cutout_plane_master(C)
		if(!PM)
			continue
		var/blur_filter = get_or_create_fog_cutout_blur_filter(PM)
		if(blur_filter)
			animate(blur_filter, size = blur_size, time = anim_time, easing = SINE_EASING)

/datum/controller/subsystem/day_cycle/proc/apply_fog_cutout_scale(client/target_client = null)
	var/fog_scale = get_modifier_param("foggy", "fog_scale", 1)
	if(isnull(fog_scale))
		fog_scale = 1
	fog_scale = min(max(fog_scale, 0.1), 4)

	var/matrix/target_transform = matrix()
	target_transform.Scale(fog_scale, fog_scale)
	var/anim_time = 10 SECONDS

	if(target_client)
		var/image/FC = get_client_fog_cutout_overlay(target_client)
		if(FC)
			animate(FC, transform = target_transform, time = anim_time, flags = ANIMATION_PARALLEL, easing = SINE_EASING)
		return

	for(var/client/C in GLOB.clients)
		var/image/FC = get_client_fog_cutout_overlay(C)
		if(!FC)
			continue
		animate(FC, transform = target_transform, time = anim_time, flags = ANIMATION_PARALLEL, easing = SINE_EASING)

/datum/controller/subsystem/day_cycle/proc/apply_modifier_visuals_start(modifier_name, client/target_client = null, play_intro = TRUE)
	if(modifier_name == "weather_misc")
		apply_weather_misc_alpha(target_client, FALSE)
		return

	if(modifier_name != "foggy")
		return

	var/list/clients_to_update = list()
	if(target_client)
		clients_to_update += target_client
	else
		for(var/client/C in GLOB.clients)
			clients_to_update += C

	for(var/client/C in clients_to_update)
		if(!C || !C.mob)
			continue

		var/obj/screen/weather_modifier/foggy/F = get_client_modifier_screen_overlay(C, "foggy_overlay", /obj/screen/weather_modifier/foggy)
		var/image/FC = get_client_modifier_overlay(C, "foggy_cutout", 'icons/mob/evil96.dmi', "fog_cutout", FOG_CUTOUT_PLANE)
		if(!F || !FC)
			continue

		FC.loc = C.mob
		FC.pixel_x = -32
		FC.pixel_y = -32
		C.images -= FC
		C.screen -= F
		C.images += FC
		C.screen += F

		if(play_intro)
			var/matrix/cutout_start_transform = matrix()
			cutout_start_transform.Scale(10, 10)
			var/matrix/cutout_end_transform = matrix()
			cutout_end_transform.Scale(1, 1)
			FC.transform = cutout_start_transform
			FC.alpha = 255
			animate(FC, transform = cutout_end_transform, time = 45 SECONDS, flags = ANIMATION_PARALLEL, easing = SINE_EASING)

			F.alpha = 0
			apply_fog_overlay_alpha(C, 45 SECONDS)
			apply_foggy_modifier_params(C)
		else
			var/fog_scale = get_modifier_param("foggy", "fog_scale", 1)
			if(isnull(fog_scale))
				fog_scale = 1
			fog_scale = min(max(fog_scale, 0.1), 4)

			var/fog_alpha = get_modifier_param("foggy", "fog_alpha", 25)
			if(isnull(fog_alpha))
				fog_alpha = 25
			fog_alpha = min(max(fog_alpha, 0), 255)

			var/blur_size = get_modifier_param("foggy", "blur_size", 1)
			if(isnull(blur_size))
				blur_size = 1
			blur_size = max(0, blur_size)

			var/matrix/cutout_transform = matrix()
			cutout_transform.Scale(fog_scale, fog_scale)
			FC.transform = cutout_transform
			FC.alpha = 255
			F.alpha = fog_alpha

			var/obj/screen/plane_master/fog_cutout/PM = get_client_fog_cutout_plane_master(C)
			if(PM)
				var/blur_filter = get_or_create_fog_cutout_blur_filter(PM)
				if(blur_filter)
					animate(blur_filter, size = blur_size, time = 0)

/datum/controller/subsystem/day_cycle/proc/apply_modifier_visuals_end(modifier_name)
	if(modifier_name == "weather_misc")
		apply_weather_misc_alpha(null, TRUE, 20)
		return

	if(modifier_name != "foggy")
		return

	for(var/client/C in GLOB.clients)
		if(!C || !C.weather_modifier_overlays)
			continue

		var/obj/screen/weather_modifier/foggy/F = C.weather_modifier_overlays["foggy_overlay"]
		var/image/FC = C.weather_modifier_overlays["foggy_cutout"]
		if(F)
			animate(F, alpha = 0, time = 20, easing = SINE_EASING)
		if(FC)
			animate(FC, alpha = 0, time = 20, easing = SINE_EASING)

		spawn(20)
			if(!C)
				return
			if(has_modifier("foggy"))
				return
			if(F)
				C.screen -= F
			if(FC)
				C.images -= FC

/atom/proc/on_day_phase_change(phase_name)
	return
