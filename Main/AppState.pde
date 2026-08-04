class AppState {
  float grosorPincel = 5;
  final float GROSOR_MIN = 1;
  final float GROSOR_MAX = 36;
  boolean modoBloqueo = false;
  boolean mostrarPapelCebolla = true;
  boolean mostrarReticula = false;

  float zoomLienzo = 1.0f;
  float zoomObjetivo = 1.0f;
  final float ZOOM_MIN = 0.5f;
  final float ZOOM_MAX = 4.0f;
  final float ZOOM_STEP = 1.2f;

  color colorFondo = #0C0C0E;
  color colorPincel = #F280CA;

  int indiceColorFondo = 0;
  int indiceColorPincel = 0;
  color[] paletaFondos = {#0C0C0E, #F280CA, #113A8C, #0798F2, #07DBF2, #F2AD85, #7E6A9B, #C1535E, #DC8898, #D8D2A0, #6E5370, #2DC653, #8AC926, #9D4EDD, #C77DFF};
  color[] paletaPinceles = {#F280CA, #113A8C, #0798F2, #07DBF2, #F2AD85, #7E6A9B, #C1535E, #DC8898, #D8D2A0, #6E5370, #2DC653, #8AC926, #9D4EDD, #C77DFF};

  void toggleBloqueo() {
    modoBloqueo = !modoBloqueo;
  }

  void togglePapelCebolla() {
    mostrarPapelCebolla = !mostrarPapelCebolla;
  }

  void toggleReticula() {
    mostrarReticula = !mostrarReticula;
  }

  void acercarZoom() {
    zoomObjetivo = constrain(zoomObjetivo * ZOOM_STEP, ZOOM_MIN, ZOOM_MAX);
  }

  void alejarZoom() {
    zoomObjetivo = constrain(zoomObjetivo / ZOOM_STEP, ZOOM_MIN, ZOOM_MAX);
  }

  void resetZoom() {
    zoomObjetivo = 1.0f;
  }

  void actualizarZoom() {
    zoomLienzo = lerp(zoomLienzo, zoomObjetivo, 0.22f);
    if (abs(zoomLienzo - zoomObjetivo) < 0.001f) zoomLienzo = zoomObjetivo;
  }

  void cambiarColorFondo() {
    indiceColorFondo = (indiceColorFondo + 1) % paletaFondos.length;
    colorFondo = paletaFondos[indiceColorFondo];
  }

  void cambiarColorPincel() {
    indiceColorPincel = (indiceColorPincel + 1) % paletaPinceles.length;
    colorPincel = paletaPinceles[indiceColorPincel];
  }

  void setColorFondo(color nuevoColor) {
    colorFondo = nuevoColor;
  }

  void setColorPincel(color nuevoColor) {
    colorPincel = nuevoColor;
  }

  void setGrosorPincel(float nuevoGrosor) {
    grosorPincel = constrain(nuevoGrosor, GROSOR_MIN, GROSOR_MAX);
  }
}
