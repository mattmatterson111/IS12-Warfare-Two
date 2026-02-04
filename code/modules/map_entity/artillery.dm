/obj/effect/map_entity/artillery_controller
	name = "artillery_controller"
	icon_state = "logic_relay"

	var/shell_type = "shrapnel"
	var/shell_count = 5
	var/pattern_spacing = 2
	var/pattern_direction = NORTH
	var/strike_delay = 35
	var/target_marker = ""

/obj/effect/map_entity/artillery_controller/receive_input(input_name, atom/activator, atom/caller, list/params)
	. = ..()
	if(.)
		return TRUE

	var/turf/strike_location = get_strike_location()
	if(!strike_location)
		return FALSE

	switch(lowertext(input_name))
		if("firescatter")
			fire_output("OnStrikeStart", activator, caller)
			spawn(strike_delay)
				mortar_scatter(strike_location, 3, shell_count, shell_type)
				spawn(30)
					fire_output("OnStrikeEnd", activator, caller)
			return TRUE

		if("fireconcentrated")
			fire_output("OnStrikeStart", activator, caller)
			spawn(strike_delay)
				mortar_concentrated(strike_location, shell_count, shell_type)
				spawn(30)
					fire_output("OnStrikeEnd", activator, caller)
			return TRUE

		if("fireline")
			fire_output("OnStrikeStart", activator, caller)
			spawn(strike_delay)
				mortar_line(strike_location, pattern_direction, shell_count, pattern_spacing, shell_type)
				spawn(30)
					fire_output("OnStrikeEnd", activator, caller)
			return TRUE

		if("firebox")
			fire_output("OnStrikeStart", activator, caller)
			spawn(strike_delay)
				mortar_box(strike_location, 5, 5, shell_type)
				spawn(50)
					fire_output("OnStrikeEnd", activator, caller)
			return TRUE

		if("firecreep")
			fire_output("OnStrikeStart", activator, caller)
			spawn(strike_delay)
				mortar_creep(strike_location, pattern_direction, 3, shell_count, 3, shell_type)
				spawn(60)
					fire_output("OnStrikeEnd", activator, caller)
			return TRUE

		if("setshelltype")
			if(params?["value"])
				shell_type = params["value"]
			return TRUE

		if("settarget")
			if(params?["value"])
				target_marker = params["value"]
			return TRUE

		if("setdirection")
			if(params?["value"])
				var/dir_text = lowertext(params["value"])
				switch(dir_text)
					if("north", "n")
						pattern_direction = NORTH
					if("south", "s")
						pattern_direction = SOUTH
					if("east", "e")
						pattern_direction = EAST
					if("west", "w")
						pattern_direction = WEST
			return TRUE

	return FALSE

/obj/effect/map_entity/artillery_controller/proc/get_strike_location()
	if(target_marker)
		var/list/targets = find_map_entities(target_marker)
		if(length(targets))
			return get_turf(targets[1])

	return get_turf(src)
