static const char norm_fg[] = "#c1c3c5";
static const char norm_bg[] = "#0a1017";
static const char norm_border[] = "#59626d";

static const char sel_fg[] = "#c1c3c5";
static const char sel_bg[] = "#6D6B6D";
static const char sel_border[] = "#c1c3c5";

static const char *colors[][3]      = {
    /*               fg           bg         border                         */
    [SchemeNorm] = { norm_fg,     norm_bg,   norm_border }, // unfocused wins
    [SchemeSel]  = { sel_fg,      sel_bg,    sel_border },  // the focused win
};
