/datum/job/soldier/blue_soldier
	title = "Blue Soldier"
	outfit_type = /decl/hierarchy/outfit/job/bluesoldier/soldier
	is_blue_team = TRUE
	selection_color = "#60a0ca"
	supervisors = "the president, the chain of command, and the drums of war"
	auto_rifle_skill = 10
	semi_rifle_skill = 9
	sniper_skill = 3
	shotgun_skill = 6
	lmg_skill = 3
	smg_skill = 3
	boltie_skill = 10

	squad_overlay = "rifleman"

	backstories = list(/datum/backstory/translator)

	equip(var/mob/living/carbon/human/H)
		H.warfare_faction = BLUE_TEAM
		..()
		H.add_stats(rand(12,17), rand(10,16), rand(8,12))
		SSwarfare.blue.team += H
		if(can_be_in_squad)
			H.assign_random_squad(BLUE_TEAM)
		H.fully_replace_character_name("Pvt. [H.real_name]")
		H.warfare_language_shit(LANGUAGE_BLUE)
		H.assign_random_quirk()
		if(announced)
			H.say(";Soldier reporting for duty!")

/datum/job/soldier/blue_soldier/sgt
	title = "Blue Squad Leader"
	total_positions = 3
	social_class = SOCIAL_CLASS_MED
	outfit_type = /decl/hierarchy/outfit/job/bluesoldier/sgt
	can_be_in_squad = FALSE //They have snowflake squad bullshit.

	auto_rifle_skill = 10
	semi_rifle_skill = 10
	shotgun_skill = 10
	// open_when_dead = TRUE

	squad_overlay = "PLA"

	announced = FALSE

	equip(var/mob/living/carbon/human/H)
		var/current_name = H.real_name
		..()
		H.verbs += /mob/living/carbon/human/proc/morale_boost
		H.assign_squad_leader(BLUE_TEAM)
		H.fully_replace_character_name("Sgt. [current_name]")
		H.say(";[title] reporting for duty!")



/datum/job/soldier/blue_soldier/medic
	title = "Blue Medic"
	outfit_type = /decl/hierarchy/outfit/job/bluesoldier/medic

	//Skill defines
	medical_skill = 10
	surgery_skill = 10
	engineering_skill = 4
	auto_rifle_skill = 3
	semi_rifle_skill = 10

	squad_overlay = "medic"

	announced = FALSE

	equip(var/mob/living/carbon/human/H)
		var/current_name = H.real_name
		..()
		H.set_trait(new/datum/trait/death_tolerant())
		H.fully_replace_character_name("Medic [current_name]")
		H.say(";Medic reporting for duty!")


/datum/job/soldier/blue_soldier/engineer
	title = "Blue Engineer"
	outfit_type = /decl/hierarchy/outfit/job/bluesoldier/engineer
	engineering_skill = 10
	//auto_rifle_skill = 5
	//semi_rifle_skill = 5
	smg_skill = 10
	shotgun_skill = 10
	//boltie_skill = 5

	squad_overlay = "sapper"

	announced = FALSE

	equip(var/mob/living/carbon/human/H)
		var/current_name = H.real_name
		..()
		H.add_stats(rand(15,17), rand(10,16), rand(12,16))
		H.fully_replace_character_name("Eng. [current_name]")
		H.say(";Engineer reporting for duty!")


/datum/job/soldier/blue_soldier/sniper
	title = "Blue Sniper"
	total_positions = 2
	outfit_type = /decl/hierarchy/outfit/job/bluesoldier/sniper
	auto_rifle_skill = 3
	semi_rifle_skill = 3
	sniper_skill = 10
	shotgun_skill = 3
	lmg_skill = 3
	smg_skill = 3
	close_when_dead = TRUE
	// open_when_dead = TRUE

	announced = FALSE

	equip(var/mob/living/carbon/human/H)
		var/current_name = H.real_name
		..()
		H.fully_replace_character_name("Sniper [current_name]")
		H.say(";Sniper reporting for duty!")

