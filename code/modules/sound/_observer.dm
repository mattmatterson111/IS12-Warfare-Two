// Arguments:
//   /datum/sound_emitter/emitter: The emitter whose sound was SOUND_UPDATEd.
// Remember that SOUND_UPDATE will NOT start playing a sound!
// You must first send the sound WITHOUT SOUND_UPDATE for the client to start
//   hearing it if they couldn't before
// Also remember that sounds are DATUMS and hence REFERENCE TYPES so copy
//   in whatever you registered to the event!!!
// ****** /event/sound_updated

// Arguments:
//   /datum/sound_emitter/emitter: The emitter that started playing a sound
// ****** /event/sound_started

// Arguments:
//   /datum/sound_emitter/emitter: The emitter that stopped playing a sound
// ****** /event/sound_stopped

// Arguments:
//   /sound/S: The sound that was pushed
//   /datum/sound_emitter/emitter: The emitter that played the sound
// ****** /event/sound_pushed

/* -------------------------------------------------------------------------- */
/*                 VG EVENTS CONVERTED TO BAY OSBERVERS BELOW                 */
/* -------------------------------------------------------------------------- */

/* ---------------------- THE EXAMPLES ABOVE ARE LEGACY --------------------- */
/* -------------------------------------------------------------------------- */

//	Observer Pattern Implementation: Moved
//		Registration type: /atom/movable
//
//		Raised when: An /atom/movable instance has moved using Move() or forceMove().
//
//		Arguments that the called proc should expect:
//			/atom/movable/moving_instance: The instance that moved
//			/atom/old_loc: The loc before the move.
//			/atom/new_loc: The loc after the move.

// SOUND UPDATED OBSERVER
GLOBAL_DATUM_INIT(sound_updated_event, /decl/observ/sound_updated, new)

/// Raised when a sound emitter's sound was updated.
/// Arguments:
///   /datum/sound_emitter/emitter: The emitter whose sound was updated.
/decl/observ/sound_updated
    name = "Sound Updated"
    expected_type = /datum/sound_emitter

// SOUND STARTED OBSERVER
GLOBAL_DATUM_INIT(sound_started_event, /decl/observ/sound_started, new)

/// Raised when a sound emitter started playing a sound.
/// Arguments:
///   /datum/sound_emitter/emitter: The emitter that started playing a sound.
/decl/observ/sound_started
    name = "Sound Started"
    expected_type = /datum/sound_emitter

// SOUND STOPPED OBSERVER
GLOBAL_DATUM_INIT(sound_stopped_event, /decl/observ/sound_stopped, new)

/// Raised when a sound emitter stopped playing a sound.
/// Arguments:
///   /datum/sound_emitter/emitter: The emitter that stopped playing a sound.
/decl/observ/sound_stopped
    name = "Sound Stopped"
    expected_type = /datum/sound_emitter

// SOUND PUSHED OBSERVER
GLOBAL_DATUM_INIT(sound_pushed_event, /decl/observ/sound_pushed, new)

/// Raised when a sound was pushed.
/// Arguments:
///   /sound/S: The sound that was pushed.
///   /datum/sound_emitter/emitter: The emitter that played the sound.
/decl/observ/sound_pushed
    name = "Sound Pushed"
    expected_type = /datum/sound_emitter
