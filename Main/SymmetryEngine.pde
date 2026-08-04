import java.awt.Shape;
import java.awt.geom.AffineTransform;

class SymmetryEngine {
  PGraphics canvas;
  GridSystem grid;
  AppState state;

  ArrayList<AnimLayer> capas;
  int indiceCapaActiva;

  VectorStroke trazoActivo;
  Shape clipAnterior;

  boolean estaDibujando = false;
  int moduloActivoDibujo = -1;
  int moduloHover = -1;
  float drawFeedbackAnim = 0;

  SymmetryEngine(PGraphics g, GridSystem gSys, AppState st) {
    canvas = g;
    grid = gSys;
    state = st;

    capas = new ArrayList<AnimLayer>();
    capas.add(new AnimLayer());
    indiceCapaActiva = 0;
  }

  AnimLayer getCapaActiva() {
    return capas.get(indiceCapaActiva);
  }

  void nuevaCapa() {
    capas.add(new AnimLayer());
    indiceCapaActiva = capas.size() - 1;
  }

  void eliminarCapaActiva() {
    if (capas.size() <= 1) {
      getCapaActiva().getEstadoActual().limpiar();
      indiceCapaActiva = 0;
      return;
    }
    capas.remove(indiceCapaActiva);
    indiceCapaActiva = constrain(indiceCapaActiva, 0, capas.size() - 1);
  }

  void moverCapaActivaAbajo() {
    if (indiceCapaActiva <= 0) return;
    AnimLayer actual = capas.get(indiceCapaActiva);
    capas.set(indiceCapaActiva, capas.get(indiceCapaActiva - 1));
    capas.set(indiceCapaActiva - 1, actual);
    indiceCapaActiva--;
  }

  void moverCapaActivaArriba() {
    if (indiceCapaActiva >= capas.size() - 1) return;
    AnimLayer actual = capas.get(indiceCapaActiva);
    capas.set(indiceCapaActiva, capas.get(indiceCapaActiva + 1));
    capas.set(indiceCapaActiva + 1, actual);
    indiceCapaActiva++;
  }

  void subirCapa() {
    if (indiceCapaActiva < capas.size() - 1) indiceCapaActiva++;
  }

  void bajarCapa() {
    if (indiceCapaActiva > 0) indiceCapaActiva--;
  }

  boolean isDibujando() {
    return estaDibujando;
  }

  void nuevoEstado() {
    getCapaActiva().addNuevoEstado();
  }

  void siguienteEstado() {
    getCapaActiva().nextEstado();
  }

  void anteriorEstado() {
    getCapaActiva().prevEstado();
  }

  int getEstadoActualIndex() {
    return getCapaActiva().estadoActualIndex;
  }

  int getTotalEstados() {
    return getCapaActiva().getNumEstados();
  }

  void iniciarTrazo(float mouseX, float mouseY) {
    float lienzoX = pantallaACanvasX(mouseX);
    float lienzoY = pantallaACanvasY(mouseY);
    moduloActivoDibujo = grid.calcularModulo(lienzoX, lienzoY);

    if (grid.moduloValido(moduloActivoDibujo)) {
      estaDibujando = true;
      trazoActivo = new VectorStroke(state.colorPincel, state.grosorPincel, moduloActivoDibujo);
      trazoActivo.addPunto(lienzoX, lienzoY);
    }
  }

  void arrastrarTrazo(float pX, float pY, float x, float y) {
    if (estaDibujando && trazoActivo != null) {
      trazoActivo.addPunto(pantallaACanvasX(x), pantallaACanvasY(y));
    }
  }

  void finalizarTrazo() {
    if (estaDibujando && trazoActivo != null) {
      trazoActivo.asegurarPuntoVisible();
      trazoActivo.simplificar(1.2f);
      getCapaActiva().getEstadoActual().addTrazo(trazoActivo);
      trazoActivo = null;
    }
    estaDibujando = false;
    moduloActivoDibujo = -1;
  }

