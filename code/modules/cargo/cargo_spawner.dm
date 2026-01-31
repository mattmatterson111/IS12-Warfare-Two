/obj/effect/map_entity/cargo_spawner
	name = "Cargo Spawner"
	icon = 'icons/obj/old_computers.dmi'
	icon_state = "cargo_pad"
	var/cargopath
	var/list/cargopaths

/obj/effect/map_entity/cargo_spawner/Initialize()
	. = ..()
	
	var/final_path = cargopath
	if(!final_path && length(cargopaths))
		final_path = pick(cargopaths)

	if(!final_path)
		return INITIALIZE_HINT_QDEL

	var/decl/cargo_product/P = decls_repository.get_decl(final_path)
	if(!P)
		return INITIALIZE_HINT_QDEL

	if(istype(P, /decl/cargo_product/job))
		var/datum/job/team_job = SSjobs.GetJobByType(P.job_path)
		if(team_job)
			SSjobs.allow_one_more(team_job.title)
	else
		var/obj/A = new P.crate_type(loc)
		A.desc = "A [P.name] crate."
		A.name = "[P.name] crate"
		if(P.contents)
			create_objects_in_loc(A, P.contents)

	return INITIALIZE_HINT_QDEL

/obj/effect/map_entity/cargo_spawner/random/defend
	cargopaths = list(
		/decl/cargo_product/crate/barbwire_pack,
		/decl/cargo_product/crate/shovel_pack,
		/decl/cargo_product/crate/barrier_pack
	)

/obj/effect/map_entity/cargo_spawner/random/medical
	cargopaths = list(
		/decl/cargo_product/train/combat_medical,
		/decl/cargo_product/crate/firstaid_pack,
		/decl/cargo_product/crate/medbelt_pack
	)

/obj/effect/map_entity/cargo_spawner/random/light_red
	cargopaths = list(
		/decl/cargo_product/crate/lantern_pack,
		/decl/cargo_product/crate/candle_red,
		/decl/cargo_product/crate/flare_hand_red
	)

/obj/effect/map_entity/cargo_spawner/random/light_blue
	cargopaths = list(
		/decl/cargo_product/crate/lantern_pack,
		/decl/cargo_product/crate/candle_blue,
		/decl/cargo_product/crate/flare_hand_blue
	)