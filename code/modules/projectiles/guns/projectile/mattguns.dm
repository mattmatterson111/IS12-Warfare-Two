//Shitty variant of the normal bolt action rifle.
/obj/item/gun/projectile/shotgun/pump/boltaction/shitty
	name = "\improper Mark I Stormrider"
	desc = "This piece is practically held together by rust and spite, jams half the time, and looks older than I am. They don’t actually expect me to fight with this, do they?"//"The much, much older brother of the sleeker, better, Mark II. Kind of a piece of shit."
	//icon = 'icons/obj/gun32x64.dmi'
	//condition_icon = 'icons/obj/gun32x64.dmi'
	//icon_state = "lever2"
	//bayonet_icon ='icons/obj/gun32x64.dmi'
	icon_state = "boltaction"
	item_state = "boltaction"
	wielded_item_state = "boltaction-wielded"
	condition = 75
	fire_sound = "brifle"
	caliber = "763"
	ammo_type = /obj/item/ammo_casing/brifle
	one_hand_penalty = 20 //FIRE THIS THING WITH BOTH FUCKING HANDS.
	empty_icon = "boltaction-e"
	far_fire_sound = "sniper_fire"
	gun_type = GUN_BOLTIE //So engineers can't shoot this shit.
	can_have_bayonet = TRUE

/obj/item/gun/projectile/shotgun/pump/boltaction/shitty/bayonet
	name = "\improper Mark I Stormrider"
	force = 20
	sharp = 1
	attack_verb = list ("stabbed", "sliced")
	hitsound = "bayonet_stab"

/obj/item/gun/
	var/can_have_bayonet = FALSE

/obj/item/gun/projectile/shotgun/pump/boltaction/attackby(obj/item/W, mob/user)
	. = ..()
	if(istype(W, /obj/item/material/sword/combat_knife) && can_have_bayonet)
		user.visible_message("[user] attaches a bayonet to the [src].","You attach a bayonet to the [src].")
		user.remove_from_mob(W)
		qdel(W)
		add_bayonet()


/obj/item/gun/projectile/shotgun/pump/boltaction/shitty/bayonet/New()
	..()
	add_bayonet()

//Now THIS is real gun, rare 5 in 100 gun spawn as soldier
/obj/item/gun/projectile/shotgun/pump/boltaction/good
	name = "\improper Mark II Glider"
	desc = "This is the updated and revised version of the Mk. I Stormrider, complete with a more manageable caliber, higher mag capacity, sleek handguard and a straight bolt that makes it hard to shove multiple rounds at a time."
	icon = 'icons/obj/gun.dmi'
	condition_icon = 'icons/obj/gun.dmi'
	icon_state = "mosin2"
	item_state = "mosin2"
	wielded_item_state = "mosin2-wielded"
	condition = 100
	screen_shake = 0.5
	fire_sound = 'sound/weapons/gunshot/splitter.ogg'
	max_shells = 9
	load_delay = 15
	caliber = "a556"
	ammo_type = /obj/item/ammo_casing/a556
	one_hand_penalty = 15 //lower caliber means better control
	empty_icon = "karabiner_empty"
	far_fire_sound = "sniper_fire"
	gun_type = GUN_BOLTIE //So engineers can't shoot this shit.
	can_have_bayonet = FALSE


/obj/item/gun/projectile/shotgun/pump/boltaction/shitty/leverchester
	name = "\improper Mark I Snapper"
	desc = "The lever action on this thing’s grimy, hasn’t seen grease in years. Still, it’s smoother than the bolt on the Stormrider, though it’s slapped together from the same junk parts. Feels like it could seize up any second."
	//icon = 'icons/obj/gun32x64.dmi'
	//condition_icon = 'icons/obj/gun32x64.dmi'
	//icon_state = "lever1"
	//bayonet_icon ='icons/obj/gun32x64.dmi'
	icon_state = "leverchester"
	item_state = "leverchester"
	wielded_item_state = "leverchester-wielded"
	fire_sound = 'sound/weapons/guns/fire/la_fire.ogg'
	bulletinsert_sound = 'sound/weapons/guns/interact/la_insert.ogg'
	pumpsound = 'sound/weapons/guns/interact/la_cock.ogg'
	backsound = 'sound/weapons/guns/interact/la_back.ogg'
	forwardsound = 'sound/weapons/guns/interact/la_forward.ogg'
	empty_icon = "leverchester-e"
	can_have_bayonet = TRUE


//Paryying.
/obj/item/gun/projectile/shotgun/pump/boltaction/handle_shield(mob/living/user, var/damage, atom/damage_source = null, mob/attacker = null, var/def_zone = null, var/attack_text = "the attack")
	if(default_sword_parry(user, damage, damage_source, attacker, def_zone, attack_text))
		return 1
	return 0

//AMMO
/obj/item/ammo_casing/brifle
	desc = "An old worn out looking bullet casing."
	caliber = "763"
	projectile_type = /obj/item/projectile/bullet/rifle/a762/brifle
	icon_state = "brifle"
	spent_icon = "brifle-casing"
	ammo_stack = /obj/item/ammo_magazine/handful/brifle_handful/two

/obj/item/projectile/bullet/rifle/a762/brifle
	fire_sound = "brifle"
	penetrating = FALSE
	damage = 65

/obj/item/ammo_magazine/brifle
	name = "Rifle Box"
	desc = "A box of rifle ammo."
	icon_state = "rbox"
	caliber = "763"
	ammo_type = /obj/item/ammo_casing/brifle
	matter = list(DEFAULT_WALL_MATERIAL = 1260)
	max_ammo = 20



//Shitty shotgun
/obj/item/gun/projectile/shotgun/pump/shitty
	name = "\improper WTX Frontier Special"
	desc = "Five in the tube, one in the chamber… yeah, that’s right. I remember a trench raider who swore by one of these. Said it was all he’d ever need. Poor bastard didn’t make it past the first shelling. Every time I hold it, though, I still hear his voice."
	//icon = 'icons/obj/gun32x64.dmi'
	//condition_icon = 'icons/obj/gun32x64.dmi'
	//icon_state = "shot1"
	//bayonet_icon ='icons/obj/gun32x64.dmi'
	icon_state = "winchester"
	item_state = "winchester"
	wielded_item_state = "winchester-wielded"
	condition = 75
	ammo_type = /obj/item/ammo_casing/shotgun/pellet
	one_hand_penalty = 20 //FIRE THIS THING WITH BOTH FUCKING HANDS AS WELL
	empty_icon = "winchester-e"
	can_have_bayonet = TRUE

