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
	. = ..()
	if(template)
		message_admins("Picked warfare template: [template.name] ([template.type])")


/datum/map_template/ruin/warfare_mid
	prefix = "maps/random_mid/"
	/// Example: "CITY" "OPERATION" "SIEGE" etc whatever just so it fits the theme decided by war_lore
	var/category = "" // Unused for now
	description = "REDACTED"
	var/spawn_weight = 1

/datum/map_template/ruin/warfare_mid/classic
	name = "Classic Fare"
	id = "classic_fare"
	description = "The classic experience."
	suffixes = list("classicfare.dmm")
	category = "PLACE"
	spawn_weight = 2

/datum/map_template/ruin/warfare_mid/bunkerfare
	name = "Bunker Fare"
	id = "bunker_fare"
	description = "The mid-bunker experience."
	suffixes = list("bunkerfare.dmm")
	category = "PLACE"
	spawn_weight = 1
