/obj/effect/landmark
	name = "landmark"
	icon = 'icons/hammer/source.dmi'//'icons/mob/screen1.dmi'
	icon_state = "landmark2"//"x2" // HAMMERIZATION // INTERWAR // I found it funny LOL
	anchored = 1.0
	unacidable = 1
	simulated = 0
	invisibility = 101
	var/delete_me = 0

/obj/effect/landmark/New()
	..()
	tag = "landmark*[name]"

	//TODO clean up this mess
	switch(name)			//some of these are probably obsolete
		if("monkey")
			GLOB.monkeystart += loc
			delete_me = 1
			return
		if("start")
			GLOB.newplayer_start += loc
			delete_me = 1
			return
		if("JoinLate")
			GLOB.latejoin += loc
			delete_me = 1
			return
		if("JoinLateGateway")
			GLOB.latejoin_gateway += loc
			delete_me = 1
			return
		if("JoinLateCryo")
			GLOB.latejoin_cryo += loc
			delete_me = 1
			return
		if("JoinLateCyborg")
			GLOB.latejoin_cyborg += loc
			delete_me = 1
			return
		if("prisonwarp")
			GLOB.prisonwarp += loc
			delete_me = 1
			return
		if("tdome1")
			GLOB.tdome1 += loc
		if("tdome2")
			GLOB.tdome2 += loc
		if("tdomeadmin")
			GLOB.tdomeadmin += loc
		if("tdomeobserve")
			GLOB.tdomeobserve += loc
		if("prisonsecuritywarp")
			GLOB.prisonsecuritywarp += loc
			delete_me = 1
			return
		if("endgame_exit")
			endgame_safespawns += loc
			delete_me = 1
			return
		if("bluespacerift")
			endgame_exits += loc
			delete_me = 1
			return

	landmarks_list += src
	return 1

/obj/effect/landmark/proc/delete()
	delete_me = 1

/obj/effect/landmark/Initialize()
	. = ..()
	if(delete_me)
		return INITIALIZE_HINT_QDEL

/obj/effect/landmark/Destroy()
	landmarks_list -= src
	return ..()

/obj/effect/landmark/start
	name = "start"
	//icon = 'icons/mob/screen1.dmi'
	icon_state = "landmark" //icon_state = "x" // HAMMERIZATION // INTERWAR // i found it funny
	anchored = 1.0
	invisibility = 101

/obj/effect/landmark/start/New()
	..()
	tag = "start*[name]"
	return 1

//
// U N U S E D
//
/obj/effect/landmark/start/HISTORY/assistant
	name = "Assistant"
/obj/effect/landmark/start/HISTORY/botanic
	name = "Botanic"
/obj/effect/landmark/start/HISTORY/bartender
	name = "Bartender"
/obj/effect/landmark/start/HISTORY/magistrate
	name = "Commandant"
/obj/effect/landmark/start/HISTORY/cargo
	name = "Crate Pusher"
/obj/effect/landmark/start/HISTORY/chemist
	name = "Chemist"
/obj/effect/landmark/start/HISTORY/chef
	name = "Chef"
/obj/effect/landmark/start/HISTORY/chaplain
	name = "Chaplain"
/obj/effect/landmark/start/HISTORY/chief_engineer
	name = "Head Upkeeper"
/obj/effect/landmark/start/HISTORY/cmo
	name = "Head Practitioner"
/obj/effect/landmark/start/HISTORY/detective
	name = "Inspector"
/obj/effect/landmark/start/HISTORY/engineer
	name = "Upkeeper"
/obj/effect/landmark/start/HISTORY/overseer
	name = "Overseer"
/obj/effect/landmark/start/HISTORY/head_peacekeeper
	name = "Head Peacekeeper"
/obj/effect/landmark/start/HISTORY/janitor
	name = "Janitor"
/obj/effect/landmark/start/HISTORY/librarian
	name = "Librarian"
/obj/effect/landmark/start/HISTORY/medical_doctor
	name = "Practitioner"
