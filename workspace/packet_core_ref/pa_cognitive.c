/*
 * pa_cognitive.c
 *
 * Cognitive engine — OBSERVE / CHOOSE / DISSOLVE over Packet substrate.
 *
 * All world access is torus-consistent via pa_wrap_coord.
 * All scans are local-window only (PA_COG_SCAN_RADIUS). PSP-safe.
 * runtime_internal.h included here only, not in pa_cognitive.h.
 */

#include <string.h>
#include "packet_adventure/pa_cognitive.h"
#include "packet_adventure/runtime_internal.h"

/* ------------------------------------------------------------------ */
/* Internal: float clamp                                              */
/* ------------------------------------------------------------------ */
static float pa_cog_clampf(float v) {
    if (v < 0.0f) return 0.0f;
    if (v > 1.0f) return 1.0f;
    return v;
}

/* ------------------------------------------------------------------ */
/* OBSERVE                                                             */
/* ------------------------------------------------------------------ */

static void pa_cog_observe(PaObserveResult *out, const PaApp *app) {
    int dx, dy;
    int r = PA_COG_SCAN_RADIUS;
    unsigned int total        = 0;
    unsigned int manifest_n   = 0;
    unsigned int turbulence_n = 0;
    unsigned int crystal_n    = 0;
    uint16_t     op_counts[PA_OP_COUNT];
    int i;

    memset(out, 0, sizeof(*out));
    memset(op_counts, 0, sizeof(op_counts));

    for (dy = -r; dy <= r; ++dy) {
        for (dx = -r; dx <= r; ++dx) {
            int wx = pa_wrap_coord(app->packet_x + dx, PA_WORLD_COLS);
            int wy = pa_wrap_coord(app->packet_y + dy, PA_WORLD_ROWS);
            int mf = pa_manifest_mf_strength_impl(app, wx, wy);

            total++;

            if (app->calm[wy][wx]) {
                crystal_n++;
            } else if (mf > 0) {
                PaOperatorType op = (PaOperatorType)app->operators[wy][wx];
                manifest_n++;
                op_counts[op]++;
                if (pa_manifest_cell_is_turbulence_impl(app, wx, wy)) {
                    turbulence_n++;
                }
            }
        }
    }

    if (total > 0) {
        out->manifest_ratio  = (float)manifest_n  / (float)total;
        out->crystal_density = (float)crystal_n   / (float)total;
    }
    if (manifest_n > 0) {
        out->turbulence_pressure = (float)turbulence_n / (float)manifest_n;
    }

    {
        uint16_t best = 0;
        uint8_t  best_op = 0;
        for (i = 0; i < PA_OP_COUNT; ++i) {
            out->visible_ops[i] = op_counts[i];
            if (op_counts[i] > best) {
                best    = op_counts[i];
                best_op = (uint8_t)i;
            }
        }
        out->dominant_op = best_op;
    }
}

/* ------------------------------------------------------------------ */
/* CHOOSE — sub-helpers then composite score                          */
/* ------------------------------------------------------------------ */

/*
 * manifest_bias: how strongly manifested is this cell?
 * mf_strength is [1..3] for manifest, 0 for latent.
 */
static float pa_cog_manifest_bias(const PaApp *app, int wx, int wy) {
    int mf = pa_manifest_mf_strength_impl(app, wx, wy);
    return pa_cog_clampf((float)mf / 3.0f);
}

/*
 * move_cost: local field density as movement cost.
 */
static float pa_cog_move_cost(const PaApp *app, int wx, int wy) {
    return pa_cog_clampf((float)app->local_density[wy][wx] / 255.0f);
}

/*
 * dissolve_risk: risk of dissolution on this cell.
 * Turbulent cells are base risk; crystal proximity amplifies it.
 * Scans radius-2 around target for crystal count.
 */
static float pa_cog_dissolve_risk(const PaApp *app, int wx, int wy) {
    int nx, ny;
    int crystal_near = 0;
    int total_near   = 0;
    float cryst_ratio;
    int is_turbulent = pa_manifest_cell_is_turbulence_impl(app, wx, wy) ? 1 : 0;

    for (ny = -2; ny <= 2; ++ny) {
        for (nx = -2; nx <= 2; ++nx) {
            int sx = pa_wrap_coord(wx + nx, PA_WORLD_COLS);
            int sy = pa_wrap_coord(wy + ny, PA_WORLD_ROWS);
            total_near++;
            if (app->calm[sy][sx]) {
                crystal_near++;
            }
        }
    }

    cryst_ratio = (total_near > 0)
        ? (float)crystal_near / (float)total_near
        : 0.0f;

    return pa_cog_clampf(is_turbulent
        ? (0.5f + cryst_ratio * 0.5f)
        : (cryst_ratio * 0.3f));
}

/*
 * pa_cog_dir_score: composite score for a direction.
 *
 *   score = manifest_bias * W_MANIFEST
 *         - move_cost     * W_COST
 *         - dissolve_risk * W_RISK
 *
 * Weights are first-pass constants. Promote to PaCogConfig when tuning.
 *
 * Returns -1.0 for non-passable directions.
 */
#define PA_COG_W_MANIFEST 0.4f
#define PA_COG_W_COST     0.35f
#define PA_COG_W_RISK     0.25f