  void renderizar(TimelineEngine timeline, PGraphics canvasIzquierdo, PGraphics canvasDerecho) {
    canvasIzquierdo.beginDraw();
    canvasIzquierdo.clear();
    canvas = canvasIzquierdo;

    if (state.mostrarPapelCebolla) dibujarPapelCebolla();

    for (int i = 0; i < capas.size(); i++) {
      AnimLayer capa = capas.get(i);
      if (!capa.visible) continue;

      for (VectorStroke t : capa.getEstadoActual().getTrazos()) {
        dibujarVectorStroke(t);
      }
    }

    if (estaDibujando && trazoActivo != null) {
      dibujarVectorStroke(trazoActivo);
    }
    canvasIzquierdo.endDraw();

    canvasDerecho.beginDraw();
    canvasDerecho.clear();
    canvas = canvasDerecho;

    for (AnimLayer capa : capas) {
      if (!capa.visible) continue;

      AnimState fotogramaVivo = timeline.getFrameInterpoladoAt(timeline.globalTime, capa);
      for (VectorStroke t : fotogramaVivo.getTrazos()) {
        dibujarVectorStroke(t);
      }
    }
    canvasDerecho.endDraw();
  }

  void dibujarPapelCebolla() {
    AnimLayer capa = getCapaActiva();
    if (capa.estadoActualIndex <= 0) return;

    AnimState estadoAnterior = capa.estados.get(capa.estadoActualIndex - 1);
    for (VectorStroke t : estadoAnterior.getTrazos()) {
      dibujarVectorStroke(t.conAlpha(42));
    }
  }

  void dibujarVectorStroke(VectorStroke trazo) {
    if (trazo.puntos.size() < 2) return;

    canvas.stroke(trazo.colorPincel);
    canvas.strokeWeight(trazo.grosor);
    canvas.strokeCap(ROUND);
    canvas.strokeJoin(ROUND);
    canvas.noFill();

    dibujarSimetriaReflexionRadial(trazo, grid.capaModulo(trazo.moduloOrigen));
  }

  void configurarClip(int m) {
    processing.awt.PGraphicsJava2D lienzo = (processing.awt.PGraphicsJava2D)canvas;
    clipAnterior = lienzo.g2.getClip();
    lienzo.g2.setClip(grid.getForma(m));
  }

  void restaurarClip() {
    processing.awt.PGraphicsJava2D lienzo = (processing.awt.PGraphicsJava2D)canvas;
    lienzo.g2.setClip(clipAnterior);
  }

  void dibujarSimetriaReflexionRadial(VectorStroke trazo, int capaOrigen) {
    int sectorOrigen = grid.sectorModulo(trazo.moduloOrigen);

    if (capaOrigen == 0) {
      for (int cD = 0; cD < Config.CENTER_QUADRANTS; cD++) {
        if (state.modoBloqueo) configurarClip(cD);
        canvas.beginShape();
        for (PVector p : trazo.puntos) {
          canvas.vertex(mapearXCentro(p.x, capaOrigen, cD), mapearYCentro(p.y, capaOrigen, cD));
        }
        canvas.endShape();
        if (state.modoBloqueo) restaurarClip();
      }
    } else {
      for (int mD = 0; mD < grid.NUM_MODULES; mD++) {
        if (!grid.moduloValido(mD) || grid.capaModulo(mD) != capaOrigen) continue;
        int t = transformacionEntreSectores(sectorOrigen, grid.sectorModulo(mD));

        if (state.modoBloqueo) configurarClip(mD);
        canvas.beginShape();
        for (PVector p : trazo.puntos) {
          canvas.vertex(transformarX(p.x, p.y, t), transformarY(p.x, p.y, t));
        }
        canvas.endShape();
        if (state.modoBloqueo) restaurarClip();
      }
    }
  }

  float mapearXCentro(float x, int cO, int cD) {
    float d = (x - grid.CANVAS_CENTER) * grid.signoXCuadrante(cO);
    return grid.CANVAS_CENTER + d * grid.signoXCuadrante(cD);
  }

  float mapearYCentro(float y, int cO, int cD) {
    float d = (y - grid.CANVAS_CENTER) * grid.signoYCuadrante(cO);
    return grid.CANVAS_CENTER + d * grid.signoYCuadrante(cD);
  }

  float transformarX(float x, float y, int t) {
    float dx = x - grid.CANVAS_CENTER;
    float dy = y - grid.CANVAS_CENTER;
    if (t == 1) return grid.CANVAS_CENTER - dy;
    else if (t == 2) return grid.CANVAS_CENTER - dx;
    else if (t == 3) return grid.CANVAS_CENTER + dy;
    else if (t == 4) return grid.CANVAS_CENTER - dx;
    else if (t == 5) return grid.CANVAS_CENTER + dx;
    else if (t == 6) return grid.CANVAS_CENTER + dy;
    else if (t == 7) return grid.CANVAS_CENTER - dy;
    return grid.CANVAS_CENTER + dx;
  }

