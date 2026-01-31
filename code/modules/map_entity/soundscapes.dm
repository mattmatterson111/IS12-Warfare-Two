



GLOBAL_LIST_EMPTY(player_active_soundscape)  

/decl/soundscape
	var/name = "unnamed"
	var/dsp = 1
	var/dsp_volume = 1.0
	var/fadetime = 1.0
	var/list/playlooping = list()
	var/list/playrandom = list()
	var/list/playsoundscape = list()

/proc/get_soundscape(soundscape_name)
	if(!soundscape_name)
		return null
	var/list/all_soundscapes = decls_repository.get_decls_of_subtype(/decl/soundscape)
	for(var/type in all_soundscapes)
		var/decl/soundscape/S = all_soundscapes[type]
		if(lowertext(S.name) == lowertext(soundscape_name))
			return S
	return null

/proc/get_soundscape_by_type(soundscape_type)
	if(!soundscape_type)
		return null
	return decls_repository.get_decl(soundscape_type)


GLOBAL_VAR_INIT(soundscape_channel_counter, 200)

/obj/effect/map_entity/env_soundscape
	name = "env_soundscape"
	icon_state = "sound"

	
	var/mode = "radius"
	var/soundscape = ""
	var/radius = 7
	var/check_lds = FALSE  
	var/volume_multiplier = 1.0  

	var/position_0 = ""
	var/position_1 = ""
	var/position_2 = ""
	var/position_3 = ""
	var/position_4 = ""
	var/position_5 = ""
	var/position_6 = ""
	var/position_7 = ""

	var/list/position_atoms
	var/channel_base = 0
	var/list/player_data  



/obj/effect/map_entity/env_soundscape/Initialize()
	. = ..()
	channel_base = GLOB.soundscape_channel_counter
	GLOB.soundscape_channel_counter += 10
	
	if(mode == "brush")
		is_brush = TRUE
	else
		
		START_PROCESSING(SSobj, src)



/obj/effect/map_entity/env_soundscape/Destroy()
	STOP_PROCESSING(SSobj, src)
	if(player_data)
		for(var/mob/M in player_data)
			stop_for_player(M, stop_random = FALSE)
	return ..()

/obj/effect/map_entity/env_soundscape/Process()
	if(!enabled)
		return

	if(!position_atoms)
		cache_position_atoms()

	var/list/players_in_range = list()

	for(var/mob/living/M in range(radius, src))
		if(!M.client)
			continue

		
		if(check_lds && !can_see_soundscape(M))
			continue

		players_in_range += M

		
		if(player_data?[M])
			continue

		
		var/obj/effect/map_entity/env_soundscape/current = GLOB.player_active_soundscape[M.client]
		if(current)
			
			if(get_dist(M, src) >= get_dist(M, current))
				continue
			current.stop_for_player(M, stop_random = FALSE)

		activate_for_player(M)

	
	if(player_data)
		for(var/mob/M in player_data)
			if(!(M in players_in_range))
				stop_for_player(M, stop_random = TRUE)


/obj/effect/map_entity/env_soundscape/proc/can_see_soundscape(mob/M)
	var/turf/player_turf = get_turf(M)
	var/turf/soundscape_turf = get_turf(src)
	if(!player_turf || !soundscape_turf)
		return FALSE

	
	if(player_turf == soundscape_turf)
		return TRUE

	
	var/list/line = getline(player_turf, soundscape_turf)
	for(var/turf/T in line)
		if(T == player_turf || T == soundscape_turf)
			continue
		if(T.density)
			return FALSE
		for(var/obj/O in T)
			if(O.density && O.opacity)
				return FALSE
	return TRUE

/obj/effect/map_entity/env_soundscape/proc/cache_position_atoms()
	position_atoms = list()
	var/list/position_names = list(position_0, position_1, position_2, position_3,
	                                position_4, position_5, position_6, position_7)
	for(var/i = 1 to 8)
		var/pos_name = position_names[i]
		if(pos_name)
			var/list/entities = find_map_entities(pos_name)
			position_atoms["[i-1]"] = length(entities) ? entities[1] : src
		else
			position_atoms["[i-1]"] = src

