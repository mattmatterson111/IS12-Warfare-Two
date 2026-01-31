
/// Usage: MAPPING_DIRECTIONAL_HELPERS(obj/structure/window, 32)
#define MAPPING_DIRECTIONAL_HELPERS(path, offset) \
/##path/directional/north { dir = NORTH; pixel_y = offset; } \
/##path/directional/south { dir = SOUTH; pixel_y = -offset; } \
/##path/directional/east { dir = EAST; pixel_x = offset; } \
/##path/directional/west { dir = WEST; pixel_x = -offset; }

/// Usage: MAPPING_RANDOM_OFFSET(obj/item/prop/trash, 8, 8)
#define MAPPING_RANDOM_OFFSET(path, xrange, yrange) \
/##path/Initialize(mapload, ...) \
{ \
	. = ..(); \
	pixel_x = rand(-xrange, xrange); \
	pixel_y = rand(-yrange, yrange); \
}

#define MAPPING_DAY_LISTENER(path) \
/##path/Initialize(mapload, ...) \
{ \
	. = ..(); \
	if(!(src in GLOB.auto_day_cycle_listeners)) \
		GLOB.auto_day_cycle_listeners += src; \
	if(SSday_cycle?.current_active_phase) \
		on_day_phase_change(SSday_cycle.current_active_phase.output_channel); \
} \
\
/##path/Destroy() \
{ \
	GLOB.auto_day_cycle_listeners -= src; \
	return ..(); \
}

/// Usage: MAPPING_AUTO_DAY_LIGHT(obj/machinery/light/auto)
#define MAPPING_AUTO_DAY_LIGHT(path) \
MAPPING_DAY_LISTENER(path/auto) \
/##path/auto/on_day_phase_change(phase_name) \
{ \
	if(SSday_cycle?.active_weather?.name in list("storming", "snowstorm")) \
	{ \
		seton(TRUE); \
		return; \
	} \
	switch(phase_name) \
	{ \
		if("dusk_end", "midnight", "dawn_start") seton(TRUE); \
		if("sunrise", "noon", "sunset") seton(FALSE); \
	} \
}

/// Usage: MAPPING_AUTO_SHUTTER(day_night_shutter, obj/machinery/door/blast/shutters, "shutter_link")
#define MAPPING_AUTO_SHUTTER(name, base_path, targetname_val) \
/##base_path/##name { \
	io_targetname = targetname_val; \
} \
MAPPING_DAY_LISTENER(base_path/##name) \
/##base_path/##name/on_day_phase_change(phase_name) \
{ \
	switch(phase_name) \
	{ \
		if("dusk_end", "midnight", "dawn_start") close(); \
		if("sunrise", "noon", "sunset") open(); \
	} \
}

/// Usage: MAPPING_RELAY(teleport_sequence, "relay_tp", list("OnTrigger:tp_destination:Teleport"))
#define MAPPING_RELAY(name, targetname_val, connections_val) \
/obj/effect/map_entity/logic_relay/##name { \
	targetname = targetname_val; \
	connections = connections_val; \
}

/// Usage: MAPPING_COUNTER(lever_puzzle, "counter_puzzle", 3, list("OnThreshold:vault_door:Open"))
#define MAPPING_COUNTER(name, targetname_val, threshold_val, connections_val) \
/obj/effect/map_entity/logic_counter/##name { \
	targetname = targetname_val; \
	threshold = threshold_val; \
	connections = connections_val; \
}

/// Usage: MAPPING_TIMER(alarm_ticker, "timer_alarm", 1 SECONDS, list("OnTimer:alarm_light:Toggle"))
#define MAPPING_TIMER(name, targetname_val, interval_val, connections_val) \
/obj/effect/map_entity/logic_timer/##name { \
	targetname = targetname_val; \
	interval = interval_val; \
	connections = connections_val; \
}

/// Used inside events list: list(CHOREO_EVENT(10, "target", "Input", "Param"), ...)
#define CHOREO_EVENT(time, target, input, param) list(time, target, input, param)

/// Usage: MAPPING_CHOREO(intro_scene, "scene_intro", list(CHOREO_EVENT(10, "lights", "TurnOn")))
#define MAPPING_CHOREO(name, targetname_val, script_val) \
/obj/effect/map_entity/logic_choreographed_scene/##name { \
	targetname = targetname_val; \
	events = script_val; \
}

