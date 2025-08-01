// Callback macros for 515 compatibility, credit to CM for giving me the idea to if/else this for backwards compatibility as well

#if DM_VERSION < 515

#define GLOBAL_PROC_REF(NAME) (.proc/##NAME)

#define PROC_REF(NAME) (.proc/##NAME)

#define PROC_BY_TYPE(PATH, NAME) (##PATH.proc/##NAME)

#define VERB(NAME) (.verb/##NAME)

#define VERB_BY_TYPE(PATH, NAME) (##PATH.verb/##NAME)

#define LIBCALL call

#else

#define GLOBAL_PROC_REF(NAME) (.proc/##NAME)

#define PROC_REF(NAME) (nameof(.proc/##NAME))

#define PROC_BY_TYPE(PATH, NAME) (nameof(##PATH.proc/##NAME))

#define PROC_BY_TYPE_UNSAFE(PATH, NAME) (nameof(##PATH::proc/##NAME))

#define VERB(NAME) (nameof(.verb/##NAME))

#define VERB_BY_TYPE(PATH, NAME) (nameof(##TYPE.verb/##NAME))

#define LIBCALL call_ext

#endif