/decl/turf_initializer/proc/InitializeTurf(var/turf/T)
	return

/area
	var/turf_initializer = null

/area/Initialize()
	. = ..()

	if(!turf_initializer)
		return

	// This is temporary till I figure out a better way
	if(turf_initializer == /decl/turf_initializer/warfare || turf_initializer == /decl/turf_initializer/warfare_flora_only || turf_initializer == /decl/turf_initializer/oldfare)
		return

	var/decl/turf_initializer/ti = decls_repository.get_decl(turf_initializer)
	if(!ti)
		return

	for(var/turf/T in src)
		ti.InitializeTurf(T)

/decl/turf_initializer/unexplored/InitializeTurf(var/turf/simulated/T)
	if(T.density)
		return

	//if(prob(1))
	//	new /obj/random/mining_hostile(T)

	else if(prob(10))
		new /obj/structure/flora/rocks(T)


/decl/turf_initializer/warfare/InitializeTurf(var/turf/simulated/T)

	if(T.density)
		return

	if(istype(T, /turf/simulated/floor/trench)  || istype(T, /turf/simulated/floor/exoplanet/water/shallow))
		return

	if(!istype(T, /turf/simulated/floor/dirty))
		return

	var/blocked_by_structure = FALSE
	for(var/obj/structure/object in T)
		if(object)
			blocked_by_structure = TRUE
			break

	if(!blocked_by_structure)
		var/list/profile
		if(GLOB.war_lore)
			profile = GLOB.war_lore.get_flora_profile()
		if(!islist(profile) && GLOB.war_lore && islist(GLOB.war_lore.flora_profiles))
			profile = GLOB.war_lore.flora_profiles["classic"]

		var/list/flora_spawns
		if(islist(profile))
			flora_spawns = profile["flora_spawns"]
		if(islist(flora_spawns))
			var/list/successful_spawns = list()
			for(var/flora_type in flora_spawns)
				if(!ispath(flora_type, /obj))
					continue

				var/spawn_chance = flora_spawns[flora_type]
				if(!isnum(spawn_chance))
					continue

				if(prob(spawn_chance))
					successful_spawns += flora_type

			if(LAZYLEN(successful_spawns))
				var/chosen_type = pick(successful_spawns)
				if(ispath(chosen_type, /obj))
					new chosen_type(T)

	if(prob(1))
		for(var/obj/structure/object in T.contents)
			if(object)
				return
		new /obj/structure/landmine(T)
	//else
	//	new /obj/structure/flora/grass/both(T)


/decl/turf_initializer/warfare_flora_only/InitializeTurf(var/turf/simulated/T)
	if(T.density)
		return

	if(istype(T, /turf/simulated/floor/trench) || istype(T, /turf/simulated/floor/exoplanet/water/shallow))
		return

	if(!istype(T, /turf/simulated/floor/dirty))
		return

	var/blocked_by_structure = FALSE
	for(var/obj/structure/object in T)
		if(object)
			blocked_by_structure = TRUE
			break

	if(!blocked_by_structure)
		var/list/profile
		if(GLOB.war_lore)
			profile = GLOB.war_lore.get_flora_profile()
		if(!islist(profile) && GLOB.war_lore && islist(GLOB.war_lore.flora_profiles))
			profile = GLOB.war_lore.flora_profiles["classic"]

		var/list/flora_spawns
		if(islist(profile))
			flora_spawns = profile["flora_spawns"]
		if(islist(flora_spawns))
			var/list/successful_spawns = list()
			for(var/flora_type in flora_spawns)
				if(!ispath(flora_type, /obj))
					continue

				var/spawn_chance = flora_spawns[flora_type]
				if(!isnum(spawn_chance))
					continue

				if(prob(spawn_chance))
					successful_spawns += flora_type

			if(LAZYLEN(successful_spawns))
				var/chosen_type = pick(successful_spawns)
				if(ispath(chosen_type, /obj))
					new chosen_type(T)




/decl/turf_initializer/oldfare/InitializeTurf(var/turf/simulated/T)
	if(T.density)
		return

	if(istype(T, /turf/simulated/floor/trench)  || istype(T, /turf/simulated/floor/exoplanet/water/shallow) || istype(T, /turf/simulated/open))
		return

	var/blocked_by_structure = FALSE
	for(var/obj/structure/object in T)
		if(object)
			blocked_by_structure = TRUE
			break

	if(!blocked_by_structure)
		var/list/profile
		if(GLOB.war_lore)
			profile = GLOB.war_lore.get_flora_profile()
		if(!islist(profile) && GLOB.war_lore && islist(GLOB.war_lore.flora_profiles))
			profile = GLOB.war_lore.flora_profiles["classic"]

		var/list/flora_spawns
		if(islist(profile))
			flora_spawns = profile["flora_spawns"]
		if(islist(flora_spawns))
			var/list/successful_spawns = list()
			for(var/flora_type in flora_spawns)
				if(!ispath(flora_type, /obj))
					continue

				var/spawn_chance = flora_spawns[flora_type]
				if(!isnum(spawn_chance))
					continue

				if(prob(spawn_chance))
					successful_spawns += flora_type

			if(LAZYLEN(successful_spawns))
				var/chosen_type = pick(successful_spawns)
				if(ispath(chosen_type, /obj))
					new chosen_type(T)

	//if(prob(1)) //Rats are lagging I'm pretty sure.
	//	new /mob/living/simple_animal/hostile/retaliate/rat(T)

	//else if(prob(10))
	//	new /obj/structure/flora/ash(T)

	if(prob(12))
		new /obj/structure/barbwire(T)

	else if(prob(5))
		var/blocked = FALSE
		for(var/obj/structure/track/S in T)
			blocked = TRUE
		if(!blocked)
			new /obj/structure/anti_tank(T)

	else if(prob(5))//Please no landmines under dirt mounds thank you.
		// please no landmines on fucking water thank you
		for(var/obj/structure/object in T.contents)
			if(object)
				return
		if(istype(T,/turf/simulated/floor/exoplanet/water/shallow))
			return
		new /obj/structure/landmine(T)
