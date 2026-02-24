const char *colorname[] = {

  /* 8 normal colors */
  [0] = "#0a1017", /* black   */
  [1] = "#6D6B6D", /* red     */
  [2] = "#44718A", /* green   */
  [3] = "#837E83", /* yellow  */
  [4] = "#4C9CBE", /* blue    */
  [5] = "#959396", /* magenta */
  [6] = "#9EA5AE", /* cyan    */
  [7] = "#c1c3c5", /* white   */

  /* 8 bright colors */
  [8]  = "#59626d",  /* black   */
  [9]  = "#6D6B6D",  /* red     */
  [10] = "#44718A", /* green   */
  [11] = "#837E83", /* yellow  */
  [12] = "#4C9CBE", /* blue    */
  [13] = "#959396", /* magenta */
  [14] = "#9EA5AE", /* cyan    */
  [15] = "#c1c3c5", /* white   */

  /* special colors */
  [256] = "#0a1017", /* background */
  [257] = "#c1c3c5", /* foreground */
  [258] = "#c1c3c5",     /* cursor */
};

/* Default colors (colorname index)
 * foreground, background, cursor */
 unsigned int defaultbg = 0;
 unsigned int defaultfg = 257;
 unsigned int defaultcs = 258;
 unsigned int defaultrcs= 258;
