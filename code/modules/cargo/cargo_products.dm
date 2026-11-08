/decl/cargo_product
	var/name = "Unknown Product"
	var/price = 0
	var/description = "No description available."
	var/category = "Miscellaneous"
	var/faction_id = null
	var/crate_type = /obj/structure/closet/crate/war_metal
	var/list/contents
	var/job_path

/decl/cargo_product/job
/decl/cargo_product/crate
/decl/cargo_product/train
	price = 0





CARGO_CRATE_PRODUCT(rifle_ammo, "Rifle Ammo Pack", 50, "Brass.Co Ammunitions", list(/obj/item/ammo_box/rifle = 10), /obj/structure/closet/crate/war_metal, null)
CARGO_CRATE_PRODUCT(modern_rifle_ammo, "Modern Rifle Ammo Pack", 50, "Brass.Co Ammunitions", list(/obj/item/ammo_box/rifle/modern = 10), /obj/structure/closet/crate/war_metal, null)
CARGO_CRATE_PRODUCT(shotgun_ammo, "Shotgun Ammo Pack", 100, "Brass.Co Ammunitions", list(/obj/item/ammo_box/shotgun = 10), /obj/structure/closet/crate/war_metal, null)
CARGO_CRATE_PRODUCT(pistol_ammo, "Pistol Ammo Pack", 50, "Brass.Co Ammunitions", list(/obj/item/ammo_magazine/c45m/warfare = 10, /obj/item/ammo_magazine/a50 = 5), /obj/structure/closet/crate/war_metal, null)
CARGO_CRATE_PRODUCT(revolver_ammo, "Revolver Ammo Pack", 50, "Brass.Co Ammunitions", list(/obj/item/ammo_magazine/handful/revolver = 10), /obj/structure/closet/crate/war_metal, null)
CARGO_CRATE_PRODUCT(hmg_ammo, "HMG Ammo Pack", 50, "Brass.Co Ammunitions", list(/obj/item/ammo_magazine/box/a556/mg08 = 5), /obj/structure/closet/crate/war_metal, null)
CARGO_CRATE_PRODUCT(old_lmg_ammo, "Old LMG Ammo Pack", 50, "Brass.Co Ammunitions", list(/obj/item/ammo_magazine/c45rifle/flat = 5), /obj/structure/closet/crate/war_metal, null)
CARGO_CRATE_PRODUCT(armageddon_ammo, "Armageddon Ammo Pack", 50, "Brass.Co Ammunitions", list(/obj/item/ammo_magazine/a762/m14/battlerifle_mag = 3, /obj/item/ammo_magazine/a762/rsc = 3), /obj/structure/closet/crate/war_metal, null)
CARGO_CRATE_PRODUCT(warcrime_ammo, "Warcrime Ammo Pack", 50, "Brass.Co Ammunitions", list(/obj/item/ammo_magazine/autoshotty = 5), /obj/structure/closet/crate/war_metal, null)
CARGO_CRATE_PRODUCT(warmonger_ammo, "Warmonger Ammo", 50, "Brass.Co Ammunitions", list(/obj/item/ammo_magazine/c45rifle/akarabiner = 10), /obj/structure/closet/crate/war_metal, null)
CARGO_CRATE_PRODUCT(flamer_ammo, "Flamethrower Ammo Pack", 100, "Brass.Co Ammunitions", list(/obj/item/ammo_magazine/flamer = 5), /obj/structure/closet/crate/war_metal, null)
CARGO_CRATE_PRODUCT(ptsd_ammo, "PTSD Ammo Pack", 100, "Brass.Co Ammunitions", list(/obj/item/ammo_box/ptsd = 5), /obj/structure/closet/crate/war_metal, null)
CARGO_CRATE_PRODUCT(mortar_ammo, "Mortar Ammo", 100, "Brass.Co Ammunitions", list(/obj/item/mortar_shell = 8), /obj/structure/closet/crate/war_metal, null)

