// Map Entity I/O System - Hammer Editor style entity scripting
// Entities connect outputs to inputs via 'connections' list
// Connection format: "Output:TargetName:Input:Delay"

GLOBAL_LIST_EMPTY(map_entities_by_name)

/obj/effect/map_entity
	name = "map_entity"
	desc = "A map entity for level scripting."
	icon = 'icons/hammer/source.dmi'
	icon_state = "landmark2"
	anchored = TRUE
	density = FALSE
	var/targetname = ""
	var/list/connections = list()
	var/connections_string = "" // Fallback for editor list issues: "Output:Target:Input:Delay;Output2:Target:Input:Delay"
	var/enabled = TRUE
	var/start_disabled = FALSE
	var/is_brush = FALSE
	var/list/brush_neighbors
	var/list/parsed_connections

/obj/effect/map_entity/ex_act()
    return FALSE

/obj/effect/map_entity/blocks_airlock()
    return FALSE


/obj/effect/map_entity/Initialize()
	. = ..()
	if(targetname)
		register_entity()
	parse_connections()
	if(start_disabled)
		enabled = FALSE
	if(is_brush)
		spawn(1)
			connect_brush_neighbors()
	spawn(2)
		fire_output("OnSpawn", null, src)

/obj/effect/map_entity/Destroy()
	if(targetname)
		unregister_entity()
	if(brush_neighbors)
		for(var/obj/effect/map_entity/E in brush_neighbors)
			LAZYREMOVE(E.brush_neighbors, src)
		brush_neighbors = null
	return ..()

/obj/effect/map_entity/proc/register_entity()
	var/key = lowertext(targetname)
	LAZYINITLIST(GLOB.map_entities_by_name[key])
	GLOB.map_entities_by_name[key] += src

/obj/effect/map_entity/proc/unregister_entity()
	var/key = lowertext(targetname)
	if(GLOB.map_entities_by_name[key])
		GLOB.map_entities_by_name[key] -= src
		if(!length(GLOB.map_entities_by_name[key]))
			GLOB.map_entities_by_name -= key

/proc/find_map_entities(target_name)
	if(!target_name)
		return list()
	var/key = lowertext(target_name)
	. = list()
	if(GLOB.map_entities_by_name[key])
		. += GLOB.map_entities_by_name[key]

/obj/effect/map_entity/proc/parse_connections()
	parsed_connections = list()

	// Fallback for editor issues
	if(connections_string)
		var/list/string_conns = splittext(connections_string, ";")
		for(var/s in string_conns)
			if(s) connections += s
	
	for(var/conn in connections)
		if(isnull(conn)) continue // specific fix for editor null list issue

		if(istext(conn))
			var/list/parts = splittext(conn, ":")
			if(length(parts) >= 3)
				var/output_name = parts[1]
				var/target_name = parts[2]
				var/input_name = parts[3]
				var/delay = length(parts) >= 4 ? text2num(parts[4]) : 0
				var/param = length(parts) >= 5 ? parts[5] : null
				LAZYINITLIST(parsed_connections[output_name])
				parsed_connections[output_name] += list(list(
					"target" = target_name,
					"input" = input_name,
					"delay" = delay,
					"param" = param
				))
		else if(islist(conn))
			var/list/C = conn
			var/output_name = C["output"]
			if(output_name)
				LAZYINITLIST(parsed_connections[output_name])
				parsed_connections[output_name] += list(list(
					"target" = C["target"],
					"input" = C["input"],
					"delay" = C["delay"] || 0,
					"param" = C["param"]
				))

/obj/effect/map_entity/proc/fire_output(output_name, atom/activator, atom/caller)
	if(!enabled || !parsed_connections?[output_name])
		return

	for(var/list/conn in parsed_connections[output_name])
		var/target_name = conn["target"]
		var/input_name = conn["input"]
		var/delay = conn["delay"]
		var/param = conn["param"]
		var/list/params = param ? list("value" = param) : null
		
		var/list/targets = find_io_targets(target_name)
		message_admins("MapEntity [src] ([targetname]) firing [output_name] -> [target_name]:[input_name] (Targets found: [length(targets)])")
		
		for(var/atom/target in targets)
			if(delay > 0)
				spawn(delay)
					if(target && !QDELETED(target))
						send_io_input(target, input_name, activator, caller, params)
			else
				send_io_input(target, input_name, activator, caller, params)

	if(is_brush && brush_neighbors)
		for(var/obj/effect/map_entity/neighbor in brush_neighbors)
			neighbor.fire_output_local(output_name, activator, caller)

/obj/effect/map_entity/proc/fire_output_local(output_name, atom/activator, atom/caller)
	if(!enabled || !parsed_connections?[output_name])
		return

	for(var/list/conn in parsed_connections[output_name])
		var/target_name = conn["target"]
		var/input_name = conn["input"]
		var/delay = conn["delay"]
		var/list/targets = find_io_targets(target_name)
		for(var/atom/target in targets)
			if(delay > 0)
				spawn(delay)
					if(target && !QDELETED(target))
						send_io_input(target, input_name, activator, caller)
			else
				send_io_input(target, input_name, activator, caller)

/obj/effect/map_entity/proc/receive_input(input_name, atom/activator, atom/caller, list/params)
	if(input_name != "OnSpawn") // Reduce spam
		message_admins("MapEntity [src] ([targetname]) received input: [input_name] from [caller]")

	if(!enabled && input_name != "Enable")
		return FALSE

	switch(lowertext(input_name))
		if("enable")
			enabled = TRUE
			return TRUE
		if("disable")
			enabled = FALSE
			return TRUE
		if("toggle")
			enabled = !enabled
			return TRUE
		if("kill")
			qdel(src)
			return TRUE
	return FALSE

/obj/effect/map_entity/proc/connect_brush_neighbors()
	if(!is_brush || !name)
		return
	LAZYINITLIST(brush_neighbors)
	for(var/dir in GLOB.cardinal)
		var/turf/T = get_step(src, dir)
		if(!T)
			continue
		for(var/obj/effect/map_entity/E in T)
			if(E == src || !E.is_brush)
				continue
			if(lowertext(E.name) != lowertext(name))
				continue
			brush_neighbors |= E
			LAZYINITLIST(E.brush_neighbors)
			E.brush_neighbors |= src

/obj/effect/map_entity/proc/add_connection(output_name, target_name, input_name, delay = 0)
	LAZYINITLIST(parsed_connections[output_name])
	parsed_connections[output_name] += list(list(
		"target" = target_name,
		"input" = input_name,
		"delay" = delay
	))

/obj/effect/map_entity/proc/clear_connections(output_name)
	if(parsed_connections)
		parsed_connections -= output_name

/obj/effect/map_entity/proc/get_entity_info()
	return "[type] (targetname: [targetname], enabled: [enabled], brush: [is_brush])"
