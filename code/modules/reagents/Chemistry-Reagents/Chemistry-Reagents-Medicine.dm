/* General medicine */

/datum/reagent/inaprovaline
	name = "Inaprovaline"
	description = "Inaprovaline is a multipurpose neurostimulant and cardioregulator. Commonly used to slow bleeding and stabilize patients."
	taste_description = "bitterness"
	reagent_state = REAGENT_LIQUID
	color = "#00bfff"
	overdose = REAGENTS_OVERDOSE * 2
	metabolism = REM * 0.5
	scannable = 1
	flags = IGNORE_MOB_SIZE

/datum/reagent/inaprovaline/affect_blood(var/mob/living/carbon/M, var/alien, var/removed)
	if(alien != IS_DIONA)
		M.add_chemical_effect(CE_STABLE)
		M.add_chemical_effect(CE_PAINKILLER, 10)

/datum/reagent/atepoine
	name = "Atepoine"
	description = "Incredibly rare cardiac stimulant."
	reagent_state = REAGENT_LIQUID
	color = "#A0522D"
	metabolism = 0.5
	overdose = REAGENTS_OVERDOSE
	scannable = 1
	flags = AFFECTS_DEAD

/datum/reagent/atepoine/affect_blood(var/mob/living/carbon/M, var/alien, var/removed)
	M.adjustBrainLoss(-5)
	M.adjustOxyLoss(-200 * removed)
	if(istype(M,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = M

		//Ports and simplifies defib code
		if(H.stat != DEAD)
			//if(H.ssd_check())
			//	to_chat(find_dead_player(H.ckey, 1), "Enter the fray once more.")
			//	sleep(200)

			H.resuscitate()

/datum/reagent/bicaridine
	name = "Bicaridine"
	description = "Bicaridine is an analgesic medication and can be used to treat blunt trauma."
	taste_description = "bitterness"
	taste_mult = 3
	reagent_state = REAGENT_LIQUID
	color = "#bf0000"
	overdose = REAGENTS_OVERDOSE
	scannable = 1
	flags = IGNORE_MOB_SIZE

/datum/reagent/bicaridine/affect_blood(var/mob/living/carbon/M, var/alien, var/removed)
	if(alien != IS_DIONA)
		M.heal_organ_damage(6 * removed, 0)

/datum/reagent/kelotane
	name = "Kelotane"
	description = "Kelotane is a drug used to treat burns."
	taste_description = "bitterness"
	reagent_state = REAGENT_LIQUID
	color = "#ffa800"
	overdose = REAGENTS_OVERDOSE
	scannable = 1
	flags = IGNORE_MOB_SIZE

/datum/reagent/kelotane/affect_blood(var/mob/living/carbon/M, var/alien, var/removed)
	if(alien != IS_DIONA)
		M.heal_organ_damage(0, 6 * removed)

/datum/reagent/dermaline
	name = "Dermaline"
	description = "Dermaline is the next step in burn medication. Works twice as good as kelotane and enables the body to restore even the direst heat-damaged tissue."
	taste_description = "bitterness"
	taste_mult = 1.5
	reagent_state = REAGENT_LIQUID
	color = "#ff8000"
	overdose = REAGENTS_OVERDOSE * 0.5
	scannable = 1
	flags = IGNORE_MOB_SIZE

/datum/reagent/dermaline/affect_blood(var/mob/living/carbon/M, var/alien, var/removed)
	if(alien != IS_DIONA)
		M.heal_organ_damage(0, 12 * removed)

/datum/reagent/dylovene
	name = "Dylovene"
	description = "Dylovene is a broad-spectrum antitoxin used to neutralize poisons before they can do significant harm."
	taste_description = "a roll of gauze"
	reagent_state = REAGENT_LIQUID
	color = "#00a000"
	scannable = 1
	flags = IGNORE_MOB_SIZE
	var/static/list/remove_toxins = list(
		/datum/reagent/toxin/zombiepowder
	)

/datum/reagent/dylovene/affect_blood(var/mob/living/carbon/M, var/alien, var/removed)
	if(alien == IS_DIONA)
		return
	M.drowsyness = max(0, M.drowsyness - 6 * removed)
	M.adjust_hallucination(-9 * removed)
	M.add_up_to_chemical_effect(CE_ANTITOX, 1)

	var/removing = (4 * removed)
	for(var/datum/reagent/R in M.ingested.reagent_list)
		if(istype(R, /datum/reagent/toxin) || (R.type in remove_toxins))
			M.ingested.remove_reagent(R.type, removing)
			return
	for(var/datum/reagent/R in M.reagents.reagent_list)
		if(istype(R, /datum/reagent/toxin) || (R.type in remove_toxins))
			M.reagents.remove_reagent(R.type, removing)
			return

/datum/reagent/dexalin
	name = "Dexalin"
	description = "Dexalin is used in the treatment of oxygen deprivation."
	taste_description = "bitterness"
	reagent_state = REAGENT_LIQUID
	color = "#0080ff"
	overdose = REAGENTS_OVERDOSE
	scannable = 1
	flags = IGNORE_MOB_SIZE

/datum/reagent/dexalin/affect_blood(var/mob/living/carbon/M, var/alien, var/removed)
	if(alien == IS_VOX)
		M.adjustToxLoss(removed * 6)
	else if(alien != IS_DIONA)
		M.add_chemical_effect(CE_OXYGENATED, 1)
	holder.remove_reagent(/datum/reagent/lexorin, 2 * removed)

/datum/reagent/dexalinp
	name = "Dexalin Plus"
	description = "Dexalin Plus is used in the treatment of oxygen deprivation. It is highly effective."
	taste_description = "bitterness"
	reagent_state = REAGENT_LIQUID
	color = "#0040ff"
	overdose = REAGENTS_OVERDOSE * 0.5
	scannable = 1
	flags = IGNORE_MOB_SIZE

/datum/reagent/dexalinp/affect_blood(var/mob/living/carbon/M, var/alien, var/removed)
	if(alien == IS_VOX)
		M.adjustToxLoss(removed * 9)
	else if(alien != IS_DIONA)
		M.add_chemical_effect(CE_OXYGENATED, 2)
	holder.remove_reagent(/datum/reagent/lexorin, 3 * removed)

/datum/reagent/tricordrazine
	name = "Tricordrazine"
	description = "Tricordrazine is a highly potent stimulant, originally derived from cordrazine. Can be used to treat a wide range of injuries."
	taste_description = "grossness"
	reagent_state = REAGENT_LIQUID
	color = "#8040ff"
	scannable = 1
	flags = IGNORE_MOB_SIZE

/datum/reagent/tricordrazine/affect_blood(var/mob/living/carbon/M, var/alien, var/removed)
	if(alien != IS_DIONA)
		M.heal_organ_damage(3 * removed, 3 * removed)

/datum/reagent/cryoxadone
	name = "Cryoxadone"
	description = "A chemical mixture with almost magical healing powers. Its main limitation is that the targets body temperature must be under 170K for it to metabolise correctly."
	taste_description = "sludge"
	reagent_state = REAGENT_LIQUID
	color = "#8080ff"
	metabolism = REM * 0.05
	scannable = 1
	flags = IGNORE_MOB_SIZE

/datum/reagent/cryoxadone/affect_blood(var/mob/living/carbon/M, var/alien, var/removed)
	M.add_chemical_effect(CE_CRYO, 1)
	if(M.bodytemperature < 170)
		M.adjustCloneLoss(-100 * removed)
		M.add_chemical_effect(CE_OXYGENATED, 1)
		M.heal_organ_damage(100 * removed, 100 * removed)
		M.add_chemical_effect(CE_PULSE, -2)

/datum/reagent/clonexadone
	name = "Clonexadone"
	description = "A liquid compound similar to that used in the cloning process. Can be used to 'finish' the cloning process when used in conjunction with a cryo tube."
	taste_description = "slime"
	reagent_state = REAGENT_LIQUID
	color = "#80bfff"
	metabolism = REM * 0.05
	scannable = 1
	flags = IGNORE_MOB_SIZE

/datum/reagent/clonexadone/affect_blood(var/mob/living/carbon/M, var/alien, var/removed)
	M.add_chemical_effect(CE_CRYO, 1)
	if(M.bodytemperature < 170)
		M.adjustCloneLoss(-300 * removed)
		M.add_chemical_effect(CE_OXYGENATED, 2)
		M.heal_organ_damage(300 * removed, 300 * removed)
		M.add_chemical_effect(CE_PULSE, -2)

/* Painkillers */

/datum/reagent/paracetamol
	name = "Paracetamol"
	description = "Most probably know this as Tylenol, but this chemical is a mild, simple painkiller."
	taste_description = "sickness"
	reagent_state = REAGENT_LIQUID
	color = "#c8a5dc"
	overdose = 60
	scannable = 1
	metabolism = 0.02
	flags = IGNORE_MOB_SIZE

/datum/reagent/paracetamol/affect_blood(var/mob/living/carbon/M, var/alien, var/removed)
	M.add_chemical_effect(CE_PAINKILLER, 25)

/datum/reagent/paracetamol/overdose(var/mob/living/carbon/M, var/alien)
	..()
	M.druggy = max(M.druggy, 2)
	M.add_chemical_effect(CE_PAINKILLER, 10)

/datum/reagent/tramadol
	name = "Tramadol"
	description = "A simple, yet effective painkiller. Don't mix with alcohol."
	taste_description = "sourness"
	reagent_state = REAGENT_LIQUID
	color = "#cb68fc"
	overdose = 30
	scannable = 1
	metabolism = 0.05
	ingest_met = 0.02
	flags = IGNORE_MOB_SIZE
	var/pain_power = 50 //magnitide of painkilling effect
	var/effective_dose = 0.5 //how many units it need to process to reach max power

/datum/reagent/tramadol/affect_blood(var/mob/living/carbon/M, var/alien, var/removed)
	var/effectiveness = 1
	if(M.chem_doses[type] < effective_dose) //some ease-in ease-out for the effect
		effectiveness = M.chem_doses[type]/effective_dose
	else if(volume < effective_dose)
		effectiveness = volume/effective_dose
	M.add_chemical_effect(CE_PAINKILLER, pain_power * effectiveness)
	if(M.chem_doses[type] > 0.5 * overdose)
		M.add_chemical_effect(CE_SLOWDOWN, 1)
		if(prob(1))
			M.slurring = max(M.slurring, 10)
	if(M.chem_doses[type] > 0.75 * overdose)
		M.add_chemical_effect(CE_SLOWDOWN, 1)
		if(prob(5))
			M.slurring = max(M.slurring, 20)
	if(M.chem_doses[type] > overdose)
		M.add_chemical_effect(CE_SLOWDOWN, 1)
		M.slurring = max(M.slurring, 30)
		if(prob(1))
			M.Weaken(2)
			M.drowsyness = max(M.drowsyness, 5)
	var/boozed = isboozed(M)
	if(boozed)
		M.add_chemical_effect(CE_ALCOHOL_TOXIC, 1)
		M.add_chemical_effect(CE_BREATHLOSS, 0.1 * boozed) //drinking and opiating makes breathing kinda hard

/datum/reagent/tramadol/overdose(var/mob/living/carbon/M, var/alien)
	..()
	M.hallucination(120, 30)
	M.druggy = max(M.druggy, 10)
	M.add_chemical_effect(CE_PAINKILLER, pain_power*0.5) //extra painkilling for extra trouble
	M.add_chemical_effect(CE_BREATHLOSS, 0.6) //Have trouble breathing, need more air
	if(isboozed(M))
		M.add_chemical_effect(CE_BREATHLOSS, 0.2) //Don't drink and OD on opiates folks

/datum/reagent/tramadol/proc/isboozed(var/mob/living/carbon/M)
	. = 0
	var/list/pool = M.reagents.reagent_list | M.ingested.reagent_list
	for(var/datum/reagent/ethanol/booze in pool)
		if(M.chem_doses[booze.type] < 2) //let them experience false security at first
			continue
		. = 1
		if(booze.strength < 40) //liquor stuff hits harder
			return 2

/datum/reagent/tramadol/morphine
	name = "Morphine"

/datum/reagent/tramadol/oxycodone
	name = "Oxycodone"
	description = "An effective and very addictive painkiller. Don't mix with alcohol."
	taste_description = "bitterness"
	color = "#800080"
	overdose = 20
	pain_power = 200
	effective_dose = 2

/* Other medicine */

/datum/reagent/synaptizine
	name = "Synaptizine"
	description = "Synaptizine is used to treat various diseases."
	taste_description = "bitterness"
	reagent_state = REAGENT_LIQUID
	color = "#99ccff"
	metabolism = REM * 0.05
	overdose = REAGENTS_OVERDOSE
	scannable = 1

/datum/reagent/synaptizine/affect_blood(var/mob/living/carbon/M, var/alien, var/removed)
	if(alien == IS_DIONA)
		return
	M.drowsyness = max(M.drowsyness - 5, 0)
	M.AdjustParalysis(-1)
	M.AdjustStunned(-1)
	M.AdjustWeakened(-1)
	holder.remove_reagent(/datum/reagent/mindbreaker, 5)
	M.adjust_hallucination(-10)
	M.add_chemical_effect(CE_MIND, 2)
	M.adjustToxLoss(5 * removed) // It used to be incredibly deadly due to an oversight. Not anymore!
	M.add_chemical_effect(CE_PAINKILLER, 20)

/datum/reagent/alkysine
	name = "Alkysine"
	description = "Alkysine is a drug used to lessen the damage to neurological tissue after a injury. Can aid in healing brain tissue."
	taste_description = "bitterness"
	reagent_state = REAGENT_LIQUID
	color = "#ffff66"
	metabolism = REM * 0.25
	overdose = REAGENTS_OVERDOSE
	scannable = 1
	flags = IGNORE_MOB_SIZE

/datum/reagent/alkysine/affect_blood(var/mob/living/carbon/M, var/alien, var/removed)
	if(alien == IS_DIONA)
		return
	M.add_chemical_effect(CE_PAINKILLER, 10)
	M.add_chemical_effect(CE_BRAIN_REGEN, 1)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		H.confused++
		H.drowsyness++

/datum/reagent/imidazoline
	name = "Imidazoline"
	description = "Heals eye damage"
	taste_description = "dull toxin"
	reagent_state = REAGENT_LIQUID
	color = "#c8a5dc"
	overdose = REAGENTS_OVERDOSE
	scannable = 1
	flags = IGNORE_MOB_SIZE


/datum/reagent/imidazoline/affect_blood(var/mob/living/carbon/M, var/alien, var/removed)
	M.eye_blurry = max(M.eye_blurry - 5, 0)
	M.eye_blind = max(M.eye_blind - 5, 0)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/internal/eyes/E = H.internal_organs_by_name[BP_EYES]
		if(E && istype(E))
			if(E.damage > 0)
				E.damage = max(E.damage - 5 * removed, 0)

/datum/reagent/peridaxon
	name = "Peridaxon"
	description = "Used to encourage recovery of internal organs and nervous systems. Medicate cautiously."
	taste_description = "bitterness"
	reagent_state = REAGENT_LIQUID
	color = "#561ec3"
	overdose = 10
	scannable = 1
	flags = IGNORE_MOB_SIZE

/datum/reagent/peridaxon/affect_blood(var/mob/living/carbon/M, var/alien, var/removed)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		for(var/obj/item/organ/internal/I in H.internal_organs)
			if(I.robotic >= ORGAN_ROBOT)
				continue
			if(I.organ_tag == BP_BRAIN)
				H.confused++
				H.drowsyness++
				if(I.damage >= I.min_bruised_damage)
					continue
			I.damage = max(I.damage - removed, 0)

/datum/reagent/ryetalyn
	name = "Ryetalyn"
	description = "Ryetalyn can cure all genetic abnomalities via a catalytic process."
	taste_description = "acid"
	reagent_state = REAGENT_SOLID
	color = "#004000"
	overdose = REAGENTS_OVERDOSE

/datum/reagent/ryetalyn/affect_blood(var/mob/living/carbon/M, var/alien, var/removed)
	var/needs_update = M.mutations.len > 0

	M.mutations = list()
	M.disabilities = 0
	M.sdisabilities = 0

	// Might need to update appearance for hulk etc.
	if(needs_update && ishuman(M))
		var/mob/living/carbon/human/H = M
		H.update_mutations()

/datum/reagent/hyperzine
	name = "Hyperzine"
	description = "Hyperzine is a highly effective, long lasting, muscle stimulant."
	taste_description = "acid"
	reagent_state = REAGENT_LIQUID
	color = "#ff3300"
	metabolism = REM * 0.15
	overdose = REAGENTS_OVERDOSE * 0.5

/datum/reagent/hyperzine/affect_blood(var/mob/living/carbon/M, var/alien, var/removed)
	if(alien == IS_DIONA)
		return
	if(prob(5))
		M.emote(pick("twitch", "blink_r", "shiver"))
	M.add_chemical_effect(CE_SPEEDBOOST, 1)
	M.add_chemical_effect(CE_PULSE, 2)

/datum/reagent/ethylredoxrazine
	name = "Ethylredoxrazine"
	description = "A powerful oxidizer that reacts with ethanol."
	reagent_state = REAGENT_SOLID
	color = "#605048"
	overdose = REAGENTS_OVERDOSE

/datum/reagent/ethylredoxrazine/affect_blood(var/mob/living/carbon/M, var/alien, var/removed)
	if(alien == IS_DIONA)
		return
	M.dizziness = 0
	M.drowsyness = 0
	M.stuttering = 0
	M.confused = 0
	if(M.ingested)
		for(var/datum/reagent/R in M.ingested.reagent_list)
			if(istype(R, /datum/reagent/ethanol))
				M.chem_doses[R.type] = max(M.chem_doses[R.type] - removed * 5, 0)

/datum/reagent/hyronalin
	name = "Hyronalin"
	description = "Hyronalin is a medicinal drug used to counter the effect of radiation poisoning."
	taste_description = "bitterness"
	reagent_state = REAGENT_LIQUID
	color = "#408000"
	metabolism = REM * 0.25
	overdose = REAGENTS_OVERDOSE
	scannable = 1
	flags = IGNORE_MOB_SIZE

/datum/reagent/hyronalin/affect_blood(var/mob/living/carbon/M, var/alien, var/removed)
	M.radiation = max(M.radiation - 30 * removed, 0)

/datum/reagent/arithrazine
	name = "Arithrazine"
	description = "Arithrazine is an unstable medication used for the most extreme cases of radiation poisoning."
	reagent_state = REAGENT_LIQUID
	color = "#008000"
	metabolism = REM * 0.25
	overdose = REAGENTS_OVERDOSE
	scannable = 1
	flags = IGNORE_MOB_SIZE

/datum/reagent/arithrazine/affect_blood(var/mob/living/carbon/M, var/alien, var/removed)
	M.radiation = max(M.radiation - 70 * removed, 0)
	M.adjustToxLoss(-10 * removed)
	if(prob(60))
		M.take_organ_damage(4 * removed, 0)

/datum/reagent/spaceacillin
	name = "Spaceacillin"
	description = "An all-purpose antiviral agent."
	taste_description = "bitterness"
	reagent_state = REAGENT_LIQUID
	color = "#c1c1c1"
	metabolism = REM * 0.1
	overdose = REAGENTS_OVERDOSE/2
	scannable = 1

/datum/reagent/spaceacillin/affect_blood(var/mob/living/carbon/M, var/alien, var/removed)
	M.immunity = max(M.immunity - 0.1, 0)
	M.add_chemical_effect(CE_ANTIVIRAL, VIRUS_COMMON)
	if(volume > 10)
		M.immunity = max(M.immunity - 0.3, 0)
		M.add_chemical_effect(CE_ANTIVIRAL, VIRUS_ENGINEERED)
	if(M.chem_doses[type] > 15)
		M.immunity = max(M.immunity - 0.25, 0)

/datum/reagent/spaceacillin/overdose(var/mob/living/carbon/M, var/alien)
	..()
	M.immunity = max(M.immunity - 0.25, 0)
	M.add_chemical_effect(CE_ANTIVIRAL, VIRUS_EXOTIC)
	if(prob(2))
		M.immunity_norm = max(M.immunity_norm - 1, 0)

/datum/reagent/sterilizine
	name = "Sterilizine"
	description = "Sterilizes wounds in preparation for surgery and thoroughly removes blood."
	taste_description = "bitterness"
	reagent_state = REAGENT_LIQUID
	color = "#c8a5dc"
	touch_met = 5

/datum/reagent/sterilizine/affect_touch(var/mob/living/carbon/M, var/alien, var/removed)
	M.germ_level -= min(removed*20, M.germ_level)
	for(var/obj/item/I in M.contents)
		I.was_bloodied = null
	M.was_bloodied = null

/datum/reagent/sterilizine/touch_obj(var/obj/O)
	O.germ_level -= min(volume*20, O.germ_level)
	O.was_bloodied = null

/datum/reagent/sterilizine/touch_turf(var/turf/T)
	T.germ_level -= min(volume*20, T.germ_level)
	for(var/obj/item/I in T.contents)
		I.was_bloodied = null
	for(var/obj/effect/decal/cleanable/blood/B in T)
		qdel(B)

/datum/reagent/leporazine
	name = "Leporazine"
	description = "Leporazine can be use to stabilize an individuals body temperature."
	taste_description = "bitterness"
	reagent_state = REAGENT_LIQUID
	color = "#c8a5dc"
	overdose = REAGENTS_OVERDOSE
	scannable = 1

/datum/reagent/leporazine/affect_blood(var/mob/living/carbon/M, var/alien, var/removed)
	if(M.bodytemperature > 310)
		M.bodytemperature = max(310, M.bodytemperature - (40 * TEMPERATURE_DAMAGE_COEFFICIENT))
	else if(M.bodytemperature < 311)
		M.bodytemperature = min(310, M.bodytemperature + (40 * TEMPERATURE_DAMAGE_COEFFICIENT))

/* Antidepressants */

#define ANTIDEPRESSANT_MESSAGE_DELAY 5*60*10

/datum/reagent/methylphenidate
	name = "Methylphenidate"
	description = "Improves the ability to concentrate."
	taste_description = "sourness"
	reagent_state = REAGENT_LIQUID
	color = "#bf80bf"
	metabolism = 0.01
	data = 0

/datum/reagent/methylphenidate/affect_blood(var/mob/living/carbon/M, var/alien, var/removed)
	if(alien == IS_DIONA)
		return
	if(volume <= 0.1 && M.chem_doses[type] >= 0.5 && world.time > data + ANTIDEPRESSANT_MESSAGE_DELAY)
		data = world.time
		to_chat(M, "<span class='warning'>You lose focus...</span>")
	else
		if(world.time > data + ANTIDEPRESSANT_MESSAGE_DELAY)
			data = world.time
			to_chat(M, "<span class='notice'>Your mind feels focused and undivided.</span>")

/datum/reagent/citalopram
	name = "Citalopram"
	description = "Stabilizes the mind a little."
	taste_description = "bitterness"
	reagent_state = REAGENT_LIQUID
	color = "#ff80ff"
	metabolism = 0.01
	data = 0

/datum/reagent/citalopram/affect_blood(var/mob/living/carbon/M, var/alien, var/removed)
	if(alien == IS_DIONA)
		return
	if(volume <= 0.1 && M.chem_doses[type] >= 0.5 && world.time > data + ANTIDEPRESSANT_MESSAGE_DELAY)
		data = world.time
		to_chat(M, "<span class='warning'>Your mind feels a little less stable...</span>")
	else
		M.add_chemical_effect(CE_MIND, 1)
		if(world.time > data + ANTIDEPRESSANT_MESSAGE_DELAY)
			data = world.time
			to_chat(M, "<span class='notice'>Your mind feels stable... a little stable.</span>")

/datum/reagent/paroxetine
	name = "Paroxetine"
	description = "Stabilizes the mind greatly, but has a chance of adverse effects."
	reagent_state = REAGENT_LIQUID
	color = "#ff80bf"
	metabolism = 0.01
	data = 0

/datum/reagent/paroxetine/affect_blood(var/mob/living/carbon/M, var/alien, var/removed)
	if(alien == IS_DIONA)
		return
	if(volume <= 0.1 && M.chem_doses[type] >= 0.5 && world.time > data + ANTIDEPRESSANT_MESSAGE_DELAY)
		data = world.time
		to_chat(M, "<span class='warning'>Your mind feels much less stable...</span>")
	else
		M.add_chemical_effect(CE_MIND, 2)
		if(world.time > data + ANTIDEPRESSANT_MESSAGE_DELAY)
			data = world.time
			if(prob(90))
				to_chat(M, "<span class='notice'>Your mind feels much more stable.</span>")
			else
				to_chat(M, "<span class='warning'>Your mind breaks apart...</span>")
				M.hallucination(200, 100)

/datum/reagent/nicotine
	name = "Nicotine"
	description = "A sickly yellow liquid sourced from tobacco leaves. Stimulates and relaxes the mind and body."
	taste_description = "peppery bitterness"
	reagent_state = REAGENT_LIQUID
	color = "#efebaa"
	metabolism = REM * 0.002
	overdose = 6
	scannable = 1
	data = 0
	reagent_addiction_strength = 2

/datum/reagent/nicotine/affect_blood(var/mob/living/carbon/M, var/alien, var/removed)
	if(alien == IS_DIONA)
		return
	if(prob(volume*20))
		M.add_chemical_effect(CE_PULSE, 1)
	if(volume <= 0.02 && M.chem_doses[type] >= 0.05 && world.time > data + ANTIDEPRESSANT_MESSAGE_DELAY * 0.3)
		data = world.time
		to_chat(M, "<span class='warning'>You feel antsy, your concentration wavers...</span>")
	else
		if(world.time > data + ANTIDEPRESSANT_MESSAGE_DELAY * 0.3)
			data = world.time
			M.add_event("relaxed", /datum/happiness_event/relaxed)

/datum/reagent/nicotine/overdose(var/mob/living/carbon/M, var/alien)
	..()
	M.add_chemical_effect(CE_PULSE, 2)

/datum/reagent/tobacco
	name = "Tobacco"
	description = "Cut and processed tobacco leaves."
	taste_description = "tobacco"
	reagent_state = REAGENT_SOLID
	color = "#684b3c"
	scannable = 1
	var/nicotine = REM * 0.2

/datum/reagent/tobacco/affect_blood(var/mob/living/carbon/M, var/alien, var/removed)
	..()
	M.reagents.add_reagent(/datum/reagent/nicotine, nicotine)

/datum/reagent/tobacco/fine
	name = "Fine Tobacco"
	taste_description = "fine tobacco"

/datum/reagent/tobacco/bad
	name = "Terrible Tobacco"
	taste_description = "acrid smoke"

/datum/reagent/tobacco/liquid
	name = "Nicotine Solution"
	description = "A diluted nicotine solution."
	reagent_state = REAGENT_LIQUID
	taste_mult = 0
	color = "#fcfcfc"
	nicotine = REM * 0.1

/datum/reagent/menthol
	name = "Menthol"
	description = "Tastes naturally minty, and imparts a very mild numbing sensation."
	taste_description = "mint"
	reagent_state = REAGENT_LIQUID
	color = "#80af9c"
	metabolism = REM * 0.002
	overdose = REAGENTS_OVERDOSE * 0.25
	scannable = 1
	data = 0

/datum/reagent/menthol/affect_blood(var/mob/living/carbon/M, var/alien, var/removed)
	if(alien == IS_DIONA)
		return
	if(world.time > data + ANTIDEPRESSANT_MESSAGE_DELAY * 0.35)
		data = world.time
		to_chat(M, "<span class='notice'>You feel faintly sore in the throat.</span>")

/datum/reagent/rezadone
	name = "Rezadone"
	description = "A powder with almost magical properties, this substance can effectively treat genetic damage in humanoids, though excessive consumption has side effects."
	taste_description = "sickness"
	reagent_state = REAGENT_SOLID
	color = "#669900"
	overdose = REAGENTS_OVERDOSE
	scannable = 1
	flags = IGNORE_MOB_SIZE

/datum/reagent/rezadone/affect_blood(var/mob/living/carbon/M, var/alien, var/removed)
	M.adjustCloneLoss(-20 * removed)
	M.adjustOxyLoss(-2 * removed)
	M.heal_organ_damage(20 * removed, 20 * removed)
	M.adjustToxLoss(-20 * removed)
	if(M.chem_doses[type] > 3 && ishuman(M))
		var/mob/living/carbon/human/H = M
		for(var/obj/item/organ/external/E in H.organs)
			E.disfigured = 1 //currently only matters for the head, but might as well disfigure them all.
	if(M.chem_doses[type] > 10)
		M.make_dizzy(5)
		M.make_jittery(5)

/datum/reagent/noexcutite
	name = "Noexcutite"
	description = "A thick, syrupy liquid that has a lethargic effect. Used to cure cases of jitteriness."
	taste_description = "numbing coldness"
	reagent_state = REAGENT_LIQUID
	color = "#bc018a"
	overdose = REAGENTS_OVERDOSE
	scannable = 1
	flags = IGNORE_MOB_SIZE

/datum/reagent/noexcutite/affect_blood(var/mob/living/carbon/M, var/alien, var/removed)

	if(alien != IS_DIONA)
		M.make_jittery(-50)

/datum/reagent/antidexafen
	name = "Antidexafen"
	description = "All-in-one cold medicine. Fever, cough, sneeze, safe for babies."
	taste_description = "cough syrup"
	reagent_state = REAGENT_LIQUID
	color = "#c8a5dc"
	overdose = 60
	scannable = 1
	metabolism = REM * 0.05
	flags = IGNORE_MOB_SIZE

/datum/reagent/antidexafen/affect_blood(var/mob/living/carbon/M, var/alien, var/removed)
	if(alien == IS_DIONA)
		return

	M.add_chemical_effect(CE_PAINKILLER, 15)
	M.add_chemical_effect(CE_ANTIVIRAL, 1)

/datum/reagent/antidexafen/overdose(var/mob/living/carbon/M, var/alien)
	..()
	M.hallucination(60, 20)
	M.druggy = max(M.druggy, 2)

/datum/reagent/adrenaline
	name = "Adrenaline"
	description = "Adrenaline is a hormone used as a drug to treat cardiac arrest and other cardiac dysrhythmias resulting in diminished or absent cardiac output."
	taste_description = "rush"
	reagent_state = REAGENT_LIQUID
	color = "#c8a5dc"
	scannable = 1
	overdose = 20
	metabolism = 0.1

/datum/reagent/adrenaline/affect_blood(var/mob/living/carbon/human/M, var/alien, var/removed)
	if(alien == IS_DIONA)
		return

	if(M.chem_doses[type] < 0.2)	//not that effective after initial rush
		M.add_chemical_effect(CE_PAINKILLER, min(30*volume, 80))
		M.add_chemical_effect(CE_PULSE, 1)
	else if(M.chem_doses[type] < 1)
		M.add_chemical_effect(CE_PAINKILLER, min(10*volume, 20))
	M.add_chemical_effect(CE_PULSE, 2)
	if(M.chem_doses[type] > 10)
		M.make_jittery(5)
	if(volume >= 5 && M.is_asystole())
		remove_self(5)
		M.resuscitate()

/datum/reagent/nanoblood
	name = "Nanoblood"
	description = "A stable hemoglobin-based nanoparticle oxygen carrier, used to rapidly replace lost blood. Toxic unless injected in small doses. Does not contain white blood cells."
	taste_description = "blood with bubbles"
	reagent_state = REAGENT_LIQUID
	color = "#c10158"
	scannable = 1
	overdose = 5
	metabolism = 1

/datum/reagent/nanoblood/affect_blood(var/mob/living/carbon/human/M, var/alien, var/removed)
	if(!M.should_have_organ(BP_HEART)) //We want the var for safety but we can do without the actual blood.
		return
	if(M.regenerate_blood(4 * removed))
		M.immunity = max(M.immunity - 0.1, 0)
		if(M.chem_doses[type] > M.species.blood_volume/8) //half of blood was replaced with us, rip white bodies
			M.immunity = max(M.immunity - 0.5, 0)

/datum/reagent/chloroform
	name = "Chloroform"
	description = "A highly toxic chemical."
	taste_description = "sweetness and suffocation"
	taste_mult = 0.6
	reagent_state = REAGENT_LIQUID
	color = "#dfdbda31"
	metabolism = REM
	overdose = REAGENTS_OVERDOSE * 0.5

/datum/reagent/chloroform/affect_blood(var/mob/living/carbon/M, var/alien, var/removed)

	var/threshold = 1

	if(M.chem_doses[type] == metabolism * threshold)
		M.confused += 2
		M.drowsyness += 2
	else if(M.chem_doses[type] < 2 * threshold)
		M.Weaken(15)
		M.eye_blurry = max(M.eye_blurry, 5)
	else
		M.sleeping = max(M.sleeping, 10)

/datum/reagent/tartaremetic
	name = "Antimony potassium tartrate"
	description = "Induced vomiting, purgative."
	taste_description = "sweetish with a metallic aftertaste."
	taste_mult = 0.6
	reagent_state = REAGENT_LIQUID
	color = "#e2e2e2d8"
	metabolism = REM * 0.1
	overdose = REAGENTS_OVERDOSE * 0.5

/datum/reagent/tartaremetic/affect_blood(var/mob/living/carbon/human/M, var/alien, var/removed)
	var/threshold = 1
	if(M.chem_doses[type] == metabolism * threshold)
		M.vomit(level=1)
	else if(M.chem_doses[type] < 2 * threshold)
		M.vomit(level=2)
	else
		M.vomit(level=3)
	var/removing = (2 * removed)
	for(var/datum/reagent/R in M.ingested.reagent_list)
		if(istype(R, /datum/reagent/toxin))
			M.ingested.remove_reagent(R.type, removing)
			return
	for(var/datum/reagent/R in M.reagents.reagent_list)
		if(istype(R, /datum/reagent/toxin))
			M.reagents.remove_reagent(R.type, removing)
			return
// prolly set it up wrong LMFAO
/datum/reagent/tartaremetic/overdose(var/mob/living/carbon/M, var/alien)
	..()
	M.losebreath += 2
	M.adjustOxyLoss(2)
	M.Weaken(4)