/// Usage: MAPPING_EXPLOSION(artillery_hit, "artillery_target", 0, 1, 3, 7)
#define MAPPING_EXPLOSION(name, targetname_val, dev_range, heavy_range, light_range, f_range) \
/obj/effect/map_entity/env_explosion/##name { \
	targetname = targetname_val; \
	devastation_range = dev_range; \
	heavy_impact_range = heavy_range; \
	light_impact_range = light_range; \
	flash_range = f_range; \
}

/// Usage: MAPPING_SHAKE(earthquake, "quake_trigger", 50, 4, TRUE)
#define MAPPING_SHAKE(name, targetname_val, duration_val, strength_val, global_val) \
/obj/effect/map_entity/env_shake/##name { \
	targetname = targetname_val; \
	duration = duration_val; \
	strength = strength_val; \
	global_shake = global_val; \
}

/// Usage: MAPPING_FADE(cinema_fade, "fade_trigger", "global", "#000000", 2 SECONDS)
#define MAPPING_FADE(name, targetname_val, mode_val, color_val, time_val) \
/obj/effect/map_entity/env_fade/##name { \
	targetname = targetname_val; \
	mode = mode_val; \
	fade_color = color_val; \
	fade_time = time_val; \
}

/// Usage: MAPPING_PARTICLES(smoke_vent, "smoke_target", "/particles/smoke")
#define MAPPING_PARTICLES(name, targetname_val, path_name) \
/obj/effect/map_entity/env_particles/##name { \
	targetname = targetname_val; \
	particle_path_name = path_name; \
}

/// Usage: MAPPING_SUN(map_sun, "sun_controller", 4, 2, "#FFFFAA")
#define MAPPING_SUN(name, targetname_val, range_val, intensity_val, color_val) \
/obj/effect/map_entity/env_sun/##name { \
	targetname = targetname_val; \
	current_range = range_val; \
	current_intensity = intensity_val; \
	current_color = color_val; \
}

/// Usage: MAPPING_COLOR_CORRECTION(spooky_zone, "cc_spooky", list(1.2, 0, 0, 0, 0.8, 0, 0, 0, 0.5))
#define MAPPING_COLOR_CORRECTION(name, targetname_val, matrix_val) \
/obj/effect/map_entity/color_correction/##name { \
	targetname = targetname_val; \
	color_matrix = matrix_val; \
}

/// Usage: MAPPING_AMBIENT_LOOP(obj/machinery/generator, 'sound/ambience/hum.ogg', 7, 30)
#define MAPPING_AMBIENT_LOOP(path, file, range_val, vol) \
/##path { \
	sound_loop = file; \
	sound_range = range_val; \
	sound_volume = vol; \
}

/// Usage: MAPPING_AMBIENT_SOUND(creaky_floor, "creak_source", 'sound/effects/creak.ogg', 15, 60)
#define MAPPING_AMBIENT_SOUND(name, targetname_val, file, range_val, vol) \
/obj/effect/map_entity/ambient_sound/##name { \
	targetname = targetname_val; \
	sound_file = file; \
	range = range_val; \
	volume = vol; \
}

/// Usage: MAPPING_SOUNDSCAPE(forest_ambience, "scape_forest", list('sound/ambience/bird1.ogg', 'sound/ambience/bird2.ogg'), 5 SECONDS, 15 SECONDS)
#define MAPPING_SOUNDSCAPE(name, targetname_val, sounds_list, min_int, max_int) \
/obj/effect/map_entity/soundscape/##name { \
	targetname = targetname_val; \
	sounds = sounds_list; \
	min_interval = min_int; \
	max_interval = max_int; \
}

/// Usage: MAPPING_AUDIO_ZONE(cave_echo, 8) // Environment 8 = Cave
#define MAPPING_AUDIO_ZONE(name, environment_val) \
/obj/effect/map_entity/audio_zone/##name { \
	environment = environment_val; \
}

/// Usage: MAPPING_LOUDSPEAKER(hq_radio, "radio_hq", /decl/speakercast_template/red, RED_TEAM)
#define MAPPING_LOUDSPEAKER(name, targetname_val, decl_path, team_id) \
/obj/effect/map_entity/loudspeaker_announcement/##name { \
	targetname = targetname_val; \
	speakercast_decl = decl_path; \
	id = team_id; \
}