CARGO_CRATE_PRODUCT(shotgun_pack, "Shotgun Pack", 100, "Brass.Co Top-Brass", list(/obj/item/gun/projectile/shotgun/pump/shitty = 5), /obj/structure/closet/crate/war_metal, null)
CARGO_CRATE_PRODUCT(pistol_pack, "Pistol Pack", 100, "Brass.Co Top-Brass", list(/obj/item/gun/projectile/golt = 2, /obj/item/gun/projectile/warfare = 3), /obj/structure/closet/crate/war_metal, null)
CARGO_CRATE_PRODUCT(harbinger_pack, "Harbinger Pack", 100, "Brass.Co Top-Brass", list(/obj/item/gun/projectile/automatic/mg08 = 2), /obj/structure/closet/crate/war_metal, null)
CARGO_CRATE_PRODUCT(warmonger_pack, "Warmonger Pack", 100, "Brass.Co Top-Brass", list(/obj/item/gun/projectile/automatic/m22/warmonger = 10), /obj/structure/closet/crate/war_metal, null)
CARGO_CRATE_PRODUCT(shovel_pack, "Shovel Pack", 35, "Tools", list(/obj/item/shovel = 5), /obj/structure/closet/crate/war_metal, null)
CARGO_CRATE_PRODUCT(machete_pack, "Machete Pack", 50, "Tools", list(/obj/item/material/hatchet/machete = 4), /obj/structure/closet/crate/war_metal, null)
CARGO_CRATE_PRODUCT(barrier_pack, "Defensive Barrier Pack", 50, "Sil's Utility Corps", list(/obj/item/defensive_barrier = 3), /obj/structure/closet/crate/war_metal, null)
CARGO_CRATE_PRODUCT(doublebarrel_pack, "Doublebarrel Shotgun Pack", 100, "Brass.Co Top-Brass", list(/obj/item/gun/projectile/shotgun/doublebarrel = 5), /obj/structure/closet/crate/war_metal, null)
CARGO_CRATE_PRODUCT(boltaction_pack, "Bolt Action Rifle Pack", 50, "Brass.Co Top-Brass", list(/obj/item/gun/projectile/shotgun/pump/boltaction/shitty/leverchester = 10), /obj/structure/closet/crate/war_metal, null)
CARGO_CRATE_PRODUCT(flamemaster_pack, "Flamethrower Pack", 200, "Brass.Co Top-Brass", list(/obj/item/gun/projectile/automatic/flamer = 1, /obj/item/ammo_magazine/flamer = 2), /obj/structure/closet/crate/war_metal, null)
CARGO_CRATE_PRODUCT(frag_pack, "Frag Grenade Pack", 300, "Brass.Co Top-Brass", list(/obj/item/grenade/frag/warfare = 5), /obj/structure/closet/crate/war_metal, null)
CARGO_CRATE_PRODUCT(trenchclub_pack, "Trench Club Pack", 100, "Brass.Co Top-Brass", list(/obj/item/melee/classic_baton/trench_club = 5), /obj/structure/closet/crate/war_metal, null)
CARGO_CRATE_PRODUCT(revolver_pack, "Trenchman Revolver Pack", 200, "Brass.Co Top-Brass", list(/obj/item/gun/projectile/revolver/manual/ = 5), /obj/structure/closet/crate/war_metal, null)
CARGO_CRATE_PRODUCT(mortar_pack, "Mortar Pack", 500, "Brass.Co Top-Brass", list(/obj/item/mortar_launcher = 2, /obj/item/mortar_shell = 6), /obj/structure/closet/crate/secure/weapon, null)