/obj/effect/map_entity/env_soundscape/proc/activate_for_player(mob/M)
	if(!M.client)
		return

	var/decl/soundscape/scape = get_soundscape(soundscape)
	if(!scape)
		return

	
	GLOB.player_active_soundscape[M.client] = src

	LAZYINITLIST(player_data)
	player_data[M] = list("channels" = list(), "timers" = list())

	start_looping_sounds(M, scape)
	start_random_sounds(M, scape)

/obj/effect/map_entity/env_soundscape/proc/stop_for_player(mob/M, stop_random = TRUE)
	if(!player_data || !player_data[M])
		return

	var/list/data = player_data[M]

	
	var/list/channels = data["channels"]
	if(channels)
		for(var/channel in channels)
			sound_to(M, sound(null, channel = channel))

	
	if(stop_random)
		var/list/timers = data["timers"]
		if(timers)
			for(var/timer_id in timers)
				deltimer(timer_id)

	
	if(M.client && GLOB.player_active_soundscape[M.client] == src)
		GLOB.player_active_soundscape -= M.client

	player_data -= M

/obj/effect/map_entity/env_soundscape/proc/start_looping_sounds(mob/M, decl/soundscape/scape)
	if(!length(scape.playlooping))
		return

	var/list/data = player_data[M]
	var/list/channels = data["channels"]
	var/channel_offset = 0

	for(var/list/loop_def in scape.playlooping)
		var/wave = loop_def["wave"]
		if(!wave)
			continue

		var/volume = loop_def["volume"] || 1.0
		var/pitch = loop_def["pitch"] || 100

		var/channel = channel_base + channel_offset
		channel_offset++

		var/sound/S = sound(wave, repeat = TRUE, channel = channel, volume = volume * 100)
		S.frequency = pitch / 100.0

		sound_to(M, S)
		channels += channel

/obj/effect/map_entity/env_soundscape/proc/start_random_sounds(mob/M, decl/soundscape/scape)
	if(!length(scape.playrandom))
		return

	for(var/list/random_def in scape.playrandom)
		schedule_random_sound(M, random_def)

/obj/effect/map_entity/env_soundscape/proc/schedule_random_sound(mob/M, list/random_def)
	var/list/time_range = random_def["time"]
	if(!time_range || length(time_range) < 2)
		return

	var/min_time = time_range[1] * 10
	var/max_time = time_range[2] * 10

	var/delay = rand(min_time, max_time)
	var/timer_id = addtimer(CALLBACK(src, PROC_REF(play_random_sound), M, random_def), delay, TIMER_STOPPABLE)

	if(player_data?[M])
		var/list/data = player_data[M]
		var/list/timers = data["timers"]
		timers += timer_id

/obj/effect/map_entity/env_soundscape/proc/play_random_sound(mob/M, list/random_def)
	if(!player_data || !player_data[M])
		return

	var/wave = null
	var/list/waves = random_def["waves"]
	if(length(waves))
		wave = pick(waves)
	else
		wave = random_def["wave"]

	if(!wave)
		schedule_random_sound(M, random_def)
		return

	var/volume = 1.0
	var/vol_def = random_def["volume"]
	if(islist(vol_def))
		var/list/vol_list = vol_def
		volume = rand(vol_list[1] * 100, vol_list[2] * 100) / 100.0
	else if(vol_def)
		volume = vol_def

	
	sound_to(M, sound(wave, volume = volume * 100))

	schedule_random_sound(M, random_def)


/obj/effect/map_entity/env_soundscape/Crossed(atom/movable/AM)
	. = ..()
	if(mode != "brush" || !enabled || !isliving(AM))
		return
	var/mob/living/M = AM
	if(!M.client)
		return
	if(player_data?[M])
		return

	
	if(brush_neighbors)
		for(var/obj/effect/map_entity/env_soundscape/E in brush_neighbors)
			if(E.player_data?[M])
				
				LAZYINITLIST(player_data)
				player_data[M] = E.player_data[M]
				E.player_data -= M
				return

	
	var/obj/effect/map_entity/env_soundscape/current = GLOB.player_active_soundscape[M.client]
	if(current && current != src)
		current.stop_for_player(M, stop_random = FALSE)

	activate_for_player(M)
	fire_output("OnActivate", M, src)

