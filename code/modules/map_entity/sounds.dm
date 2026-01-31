



/obj/effect/map_entity/ambient_sound
	name = "ambient_sound"
	icon_state = "sound"
	var/sound_file = null
	var/volume = 50
	var/range = 10
	var/ignore_walls = FALSE
	var/looping = FALSE
	var/sound_source = ""  
	var/datum/sound_token/current_sound
	var/atom/cached_source

/obj/effect/map_entity/ambient_sound/Destroy()
	stop_sound()
	return ..()

/obj/effect/map_entity/ambient_sound/proc/get_source()
	if(!sound_source)
		return null
	if(!cached_source)
		var/list/entities = find_io_targets(sound_source)
		if(length(entities))
			cached_source = entities[1]
	return cached_source

/obj/effect/map_entity/ambient_sound/proc/play_sound(atom/activator)
	if(!sound_file)
		return

	var/atom/source = get_source()
	if(source)
		var/sound/S = sound(sound_file, volume = volume)
		S.atom = source
		for(var/mob/M in range(range, source))
			sound_to(M, S)
	else if(range > 0)
		playsound(src, sound_file, volume, vary = TRUE, extrarange = range - 7)
	else
		sound_to(world, sound(sound_file, volume = volume))

/obj/effect/map_entity/ambient_sound/proc/stop_sound()
	if(current_sound)
		qdel(current_sound)
		current_sound = null

/obj/effect/map_entity/ambient_sound/receive_input(input_name, atom/activator, atom/caller, list/params)
	. = ..()
	if(.)
		return TRUE
	switch(lowertext(input_name))
		if("playsound", "play")
			play_sound(activator)
			fire_output("OnPlay", activator, caller)
			return TRUE
		if("stopsound", "stop")
			stop_sound()
			fire_output("OnStop", activator, caller)
			return TRUE
		if("setvolume")
			if(params?["value"])
				volume = Clamp(text2num(params["value"]), 0, 100)
			return TRUE
	return FALSE


/obj/effect/map_entity/sound_play
	name = "sound_play"
	icon_state = "sound"
	var/sound_file = null
	var/volume = 50
	var/range = 10
	var/sound_source = ""
	var/atom/cached_source

/obj/effect/map_entity/sound_play/proc/get_source()
	if(!sound_source)
		return null
	if(!cached_source)
		var/list/entities = find_io_targets(sound_source)
		if(length(entities))
			cached_source = entities[1]
	return cached_source

/obj/effect/map_entity/sound_play/proc/play_sfx(atom/activator)
	if(!sound_file)
		return
	
	var/atom/source = get_source()
	if(!source)
		source = src

	if(range > 0)
		playsound(source, sound_file, volume, vary = FALSE, extrarange = range - 7)
	else
		sound_to(world, sound(sound_file, volume = volume))

/obj/effect/map_entity/sound_play/receive_input(input_name, atom/activator, atom/caller, list/params)
	. = ..()
	if(.)
		return TRUE
	switch(lowertext(input_name))
		if("play")
			play_sfx(activator)
			return TRUE
		if("setvolume")
			if(params?["value"])
				volume = Clamp(text2num(params["value"]), 0, 100)
			return TRUE
	return FALSE


/obj/effect/map_entity/ambient_sound/auto
	name = "ambient_sound_auto"

/obj/effect/map_entity/ambient_sound/auto/Initialize()
	. = ..()
	spawn(5)
		play_sound(null)


/obj/effect/map_entity/ambient_sound/trigger
	name = "sound_trigger"
	is_brush = TRUE
	var/trigger_once = FALSE
	var/cooldown = 0
	var/last_play_time = 0

/obj/effect/map_entity/ambient_sound/trigger/Crossed(atom/movable/AM)
	. = ..()
	if(!enabled || !isliving(AM))
		return
	if(cooldown > 0 && (world.time - last_play_time) < cooldown)
		return
	last_play_time = world.time
	play_sound(AM)
	fire_output("OnTrigger", AM, src)
	if(trigger_once)
		qdel(src)


