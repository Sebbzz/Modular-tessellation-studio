import processing.awt.PGraphicsJava2D;
import java.awt.Shape;
import java.awt.geom.Area;
import java.awt.geom.Ellipse2D;
import java.awt.geom.Path2D;
import java.awt.geom.Rectangle2D;
import java.awt.geom.AffineTransform;
import gifAnimation.*;

AppState state;
GridSystem grid;
SymmetryEngine engine;
UIManager ui;
HistoryManager history;
TimelineEngine timeline;
PGraphics dibujo;
PGraphics animacionDibujo;
GifExporter gifExporter;


void settings() {
  size(Config.LEFT_BAR_W + Config.CANVAS_SIZE + Config.CENTER_BAR_W + Config.ANIM_CANVAS_SIZE + Config.RIGHT_BAR_W,
       Config.CANVAS_SIZE + Config.BOTTOM_BAR_H, JAVA2D);
  smooth(8);
}

void setup() {
  surface.setTitle("Z3bbZ Studio - Generative Animation Workspace");

  state = new AppState();
  dibujo = crearCanvas(Config.CANVAS_SIZE, Config.CANVAS_SIZE);
  animacionDibujo = crearCanvas(Config.ANIM_CANVAS_SIZE, Config.ANIM_CANVAS_SIZE);

  grid = new GridSystem();
  engine = new SymmetryEngine(dibujo, grid, state);
  history = new HistoryManager(engine);
  timeline = new TimelineEngine(engine);
  gifExporter = new GifExporter(this, engine, timeline, state);
  ui = new UIManager(state, engine, history, timeline);
}

PGraphics crearCanvas(int w, int h) {
  PGraphics pg = createGraphics(w, h, JAVA2D);
  pg.smooth(8);
  pg.beginDraw();
  pg.clear();
  pg.endDraw();
  return pg;
}

void draw() {
  dibujarFondoAplicacion();

  state.actualizarZoom();
  timeline.update();
  engine.actualizarHover(mouseX, mouseY);

  pushStyle();
  noStroke();
  fill(state.colorFondo);
  rect(Config.LEFT_BAR_W, 0, Config.CANVAS_SIZE, Config.CANVAS_SIZE);
  rect(Config.LEFT_BAR_W + Config.CANVAS_SIZE + Config.CENTER_BAR_W, 0, Config.ANIM_CANVAS_SIZE, Config.CANVAS_SIZE);
  popStyle();

  engine.renderizar(timeline, dibujo, animacionDibujo);

  dibujarCanvasEdicion();
  image(animacionDibujo, Config.LEFT_BAR_W + Config.CANVAS_SIZE + Config.CENTER_BAR_W, 0);

  engine.dibujarReticulaOverlay();
  engine.dibujarHover();
  ui.dibujarPaneles();

  if (engine.enVistaCanvas(mouseX, mouseY)) {
    noCursor();
    ui.dibujarPuntero(mouseX, mouseY, engine.isDibujando());
  } else {
    cursor(ARROW);
  }
}

void mousePressed() {
  if (mouseButton != LEFT) return;

  if (engine.enVistaCanvas(mouseX, mouseY)) {
    history.guardarEstado();
    engine.iniciarTrazo(mouseX, mouseY);
  } else {
    ui.revisarClics(mouseX, mouseY);
  }
}

void mouseDragged() {
  if (mouseButton == LEFT) {
    if (ui.arrastrarControles(mouseX, mouseY)) return;
    engine.arrastrarTrazo(pmouseX, pmouseY, mouseX, mouseY);
  }
}

void mouseReleased() {
  ui.soltarControles();
  if (mouseButton == LEFT) engine.finalizarTrazo();
}

void dibujarFondoAplicacion() {
  background(Config.UI_BG_DEEP);
  pushStyle();
  noStroke();
  for (int y = 0; y < height; y += 2) {
    float t = y / (float)height;
    fill(lerpColor(#050608, #111318, t));
    rect(0, y, width, 2);
  }
  fill(255, 4);
  rect(Config.LEFT_BAR_W, 0, Config.CANVAS_SIZE, Config.CANVAS_SIZE);
  rect(Config.LEFT_BAR_W + Config.CANVAS_SIZE + Config.CENTER_BAR_W, 0, Config.ANIM_CANVAS_SIZE, Config.CANVAS_SIZE);
  fill(0, 22);
  rect(0, Config.CANVAS_SIZE, width, Config.BOTTOM_BAR_H);
  popStyle();
}

void dibujarCanvasEdicion() {
  pushStyle();
  clip(Config.LEFT_BAR_W, 0, Config.CANVAS_SIZE, Config.CANVAS_SIZE);
  imageMode(CENTER);
  image(dibujo,
        Config.LEFT_BAR_W + Config.CANVAS_SIZE / 2.0f,
        Config.CANVAS_SIZE / 2.0f,
        Config.CANVAS_SIZE * state.zoomLienzo,
        Config.CANVAS_SIZE * state.zoomLienzo);
  imageMode(CORNER);
  noClip();
  popStyle();
}

void keyPressed() {
  if (key == 'z' || key == 'Z') {
    history.deshacer();
  } else if (key == 'y' || key == 'Y') {
    history.rehacer();
  } else if (key == 'c' || key == 'C') {
    history.guardarEstado();
    engine.limpiarCanvas();
  } else if (key == 'e' || key == 'E') {
    gifExporter.exportarGif();
  } else if (key == 'l' || key == 'L') {
    state.toggleBloqueo();
  } else if (key == 'o' || key == 'O') {
    state.togglePapelCebolla();
  } else if (key == 'n' || key == 'N') {
    history.guardarEstado();
    engine.nuevoEstado();
    timeline.sincronizarConEstadoActivo();
  } else if (key == ' ') {
    timeline.togglePlay();
  } else if (key == 'm' || key == 'M') {
    timeline.setMode((timeline.mode + 1) % 3);
  } else if (key == '+' || key == '=') {
    state.acercarZoom();
  } else if (key == '-' || key == '_') {
    state.alejarZoom();
  } else if (key == '0') {
    state.resetZoom();
  } else if (key == 'g' || key == 'G') {
    state.toggleReticula();
  } else if (keyCode == RIGHT) {
    engine.siguienteEstado();
    timeline.sincronizarConEstadoActivo();
  } else if (keyCode == LEFT) {
    engine.anteriorEstado();
    timeline.sincronizarConEstadoActivo();
  } else if (keyCode == UP) {
    engine.subirCapa();
    timeline.sincronizarConEstadoActivo();
  } else if (keyCode == DOWN) {
    engine.bajarCapa();
    timeline.sincronizarConEstadoActivo();
  }
}
