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
	price = 50
	category = "Ammunition"
	container = /obj/structure/closet/crate/wooden
	willcontain = list(/obj/item/ammo_box/rifle = 10)

/datum/snowflake_supply/shotgun_ammo_pack
	name = "Shotgun Ammo Pack"
	price = 100
	category = "Ammunition"
	container = /obj/structure/closet/crate/wooden
	willcontain = list(/obj/item/ammo_box/shotgun = 10)

/datum/snowflake_supply/pistol_ammo_pack
	name = "Pistol Ammo Pack"
	price = 50
	category = "Ammunition"
	container = /obj/structure/closet/crate/wooden
	willcontain = list(/obj/item/ammo_magazine/c45m/warfare = 10, /obj/item/ammo_magazine/a50 = 5)

/datum/snowflake_supply/revolver_ammo_pack
	name = "Revolver Ammo Pack"
	price = 50
	category = "Ammunition"
	container = /obj/structure/closet/crate/wooden
	willcontain = list(/obj/item/ammo_magazine/handful/revolver = 10)

/datum/snowflake_supply/soulburn_ammo_pack
	name = "Soulburn Ammo Pack"
	price = 50
	category = "Ammunition"
	container = /obj/structure/closet/crate/wooden
	willcontain = list(/obj/item/ammo_magazine/mc9mmt/machinepistol = 10)

/datum/snowflake_supply/hmg_ammo_pack
	name = "HMG Ammo Pack"
	price = 100
	category = "Ammunition"
	container = /obj/structure/closet/crate/wooden
	willcontain = list(/obj/item/ammo_magazine/box/a556/mg08 = 5)

/datum/snowflake_supply/warmonger_ammo
	name = "Warmonger Ammo"
	price = 50
	category = "Ammunition"
	container = /obj/structure/closet/crate/wooden
	willcontain = list(/obj/item/ammo_magazine/c45rifle/akarabiner = 10)

/datum/snowflake_supply/flamethrower_ammo_pack
	name = "Flamethrower Ammo Pack"
	price = 100
	category = "Ammunition"
	container = /obj/structure/closet/crate/wooden
	willcontain = list(/obj/item/ammo_magazine/flamer = 5)

/datum/snowflake_supply/ptsd_ammo_pack
	name = "PTSD Ammo Pack"
	price = 100
	category = "Ammunition"
	container = /obj/structure/closet/crate/wooden
	willcontain = list(/obj/item/ammo_box/ptsd = 5)

/datum/snowflake_supply/mortar_ammo
	name = "Mortar Ammo"
	price = 100
	category = "Ammunition"
	container = /obj/structure/closet/crate/wooden
	willcontain = list(/obj/item/mortar_shell = 8)

/datum/snowflake_supply/shotgun_pack
	name = "Shotgun Pack"
	price = 100
	category = "Weaponry"
	container = /obj/structure/closet/crate/wooden
	willcontain = list(/obj/item/gun/projectile/shotgun/pump/shitty = 5)

/datum/snowflake_supply/pistol_pack
	name = "Pistol Pack"
	price = 100
	category = "Weaponry"
	container = /obj/structure/closet/crate/wooden
	willcontain = list(/obj/item/gun/projectile/golt = 2, /obj/item/gun/projectile/warfare = 3)

/datum/snowflake_supply/harbinger_pack
	name = "Harbinger Pack"
	price = 100
	category = "Weaponry"
	container = /obj/structure/closet/crate/wooden
	willcontain = list(/obj/item/gun/projectile/automatic/mg08 = 2)

/datum/snowflake_supply/warmonger_pack
	name = "Warmonger Pack"
	price = 100
	category = "Weaponry"
	container = /obj/structure/closet/crate/wooden
	willcontain = list(/obj/item/gun/projectile/automatic/m22/warmonger = 10)

/datum/snowflake_supply/shovel_pack
	name = "Shovel Pack"
	price = 50
	category = "Weaponry"
	container = /obj/structure/closet/crate/wooden
	willcontain = list(/obj/item/shovel = 5)