/obj/effect/map_entity/music_loop
	name = "env_music_loop"
	icon_state = "sound"
	is_brush = TRUE
	var/sound_file = null 
	var/volume = 100 
	var/fade_in_time = 10 
	var/fade_out_time = 20 
	var/music_channel = 1024 
	var/list/listeners = list() 

/obj/effect/map_entity/music_loop/Destroy()
	for(var/mob/M in listeners)
		stop_music(M)
	return ..()

/obj/effect/map_entity/music_loop/Crossed(atom/movable/AM)
	. = ..()
	if(!enabled)
		return
	if(!ismob(AM))
		return
	var/mob/M = AM
	if(!M.client)
		return

	LAZYADD(listeners, M)
	play_music(M)

/obj/effect/map_entity/music_loop/Uncrossed(atom/movable/AM)
	. = ..()
	if(AM in listeners)
		LAZYREMOVE(listeners, AM)
		stop_music(AM)

/obj/effect/map_entity/music_loop/proc/play_music(mob/M)
	if(!sound_file) return
	
	if(fade_in_time > 0)
		sound_to(M, sound(sound_file, repeat = TRUE, channel = music_channel, volume = volume, wait = 0)) 
	else
		sound_to(M, sound(sound_file, repeat = TRUE, channel = music_channel, volume = volume, wait = 0))

/obj/effect/map_entity/music_loop/proc/stop_music(mob/M)
	if(!M.client) return
	sound_to(M, sound(null, channel = music_channel))

/obj/effect/map_entity/music_loop/receive_input(input_name, atom/activator, atom/caller, list/params)
	. = ..()
	if(.) return TRUE
	switch(lowertext(input_name))
		if("enable")
			enabled = TRUE
			return TRUE
		if("disable")
			enabled = FALSE
			for(var/mob/M in listeners)
				stop_music(M)
			listeners.Cut()
			return TRUE
	return FALSE


/obj/effect/map_entity/global_sound
	name = "global_sound"
	icon_state = "sound"
	var/sound_file = null
	var/volume = 100

/obj/effect/map_entity/global_sound/proc/play_global()
	if(!sound_file)
		return
	sound_to(world, sound(sound_file, volume = volume))

/obj/effect/map_entity/global_sound/receive_input(input_name, atom/activator, atom/caller, list/params)
	. = ..()
	if(.)
		return TRUE
	switch(lowertext(input_name))
		if("playsound", "play")
			play_global()
			fire_output("OnPlay", activator, caller)
			return TRUE
	return FALSE


/obj/effect/map_entity/announcement
	name = "announcement"
	icon_state = "logic_relay"
	var/message = ""
	var/range = 0  
	var/message_class = "notice"
	var/filter_faction = null

/obj/effect/map_entity/announcement/proc/make_announcement(atom/activator)
	if(!message)
		return
	if(range > 0)
		for(var/mob/living/L in range(range, src))
			if(filter_faction && L.warfare_faction != filter_faction)
				continue
			to_chat(L, "<span class='[message_class]'>[message]</span>")
	else
		if(filter_faction)
			for(var/mob/living/L in GLOB.player_list)
				if(L.warfare_faction == filter_faction)
					to_chat(L, "<span class='[message_class]'>[message]</span>")
		else
			to_world("<span class='[message_class]'>[message]</span>")

/obj/effect/map_entity/announcement/receive_input(input_name, atom/activator, atom/caller, list/params)
	. = ..()
	if(.)
		return TRUE
	switch(lowertext(input_name))
		if("announce", "trigger")
			make_announcement(activator)
			fire_output("OnAnnounce", activator, caller)
			return TRUE
		if("setmessage")
			if(params?["value"])
				message = params["value"]
			return TRUE
	return FALSE


/obj/effect/map_entity/soundscape
	name = "soundscape"
	icon_state = "env_soundscape"
	var/list/sounds = list()
	var/sound_file = null
	var/volume = 30
	var/range = 8
	var/min_interval = 5 SECONDS
	var/max_interval = 15 SECONDS
	var/active = TRUE
	var/start_on_spawn = TRUE
	var/timer_id = null

/obj/effect/map_entity/soundscape/Initialize()
	. = ..()
	if(start_on_spawn && active)
		schedule_next_sound()

