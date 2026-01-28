/decl/turf_initializer/proc/InitializeTurf(var/turf/T)
	return

/area
	var/turf_initializer = null

/area/Initialize()
	. = ..()
	for(var/turf/T in src)
		if(turf_initializer)
			var/decl/turf_initializer/ti = decls_repository.get_decl(turf_initializer)
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

	else if(prob(10))
		new /obj/structure/flora/tree/dead(T)

	else if(prob(15))
		new /obj/structure/flora/grass/both(T)

	else if(prob(10))
		new /obj/structure/flora/grass/brown(T)

	else if(prob(5))
		new /obj/structure/flora/log(T)

	else if(prob(30))
		new /obj/structure/flora/rocks(T)

	else if(prob(1))
		for(var/obj/structure/object in T.contents)
			if(object)
				return
		new /obj/structure/landmine(T)
	//else
	//	new /obj/structure/flora/grass/both(T)




/decl/turf_initializer/oldfare/InitializeTurf(var/turf/simulated/T)
	if(T.density)
		return

	if(istype(T, /turf/simulated/floor/trench)  || istype(T, /turf/simulated/floor/exoplanet/water/shallow) || istype(T, /turf/simulated/open))
		return

	//if(prob(1)) //Rats are lagging I'm pretty sure.
	//	new /mob/living/simple_animal/hostile/retaliate/rat(T)

	//else if(prob(10))
	//	new /obj/structure/flora/ash(T)

	else if(prob(12))
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