
/datum/language/warfare
	name = "warfare language"
	desc = "Nothing. Just code stuff"
	speech_verb = "says"
	whisper_verb = "whispers"
	flags = RESTRICTED

/datum/language/warfare/get_spoken_verb(var/msg_end)
	switch(msg_end)
		if("!")
			return pick("exclaims", "shouts", "yells") //TODO: make the basic proc handle lists of verbs.
		if("?")
			return ask_verb
	return speech_verb

/datum/language/warfare/red
	name = LANGUAGE_RED
	desc = "This is the languaged used by the Red Team."
	colour = "red_team"
	key = "r"
	syllables = list("zhena", "reb", "kot", "tvoy", "vodka", "blyad", "lenin", "ponimat", "zhit", "kley", "sto", "yat", "si", "det", "re", "be", "nok", "chto", "tovarish", "kak", "govor", "navernoe", "da", "net", "horosho", "pochemu", "privet", "ebat", "krovat", "stol", "za", "ryad", "ka", "voyna", "dumat", "patroni", "fashisti", "zdorovie", "day", "dengi", "nemci", "chehi", "odin", "dva", "soyuz", "holod", "granata", "ne", "re", "ru", "rukzak")

/datum/language/warfare/blue
	name = LANGUAGE_BLUE
	desc = "This is the languaged used by the Blue Team."
	colour = "blue_team"
	key = "z"
	syllables = list("byt", "ten", "ze", "ktery", "pan", "hlava", "zem", "lide", "doba", "dobry", "cely", "tvrdy", "roz", "hodny", "nezlomny", "staly", "scvrnkly", "ener", "gicky", "nezmen", "itelne", "hi", "ved", "dur", "pec", "dat", "bet", "ten", "on", "na", "he", "ktere", "pen", "hivot", "clo", "vek", "pre", "zeme", "lidu", "dob", "hlav", "mht", "moci", "muse", "vedet", "chtht", "jht", "rhci", "cele", "hive", "trvanlive", "hou", "hev", "nate", "dobre")

/datum/language/warfare/diplomatic //used by both team caps to ""communicate"" over the phone
	name = LANGUAGE_DIPLOMATIC
	desc = "Born out of centuries of hostile Red-Blue relations, this 'language' mutated from the preservation and evolution of centuries of insults exchanged between reds and blues. Eventually the range of insults and their combinations covered a wide variety of subtle meanings, causing it to become the de-facto diplomatic language of both nations, and their only method of communication."
	key = "t"
	speech_verb = "screams"
	///EVERY SYLIBLE AN INSULT
	syllables = list(" FUCK YOU. "," I KNOW WHERE YOU LIVE. "," YOUR FATHER IS A NICE PERSON. "," YOU HAVE NO SENTIRES, NO ENGINEERS, AND NO TRENCHES! "," DO YOU KNOW WHO ELSE GOT SLAMMED BY ARTILLERY? "," GET HELP. "," STALY ENER NOK BE! "," YOU'RE BAD! YOU'RE BAD! YOU'RE BAD! "," KILL YOURSELF, METAPHORICALLY SPEAKING. "," REDDIE GRAY WILL STAB YOU FOR 5 TEETH TO GET A CAN OF PISSARDINES! "," WHO THE FUCK ARE YOU? "," MY DAD RUNS THE NATION! HE'LL USE THE MEGA-GUN ON YOU! "," I BET YOU DON'T BRIBE NEARLY AS MANY STATE OFFICIALS AS I DO! "," IT'S JUST NOT THE SAME! "," IF YOU WANT A FUCKING BRAWL COME DOWN TO MY COMMAND TRENCH AND I'LL KICK YOUR FUCKING HEAD IN! I'LL DO YOU IN! "," YOU NEED TO TAKE THE E10 TRAIN ROUTE TO YOUR CAPITAL CITY. ", "THANK YOU, REALLY, THANK YOU."," TABLE. "," NAME EVERY TIER OF THE ANCIENT GREENSLANDIAN NOBLE SYSTEM. "," EGALITARIAN OPINION DETCTED. EGALITARIAN OPINION REJECTED. "," STINKY. "," YOU WANT ME TO CALM DOWN? So be it, I shall briefly speak in a calmer fasion henceforth to accentuate the fact that I am a sapient being capable of higher thought and reasoning, something that your BROKE ASS ISN'T! "," FUK OF!!! ")
	//My sympathies go out to the newly spawned private seeing this as they go grab a gas mask.