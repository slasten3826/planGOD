#ifndef PA_COGNITIVE_H
#define PA_COGNITIVE_H

/*
 * pa_cognitive.h
 *
 * Cognitive engine — operator query layer above Packet substrate.
 *
 * Reads:   const PaApp* (after pa_app_update returns)
 * Outputs: PaCogState   (shells read this, never PaApp directly)
 *
 * Include graph:
 *   pa_cognitive.h  -> packet/core.h only  (thin public header)
 *   pa_cognitive.c  -> runtime_internal.h  (full, implementation only)
 *
 * PaCogState does NOT live inside PaApp.
 * Shell owns both. Shell calls in sequence:
 *
 *   pa_app_update(&app);
 *   pa_cog_update(&cog, &app);
 *
 * Trusts field state after both pa_update_packet_field calls inside
 * pa_app_update have completed. No extra refresh step in pa_app_update.
 *
 * Files:
 *   include/packet_adventure/pa_cognitive.h  (this file)
 *   src/cognitive/pa_cognitive.c
 */

#include <stdint.h>
#include "packet/core.h"    /* PA_OP_COUNT, PaApp, PaOperatorType */

/* ------------------------------------------------------------------ */
/* Scan radius — torus-consistent local window, PSP-safe              */
/* ------------------------------------------------------------------ */
#define PA_COG_SCAN_RADIUS 8

/* ------------------------------------------------------------------ */
/* Direction indices                                                   */
/* ------------------------------------------------------------------ */
#define PA_COG_DIR_UP    0
#define PA_COG_DIR_DOWN  1
#define PA_COG_DIR_LEFT  2
#define PA_COG_DIR_RIGHT 3

/* ------------------------------------------------------------------ */
/* OBSERVE result                                                      */
/* Scanned over torus-wrapped window of PA_COG_SCAN_RADIUS.           */
/* ------------------------------------------------------------------ */
typedef struct {
    float    manifest_ratio;             /* manifest cells / total in window  */
    float    turbulence_pressure;        /* turbulence cells / manifest cells */
    float    crystal_density;            /* crystal cells / total in window   */
    uint16_t visible_ops[PA_OP_COUNT];  /* count of each operator in window  */
    uint8_t  dominant_op;              /* operator with highest count       */
} PaObserveResult;

/* ------------------------------------------------------------------ */
/* CHOOSE result                                                       */
/* Directional query, torus-consistent movement targets.              */
/* ------------------------------------------------------------------ */
typedef struct {
    uint8_t passable;       /* 1 = valid move target; 0 = blocked        */
    float   manifest_bias;  /* [0..1]  mf_strength / 3                   */
    float   move_cost;      /* [0..1]  density / 255                     */
    float   dissolve_risk;  /* [0..1]  turbulence * crystal_proximity    */
    float   score;          /* composite; -1.0 if not passable           */
} PaChoiceDir;

typedef struct {
    PaChoiceDir dirs[4];   /* indexed PA_COG_DIR_* */
    int8_t      best_dir;  /* PA_COG_DIR_* of highest score; -1 if all blocked */
} PaChooseResult;

/* ------------------------------------------------------------------ */
/* DISSOLVE result                                                     */
/* Local dissolution pressure at Packet's current position.           */
/* ------------------------------------------------------------------ */
typedef struct {
    float    local_pressure;   /* density[py][px] / 255                      */
    float    collapse_risk;    /* incompatible op ratio in radius-2 window   */
    uint16_t crystal_count;    /* CRYSTAL cells in scan window               */
    uint8_t  near_wall;        /* 1 if wall tile in immediate adjacency      */
} PaDissolveResult;

/* ------------------------------------------------------------------ */
/* PaCogState — aggregate, consumed read-only by all shells           */
/* ------------------------------------------------------------------ */
typedef struct {
    PaObserveResult  observe;
    PaChooseResult   choose;
    PaDissolveResult dissolve;
    uint32_t         frame;    /* app->frame at time of last update */
} PaCogState;

/* ------------------------------------------------------------------ */
/* API                                                                 */
/* ------------------------------------------------------------------ */

/* Zero-initialize. Call once after pa_app_init(). */
void pa_cog_init(PaCogState *cog);

/*
 * Recompute full cognitive state.
 * Call from shell once per tick, after pa_app_update() returns.
 * Does not modify PaApp.
 */
void pa_cog_update(PaCogState *cog, const PaApp *app);

#endif /* PA_COGNITIVE_H */
