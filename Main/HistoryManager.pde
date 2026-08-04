class HistorySnapshot {
  ArrayList<AnimLayer> capas;
  int indiceCapaActiva;

  HistorySnapshot(ArrayList<AnimLayer> capasOrigen, int indiceActivo) {
    capas = new ArrayList<AnimLayer>();
    for (AnimLayer capa : capasOrigen) capas.add(capa.clonar());
    indiceCapaActiva = indiceActivo;
  }
}

class HistoryManager {
  ArrayList<HistorySnapshot> historialDeshacer = new ArrayList<HistorySnapshot>();
  ArrayList<HistorySnapshot> historialRehacer = new ArrayList<HistorySnapshot>();
  SymmetryEngine engine;

  final int MAX_HISTORY = Config.MAX_HISTORY;

  HistoryManager(SymmetryEngine engine) {
    this.engine = engine;
  }

  void guardarEstado() {
    historialDeshacer.add(capturar());
    if (historialDeshacer.size() > MAX_HISTORY) historialDeshacer.remove(0);
    historialRehacer.clear();
  }

  void deshacer() {
    if (historialDeshacer.size() == 0) return;
    historialRehacer.add(capturar());
    restaurar(historialDeshacer.remove(historialDeshacer.size() - 1));
  }

  void rehacer() {
    if (historialRehacer.size() == 0) return;
    historialDeshacer.add(capturar());
    restaurar(historialRehacer.remove(historialRehacer.size() - 1));
  }

  HistorySnapshot capturar() {
    return new HistorySnapshot(engine.capas, engine.indiceCapaActiva);
  }

  void restaurar(HistorySnapshot snapshot) {
    engine.capas = new ArrayList<AnimLayer>();
    for (AnimLayer capa : snapshot.capas) engine.capas.add(capa.clonar());
    if (engine.capas.size() == 0) engine.capas.add(new AnimLayer());
    engine.indiceCapaActiva = constrain(snapshot.indiceCapaActiva, 0, engine.capas.size() - 1);
  }
}
