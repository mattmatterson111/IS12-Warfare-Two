

#define MAPPING_DIRECTIONAL_HELPERS(path, offset) \
/##path/directional/north { dir = NORTH; pixel_y = offset; } \
/##path/directional/south { dir = SOUTH; pixel_y = -offset; } \
/##path/directional/east { dir = EAST; pixel_x = offset; } \
/##path/directional/west { dir = WEST; pixel_x = -offset; }


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


#define MAPPING_RELAY(name, targetname_val, connections_val) \
/obj/effect/map_entity/logic_relay/##name { \
	io_targetname = targetname_val; \
	io_connections = connections_val; \
}


#define MAPPING_COUNTER(name, targetname_val, threshold_val, connections_val) \
/obj/effect/map_entity/logic_counter/##name { \
	io_targetname = targetname_val; \
	threshold = threshold_val; \
	io_connections = connections_val; \
}


#define MAPPING_TIMER(name, targetname_val, interval_val, connections_val) \
/obj/effect/map_entity/logic_timer/##name { \
	io_targetname = targetname_val; \
	interval = interval_val; \
	io_connections = connections_val; \
}


#define CHOREO_EVENT(time, target, input, param) list(time, target, input, param)


#define MAPPING_CHOREO(name, targetname_val, script_val) \
/obj/effect/map_entity/logic_choreographed_scene/##name { \
	io_targetname = targetname_val; \
	events = script_val; \
}


#define MAPPING_EXPLOSION(name, targetname_val, dev_range, heavy_range, light_range, f_range) \
/obj/effect/map_entity/env_explosion/##name { \
	io_targetname = targetname_val; \
	devastation_range = dev_range; \
	heavy_impact_range = heavy_range; \
	light_impact_range = light_range; \
	flash_range = f_range; \
}


#define MAPPING_SHAKE(name, targetname_val, duration_val, strength_val, global_val) \
/obj/effect/map_entity/env_shake/##name { \
	io_targetname = targetname_val; \
	duration = duration_val; \
	strength = strength_val; \
	global_shake = global_val; \
}


#define MAPPING_FADE(name, targetname_val, mode_val, color_val, time_val) \
/obj/effect/map_entity/env_fade/##name { \
	io_targetname = targetname_val; \
	mode = mode_val; \
	fade_color = color_val; \
	fade_time = time_val; \
}


#define MAPPING_PARTICLES(name, targetname_val, path_name) \
/obj/effect/map_entity/env_particles/##name { \
	io_targetname = targetname_val; \
	particle_path_name = path_name; \
}


#define MAPPING_SUN(name, targetname_val, range_val, intensity_val, color_val) \
/obj/effect/map_entity/env_sun/##name { \
	io_targetname = targetname_val; \
	current_range = range_val; \
	current_intensity = intensity_val; \
	current_color = color_val; \
}


#define MAPPING_COLOR_CORRECTION(name, targetname_val, matrix_val) \
/obj/effect/map_entity/color_correction/##name { \
	io_targetname = targetname_val; \
	color_matrix = matrix_val; \
}


#define MAPPING_AMBIENT_LOOP(path, file, range_val, vol) \
/##path { \
	sound_loop = file; \
	sound_range = range_val; \
	sound_volume = vol; \
}


#define MAPPING_AMBIENT_SOUND(name, targetname_val, file, range_val, vol) \
/obj/effect/map_entity/ambient_sound/##name { \
	io_targetname = targetname_val; \
	sound_file = file; \
	range = range_val; \
	volume = vol; \
}


#define MAPPING_SOUNDSCAPE(name, targetname_val, sounds_list, min_int, max_int) \
/obj/effect/map_entity/soundscape/##name { \
	io_targetname = targetname_val; \
	sounds = sounds_list; \
	min_interval = min_int; \
	max_interval = max_int; \
}


#define MAPPING_AUDIO_ZONE(name, environment_val) \
/obj/effect/map_entity/audio_zone/##name { \
	environment = environment_val; \
}


#define MAPPING_LOUDSPEAKER(name, targetname_val, decl_path, team_id) \
/obj/effect/map_entity/loudspeaker_announcement/##name { \
	io_targetname = targetname_val; \
	speakercast_decl = decl_path; \
	id = team_id; \
}


#define MAPPING_ANNOUNCEMENT(name, targetname_val, msg, class_val, team_id) \
/obj/effect/map_entity/announcement/##name { \
	io_targetname = targetname_val; \
	message = msg; \
	message_class = class_val; \
	filter_faction = team_id; \
}
/*
#define SC_LOOP(wave_val, vol_val, pitch_val) list("wave" = wave_val, "volume" = vol_val, "pitch" = pitch_val)

#define SC_RANDOM(min_t, max_t, min_v, max_v, waves_val) list("time" = list(min_t, max_t), "volume" = list(min_v, max_v), "waves" = waves_val)


#define MAPPING_SOUNDSCAPE_DECL(path, name_val, dsp_val, fade_val, loops_val, randoms_val) \
/decl/soundscape/##path { \
	name = name_val; \
	dsp = dsp_val; \
	fadetime = fade_val; \
	playlooping = loops_val; \
	playrandom = randoms_val; \
}
*/

#define MAPPING_IO_SHUTTER(name, base_path, targetname_val) \
/##base_path/##name { \
	io_targetname = targetname_val; \
} \
/##base_path/##name/IO_receive_input(input_name, activator, caller, params) { \
	switch(lowertext(input_name)) { \
		if("open") open(); \
		if("close") close(); \
		if("toggle") force_toggle(); \
	} \
	return ..(); \
}


#define MAPPING_TELEPORTER(name, targetname_val, dest, filters) \
/obj/effect/map_entity/teleporter/##name { \
	io_targetname = targetname_val; \
	destination = dest; \
	allowed_types = filters; \
}


#define MAPPING_TRIGGER(name, targetname_val, connections_val) \
/obj/effect/map_entity/trigger/multiple/##name { \
	io_targetname = targetname_val; \
	io_connections = connections_val; \
}


#define MAPPING_ONEWAY_CLIP(name, direction, inverse_val) \
/obj/effect/map_entity/clip/oneway/##name { \
	dir = direction; \
	inverse = inverse_val; \
}


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


#define MAPPING_ARTILLERY(name, targetname_val, shell_type_val, count_val, dir_val) \
/obj/effect/map_entity/artillery_controller/##name { \
	io_targetname = targetname_val; \
	shell_type = shell_type_val; \
	shell_count = count_val; \
	pattern_direction = dir_val; \
}

