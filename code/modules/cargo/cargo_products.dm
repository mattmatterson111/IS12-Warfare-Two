/decl/cargo_product
	var/name = "Unknown Product"
	var/price = 0
	var/category = "Miscellaneous"
	var/faction_id = null 
	var/crate_type = /obj/structure/closet/crate/wooden
	var/list/contents
	var/job_path

/decl/cargo_product/job
/decl/cargo_product/crate
/decl/cargo_product/train
	price = 0 





CARGO_CRATE_PRODUCT(rifle_ammo, "Rifle Ammo Pack", 50, "Brass.Co Ammunitions", list(/obj/item/ammo_box/rifle = 10), /obj/structure/closet/crate/wooden, null)
CARGO_CRATE_PRODUCT(modern_rifle_ammo, "Modern Rifle Ammo Pack", 50, "Brass.Co Ammunitions", list(/obj/item/ammo_box/rifle/modern = 10), /obj/structure/closet/crate/wooden, null)
CARGO_CRATE_PRODUCT(shotgun_ammo, "Shotgun Ammo Pack", 100, "Brass.Co Ammunitions", list(/obj/item/ammo_box/shotgun = 10), /obj/structure/closet/crate/wooden, null)
CARGO_CRATE_PRODUCT(pistol_ammo, "Pistol Ammo Pack", 50, "Brass.Co Ammunitions", list(/obj/item/ammo_magazine/c45m/warfare = 10, /obj/item/ammo_magazine/a50 = 5), /obj/structure/closet/crate/wooden, null)
CARGO_CRATE_PRODUCT(revolver_ammo, "Revolver Ammo Pack", 50, "Brass.Co Ammunitions", list(/obj/item/ammo_magazine/handful/revolver = 10), /obj/structure/closet/crate/wooden, null)
CARGO_CRATE_PRODUCT(hmg_ammo, "HMG Ammo Pack", 50, "Brass.Co Ammunitions", list(/obj/item/ammo_magazine/box/a556/mg08 = 5), /obj/structure/closet/crate/wooden, null)
CARGO_CRATE_PRODUCT(old_lmg_ammo, "Old LMG Ammo Pack", 50, "Brass.Co Ammunitions", list(/obj/item/ammo_magazine/c45rifle/flat = 5), /obj/structure/closet/crate/wooden, null)
CARGO_CRATE_PRODUCT(armageddon_ammo, "Armageddon Ammo Pack", 50, "Brass.Co Ammunitions", list(/obj/item/ammo_magazine/a762/m14/battlerifle_mag = 3, /obj/item/ammo_magazine/a762/rsc = 3), /obj/structure/closet/crate/wooden, null)
CARGO_CRATE_PRODUCT(warcrime_ammo, "Warcrime Ammo Pack", 50, "Brass.Co Ammunitions", list(/obj/item/ammo_magazine/autoshotty = 5), /obj/structure/closet/crate/wooden, null)
CARGO_CRATE_PRODUCT(warmonger_ammo, "Warmonger Ammo", 50, "Brass.Co Ammunitions", list(/obj/item/ammo_magazine/c45rifle/akarabiner = 10), /obj/structure/closet/crate/wooden, null)
CARGO_CRATE_PRODUCT(flamer_ammo, "Flamethrower Ammo Pack", 100, "Brass.Co Ammunitions", list(/obj/item/ammo_magazine/flamer = 5), /obj/structure/closet/crate/wooden, null)
CARGO_CRATE_PRODUCT(ptsd_ammo, "PTSD Ammo Pack", 100, "Brass.Co Ammunitions", list(/obj/item/ammo_box/ptsd = 5), /obj/structure/closet/crate/wooden, null)
CARGO_CRATE_PRODUCT(mortar_ammo, "Mortar Ammo", 100, "Brass.Co Ammunitions", list(/obj/item/mortar_shell = 8), /obj/structure/closet/crate/wooden, null)