/datum/job/soldier/blue_soldier/flame_trooper
	title = "Blue Flame Trooper"
	total_positions = 0
	outfit_type = /decl/hierarchy/outfit/job/bluesoldier/flamer
	auto_rifle_skill = 8
	semi_rifle_skill = 8
	sniper_skill = 3
	shotgun_skill = 3
	lmg_skill = 3
	smg_skill = 3
	can_be_in_squad = FALSE
	close_when_dead = TRUE

	announced = FALSE

	spawn_in_cryopod = TRUE
	cryopod_id = BLUE_TEAM

	equip(var/mob/living/carbon/human/H)
		var/current_name = H.real_name
		..()
		H.fully_replace_character_name("FT. [current_name]")
		H.add_stats(18, rand(10,16), rand(15,18))
		H.say(";Flame Trooper reporting for duty!")

/datum/job/soldier/blue_soldier/sentry
	title = "Blue Sentry"
	total_positions = 0
	outfit_type = /decl/hierarchy/outfit/job/bluesoldier/sentry
	auto_rifle_skill = 5
	semi_rifle_skill = 5
	sniper_skill = 3
	shotgun_skill = 3
	lmg_skill = 10
	smg_skill = 3
	can_be_in_squad = FALSE
	// open_when_dead = TRUE

	squad_overlay = "heavy_weaponry"

	announced = FALSE

	spawn_in_cryopod = TRUE
	cryopod_id = BLUE_TEAM

	equip(var/mob/living/carbon/human/H)
		var/current_name = H.real_name
		..()
		H.fully_replace_character_name("Sentry [current_name]")
		H.add_stats(18, rand(10,16), rand(15,18))
		H.say(";Sentry reporting for duty!")



/datum/job/soldier/blue_soldier/captain
	title = "Blue Captain"
	total_positions = 1
	req_admin_notify = TRUE
	social_class = SOCIAL_CLASS_HIGH
	outfit_type = /decl/hierarchy/outfit/job/bluesoldier/leader
	can_be_in_squad = FALSE //They're above all the squads.
	sniper_skill = 10
	open_when_dead = TRUE

	announced = FALSE

	backstories = list(/datum/backstory/nepotismcaptain, /datum/backstory/childcaptain)

	equip(var/mob/living/carbon/human/H)
		var/current_name = H.real_name
		..()
		//add a medal
		var/obj/item/clothing/suit/armor/bluecoat/RC = H.get_equipped_item(slot_wear_suit)
		var/obj/item/clothing/accessory/medal/blue/captain/order1/M = new(H)
		RC.attach_accessory(H, M, TRUE)

		H.fully_replace_character_name("Cpt. [current_name]")
		H.get_idcard()?.access = get_all_accesses()
		var/obj/O = H.get_equipped_item(slot_s_store)
		if(O)
			qdel(O)
		H.verbs += list(
			/mob/living/carbon/human/proc/help_me,
			/mob/living/carbon/human/proc/retreat,
			/mob/living/carbon/human/proc/announce,
			/mob/living/carbon/human/proc/give_order,
			/mob/living/carbon/human/proc/check_reinforcements
		)
		H.voice_in_head(pick(GLOB.lone_thoughts))
		to_chat(H, "<b>Artillery Password</b>: [GLOB.cargo_password]")
		H.mind.store_memory("<b>Artillery Password</b>: [GLOB.cargo_password]")
		for(var/obj/structure/phone/phone in GLOB.phone_list)
			if(phone.phonename == RED_TEAM)
				to_chat(H, "<b>Enemy captain's phone number</b>: [phone.fullphonenumber]")
				H.mind.store_memory("<b>Enemy captain's phone number</b>: [phone.fullphonenumber]")
		/*
		for(var/obj/structure/phone/phone in GLOB.phone_list)
			if(phone.phonename == "BLUE COMMAND")
				to_chat(H, "<b>Blusnian High Command's Number</b>: [phone.fullphonenumber]")
				H.mind.store_memory("<b>Blusnian High Command's Number</b>: [phone.fullphonenumber]")
		*/ // Dont call twice, and we no longer give them high command
		H.say(";[H.real_name] [pick("taking","in")] command!")
		H.add_language(LANGUAGE_DIPLOMATIC)
		to_chat(H,SPAN_NOTICE("You are fluent in <u>Diplomatic Standard</u>, allowing you to communicate with the opposing captain. <b>Check the language tab for more details.</b>"))

