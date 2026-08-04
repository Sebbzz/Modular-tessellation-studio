class GridSystem {
  Shape[] formasModulo;
  
  final int NUM_MODULES = Config.CENTER_QUADRANTS + Config.RING_COUNT * Config.SECTOR_COUNT + Config.SECTOR_COUNT;
  final float CANVAS_CENTER = Config.CANVAS_SIZE / 2.0f;
  final float OUTER_RADIUS = Config.CANVAS_SIZE * 0.48f;
  final float INNER_RADIUS = OUTER_RADIUS * 0.08f;
  final float RING_THICKNESS = (OUTER_RADIUS - INNER_RADIUS) / Config.RING_COUNT;

  GridSystem() {
    construirModulos();
  }

  void construirModulos() {
    formasModulo = new Shape[NUM_MODULES];
    Area cA = new Area(new Rectangle2D.Float(0, 0, Config.CANVAS_SIZE, Config.CANVAS_SIZE));
    
    for (int c = 0; c < Config.CENTER_QUADRANTS; c++) {
      guardarModulo(c, crearCuadranteCentral(c), cA);
    }
    
    for (int a = 0; a < Config.RING_COUNT; a++) {
      float rI = INNER_RADIUS + a * RING_THICKNESS;
      float rE = INNER_RADIUS + (a + 1) * RING_THICKNESS;
      for (int s = 0; s < Config.SECTOR_COUNT; s++) {
        guardarModulo(Config.INNER_MODULE_START + a * Config.SECTOR_COUNT + s, new Area(crearSector(rI, rE, s)), cA);
      }
    }
    
    for (int s = 0; s < Config.SECTOR_COUNT; s++) {
      guardarModulo(Config.OUTER_MODULE_START + s, new Area(crearSector(OUTER_RADIUS, Config.CANVAS_SIZE * 1.35f, s)), cA);
    }
  }

  void guardarModulo(int i, Area f, Area cA) { 
    f.intersect(cA); 
    formasModulo[i] = f; 
  }
  
  Area crearCuadranteCentral(int c) {
    Area f = new Area(new Ellipse2D.Float(CANVAS_CENTER - INNER_RADIUS, CANVAS_CENTER - INNER_RADIUS, INNER_RADIUS * 2, INNER_RADIUS * 2));
    float x = signoXCuadrante(c) < 0 ? CANVAS_CENTER - INNER_RADIUS : CANVAS_CENTER;
    float y = signoYCuadrante(c) < 0 ? CANVAS_CENTER - INNER_RADIUS : CANVAS_CENTER;
    f.intersect(new Area(new Rectangle2D.Float(x, y, INNER_RADIUS, INNER_RADIUS)));
    return f;
  }
  
  Shape crearSector(float rI, float rE, int s) {
    float aI = s * TWO_PI / Config.SECTOR_COUNT;
    float aF = (s + 1) * TWO_PI / Config.SECTOR_COUNT;
    int p = 24; 
    Path2D.Float sP = new Path2D.Float();
    sP.moveTo(CANVAS_CENTER + cos(aI) * rE, CANVAS_CENTER + sin(aI) * rE);
    for (int i = 1; i <= p; i++) { 
      float a = lerp(aI, aF, (float)i / p); 
      sP.lineTo(CANVAS_CENTER + cos(a) * rE, CANVAS_CENTER + sin(a) * rE); 
    }
    for (int i = p; i >= 0; i--) { 
      float a = lerp(aI, aF, (float)i / p); 
      sP.lineTo(CANVAS_CENTER + cos(a) * rI, CANVAS_CENTER + sin(a) * rI); 
    }
    sP.closePath(); 
    return sP;
  }

  int calcularModulo(float x, float y) {
    if (!enCanvasLocal(x, y)) return -1;
    float dx = x - CANVAS_CENTER; 
    float dy = y - CANVAS_CENTER; 
    float r = sqrt(dx * dx + dy * dy);
    
    if (r <= INNER_RADIUS) return calcularCuadranteCentral(x, y);
    
    float a = atan2(dy, dx); 
    if (a < 0) a += TWO_PI;
    
    int s = floor(a / (TWO_PI / Config.SECTOR_COUNT)); 
    if (s >= Config.SECTOR_COUNT) s = Config.SECTOR_COUNT - 1;
    
    if (r <= OUTER_RADIUS) { 
      int aN = floor((r - INNER_RADIUS) / RING_THICKNESS); 
      aN = constrain(aN, 0, Config.RING_COUNT - 1); 
      return Config.INNER_MODULE_START + aN * Config.SECTOR_COUNT + s; 
    }
    return Config.OUTER_MODULE_START + s;
  }

  int calcularCuadranteCentral(float x, float y) {
    boolean d = x >= CANVAS_CENTER; 
    boolean a = y >= CANVAS_CENTER;
    if (!a && d) return 1; 
    else if (a && !d) return 2; 
    else if (a && d) return 3; 
    return 0;
  }

  boolean enCanvasLocal(float x, float y) { 
    return x >= 0 && x < Config.CANVAS_SIZE && y >= 0 && y < Config.CANVAS_SIZE; 
  }
  
  boolean enCanvasPantalla(float x, float y) { 
    return x >= Config.LEFT_BAR_W && x < Config.LEFT_BAR_W + Config.CANVAS_SIZE && y >= 0 && y < Config.CANVAS_SIZE; 
  }

  int capaModulo(int m) { 
    if (m < Config.CENTER_QUADRANTS) return 0;
    if (m < Config.OUTER_MODULE_START) return 1 + (m - Config.INNER_MODULE_START) / Config.SECTOR_COUNT; 
    return Config.RING_COUNT + 1;
  }

  int sectorModulo(int m) { 
    if (m < Config.CENTER_QUADRANTS) return m; 
    if (m < Config.OUTER_MODULE_START) return (m - Config.INNER_MODULE_START) % Config.SECTOR_COUNT;
    return m - Config.OUTER_MODULE_START; 
  }

  boolean moduloValido(int m) { 
    return m >= 0 && m < NUM_MODULES && formasModulo[m] != null;
  }

  Shape getForma(int m) { return formasModulo[m]; }
  int signoXCuadrante(int c) { return c == 1 || c == 3 ? 1 : -1; }
  int signoYCuadrante(int c) { return c >= 2 ? 1 : -1; }
  float radioHastaBordeCanvas(float angulo) {
    float dominante = max(abs(cos(angulo)), abs(sin(angulo)));
    if (dominante < 0.0001f) return CANVAS_CENTER;
    return CANVAS_CENTER / dominante;
  }
}
