/datum/snowflake_supply
	var/name = null /// Self explanatory
	var/price = null /// FREE IF NULL. Ditto.
	var/description = ""
	var/category = null /// Sorts us. Ditto.
	var/container = null /// container to the container we're spawned in. Ditto.
	var/list/willcontain = null /// List of stuff we'll spawn with. Ditto.

/datum/snowflake_supply/New()
	. = ..()

/datum/snowflake_supply/proc/Spawn(loc)
	var/obj/C = new container (null) //nullspace this mf rq
	C.name = name
	create_objects_in_loc(C, willcontain)
	C.forceMove(loc) // could be better

/datum/snowflake_supply/rifle_ammo_pack
	name = "Rifle Ammo Pack"
	description = "Standard-issue rifle ammo crates. Keeps your frontline firing."
	price = 50
	category = "Ammunition"
	container = /obj/structure/closet/crate/wooden
	willcontain = list(/obj/item/ammo_box/rifle = 10)

/datum/snowflake_supply/shotgun_ammo_pack
	name = "Shotgun Ammo Pack"
	description = "Packed to the brim. For doors, trenches, and everything in-between."
	price = 100
	category = "Ammunition"
	container = /obj/structure/closet/crate/wooden
	willcontain = list(/obj/item/ammo_box/shotgun = 10)

/datum/snowflake_supply/pistol_ammo_pack
	name = "Pistol Ammo Pack"
	description = "Sidearm ammunition for officers and backups. Never be caught empty."
	price = 50
	category = "Ammunition"
	container = /obj/structure/closet/crate/wooden
	willcontain = list(/obj/item/ammo_magazine/c45m/warfare = 10, /obj/item/ammo_magazine/a50 = 5)

/datum/snowflake_supply/revolver_ammo_pack
	name = "Revolver Ammo Pack"
	description = "For those clinging to the classics. Reliable power, one bullet at a time."
	price = 50
	category = "Ammunition"
	container = /obj/structure/closet/crate/wooden
	willcontain = list(/obj/item/ammo_magazine/handful/revolver = 10)

/datum/snowflake_supply/soulburn_ammo_pack
	name = "Soulburn Ammo Pack"
	description = "Spray-and-pray mags for the soulburn. Keep shooting, they'll stop eventually."
	price = 50
	category = "Ammunition"
	container = /obj/structure/closet/crate/wooden
	willcontain = list(/obj/item/ammo_magazine/mc9mmt/machinepistol = 10)

/datum/snowflake_supply/hmg_ammo_pack
	name = "HMG Ammo Pack"
	description = "Belted brass for heavy iron. When the lead must fly, make it a BrassCo sky."
	price = 100
	category = "Ammunition"
	container = /obj/structure/closet/crate/wooden
	willcontain = list(/obj/item/ammo_magazine/box/a556/mg08 = 5)

/datum/snowflake_supply/warmonger_ammo
	name = "Warmonger Ammo"
	description = "Hardy, high-pressure Warmonger rounds. Accuracy in the first shot, devastation in the rest."
	price = 50
	category = "Ammunition"
	container = /obj/structure/closet/crate/wooden
	willcontain = list(/obj/item/ammo_magazine/c45rifle/akarabiner = 10)

/datum/snowflake_supply/flamethrower_ammo_pack
	name = "Flamethrower Ammo Pack"
	description = "Liquid inferno, bottled and sealed. Just add a spark."
	price = 100
	category = "Ammunition"
	container = /obj/structure/closet/crate/wooden
	willcontain = list(/obj/item/ammo_magazine/flamer = 5)

/datum/snowflake_supply/ptsd_ammo_pack
	name = "PTSD Ammo Pack"
	description = "It's not going to end, is it?"
	price = 100
	category = "Ammunition"
	container = /obj/structure/closet/crate/wooden
	willcontain = list(/obj/item/ammo_box/ptsd = 5)