/datum/job/soldier/blue_soldier/scout
	title = "Blue Scavenger"
	total_positions = -1
	outfit_type = /decl/hierarchy/outfit/job/bluesoldier/scout
	child_role = TRUE
	can_be_in_squad = FALSE
	//Kids suck at everything.
	specific_skill = TRUE
	medical_skill = 1
	surgery_skill = 1
	ranged_skill = 1
	engineering_skill = 1
	melee_skill = 1
	auto_rifle_skill = 1
	semi_rifle_skill = 1
	sniper_skill = 1
	shotgun_skill = 1
	lmg_skill = 1
	smg_skill = 1
	boltie_skill = 1
	supervisors = "adults and your very cool country"
	announced = FALSE

	equip(mob/living/carbon/human/H)
		var/current_name = H.real_name
		..()
		H.fast_stripper = TRUE
		H.add_stats(rand(3,6), rand(12,16), rand(6,9))
		qdel(H.get_equipped_item(slot_s_store))  // they cant even handle guns
		H.fully_replace_character_name("Scav. [current_name]")
		H.set_trait(new/datum/trait/child())
		H.say(";Scav reporting for duty!")

/decl/hierarchy/outfit/job/bluesoldier
	name = OUTFIT_JOB_NAME("Blue Soldier")
	head = /obj/item/clothing/head/helmet/bluehelmet
	uniform = /obj/item/clothing/under/blue_uniform
	back = /obj/item/storage/backpack/satchel/warfare
	shoes = /obj/item/clothing/shoes/jackboots/warfare/blue
	l_ear = null
	l_pocket = /obj/item/storage/box/ifak
	suit = /obj/item/clothing/suit/armor/bluecoat
	gloves = /obj/item/clothing/gloves/thick/swat/combat/warfare
	neck = /obj/item/reagent_containers/food/drinks/canteen
	pda_type = null
	id_type = /obj/item/card/id/dog_tag/blue
	flags = OUTFIT_NO_BACKPACK|OUTFIT_NO_SURVIVAL_GEAR

/decl/hierarchy/outfit/job/bluesoldier/soldier/equip()
	if(aspect_chosen(/datum/aspect/lone_rider))
		suit_store = /obj/item/gun/projectile/shotgun/pump/boltaction/shitty/leverchester
		r_pocket = /obj/item/ammo_box/rifle
		backpack_contents = initial(backpack_contents)
		belt = null

	else if (prob(5))
		suit_store = /obj/item/gun/projectile/automatic/m22/warmonger/m14/battlerifle/rsc
		r_pocket =  /obj/item/ammo_magazine/a762/rsc
		backpack_contents = list(/obj/item/grenade/smokebomb = 1)
		belt = /obj/item/storage/belt/armageddon

	else if (prob(15))
		suit_store = /obj/item/gun/projectile/shotgun/pump/boltaction/good
		r_pocket =  /obj/item/ammo_box/rifle/modern
		backpack_contents = initial(backpack_contents)
		belt = null

	else if(prob(25))
		suit_store = /obj/item/gun/projectile/shotgun/pump/boltaction/shitty/leverchester
		r_pocket = /obj/item/ammo_box/rifle
		backpack_contents = list(/obj/item/grenade/smokebomb = 1)
		belt = null

	else if(prob(50))
		suit_store = /obj/item/gun/projectile/shotgun/pump/boltaction/shitty/bayonet
		r_pocket = /obj/item/ammo_box/rifle
		backpack_contents = list(/obj/item/grenade/smokebomb = 1)
		belt = null

	else
		suit_store = /obj/item/gun/projectile/shotgun/pump/boltaction/shitty
		r_pocket = /obj/item/ammo_box/rifle
		backpack_contents = list(/obj/item/grenade/smokebomb = 1)
		belt = null

	if(aspect_chosen(/datum/aspect/nightfare))
		backpack_contents += list(/obj/item/torch/self_lit = 1, /obj/item/ammo_box/flares/blue = 1)
	if(aspect_chosen(/datum/aspect/trenchmas))
		backpack_contents += list(/obj/item/gift/warfare = 1)
	..()

