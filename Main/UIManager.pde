class UIManager {
  AppState state;
  SymmetryEngine engine;
  HistoryManager history;
  TimelineEngine timeline;

  HashMap<String, Float> animStates = new HashMap<String, Float>();
  float clickRingRadius = 0;
  float clickRingAlpha = 0;
  float drawFeedbackAnim = 0;
  boolean ajustandoGrosor = false;
  boolean editandoColorFondo = false;
  boolean mostrarPanelCapas = false;

  final int BUTTON_H = 40;
  final int ICON_BTN = 40;
  final int PANEL_R = 8;
  final int LOCK_W = 60;

  final int CENTER_X = Config.LEFT_BAR_W + Config.CANVAS_SIZE + (Config.CENTER_BAR_W - LOCK_W) / 2;
  final int TOOLBAR_W = 76;
  final int TOOLBAR_H = 740;
  final int CENTER_Y = (Config.CANVAS_SIZE - TOOLBAR_H) / 2;
  final int BRUSH_SWATCH_Y = CENTER_Y + 44;
  final int BG_SWATCH_Y = CENTER_Y + 78;
  final int PALETTE_Y = CENTER_Y + 128;
  final int LOCK_Y = CENTER_Y + 328;
  final int SIZE_SLIDER_Y = CENTER_Y + 404;
  final int SIZE_SLIDER_H = 76;
  final int ZOOM_OUT_Y = CENTER_Y + 548;
  final int ZOOM_IN_Y = CENTER_Y + 596;
  final int GRID_Y = CENTER_Y + 656;
  final int DOCK_Y = Config.CANVAS_SIZE + 14;
  final int DOCK_H = 84;
  final int CTRL_X = Config.LEFT_BAR_W + 18;
  final int EXPORT_W = 112;
  final int DOCK_LABEL_Y = DOCK_Y + 12;
  final int DOCK_CONTROL_Y = DOCK_Y + 34;

  UIManager(AppState state, SymmetryEngine engine, HistoryManager history, TimelineEngine timeline) {
    this.state = state;
    this.engine = engine;
    this.history = history;
    this.timeline = timeline;
  }

  void dibujarPaneles() {
    dibujarMarcosCanvas();
    dibujarBarraHerramientas();
    dibujarDockInferior();
  }

  void dibujarMarcosCanvas() {
    pushStyle();
    dibujarMarcoCanvas(Config.LEFT_BAR_W, 0, Config.CANVAS_SIZE, Config.CANVAS_SIZE);
    dibujarMarcoCanvas(Config.LEFT_BAR_W + Config.CANVAS_SIZE + Config.CENTER_BAR_W, 0, Config.ANIM_CANVAS_SIZE, Config.CANVAS_SIZE);
    popStyle();
  }

  void dibujarMarcoCanvas(int x, int y, int w, int h) {
    noFill();
    stroke(255, 20);
    strokeWeight(1);
    rect(x + 0.5f, y + 0.5f, w - 1, h - 1);
  }

  void dibujarBarraHerramientas() {
    dibujarPanelVidrio(CENTER_X - 8, CENTER_Y, TOOLBAR_W, TOOLBAR_H, PANEL_R);
    dibujarSeccionVertical("COLOR", CENTER_X, CENTER_Y + 24);
    dibujarSelectorDestinoColor(CENTER_X, BRUSH_SWATCH_Y, LOCK_W, 26, false, "PINCEL", "target_brush");
    dibujarSelectorDestinoColor(CENTER_X, BG_SWATCH_Y, LOCK_W, 26, true, "FONDO", "target_bg");
    dibujarPaletaColor(CENTER_X, PALETTE_Y);

    dibujarSeparadorVertical(CENTER_X + LOCK_W / 2, CENTER_Y + 302);
    dibujarSeccionVertical("TRAZO", CENTER_X, CENTER_Y + 314);
    dibujarBotonCandado(CENTER_X, LOCK_Y, LOCK_W, BUTTON_H, "btn_lock");
    dibujarSliderGrosor(CENTER_X, SIZE_SLIDER_Y, LOCK_W, SIZE_SLIDER_H);

    dibujarSeparadorVertical(CENTER_X + LOCK_W / 2, CENTER_Y + 522);
    dibujarSeccionVertical("VISTA", CENTER_X, CENTER_Y + 534);
    dibujarBotonIcono(CENTER_X, ZOOM_OUT_Y, LOCK_W, BUTTON_H, "zoom_out", false, "btn_zoom_out");
    dibujarBotonIcono(CENTER_X, ZOOM_IN_Y, LOCK_W, BUTTON_H, "zoom_in", false, "btn_zoom_in");
    dibujarBotonIcono(CENTER_X, GRID_Y, LOCK_W, BUTTON_H, "grid", state.mostrarReticula, "btn_grid");
    dibujarZoomLabel(CENTER_X + LOCK_W / 2, GRID_Y + BUTTON_H + 15);
  }

  void dibujarDockInferior() {
    dibujarPanelVidrio(Config.LEFT_BAR_W + 12, DOCK_Y - 6, Config.CANVAS_SIZE * 2 + Config.CENTER_BAR_W - 24, DOCK_H + 12, PANEL_R);

    int x = CTRL_X;
    dibujarGrupoLabel(x, DOCK_LABEL_Y, "REPRODUCCION");
    dibujarBotonIcono(x, DOCK_CONTROL_Y, 60, BUTTON_H, timeline.isPlaying ? "pause" : "play", timeline.isPlaying, "btn_play"); x += 68;
    dibujarBotonIcono(x, DOCK_CONTROL_Y, 38, BUTTON_H, "prev", false, "btn_prev_state"); x += 44;
    dibujarBotonIcono(x, DOCK_CONTROL_Y, 38, BUTTON_H, "next", false, "btn_next_state"); x += 54;

    dibujarGrupoLabel(x, DOCK_LABEL_Y, "ESTADOS");
    dibujarBotonTexto(x, DOCK_CONTROL_Y, 84, BUTTON_H, "NUEVO", "plus", false, "btn_new_state"); x += 98;

    dibujarGrupoLabel(x, DOCK_LABEL_Y, "CAPAS");
    dibujarBotonTexto(x, DOCK_CONTROL_Y, 70, BUTTON_H, "ABAJO", "layer_down", false, "btn_layer_down"); x += 78;
    dibujarBotonTexto(x, DOCK_CONTROL_Y, 74, BUTTON_H, "ARRIBA", "layer_up", false, "btn_layer_up"); x += 86;
    dibujarBotonTexto(x, DOCK_CONTROL_Y, 78, BUTTON_H, "GESTION", "layers", mostrarPanelCapas, "btn_layers_panel"); x += 90;

    dibujarGrupoLabel(x, DOCK_LABEL_Y, "VISTA");
    dibujarBotonTexto(x, DOCK_CONTROL_Y, 82, BUTTON_H, "CEBOLLA", "onion", state.mostrarPapelCebolla, "btn_onion"); x += 92;
    dibujarBotonTexto(x, DOCK_CONTROL_Y, 96, BUTTON_H, getModoString(timeline.mode), "mode", false, "btn_mode"); x += 110;

    dibujarGrupoLabel(x, DOCK_LABEL_Y, "EDICION");
    dibujarBotonIcono(x, DOCK_CONTROL_Y, 56, BUTTON_H, "undo", false, "btn_undo"); x += 62;
    dibujarBotonIcono(x, DOCK_CONTROL_Y, 56, BUTTON_H, "redo", false, "btn_redo"); x += 62;
    dibujarBotonIcono(x, DOCK_CONTROL_Y, 72, BUTTON_H, "trash", false, "btn_clear"); x += 82;

    int timelineX = Config.LEFT_BAR_W + Config.CANVAS_SIZE + Config.CENTER_BAR_W + 62;
    int timelineW = Config.ANIM_CANVAS_SIZE - 62 - EXPORT_W - 28;
    int exportX = timelineX + timelineW + 18;
    dibujarGrupoLabel(timelineX, DOCK_LABEL_Y, "LINEA DE TIEMPO");
    dibujarIndicadores(timelineX, DOCK_Y + 30);
    dibujarScrubber(timelineX, DOCK_Y + 66, timelineW);
    dibujarGrupoLabel(exportX, DOCK_LABEL_Y, "SALIDA");
    dibujarBotonTexto(exportX, DOCK_CONTROL_Y, EXPORT_W, BUTTON_H, "Exportar", "export", false, "btn_export");
    if (mostrarPanelCapas) dibujarPanelCapas();
  }

  void dibujarIndicadores(int x, int y) {
    pushStyle();
    fill(Config.TEXT_MUTED);
    textAlign(LEFT, CENTER);
    textSize(11);
    text("ESTADO " + (engine.getEstadoActualIndex() + 1) + "/" + engine.getTotalEstados() +
         "    CAPA " + (engine.indiceCapaActiva + 1) + "/" + engine.capas.size(), x, y);
    popStyle();
  }

  void dibujarScrubber(int x, int y, int w) {
    pushStyle();
    stroke(Config.STROKE_SOFT, 150);
    strokeWeight(3);
    strokeCap(ROUND);
    line(x, y, x + w, y);

    int totalEstados = engine.getCapaActiva().getNumEstados();
    fill(Config.TEXT_DIM);
    noStroke();
    for (int i = 0; i < totalEstados; i++) {
      float kx = x + (totalEstados > 1 ? map(i, 0, totalEstados - 1, 0, w) : 0);
      boolean actual = i == engine.getEstadoActualIndex();
      fill(actual ? Config.TEXT_MAIN : Config.TEXT_DIM);
      ellipse(kx, y, actual ? 8 : 5, actual ? 8 : 5);
    }

    if (totalEstados > 1) {
      float tMax = max(1, totalEstados - 1);
      float cabezalX = x + map(constrain(timeline.globalTime, 0, tMax), 0, tMax, 0, w);
      fill(timeline.isPlaying ? Config.ACCENT_PLAY : Config.TEXT_MAIN);
      ellipse(cabezalX, y, 12, 12);
      noFill();
      stroke(255, 34);
      strokeWeight(1);
      ellipse(cabezalX, y, 18, 18);
    }
    popStyle();
  }

  String getModoString(int modo) {
    if (modo == Config.MODE_ONCE) return "ONCE";
    if (modo == Config.MODE_LOOP) return "LOOP";
    return "PINGPONG";
  }

  void dibujarZoomLabel(int x, int y) {
    pushStyle();
    fill(Config.TEXT_MUTED);
    textAlign(CENTER, CENTER);
    textSize(10);
    text(nf(state.zoomLienzo, 1, 2) + "x", x, y);
    popStyle();
  }

  void revisarClics(float mx, float my) {
    if (sobreSliderGrosor(mx, my)) { iniciarAjusteGrosor(my); return; }
    int colorIndex = indiceColorPaleta(mx, my);
    if (colorIndex >= 0) { aplicarColorPaleta(colorIndex); return; }
    if (sobreBoton(CENTER_X, BG_SWATCH_Y, LOCK_W, 26)) { editandoColorFondo = true; return; }
    else if (sobreBoton(CENTER_X, BRUSH_SWATCH_Y, LOCK_W, 26)) { editandoColorFondo = false; return; }
    else if (sobreBoton(CENTER_X, LOCK_Y, LOCK_W, BUTTON_H + 20)) state.toggleBloqueo();
    else if (sobreBoton(CENTER_X, ZOOM_OUT_Y, LOCK_W, BUTTON_H)) state.alejarZoom();
    else if (sobreBoton(CENTER_X, ZOOM_IN_Y, LOCK_W, BUTTON_H)) state.acercarZoom();
    else if (sobreBoton(CENTER_X, GRID_Y, LOCK_W, BUTTON_H)) state.toggleReticula();

    int x = CTRL_X;
    if (sobreBoton(x, DOCK_CONTROL_Y, 60, BUTTON_H)) timeline.togglePlay(); x += 68;
    if (sobreBoton(x, DOCK_CONTROL_Y, 38, BUTTON_H)) { engine.anteriorEstado(); timeline.sincronizarConEstadoActivo(); return; } x += 44;
    if (sobreBoton(x, DOCK_CONTROL_Y, 38, BUTTON_H)) { engine.siguienteEstado(); timeline.sincronizarConEstadoActivo(); return; } x += 54;
    if (sobreBoton(x, DOCK_CONTROL_Y, 84, BUTTON_H)) { history.guardarEstado(); engine.nuevoEstado(); timeline.sincronizarConEstadoActivo(); return; } x += 98;
    if (sobreBoton(x, DOCK_CONTROL_Y, 70, BUTTON_H)) { engine.bajarCapa(); timeline.sincronizarConEstadoActivo(); return; } x += 78;
    if (sobreBoton(x, DOCK_CONTROL_Y, 74, BUTTON_H)) {
      if (engine.indiceCapaActiva < engine.capas.size() - 1) engine.subirCapa();
      else { history.guardarEstado(); engine.nuevaCapa(); }
      timeline.sincronizarConEstadoActivo();
      return;
    } x += 86;
    if (sobreBoton(x, DOCK_CONTROL_Y, 78, BUTTON_H)) { mostrarPanelCapas = !mostrarPanelCapas; return; } x += 90;
    if (sobreBoton(x, DOCK_CONTROL_Y, 82, BUTTON_H)) { state.togglePapelCebolla(); return; } x += 92;
    if (sobreBoton(x, DOCK_CONTROL_Y, 96, BUTTON_H)) { timeline.setMode((timeline.mode + 1) % 3); return; } x += 110;
    if (sobreBoton(x, DOCK_CONTROL_Y, 56, BUTTON_H)) { history.deshacer(); timeline.sincronizarConEstadoActivo(); return; } x += 62;
    if (sobreBoton(x, DOCK_CONTROL_Y, 56, BUTTON_H)) { history.rehacer(); timeline.sincronizarConEstadoActivo(); return; } x += 62;
    if (sobreBoton(x, DOCK_CONTROL_Y, 72, BUTTON_H)) { history.guardarEstado(); engine.limpiarCanvas(); return; } x += 82;

    int timelineX = Config.LEFT_BAR_W + Config.CANVAS_SIZE + Config.CENTER_BAR_W + 62;
    int timelineW = Config.ANIM_CANVAS_SIZE - 62 - EXPORT_W - 28;
    int exportX = timelineX + timelineW + 18;
    if (sobreBoton(exportX, DOCK_CONTROL_Y, EXPORT_W, BUTTON_H)) gifExporter.exportarGif();
    if (mostrarPanelCapas && revisarClicsPanelCapas(mx, my)) return;
  }

  boolean arrastrarControles(float mx, float my) {
    if (!ajustandoGrosor) return false;
    actualizarGrosorDesdeSlider(my);
    return true;
  }

  void soltarControles() {
    ajustandoGrosor = false;
  }

  void dibujarPuntero(float mx, float my, boolean estaDibujando) {
    pushStyle();
    if (clickRingAlpha > 0.5f) {
      noFill();
      stroke(state.colorPincel, clickRingAlpha);
      strokeWeight(1.5f);
      ellipse(mx, my, clickRingRadius, clickRingRadius);
      clickRingRadius += 2.5f;
      clickRingAlpha = lerp(clickRingAlpha, 0, 0.12f);
    }
    drawFeedbackAnim = lerp(drawFeedbackAnim, estaDibujando ? 1.0f : 0.0f, 0.15f);
    if (drawFeedbackAnim > 0.01f) {
      noStroke();
      fill(state.colorPincel, 15 * drawFeedbackAnim);
      ellipse(mx, my, state.grosorPincel * 2.5f, state.grosorPincel * 2.5f);
    }
    noFill();
    float speed = dist(mx, my, pmouseX, pmouseY);
    float dynamicOffset = constrain(speed * 0.2f, 0, 4);
    stroke(255, 40);
    strokeWeight(1);
    ellipse(mx, my, state.grosorPincel + 4 + dynamicOffset, state.grosorPincel + 4 + dynamicOffset);
    stroke(state.colorPincel, 220);
    strokeWeight(1.5);
    ellipse(mx, my, state.grosorPincel, state.grosorPincel);
    fill(255);
    noStroke();
    ellipse(mx, my, 2, 2);
    popStyle();
  }

  boolean sobreBoton(int x, int y, int w, int h) {
    return mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y + h;
  }

  float getAnimState(String id, boolean targetState) {
    float currentValue = animStates.containsKey(id) ? animStates.get(id) : 0f;
    float targetValue = targetState ? 1.0f : 0.0f;
    float newValue = lerp(currentValue, targetValue, 0.24f);
    animStates.put(id, newValue);
    return newValue;
  }

  void dibujarPanelVidrio(int x, int y, int w, int h, int r) {
    pushStyle();
    noStroke();
    for (int i = 8; i > 0; i--) {
      fill(0, 2.2f);
      rect(x - i, y + i * 0.6f, w + i * 2, h + i * 1.5f, r + i);
    }
    fill(18, 20, 24, 206);
    rect(x, y, w, h, r);
    fill(255, 5);
    rect(x + 1, y + 1, w - 2, 1, r);
    noFill();
    stroke(255, 18);
    strokeWeight(1);
    rect(x + 0.5f, y + 0.5f, w - 1, h - 1, r);
    popStyle();
  }

  void dibujarGrupoLabel(int x, int y, String label) {
    pushStyle();
    fill(Config.TEXT_DIM);
    textAlign(LEFT, CENTER);
    textSize(9);
    text(label, x, y);
    popStyle();
  }

  void dibujarPanelCapas() {
    int x = Config.LEFT_BAR_W + Config.CANVAS_SIZE + Config.CENTER_BAR_W + 22;
    int y = 34;
    int w = 232;
    int h = 236;
    pushStyle();
    noStroke();
    fill(18, 20, 24, 236);
    rect(x, y, w, h, 8);
    noFill();
    stroke(255, 24);
    rect(x + 0.5f, y + 0.5f, w - 1, h - 1, 8);

    fill(Config.TEXT_MAIN);
    textAlign(LEFT, CENTER);
    textSize(12);
    text("GESTION DE CAPAS", x + 14, y + 18);
    fill(Config.TEXT_MUTED);
    textSize(10);
    text("CAPA " + (engine.indiceCapaActiva + 1) + " / " + engine.capas.size(), x + 14, y + 38);

    boolean visible = engine.getCapaActiva().visible;
    dibujarBotonTexto(x + 14, y + 58, 96, 32, "SEL -", "layer_prev", false, "layer_panel_prev");
    dibujarBotonTexto(x + 118, y + 58, 96, 32, "SEL +", "layer_next", false, "layer_panel_next");
    dibujarBotonTexto(x + 14, y + 98, 96, 32, "MOVER -", "move_down", false, "layer_panel_move_down");
    dibujarBotonTexto(x + 118, y + 98, 96, 32, "MOVER +", "move_up", false, "layer_panel_move_up");
    dibujarBotonTexto(x + 14, y + 138, 96, 32, visible ? "VISIBLE" : "OCULTA", "visibility", visible, "layer_panel_visible");
    dibujarBotonTexto(x + 118, y + 138, 96, 32, "NUEVA", "new_layer", false, "layer_panel_new");
    dibujarBotonTexto(x + 14, y + 184, 200, 32, engine.capas.size() > 1 ? "BORRAR CAPA" : "LIMPIAR CAPA", "delete_layer", false, "layer_panel_delete");
    popStyle();
  }

  boolean revisarClicsPanelCapas(float mx, float my) {
    int x = Config.LEFT_BAR_W + Config.CANVAS_SIZE + Config.CENTER_BAR_W + 22;
    int y = 34;
    if (!sobrePunto(mx, my, x, y, 232, 236)) return false;

    if (sobrePunto(mx, my, x + 14, y + 58, 96, 32)) {
      engine.bajarCapa();
      timeline.sincronizarConEstadoActivo();
      return true;
    }
    if (sobrePunto(mx, my, x + 118, y + 58, 96, 32)) {
      engine.subirCapa();
      timeline.sincronizarConEstadoActivo();
      return true;
    }
    if (sobrePunto(mx, my, x + 14, y + 98, 96, 32)) {
      history.guardarEstado();
      engine.moverCapaActivaAbajo();
      timeline.sincronizarConEstadoActivo();
      return true;
    }
    if (sobrePunto(mx, my, x + 118, y + 98, 96, 32)) {
      history.guardarEstado();
      engine.moverCapaActivaArriba();
      timeline.sincronizarConEstadoActivo();
      return true;
    }
    if (sobrePunto(mx, my, x + 14, y + 138, 96, 32)) {
      history.guardarEstado();
      engine.getCapaActiva().visible = !engine.getCapaActiva().visible;
      return true;
    }
    if (sobrePunto(mx, my, x + 118, y + 138, 96, 32)) {
      history.guardarEstado();
      engine.nuevaCapa();
      timeline.sincronizarConEstadoActivo();
      return true;
    }
    if (sobrePunto(mx, my, x + 14, y + 184, 200, 32)) {
      history.guardarEstado();
      engine.eliminarCapaActiva();
      timeline.sincronizarConEstadoActivo();
      return true;
    }
    return true;
  }

  boolean sobrePunto(float mx, float my, int x, int y, int w, int h) {
    return mx >= x && mx <= x + w && my >= y && my <= y + h;
  }

  void dibujarSeccionVertical(String label, int x, int y) {
    pushStyle();
    fill(Config.TEXT_DIM);
    textAlign(CENTER, CENTER);
    textSize(9);
    text(label, x + LOCK_W / 2, y);
    popStyle();
  }

  void dibujarSeparadorVertical(int x, int y) {
    pushStyle();
    stroke(255, 12);
    strokeWeight(1);
    line(x - 17, y, x + 17, y);
    popStyle();
  }

  void dibujarSliderGrosor(int x, int y, int w, int h) {
    pushStyle();
    float cx = x + w / 2;
    float trackTop = y + 8;
    float trackBottom = y + h - 20;
    float t = map(state.grosorPincel, state.GROSOR_MIN, state.GROSOR_MAX, 1, 0);
    float knobY = lerp(trackTop, trackBottom, t);
    boolean hovered = sobreSliderGrosor(mouseX, mouseY);
    float anim = getAnimState("slider_size", hovered || ajustandoGrosor);

    stroke(255, 14 + 18 * anim);
    strokeWeight(7);
    strokeCap(ROUND);
    line(cx, trackTop, cx, trackBottom);
    stroke(Config.TEXT_MAIN, 56 + 84 * anim);
    strokeWeight(3);
    line(cx, knobY, cx, trackBottom);

    noStroke();
    fill(Config.SURFACE_ACTIVE);
    ellipse(cx, knobY, 15 + 3 * anim, 15 + 3 * anim);
    fill(state.colorPincel, 180);
    ellipse(cx, knobY, constrain(state.grosorPincel * 0.38f, 4, 13), constrain(state.grosorPincel * 0.38f, 4, 13));

    fill(lerpColor(Config.TEXT_DIM, Config.TEXT_MUTED, anim));
    textAlign(CENTER, CENTER);
    textSize(9);
    text(nf(state.grosorPincel, 1, 0), cx, y + h - 5);
    popStyle();
  }

  boolean sobreSliderGrosor(float mx, float my) {
    return mx >= CENTER_X && mx <= CENTER_X + LOCK_W && my >= SIZE_SLIDER_Y && my <= SIZE_SLIDER_Y + SIZE_SLIDER_H;
  }

  void iniciarAjusteGrosor(float my) {
    ajustandoGrosor = true;
    actualizarGrosorDesdeSlider(my);
  }

  void actualizarGrosorDesdeSlider(float my) {
    float trackTop = SIZE_SLIDER_Y + 8;
    float trackBottom = SIZE_SLIDER_Y + SIZE_SLIDER_H - 20;
    float t = constrain(map(my, trackBottom, trackTop, 0, 1), 0, 1);
    state.setGrosorPincel(lerp(state.GROSOR_MIN, state.GROSOR_MAX, t));
  }

  void dibujarBotonIcono(int x, int y, int w, int h, String icono, boolean activo, String id) {
    dibujarBotonBase(x, y, w, h, activo, id);
    float hoverAnim = getAnimState(id + "_hover", sobreBoton(x, y, w, h));
    float activeAnim = getAnimState(id + "_active", activo);
    color textColor = lerpColor(Config.TEXT_MUTED, Config.TEXT_MAIN, max(hoverAnim, activeAnim));
    dibujarTextoBoton(x, y, w, h, textoBoton(icono), textColor);
  }

  void dibujarBotonTexto(int x, int y, int w, int h, String etiqueta, String icono, boolean activo, String id) {
    dibujarBotonBase(x, y, w, h, activo, id);
    float hoverAnim = getAnimState(id + "_hover", sobreBoton(x, y, w, h));
    float activeAnim = getAnimState(id + "_active", activo);
    color textColor = lerpColor(Config.TEXT_MUTED, Config.TEXT_MAIN, max(hoverAnim, activeAnim));
    dibujarTextoBoton(x, y, w, h, etiqueta, textColor);
  }

  void dibujarTextoBoton(int x, int y, int w, int h, String etiqueta, color textColor) {
    pushStyle();
    fill(textColor);
    textAlign(CENTER, CENTER);
    textSize(etiqueta.length() > 7 ? 10 : 11);
    text(etiqueta, x + w / 2, y + h / 2 - 1);
    popStyle();
  }

  String textoBoton(String icono) {
    if (icono.equals("play")) return "PLAY";
    if (icono.equals("pause")) return "PAUSA";
    if (icono.equals("prev")) return "<";
    if (icono.equals("next")) return ">";
    if (icono.equals("zoom_out")) return "-";
    if (icono.equals("zoom_in")) return "+";
    if (icono.equals("grid")) return "GRID";
    if (icono.equals("undo")) return "UNDO";
    if (icono.equals("redo")) return "REDO";
    if (icono.equals("trash")) return "LIMPIAR";
    return icono;
  }

  void dibujarBotonBase(int x, int y, int w, int h, boolean activo, String id) {
    pushStyle();
    boolean hovered = sobreBoton(x, y, w, h);
    float hoverAnim = getAnimState(id + "_hover", hovered);
    float activeAnim = getAnimState(id + "_active", activo);
    float emphasis = max(hoverAnim, activeAnim);
    noStroke();
    fill(lerpColor(Config.SURFACE, activo ? Config.SURFACE_ACTIVE : Config.SURFACE_SOFT, emphasis));
    rect(x, y, w, h, 7);
    if (activo) {
      fill(255, 18 + 24 * activeAnim);
      rect(x + 3, y + 3, 3, h - 6, 2);
    }
    noFill();
    stroke(255, 12 + 28 * emphasis);
    strokeWeight(1);
    rect(x + 0.5f, y + 0.5f, w - 1, h - 1, 7);
    popStyle();
  }

  void dibujarSelectorDestinoColor(int x, int y, int w, int h, boolean fondo, String etiqueta, String id) {
    boolean activo = editandoColorFondo == fondo;
    dibujarBotonBase(x, y, w, h, activo, id);
    pushStyle();
    color muestra = fondo ? state.colorFondo : state.colorPincel;
    noStroke();
    fill(muestra);
    ellipse(x + 12, y + h / 2, 10, 10);
    noFill();
    stroke(255, 50);
    strokeWeight(1);
    ellipse(x + 12, y + h / 2, 10, 10);
    fill(activo ? Config.TEXT_MAIN : Config.TEXT_MUTED);
    textAlign(LEFT, CENTER);
    textSize(10);
    text(etiqueta, x + 22, y + h / 2 - 1);
    popStyle();
  }

  void dibujarPaletaColor(int x, int y) {
    pushStyle();
    int d = 16;
    int gapX = 28;
    int gapY = 26;
    int startX = x + 16;
    int startY = y;
    for (int i = 0; i < state.paletaPinceles.length; i++) {
      int col = i % 2;
      int row = i / 2;
      float cx = startX + col * gapX;
      float cy = startY + row * gapY;
      color c = state.paletaPinceles[i];
      boolean seleccionado = editandoColorFondo ? c == state.colorFondo : c == state.colorPincel;
      boolean hovered = dist(mouseX, mouseY, cx, cy) <= d * 0.7f;
      float anim = getAnimState("palette_" + i, hovered || seleccionado);

      noStroke();
      fill(0, 82);
      ellipse(cx, cy + 1, d + 5 + 2 * anim, d + 5 + 2 * anim);
      fill(c);
      ellipse(cx, cy, d, d);
      noFill();
      stroke(seleccionado ? Config.TEXT_MAIN : color(255, 56 + 70 * anim));
      strokeWeight(seleccionado ? 2 : 1);
      ellipse(cx, cy, d + 5 + 2 * anim, d + 5 + 2 * anim);
    }
    popStyle();
  }

  int indiceColorPaleta(float mx, float my) {
    int d = 18;
    int gapX = 28;
    int gapY = 26;
    int startX = CENTER_X + 16;
    int startY = PALETTE_Y;
    for (int i = 0; i < state.paletaPinceles.length; i++) {
      int col = i % 2;
      int row = i / 2;
      float cx = startX + col * gapX;
      float cy = startY + row * gapY;
      if (dist(mx, my, cx, cy) <= d * 0.75f) return i;
    }
    return -1;
  }

  void aplicarColorPaleta(int index) {
    color nuevoColor = state.paletaPinceles[index];
    if (editandoColorFondo) state.setColorFondo(nuevoColor);
    else state.setColorPincel(nuevoColor);
  }

  void dibujarSwatchColor(int x, int y, int w, int h, color muestra, boolean fondo, String id) {
    pushStyle();
    boolean hovered = sobreBoton(x, y, w, h + 20);
    float anim = getAnimState(id, hovered);
    fill(lerpColor(Config.TEXT_DIM, Config.TEXT_MUTED, anim));
    textAlign(CENTER, CENTER);
    textSize(9);
    text(fondo ? "FONDO" : "PINCEL", x + w / 2, y - 10);
    dibujarBotonBase(x, y, w, h, false, id + "_base");
    noStroke();
    fill(0, 92);
    ellipse(x + w / 2, y + h / 2 + 1, 27 + 2 * anim, 27 + 2 * anim);
    fill(muestra);
    ellipse(x + w / 2, y + h / 2, 24, 24);
    noFill();
    stroke(255, 45);
    strokeWeight(1);
    ellipse(x + w / 2, y + h / 2, 24, 24);
    popStyle();
  }

  void dibujarBotonCandado(int x, int y, int w, int h, String id) {
    dibujarBotonBase(x, y, w, h, state.modoBloqueo, id);
    float hoverAnim = getAnimState(id + "_hover", sobreBoton(x, y, w, h + 20));
    float lockAnim = getAnimState(id + "_lock", state.modoBloqueo);
    color textColor = lerpColor(Config.TEXT_MUTED, Config.TEXT_MAIN, max(hoverAnim, lockAnim));
    dibujarTextoBoton(x, y, w, h, "CLIP", textColor);
  }

}