/datum/snowflake_supply/mortar_ammo
	name = "Mortar Ammo"
	description = "Kaboom!"
	price = 100
	category = "Ammunition"
	container = /obj/structure/closet/crate/wooden
	willcontain = list(/obj/item/mortar_shell = 8)

/datum/snowflake_supply/shotgun_pack
	name = "Shotgun Pack"
	description = "Pump-action room clearers."
	price = 100
	category = "Weaponry"
	container = /obj/structure/closet/crate/wooden
	willcontain = list(/obj/item/gun/projectile/shotgun/pump/shitty = 5)

/datum/snowflake_supply/pistol_pack
	name = "Pistol Pack"
	description = "Not glamorous, but necessary."
	price = 100
	category = "Weaponry"
	container = /obj/structure/closet/crate/wooden
	willcontain = list(/obj/item/gun/projectile/golt = 2, /obj/item/gun/projectile/warfare = 3)

/datum/snowflake_supply/harbinger_pack
	name = "Harbinger Pack"
	description = "You ever want to.. yknow.. shoot a scav in the head?"
	price = 100
	category = "Weaponry"
	container = /obj/structure/closet/crate/wooden
	willcontain = list(/obj/item/gun/projectile/automatic/mg08 = 2)

/datum/snowflake_supply/warmonger_pack
	name = "Warmonger Pack"
	description = "The Warmonger is loud, automatic, and distressingly effective. This is a lot of them."
	price = 100
	category = "Weaponry"
	container = /obj/structure/closet/crate/wooden
	willcontain = list(/obj/item/gun/projectile/automatic/m22/warmonger = 10)

/datum/snowflake_supply/shovel_pack
	name = "Shovel Pack"
	description = "Dig trenches, bash skulls. Multi-purpose and underrated."
	price = 50
	category = "Weaponry"
	container = /obj/structure/closet/crate/wooden
	willcontain = list(/obj/item/shovel = 5)

/datum/snowflake_supply/doublebarrel_shotgun_pack
	name = "Doublebarrel Shotgun Pack"
	description = "Two barrels, one message."
	price = 100
	category = "Weaponry"
	container = /obj/structure/closet/crate/wooden
	willcontain = list(/obj/item/gun/projectile/shotgun/doublebarrel = 5)

/datum/snowflake_supply/bolt_action_rifle_pack
	name = "Bolt Action Rifle Pack"
	description = "They still work.. mostly."
	price = 50
	category = "Weaponry"
	container = /obj/structure/closet/crate/wooden
	willcontain = list(/obj/item/gun/projectile/shotgun/pump/boltaction/shitty/leverchester = 10)

/datum/snowflake_supply/soulburn_pack
	name = "Soulburn Pack"
	description = "Loud, light, and lethal in tight spaces."
	price = 100
	category = "Weaponry"
	container = /obj/structure/closet/crate/wooden
	willcontain = list(/obj/item/gun/projectile/automatic/machinepistol/wooden = 5)

/datum/snowflake_supply/flamethrower_pack
	name = "Flamethrower Pack"
	description = "One flamethrower, two tanks of fuel. Watch the world burn."
	price = 200
	category = "Weaponry"
	container = /obj/structure/closet/crate/wooden
	willcontain = list(/obj/item/gun/projectile/automatic/flamer = 1, /obj/item/ammo_magazine/flamer = 2)

/datum/snowflake_supply/frag_grenade_pack
	name = "Frag Grenade Pack"
	description = "Five fragmentation grenades. Pull pins, toss, forget."
	price = 350
	category = "Weaponry"
	container = /obj/structure/closet/crate/wooden
	willcontain = list(/obj/item/grenade/frag/warfare = 5)

/datum/snowflake_supply/trench_club_pack
	name = "Trench Club Pack"
	description = "Spiked, weighted, and personal. Paint a message in the mud with their remains."
	price = 100
	category = "Weaponry"
	container = /obj/structure/closet/crate/wooden
	willcontain = list(/obj/item/melee/classic_baton/trench_club = 5)