/obj/effect/landmark/start/HISTORY/paramedic
	name = "Paramedic"
/obj/effect/landmark/start/HISTORY/meister
	name = "Quartermaster"
/obj/effect/landmark/start/HISTORY/robotic_augmentor
	name = "Robotic Augmentor"
/obj/effect/landmark/start/HISTORY/peacekeeper
	name = "Peacekeeper"
/obj/effect/landmark/start/HISTORY/shaft_miner
	name = "Shaft Miner"
/obj/effect/landmark/start/HISTORY/scientist
	name = "Tenchotrainee"
/obj/effect/landmark/start/HISTORY/warden
	name = "Warden"
/obj/effect/landmark/start/HISTORY/xenobiologist
	name = "Xenobiologist"
/obj/effect/landmark/start/HISTORY/supreme_arbiter
	name = "Supreme Arbiter"
/obj/effect/landmark/start/HISTORY/arbiter
	name = "Arbiter"
/obj/effect/landmark/start/HISTORY/cargo_kid
	name ="Cargo Kid"
/obj/effect/landmark/start/HISTORY/cadet
	name = "Cadet"
/obj/effect/landmark/start/HISTORY/heir
	name = "Heir"
//
// W A R F A R E
//
//RED
//
/obj/effect/landmark/start/WARFARE/red
	name = "Red Soldier"
/obj/effect/landmark/start/WARFARE/red/medic
	name = "Red Medic"
/obj/effect/landmark/start/WARFARE/red/engi
	name = "Red Engineer"
/obj/effect/landmark/start/WARFARE/red/sl
	name = "Red Squad Leader"
/obj/effect/landmark/start/WARFARE/red/lt
	name = "Red Logistics Lieutenant"
/obj/effect/landmark/start/WARFARE/red/prac
	name = "Red Practitioner"
/obj/effect/landmark/start/WARFARE/red/scav
	name = "Red Scavenger"
/obj/effect/landmark/start/WARFARE/red/sentry
	name = "Red Sentry"
/obj/effect/landmark/start/WARFARE/red/flamer
	name = "Red Flame Trooper"
/obj/effect/landmark/start/WARFARE/red/sniper
	name = "Red Sniper"
/obj/effect/landmark/start/WARFARE/red/cap
	name = "Red Captain"
//
// BLUE
//
/obj/effect/landmark/start/WARFARE/blue
	name = "Blue Soldier"
/obj/effect/landmark/start/WARFARE/blue/medic
	name = "Blue Medic"
/obj/effect/landmark/start/WARFARE/blue/engi
	name = "Blue Engineer"
/obj/effect/landmark/start/WARFARE/blue/sl
	name = "Blue Squad Leader"
/obj/effect/landmark/start/WARFARE/blue/lt
	name = "Blue Logistics Lieutenant"
/obj/effect/landmark/start/WARFARE/blue/prac
	name = "Blue Practitioner"
/obj/effect/landmark/start/WARFARE/blue/scav
	name = "Blue Scavenger"
/obj/effect/landmark/start/WARFARE/blue/sentry
	name = "Blue Sentry"
/obj/effect/landmark/start/WARFARE/blue/flamer
	name = "Blue Flame Trooper"
/obj/effect/landmark/start/WARFARE/blue/sniper
	name = "Blue Sniper"
/obj/effect/landmark/start/WARFARE/blue/cap
	name = "Blue Captain"

//Costume spawner landmarks
/obj/effect/landmark/costume/New() //costume spawner, selects a random subclass and disappears

	var/list/options = typesof(/obj/effect/landmark/costume)
	var/PICK= options[rand(1,options.len)]
	new PICK(src.loc)
	delete_me = 1