/obj/effect/map_entity/soundscape/Destroy()
	if(timer_id)
		deltimer(timer_id)
		timer_id = null
	return ..()

/obj/effect/map_entity/soundscape/proc/schedule_next_sound()
	if(!active || !enabled)
		return
	var/delay = rand(min_interval, max_interval)
	timer_id = addtimer(CALLBACK(src, PROC_REF(play_ambient_sound)), delay, TIMER_STOPPABLE)

/obj/effect/map_entity/soundscape/proc/play_ambient_sound()
	if(!active || !enabled)
		return
	var/sound_to_play = sounds?.len ? pick(sounds) : sound_file
	if(sound_to_play)
		playsound(src, sound_to_play, volume, vary = TRUE, extrarange = range - 7)
		fire_output("OnSound", null, src)
	schedule_next_sound()

/obj/effect/map_entity/soundscape/proc/start_soundscape()
	if(active)
		return
	active = TRUE
	schedule_next_sound()

/obj/effect/map_entity/soundscape/proc/stop_soundscape()
	active = FALSE
	if(timer_id)
		deltimer(timer_id)
		timer_id = null

/obj/effect/map_entity/soundscape/receive_input(input_name, atom/activator, atom/caller, list/params)
	. = ..()
	if(.)
		return TRUE
	switch(lowertext(input_name))
		if("start")
			start_soundscape()
			return TRUE
		if("stop")
			stop_soundscape()
			return TRUE
		if("toggle")
			if(active)
				stop_soundscape()
			else
				start_soundscape()
			return TRUE
	return FALSE






/obj/effect/map_entity/loudspeaker_announcement
	name = "loudspeaker_announcement"
	icon_state = "loudspeaker"
	
	var/id = 0
	var/decl/speakercast_template/speakercast_decl = /decl/speakercast_template/female_mumble
	
	var/broadcasting = FALSE
	var/list/speakers = list()

/obj/effect/map_entity/loudspeaker_announcement/Initialize()
	. = ..()
	speakercast_decl = decls_repository.get_decl(speakercast_decl)

/obj/effect/map_entity/loudspeaker_announcement/proc/update_speakers()
	if(!speakers)
		speakers = list()
	speakers.Cut()
	for(var/obj/structure/announcementspeaker/s in GLOB.speakers)
		if(s.in_use_by)
			continue
		if(s.id != id)
			continue
		speakers |= s

/obj/effect/map_entity/loudspeaker_announcement/proc/start_broadcast()
	if(broadcasting)
		return
	broadcasting = TRUE
	update_speakers()
	for(var/obj/structure/announcementspeaker/s in speakers)
		soundoverlay(s, newplane = FOOTSTEP_ALERT_PLANE)
		playsound(s.loc, speakercast_decl.broadcast_start_sound, speakercast_decl.broadcast_start_sound_volume, 0)
		spawn(3)
			s.start_hum()

/obj/effect/map_entity/loudspeaker_announcement/proc/stop_broadcast()
	if(!broadcasting)
		return
	broadcasting = FALSE
	for(var/obj/structure/announcementspeaker/s in speakers)
		playsound(s.loc, speakercast_decl.broadcast_end_sound, speakercast_decl.broadcast_end_sound_volume, 0)
		s.overlays.Cut()
		soundoverlay(s, newplane = FOOTSTEP_ALERT_PLANE)
		spawn(3)
			s.stop_hum()

/obj/effect/map_entity/loudspeaker_announcement/proc/broadcast_message(text)
	if(!broadcasting)
		return
	
	speakercast_decl.broadcast(text, id ? id : "ALL", null)