/// Usage: MAPPING_ANNOUNCEMENT(intel_alert, "alert_intel", "Intel has been secured!", "notice", BLUE_TEAM)
#define MAPPING_ANNOUNCEMENT(name, targetname_val, msg, class_val, team_id) \
/obj/effect/map_entity/announcement/##name { \
	targetname = targetname_val; \
	message = msg; \
	message_class = class_val; \
	filter_faction = team_id; \
}

#define SC_LOOP(wave_val, vol_val, pitch_val) list("wave" = wave_val, "volume" = vol_val, "pitch" = pitch_val)

#define SC_RANDOM(min_t, max_t, min_v, max_v, waves_val) list("time" = list(min_t, max_t), "volume" = list(min_v, max_v), "waves" = waves_val)

/// Usage: MAPPING_SOUNDSCAPE_DECL(trench, "warfare.trench", 1, 2.0, list(SC_LOOP(...)), list(SC_RANDOM(...)))
#define MAPPING_SOUNDSCAPE_DECL(path, name_val, dsp_val, fade_val, loops_val, randoms_val) \
/decl/soundscape/##path { \
	name = name_val; \
	dsp = dsp_val; \
	fadetime = fade_val; \
	playlooping = loops_val; \
	playrandom = randoms_val; \
}

/// Usage: MAPPING_IO_SHUTTER(manual_override, obj/machinery/door/blast/regular, "override_door")
#define MAPPING_IO_SHUTTER(name, base_path, targetname_val) \
/##base_path/##name { \
	io_targetname = targetname_val; \
} \
/##base_path/##name/IO_receive_input(input_name, activator, caller) { \
	switch(lowertext(input_name)) { \
		if("open") open(); \
		if("close") close(); \
		if("toggle") force_toggle(); \
	} \
	return ..(); \
}

/// Usage: MAPPING_TELEPORTER(secret_tunnel, "tp_secret", "exit_point", list(/mob/living))
#define MAPPING_TELEPORTER(name, targetname_val, dest, filters) \
/obj/effect/map_entity/teleporter/##name { \
	targetname = targetname_val; \
	destination = dest; \
	allowed_types = filters; \
}

/// Usage: MAPPING_TRIGGER(trap_spring, "trap_trigger", list("OnTrigger:arrow_trap:Trigger"))
#define MAPPING_TRIGGER(name, targetname_val, connections_val) \
/obj/effect/map_entity/trigger/multiple/##name { \
	targetname = targetname_val; \
	connections = connections_val; \
}

/// Usage: MAPPING_ONEWAY_CLIP(vault_exit, NORTH, FALSE) // Blocks everything NOT moving NORTH
#define MAPPING_ONEWAY_CLIP(name, direction, inverse_val) \
/obj/effect/map_entity/clip/oneway/##name { \
	dir = direction; \
	inverse = inverse_val; \
}

/// Generates entry, idle, and exit landmarks for a specific train ID
#define TRAIN_MARKER_SET(id_val) \
/obj/effect/landmark/train_marker/entry/##id_val { id = #id_val; } \
/obj/effect/landmark/train_marker/idle/##id_val { id = #id_val; } \
/obj/effect/landmark/train_marker/exit/##id_val { id = #id_val; }

#define CARGO_JOB_PRODUCT(id_val, name_val, price_val, category_val, job_path_val, faction_val) \
/decl/cargo_product/job/##id_val { \
	name = name_val; \
	price = price_val; \
	category = category_val; \
	job_path = job_path_val; \
	faction_id = faction_val; \
}

#define CARGO_CRATE_PRODUCT(id_val, name_val, price_val, category_val, contents_val, crate_override, faction_val) \
/decl/cargo_product/crate/##id_val { \
	name = name_val; \
	price = price_val; \
	category = category_val; \
	contents = contents_val; \
	crate_type = crate_override; \
	faction_id = faction_val; \
}

#define CARGO_TRAIN_PRODUCT(id_val, name_val, contents_val, crate_override) \
/decl/cargo_product/train/##id_val { \
	name = name_val; \
	contents = contents_val; \
	crate_type = crate_override; \
}

