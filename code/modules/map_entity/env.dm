// Environment entities for map effects

// Env Shake - screen shake effect
/obj/effect/map_entity/env_shake
	name = "env_shake"
	icon_state = "trigger"
	is_brush = TRUE
	var/duration = 5
	var/strength = 2
	var/global_shake = FALSE  // If TRUE, shakes all players on map

/obj/effect/map_entity/env_shake/proc/do_shake()
	if(global_shake)
		for(var/mob/M in GLOB.player_list)
			if(M.client)
				shake_camera(M, duration, strength)
	else
		// Shake mobs inside brush area
		var/list/turfs_to_check = list(get_turf(src))
		if(brush_neighbors)
			for(var/obj/effect/map_entity/E in brush_neighbors)
				turfs_to_check |= get_turf(E)
		for(var/turf/T in turfs_to_check)
			for(var/mob/M in T)
				if(M.client)
					shake_camera(M, duration, strength)

/obj/effect/map_entity/env_shake/receive_input(input_name, atom/activator, atom/caller, list/params)
	. = ..()
	if(.)
		return TRUE
	switch(lowertext(input_name))
		if("shake")
			do_shake()
			fire_output("OnShake", activator, caller)
			return TRUE
		if("setduration")
			duration = text2num(params?["value"]) || duration
			return TRUE
		if("setstrength")
			strength = text2num(params?["value"]) || strength
			return TRUE
	return FALSE

// Env Fade - screen fade effect
/obj/effect/map_entity/env_fade
	name = "env_fade"
	icon_state = "fade"
	is_brush = TRUE
	var/fade_color = "#000000"
	var/fade_time = 1 SECOND
	var/hold_time = 0  // How long to hold before auto-unfade (0 = manual)
	var/global_fade = FALSE

/obj/effect/map_entity/env_fade/proc/get_affected_clients()
	var/list/clients = list()
	if(global_fade)
		for(var/mob/M in GLOB.player_list)
			if(M.client)
				clients += M.client
	else
		var/list/turfs_to_check = list(get_turf(src))
		if(brush_neighbors)
			for(var/obj/effect/map_entity/E in brush_neighbors)
				turfs_to_check |= get_turf(E)
		for(var/turf/T in turfs_to_check)
			for(var/mob/M in T)
				if(M.client)
					clients += M.client
	return clients

/obj/effect/map_entity/env_fade/proc/do_fade_in()
	var/list/clients = get_affected_clients()
	for(var/client/C in clients)
		animate(C, color = fade_color, time = fade_time)
	fire_output("OnFadeIn", null, src)
	if(hold_time > 0)
		spawn(fade_time + hold_time)
			do_fade_out()

/obj/effect/map_entity/env_fade/proc/do_fade_out()
	var/list/clients = get_affected_clients()
	for(var/client/C in clients)
		animate(C, color = null, time = fade_time)
	fire_output("OnFadeOut", null, src)

/obj/effect/map_entity/env_fade/receive_input(input_name, atom/activator, atom/caller, list/params)
	. = ..()
	if(.)
		return TRUE
	switch(lowertext(input_name))
		if("fadein", "fade")
			do_fade_in()
			return TRUE
		if("fadeout", "unfade")
			do_fade_out()
			return TRUE
		if("setcolor")
			fade_color = params?["value"] || fade_color
			return TRUE
		if("settime")
			fade_time = text2num(params?["value"]) || fade_time
			return TRUE
	return FALSE

// Env Explosion - explosion effect
/obj/effect/map_entity/env_explosion
	name = "env_explosion"
	icon_state = "explosion"
	var/devastation_range = 0
	var/heavy_impact_range = 1
	var/light_impact_range = 2
	var/flash_range = 3

/obj/effect/map_entity/env_explosion/receive_input(input_name, atom/activator, atom/caller, list/params)
	. = ..()
	if(.)
		return TRUE
	switch(lowertext(input_name))
		if("explode", "trigger")
			explosion(get_turf(src), devastation_range, heavy_impact_range, light_impact_range, flash_range)
			fire_output("OnExplode", activator, caller)
			return TRUE
	return FALSE

// Env Sun - controls global daylight objects
/obj/effect/map_entity/env_sun
	name = "env_sun"
	icon_state = "env_sun"
	var/current_range = 2
	var/current_intensity = 1
	var/current_color = "#545484"

/obj/effect/map_entity/env_sun/proc/update_daylight()
	for(var/obj/effect/lighting_dummy/daylight/D in GLOB.lighting_dummies)
		D.set_light(current_range, current_intensity, current_color)

/obj/effect/map_entity/env_sun/receive_input(input_name, atom/activator, atom/caller, list/params)
	. = ..()
	if(.)
		return TRUE
	switch(lowertext(input_name))
		if("update", "setlight") // Apply all current settings (or params if provided)
			if(params)
				if(params["range"]) current_range = text2num(params["range"])
				if(params["intensity"]) current_intensity = text2num(params["intensity"])
				if(params["color"]) current_color = params["color"]
			update_daylight()
			return TRUE
		if("setcolor")
			var/val = params?["value"]
			if(val)
				current_color = val
				update_daylight()
			return TRUE
		if("setrange")
			var/val = params?["value"]
			if(val)
				current_range = text2num(val)
				update_daylight()
			return TRUE
		if("setintensity")
			var/val = params?["value"]
			if(val)
				current_intensity = text2num(val)
				update_daylight()
			return TRUE
	return FALSE

// Env Particles - displays a particle effect
/obj/effect/map_entity/env_particles
	name = "env_particles"
	icon_state = "particles"
	var/particle_path_name = "" // Text path to the particles (e.g. "/particles/smoke")

/obj/effect/map_entity/env_particles/Initialize()
	. = ..()
	if(particle_path_name)
		update_particles()

/obj/effect/map_entity/env_particles/proc/update_particles()
	if(particles)
		particles = null
		
	if(particle_path_name)
		var/path = text2path(particle_path_name)
		if(ispath(path, /particles))
			particles = new path()

/obj/effect/map_entity/env_particles/receive_input(input_name, atom/activator, atom/caller, list/params)
	. = ..()
	if(.)
		return TRUE
	switch(lowertext(input_name))
		if("setparticle")
			var/val = params?["value"]
			if(val)
				particle_path_name = val
				update_particles()
			return TRUE
		if("seton", "start", "enable")
			enabled = TRUE
			if(!particles)
				update_particles()
			return TRUE
		if("setoff", "stop", "disable")
			enabled = FALSE
			particles = null
			return TRUE
		if("toggle")
			// Toggle particles existence based on current state (not just enabled var)
			if(particles)
				enabled = FALSE
				particles = null
			else
				enabled = TRUE
				update_particles()
			return TRUE
		if("delete")
			qdel(src)
			return TRUE
	return FALSE
