/datum/backstory/nepotismcaptain
	name = "The product of Nepotism"
	description = "<b>You.</b> Yes, <i>you.</i> <i>You</i> come from a high-end family within Redistan, you know practically nothing about war, weaponry, or the like. All you really know is that your family is rich, and that you have supreme authority over all, and that noone should question it."
	chance = 15 // rare, since it edits your stats.

/datum/backstory/nepotismcaptain/apply(mob/living/carbon/human/user)
	. = ..() // fuck you?? you're a nepo baby, you don't know how to FIGHT
	user.SKILL_LEVEL(melee) = rand(3,6)
	user.SKILL_LEVEL(auto_rifle) = rand(3,6)
	user.SKILL_LEVEL(semi_rifle) = rand(3,6)
	user.SKILL_LEVEL(sniper) = rand(3,6)
	user.SKILL_LEVEL(shotgun) = rand(3,6)
	user.SKILL_LEVEL(lmg) = rand(3,6)
	user.SKILL_LEVEL(smg) = rand(3,6)
	user.SKILL_LEVEL(boltie) = rand(3,6)

// pracs

/datum/backstory/disgruntledprac
	name = "The product of Spite"
	description = "<b>You.</b> Yes, <i>you.</i> <i>You</i> are a practicioner and- <b><i>THIS?</b> This</i> is no place for you to be.. You wanted to serve in a clinic, but <i>nnoooo..</i> they just had to send you HERE, wanting you to be both NEUTRAL and- to only aid the team that hired you..? It just doesn't make sense! Alas, you still have to do your duties.. <i>But..</i> Noone said you had to do it with a smile."
	chance = 15

/datum/backstory/scholar
	name = "The Product of Intelligence"
	description = "<b>You.</b> Yes, <i>you.</i> <i>You</i> are a practitioner of talent, molded by rigorous study and honed in the halls of a clinic. You were an apprentice once, yet even then, you showed rare insight and a quick mastery over complex practices, adept as any seasoned practitioner. And <b><i>THIS?</b> This</i> is where they send you? To play impartial to a team and ignore the greater good? <i>Unbelievable.</i> Still, you will serve, but you won't let anyone forget that you should be somewhere better.."
	chance = 15

/datum/backstory/idealistic
	name = "The Idealist"
	description = "<b>You.</b> Yes, <i>you.</i> <i>You</i> are a practitioner with purpose, driven by a vision to heal and uplift others. While others may have come here grudgingly, <i>you</i> volunteered. You believe in aiding those who need it most, and you’re ready to face any challenge. Every patient is a new opportunity, every duty a calling. This place may not be the clinic of your dreams, but to you, it’s a canvas for compassion."
	chance = 15

/datum/backstory/frontier_medic
	name = "The Frontier Beak"
	description = "<b>You.</b> Yes, <i>you.</i> <i>You</i> are a practitioner seasoned by the harsh conditions of remote outposts and colonies. This isn’t your first time on the frontier, and you’re used to working with limited supplies and improvising when things get tough. The frontline feels almost <i>luxurious</i> by comparison, and you thrive on the challenge. If anyone here knows how to survive, it’s you."
	chance = 15