CARGO_CRATE_PRODUCT(shotgun_pack, "Shotgun Pack", 100, "Brass.Co Top-Brass", list(/obj/item/gun/projectile/shotgun/pump/shitty = 5), /obj/structure/closet/crate/secure/weapon, null)
CARGO_CRATE_PRODUCT(pistol_pack, "Pistol Pack", 100, "Brass.Co Top-Brass", list(/obj/item/gun/projectile/golt = 2, /obj/item/gun/projectile/warfare = 3), /obj/structure/closet/crate/secure/weapon, null)
CARGO_CRATE_PRODUCT(harbinger_pack, "Harbinger Pack", 100, "Brass.Co Top-Brass", list(/obj/item/gun/projectile/automatic/mg08 = 2), /obj/structure/closet/crate/secure/weapon, null)
CARGO_CRATE_PRODUCT(warmonger_pack, "Warmonger Pack", 100, "Brass.Co Top-Brass", list(/obj/item/gun/projectile/automatic/m22/warmonger = 10), /obj/structure/closet/crate/secure/weapon, null)
CARGO_CRATE_PRODUCT(shovel_pack, "Shovel Pack", 35, "Tools", list(/obj/item/shovel = 5), /obj/structure/closet/crate/wooden, null)
CARGO_CRATE_PRODUCT(barrier_pack, "Defensive Barrier Pack", 50, "Sil's Utility Corps", list(/obj/item/defensive_barrier = 3), /obj/structure/closet/crate/wooden, null)
CARGO_CRATE_PRODUCT(doublebarrel_pack, "Doublebarrel Shotgun Pack", 100, "Brass.Co Top-Brass", list(/obj/item/gun/projectile/shotgun/doublebarrel = 5), /obj/structure/closet/crate/secure/weapon, null)
CARGO_CRATE_PRODUCT(boltaction_pack, "Bolt Action Rifle Pack", 50, "Brass.Co Top-Brass", list(/obj/item/gun/projectile/shotgun/pump/boltaction/shitty/leverchester = 10), /obj/structure/closet/crate/secure/weapon, null)
CARGO_CRATE_PRODUCT(flamemaster_pack, "Flamethrower Pack", 200, "Brass.Co Top-Brass", list(/obj/item/gun/projectile/automatic/flamer = 1, /obj/item/ammo_magazine/flamer = 2), /obj/structure/closet/crate/secure/weapon, null)
CARGO_CRATE_PRODUCT(frag_pack, "Frag Grenade Pack", 300, "Brass.Co Top-Brass", list(/obj/item/grenade/frag/warfare = 5), /obj/structure/closet/crate/wooden, null)
CARGO_CRATE_PRODUCT(trenchclub_pack, "Trench Club Pack", 100, "Brass.Co Top-Brass", list(/obj/item/melee/classic_baton/trench_club = 5), /obj/structure/closet/crate/wooden, null)
CARGO_CRATE_PRODUCT(revolver_pack, "Trenchman Revolver Pack", 200, "Brass.Co Top-Brass", list(/obj/item/gun/projectile/revolver/manual/ = 5), /obj/structure/closet/crate/secure/weapon, null)
CARGO_CRATE_PRODUCT(mortar_pack, "Mortar Pack", 500, "Brass.Co Top-Brass", list(/obj/item/mortar_launcher = 2, /obj/item/mortar_shell = 6), /obj/structure/closet/crate/secure/weapon, null)