/obj/item/gun/projectile/shotgun/pump/shitty/attackby(obj/item/W, mob/user)
	. = ..()
	if(istype(W, /obj/item/material/sword/combat_knife) && can_have_bayonet)
		user.visible_message("[user] attaches a bayonet to the [src].","You attach a bayonet to the [src].")
		user.remove_from_mob(W)
		qdel(W)
		add_bayonet()

/obj/item/gun/projectile/shotgun/pump/shitty/sawn
	name = "\improper Sawn Off WTX Frontier Special"
	desc = "Purposely cut down and made shorter, it still packs the same punch as its longer brother but in a more compact package. I can’t help but wonder if it’s even reliable."
	icon_state = "sawnchester"
	item_state = "sawnchester"
	wielded_item_state = "sawnchester-wielded"
	slot_flags = SLOT_BELT|SLOT_BACK|SLOT_S_STORE
	w_class = ITEM_SIZE_NORMAL
	max_shells = 4
	empty_icon = "sawnchester-e"


/obj/item/gun/projectile/shotgun/pump/shitty/sawn/smallshotty
	name = "\improper WTX Reckoning"
	desc = "Small enough to stow away and simple to handle deceptively compact shotgun became a common sight for Couriers running messages between command and the frontlines its better then nothing."
	icon_state = "smallshotty"
	item_state = "smallshotty"
	wielded_item_state = "smallshotty-wielded"
	empty_icon = "smallshotty-e"

/obj/item/gun/projectile/shotgun/pump/shitty/bayonet
	force = 20
	sharp = 1
	attack_verb = list ("stabbed", "sliced")
	hitsound = "bayonet_stab"

/obj/item/gun/projectile/shotgun/pump/shitty/bayonet/New()
	..()
	add_bayonet()
	desc += " This one has a bayonet."



/obj/item/gun/projectile/automatic
	attachable_allowed = list(/obj/item/attachable/holosight, /obj/item/attachable/verticalgrip, /obj/item/attachable/reddot, /obj/item/attachable/lasersight, /obj/item/attachable/angledgrip)
	screen_shake = 2

/obj/item/gun/projectile/automatic/set_gun_attachment_offsets()
	attachable_offset = list("muzzle_x" = 32, "muzzle_y" = 18,"rail_x" = 13, "rail_y" = 22, "under_x" = 22, "under_y" = 14, "stock_x" = 24, "stock_y" = 13, "special_x" = 28, "special_y" = 16)

/obj/item/gun/projectile/automatic/m22/warmonger
	name = "Mk.3 Warmonger"
	desc = "One of those newer mass production factory-made rifles; it’s stuck in semi-automatic, but it makes you feel like a real soldier."
	icon_state = "autorifle"
	item_state = "autorifle"
	wielded_item_state = "autorifle-wielded"
	fire_sound = 'sound/weapons/gunshot/gunshot_arifle.ogg'
	loaded_icon = "autorifle"
	unwielded_loaded_icon = "autorifle"
	wielded_loaded_icon = "autorifle-wielded"
	unloaded_icon = "autorifle-e"
	unwielded_unloaded_icon = "autorifle-e"
	wielded_unloaded_icon = "autorifle-wielded-e"
	condition = 75

	magazine_type = /obj/item/ammo_magazine/c45rifle/akarabiner
	allowed_magazines = /obj/item/ammo_magazine/c45rifle/akarabiner
	fire_delay = 0
	firemodes = list()
	w_class = ITEM_SIZE_HUGE
	gun_type = GUN_SEMIAUTO
	//can_have_bayonet = TRUE


/obj/item/gun/projectile/automatic/m22/warmonger/attackby(obj/item/W, mob/user)
	. = ..()
	if(istype(W, /obj/item/material/sword/combat_knife) && can_have_bayonet)
		user.visible_message("[user] attaches a bayonet to the [src].","You attach a bayonet to the [src].")
		user.remove_from_mob(W)
		qdel(W)
		add_bayonet()

/obj/item/gun/projectile/automatic/m22/warmonger/fully_auto
	name = "Mk.5 Warmonger"
	desc = "The same old Warmonger rifle with a fully automatic switch; the grip’s been retextured as well. This is the kind of rifle you want but don’t deserve."
	icon_state = "autorifle-alt"
	item_state = "autorifle-alt"
	wielded_item_state = "autorifle-alt-wielded"
	fire_sound = 'sound/weapons/guns/fire/ak_fire.ogg'
	unload_sound = 'sound/weapons/guns/interact/ak_magout.ogg'
	reload_sound = 'sound/weapons/guns/interact/ak_magin.ogg'
	cock_sound = 'sound/weapons/guns/interact/ak_cock.ogg'

	loaded_icon = "autorifle-alt"
	unwielded_loaded_icon = "autorifle-alt"
	wielded_loaded_icon = "autorifle-alt-wielded"
	unloaded_icon = "autorifle-alt-e"
	unwielded_unloaded_icon = "autorifle-alt-e"
	wielded_unloaded_icon = "autorifle-alt-wielded-e"
	far_fire_sound = 'sound/effects/weapons/gun/ak_farfire.ogg'
	condition = 250

	gun_type = GUN_AUTOMATIC

	firemodes = list(
		list(mode_name="semiauto",       burst=1, fire_delay=0,    move_delay=null, one_hand_penalty=4, burst_accuracy=null, dispersion=null, automatic = 0),
		list(mode_name="automatic",   	 burst=1, fire_delay=0,  move_delay=0, one_hand_penalty=6, burst_accuracy=list(0,-1,-1), dispersion=list(0.0, 3, 5), automatic = 2)
		)