/datum/snowflake_supply/doublebarrel_shotgun_pack
	name = "Doublebarrel Shotgun Pack"
	price = 100
	category = "Weaponry"
	container = /obj/structure/closet/crate/wooden
	willcontain = list(/obj/item/gun/projectile/shotgun/doublebarrel = 5)

/datum/snowflake_supply/bolt_action_rifle_pack
	name = "Bolt Action Rifle Pack"
	price = 50
	category = "Weaponry"
	container = /obj/structure/closet/crate/wooden
	willcontain = list(/obj/item/gun/projectile/shotgun/pump/boltaction/shitty/leverchester = 10)

/datum/snowflake_supply/soulburn_pack
	name = "Soulburn Pack"
	price = 100
	category = "Weaponry"
	container = /obj/structure/closet/crate/wooden
	willcontain = list(/obj/item/gun/projectile/automatic/machinepistol/wooden = 5)

/datum/snowflake_supply/flamethrower_pack
	name = "Flamethrower Pack"
	price = 200
	category = "Weaponry"
	container = /obj/structure/closet/crate/wooden
	willcontain = list(/obj/item/gun/projectile/automatic/flamer = 1, /obj/item/ammo_magazine/flamer = 2)

/datum/snowflake_supply/frag_grenade_pack
	name = "Frag Grenade Pack"
	price = 350
	category = "Weaponry"
	container = /obj/structure/closet/crate/wooden
	willcontain = list(/obj/item/grenade/frag/warfare = 5)

/datum/snowflake_supply/trench_club_pack
	name = "Trench Club Pack"
	price = 100
	category = "Weaponry"
	container = /obj/structure/closet/crate/wooden
	willcontain = list(/obj/item/melee/classic_baton/trench_club = 5)

/datum/snowflake_supply/mortar_pack
	name = "Mortar Pack"
	price = 800
	category = "Weaponry"
	container = /obj/structure/closet/crate/wooden
	willcontain = list(/obj/item/mortar_launcher = 2, /obj/item/mortar_shell = 6)

/datum/snowflake_supply/gas_mask_pack
	name = "Gas Mask Pack"
	price = 50
	category = "Miscellaneous"
	container = /obj/structure/closet/crate/wooden
	willcontain = list(/obj/item/clothing/mask/gas/sniper/penal1 = 10)

/datum/snowflake_supply/barbwire_pack
	name = "Barbwire Pack"
	price = 50
	category = "Miscellaneous"
	container = /obj/structure/closet/crate/wooden
	willcontain = list(/obj/item/stack/barbwire = 5)

/datum/snowflake_supply/canned_food_pack
	name = "Canned Food Pack"
	price = 20
	category = "Miscellaneous"
	container = /obj/structure/closet/crate/wooden
	willcontain = list(/obj/random/canned_food/red = 10)

/datum/snowflake_supply/bodybag_pack
	name = "Bodybag Pack"
	price = 5
	category = "Miscellaneous"
	container = /obj/structure/closet/crate/wooden
	willcontain = list(/obj/item/storage/box/bodybags = 3)

/datum/snowflake_supply/cigarette_pack
	name = "Cigarette Pack"
	price = 50
	category = "Miscellaneous"
	container = /obj/structure/closet/crate/wooden
	willcontain = list(/obj/item/storage/fancy/cigarettes = 10)

/datum/snowflake_supply/first_aid_pack
	name = "First Aid Pack"
	price = 100
	category = "Miscellaneous"
	container = /obj/structure/closet/crate/wooden
	willcontain = list(/obj/item/storage/firstaid/regular = 5)

/datum/snowflake_supply/advanced_first_aid_pack
	name = "Advanced First Aid Pack"
	price = 200
	category = "Miscellaneous"
	container = /obj/structure/closet/crate/wooden
	willcontain = list(/obj/item/storage/firstaid/adv = 5)