//SUBCLASSES.  Spawn a bunch of items and disappear likewise
/obj/effect/landmark/costume/chameleon/New()
	new /obj/item/clothing/mask/chameleon(src.loc)
	new /obj/item/clothing/under/chameleon(src.loc)
	new /obj/item/clothing/glasses/chameleon(src.loc)
	new /obj/item/clothing/shoes/chameleon(src.loc)
	new /obj/item/clothing/gloves/chameleon(src.loc)
	new /obj/item/clothing/suit/chameleon(src.loc)
	new /obj/item/clothing/head/chameleon(src.loc)
	new /obj/item/storage/backpack/chameleon(src.loc)
	delete_me = 1

/obj/effect/landmark/costume/gladiator/New()
	new /obj/item/clothing/under/gladiator(src.loc)
	new /obj/item/clothing/head/helmet/gladiator(src.loc)
	delete_me = 1

/obj/effect/landmark/costume/madscientist/New()
	new /obj/item/clothing/under/gimmick/rank/captain/suit(src.loc)
	new /obj/item/clothing/head/flatcap(src.loc)
	new /obj/item/clothing/suit/storage/toggle/labcoat/mad(src.loc)
	new /obj/item/clothing/glasses/gglasses(src.loc)
	delete_me = 1

/obj/effect/landmark/costume/elpresidente/New()
	new /obj/item/clothing/under/gimmick/rank/captain/suit(src.loc)
	new /obj/item/clothing/head/flatcap(src.loc)
	new /obj/item/clothing/mask/smokable/cigarette/cigar(src.loc)
	new /obj/item/clothing/shoes/jackboots(src.loc)
	delete_me = 1

/obj/effect/landmark/costume/nyangirl/New()
	new /obj/item/clothing/under/schoolgirl(src.loc)
	new /obj/item/clothing/head/kitty(src.loc)
	delete_me = 1

/obj/effect/landmark/costume/maid/New()
	new /obj/item/clothing/under/blackskirt(src.loc)
	var/CHOICE = pick( /obj/item/clothing/head/beret , /obj/item/clothing/head/rabbitears )
	new CHOICE(src.loc)
	new /obj/item/clothing/glasses/sunglasses/blindfold(src.loc)
	delete_me = 1

/obj/effect/landmark/costume/butler/New()
	new /obj/item/clothing/accessory/wcoat(src.loc)
	new /obj/item/clothing/under/suit_jacket(src.loc)
	new /obj/item/clothing/head/that(src.loc)
	delete_me = 1

/obj/effect/landmark/costume/scratch/New()
	new /obj/item/clothing/gloves/white(src.loc)
	new /obj/item/clothing/shoes/white(src.loc)
	new /obj/item/clothing/under/scratch(src.loc)
	if (prob(30))
		new /obj/item/clothing/head/cueball(src.loc)
	delete_me = 1

/obj/effect/landmark/costume/prig/New()
	new /obj/item/clothing/accessory/wcoat(src.loc)
	new /obj/item/clothing/glasses/monocle(src.loc)
	var/CHOICE= pick( /obj/item/clothing/head/bowler, /obj/item/clothing/head/that)
	new CHOICE(src.loc)
	new /obj/item/clothing/shoes/black(src.loc)
	new /obj/item/cane(src.loc)
	new /obj/item/clothing/under/sl_suit(src.loc)
	new /obj/item/clothing/mask/fakemoustache(src.loc)
	delete_me = 1

/obj/effect/landmark/costume/plaguedoctor/New()
	new /obj/item/clothing/suit/bio_suit/plaguedoctorsuit(src.loc)
	new /obj/item/clothing/head/plaguedoctorhat(src.loc)
	delete_me = 1

/obj/effect/landmark/costume/nightowl/New()
	new /obj/item/clothing/under/owl(src.loc)
	new /obj/item/clothing/mask/gas/owl_mask(src.loc)
	delete_me = 1

/obj/effect/landmark/costume/waiter/New()
	new /obj/item/clothing/under/waiter(src.loc)
	var/CHOICE= pick( /obj/item/clothing/head/kitty, /obj/item/clothing/head/rabbitears)
	new CHOICE(src.loc)
	new /obj/item/clothing/suit/apron(src.loc)
	delete_me = 1