CARGO_CRATE_PRODUCT(barbwire_pack, "Barbwire Pack", 50, "Sil's Utility Corps", list(/obj/item/stack/barbwire = 5), /obj/structure/closet/crate/wooden, null)
CARGO_CRATE_PRODUCT(bodybag_pack, "Bodybag Pack", 5, "Daisy's Panacea", list(/obj/item/storage/box/bodybags = 3), /obj/structure/closet/crate/medical, null)
CARGO_CRATE_PRODUCT(cigarette_pack, "Cigarette Pack", 50, "ChowField Provisions", list(/obj/item/storage/fancy/cigarettes = 10), /obj/structure/closet/crate/wooden, null)
CARGO_CRATE_PRODUCT(firstaid_pack, "First Aid Pack", 100, "Daisy's Panacea", list(/obj/item/storage/firstaid/regular = 5), /obj/structure/closet/crate/medical, null)
CARGO_CRATE_PRODUCT(advfirstaid_pack, "Advanced First Aid Pack", 200, "Daisy's Panacea", list(/obj/item/storage/firstaid/adv = 5), /obj/structure/closet/crate/medical, null)
CARGO_CRATE_PRODUCT(medbelt_pack, "Medical Belt Pack", 50, "Daisy's Panacea", list(/obj/item/storage/belt/medical/full = 10), /obj/structure/closet/crate/medical, null)
CARGO_CRATE_PRODUCT(booze_pack, "Booze Pack", 100, "ChowField Provisions", list(/obj/random/drinkbottle = 8), /obj/structure/closet/crate/wooden, null)
CARGO_CRATE_PRODUCT(atepoine_pack, "Atepoine Pack", 50, "Daisy's Panacea", list(/obj/item/reagent_containers/hypospray/autoinjector/revive = 10), /obj/structure/closet/crate/medical, null)
CARGO_CRATE_PRODUCT(smoke_pack, "Smoke Grenade Pack", 150, "Sil's Utility Corps", list(/obj/item/grenade/smokebomb = 5), /obj/structure/closet/crate/wooden, null)
CARGO_CRATE_PRODUCT(prosthetic_pack, "Prosthetic Limbs Pack", 200, "Daisy's Panacea", list(/obj/item/organ/external/arm/robo_arm = 2, /obj/item/organ/external/arm/right/robo_arm = 2, /obj/item/organ/external/hand/robo_hand = 2, /obj/item/organ/external/hand/right/robo_hand = 2, /obj/item/organ/external/leg/robo_leg = 2, /obj/item/organ/external/leg/right/robo_leg = 2, /obj/item/organ/external/foot/robo_foot = 2, /obj/item/organ/external/foot/right/robo_foot = 2), /obj/structure/closet/crate/medical, null)
CARGO_CRATE_PRODUCT(blood_pack, "Blood Injector Pack", 50, "Daisy's Panacea", list(/obj/item/reagent_containers/hypospray/autoinjector/blood = 10), /obj/structure/closet/crate/wooden, null)

CARGO_JOB_PRODUCT(reinforcements, "Reinforcements", 750, "Units", "none", null)


CARGO_CRATE_PRODUCT(lantern_pack, "Lantern Pack", 50, "Wick's Trenchlights", list(/obj/item/device/flashlight/lantern = 5), /obj/structure/closet/crate/wooden, null)





CARGO_CRATE_PRODUCT(gasmask_red, "Gas Mask Pack", 50, "Sil's Utility Corps", list(/obj/item/clothing/mask/gas/sniper/penal1 = 10), /obj/structure/closet/crate/wooden, RED_TEAM)
CARGO_CRATE_PRODUCT(cannedfood_red, "Canned Food Pack", 20, "ChowField Provisions", list(/obj/random/canned_food/red = 10), /obj/structure/closet/crate/wooden, RED_TEAM)
CARGO_CRATE_PRODUCT(explosives_red, "Plastic Explosives Pack", 150, "Sil's Utility Corps", list(/obj/item/plastique/red = 5), /obj/structure/closet/crate/wooden, RED_TEAM)
CARGO_CRATE_PRODUCT(flare_red, "Illumination Mortar Ammo", 50, "Wick's Trenchlights", list(/obj/item/mortar_shell/flare = 8), /obj/structure/closet/crate/wooden, RED_TEAM)
CARGO_CRATE_PRODUCT(flare_hand_red, "Flare Pack", 50, "Wick's Trenchlights", list(/obj/item/ammo_box/flares = 10), /obj/structure/closet/crate/wooden, RED_TEAM)
CARGO_CRATE_PRODUCT(candle_red, "Candle Pack", 10, "Wick's Trenchlights", list(/obj/item/flame/candle = 10), /obj/structure/closet/crate/wooden, RED_TEAM)