CARGO_CRATE_PRODUCT(barbwire_pack, "Barbwire Pack", 50, "Sil's Utility Corps", list(/obj/item/stack/barbwire = 5), /obj/structure/closet/crate/war_metal, null)
CARGO_CRATE_PRODUCT(bodybag_pack, "Bodybag Pack", 5, "Daisy's Panacea", list(/obj/item/storage/box/bodybags = 3), /obj/structure/closet/crate/war_metal, null)
CARGO_CRATE_PRODUCT(cigarette_pack, "Cigarette Pack", 50, "ChowField Provisions", list(/obj/item/storage/fancy/cigarettes = 10), /obj/structure/closet/crate/war_metal, null)
CARGO_CRATE_PRODUCT(firstaid_pack, "First Aid Pack", 100, "Daisy's Panacea", list(/obj/item/storage/firstaid/regular = 5), /obj/structure/closet/crate/war_metal, null)
CARGO_CRATE_PRODUCT(advfirstaid_pack, "Advanced First Aid Pack", 200, "Daisy's Panacea", list(/obj/item/storage/firstaid/adv = 5), /obj/structure/closet/crate/war_metal, null)
CARGO_CRATE_PRODUCT(medbelt_pack, "Medical Belt Pack", 50, "Daisy's Panacea", list(/obj/item/storage/belt/medical/full = 10), /obj/structure/closet/crate/war_metal, null)
CARGO_CRATE_PRODUCT(booze_pack, "Booze Pack", 100, "ChowField Provisions", list(/obj/random/drinkbottle = 8), /obj/structure/closet/crate/war_metal, null)
CARGO_CRATE_PRODUCT(atepoine_pack, "Atepoine Pack", 50, "Daisy's Panacea", list(/obj/item/reagent_containers/hypospray/autoinjector/revive = 10), /obj/structure/closet/crate/war_metal, null)
CARGO_CRATE_PRODUCT(smoke_pack, "Smoke Grenade Pack", 150, "Sil's Utility Corps", list(/obj/item/grenade/smokebomb = 5), /obj/structure/closet/crate/war_metal, null)
CARGO_CRATE_PRODUCT(prosthetic_pack, "Prosthetic Limbs Pack", 200, "Daisy's Panacea", list(/obj/item/organ/external/arm/robo_arm = 2, /obj/item/organ/external/arm/right/robo_arm = 2, /obj/item/organ/external/hand/robo_hand = 2, /obj/item/organ/external/hand/right/robo_hand = 2, /obj/item/organ/external/leg/robo_leg = 2, /obj/item/organ/external/leg/right/robo_leg = 2, /obj/item/organ/external/foot/robo_foot = 2, /obj/item/organ/external/foot/right/robo_foot = 2), /obj/structure/closet/crate/war_metal, null)
CARGO_CRATE_PRODUCT(blood_pack, "Blood Injector Pack", 50, "Daisy's Panacea", list(/obj/item/reagent_containers/hypospray/autoinjector/blood = 10), /obj/structure/closet/crate/war_metal, null)

CARGO_JOB_PRODUCT(reinforcements, "Reinforcements", 750, "Units", "none", null)


CARGO_CRATE_PRODUCT(lantern_pack, "Lantern Pack", 50, "Wick's Trenchlights", list(/obj/item/device/flashlight/lantern = 5), /obj/structure/closet/crate/war_metal, null)





CARGO_CRATE_PRODUCT(gasmask_red, "Gas Mask Pack (R)", 50, "Sil's Utility Corps", list(/obj/item/clothing/mask/gas/sniper/penal1 = 10), /obj/structure/closet/crate/war_metal, RED_TEAM)
CARGO_CRATE_PRODUCT(cannedfood_red, "Canned Food Pack (R)", 20, "ChowField Provisions", list(/obj/random/canned_food/red = 10), /obj/structure/closet/crate/war_metal, RED_TEAM)
CARGO_CRATE_PRODUCT(explosives_red, "Plastic Explosives Pack (R)", 150, "Sil's Utility Corps", list(/obj/item/plastique/red = 5), /obj/structure/closet/crate/war_metal, RED_TEAM)
CARGO_CRATE_PRODUCT(flare_red, "Illumination Mortar Ammo (R)", 50, "Wick's Trenchlights", list(/obj/item/mortar_shell/flare = 8), /obj/structure/closet/crate/war_metal, RED_TEAM)
CARGO_CRATE_PRODUCT(flare_hand_red, "Flare Pack (R)", 50, "Wick's Trenchlights", list(/obj/item/ammo_box/flares = 10), /obj/structure/closet/crate/war_metal, RED_TEAM)
CARGO_CRATE_PRODUCT(candle_red, "Candle Pack (R)", 10, "Wick's Trenchlights", list(/obj/item/flame/candle = 10), /obj/structure/closet/crate/war_metal, RED_TEAM)

