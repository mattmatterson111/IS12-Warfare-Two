// Color Correction Map Entity
// Modes:
// 0: Global (applied to everyone)
// 1: Specific (applied to target via Apply input)
// 2: Brush (applied to mobs entering the brush)

/obj/effect/map_entity/color_correction
	name = "color_correction"
	icon_state = "colorcorrect" // Requires icon
	is_brush = FALSE // Set to TRUE for Mode 2 in map editor usually, but we handle logic below
	
	var/mode = 0
	var/color_val = "#FFFFFF" // Hex color or "r,g,b,a" matrix string
	var/list/entities_inside = null

	var/transition_time = 0 // 0 = instant, >0 = animate time

	// Internal
	// var/datum/color_correction_instance/global_instance

/obj/effect/map_entity/color_correction/Initialize()
	. = ..()
	// Parse color_val if it's a matrix string
	if(istext(color_val))
		if(findtext(color_val, "#"))
			return
		var/clean_val = color_val
		// Basic cleanup for DM list formatting
		clean_val = replacetext(clean_val, "list(", "")
		clean_val = replacetext(clean_val, ")", "")
		clean_val = replacetext(clean_val, "\\", "")
		clean_val = replacetext(clean_val, "'", "")
		clean_val = replacetext(clean_val, "\n", "")
		clean_val = replacetext(clean_val, " ", "") // Remove spaces for cleaner splitting if needed
		
		// Allow for either ; or , as delimiters, or mixed
		clean_val = replacetext(clean_val, ",", ";")
		
		if(findtext(clean_val, ";"))
			var/list/split_colors = splittext(clean_val, ";")
			var/list/matrix_list = list()
			for(var/val in split_colors)
				var/num_val = text2num(val)
				if(!isnull(num_val))
					matrix_list += num_val
			
			if(matrix_list.len == 20 || matrix_list.len == 16)
				color_val = matrix_list

	if(mode == 0 && enabled) // Global
		apply_global()

/obj/effect/map_entity/color_correction/Destroy()
	if(mode == 0 && enabled) // if(global_instance)
		remove_global()
	if(entities_inside)
		for(var/mob/M in entities_inside)
			remove_from(M)
	return ..()

/obj/effect/map_entity/color_correction/receive_input(input_name, atom/activator, atom/caller, list/params)
	. = ..()
	if(.)
		return TRUE

	switch(lowertext(input_name))
		if("enable")
			enabled = TRUE
			if(mode == 0) apply_global()
			fire_output("OnEnable", activator, caller)
			return TRUE
		if("disable")
			enabled = FALSE
			if(mode == 0) remove_global()
			fire_output("OnDisable", activator, caller)
			return TRUE
		if("apply")
			if(mode == 1 && ishuman(activator))
				apply_to(activator)
			return TRUE
		if("remove")
			if(mode == 1 && ishuman(activator))
				remove_from(activator)
			return TRUE
		if("settime")
			transition_time = text2num(params["value"])
			return TRUE
	return FALSE

/obj/effect/map_entity/color_correction/Crossed(atom/movable/AM)
	. = ..()
	if(!enabled || mode != 2)
		return
	if(!ishuman(AM))
		return
	
	LAZYADD(entities_inside, AM)
	apply_to(AM)

/obj/effect/map_entity/color_correction/Uncrossed(atom/movable/AM)
	. = ..()
	if(mode != 2)
		return
	if(!ishuman(AM))
		return

	if(AM in entities_inside)
		LAZYREMOVE(entities_inside, AM)
		remove_from(AM)

/obj/effect/map_entity/color_correction/proc/apply_global()
	// In a real implementation this would likely push a priority-based color datum to the global HUD/client list
	// For now we'll iterate clients, but ideally this should be a subsystem thing
	for(var/client/C in GLOB.clients)
		if(C.mob)
			apply_to(C.mob)
	
	// Hook for new clients (not implemented here, assumes existing hook or simplistic approach)

/obj/effect/map_entity/color_correction/proc/remove_global()
	for(var/client/C in GLOB.clients)
		if(C.mob)
			remove_from(C.mob)

/obj/effect/map_entity/color_correction/proc/apply_to(mob/M)
	if(!M.client) return
	
	if(transition_time > 0)
		animate(M.client, color = color_val, time = transition_time)
	else
		M.client.color = color_val
	
	if(transition_time > 0)
		animate(M.client, color = color_val, time = transition_time)
	else
		M.client.color = color_val
	
	fire_output("OnApply", M, src)

/obj/effect/map_entity/color_correction/proc/remove_from(mob/M)
	if(!M.client) return
	
	// Revert color (Simplistic: set to null or default)
	
	if(transition_time > 0)
		animate(M.client, color = null, time = transition_time)
	else
		M.client.color = null
	
	fire_output("OnRemove", M, src)