/datum/snowflake_supply/mortar_pack
	name = "Mortar Pack"
	description = "Two field mortars and six shells.\nKaboom."
	price = 800
	category = "Weaponry"
	container = /obj/structure/closet/crate/wooden
	willcontain = list(/obj/item/mortar_launcher = 2, /obj/item/mortar_shell = 6)

/datum/snowflake_supply/gas_mask_pack
	name = "Gas Mask Pack"
	description = "When will the war end?"
	price = 50
	category = "Miscellaneous"
	container = /obj/structure/closet/crate/wooden
	willcontain = list(/obj/item/clothing/mask/gas/sniper/penal1 = 10)

/datum/snowflake_supply/barbwire_pack
	name = "Barbwire Pack"
	description = "Hold the line with five coils of our ‘Ripper-Grade’ tactical wire. Because walking into barbs should hurt like it means it."
	price = 50
	category = "Miscellaneous"
	container = /obj/structure/closet/crate/wooden
	willcontain = list(/obj/item/stack/barbwire = 5)

/datum/snowflake_supply/canned_food_pack
	name = "Canned Food Pack"
	description = "Spann & Co. proudly delivers ten tins of battlefield chow.\n No bones, few teeth, all calories."
	price = 20
	category = "Miscellaneous"
	container = /obj/structure/closet/crate/wooden
	willcontain = list(/obj/random/canned_food/red = 10)

/datum/snowflake_supply/bodybag_pack
	name = "Bodybag Pack"
	description = "Planning ahead? Three boxes of triple-seal bodybags to keep things tidy when war doesn’t."
	price = 5
	category = "Miscellaneous"
	container = /obj/structure/closet/crate/wooden
	willcontain = list(/obj/item/storage/box/bodybags = 3)

/datum/snowflake_supply/cigarette_pack
	name = "Cigarette Pack"
	description = "Spann & Co. brings the smokes. Ten packs of comfort for lungs that already gave up."
	price = 50
	category = "Miscellaneous"
	container = /obj/structure/closet/crate/wooden
	willcontain = list(/obj/item/storage/fancy/cigarettes = 10)

/datum/snowflake_supply/first_aid_pack
	name = "First Aid Pack"
	description = "Five kits for battlefield fixes. \nProvided to you by Daisy Beakson's Remedies"
	price = 100
	category = "Miscellaneous"
	container = /obj/structure/closet/crate/wooden
	willcontain = list(/obj/item/storage/firstaid/regular = 5)

/datum/snowflake_supply/advanced_first_aid_pack
	name = "Advanced First Aid Pack"
	description = "Five PREMIUM kits for battlefield fixes. \nProvided to you by Daisy Beakson's Remedies"
	price = 200
	category = "Miscellaneous"
	container = /obj/structure/closet/crate/wooden
	willcontain = list(/obj/item/storage/firstaid/adv = 5)

/datum/snowflake_supply/medical_belt_pack
	name = "Medical Belt Pack"
	description = "Ten fully-stocked belts. \nProvided to you by Daisy Beakson's Remedies!"
	price = 50
	category = "Miscellaneous"
	container = /obj/structure/closet/crate/wooden
	willcontain = list(/obj/item/storage/belt/medical/full = 10)

/datum/snowflake_supply/booze_pack
	name = "Booze Pack"
	description = "A crate of booze, sourced from quieter provinces around the backlines. Drink to forget, drink to remember, drink because there’s nothing else."
	price = 100
	category = "Miscellaneous"
	container = /obj/structure/closet/crate/wooden
	willcontain = list(/obj/random/drinkbottle = 8)

/datum/snowflake_supply/atepoine_pack
	name = "Atepoine Pack"
	description = "Ten injectors for when your patient says 'I'm fine' while missing a lung and a heartbeat."
	price = 50
	category = "Miscellaneous"
	container = /obj/structure/closet/crate/wooden
	willcontain = list(/obj/item/reagent_containers/hypospray/autoinjector/revive = 10)