CARGO_JOB_PRODUCT(sniper_red, "Red sniper", 500, "Units", /datum/job/soldier/red_soldier/sniper, RED_TEAM)
CARGO_JOB_PRODUCT(flamer_red, "Red flamer", 1000, "Units", /datum/job/soldier/red_soldier/flame_trooper, RED_TEAM)
CARGO_JOB_PRODUCT(sentry_red, "Red sentry", 750, "Units", /datum/job/soldier/red_soldier/sentry, RED_TEAM)





CARGO_CRATE_PRODUCT(gasmask_blue, "Gas Mask Pack (B)", 50, "Sil's Utility Corps", list(/obj/item/clothing/mask/gas/sniper/penal3 = 10), /obj/structure/closet/crate/war_metal, BLUE_TEAM)
CARGO_CRATE_PRODUCT(cannedfood_blue, "Canned Food Pack (B)", 20, "ChowField Provisions", list(/obj/random/canned_food/blue = 10), /obj/structure/closet/crate/war_metal, BLUE_TEAM)
CARGO_CRATE_PRODUCT(explosives_blue, "Plastic Explosives Pack (B)", 150, "Sil's Utility Corps", list(/obj/item/plastique/blue = 5), /obj/structure/closet/crate/war_metal, BLUE_TEAM)
CARGO_CRATE_PRODUCT(flare_blue, "Illumination Mortar Ammo (B)", 50, "Wick's Trenchlights", list(/obj/item/mortar_shell/flare/blue = 8), /obj/structure/closet/crate/war_metal, BLUE_TEAM)
CARGO_CRATE_PRODUCT(flare_hand_blue, "Flare Pack (B)", 50, "Wick's Trenchlights", list(/obj/item/ammo_box/flares/blue = 10), /obj/structure/closet/crate/war_metal, BLUE_TEAM)
CARGO_CRATE_PRODUCT(candle_blue, "Candle Pack (B)", 10, "Wick's Trenchlights", list(/obj/item/flame/candle/blue = 10), /obj/structure/closet/crate/war_metal, BLUE_TEAM)

CARGO_JOB_PRODUCT(sniper_blue, "Blue sniper", 500, "Units", /datum/job/soldier/blue_soldier/sniper, BLUE_TEAM)
CARGO_JOB_PRODUCT(flamer_blue, "Blue flamer", 1000, "Units", /datum/job/soldier/blue_soldier/flame_trooper, BLUE_TEAM)
CARGO_JOB_PRODUCT(sentry_blue, "Blue sentry", 750, "Units", /datum/job/soldier/blue_soldier/sentry, BLUE_TEAM)





CARGO_TRAIN_PRODUCT(combat_medical, "Combat Medical Supplies", list(/obj/item/storage/firstaid/regular = 2, /obj/item/reagent_containers/hypospray/autoinjector/revive = 3), /obj/structure/closet/crate/war_metal)
CARGO_TRAIN_PRODUCT(emergency_ammo, "Emergency Ammunitions", list(/obj/item/ammo_box/rifle = 3, /obj/item/ammo_box/shotgun = 3, /obj/item/ammo_box/ptsd = 1), /obj/structure/closet/crate/war_metal)
CARGO_TRAIN_PRODUCT(lantern_pack, "Lantern Pack", list(/obj/item/device/flashlight/lantern = 5), /obj/structure/closet/crate/war_metal)

// Big ass descriptions down here

/decl/cargo_product/crate/rifle_ammo
	description = "Contents: 10 units \nPrice per unit: 5 credits \nRifle ammo for your rifle. \nCompatible with: Mk.1 Stormrider, Mk.1 Snapper"
/decl/cargo_product/crate/modern_rifle_ammo
	description = "Contents: 10 units \nPrice per unit: 5 credits \nModern rifle ammo for your modern rifle. \nCompatible with: Mk.2 Glider"