  float transformarY(float x, float y, int t) {
    float dx = x - grid.CANVAS_CENTER;
    float dy = y - grid.CANVAS_CENTER;
    if (t == 1) return grid.CANVAS_CENTER + dx;
    else if (t == 2) return grid.CANVAS_CENTER - dy;
    else if (t == 3) return grid.CANVAS_CENTER - dx;
    else if (t == 4) return grid.CANVAS_CENTER + dy;
    else if (t == 5) return grid.CANVAS_CENTER - dy;
    else if (t == 6) return grid.CANVAS_CENTER + dx;
    else if (t == 7) return grid.CANVAS_CENTER - dx;
    return grid.CANVAS_CENTER + dy;
  }

  int transformacionEntreSectores(int sO, int sD) {
    for (int t = 0; t < 8; t++) {
      if (transformarSector(sO, t) == sD) return t;
    }
    return 0;
  }

  int transformarSector(int s, int t) {
    float aM = (s + 0.5f) * TWO_PI / Config.SECTOR_COUNT;
    float dx = cos(aM);
    float dy = sin(aM);
    float tx = 0;
    float ty = 0;

    if (t == 1) { tx = -dy; ty = dx; }
    else if (t == 2) { tx = -dx; ty = -dy; }
    else if (t == 3) { tx = dy; ty = -dx; }
    else if (t == 4) { tx = -dx; ty = dy; }
    else if (t == 5) { tx = dx; ty = -dy; }
    else if (t == 6) { tx = dy; ty = dx; }
    else if (t == 7) { tx = -dy; ty = -dx; }
    else { tx = dx; ty = dy; }

    float a = atan2(ty, tx);
    if (a < 0) a += TWO_PI;
    return min(floor(a / (TWO_PI / Config.SECTOR_COUNT)), Config.SECTOR_COUNT - 1);
  }

  void actualizarHover(float mx, float my) {
    if (estaDibujando) moduloHover = moduloActivoDibujo;
    else if (enVistaCanvas(mx, my)) moduloHover = grid.calcularModulo(pantallaACanvasX(mx), pantallaACanvasY(my));
    else moduloHover = -1;
  }

  boolean enVistaCanvas(float sx, float sy) {
    if (sx < Config.LEFT_BAR_W || sx >= Config.LEFT_BAR_W + Config.CANVAS_SIZE || sy < 0 || sy >= Config.CANVAS_SIZE) return false;
    return grid.enCanvasLocal(pantallaACanvasX(sx), pantallaACanvasY(sy));
  }

  float pantallaACanvasX(float sx) {
    float c = Config.CANVAS_SIZE / 2.0f;
    float localX = sx - Config.LEFT_BAR_W;
    return c + (localX - c) / state.zoomLienzo;
  }

  float pantallaACanvasY(float sy) {
    float c = Config.CANVAS_SIZE / 2.0f;
    return c + (sy - c) / state.zoomLienzo;
  }

  void dibujarHover() {
    drawFeedbackAnim = lerp(drawFeedbackAnim, estaDibujando ? 1.0f : 0.0f, 0.15f);
    if (moduloHover < 0 || moduloHover >= grid.NUM_MODULES) return;

    processing.awt.PGraphicsJava2D lienzo = (processing.awt.PGraphicsJava2D)g;
    boolean fondoClaro = colorBrightness(state.colorFondo) > 127;
    color baseC = fondoClaro ? color(0) : color(255);
    color targetC = color(255, 0, 255);
    color c = lerpColor(baseC, targetC, drawFeedbackAnim * 0.3f);

    lienzo.g2.setColor(new java.awt.Color((int)red(c), (int)green(c), (int)blue(c), (int)(15 + 20 * drawFeedbackAnim)));
    java.awt.Shape clipAnteriorPantalla = lienzo.g2.getClip();
    AffineTransform transformAnterior = lienzo.g2.getTransform();
    lienzo.g2.setClip(Config.LEFT_BAR_W, 0, Config.CANVAS_SIZE, Config.CANVAS_SIZE);
    lienzo.g2.translate(Config.LEFT_BAR_W + grid.CANVAS_CENTER, grid.CANVAS_CENTER);
    lienzo.g2.scale(state.zoomLienzo, state.zoomLienzo);
    lienzo.g2.translate(-grid.CANVAS_CENTER, -grid.CANVAS_CENTER);
    lienzo.g2.fill(grid.getForma(moduloHover));
    lienzo.g2.setTransform(transformAnterior);
    lienzo.g2.setClip(clipAnteriorPantalla);
  }