/decl/hierarchy/outfit/job/bluesoldier/sgt
	suit_store = /obj/item/gun/projectile/shotgun/pump/boltaction/shitty/leverchester
	r_pocket = /obj/item/ammo_box/rifle
	backpack_contents = list(/obj/item/grenade/smokebomb = 1, /obj/item/clothing/mask/gas/blue = 1)

/decl/hierarchy/outfit/job/bluesoldier/sgt/equip()
	if(prob(10))
		suit_store = /obj/item/gun/projectile/shotgun/pump/shitty/sawn
		r_pocket = /obj/item/ammo_box/shotgun

	else if(prob(25))
		suit_store = /obj/item/gun/projectile/shotgun/pump/shitty
		r_pocket = /obj/item/ammo_box/shotgun

	else if(prob(5))
		suit_store = /obj/item/gun/projectile/automatic/m22/warmonger/m14/battlerifle/rsc
		r_pocket =  /obj/item/ammo_magazine/a762/rsc
		backpack_contents = list(/obj/item/grenade/smokebomb = 1)
		belt = /obj/item/storage/belt/armageddon

	else if(prob(5))
		suit_store = /obj/item/gun/projectile/automatic/m22/warmonger/fully_auto
		backpack_contents = list(/obj/item/clothing/mask/gas/blue = 1)
		r_pocket = /obj/item/grenade/smokebomb
		chest_holster = /obj/item/storage/backpack/satchel/warfare/chestrig/blue/soldier
	else if(prob(5)) //I am light weapons guy. And this is my weapon.
		suit_store = /obj/item/gun/projectile/automatic/m22/warmonger/fully_auto/oldlmg
		r_pocket = /obj/item/grenade/smokebomb
		backpack_contents = list(/obj/item/clothing/mask/gas/blue = 1)
		chest_holster = /obj/item/storage/backpack/satchel/warfare/chestrig/blue/oldlmg
/*
	if(prob(50))//Give them an MRE. They're going to be out there a while.
		backpack_contents += list(/obj/item/storage/box/mre = 1)
	else
		backpack_contents += list(/obj/item/storage/box/mre/var1 = 1)
*/
	if(aspect_chosen(/datum/aspect/nightfare))
		backpack_contents += list(/obj/item/ammo_box/flares/blue = 1, /obj/item/torch/self_lit = 1)
	..()

/decl/hierarchy/outfit/job/bluesoldier/engineer
	//r_pocket = /obj/item/ammo_magazine/mc9mmt/machinepistol
	l_pocket = /obj/item/wirecutters
	//suit_store = /obj/item/gun/projectile/automatic/machinepistol
	back = /obj/item/storage/backpack/warfare
	belt = /obj/item/gun/projectile/warfare
	backpack_contents = list(/obj/item/stack/barbwire = 1, /obj/item/shovel = 1, /obj/item/defensive_barrier = 3, /obj/item/storage/box/ifak = 1, /obj/item/ammo_magazine/c45m/warfare = 2)