/obj/effect/landmark/costume/pirate/New()
	new /obj/item/clothing/under/pirate(src.loc)
	new /obj/item/clothing/suit/pirate(src.loc)
	var/CHOICE = pick( /obj/item/clothing/head/pirate , /obj/item/clothing/mask/bandana/red)
	new CHOICE(src.loc)
	new /obj/item/clothing/glasses/eyepatch(src.loc)
	delete_me = 1

/obj/effect/landmark/costume/commie/New()
	new /obj/item/clothing/under/soviet(src.loc)
	new /obj/item/clothing/head/ushanka(src.loc)
	delete_me = 1

/obj/effect/landmark/costume/imperium_monk/New()
	new /obj/item/clothing/suit/imperium_monk(src.loc)
	if (prob(25))
		new /obj/item/clothing/mask/gas/cyborg(src.loc)
	delete_me = 1

/obj/effect/landmark/costume/holiday_priest/New()
	new /obj/item/clothing/suit/holidaypriest(src.loc)
	delete_me = 1

/obj/effect/landmark/costume/marisawizard/fake/New()
	new /obj/item/clothing/head/wizard/marisa/fake(src.loc)
	new/obj/item/clothing/suit/wizrobe/marisa/fake(src.loc)
	delete_me = 1

/obj/effect/landmark/costume/cutewitch/New()
	new /obj/item/clothing/under/sundress(src.loc)
	new /obj/item/clothing/head/witchwig(src.loc)
	new /obj/item/staff/broom(src.loc)
	delete_me = 1

/obj/effect/landmark/costume/fakewizard/New()
	new /obj/item/clothing/suit/wizrobe/fake(src.loc)
	new /obj/item/clothing/head/wizard/fake(src.loc)
	new /obj/item/staff/(src.loc)
	delete_me = 1

/obj/effect/landmark/costume/sexyclown/New()
	new /obj/item/clothing/mask/gas/sexyclown(src.loc)
	new /obj/item/clothing/under/sexyclown(src.loc)
	delete_me = 1

/obj/effect/landmark/costume/sexymime/New()
	new /obj/item/clothing/mask/gas/sexymime(src.loc)
	new /obj/item/clothing/under/sexymime(src.loc)
	delete_me = 1

/obj/effect/landmark/costume/savagehunter/New()
	new /obj/item/clothing/mask/spirit(src.loc)
	new /obj/item/clothing/under/savage_hunter(src.loc)
	delete_me = 1

/obj/effect/landmark/costume/savagehuntress/New()
	new /obj/item/clothing/mask/spirit(src.loc)
	new /obj/item/clothing/under/savage_hunter/female(src.loc)
	delete_me = 1

/obj/effect/landmark/ruin
	var/datum/map_template/ruin/ruin_template

/obj/effect/landmark/ruin/New(loc, my_ruin_template)
	name = "ruin_[sequential_id(/obj/effect/landmark/ruin)]"
	..(loc)
	ruin_template = my_ruin_template
	GLOB.ruin_landmarks |= src

/obj/effect/landmark/ruin/Destroy()
	GLOB.ruin_landmarks -= src
	ruin_template = null
	. = ..()

/obj/effect/landmark/random_gen
	var/generation_width
	var/generation_height
	var/seed
	delete_me = TRUE

/obj/effect/landmark/random_gen/asteroid/Initialize()
	. = ..()

	var/min_x = 1
	var/min_y = 1
	var/max_x = world.maxx
	var/max_y = world.maxy

	if (generation_width)
		min_x = max(src.x, min_x)
		max_x = min(src.x + generation_width, max_x)
	if (generation_height)
		min_y = max(src.y, min_y)
		max_y = min(src.y + generation_height, max_y)

	new /datum/random_map/automata/cave_system(seed, min_x, min_y, src.z, max_x, max_y)
	new /datum/random_map/noise/ore(seed, min_x, min_y, src.z, max_x, max_y)

	GLOB.using_map.refresh_mining_turfs(src.z)
