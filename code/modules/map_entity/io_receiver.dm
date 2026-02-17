


GLOBAL_LIST_EMPTY(io_objects_by_name)  

/atom/movable
	var/io_targetname = ""
	var/list/io_connections = null
	var/io_connections_string = ""
	var/list/io_parsed_connections = null

/atom/movable/Initialize()
	. = ..()
	if(istype(src, /obj/effect/map_entity))
		return .
	if(io_targetname)
		IO_register()
	if((io_connections && length(io_connections)) || io_connections_string)
		IO_parse_connections()

/atom/movable/Destroy()
	if(istype(src, /obj/effect/map_entity))
		return ..()
	IO_unregister()
	return ..()


/atom/movable/proc/IO_register()
	if(!io_targetname)
		return
	var/key = lowertext(io_targetname)
	LAZYINITLIST(GLOB.io_objects_by_name[key])
	GLOB.io_objects_by_name[key] += src


/atom/movable/proc/IO_unregister()
	if(!io_targetname)
		return
	var/key = lowertext(io_targetname)
	if(GLOB.io_objects_by_name[key])
		GLOB.io_objects_by_name[key] -= src
		if(!length(GLOB.io_objects_by_name[key]))
			GLOB.io_objects_by_name -= key


/atom/movable/proc/IO_parse_connections()
	var/list/source_connections = list()
	if(io_connections)
		source_connections += io_connections

	if(io_connections_string)
		var/list/string_conns = splittext(io_connections_string, ";")
		for(var/s in string_conns)
			if(s)
				source_connections += s

	io_parsed_connections = list()
	if(!length(source_connections))
		return

	for(var/conn in source_connections)
		if(isnull(conn))
			continue

		if(istext(conn))
			var/list/parts = splittext(conn, ":")
			if(length(parts) >= 3)
				var/output_name = parts[1]
				var/target = parts[2]
				var/input = parts[3]
				var/delay = length(parts) >= 4 ? text2num(parts[4]) : 0
				var/param = length(parts) >= 5 ? parts[5] : null
				LAZYINITLIST(io_parsed_connections[output_name])
				io_parsed_connections[output_name] += list(list(
					"target" = target,
					"input" = input,
					"delay" = delay,
					"param" = param
				))
		else if(islist(conn))
			var/list/C = conn
			var/output_name = C["output"]
			if(output_name)
				LAZYINITLIST(io_parsed_connections[output_name])
				io_parsed_connections[output_name] += list(list(
					"target" = C["target"],
					"input" = C["input"],
					"delay" = C["delay"] || 0,
					"param" = C["param"]
				))


/atom/movable/proc/IO_receive_input(input_name, atom/activator, atom/caller, list/params)
	return FALSE

/atom/movable/proc/IO_fire_output(output_name, atom/activator)
	if(!io_parsed_connections || !io_parsed_connections[output_name])
		return

	for(var/list/conn in io_parsed_connections[output_name])
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
						send_io_input(target, input_name, activator, src, params)
			else
				send_io_input(target, input_name, activator, src, params)


/proc/send_io_input(atom/target, input_name, atom/activator, atom/caller, list/params)
	if(istype(target, /obj/effect/map_entity))
		var/obj/effect/map_entity/ME = target
		ME.receive_input(input_name, activator, caller, params)
	else if(istype(target, /atom/movable))
		var/atom/movable/O = target
		O.IO_receive_input(input_name, activator, caller, params)


/proc/find_io_targets(target_name)
	if(!target_name)
		return list()

	var/key = lowertext(target_name)
	var/list/results = list()

	
	if(GLOB.map_entities_by_name[key])
		results += GLOB.map_entities_by_name[key]

	
	if(GLOB.io_objects_by_name[key])
		results += GLOB.io_objects_by_name[key]

	return results



/proc/IO_output(connection_string, atom/activator, atom/caller)
	var/list/parts = splittext(connection_string, ":")
	if(length(parts) < 2)
		return FALSE

	var/target_name = parts[1]
	var/input_name = parts[2]
	var/param = length(parts) >= 3 ? parts[3] : null
	var/list/params = param ? list("value" = param) : null

	var/list/targets = find_io_targets(target_name)
	for(var/target in targets)
		if(istype(target, /obj/effect/map_entity))
			var/obj/effect/map_entity/ME = target
			ME.receive_input(input_name, activator, caller, params)
		else if(istype(target, /atom/movable))
			var/atom/movable/O = target
			O.IO_receive_input(input_name, activator, caller, params)

	return TRUE
