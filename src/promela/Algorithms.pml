#ifndef __ALGORITHMS_PML__
#define __ALGORITHMS_PML__

#define ALGO_NO_MOVE   (1)
#define ALGO_TO_HALF   (2)
#define ALGO_TO_OTHER  (3)
#define ALGO_VIG_2COLS (4)
#define ALGO_VIG_3COLS (5)
#define ALGO_OPTIMAL   (6)
#define ALGO_FLO_ALGO3EXT (7)
#define ALGO_FLO_ALGO3EXT_PRIME (8)
#define ALGO_3EXT_NONQSS (9)
#define ALGO_WADA_4EXT (10)
#define ALGO_WADA_5EXT (11)
#define ALGO_TIXEUIL_EXTRA (12)


#if ALGO == ALGO_NO_MOVE
#  define ALGO_NAME      "ALGO_NO_MOVE"
#  define Algorithm(o,c) Alg_NoMove(o,c)
#  define MAX_COLOR      (BLACK)
inline Alg_NoMove(obs, command)
{
    command.move		= STAY;
    command.new_color	= BLACK
}

#elif ALGO == ALGO_TO_HALF
#  define ALGO_NAME      "ALGO_TO_HALF"
#  define Algorithm(o,c) Alg_MoveToHalf(o,c)
#  define MAX_COLOR      (BLACK)
inline Alg_MoveToHalf(obs, command)
{
    command.move		= TO_HALF;
    command.new_color	= BLACK
}

#elif ALGO == ALGO_TO_OTHER
#  define ALGO_NAME      "ALGO_TO_OTHER"
#  define Algorithm(o,c) Alg_MoveToOther(o,c)
#  define MAX_COLOR      (BLACK)
inline Alg_MoveToOther(obs, command)
{
    command.move		= TO_OTHER;
    command.new_color	= BLACK
}

#elif ALGO == ALGO_VIG_2COLS
#  define ALGO_NAME      "ALGO_VIG_2COLS"
#  define Algorithm(o,c) Alg_Vig2Cols(o,c)
#  define MAX_COLOR      (WHITE)
inline Alg_Vig2Cols(obs, command)
{
    command.move      = STAY;
    command.new_color = obs.color.me;
    if
    :: (obs.color.me == BLACK) ->
        if
        :: (obs.color.other == BLACK) -> command.new_color = WHITE
        :: (obs.color.other == WHITE) -> skip
        fi
    :: (obs.color.me == WHITE) ->
        if
        :: (obs.color.other == BLACK) -> command.move = TO_OTHER
        :: (obs.color.other == WHITE) -> command.move = TO_HALF; command.new_color = BLACK
        fi	
    :: else -> command.new_color = BLACK
    fi
}

#elif ALGO == ALGO_VIG_3COLS
#  define ALGO_NAME      "ALGO_VIG_3COLS"
#  define Algorithm(o,c) Alg_Vig3Cols(o,c)
#  define MAX_COLOR      (RED)
inline Alg_Vig3Cols(obs, command)
{
    command.move      = STAY;
    command.new_color = obs.color.me;
    if
    :: (obs.color.me == BLACK) ->
        if
        :: (obs.color.other == BLACK)	-> command.move = TO_HALF; command.new_color = WHITE
        :: (obs.color.other == WHITE)	-> command.move = TO_OTHER
        :: (obs.color.other == RED)		-> skip
        fi
    :: (obs.color.me == WHITE) ->
        if
        :: (obs.color.other == BLACK)	-> skip
        :: (obs.color.other == WHITE)	-> command.new_color = RED
        :: (obs.color.other == RED)		-> command.move = TO_OTHER
        fi
    :: (obs.color.me == RED) -> 
        if
        :: (obs.color.other == BLACK)	-> command.move = TO_OTHER
        :: (obs.color.other == WHITE)	-> skip
        :: (obs.color.other == RED)		-> command.new_color = BLACK
        fi
    :: else -> command.new_color = BLACK
    fi
}

#elif ALGO == ALGO_FLO_ALGO3EXT
#  define ALGO_NAME      "ALGO_FLO_ALGO3EXT"
#  define Algorithm(o,c) Alg_FloAlgo3Ext(o,c)
#  define MAX_COLOR      (RED)
inline Alg_FloAlgo3Ext(obs, command)
{
    command.move      = STAY;
    command.new_color = obs.color.me;
    if
    :: (obs.color.other == BLACK)	-> command.move = TO_HALF; command.new_color = WHITE
    :: (obs.color.other == WHITE)	-> command.new_color = RED
    :: (obs.color.other == RED)		-> command.move = TO_OTHER; command.new_color = BLACK
    :: else -> command.new_color = BLACK
    fi
}

