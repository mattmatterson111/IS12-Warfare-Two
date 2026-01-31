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
	is_brush = FALSE
	
	/// Mode: "global", "brush", "manual_brush", "input"
	var/mode = "brush"
	var/fade_color = "#000000"
	var/fade_time = 1 SECOND
	var/hold_time = 0  // How long to hold before auto-unfade (0 = manual)
	// var/global_fade = FALSE // Deprecated

	var/list/entities_inside = null

/obj/effect/map_entity/env_fade/Initialize()
	. = ..()
	
	// Legacy mapping
	if(vars.Find("global_fade") && vars["global_fade"])
		mode = "global"

	if(mode == "brush" || mode == "manual_brush")
		is_brush = TRUE
		if(mode == "brush") // manual_brush usually doesn't need instant neighbor connection unless we want tracking across them
			spawn(1)
				connect_brush_neighbors()

/obj/effect/map_entity/env_fade/Crossed(atom/movable/AM)
	. = ..()
	if(!enabled)
		return
	if(mode != "brush" && mode != "manual_brush")
		return
	if(!ishuman(AM))
		return
	
	LAZYADD(entities_inside, AM)
	
	if(mode == "brush")
		var/mob/M = AM
		if(M.client)
			animate(M.client, color = fade_color, time = fade_time)

/obj/effect/map_entity/env_fade/Uncrossed(atom/movable/AM)
	. = ..()
	if(mode != "brush" && mode != "manual_brush")
		return
	if(!ishuman(AM))
		return
	
	if(AM in entities_inside)
		LAZYREMOVE(entities_inside, AM)
		var/mob/M = AM
		if(mode == "brush" && M.client)
			animate(M.client, color = null, time = fade_time)

/obj/effect/map_entity/env_fade/proc/do_fade_in(atom/activator)
	var/list/clients = list()

	if(mode == "global")
		for(var/mob/M in GLOB.player_list)
			if(M.client) clients += M.client
	else if(mode == "input")
		if(ishuman(activator))
			var/mob/M = activator
			if(M.client) clients += M.client
	else if(mode == "manual_brush")
		if(entities_inside)
			for(var/mob/M in entities_inside)
				if(M.client) clients += M.client

	for(var/client/C in clients)
		animate(C, color = fade_color, time = fade_time)
	
	fire_output("OnFadeIn", activator, src)
	
	if(hold_time > 0)
		spawn(fade_time + hold_time)
			do_fade_out(activator)

/obj/effect/map_entity/env_fade/proc/do_fade_out(atom/activator)
	var/list/clients = list()

	if(mode == "global")
		for(var/mob/M in GLOB.player_list)
			if(M.client) clients += M.client
	else if(mode == "input")
		if(ishuman(activator))
			var/mob/M = activator
			if(M.client) clients += M.client
	else if(mode == "manual_brush")
		if(entities_inside)
			for(var/mob/M in entities_inside)
				if(M.client) clients += M.client

	for(var/client/C in clients)
		animate(C, color = null, time = fade_time)
	
	fire_output("OnFadeOut", activator, src)

/obj/effect/map_entity/env_fade/receive_input(input_name, atom/activator, atom/caller, list/params)
	. = ..()
	if(.)
		return TRUE
	switch(lowertext(input_name))
		if("fadein", "fade")
			do_fade_in(activator)
			return TRUE
		if("fadeout", "unfade")
			do_fade_out(activator)
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
