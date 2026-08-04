class TimelineEngine {
  SymmetryEngine engine; // Referencia global para leer todas las capas

  boolean isPlaying = false;
  float globalTime = 0.0f; 
  float speed = 0.02f;     
  
  int mode = Config.MODE_PING_PONG;
  int direction = 1;       

  // El constructor ahora recibe el motor completo
  TimelineEngine(SymmetryEngine engineVinculado) {
    this.engine = engineVinculado;
  }

  void update() {
    if (!isPlaying) return;

    // Encontrar la capa con más fotogramas para definir el límite del tiempo global
    int maxEstadosGlobal = 1;
    for (AnimLayer capa : engine.capas) {
      if (capa.getNumEstados() > maxEstadosGlobal) {
        maxEstadosGlobal = capa.getNumEstados();
      }
    }

    if (maxEstadosGlobal < 2) return;

    globalTime += speed * direction;
    float maxTime = maxEstadosGlobal - 1;

    // Lógica de Modos de Reproducción
    switch (mode) {
      case Config.MODE_ONCE:
        if (globalTime >= maxTime) {
          globalTime = maxTime;
          isPlaying = false;
        }
        break;
        
      case Config.MODE_LOOP:
        if (globalTime >= maxTime) {
          globalTime = 0; 
        }
        break;
        
      case Config.MODE_PING_PONG:
        if (globalTime >= maxTime) {
          globalTime = maxTime;
          direction = -1; 
        } else if (globalTime <= 0) {
          globalTime = 0;
          direction = 1;  
        }
        break;
    }
  }

  // --- INTERPOLACIÓN MULTICAPA ---
  AnimState getFrameInterpoladoAt(float exactTime, AnimLayer capa) {
    if (capa.getNumEstados() <= 1) return capa.getEstadoActual();

    int maxCapaTime = capa.getNumEstados() - 1;
    // Evita que una capa con menos frames se desborde si otra capa es más larga
    float localTime = min(exactTime, maxCapaTime); 

    int frameA = floor(localTime);
    int frameB = frameA + 1;
    if (frameB > maxCapaTime) frameB = maxCapaTime;

    float localT = localTime - frameA;
    float easedT = easeInOutCubic(localT);

    return capa.estados.get(frameA).interpolar(capa.estados.get(frameB), easedT);
  }

  float easeInOutCubic(float x) {
    return x < 0.5f ? 4 * x * x * x : 1 - pow(-2 * x + 2, 3) / 2;
  }

  void togglePlay() { 
    isPlaying = !isPlaying; 
  }
  
  void setMode(int m) { 
    mode = m;
    if (mode != Config.MODE_PING_PONG) direction = 1;
  }

  void rebobinar() {
    globalTime = 0;
    direction = 1;
  }

  void sincronizarConEstadoActivo() {
    globalTime = engine.getEstadoActualIndex();
    direction = 1;
  }
}