/decl/cargo_product/crate/shotgun_ammo
	description = "Contents: 10 units \nPrice per unit: 5 credits \nShotgun shells for your shotgun. \nCompatible with: WTX Shotgun Family, MS Shotgun Family"
/decl/cargo_product/crate/pistol_ammo
	description = "Contents: 10 units \nPrice per unit: 5 credits \nPistol magazines for your pistols. \nCompatible with: Mk.1 Reckoning, Mk.1 Golt "
/decl/cargo_product/crate/revolver_ammo
	description = "Contents: 10 units \nPrice per unit: 5 credits \nRevolver ammo for your revolvers. \nCompatible with: Captain's Special, Trenchman"
/decl/cargo_product/crate/hmg_ammo
	description = "Contents: 10 units \nPrice per unit: 5 credits \nHMG magazines for your HMG. \nCompatible with: Mk.1 Harbinger"
/decl/cargo_product/crate/old_lmg_ammo
	description = "Contents: 10 units \nPrice per unit: 5 credits \nPancakes."
/decl/cargo_product/crate/armageddon_ammo
	description = "Contents: 10 units \nPrice per unit: 5 credits \nArmageddon clips for your Armageddon-style rifle. \nCompatible with: Mk.1 Armageddon, Mk.2 Armageddon "
/decl/cargo_product/crate/warcrime_ammo
	description = "Contents: 10 units \nPrice per unit: 5 credits \nWarcrime mags for your Warcrime shotgun. \nCompatible with: MS Warcrime"
/decl/cargo_product/crate/warmonger_ammo
	description = "Contents: 10 units \nPrice per unit: 5 credits \nWarmonger mags for your Warmonger Rifle Company™ rifle. \nCompatible with: Warmonger Rifle Company™ family, Mk.1 Nemesis"
/decl/cargo_product/crate/flamer_ammo
	description = "Contents: 10 units \nPrice per unit: 5 credits \nIs it propane, gasoline, napalm? Nobody knows."
/decl/cargo_product/crate/ptsd_ammo
	description = "Contents: 10 units \nPrice per unit: 5 credits \nPTSD ammo for your PTSD rifle. \nCompatible with: PTSD-41"
/decl/cargo_product/crate/mortar_ammo
	description = "Contents: 10 units \nPrice per unit: 5 credits \nHigh-exlosive mortar shells for your mortar. \n Compatible with: Trench Ender"

/decl/cargo_product/crate/shotgun_pack
	description = "Contents: 10 units \nPrice per unit: 5 credits \nWTX Frontier shotguns. \nWhile a shotgun seems like the premier choice for clearing trenches, you'll quickly find out that it's HORRIBLE at range and will probably run out of ammo quickly. \nAs a side bonus, if you're up and close you can blast people's appendages off!"
/decl/cargo_product/crate/pistol_pack
	description = "Contents: 10 units \nPrice per unit: 5 credits \nReckoning pistols and Golt pistols. \nPistols are great for non-combat roles such as a Scavenger, Practitioner or Captain. Though, if you're buying a combat pistol for a non-combat role, are they really a non-combat role? \nI don't really know what the Golt does but it was pretty heavy when I was packaging it."
/decl/cargo_product/crate/harbinger_pack
	description = "Contents: 10 units \nPrice per unit: 5 credits \nHarbinger HMGs. \nYou probably can't use this unless you're one of the heavy dudes. \nHey, have you tried ordering a Sentry yet?"
/decl/cargo_product/crate/warmonger_pack
	description = "Contents: 10 units \nPrice per unit: 5 credits \nWarmonger rifles.. \nNot sure if it's a carbine or a rifle. \nIt's tactical and mag-fed and semi-auto and stuff like that."
/decl/cargo_product/crate/shovel_pack
	description = "Contents: 10 units \nPrice per unit: 5 credits \nStandard entrenchment tools. \nYou can dig trenches with this. \nEssential to winning a war, trust me."
