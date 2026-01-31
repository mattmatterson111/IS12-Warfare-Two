/proc/ghostclip_blocks_los(turf/source, turf/target)
	if(!source || !target)
		return FALSE

	var/list/line_turfs = getline(source, target)
	for(var/turf/T in line_turfs)
		for(var/obj/O in T)
			if(O.atom_flags & ATOM_FLAG_GHOSTCLIP)
				return TRUE
	return FALSE

/proc/ghost_can_reach(mob/observer/ghost/G, atom/target)
	if(!G || !target)
		return FALSE

	if(G.client?.holder)
		return TRUE

	var/turf/ghost_turf = get_turf(G)
	var/turf/target_turf = get_turf(target)

	if(!ghost_turf || !target_turf)
		return FALSE

	for(var/obj/O in target_turf)
		if(O.atom_flags & ATOM_FLAG_GHOSTCLIP)
			return FALSE

	if(ghostclip_blocks_los(ghost_turf, target_turf))
		return FALSE

	return TRUE
