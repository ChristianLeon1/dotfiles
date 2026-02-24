/* Taken from https://github.com/djpohly/dwl/issues/466 */
#define COLOR(hex)    { ((hex >> 24) & 0xFF) / 255.0f, \
                        ((hex >> 16) & 0xFF) / 255.0f, \
                        ((hex >> 8) & 0xFF) / 255.0f, \
                        (hex & 0xFF) / 255.0f }

static const float rootcolor[]             = COLOR(0x0a1017ff);
static uint32_t colors[][3]                = {
	/*               fg          bg          border    */
	[SchemeNorm] = { 0xc1c3c5ff, 0x0a1017ff, 0x59626dff },
	[SchemeSel]  = { 0xc1c3c5ff, 0x44718Aff, 0x6D6B6Dff },
	[SchemeUrg]  = { 0xc1c3c5ff, 0x6D6B6Dff, 0x44718Aff },
};