/obj/item/gun/projectile/automatic/m22/warmonger/fully_auto/nemesis
	name = "Mk.1 Nemesis"
	desc = "A rough experiment to bring squad automatic riflesmen to the front lines. It's fully automatic and lighter than the GMPG, but that's where the positives end."
	icon_state = "bar"
	item_state = "bar"
	wielded_item_state = "bar-wielded"
	fire_sound = 'sound/weapons/guns/fire/bar_fire.ogg'
	unload_sound = 'sound/weapons/guns/interact/bar_magout.ogg'
	reload_sound = 'sound/weapons/guns/interact/bar_magin.ogg'
	cock_sound = 'sound/weapons/guns/interact/bar_cock.ogg'
	far_fire_sound = "rifle_fire"

	loaded_icon = "bar"
	unwielded_loaded_icon = "bar"
	wielded_loaded_icon = "bar-wielded"
	unloaded_icon = "bar-e"
	unwielded_unloaded_icon = "bar-e"
	wielded_unloaded_icon = "bar-wielded-e"

/obj/item/gun/projectile/automatic/m22/warmonger/fully_auto/ersatz
	name = "Mk.1 Ersatz"
	desc = "Alternate version of the Mk.5 Warmonger with better handling."
	icon_state = "ersatz"
	item_state = "ersatz"
	wielded_item_state = "ersatz-wielded"
	fire_sound = 'sound/weapons/guns/fire/ak_fire.ogg'
	unload_sound = 'sound/weapons/guns/interact/ak_magout.ogg'
	reload_sound = 'sound/weapons/guns/interact/ak_magin.ogg'
	cock_sound = 'sound/weapons/guns/interact/ak_cock.ogg'
	far_fire_sound = 'sound/effects/weapons/gun/ak_farfire.ogg'

	loaded_icon = "ersatz"
	unwielded_loaded_icon = "ersatz"
	wielded_loaded_icon = "ersatz-wielded"
	unloaded_icon = "ersatz-e"
	unwielded_unloaded_icon = "ersatz-e"
	wielded_unloaded_icon = "ersatz-wielded-e"

	screen_shake = 1

/obj/item/gun/projectile/automatic/m22/warmonger/m14
	name = "M41 Eclipse"
	desc = "A semi-automatic sharpshooter’s rifle made from old war scraps. Its rounds are powerful, but good luck trying to get this thing to work half the time."
	icon_state = "semirifle"
	item_state = "semirifle"
	wielded_item_state = "semirifle-wielded"
	fire_sound = 'sound/weapons/guns/fire/m14_fire.ogg'
	unload_sound = 'sound/weapons/guns/interact/fal_magout.ogg'
	reload_sound = 'sound/weapons/guns/interact/fal_magin.ogg'
	caliber = "a762"
	loaded_icon = "semirifle"
	unwielded_loaded_icon = "semirifle"
	wielded_loaded_icon = "semirifle-wielded"
	unloaded_icon = "semirifle-e"
	unwielded_unloaded_icon = "semirifle-e"
	wielded_unloaded_icon = "battlerifle-wielded-e"
	can_have_bayonet = TRUE

	magazine_type = /obj/item/ammo_magazine/a762/m14
	allowed_magazines = /obj/item/ammo_magazine/a762/m14
	gun_type = GUN_SEMIAUTO

/obj/item/gun/projectile/automatic/m22/warmonger/m14/attackby(obj/item/W, mob/user)
	. = ..()
	if(istype(W, /obj/item/material/sword/combat_knife) && can_have_bayonet)
		user.visible_message("[user] attaches a bayonet to the [src].","You attach a bayonet to the [src].")
		user.remove_from_mob(W)
		qdel(W)
		add_bayonet()

/obj/item/ammo_magazine/a762/m14
	name = "M41 magazine"
	desc = "Found either in your gun, in your satchel, or on the ground empty."
	max_ammo = 20
	icon_state = "autorifle"

/obj/item/gun/projectile/automatic/m22/warmonger/fully_auto/oldlmg
	name = "Mk.4 Warmonger"
	desc = "This is the cousin of the Mk.5 Warmonger. It was designed to cut costs from equipment issuing but ultimately ended up being used less than the Mk.5 Warmonger due to its weird design. It's often called the Trench Sweeper due to its very tight spread and fast firerate."
	icon_state = "lmg-old"
	item_state = "lmg-old"
	wielded_item_state = "lmg-old-wielded"
	fire_sound = 'sound/weapons/guns/fire/old_lmg.ogg'
	unload_sound = 'sound/weapons/guns/interact/ak_magout.ogg'
	reload_sound = 'sound/weapons/guns/interact/ak_magin.ogg'
	cock_sound = 'sound/weapons/guns/interact/ak_cock.ogg'
	far_fire_sound = 'sound/effects/weapons/gun/ak_farfire.ogg'
	condition = 150

	loaded_icon = "lmg-old"
	unwielded_loaded_icon = "lmg-old"
	wielded_loaded_icon = "lmg-old-wielded"
	unloaded_icon = "lmg-old-e"
	unwielded_unloaded_icon = "lmg-old"
	wielded_unloaded_icon = "lmg-old-wielded"

	magazine_type = /obj/item/ammo_magazine/c45rifle/flat
	allowed_magazines = /obj/item/ammo_magazine/c45rifle/flat
	w_class = ITEM_SIZE_HUGE
	gun_type = GUN_AUTOMATIC
	screen_shake = 0.75

	burst=1
	fire_delay=0
	move_delay=0
	one_hand_penalty=10
	burst_accuracy=list(0,-1,-1)
	dispersion=list(0.0, 2, 3)
	automatic = 1.5

/obj/item/gun/projectile/automatic/m22/warmonger/fully_auto/oldlmg/examine(mob/user)
	. = ..()
	if(get_dist(user, src) > 1)
		return
	to_chat(user,SPAN_BOLD("You notice a steel plate with some words stamped into them on the stock:"))
	to_chat(user,SPAN_BOLD("To win one hundred victories in one hundred battles is not the acme of skill. To subdue the enemy without fighting is the acme of skill."))


/obj/item/ammo_magazine/c45rifle/flat
	name = "Warmonger flat magazine"
	desc = "A pancake- Wait a minute! This is just a steel drum magazine!"
	max_ammo = 45
	icon_state = "lmg-oldmag"