/datum/snowflake_supply/medical_belt_pack
	name = "Medical Belt Pack"
	price = 50
	category = "Miscellaneous"
	container = /obj/structure/closet/crate/wooden
	willcontain = list(/obj/item/storage/belt/medical/full = 10)

/datum/snowflake_supply/booze_pack
	name = "Booze Pack"
	description = "Imported from a nearby, untouched province, alongside many other places, this pack of booze is sure to help you relax."
	price = 100
	category = "Miscellaneous"
	container = /obj/structure/closet/crate/wooden
	willcontain = list(/obj/random/drinkbottle = 8)

/datum/snowflake_supply/atepoine_pack
	name = "Atepoine Pack"
	price = 50
	category = "Miscellaneous"
	container = /obj/structure/closet/crate/wooden
	willcontain = list(/obj/item/reagent_containers/hypospray/autoinjector/revive = 10)

/datum/snowflake_supply/blood_injector_pack
	name = "Blood Injector Pack"
	price = 50
	category = "Miscellaneous"
	container = /obj/structure/closet/crate/wooden
	willcontain = list(/obj/item/reagent_containers/hypospray/autoinjector/blood = 10)

/datum/snowflake_supply/smoke_grenade_pack
	name = "Smoke Grenade Pack"
	price = 150
	category = "Miscellaneous"
	container = /obj/structure/closet/crate/wooden
	willcontain = list(/obj/item/grenade/smokebomb = 5)

/datum/snowflake_supply/illumination_mortar_red
	name = "Illumination Mortar Ammo (Red)"
	price = 300
	category = "Ammunition"
	container = /obj/structure/closet/crate/wooden
	willcontain = list(/obj/item/mortar_shell/flare = 8)

/datum/snowflake_supply/blue_flare_ammo
	name = "Illumination Mortar Ammo - Blue"
	price = 300
	category = "Ammunition"
	container = /obj/structure/closet/crate/wooden
	willcontain = list(/obj/item/mortar_shell/flare/blue = 8)


/// REINFORCEMENTS ///

/datum/snowflake_supply/reinforcements
	name = "Reinforcements"
	price = 750
	category = "Units"
	container = null

/datum/snowflake_supply/reinforcements/red
	name = "Reinforcements"
	price = 750
	category = "Units"
	container = null

/datum/snowflake_supply/reinforcements/blue
	name = "Reinforcements"
	price = 750
	category = "Units"
	container = null

// job datums

/datum/snowflake_supply/job/
	var/datum/job/job_type /// The job type that we'll be opening up or changing.
	var/amount /// amount of slots to open for the 'job_type'

/datum/snowflake_supply/job/unit_blue_sniper
	name = "Blue Sniper Unit"
	price = 500
	category = "Units"
	job_type = /datum/job/soldier/blue_soldier/sniper

/datum/snowflake_supply/job/unit_blue_flametrooper
	name = "Blue Flame Trooper Unit"
	price = 1000
	category = "Units"
	job_type = /datum/job/soldier/blue_soldier/flame_trooper

/datum/snowflake_supply/job/unit_blue_sentry
	name = "Blue Sentry Unit"
	price = 750
	category = "Units"
	job_type = /datum/job/soldier/blue_soldier/sentry



/datum/snowflake_supply/job/unit_red_sniper
	name = "Blue Sniper Unit"
	price = 500
	category = "Units"
	job_type = /datum/job/soldier/red_soldier/sniper

/datum/snowflake_supply/job/unit_red_flametrooper
	name = "Blue Flame Trooper Unit"
	price = 1000
	category = "Units"
	job_type = /datum/job/soldier/red_soldier/flame_trooper

/datum/snowflake_supply/job/unit_red_sentry
	name = "Blue Sentry Unit"
	price = 750
	category = "Units"
	job_type = /datum/job/soldier/red_soldier/sentry

/datum/snowflake_supply/artillery