/decl/hierarchy/outfit/job/bluesoldier/engineer/equip()
	if(prob(1))//Rare engineer spawn
		suit_store = /obj/item/gun/projectile/automatic/autoshotty
		r_pocket = /obj/item/shovel
		belt = /obj/item/storage/belt/autoshotty
		backpack_contents = list(/obj/item/stack/barbwire = 1, /obj/item/shovel = 1, /obj/item/defensive_barrier = 3, /obj/item/storage/box/ifak = 1, /obj/item/grenade/smokebomb = 1)
	else if (prob(7)) //if(prob(50))
		suit_store = /obj/item/gun/projectile/shotgun/pump/shitty
		r_pocket = /obj/item/ammo_box/shotgun

	else if (prob(15))
		suit_store = /obj/item/gun/projectile/shotgun/pump/boltaction/good
		r_pocket =  /obj/item/ammo_box/rifle/modern

	else if(prob(25))
		suit_store = /obj/item/gun/projectile/shotgun/pump/boltaction/shitty/leverchester
		r_pocket = /obj/item/ammo_box/rifle

	else if(prob(50))
		suit_store = /obj/item/gun/projectile/shotgun/pump/boltaction/shitty/bayonet
		r_pocket = /obj/item/ammo_box/rifle

	else
		suit_store = /obj/item/gun/projectile/shotgun/pump/boltaction/shitty
		r_pocket = /obj/item/ammo_box/rifle
	/*
	else
		suit_store = /obj/item/gun/projectile/automatic/machinepistol
		r_pocket = /obj/item/shovel
		belt = /obj/item/storage/belt/warfare
		backpack_contents = list(/obj/item/stack/barbwire = 1, /obj/item/defensive_barrier = 3, /obj/item/storage/box/ifak = 1, /obj/item/grenade/smokebomb = 1)
	*/
	if(aspect_chosen(/datum/aspect/nightfare))
		backpack_contents += list(/obj/item/ammo_box/flares/blue = 1, /obj/item/torch/self_lit = 1)
	if(aspect_chosen(/datum/aspect/trenchmas))
		backpack_contents += list(/obj/item/gift/warfare = 1)
	..()


/decl/hierarchy/outfit/job/bluesoldier/medic
	suit = /obj/item/clothing/suit/armor/bluecoat/medic
	belt = /obj/item/storage/belt/medical/full
	r_pocket = /obj/item/ammo_magazine/c45rifle/akarabiner
	l_pocket = /obj/item/stack/medical/bruise_pack
	suit_store = /obj/item/gun/projectile/automatic/m22/warmonger
	gloves = /obj/item/clothing/gloves/latex
	head = /obj/item/clothing/head/helmet/bluehelmet/medic

/decl/hierarchy/outfit/job/bluesoldier/medic/equip()
	if(prob(50))
		suit_store = /obj/item/gun/projectile/automatic/m22/warmonger
		r_pocket = /obj/item/ammo_magazine/c45rifle/akarabiner
		backpack_contents = list(/obj/item/ammo_magazine/c45rifle/akarabiner = 3, /obj/item/grenade/smokebomb = 1)

	else
		suit_store = /obj/item/gun/projectile/shotgun/pump/boltaction/shitty/bayonet
		r_pocket = /obj/item/ammo_box/rifle
		backpack_contents = list(/obj/item/grenade/smokebomb = 1)
	if(aspect_chosen(/datum/aspect/nightfare))
		backpack_contents += list(/obj/item/ammo_box/flares/blue = 1, /obj/item/torch/self_lit = 1)
	if(aspect_chosen(/datum/aspect/trenchmas))
		backpack_contents += list(/obj/item/gift/warfare = 1)
	..()

/decl/hierarchy/outfit/job/bluesoldier/sniper
	l_ear = /obj/item/device/radio/headset/blue_team/all
	suit = /obj/item/clothing/suit/armor/sniper
	head = null
	suit_store = /obj/item/gun/projectile/heavysniper
	belt = /obj/item/gun/projectile/revolver/manual //Backup weapon.
	r_pocket = /obj/item/ammo_box/ptsd
	backpack_contents = list(/obj/item/grenade/smokebomb = 1, /obj/item/clothing/mask/gas/sniper = 1)
	chest_holster = null

/decl/hierarchy/outfit/job/bluesoldier/sniper/equip()
	if(prob(50))
		belt = /obj/item/gun/projectile/warfare
	else
		belt = /obj/item/gun/projectile/revolver/manual
	if(aspect_chosen(/datum/aspect/nightfare))
		backpack_contents += list(/obj/item/ammo_box/flares/blue = 1, /obj/item/torch/self_lit = 1)
	if(aspect_chosen(/datum/aspect/trenchmas))
		backpack_contents += list(/obj/item/gift/warfare = 1)
	..()