/obj/item/gun/projectile/automatic/m22/warmonger/sks //GAAAAAAAAAAAAH
	name = "Mk.1 Headhunter"
	desc = "A faster firing marksman rifle known for its easy reload and solid frame. Much better than a bolt action but just as unreliable."
	icon_state = "sks"
	item_state = "sks"
	wielded_item_state = "sks-wielded"
	fire_sound = 'sound/weapons/guns/fire/sks_fire.ogg'
	unload_sound = 'sound/weapons/guns/interact/sks_magout.ogg'
	reload_sound = 'sound/weapons/guns/interact/sks_magin.ogg'
	cock_sound = 'sound/weapons/guns/interact/sks_cock.ogg'
	far_fire_sound = 'sound/effects/weapons/gun/sks_farfire.ogg'
	caliber = "a762"
	loaded_icon = "sks"
	unwielded_loaded_icon = "sks"
	wielded_loaded_icon = "sks-wielded"
	unloaded_icon = "sks-e"
	unwielded_unloaded_icon = "sks-e"
	wielded_unloaded_icon = "sks-wielded-e"
	auto_eject = TRUE
	auto_eject_sound = 'sound/weapons/guns/interact/sks_magout.ogg' //Magout!
	gun_vary = FALSE

	magazine_type = /obj/item/ammo_magazine/a762/sks
	allowed_magazines = /obj/item/ammo_magazine/a762/sks
	condition = 200
	gun_type = GUN_SEMIAUTO

/obj/item/ammo_magazine/a762/sks
	name = "Headhunter mag"
	desc = "It looks like it should just be a clip, but it actually slides all the way into the gun. Very strange design, but who are you to judge."
	max_ammo = 10
	icon_state = "sksclip"



/obj/item/gun/projectile/automatic/m22/warmonger/allrounder
	name = "Mk.1 Endbringer"
	desc = "Another semi-automatic that was designed to replace older bolt actions from the old war. Instead, it failed and ended up issued alongside them as a supplement."
	icon_state = "allrounder"
	item_state = "allrounder"
	wielded_item_state = "allrounder-wielded"
	fire_sound = 'sound/weapons/guns/fire/allrounder_fire.ogg'
	unload_sound = 'sound/weapons/guns/interact/combatrifle_magout.ogg'
	reload_sound = 'sound/weapons/guns/interact/combatrifle_magin.ogg'
	cock_sound = 'sound/weapons/guns/interact/combatrifle_cock.ogg'
	caliber = "a762"
	loaded_icon = "allrounder"
	unwielded_loaded_icon = "allrounder"
	wielded_loaded_icon = "allrounder-wielded"
	unloaded_icon = "allrounder-e"
	unwielded_unloaded_icon = "allrounder-e"
	wielded_unloaded_icon = "allrounder-wielded-e"

	magazine_type = /obj/item/ammo_magazine/a762/allrounder
	allowed_magazines = /obj/item/ammo_magazine/a762/allrounder
	condition = 200


/obj/item/ammo_magazine/a762/allrounder
	name = "Endbringer magazine"
	desc = "Found either in your gun, in your satchel, or on the ground empty."
	max_ammo = 10
	icon_state = "autorifle"


/obj/item/gun/projectile/automatic/m22/warmonger/m14/battlerifle
	name = "Mk.2 Armageddon"
	desc = "A factory-produced and oiled semi-automatic carbine that's much nicer than whatever scraps those medics are using."
	icon_state = "battlerifle"
	item_state = "battlerifle"
	wielded_item_state = "battlerifle-wielded"
	fire_sound = 'sound/weapons/guns/fire/fal_fire.ogg'

	magazine_type = /obj/item/ammo_magazine/a762/m14/battlerifle_mag
	allowed_magazines = list(/obj/item/ammo_magazine/a762/m14/battlerifle_mag, /obj/item/ammo_magazine/c45rifle/akarabiner)
	gun_type = GUN_SEMIAUTO

	loaded_icon = "battlerifle"
	unwielded_loaded_icon = "battlerifle"
	wielded_loaded_icon = "battlerifle-wielded"
	unloaded_icon = "battlerifle-e"
	unwielded_unloaded_icon = "battlerifle-e"
	wielded_unloaded_icon = "battlerifle-wielded-e"

/obj/item/ammo_magazine/a762/m14/battlerifle_mag
	name = "Armageddon magazine"


/obj/item/gun/projectile/automatic/m22/warmonger/m14/battlerifle/rsc
	name = "Mk.1 Armageddon"
	desc = "The first interation of the Armageddon carbine, utilizing a specific clip design. It's bad, but it might just hold up in a real fight."
	icon_state = "rsc"
	item_state = "rsc"
	wielded_item_state = "rsc-wielded"

	magazine_type = /obj/item/ammo_magazine/a762/rsc
	allowed_magazines = /obj/item/ammo_magazine/a762/rsc
	gun_type = GUN_SEMIAUTO

	caliber = "763"

	loaded_icon = "rsc"
	unwielded_loaded_icon = "rsc"
	wielded_loaded_icon = "rsc-wielded"
	unloaded_icon = "rsc-e"
	unwielded_unloaded_icon = "rsc-e"
	wielded_unloaded_icon = "rsc-wielded-e"

/obj/item/ammo_magazine/a762/rsc
	icon_state = "rsc"
	name = "Armageddon clip"
	max_ammo = 5
	desc = "A clip for the MK.1 Armageddon."
	caliber = "763"
	ammo_type = /obj/item/ammo_casing/brifle

/obj/item/gun/projectile/automatic/m22/combatrifle
	name = "Mk. 2 Nightfall"
	desc = "An advanced design from post war days, with a rock solid frame and firm parts. It’s got a selective fire switch, and it might even hit what you're aiming at."
	icon_state = "combatrifle"
	item_state ="combatrifle"
	magazine_type = /obj/item/ammo_magazine/c45rifle/combatrifle
	allowed_magazines = /obj/item/ammo_magazine/c45rifle/combatrifle
	one_hand_penalty = 5
	wielded_item_state = "combatrifle-wielded"
	fire_sound = 'sound/weapons/guns/fire/combatrifle_fire.ogg'
	unload_sound = 'sound/weapons/guns/interact/combatrifle_magout.ogg'
	reload_sound = 'sound/weapons/guns/interact/combatrifle_magin.ogg'
	cock_sound = 'sound/weapons/guns/interact/combatrifle_cock.ogg'

	loaded_icon = "combatrifle"
	unwielded_loaded_icon = "combatrifle"
	wielded_loaded_icon = "combatrifle-wielded"
	unloaded_icon = "combatrifle-e"
	unwielded_unloaded_icon = "combatrifle-e"
	wielded_unloaded_icon = "combatrifle-wielded-e"

	gun_type = GUN_AUTOMATIC

	w_class = ITEM_SIZE_HUGE

	//Assault rifle, burst fire degrades quicker than SMG, worse one-handing penalty, slightly increased move delay
	firemodes = list(
		list(mode_name="semiauto",       burst=1, fire_delay=0,    move_delay=null, one_hand_penalty=4, burst_accuracy=null, dispersion=null, automatic = 0),
		list(mode_name="automatic",   	 burst=1, fire_delay=0,  move_delay=0, one_hand_penalty=6, burst_accuracy=list(0,-1,-1), dispersion=list(0.0, 3, 5), automatic = 2)
		)