/decl/cargo_product/crate/machete_pack
	description = "Contents: 10 units \nPrice per unit: 5 credits \nMachetes. \nChop stuff and people. \nCharging someone head-on with this probably isn't very effective."
/decl/cargo_product/crate/barrier_pack
	description = "Contents: 10 units \nPrice per unit: 5 credits \nSteel barricades. \nThey fold up and down. It's so portable you can put it in your backpack. \nQuite useful."
/decl/cargo_product/crate/doublebarrel_pack
	description = "Contents: 10 units \nPrice per unit: 5 credits \nMS Doom shotguns. \nIt's 2 barrels with a wooden stock and a trigger. \nCould come in handy."
/decl/cargo_product/crate/boltaction_pack
	description = "Contents: 10 units \nPrice per unit: 5 credits \nBolt-action rifles. \nI don't know why you would buy this. Every soldier comes with one, and it's so bad you don't need to worry about losing it."
/decl/cargo_product/crate/flamemaster_pack
	description = "Contents: 10 units \nPrice per unit: 5 credits \nFlamethrowers. \nYou REALLY can't use this unless you're one of the flamer dudes. \nHey, have you tried ordering a Flame Trooper yet?"
/decl/cargo_product/crate/frag_pack
	description = "Contents: 10 units \nPrice per unit: 5 credits \nFrag grenades. \nThrow it at the ENEMEY!"
/decl/cargo_product/crate/trenchclub_pack
	description = "Contents: 10 units \nPrice per unit: 5 credits \nTrench clubs. \nIf there's one thing my mom taught me, it's that you shouldn't bring a knife to a gun fight. The same goes for trench clubs."
/decl/cargo_product/crate/revolver_pack
	description = "Contents: 10 units \nPrice per unit: 5 credits \nTrenchman revolvers. \nReliable single-action revolvers. \nYou also shouldn't bring a single-action gun to a double-action gun fight."
/decl/cargo_product/crate/mortar_pack
	description = "Contents: 10 units \nPrice per unit: 5 credits \nTrench Ender mortars. \nThey usually fire high-explosive mortars. \nVery good for area denial and turning people into mist."
/decl/cargo_product/crate/barbwire_pack
	description = "Contents: 10 units \nPrice per unit: 5 credits \nBarbed wire. \nTHE area denial tool. \nBarbed wire is a scary thing, it makes people stuck in it and it cuts them up if they try to escape. Can be easily destroyed though."
/decl/cargo_product/crate/bodybag_pack
	description = "Contents: 10 units \nPrice per unit: 5 credits \nBodybags. \nFor when you can't give your friend a proper burial."
/decl/cargo_product/crate/cigarette_pack
	description = "Contents: 10 units \nPrice per unit: 5 credits \nNicotine cigarettes. \nReally low quality and rough but it's all you have."
/decl/cargo_product/crate/firstaid_pack
	description = "Contents: 10 units \nPrice per unit: 5 credits \nEvery soldier should have one. \nContains a health analyzer, ointment, bruise packs, and some medicine."
/decl/cargo_product/crate/advfirstaid_pack
	description = "Contents: 10 units \nPrice per unit: 5 credits \nThis is the medkit you wish you had. \nContains Inaprovaline, bruise packs, ointment and a splint."
/decl/cargo_product/crate/medbelt_pack
	description = "Contents: 10 units \nPrice per unit: 5 credits \nA belt full to the brim of medical supplies. \nContains a health analyzer, suture, universal blood, Atepoine, wirecutters and a morphine ampule."
/decl/cargo_product/crate/booze_pack
	description = "Contents: 10 units \nPrice per unit: 5 credits \nJarvis, more alcohol."
/decl/cargo_product/crate/atepoine_pack
	description = "Contents: 10 units \nPrice per unit: 5 credits \nAtepoine. \nAtepoine is a very strong medicine that can restart hearts and defibrillate them."
/decl/cargo_product/crate/smoke_pack
	description = "Contents: 10 units \nPrice per unit: 5 credits \nSmoke grenades. \nHave you smoked mid to CT spawn?"
