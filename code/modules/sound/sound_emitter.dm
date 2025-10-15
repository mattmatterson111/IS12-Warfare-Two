
/*
	This is a sound_emitter. It is made of /sounds and var/atom/source
	These are passive data sources that hold information about which sound an atom is currently emitting.
	The sound_emitter is the primary means by which developers interact with the sound system. For example,
	  when writing an /obj/machine that needs to emit some sound (either one-off or looping ambient sounds),
	  the user need only call `play` or `stop`. The sound_emitter maintains an internal container of sounds
	  it can play which must be referenced with a key in `play`.
	They are registered with the sound_zone_manager (SZM) on construction and invoke events when
	  starting, updating or stopping a sound. These events are subscribed to by /mobs that enter range.
	  The subscription is driven by the SZM, which maintains a hashmap of sound_emitter locations.
*/

/atom/movable
	var/datum/sound_emitter/sound_emitter

/atom/movable/Destroy()
	qdel(sound_emitter)
	return ..()

/atom/proc/setup_sound()
	return

/mob
	var/last_sound_zone_hash = null
	// proxy for when the sound needs to be sent to some other mob, e.g. aiEye mob movement needs sounds sent to AI Core mob
	//  this is because the AI Eye client is null so we can't get to the SLC via the aiEye mob
	var/mob/sound_endpoint = null
/mob/New()
	..()
	sound_endpoint = src

/proc/turf_volume_coeff(atom/a)
	if (!a || !istype(a))
		return 1 // ?:D?
	var/turf/t = get_turf(a)
	if (!t)
		return 0 // no sound for the damned

	if (istype(t, /turf/simulated))
		return 1

	if (istype(t, /turf/unsimulated))
		return 1
	return 0 //damned

/datum/sound_emitter
	var/atom/source = null
	var/list/sounds = list() // list of managed_sound
	var/datum/managed_sound/active_sound = null
	var/range
	var/last_hash = null

	// update driven by subsystem via update_active_sound_param
	var/env_volume_coeff = 1

	var/datum/sound_zone_manager/szm // not strictly necessary but its here for easy debugging in this early stage

// for static things (e.g. machines that must be bolted to work) pass is_static = TRUE
//  this causes the reserved channel to be taken from a shared pool, as static objects won't move close
//  to eachother and won't contend. There is no overlap between the shared and unique pools, so no contention
//  for example if someone carrying something noisy (mobile -> unique pool) walks close to something in the shared pool.
// Dimensional Push is the exception to this (probably), the sound messing up is part of the !!! fun !!!
/datum/sound_emitter/New(atom/A, var/is_static = FALSE, var/audio_range = 7)
	..()
	source = A
	range = audio_range
	sound_emitter_collection.add(src)
	if (sound_zone_manager)
		szm = sound_zone_manager
	sound_zone_manager.register_emitter(src)

/datum/sound_emitter/Destroy()
	sound_emitter_collection.remove(src)
	sound_zone_manager.unregister_emitter(src)
	deactivate()
	if (sounds)
		sounds.Cut()
		sounds = null
	. = ..()

/*
		GENERAL USE INTERFACE - SETUP, PLAY/STOP CONTROL
*/

/datum/sound_emitter/proc/add(sound/s, key)
	if (!s || !istype(s, /sound))
		return
	if (key && (key in sounds))
		return
	s.atom = source
	s.environment = -1 // byond bug(?) if you set this to anything else, it will permanently set the channel environment to it
	s.transform = matrix(1, 0, 0, 0, 1, 0) //dont think theres a good reason for this to be anything else
	sounds[key] = new /datum/managed_sound(s)

/datum/sound_emitter/proc/play(key)
	var/datum/managed_sound/S = sounds[key]
	if (!S)
		CRASH("Sound emitter play called for key [key], but sound does not exist.")

	if (S.base_sound.repeat == 1)
		activate(key)
	else
		play_once(copy_sound(S.base_sound))