/obj/effect/map_entity/loudspeaker_announcement/receive_input(input_name, atom/activator, atom/caller, list/params)
	. = ..()
	if(.)
		return TRUE
	
	switch(lowertext(input_name))
		if("toggle", "togglebroadcast")
			if(broadcasting)
				stop_broadcast()
			else
				start_broadcast()
			return TRUE
		if("seton", "start", "enable")
			start_broadcast()
			return TRUE
		if("setoff", "stop", "disable")
			stop_broadcast()
			return TRUE
		if("broadcast", "announce")
			var/text = params?["value"]
			if(text)
				broadcast_message(text)
			return TRUE
		if("setid")
			var/val = params?["value"]
			if(val)
				if(isnum(text2num(val)))
					id = text2num(val)
				else
					id = val
			return TRUE
		if("settemplate")
			var/val = params?["value"]
			if(val)
				var/getpath = text2path(val)
				if(ispath(getpath, /decl/speakercast_template))
					speakercast_decl = decls_repository.get_decl(getpath)
			return TRUE
	return FALSE






/obj/effect/map_entity/audio_zone
	name = "audio_zone"
	icon_state = "sound" 
	is_brush = TRUE
	var/environment = 0
	var/list/listeners = list()

/obj/effect/map_entity/audio_zone/Crossed(atom/movable/AM)
	. = ..()
	if(!enabled || !ismob(AM))
		return
	var/mob/M = AM
	if(!M.client)
		return
	LAZYADD(listeners, M)
	apply_reverb(M)

/obj/effect/map_entity/audio_zone/Uncrossed(atom/movable/AM)
	. = ..()
	if(AM in listeners)
		LAZYREMOVE(listeners, AM)
		remove_reverb(AM)

/obj/effect/map_entity/audio_zone/proc/apply_reverb(mob/M)
	if(M.client)
		
		
		M.client.sound_environment = environment

/obj/effect/map_entity/audio_zone/proc/remove_reverb(mob/M)
	if(M.client)
		
		
		M.client.sound_environment = 0


/obj/effect/map_entity/audio_zone/generic
	name = "audio_zone_generic"
	environment = 0
/obj/effect/map_entity/audio_zone/padded_cell
	name = "audio_zone_padded_cell"
	environment = 1
/obj/effect/map_entity/audio_zone/room
	name = "audio_zone_room"
	environment = 2
/obj/effect/map_entity/audio_zone/bathroom
	name = "audio_zone_bathroom"
	environment = 3
/obj/effect/map_entity/audio_zone/livingroom
	name = "audio_zone_livingroom"
	environment = 4
/obj/effect/map_entity/audio_zone/stoneroom
	name = "audio_zone_stoneroom"
	environment = 5
/obj/effect/map_entity/audio_zone/auditorium
	name = "audio_zone_auditorium"
	environment = 6
/obj/effect/map_entity/audio_zone/concerthall
	name = "audio_zone_concerthall"
	environment = 7
/obj/effect/map_entity/audio_zone/cave
	name = "audio_zone_cave"
	environment = 8
/obj/effect/map_entity/audio_zone/arena
	name = "audio_zone_arena"
	environment = 9
/obj/effect/map_entity/audio_zone/hangar
	name = "audio_zone_hangar"
	environment = 10
/obj/effect/map_entity/audio_zone/carpetedhallway
	name = "audio_zone_carpetedhallway"
	environment = 11
/obj/effect/map_entity/audio_zone/hallway
	name = "audio_zone_hallway"
	environment = 12
/obj/effect/map_entity/audio_zone/stonecorridor
	name = "audio_zone_stonecorridor"
	environment = 13
/obj/effect/map_entity/audio_zone/alley
	name = "audio_zone_alley"
	environment = 14
/obj/effect/map_entity/audio_zone/forest
	name = "audio_zone_forest"
	environment = 15
/obj/effect/map_entity/audio_zone/city
	name = "audio_zone_city"
	environment = 16
/obj/effect/map_entity/audio_zone/mountains
	name = "audio_zone_mountains"
	environment = 17
/obj/effect/map_entity/audio_zone/quarry
	name = "audio_zone_quarry"
	environment = 18
/obj/effect/map_entity/audio_zone/plain
	name = "audio_zone_plain"
	environment = 19
/obj/effect/map_entity/audio_zone/parkinglot
	name = "audio_zone_parkinglot"
	environment = 20
/obj/effect/map_entity/audio_zone/sewerpipe
	name = "audio_zone_sewerpipe"
	environment = 21
/obj/effect/map_entity/audio_zone/underwater
	name = "audio_zone_underwater"
	environment = 22

