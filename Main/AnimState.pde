class AnimState {
  ArrayList<VectorStroke> trazos;

  AnimState() {
    trazos = new ArrayList<VectorStroke>();
  }

  void addTrazo(VectorStroke trazo) {
    if (trazo != null) trazos.add(trazo);
  }

  ArrayList<VectorStroke> getTrazos() {
    return trazos;
  }

  void limpiar() {
    trazos.clear();
  }

  AnimState clonar() {
    AnimState copia = new AnimState();
    for (VectorStroke trazo : trazos) copia.addTrazo(trazo.clonar());
    return copia;
  }

  AnimState conAlpha(float alpha) {
    AnimState copia = new AnimState();
    for (VectorStroke trazo : trazos) copia.addTrazo(trazo.conAlpha(alpha));
    return copia;
  }

  AnimState interpolar(AnimState destino, float t) {
    AnimState fotogramaIntermedio = new AnimState();
    if (destino == null) return clonar();

    int maxTrazos = max(trazos.size(), destino.trazos.size());
    for (int i = 0; i < maxTrazos; i++) {
      VectorStroke trazoBase = i < trazos.size() ? trazos.get(i) : null;
      VectorStroke trazoDestino = i < destino.trazos.size() ? destino.trazos.get(i) : null;

      if (trazoBase != null && trazoDestino != null) {
        fotogramaIntermedio.addTrazo(trazoBase.interpolar(trazoDestino, t));
      } else if (trazoBase != null) {
        fotogramaIntermedio.addTrazo(trazoBase.conAlpha(lerp(255, 0, t)));
      } else if (trazoDestino != null) {
        fotogramaIntermedio.addTrazo(trazoDestino.conAlpha(lerp(0, 255, t)));
      }
    }
    return fotogramaIntermedio;
  }
}