/datum/sound_emitter/proc/play_once(sound/S, interrupt = FALSE)
	S.atom = source
	S.repeat = 0 //no repeat - no need for channel reservation
	S.wait = 0
	if (interrupt)
		stop()
	// reduce volume if emitter is in low pressure
	S.volume *= turf_volume_coeff(source)
	if (!S.volume)
		return

	GLOB.sound_pushed_event.raise_event(src, copy_sound(S), src)

/datum/sound_emitter/proc/is_currently_playing()
	return (active_sound != null)

/datum/sound_emitter/proc/update_active_sound_param(volume = null, frequency = null)
	if (!is_currently_playing())
		return
	// update active_sound overrides if given
	if (volume)
		active_sound.volume_override = volume
	if (frequency)
		active_sound.frequency_override = frequency

	update_env_effect()

	var/sound/S = active_sound.get()
	S.status |= SOUND_UPDATE
	GLOB.sound_updated_event.raise_event(src, src)

/datum/sound_emitter/proc/stop()
	if (!is_currently_playing())
		return
	deactivate()

/datum/sound_emitter/proc/update_source(atom/new_source)
	sound_emitter_collection.remove(src)
	sound_zone_manager.unregister_emitter(src)
	//old source should no longer fire move events
	GLOB.moved_event.unregister(source, src, nameof(src::on_source_moved()))

	source = new_source
	for (var/key in sounds)
		var/datum/managed_sound/S = sounds[key]
		S.update_atom(new_source)
	update_active_sound_param()

	sound_emitter_collection.add(src)
	sound_zone_manager.register_emitter(src)
	//new source
	GLOB.moved_event.register(source, src, nameof(src::on_source_moved()))

/*
		SYSTEMS-FACING INTERFACE
*/

/datum/sound_emitter/proc/on_source_moved(atom/mover)
	if (mover != source)
		CRASH("Called on_source_moved while mover ([mover]) != source ([source])")
	var/turf/T = source.loc
	if (!isturf(T))
		T = get_turf(source)
	if (!T)
		CRASH("Failed to get source turf")
	sound_zone_manager.update_emitter(src, T.x, T.y, T.z)

/datum/sound_emitter/proc/contains(turf/T)
	if (!T)
		return FALSE
	var/turf/S = source.loc
	if (!isturf(S))
		S = get_turf(source)
	if (!S)
		CRASH("Failed to get source turf in in_range")
	var/minX = S.x - range
	var/maxX = S.x + range
	var/minY = S.y - range
	var/maxY = S.y + range
	return (minX <= T.x && T.x <= maxX && minY <= T.y && T.y <= maxY)

/*
		INTERNAL, DON'T CALL THESE DIRECTLY YOU
*/

// push sounds to any clients in range, register with sound_zone_manager for dynamic updates
/datum/sound_emitter/proc/activate(key)
	// bookkeeping
	active_sound = sounds[key]
	if (!active_sound)
		CRASH("[key] not found in sounds cache for emitter on [source]")

	update_env_effect()
	GLOB.sound_started_event.raise_event(src, src)

// halt sounds to clients, unregister from dynamic updates
/datum/sound_emitter/proc/deactivate()
	active_sound = null

	GLOB.sound_stopped_event.raise_event(src, src)

/datum/sound_emitter/proc/update_env_effect()
	if (!is_currently_playing())
		return
	env_volume_coeff = turf_volume_coeff(source)
	active_sound.volume_mutator = env_volume_coeff

/datum/sound_emitter/proc/clients_in_range()
	var/list/in_range = list()
	//var/turf/t_source = get_turf(source)
	for (var/mob/player in GLOB.player_list)
		if (!player || !player.sound_endpoint)
			continue // nowhere to send the sound
		var/client/client = player.sound_endpoint.client
		if (!client || !client.listener_context)
			continue // nowhere to send the sound
		var/turf/receiver = get_turf(client.listener_context.proxy)
		if (!receiver)
			continue //player on some invalid turf, CRASH?
		/* *FUCK*
		if((get_z_dist(receiver, t_source) <= range))
			in_range += client
		*/

	return in_range

/datum/sound_emitter/proc/operator""()
	return "sound_emitter on [source] playing sound [active_sound?.base_sound?.file]"
