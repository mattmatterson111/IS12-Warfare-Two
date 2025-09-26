/obj/effect/landmark/squad
	name = "squadmember"

/obj/effect/landmark/squad/leader
	name = "squadleader"

/obj/effect/landmark/squad_locker

/datum/map_template/ruin/ert
	name = "Test ERT"
	id = "test_ert"
	prefix = "maps/ert/"
	description = "The test experience."
	suffixes = list("base.dmm")
	var/list/spawnpoints = list() // Don't need to use a weird for loop
	var/locker_spawns = list() // Don't need to use a weird for loop

/datum/map_template/ruin/ert/init_atoms(list/atoms)
	. = ..()
	for(var/atom/A in atoms)
		if(istype(A, /obj/effect/landmark/squad))
			spawnpoints += A
		if(istype(A, /obj/effect/landmark/squad_locker))
			locker_spawns += A
		else
			continue

/datum/map_template/ruin/ert/base