#elif ALGO == ALGO_FLO_ALGO3EXT_PRIME
#  define ALGO_NAME      "ALGO_FLO_ALGO3EXT_PRIME"
#  define Algorithm(o,c)	Alg_FloAlgo3ExtPrime(o,c)
#  define MAX_COLOR		(RED)
inline Alg_FloAlgo3ExtPrime(obs, command)
{
    command.move      = STAY;
    command.new_color = obs.color.me;
    if
    :: (obs.color.other == BLACK)	-> command.move = TO_HALF; command.new_color = WHITE
    :: (obs.color.other == WHITE)	-> command.move = TO_OTHER; command.new_color = RED
    :: (obs.color.other == RED)		-> command.new_color = BLACK
    :: else -> command.new_color = BLACK
    fi
}

#elif ALGO == ALGO_3EXT_NONQSS
#  define ALGO_NAME     "ALGO_3EXT_NONQSS"
#  define Algorithm(o,c)	Alg_3ExtNonQSS(o,c)
#  define MAX_COLOR		(RED)
inline Alg_3ExtNonQSS(obs, command)
{
    command.move      = STAY;
    command.new_color = obs.color.me;
    if
    :: (obs.color.other == BLACK)	-> command.move = TO_HALF; command.new_color = WHITE
    :: (obs.color.other == WHITE)	-> command.new_color = RED
    :: (obs.color.other == RED)		-> command.move = TO_OTHER; command.new_color = WHITE
    :: else -> command.new_color = BLACK
    fi
}

#elif ALGO == ALGO_WADA_4EXT
#  define ALGO_NAME      "ALGO_WADA_4EXT"
#  define Algorithm(o,c) Alg_Wada4ExtProto(o,c)
#  define MAX_COLOR      (YELLOW)
inline Alg_Wada4ExtProto(obs, command)
{
    command.move      = STAY;
    command.new_color = obs.color.me;
    if
    :: (obs.color.other == BLACK)	-> command.move = TO_HALF;    command.new_color = WHITE
    :: (obs.color.other == WHITE)	-> command.new_color = RED
    :: (obs.color.other == RED)		-> command.move = TO_OTHER;   command.new_color = YELLOW
    :: (obs.color.other == YELLOW)	-> command.new_color = BLACK
    :: else -> command.new_color = BLACK
    fi
}

#elif ALGO == ALGO_WADA_5EXT
#  define ALGO_NAME      "ALGO_WADA_5EXT"
#  define Algorithm(o,c) Alg_Wada5Ext(o,c)
#  define MAX_COLOR      (GREEN)
inline Alg_Wada5Ext(obs, command)
{
    command.move      = STAY;
    command.new_color = obs.color.me;
    if
    :: (obs.color.other == BLACK)	-> command.move = TO_HALF;    command.new_color = WHITE
    :: (obs.color.other == WHITE)	-> command.new_color = RED
    :: (obs.color.other == RED)		-> command.move = TO_OTHER;   command.new_color = YELLOW
    :: (obs.color.other == YELLOW)	-> command.new_color = GREEN
    :: (obs.color.other == GREEN)	-> command.new_color = BLACK
    :: else -> command.new_color = BLACK
    fi
}

#elif ALGO == ALGO_OPTIMAL
#  define ALGO_NAME      "ALGO_OPTIMAL"
#  define Algorithm(o,c) Alg_Optimal(o,c)
#  define MAX_COLOR      (WHITE)
inline Alg_Optimal(obs, command)
{
    command.move      = STAY;
    command.new_color = obs.color.me;
    if
    :: (obs.color.me == BLACK) ->
        if
        :: (obs.color.other == BLACK) -> command.new_color = WHITE
        :: (obs.color.other == WHITE) -> skip
        fi
    :: (obs.color.me == WHITE) ->
        if
        :: obs.same_position -> skip
        :: else ->
            if
            :: (obs.color.other == BLACK) -> command.move = TO_OTHER
            :: (obs.color.other == WHITE) -> command.move = TO_HALF; command.new_color = BLACK
            fi
        fi
    :: else -> command.new_color = BLACK
    fi
}

#elif ALGO == ALGO_TIXEUIL_EXTRA
#  define ALGO_NAME      "ALGO_TIXEUIL_EXTRA"
#  define Algorithm(o,c) Alg_TixeuilExtra(o,c)
#  define MAX_COLOR      (YELLOW)
#  define COLMTWHITE     (YELLOW)
#  define COLMTBLACK     (RED)
inline Alg_TixeuilExtra(obs, command)
{
    command.move      = STAY;
    command.new_color = obs.color.me;
    if
    :: (obs.color.me == BLACK) ->
        if
        :: (obs.color.other == BLACK) ||
           (obs.color.other == COLMTBLACK) -> command.new_color = COLMTWHITE
        :: (obs.color.other == WHITE) ||
           (obs.color.other == COLMTWHITE) -> skip
        fi
    :: (obs.color.me == WHITE) ->
        if
        :: obs.same_position -> skip
        :: else ->
            if
            :: (obs.color.other == BLACK) -> command.move = TO_OTHER
            :: (obs.color.other == WHITE) ||
               (obs.color.other == COLMTBLACK) -> {
                command.move = TO_HALF;
                command.new_color = COLMTBLACK;
            }
            :: (obs.color.other == COLMTWHITE) -> command.move = TO_OTHER
            fi
        fi
    :: (obs.color.me == COLMTBLACK) -> command.new_color = BLACK
    :: (obs.color.me == COLMTWHITE) -> command.new_color = WHITE; command.move = TO_OTHER
    :: else -> command.new_color = BLACK
    fi
}