/obj/item/gun/projectile/automatic/mg08
	name = "LMG Harbinger"
	desc = "Named for the death it brings."
	//icon = 'icons/obj/gunx35.dmi'
	icon_state = "hmg"
	item_state = "hmg"
	str_requirement = 18
	w_class = ITEM_SIZE_HUGE
	force = 10
	slot_flags = SLOT_BACK|SLOT_S_STORE
	max_shells = 50
	caliber = "a556"
	origin_tech = list(TECH_COMBAT = 6, TECH_MATERIAL = 1, TECH_ILLEGAL = 2)
	ammo_type = /obj/item/ammo_casing/a556
	load_method = MAGAZINE
	magazine_type = /obj/item/ammo_magazine/box/a556/mg08
	allowed_magazines = /obj/item/ammo_magazine/box/a556/mg08
	one_hand_penalty = 50
	wielded_item_state = "hmg-wielded"
	fire_sound = 'sound/weapons/gunshot/harbinger.ogg'//fire_sound = 'sound/weapons/gunshot/hmg.ogg'
	fire_volume = 55 // BIIG EVIL FUCKING GUUN
	unload_sound 	= 'sound/weapons/guns/interact/ltrifle_magout.ogg'
	reload_sound 	= 'sound/weapons/guns/interact/ltrifle_magin.ogg'
	cock_sound 		= 'sound/weapons/guns/interact/ltrifle_cock.ogg'
	loaded_icon = "hmg"
	unwielded_loaded_icon = "hmg"
	wielded_loaded_icon = "hmg-wielded"
	unloaded_icon = "hmg-e"
	unwielded_unloaded_icon = "hmg-e"
	wielded_unloaded_icon = "hmg-wielded-e"
	fire_delay=2
	burst=1
	move_delay=12
	one_hand_penalty=8
	automatic = 2
	firemodes = list()
	gun_type = GUN_LMG
	condition = 300 //Enough for two clean mags.
	var/deployed = FALSE

/obj/item/gun/projectile/automatic/mg08/special_check(var/mob/user)
	if(misfire)
		return 1
	if(!deployed)//Can't fire.
		to_chat(user, "<span class='danger'>I can't fire it if it's not deployed.</span>")
		return 0
	return ..()


/obj/item/gun/projectile/automatic/mg08/attack_self(mob/user)
	. = ..()
	if(deployed)//If there's an mg deployed, then pack it up again.
		pack_up_mg(user)
	else
		deploy_mg(user)//Otherwise, deploy that motherfucker.

/obj/item/gun/projectile/automatic/mg08/proc/deploy_mg(mob/user)
	if(user.doing_something)
		return
	for(var/obj/structure/mg08_structure/M in user.loc)//If there's already an mg there then don't deploy it. Dunno how that's possible but stranger things have happened.
		if(M)
			to_chat(user, "There is already an LMG here.")
			return
	user.visible_message("[user] starts to deploy the [src]")
	user.doing_something = TRUE
	if(!do_after(user,30))
		user.doing_something = FALSE //Prevents Permanently being unable to deploy harbingers
		return
	user.doing_something = FALSE
	var/obj/structure/mg08_structure/M = new(get_turf(user)) //Make a new one here.
	M.dir = user.dir
	switch(M.dir)
		if(EAST)
			user.pixel_x -= 5
		if(WEST)
			user.pixel_x += 5
		if(NORTH)
			user.pixel_y -= 5
		if(SOUTH)
			user.pixel_y += 5
			M.plane = ABOVE_HUMAN_PLANE
	deployed = TRUE
	playsound(src, 'sound/weapons/mortar_deploy.ogg', 100, FALSE)
	update_icon(user)

/obj/item/gun/projectile/automatic/mg08/proc/pack_up_mg(mob/user)
	user.visible_message("[user] packs up the [src]")
	for(var/obj/structure/mg08_structure/M in user.loc)
		switch(M.dir)//Set our offset back to normal.
			if(EAST)
				user.pixel_x += 5
			if(WEST)
				user.pixel_x -= 5
			if(NORTH)
				user.pixel_y += 5
			if(SOUTH)
				user.pixel_y -= 5
		qdel(M) //Delete the mg structure.
	deployed = FALSE
	update_icon(user)

/obj/item/gun/projectile/automatic/mg08/dropped(mob/user)
	. = ..()
	if(deployed)
		pack_up_mg(user)

/obj/item/gun/projectile/automatic/mg08/equipped(var/mob/user, var/slot)
	..()
	if((slot == slot_back) || (slot == slot_s_store))
		. = ..()
		if(deployed)
			pack_up_mg(user)

/obj/structure/mg08_structure //That thing that's created when you place down your mg, purely for looks.
	name = "Deployed LMG Harbinger"
	anchored = TRUE //No moving this around please.

/obj/structure/mg08/CanPass(atom/movable/mover, turf/target, height, air_group)//Humans cannot pass cross this thing in any way shape or form.
	if(ishuman(mover))
		var/mob/living/carbon/human/H = mover
		if(locate(/obj/item/gun/projectile/automatic/mg08) in H)//Locate the mg.
			if(istype(H.l_hand, /obj/item/gun/projectile/automatic/mg08))
				var/obj/item/gun/projectile/automatic/mg08/gun = H.l_hand
				switch(gun.deployed)
					if(TRUE) return FALSE
					if(FALSE)
						qdel(src)
						return TRUE
			if(istype(H.r_hand, /obj/item/gun/projectile/automatic/mg08))
				var/obj/item/gun/projectile/automatic/mg08/gun = H.r_hand
				switch(gun.deployed)
					if(TRUE) return FALSE
					if(FALSE)
						qdel(src)
						return TRUE
		qdel(src)
		return TRUE
	else
		return TRUE