/decl/cargo_product/crate/prosthetic_pack
	description = "Contents: 10 units \nPrice per unit: 5 credits \nProsthetic limbs. If you lose your limbs you can put a limb in place of the missing limb to have another limb until you find your old limb."
/decl/cargo_product/crate/blood_pack
	description = "Contents: 10 units \nPrice per unit: 5 credits \nBlood. \nIf you bleed too much you can replenish your body with some of this red juice."
/decl/cargo_product/job/reinforcements
	description = "Contents: 10 units \nPrice per unit: 5 credits \nMobilizes more soldiers."
/decl/cargo_product/crate/lantern_pack
	description = "Contents: 10 units \nPrice per unit: 5 credits \nLet there be LIGHT!"

/decl/cargo_product/crate/gasmask_red
	description = "Contents: 10 units \nPrice per unit: 5 credits \nGas for me and not for thee."
/decl/cargo_product/crate/cannedfood_red
	description = "Contents: 10 units \nPrice per unit: 5 credits \nThey were boiling shit, in a kettle."
/decl/cargo_product/crate/explosives_red
	description = "Contents: 10 units \nPrice per unit: 5 credits \nIt goes boom boom boom!"
/decl/cargo_product/crate/flare_red
	description = "Contents: 10 units \nPrice per unit: 5 credits \nLight up your world with this."
/decl/cargo_product/crate/flare_hand_red
	description = "Contents: 10 units \nPrice per unit: 5 credits \nLight up your world with this."
/decl/cargo_product/crate/candle_red
	description = "Contents: 10 units \nPrice per unit: 5 credits \nLight up your world with this."
/decl/cargo_product/job/sniper_red
	description = "Contents: 10 units \nPrice per unit: 5 credits \nCalls in a sniper to assist you with sniping duties. Boom, headshot!"
/decl/cargo_product/job/flamer_red
	description = "Contents: 10 units \nPrice per unit: 5 credits \nCalls in a flame trooper to assist you with flaming duties. I still remember the smell."
/decl/cargo_product/job/sentry_red
	description = "Contents: 10 units \nPrice per unit: 5 credits \nCalls in a sentry to assist you with sentrying duties. Ratatatatata!"

/decl/cargo_product/crate/gasmask_blue
	description = "Contents: 10 units \nPrice per unit: 5 credits \nGas for me and not for thee."
/decl/cargo_product/crate/cannedfood_blue
	description = "Contents: 10 units \nPrice per unit: 5 credits \nThey were boiling shit, in a kettle."
/decl/cargo_product/crate/explosives_blue
	description = "Contents: 10 units \nPrice per unit: 5 credits \nIt goes boom boom boom!"
/decl/cargo_product/crate/flare_blue
	description = "Contents: 10 units \nPrice per unit: 5 credits \nLight up your world with this."
/decl/cargo_product/crate/flare_hand_blue
	description = "Contents: 10 units \nPrice per unit: 5 credits \nLight up your world with this."
/decl/cargo_product/crate/candle_blue
	description = "Contents: 10 units \nPrice per unit: 5 credits \nLight up your world with this."
/decl/cargo_product/job/sniper_blue
	description = "Contents: 10 units \nPrice per unit: 5 credits \nCalls in a sniper to assist you with sniping duties. Boom, headshot!"
/decl/cargo_product/job/flamer_blue
	description = "Contents: 10 units \nPrice per unit: 5 credits \nCalls in a flame trooper to assist you with flaming duties. I still remember the smell."
/decl/cargo_product/job/sentry_blue
	description = "Contents: 10 units \nPrice per unit: 5 credits \nCalls in a sentry to assist you with sentrying duties. Ratatatatata!"

/decl/cargo_product/train/combat_medical
	description = "Contents: 10 units \nPrice per unit: 5 credits \nTesting"
/decl/cargo_product/train/emergency_ammo
	description = "Contents: 10 units \nPrice per unit: 5 credits \nTesting"
/decl/cargo_product/train/lantern_pack
	description = "Contents: 10 units \nPrice per unit: 5 credits \nTesting"