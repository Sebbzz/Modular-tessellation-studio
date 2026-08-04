static class Config {
  static final int CANVAS_SIZE = 810;
  static final int ANIM_CANVAS_SIZE = 810;

  static final int LEFT_BAR_W = 0;
  static final int CENTER_BAR_W = 100;
  static final int RIGHT_BAR_W = 0;
  static final int BOTTOM_BAR_H = 118;

  static final color UI_BG = #07080A;
  static final color UI_BG_DEEP = #030405;
  static final color SURFACE = #111318;
  static final color SURFACE_SOFT = #181B20;
  static final color SURFACE_ACTIVE = #24272E;
  static final color STROKE_SOFT = #2B3038;
  static final color TEXT_MAIN = #F6F7F4;
  static final color TEXT_MUTED = #A0A6AD;
  static final color TEXT_DIM = #5E646D;
  static final color ACCENT_COLOR = #FFFFFF;
  static final color ACCENT_PLAY = #2DC653;
  static final color ACCENT_WARN = #FF6961;

  static final int MODE_ONCE = 0;
  static final int MODE_LOOP = 1;
  static final int MODE_PING_PONG = 2;

  static final int MAX_HISTORY = 50;
  static final int CENTER_QUADRANTS = 4;
  static final int SECTOR_COUNT = 8;
  static final int RING_COUNT = 8;
  static final int INNER_MODULE_START = CENTER_QUADRANTS;
  static final int OUTER_MODULE_START = INNER_MODULE_START + RING_COUNT * SECTOR_COUNT;
}