/obj/effect/map_entity/env_soundscape/Uncrossed(atom/movable/AM)
	. = ..()
	if(mode != "brush" || !isliving(AM))
		return
	var/mob/M = AM
	if(!player_data || !player_data[M])
		return

	
	var/turf/T = AM.loc
	if(T && brush_neighbors)
		for(var/obj/effect/map_entity/env_soundscape/E in brush_neighbors)
			if(E.loc == T)
				
				return

	stop_for_player(M, stop_random = TRUE)
	fire_output("OnDeactivate", M, src)

/*
Inputs:
SetVolume - Sets volume multiplier (param: value 0.0-2.0)
SetSoundscape - Changes the soundscape definition (param: value)
FadeOut - Stops all sounds for all players

Outputs:
OnActivate - When a player enters range/brush
OnDeactivate - When a player leaves
OnSound - When a random sound plays
*/
/obj/effect/map_entity/env_soundscape/receive_input(input_name, atom/activator, atom/caller, list/params)
	. = ..()
	if(.)
		return TRUE
	switch(lowertext(input_name))
		if("setvolume")
			if(params?["value"])
				volume_multiplier = Clamp(text2num(params["value"]), 0, 2)
			return TRUE
		if("setsoundscape")
			if(params?["value"])
				soundscape = params["value"]
			return TRUE
		if("fadeout")
			if(player_data)
				for(var/mob/M in player_data)
					stop_for_player(M, stop_random = TRUE)
			return TRUE
	return FALSE




/obj/effect/map_entity/env_soundscape_trigger
	name = "env_soundscape_trigger"
	icon_state = "trigger"
	is_brush = TRUE

	var/soundscape = ""
	var/channel_base = 0
	var/list/player_data

/obj/effect/map_entity/env_soundscape_trigger/Initialize()
	. = ..()
	channel_base = GLOB.soundscape_channel_counter
	GLOB.soundscape_channel_counter += 10

/obj/effect/map_entity/env_soundscape_trigger/Crossed(atom/movable/AM)
	. = ..()
	if(!enabled || !isliving(AM))
		return

	var/mob/living/M = AM
	if(!M.client)
		return

	if(player_data?[M])
		return
	
	
	if(brush_neighbors)
		for(var/obj/effect/map_entity/env_soundscape_trigger/E in brush_neighbors)
			if(E.player_data?[M])
				
				LAZYINITLIST(player_data)
				player_data[M] = E.player_data[M]
				E.player_data -= M
				
				
				return

	var/decl/soundscape/scape = get_soundscape(soundscape)
	if(!scape)
		return

	
	var/obj/effect/map_entity/env_soundscape/current = GLOB.player_active_soundscape[M.client]
	if(current)
		current.stop_for_player(M, stop_random = FALSE)

	LAZYINITLIST(player_data)
	player_data[M] = list("channels" = list())

	var/list/data = player_data[M]
	var/list/channels = data["channels"]
	var/channel_offset = 0

	for(var/list/loop_def in scape.playlooping)
		var/wave = loop_def["wave"]
		if(!wave)
			continue

		var/volume = loop_def["volume"] || 1.0
		var/pitch = loop_def["pitch"] || 100

		var/channel = channel_base + channel_offset
		channel_offset++

		var/sound/S = sound(wave, repeat = TRUE, channel = channel, volume = volume * 100)
		S.frequency = pitch / 100.0

		sound_to(M, S)
		channels += channel

/obj/effect/map_entity/env_soundscape_trigger/Uncrossed(atom/movable/AM)
	. = ..()
	if(!isliving(AM))
		return

	var/mob/M = AM
	if(!player_data || !player_data[M])
		return
	
	
	var/turf/T = AM.loc
	if(T && brush_neighbors)
		for(var/obj/effect/map_entity/env_soundscape_trigger/E in brush_neighbors)
			if(E.loc == T)
				
				
				return

	var/list/data = player_data[M]
	var/list/channels = data["channels"]

	for(var/channel in channels)
		sound_to(M, sound(null, channel = channel))

	if(M.client && GLOB.player_active_soundscape[M.client] == src)
		GLOB.player_active_soundscape -= M.client

	player_data -= M