CARGO_JOB_PRODUCT(sniper_red, "Red sniper", 500, "Units", /datum/job/soldier/red_soldier/sniper, RED_TEAM)
CARGO_JOB_PRODUCT(flamer_red, "Red flamer", 1000, "Units", /datum/job/soldier/red_soldier/flame_trooper, RED_TEAM)
CARGO_JOB_PRODUCT(sentry_red, "Red sentry", 750, "Units", /datum/job/soldier/red_soldier/sentry, RED_TEAM)





CARGO_CRATE_PRODUCT(gasmask_blue, "Gas Mask Pack", 50, "Sil's Utility Corps", list(/obj/item/clothing/mask/gas/sniper/penal3 = 10), /obj/structure/closet/crate/wooden, BLUE_TEAM)
CARGO_CRATE_PRODUCT(cannedfood_blue, "Canned Food Pack", 20, "ChowField Provisions", list(/obj/random/canned_food/blue = 10), /obj/structure/closet/crate/wooden, BLUE_TEAM)
CARGO_CRATE_PRODUCT(explosives_blue, "Plastic Explosives Pack", 150, "Sil's Utility Corps", list(/obj/item/plastique/blue = 5), /obj/structure/closet/crate/wooden, BLUE_TEAM)
CARGO_CRATE_PRODUCT(flare_blue, "Illumination Mortar Ammo", 50, "Wick's Trenchlights", list(/obj/item/mortar_shell/flare/blue = 8), /obj/structure/closet/crate/wooden, BLUE_TEAM)
CARGO_CRATE_PRODUCT(flare_hand_blue, "Flare Pack", 50, "Wick's Trenchlights", list(/obj/item/ammo_box/flares/blue = 10), /obj/structure/closet/crate/wooden, BLUE_TEAM)
CARGO_CRATE_PRODUCT(candle_blue, "Candle Pack", 10, "Wick's Trenchlights", list(/obj/item/flame/candle/blue = 10), /obj/structure/closet/crate/wooden, BLUE_TEAM)

CARGO_JOB_PRODUCT(sniper_blue, "Blue sniper", 500, "Units", /datum/job/soldier/blue_soldier/sniper, BLUE_TEAM)
CARGO_JOB_PRODUCT(flamer_blue, "Blue flamer", 1000, "Units", /datum/job/soldier/blue_soldier/flame_trooper, BLUE_TEAM)
CARGO_JOB_PRODUCT(sentry_blue, "Blue sentry", 750, "Units", /datum/job/soldier/blue_soldier/sentry, BLUE_TEAM)





CARGO_TRAIN_PRODUCT(combat_medical, "Combat Medical Supplies", list(/obj/item/storage/firstaid/regular = 2, /obj/item/reagent_containers/hypospray/autoinjector/revive = 3), /obj/structure/closet/crate/medical)
CARGO_TRAIN_PRODUCT(emergency_ammo, "Emergency Ammunitions", list(/obj/item/ammo_box/rifle = 3, /obj/item/ammo_box/shotgun = 3, /obj/item/ammo_box/ptsd = 1), /obj/structure/closet/crate/wooden)
CARGO_TRAIN_PRODUCT(lantern_pack, "Lantern Pack", list(/obj/item/device/flashlight/lantern = 5), /obj/structure/closet/crate/wooden)
CARGO_TRAIN_PRODUCT(industrial, "Industrial Supplies", list(/obj/item/stack/barbwire = 5, /obj/item/shovel = 3, /obj/item/defensive_barrier = 2), /obj/structure/closet/crate/wooden)