/decl/hierarchy/outfit/job/bluesoldier/flamer
	name = OUTFIT_JOB_NAME("Blue Flamer")
	l_ear = /obj/item/device/radio/headset/blue_team/all
	suit = /obj/item/clothing/suit/fire/blue
	mask = /obj/item/clothing/mask/gas/blue/flamer
	gloves = /obj/item/clothing/gloves/thick/swat/combat/warfare/blue/flamer
	belt = /obj/item/gun/projectile/automatic/flamer
	head = /obj/item/clothing/head/helmet/bluehelmet/fire
	shoes = /obj/item/clothing/shoes/jackboots/warfare/blue/flamer
	r_pocket = /obj/item/grenade/fire
	backpack_contents = list(/obj/item/grenade/smokebomb = 1)
	chest_holster = /obj/item/storage/backpack/satchel/warfare/chestrig/blue
	chestholster_contents = list(/obj/item/ammo_magazine/flamer = 4)

/decl/hierarchy/outfit/job/bluesoldier/sentry
	name = OUTFIT_JOB_NAME("Blue Sentry")
	l_ear = /obj/item/device/radio/headset/blue_team/all
	suit = /obj/item/clothing/suit/armor/sentry/blue
	head = /obj/item/clothing/head/helmet/sentryhelm/blue
	belt = /obj/item/melee/trench_axe
	suit_store = /obj/item/gun/projectile/automatic/mg08
	backpack_contents = list(/obj/item/ammo_magazine/box/a556/mg08 = 3, /obj/item/grenade/smokebomb = 1)

/decl/hierarchy/outfit/job/bluesoldier/sentry/equip()
	if(aspect_chosen(/datum/aspect/nightfare))
		backpack_contents += list(/obj/item/torch/self_lit = 1)
		belt = /obj/item/ammo_box/flares/blue
	if(aspect_chosen(/datum/aspect/trenchmas))
		backpack_contents += list(/obj/item/gift/warfare = 1)
	..()

/decl/hierarchy/outfit/job/bluesoldier/leader
	name = OUTFIT_JOB_NAME("Blue Captain")
	glasses = /obj/item/clothing/glasses/sunglasses
	suit = /obj/item/clothing/suit/armor/bluecoat/leader
	head = /obj/item/clothing/head/warfare_officer/blueofficer
	l_ear = /obj/item/device/radio/headset/blue_team/all
	belt = /obj/item/gun/projectile/revolver/cpt
	r_pocket = /obj/item/device/binoculars
	l_pocket = /obj/item/key/captain
	chest_holster = null
	backpack_contents = list(/obj/item/ammo_magazine/handful/revolver = 2, /obj/item/grenade/smokebomb = 1)

/decl/hierarchy/outfit/job/bluesoldier/leader/equip()
/*
	if(prob(50))//Give them an MRE. They're going to be out there a while.
		backpack_contents += list(/obj/item/storage/box/mre = 1)
	else
		backpack_contents += list(/obj/item/storage/box/mre/var1 = 1)
*/
	if(aspect_chosen(/datum/aspect/nightfare))
		backpack_contents += list(/obj/item/ammo_box/flares/blue = 1 , /obj/item/torch/self_lit = 1)
	..()

/decl/hierarchy/outfit/job/bluesoldier/scout
	suit = /obj/item/clothing/suit/armor/bluecoat
	l_ear = /obj/item/device/radio/headset/blue_team/all
	uniform = /obj/item/clothing/under/child_jumpsuit/warfare/blue
	shoes = /obj/item/clothing/shoes/jackboots/warfare/blue
	gloves = null
	r_pocket = /obj/item/device/binoculars
	backpack_contents = list(/obj/item/grenade/smokebomb = 1)
	r_hand = /obj/item/tagnabber

/decl/hierarchy/outfit/job/bluesoldier/scout/equip()
	if(aspect_chosen(/datum/aspect/nightfare))
		backpack_contents += list(/obj/item/torch/self_lit = 1)
		belt = /obj/item/ammo_box/flares/blue
	if(aspect_chosen(/datum/aspect/trenchmas))
		backpack_contents += list(/obj/item/gift/warfare = 1)
	..()