/datum/snowflake_supply/blood_injector_pack
	name = "Blood Injector Pack"
	description = "My blood- Noo!"
	price = 50
	category = "Miscellaneous"
	container = /obj/structure/closet/crate/wooden
	willcontain = list(/obj/item/reagent_containers/hypospray/autoinjector/blood = 10)

/datum/snowflake_supply/smoke_grenade_pack
	name = "Smoke Grenade Pack"
	description = "Do NOT use these in small not-so-open spaces."
	price = 150
	category = "Miscellaneous"
	container = /obj/structure/closet/crate/wooden
	willcontain = list(/obj/item/grenade/smokebomb = 5)

/datum/snowflake_supply/illumination_mortar_red
	name = "Illumination Mortar Ammo (Red)"
	description = "Light up the sky!"
	price = 300
	category = "Ammunition"
	container = /obj/structure/closet/crate/wooden
	willcontain = list(/obj/item/mortar_shell/flare = 8)

/datum/snowflake_supply/illumination_mortar_blue
	name = "Illumination Mortar Ammo - Blue"
	description = "Light up the sky!"
	price = 300
	category = "Ammunition"
	container = /obj/structure/closet/crate/wooden
	willcontain = list(/obj/item/mortar_shell/flare/blue = 8)


/// REINFORCEMENTS ///

/datum/snowflake_supply/reinforcements
	name = "Reinforcements"
	description = "More bodies for the front."
	price = 500
	category = "Units"
	var/team = null
	container = null

/datum/snowflake_supply/reinforcements/Spawn(loc)
	SSwarfare.blue.left += 5

/datum/snowflake_supply/reinforcements/red
	team = RED_TEAM

/datum/snowflake_supply/reinforcements/red/Spawn(loc)
	SSwarfare.red.left += 5

/datum/snowflake_supply/reinforcements/blue
	team = BLUE_TEAM

/datum/snowflake_supply/reinforcements/blue/Spawn(loc)
	SSwarfare.blue.left += 5

// job datums

/datum/snowflake_supply/job/
	var/datum/job/job_type /// The job type that we'll be opening up or changing.
	var/amount /// amount of slots to open for the 'job_type'

/datum/snowflake_supply/job/unit_blue_sniper
	name = "Blue Sniper Unit"
	description = "Long-range elimination specialists. One shot, one ghost."
	price = 500
	category = "Units"
	job_type = /datum/job/soldier/blue_soldier/sniper

/datum/snowflake_supply/job/unit_blue_flametrooper
	name = "Blue Flame Trooper Unit"
	description = "Fuel, fire, fury."
	price = 1000
	category = "Units"
	job_type = /datum/job/soldier/blue_soldier/flame_trooper

/datum/snowflake_supply/job/unit_blue_sentry
	name = "Blue Sentry Unit"
	description = "Static defense with heavy firepower. Let them come."
	price = 750
	category = "Units"
	job_type = /datum/job/soldier/blue_soldier/sentry


/datum/snowflake_supply/job/Spawn(loc)
	var/datum/job/team_job = SSjobs.GetJobByType(job_type) //Open up the corresponding job on that team.
	SSjobs.allow_one_more(team_job.title)


/datum/snowflake_supply/job/unit_red_sniper
	name = "Red Sniper Unit"
	description = "Long-range elimination specialists. One shot, one ghost."
	price = 500
	category = "Units"
	job_type = /datum/job/soldier/red_soldier/sniper

/datum/snowflake_supply/job/unit_red_flametrooper
	name = "Red Flame Trooper Unit"
	description = "Fuel, fire, fury."
	price = 1000
	category = "Units"
	job_type = /datum/job/soldier/red_soldier/flame_trooper

/datum/snowflake_supply/job/unit_red_sentry
	name = "Red Sentry Unit"
	description = "Static defense with heavy firepower. Let them come."
	price = 750
	category = "Units"
	job_type = /datum/job/soldier/red_soldier/sentry

/datum/snowflake_supply/artillery