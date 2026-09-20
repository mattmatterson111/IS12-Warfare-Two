/decl/turf_initializer/proc/InitializeTurf(var/turf/T)
	return

/decl/turf_initializer/proc/spawn_profile_flora(var/turf/simulated/T)
	if(locate(/obj/structure) in T)
		return

	var/list/profile = GLOB.war_lore?.get_flora_profile()
	if(!islist(profile) && islist(GLOB.war_lore?.flora_profiles))
		profile = GLOB.war_lore.flora_profiles["classic"]

	var/list/flora_spawns = profile?["flora_spawns"]
	if(!islist(flora_spawns))
		return

	var/list/spawn_candidates = list()
	for(var/flora_type in flora_spawns)
		if(ispath(flora_type, /obj) && isnum(flora_spawns[flora_type]) && prob(flora_spawns[flora_type]))
			spawn_candidates += flora_type

	if(LAZYLEN(spawn_candidates))
		var/spawn_type = pick(spawn_candidates)
		new spawn_type(T)

/area
	var/turf_initializer = null

/area/Initialize()
	. = ..()

	if(!turf_initializer)
		return

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

	spawn_profile_flora(T)

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

	spawn_profile_flora(T)




/decl/turf_initializer/oldfare/InitializeTurf(var/turf/simulated/T)
	if(T.density)
		return

	if(istype(T, /turf/simulated/floor/trench)  || istype(T, /turf/simulated/floor/exoplanet/water/shallow) || istype(T, /turf/simulated/open))
		return

	spawn_profile_flora(T)

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

	else if(prob(5))
		// Avoid landmines below existing structures or on shallow water.
		for(var/obj/structure/object in T.contents)
			if(object)
				return
		if(istype(T,/turf/simulated/floor/exoplanet/water/shallow))
			return
		new /obj/structure/landmine(T)