class GifExporter {
  PApplet parent;
  SymmetryEngine engine;
  TimelineEngine timeline;
  AppState state;

  GifExporter(PApplet parent, SymmetryEngine engine, TimelineEngine timeline, AppState state) {
    this.parent = parent;
    this.engine = engine;
    this.timeline = timeline;
    this.state = state;
  }

  void exportarGif() {
    // 1. Determinar el tiempo máximo evaluando TODAS las capas
    int maxEstadosGlobal = 1;
    for (AnimLayer capa : engine.capas) {
      if (capa.getNumEstados() > maxEstadosGlobal) {
        maxEstadosGlobal = capa.getNumEstados();
      }
    }

    if (maxEstadosGlobal < 2) {
      println("Error: Necesitas al menos 2 estados (fotogramas clave) en alguna capa para exportar una animación.");
      return;
    }

    println("Calculando y renderizando GIF Multicapa... Por favor espera.");
    
    // Configuración del archivo GIF
    String nombre = "CanvasStudio-Anim-" + year() + nf(month(), 2) + nf(day(), 2) + "-" + nf(hour(), 2) + nf(minute(), 2) + nf(second(), 2) + ".gif";
    GifMaker gifExport = new GifMaker(parent, nombre);
    gifExport.setRepeat(0); // Bucle infinito
    gifExport.setDelay(1000 / 60); // Asumiendo 60 FPS

    float maxTime = maxEstadosGlobal - 1;
    float framesPerTransition = 1.0f / timeline.speed;

    // Calcular el total de fotogramas para un ciclo exacto y cerrado
    int totalFrames = (timeline.mode == Config.MODE_PING_PONG) ? 
                      round(maxTime * framesPerTransition * 2) : 
                      round(maxTime * framesPerTransition);

    // Lienzo temporal para renderizar (aislado de la UI)
    PGraphics frameCanvas = parent.createGraphics(Config.ANIM_CANVAS_SIZE, Config.CANVAS_SIZE, JAVA2D);
    PGraphics oldCanvas = engine.canvas; // Guardamos el objetivo original del motor

    // Bucle de horneado (Baking)
    for (int i = 0; i <= totalFrames; i++) {
      float virtualTime = 0;

      // Calcular la posición del tiempo exacto según el modo
      if (timeline.mode == Config.MODE_PING_PONG) {
        float halfFrames = maxTime * framesPerTransition;
        if (i <= halfFrames) {
          virtualTime = map(i, 0, halfFrames, 0, maxTime); 
        } else {
          virtualTime = map(i, halfFrames, totalFrames, maxTime, 0); 
        }
      } else {
        virtualTime = map(i, 0, totalFrames, 0, maxTime); 
      }

      // Renderizar sobre el lienzo temporal
      frameCanvas.beginDraw();
      frameCanvas.background(state.colorFondo);
      engine.canvas = frameCanvas; // Redirigir la brocha del motor

      // 2. Renderizar la interpolación de CADA capa visible de fondo a frente
      for (AnimLayer capa : engine.capas) {
        if (!capa.visible) continue;
        
        AnimState estadoFrame = timeline.getFrameInterpoladoAt(virtualTime, capa);
        for (VectorStroke trazo : estadoFrame.getTrazos()) {
          engine.dibujarVectorStroke(trazo);
        }
      }

      frameCanvas.endDraw();
      gifExport.addFrame(frameCanvas.get()); // Enviar el lienzo quemado al GIF

      // Feedback en consola
      if (i % 30 == 0 || i == totalFrames) {
        println("Renderizando frame " + i + " de " + totalFrames + " (" + int((i/(float)totalFrames)*100) + "%)");
      }
    }

    gifExport.finish();
    engine.canvas = oldCanvas; // Devolver el lienzo original al motor
    println("¡GIF Animado exportado con éxito! -> " + nombre);
  }
}
