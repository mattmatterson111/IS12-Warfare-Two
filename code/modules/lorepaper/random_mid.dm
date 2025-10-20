/obj/effect/ruin_loader/warfare_mid// EVIL EVIL EVIL EVIL
	icon = 'icons/hammer/source.dmi'
	icon_state = "env_fear"

/obj/effect/ruin_loader/warfare_mid/Initialize()
	var/list/sites_by_spawn_weight = list()
	for (var/site_name in SSmapping.warfare_mid_templates)
		var/datum/map_template/ruin/warfare_mid/site = SSmapping.warfare_mid_templates[site_name]
		sites_by_spawn_weight[site] = site.spawn_weight
	var/datum/map_template/ruin/warfare_mid/picked = pickweight(sites_by_spawn_weight)
	Load(null, picked, is_centered = FALSE)


/obj/effect/ruin_loader/warfare_mid/Load(list/potentialRuins, datum/map_template/template, is_centered = TRUE)
	var/start_timeofday = REALTIMEOFDAY
	. = ..()
	var/time = (REALTIMEOFDAY - start_timeofday) / 10
	message_admins("Loaded warfare mid template: '[template.name]', in: [time] seconds.")

/datum/map_template/ruin/warfare_mid
	prefix = "maps/random_mid/"
	/// Example: "CITY" "OPERATION" "SIEGE" etc whatever just so it fits the theme decided by war_lore
	var/category = "" // Unused for now
	var/spawn_weight = 1

/datum/map_template/ruin/warfare_mid/classic
	name = "Classic Fare"
	id = "classic_fare"
	description = "The classic experience."
	suffixes = list("classicfare.dmm")
	category = "PLACE"
	spawn_weight = 2
/*
/datum/map_template/ruin/warfare_mid/underground
	name = "underfare"
	id = "under_fare"
	description = "The underground experience."
	suffixes = list("underfare.dmm")
	category = "PLACE"
	spawn_weight = 1
*/
/datum/map_template/ruin/warfare_mid/bunker
	name = "Bunker Fare"
	id = "bunker_fare"
	description = "The mid-bunker experience."
	suffixes = list("bunkerfare.dmm")
	category = "PLACE"
	spawn_weight = 1

/datum/map_template/ruin/warfare_mid/trench
	name = "Trench Fare"
	id = "trench_fare"
	description = "The mid-trench experience."
	suffixes = list("trenchfare.dmm")
	category = "PLACE"
	spawn_weight = 1
/* // experiments concluded, underground mid maps = bad
/datum/map_template/ruin/warfare_mid/blitz
	name = "Blitz Fare"
	id = "blitz_fare"
	description = "The under-mid-bunker experience."
	suffixes = list("blitzfare.dmm")
	category = "PLACE"
	spawn_weight = 1
*/

/datum/map_template/ruin/warfare_mid/payload
	name = "Payload Fare"
	id = "payload_fare"
	description = "The payload experience."
	suffixes = list("payloadfare.dmm")
	category = "PLACE"
	spawn_weight = 1