#elif ALGO == ALGO_REGULAR6
#  define ALGO_NAME      "ALGO_REGULAR6"
#  define Algorithm(o,c) Alg_Regular6(o,c)
#  define COL_A          (0)
#  define COL_A_P        (1)
#  define COL_B          (2)
#  define COL_B_P        (3)
#  define COL_C          (4)
#  define COL_C_P        (5)
#  define MAX_COLOR      (COL_C_P)
inline Alg_Regular6(obs, command)
{
    command.move      = STAY;
    command.new_color = obs.color.me;
    if
    :: (obs.color.me == COL_A_P) -> command.new_color = COL_B
    :: (obs.color.me == COL_B_P) -> command.new_color = COL_C
    :: (obs.color.me == COL_C_P) -> command.new_color = COL_A
    :: (obs.color.me == COL_A) ->
        if
        :: (obs.color.other == COL_A) -> command.new_color = COL_A_P; command.move = TO_HALF;
        :: (obs.color.other == COL_B) -> command.move = TO_OTHER
        :: else -> skip
        fi
    :: (obs.color.me == COL_B) ->
        if
        :: (obs.color.other == COL_B) -> command.new_color = COL_B_P
        :: (obs.color.other == COL_C) -> command.move = TO_OTHER
        :: else -> skip
        fi
    :: (obs.color.me == COL_C) -> 
        if
        :: (obs.color.other == COL_C) -> command.new_color = COL_C_P
        :: (obs.color.other == COL_A) -> command.move = TO_OTHER
        :: else -> skip
        fi
    :: else -> command.new_color = COL_A
    fi
}

#elif ALGO == ALGO_REGULAR5
#  define ALGO_NAME      "ALGO_REGULAR5"
#  define Algorithm(o,c) Alg_Regular5(o,c)
#  define COL_A          (0)
#  define COL_A_P        (1)
#  define COL_B          (2)
#  define COL_B_P        (3)
#  define COL_C          (4)
#  define MAX_COLOR      (COL_C)
inline Alg_Regular5(obs, command)
{
    command.move      = STAY;
    command.new_color = obs.color.me;
    if
    :: (obs.color.me == COL_A_P) -> command.new_color = COL_B
    :: (obs.color.me == COL_B_P) -> command.new_color = COL_C
    :: (obs.color.me == COL_A) ->
        if
        :: (obs.color.other == COL_A) -> command.new_color = COL_A_P; command.move = TO_HALF;
        :: (obs.color.other == COL_B) -> command.move = TO_OTHER
        :: else -> skip
        fi
    :: (obs.color.me == COL_B) ->
        if
        :: (obs.color.other == COL_B) -> command.new_color = COL_B_P
        :: (obs.color.other == COL_C) -> command.move = TO_OTHER
        :: else -> skip
        fi
    :: (obs.color.me == COL_C) -> 
        if
        :: (obs.color.other == COL_C) -> command.new_color = COL_A
        :: (obs.color.other == COL_A) -> command.move = TO_OTHER
        :: else -> skip
        fi
    :: else -> command.new_color = COL_A
    fi
}

#elif ALGO == ALGO_REGULAR4
#  define ALGO_NAME      "ALGO_REGULAR4"
#  define Algorithm(o,c) Alg_Regular4(o,c)
#  define COL_A          (0)
#  define COL_A_P        (1)
#  define COL_B          (2)
#  define COL_C          (3)
#  define MAX_COLOR      (COL_C)
inline Alg_Regular4(obs, command)
{
    command.move      = STAY;
    command.new_color = obs.color.me;
    if
    :: (obs.color.me == COL_A_P) -> command.new_color = COL_B
    :: (obs.color.me == COL_A) ->
        if
        :: (obs.color.other == COL_A) -> command.new_color = COL_A_P; command.move = TO_HALF;
        :: (obs.color.other == COL_B) -> command.move = TO_OTHER
        :: else -> skip
        fi
    :: (obs.color.me == COL_B) ->
        if
        :: (obs.color.other == COL_B) -> command.new_color = COL_C
        :: (obs.color.other == COL_C) -> command.move = TO_OTHER
        :: else -> skip
        fi
    :: (obs.color.me == COL_C) -> 
        if
        :: (obs.color.other == COL_C) -> command.new_color = COL_A
        :: (obs.color.other == COL_A) -> command.move = TO_OTHER
        :: else -> skip
        fi
    :: else -> command.new_color = COL_A
    fi
}

#else
#  error "No algorithm defined. Define ALGO."
#endif

#define NUM_COLORS  ((MAX_COLOR)-(BLACK)+1)

#endif