  void dibujarReticulaOverlay() {
    if (!state.mostrarReticula) return;

    pushStyle();
    clip(Config.LEFT_BAR_W, 0, Config.CANVAS_SIZE, Config.CANVAS_SIZE);
    pushMatrix();
    translate(Config.LEFT_BAR_W + grid.CANVAS_CENTER, grid.CANVAS_CENTER);
    scale(state.zoomLienzo);
    translate(-grid.CANVAS_CENTER, -grid.CANVAS_CENTER);

    noFill();
    boolean fondoClaro = colorBrightness(state.colorFondo) > 132;
    color gridC = fondoClaro ? color(0) : color(255);
    color haloC = fondoClaro ? color(255) : color(0);
    float pesoBase = 1.0f / state.zoomLienzo;

    strokeWeight(2.4f / state.zoomLienzo);
    stroke(haloC, 58);

    ellipse(grid.CANVAS_CENTER, grid.CANVAS_CENTER, grid.INNER_RADIUS * 2, grid.INNER_RADIUS * 2);
    for (int r = 1; r <= Config.RING_COUNT; r++) {
      float radio = grid.INNER_RADIUS + r * grid.RING_THICKNESS;
      ellipse(grid.CANVAS_CENTER, grid.CANVAS_CENTER, radio * 2, radio * 2);
    }

    for (int s = 0; s < Config.SECTOR_COUNT; s++) {
      float a = s * TWO_PI / Config.SECTOR_COUNT;
      float x = grid.CANVAS_CENTER + cos(a) * grid.radioHastaBordeCanvas(a);
      float y = grid.CANVAS_CENTER + sin(a) * grid.radioHastaBordeCanvas(a);
      line(grid.CANVAS_CENTER, grid.CANVAS_CENTER, x, y);
    }

    strokeWeight(pesoBase);
    stroke(gridC, 86);
    ellipse(grid.CANVAS_CENTER, grid.CANVAS_CENTER, grid.INNER_RADIUS * 2, grid.INNER_RADIUS * 2);
    for (int r = 1; r <= Config.RING_COUNT; r++) {
      float radio = grid.INNER_RADIUS + r * grid.RING_THICKNESS;
      ellipse(grid.CANVAS_CENTER, grid.CANVAS_CENTER, radio * 2, radio * 2);
    }

    stroke(gridC, 72);
    for (int s = 0; s < Config.SECTOR_COUNT; s++) {
      float a = s * TWO_PI / Config.SECTOR_COUNT;
      float x = grid.CANVAS_CENTER + cos(a) * grid.radioHastaBordeCanvas(a);
      float y = grid.CANVAS_CENTER + sin(a) * grid.radioHastaBordeCanvas(a);
      line(grid.CANVAS_CENTER, grid.CANVAS_CENTER, x, y);
    }

    strokeWeight(1.25f / state.zoomLienzo);
    stroke(gridC, 118);
    line(grid.CANVAS_CENTER - grid.INNER_RADIUS, grid.CANVAS_CENTER, grid.CANVAS_CENTER + grid.INNER_RADIUS, grid.CANVAS_CENTER);
    line(grid.CANVAS_CENTER, grid.CANVAS_CENTER - grid.INNER_RADIUS, grid.CANVAS_CENTER, grid.CANVAS_CENTER + grid.INNER_RADIUS);

    popMatrix();
    noClip();
    popStyle();
  }

  void limpiarCanvas() {
    getCapaActiva().getEstadoActual().limpiar();
  }

  void exportarDibujo() {
    String nombre = "Canvas-" + year() + nf(month(), 2) + nf(day(), 2) + "-" + nf(hour(), 2) + nf(minute(), 2) + nf(second(), 2) + ".png";
    PGraphics e = canvas.parent.createGraphics(Config.CANVAS_SIZE, Config.CANVAS_SIZE, JAVA2D);
    if (e != null) {
      e.beginDraw();
      e.background(state.colorFondo);
      e.image(canvas, 0, 0);
      e.endDraw();
      e.save(nombre);
      println("Exportado con exito: " + nombre);
    }
  }

  float colorBrightness(color c) {
    return (red(c) + green(c) + blue(c)) / 3.0f;
  }
}