/obj/structure/mg08_structure/CheckExit(atom/movable/O, turf/target)//Humans can't leave this thing either.
	if(ishuman(O))
		var/mob/living/carbon/human/H = O
		if(locate(/obj/item/gun/projectile/automatic/mg08) in H)//Locate the mg.
			if(istype(H.l_hand, /obj/item/gun/projectile/automatic/mg08))
				var/obj/item/gun/projectile/automatic/mg08/gun = H.l_hand
				switch(gun.deployed)
					if(TRUE) return FALSE
					if(FALSE)
						qdel(src)
						return TRUE
			if(istype(H.r_hand, /obj/item/gun/projectile/automatic/mg08))
				var/obj/item/gun/projectile/automatic/mg08/gun = H.r_hand
				switch(gun.deployed)
					if(TRUE) return FALSE
					if(FALSE)
						qdel(src)
						return TRUE
		qdel(src)
		return TRUE
	else
		return TRUE

/obj/structure/mg08_structure/rotate/proc/rotate()//Can't rotate it.
	return

/obj/item/gun/projectile/automatic/gpmg
	name = "GPMG Requiem"
	desc = "A coveted LMG. Lighter than the Harbingers of the old war, but still just as deadly!"
	icon_state = "lmg"
	item_state = "lmg"
	wielded_item_state = "lmg-wielded"
	loaded_icon = "lmg"
	unwielded_loaded_icon = "lmg"
	wielded_loaded_icon = "lmg-wielded"
	unloaded_icon = "lmg-e"
	unwielded_unloaded_icon = "lmg-e"
	wielded_unloaded_icon = "lmg-wielded-e"
	str_requirement = 16
	w_class = ITEM_SIZE_HUGE
	force = 10
	slot_flags = SLOT_BACK|SLOT_S_STORE
	max_shells = 50
	caliber = "a556"
	origin_tech = list(TECH_COMBAT = 6, TECH_MATERIAL = 1, TECH_ILLEGAL = 2)
	ammo_type = /obj/item/ammo_casing/a556
	load_method = MAGAZINE
	magazine_type = /obj/item/ammo_magazine/box/a556/mg08
	allowed_magazines = /obj/item/ammo_magazine/box/a556/mg08
	one_hand_penalty = 50
	fire_sound = 'sound/weapons/gunshot/harbinger.ogg'
	unload_sound 	= 'sound/weapons/guns/interact/ltrifle_magout.ogg'
	reload_sound 	= 'sound/weapons/guns/interact/ltrifle_magin.ogg'
	cock_sound 		= 'sound/weapons/guns/interact/ltrifle_cock.ogg'
	fire_delay=2
	burst=1
	can_jam = FALSE
	one_hand_penalty=8
	burst_accuracy=list(0,-1,-1)
	dispersion=list(0.0, 3, 5)
	automatic = 2
	firemodes = list()
	gun_type = GUN_LMG

/obj/item/gun/projectile/automatic/machinepistol
	name = "Mk.2 Soulburn SMG"
	desc = "A submachine gun, which is misleading because it's a shredder. It puts a LOT of bullets down range, capable of killing an infantryman in mere seconds, but it has a flimsy wire stock."
	icon_state = "machinepistol"
	item_state = "machinepistol"
	wielded_item_state = "machinepistol-wielded"
	one_hand_penalty = 50
	slot_flags = SLOT_BACK|SLOT_S_STORE
	w_class = ITEM_SIZE_HUGE
	condition = 250
	can_have_bayonet = TRUE

	fire_sound = 'sound/weapons/guns/fire/smg_fire.ogg'

	magazine_type = /obj/item/ammo_magazine/mc9mmt/machinepistol
	allowed_magazines = /obj/item/ammo_magazine/mc9mmt/machinepistol

	loaded_icon = "machinepistol"
	unwielded_loaded_icon = "machinepistol"
	wielded_loaded_icon = "machinepistol-wielded"
	unloaded_icon = "machinepistol-e"
	unwielded_unloaded_icon = "machinepistol-e"
	wielded_unloaded_icon = "machinepistol-e"

	gun_type = GUN_SMG

/obj/item/gun/projectile/automatic/machinepistol/attackby(obj/item/W, mob/user)
	. = ..()
	if(istype(W, /obj/item/material/sword/combat_knife) && can_have_bayonet)
		user.visible_message("[user] attaches a bayonet to the [src].","You attach a bayonet to the [src].")
		user.remove_from_mob(W)
		qdel(W)
		add_bayonet()

/obj/item/gun/projectile/automatic/machinepistol/set_gun_attachment_offsets()
	attachable_offset = list("muzzle_x" = 32, "muzzle_y" = 18,"rail_x" = 12, "rail_y" = 24, "under_x" = 24, "under_y" = 14, "stock_x" = 24, "stock_y" = 13, "special_x" = 28, "special_y" = 16)

/obj/item/gun/projectile/automatic/machinepistol/wooden
	name = "Mk.1 Soulburn SMG"
	desc = "A prototype of what? I have no clue. It feels relatively new, and I’ve been told its high fire rate puts rounds downrange faster than any machine gun. those early production parts are practically exposed. I'm not an engineer but  I think this thing is going to malfunction."
	icon = 'icons/obj/gun.dmi'
	//condition_icon = 'icons/obj/gun32x64.dmi'
	//icon_state = "auto1"
	//loaded_icon = "auto1"
	//unloaded_icon = "auto1"
	//bayonet_icon ='icons/obj/gun32x64.dmi'
	icon_state = "schmeiser"
	item_state = "schmeiser"
	wielded_item_state = "schmeiser-wielded"

	//loaded_icon = "schmeiser"
	unwielded_loaded_icon = "schmeiser"
	wielded_loaded_icon = "schmeiser-wielded"
	//unloaded_icon = "schmeiser-e"
	unwielded_unloaded_icon = "schmeiser-e"
	wielded_unloaded_icon = "schmeiser-e"

