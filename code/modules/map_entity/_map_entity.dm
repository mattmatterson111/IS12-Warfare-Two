GLOBAL_LIST_EMPTY(map_entities_by_name)

#define MAP_ENTITY_DEBUG 0

#define MAP_ENTITY_COLOR_OUTPUT "#00ff73"
#define MAP_ENTITY_COLOR_INPUT "#ffae00"
#define MAP_ENTITY_COLOR_SEQUENCE "#FF00FF"

/obj/effect/map_entity
	name = "map_entity"
	desc = "A map entity for level scripting."
	icon = 'icons/hammer/source.dmi'
	icon_state = "landmark2"
	anchored = TRUE
	density = FALSE
	
	var/enabled = TRUE
	var/start_disabled = FALSE
	var/is_brush = FALSE
	var/list/brush_neighbors

/atom/proc/debug_flash(flash_color)
#if MAP_ENTITY_DEBUG
	var/debug_old_color = color
	animate(src, color = flash_color, time = 0.5)
	animate(color = debug_old_color, time = 5)
#endif

/obj/effect/map_entity/proc/debug_log(message)
#if MAP_ENTITY_DEBUG
	message_admins("MapEntity [src] ([io_targetname]) [message]")
#endif



/obj/effect/map_entity/ex_act()
    return FALSE

/obj/effect/map_entity/blocks_airlock()
    return FALSE


/obj/effect/map_entity/Initialize()
	. = ..()
	if(!MAP_ENTITY_DEBUG && !is_type_in_list(src, list(/obj/effect/map_entity/weather_mask, /obj/effect/map_entity/fire_pit)))
		invisibility = 101
	if(io_targetname)
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
	if(io_targetname)
		unregister_entity()
	if(brush_neighbors)
		for(var/obj/effect/map_entity/E in brush_neighbors)
			LAZYREMOVE(E.brush_neighbors, src)
		brush_neighbors = null
	return ..()

/obj/effect/map_entity/proc/register_entity()
	var/key = lowertext(io_targetname)
	LAZYINITLIST(GLOB.map_entities_by_name[key])
	GLOB.map_entities_by_name[key] += src

/obj/effect/map_entity/proc/unregister_entity()
	var/key = lowertext(io_targetname)
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
	var/list/source_connections = list()
	if(io_connections)
		source_connections += io_connections

	if(io_connections_string)
		var/list/string_conns = splittext(io_connections_string, ";")
		for(var/s in string_conns)
			if(s)
				source_connections += s

	io_connections = list()
	if(!length(source_connections))
		return

	for(var/conn in source_connections)
		if(isnull(conn))
			continue

		if(istext(conn))
			var/list/parts = splittext(conn, ":")
			if(length(parts) >= 3)
				var/output_name = parts[1]
				var/target_name = parts[2]
				var/input_name = parts[3]
				var/delay = length(parts) >= 4 ? text2num(parts[4]) : 0
				var/param = length(parts) >= 5 ? parts[5] : null
				LAZYINITLIST(io_connections[output_name])
				io_connections[output_name] += list(list(
					"target" = target_name,
					"input" = input_name,
					"delay" = delay,
					"param" = param
				))
		else if(islist(conn))
			var/list/C = conn
			var/output_name = C["output"]
			if(output_name)
				LAZYINITLIST(io_connections[output_name])
				io_connections[output_name] += list(list(
					"target" = C["target"],
					"input" = C["input"],
					"delay" = C["delay"] || 0,
					"param" = C["param"]
				))

/obj/effect/map_entity/proc/fire_output(output_name, atom/activator, atom/caller)
	if(!enabled || !io_connections?[output_name])
		return

	for(var/list/conn in io_connections[output_name])
		var/target_name = conn["target"]
		var/input_name = conn["input"]
		var/delay = conn["delay"]
		var/param = conn["param"]
		var/list/params = param ? list("value" = param) : null

		var/list/targets = find_io_targets(target_name)
		debug_flash(MAP_ENTITY_COLOR_OUTPUT)
		debug_log("firing [output_name] -> [target_name]:[input_name] (Targets: [length(targets)])")


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
	if(!enabled || !io_connections?[output_name])
		return

	for(var/list/conn in io_connections[output_name])
		var/target_name = conn["target"]
		var/input_name = conn["input"]
		var/delay = conn["delay"]
		var/param = conn["param"]
		var/list/params = param ? list("value" = param) : null
		var/list/targets = find_io_targets(target_name)
		for(var/atom/target in targets)
			if(delay > 0)
				spawn(delay)
					if(target && !QDELETED(target))
						send_io_input(target, input_name, activator, caller, params)
			else
				send_io_input(target, input_name, activator, caller, params)

/obj/effect/map_entity/proc/receive_input(input_name, atom/activator, atom/caller, list/params)
	if(input_name != "OnSpawn")
		debug_flash(MAP_ENTITY_COLOR_INPUT)
		debug_log("received input: [input_name] from [caller]")


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
	LAZYINITLIST(io_connections)
	LAZYINITLIST(io_connections[output_name])
	io_connections[output_name] += list(list(
		"target" = target_name,
		"input" = input_name,
		"delay" = delay
	))

/obj/effect/map_entity/proc/clear_connections(output_name)
	if(io_connections)
		io_connections -= output_name

/obj/effect/map_entity/proc/get_entity_info()
	return "[type] (io_targetname: [io_targetname], enabled: [enabled], brush: [is_brush])"
