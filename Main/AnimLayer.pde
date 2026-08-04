class AnimLayer {
  ArrayList<AnimState> estados;
  int estadoActualIndex;
  boolean visible = true;

  AnimLayer() {
    estados = new ArrayList<AnimState>();
    estados.add(new AnimState());
    estadoActualIndex = 0;
  }

  AnimState getEstadoActual() {
    estadoActualIndex = constrain(estadoActualIndex, 0, estados.size() - 1);
    return estados.get(estadoActualIndex);
  }

  void addNuevoEstado() {
    estados.add(estadoActualIndex + 1, getEstadoActual().clonar());
    estadoActualIndex++;
  }

  void nextEstado() {
    if (estadoActualIndex < estados.size() - 1) estadoActualIndex++;
  }

  void prevEstado() {
    if (estadoActualIndex > 0) estadoActualIndex--;
  }

  int getNumEstados() {
    return estados.size();
  }

  AnimLayer clonar() {
    AnimLayer copia = new AnimLayer();
    copia.estados.clear();
    for (AnimState estado : estados) copia.estados.add(estado.clonar());
    copia.estadoActualIndex = constrain(estadoActualIndex, 0, copia.estados.size() - 1);
    copia.visible = visible;
    return copia;
  }
}