/obj/item/gun/projectile/automatic/flamer
	name = "Mk.1 Scorcher"
	desc = "Just looking at this thing makes my stomach churn. It has this sickly smell of decaying flesh, I saw one of these clear an entire trench once, leaving nothing but charred remains and smoke."
	icon_state = "flamer"
	item_state = "flamer"
	wielded_item_state = "flamer-wielded"
	caliber = "flamer"
	one_hand_penalty = 50
	str_requirement = 18
	fire_sound = "flamer_fire"
	handle_casings = CLEAR_CASINGS
	casingsound = null//No eject sound for you.
	firemodes = list()
	automatic = 0.1
	fire_delay=0
	burst=1
	magazine_type = /obj/item/ammo_magazine/flamer
	allowed_magazines = /obj/item/ammo_magazine/flamer
	can_jam = FALSE

	unload_sound = 'sound/weapons/guns/interact/flamer_remove.ogg'
	reload_sound = 'sound/weapons/guns/interact/flamer_insert.ogg'

	loaded_icon = "flamer"
	unwielded_loaded_icon = "flamer"
	wielded_loaded_icon = "flamer-wielded"
	unloaded_icon = "flamer-e"
	unwielded_unloaded_icon = "flamer-e"
	wielded_unloaded_icon = "flamer-wielded-e"

	gun_type = GUN_PISTOL //anyone can use this... just not anyone should.



/obj/item/gun/projectile/automatic/autoshotty
	name = "MS Warcrime"
	desc = "This thing looks like a cross between one of those sleek, newer rifles and a shotgun. The automatic fire feels almost wrong, Despite being buried in dirt for ages, the feed and ejection are surprisingly well maintained. It’s unsettling to think that this weapon can turn a man inside out in eight different ways in under five sixths of a second. No wonder it earned its nickname."
	icon_state = "autoshotty"
	item_state = "autoshotty"
	wielded_item_state = "autoshotty"
	magazine_type = /obj/item/ammo_magazine/autoshotty
	allowed_magazines = /obj/item/ammo_magazine/autoshotty
	caliber = "shotgun"
	fire_sound = 'sound/weapons/guns/fire/autoshotty_fire.ogg'
	ammo_type = /obj/item/ammo_casing/shotgun/newshot
	reload_sound = 'sound/weapons/guns/interact/autoshotty_magin.ogg'
	unload_sound = 'sound/weapons/guns/interact/autoshotty_magout.ogg'
	cock_sound = 'sound/weapons/guns/interact/autoshotty_cock.ogg'
	slot_flags = SLOT_BACK|SLOT_S_STORE
	loaded_icon = "autoshotty"
	unwielded_loaded_icon = "autoshotty"
	wielded_loaded_icon = "autoshotty-wielded"
	unloaded_icon = "autoshotty-e"
	unwielded_unloaded_icon = "autoshotty-e"
	wielded_unloaded_icon = "autoshotty-wielded-e"
	burst=1
	fire_delay=2
	one_hand_penalty=7
	dispersion=list(0.0, 0.8, 1.5)
	automatic = 2
	firemodes = list()

	gun_type = GUN_SHOTGUN

/obj/item/ammo_magazine/autoshotty
	name = "Warcrime mag"
	desc = "Just looking at it makes you bloodthirsty."
	icon_state = "autoshotty"
	caliber = "shotgun"
	mag_type = MAGAZINE
	ammo_type = /obj/item/ammo_casing/shotgun/newshot
	max_ammo = 6
	multiple_sprites = 1


/obj/item/gun/projectile/warfare
	name = "Mk.1 Reckoning"
	icon_state = "handgun"
	item_state = "handgun"
	fire_sound = "gunshot"//Pistol sounds.
	desc = "A 45 caliber pistol that will put holes in your enemy if you're lucky. Better than nothing, but not by much."
	magazine_type = /obj/item/ammo_magazine/c45m/warfare
	allowed_magazines = /obj/item/ammo_magazine/c45m/warfare
	caliber = ".45"
	load_method = MAGAZINE
	fire_delay = 4

/obj/item/gun/projectile/warfare/update_icon()//We gotta snowflake this a bit.
	..()
	if(ammo_magazine)
		if(ammo_magazine.stored_ammo.len)
			icon_state = "[initial(icon_state)][ammo_magazine.stored_ammo.len]"
		else
			icon_state = "[initial(icon_state)]0"
	else
		icon_state = "handgun-e"


/obj/item/ammo_magazine/c45m/warfare
	name = "Reckoning magazine (.45)"
	icon_state = "handgunmag"
	mag_type = MAGAZINE
	ammo_type = /obj/item/ammo_casing/c45
	caliber = ".45"
	max_ammo = 7
	multiple_sprites = 1

/obj/item/gun/projectile/golt
	name = "Mk.1 Golt"
	icon_state = "colt"
	unloaded_icon = "colt-e"
	item_state = "handgun"
	fire_sound = "sound/weapons/guns/fire/pistol1.ogg"
	desc = "Potent handgun that fires an unwieldy and unusual caliber, denotated 'Wristfucker'."
	magazine_type = /obj/item/ammo_magazine/a50
	allowed_magazines = /obj/item/ammo_magazine/a50
	caliber = ".50"
	load_method = MAGAZINE
	fire_delay = 5
	condition = 75

/obj/item/gun/projectile/shotgun/pump/boltaction/grenadelauncher
	name = "GRA Pubtrator"
	desc = "These wooden grips feel like they could splinter at any moment, clinging to a skeletal metal frame of low grade tubes.\n It’s got an over-under barrel setup, nothing fancy. We load it with whatever fits: chlorine gas, fragmentation grenades, and even the occasional smoke round.\n It’s cheap metal, so the barrel heat up too fast, and the grip breaks apart sometimes. I struggle to hold it together.\n That’s the General’s genius; he knows exactly what he’s doing. He doesn’t care if the thing falls apart mid fight; he’s already cashed the check."
	icon = 'icons/obj/gun.dmi'
	icon_state = "zof"
	wielded_item_state = "autorifle-wielded"
	fire_sound = "launcher_fire"
	loaded_icon = "zof"
	ammo_type = /obj/item/ammo_casing/grenade
	max_shells = 1
	caliber = "a40mm"
	condition = 75
	fire_delay = 0
	one_hand_penalty = 50
	str_requirement = 8
	slowdown_general = 0.25
	reload_sound 		= 'sound/weapons/guns/interact/launcher_insert.ogg'
	bulletinsert_sound 	= 'sound/weapons/guns/interact/launcher_insert.ogg'
	forwardsound 		= 'sound/weapons/guns/interact/launcher_rack.ogg'
	pumpsound			= 'sound/weapons/guns/interact/launcher_rack.ogg'
	starts_loaded = FALSE
	unload_sound = null
	casingsound = null