static float pa_cog_dir_score(float manifest_bias, float move_cost, float dissolve_risk) {
    return pa_cog_clampf(
          manifest_bias * PA_COG_W_MANIFEST
        - move_cost     * PA_COG_W_COST
        - dissolve_risk * PA_COG_W_RISK
    );
}

/*
 * Fill one direction entry.
 * target = torus-wrapped move destination.
 */
static void pa_cog_fill_dir(PaChoiceDir *d, const PaApp *app, int tdx, int tdy) {
    /* torus-wrap the target — never treat edge as blocked */
    int tx = pa_wrap_coord(app->packet_x + tdx, PA_WORLD_COLS);
    int ty = pa_wrap_coord(app->packet_y + tdy, PA_WORLD_ROWS);

    memset(d, 0, sizeof(*d));

    if (app->tiles[ty][tx] == PA_TILE_WALL) {
        d->passable = 0;
        d->score    = -1.0f;
        return;
    }
    if (pa_manifest_mf_strength_impl(app, tx, ty) == 0) {
        d->passable = 0;
        d->score    = -1.0f;
        return;
    }

    d->passable      = 1;
    d->manifest_bias = pa_cog_manifest_bias(app, tx, ty);
    d->move_cost     = pa_cog_move_cost(app, tx, ty);
    d->dissolve_risk = pa_cog_dissolve_risk(app, tx, ty);
    d->score         = pa_cog_dir_score(d->manifest_bias, d->move_cost, d->dissolve_risk);
}

static void pa_cog_choose(PaChooseResult *out, const PaApp *app) {
    int i;
    float best = -2.0f;

    memset(out, 0, sizeof(*out));
    out->best_dir = -1;

    pa_cog_fill_dir(&out->dirs[PA_COG_DIR_UP],    app,  0, -1);
    pa_cog_fill_dir(&out->dirs[PA_COG_DIR_DOWN],  app,  0,  1);
    pa_cog_fill_dir(&out->dirs[PA_COG_DIR_LEFT],  app, -1,  0);
    pa_cog_fill_dir(&out->dirs[PA_COG_DIR_RIGHT], app,  1,  0);

    for (i = 0; i < 4; ++i) {
        if (out->dirs[i].passable && out->dirs[i].score > best) {
            best          = out->dirs[i].score;
            out->best_dir = (int8_t)i;
        }
    }
}

/* ------------------------------------------------------------------ */
/* DISSOLVE                                                            */
/* ------------------------------------------------------------------ */

static void pa_cog_dissolve(PaDissolveResult *out, const PaApp *app) {
    int px = app->packet_x;
    int py = app->packet_y;
    PaOperatorType packet_op = (PaOperatorType)app->operators[py][px];
    int r = PA_COG_SCAN_RADIUS;
    int dx, dy;
    int nx, ny;
    unsigned int total_manifest  = 0;
    unsigned int incompatible_n  = 0;
    uint16_t     crystal_n       = 0;

    memset(out, 0, sizeof(*out));

    out->local_pressure = pa_cog_clampf(
        (float)app->local_density[py][px] / 255.0f
    );

    /* Immediate adjacency wall check */
    for (dy = -1; dy <= 1; ++dy) {
        for (dx = -1; dx <= 1; ++dx) {
            if (dx == 0 && dy == 0) continue;
            {
                int wx = pa_wrap_coord(px + dx, PA_WORLD_COLS);
                int wy = pa_wrap_coord(py + dy, PA_WORLD_ROWS);
                if (app->tiles[wy][wx] == PA_TILE_WALL) {
                    out->near_wall = 1;
                }
            }
        }
    }

    /* Full scan for crystal count and collapse_risk */
    for (dy = -r; dy <= r; ++dy) {
        for (dx = -r; dx <= r; ++dx) {
            int wx = pa_wrap_coord(px + dx, PA_WORLD_COLS);
            int wy = pa_wrap_coord(py + dy, PA_WORLD_ROWS);

            if (app->calm[wy][wx]) {
                crystal_n++;
                continue;
            }
            if (app->tiles[wy][wx] == PA_TILE_WALL) {
                continue;
            }
            if (pa_manifest_mf_strength_impl(app, wx, wy) > 0) {
                PaOperatorType near_op = (PaOperatorType)app->operators[wy][wx];
                total_manifest++;
                if (!pa_operator_allowed(packet_op, near_op) && near_op != packet_op) {
                    incompatible_n++;
                }
            }
        }
    }

    out->crystal_count = crystal_n;
    out->collapse_risk = (total_manifest > 0)
        ? pa_cog_clampf((float)incompatible_n / (float)total_manifest)
        : 0.0f;
}

/* ------------------------------------------------------------------ */
/* Public API                                                          */
/* ------------------------------------------------------------------ */

void pa_cog_init(PaCogState *cog) {
    memset(cog, 0, sizeof(*cog));
}

void pa_cog_update(PaCogState *cog, const PaApp *app) {
    pa_cog_observe (&cog->observe,  app);
    pa_cog_choose  (&cog->choose,   app);
    pa_cog_dissolve(&cog->dissolve, app);
    cog->frame = app->frame;
}