/obj/item/ammo_casing/grenade/ // BASE ITEM

/obj/item/ammo_casing/grenade/frag
	name = "40mm \"Ripper\" Round"
	desc = "This shell is warm to the touch, coated in a layer of grime.\n The metal is scratched and dented, with a very small heart crudely carved into the side.\n I’ve seen what this thing can do to a man, let alone a whole room. The integrity of the shell is questionable; it looks like it could either explode in a glorious fireball or just fizzle out in disappointment.\n Either way, I wouldn't want to be anywhere near it when it goes off."
	caliber = "a40mm"
	projectile_type = /obj/item/projectile/bullet/grenade/frag
	icon_state = "grenade_frag"
	spent_icon = "null"

/obj/item/ammo_casing/grenade/smoke
	name = "40mm Peacekeeping Pacification Round"
	desc = "This shell is cold to the touch, its markings faded and worn away from a millennia of neglect. I know The Authority is particularly fond of using these things to disperse crowds, but the name won’t fool me. They’ve been issued to our unit as well, and safe to say, these aren't rubber balls, that’s for damn sure."
	caliber = "a40mm"
	projectile_type = /obj/item/projectile/bullet/grenade/smoke
	icon_state = "grenade_smoke"

/obj/item/projectile/bullet/grenade
	icon = 'icons/obj/ammo.dmi'
	icon_state = "frag_fired"
	fire_sound = null
	damage = 25
	armor_penetration = 5
	embed = 0
	sharp = 0
	hitscan = FALSE
	speed = 0.4
	var/num_fragments = 200
	var/explosion_size = 3
	var/spread_range = 7 //leave as is, for some reason setting this higher makes the spread pattern have gaps close to the epicenter
	var/list/fragment_types = list(/obj/item/projectile/bullet/pellet/fragment = 1)

/obj/item/projectile/bullet/grenade/proc/on_explosion(var/O)
	O = get_turf(src)
	if(!O) return
	if(explosion_size)
		explosion(O, -1, -1, explosion_size, round(explosion_size/2), 0, particles = TRUE, large = FALSE, color = COLOR_BLACK, autosize = FALSE, sizeofboom = 1, explosionsound = pick('sound/effects/mortarexplo1.ogg','sound/effects/mortarexplo2.ogg','sound/effects/mortarexplo3.ogg'), farexplosionsound = pick('sound/effects/farexplonewnew1.ogg','sound/effects/farexplonewnew2.ogg','sound/effects/farexplonewnew3.ogg'))

/obj/item/projectile/bullet/grenade/on_impact(var/atom/target, var/blocked = 0)
	return FALSE

/obj/item/projectile/bullet/grenade/on_hit(atom/target)
    on_explosion()

/obj/item/projectile/bullet/grenade/frag/on_explosion(O)
	. = ..()
	src.fragmentate(O, num_fragments, spread_range, fragment_types)

/obj/effect/abstract/smoke/New()
	var/datum/effect/effect/system/smoke_spread/smoke
	smoke = new /datum/effect/effect/system/smoke_spread()
	smoke.attach(src)
	playsound(src.loc, 'sound/effects/smoke.ogg', 50)
	smoke.set_up(10, 0, src.loc)
	spawn(0)
		smoke.start()
		sleep(10)
		smoke.start()
		sleep(10)
		smoke.start()
		sleep(10)
		smoke.start()
	sleep(80)
	qdel(smoke)
	smoke = null
	qdel(src)

/obj/item/projectile/bullet/grenade/smoke/
	icon_state = "smoke_fired"

/obj/item/projectile/bullet/grenade/smoke/on_explosion()
	var/turf/T = src.loc
	qdel(src)
	new/obj/effect/abstract/smoke(T)


	//Shig 420
/obj/item/gun/projectile/warfare/shig
	name = "Shig 420"
	icon_state = "handgun"
	item_state = "handgun"
	fire_sound = "gunshot"//Pistol sounds.
	desc = "A cutting edge innovation in weapons technology. It always lands a shot. The fact that it's your own skin half the time doesn't matter. It's the Shig 420! It'll win us the war!"

/obj/item/gun/projectile/warfare/shig/attackby(obj/item/W, mob/user)
	. = ..()
	handleMisfire(user)

/obj/item/gun/projectile/warfare/shig/grab_sound(mob/living/carbon/human/user)
	. = ..()
	handleMisfire(user)

/obj/item/gun/projectile/warfare/shig/examine(mob/user)
	. = ..()
	if(get_dist(user, src) > 1)
		return
	to_chat(user,SPAN_MINDVOICE("Who even allowed this to be sent to the front?"))
	if(user.HasRoleSimpleCheck("Red Captain") || user.HasRoleSimpleCheck("Blue Captain"))
		to_chat(user,SPAN_MINDVOICE("<b>I did. Everyone on the War Council did. Do they not understand how desperate the situation is?</b>"))

/obj/item/gun/projectile/warfare/shig/proc/handleMisfire(mob/victim)
	if(calculateMisfire())
		to_chat(victim,SPAN_DANGER("The Shig 420 misfires! Why did our team purchase this stupid thing?!"))
		Fire(victim,victim)

/obj/item/gun/projectile/warfare/shig/proc/calculateMisfire() //straight 50/50 chance. It's the shig420 after all.
	var/willMisfire = rand(1,2)
	if(willMisfire == 1)
		return TRUE
	else if(willMisfire == 2)
		return FALSE
	else
		//to_chat(usr,"DIVINE INTERVENTION! NOFITFY AN ADMIN!") //here to check if actually doing a fair 50/50 roll
		return FALSE

/*
/obj/item/gun/projectile/warfare/shig/evil
	name = "Shig 420"
	desc = SPAN_DANGER("I shouldn't touch this... I shouldn't even look at it...\n\nBy god... What have we done?")
*/