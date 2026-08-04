class VectorStroke {
  ArrayList<PVector> puntos;
  color colorPincel;
  float grosor;
  int moduloOrigen;

  VectorStroke(color c, float g, int mod) {
    puntos = new ArrayList<PVector>();
    colorPincel = c;
    grosor = g;
    moduloOrigen = mod;
  }

  void addPunto(float x, float y) {
    if (puntos.size() > 0) {
      PVector ultimo = puntos.get(puntos.size() - 1);
      if (dist(ultimo.x, ultimo.y, x, y) < 0.5f) return;
    }
    puntos.add(new PVector(x, y));
  }

  void asegurarPuntoVisible() {
    if (puntos.size() == 1) {
      PVector p = puntos.get(0);
      puntos.add(new PVector(p.x + 0.01f, p.y + 0.01f));
    }
  }

  void simplificar(float epsilon) {
    if (puntos.size() < 3) return;
    puntos = douglasPeucker(puntos, epsilon);
  }

  ArrayList<PVector> douglasPeucker(ArrayList<PVector> pts, float epsilon) {
    float dmax = 0;
    int index = 0;
    int end = pts.size() - 1;

    for (int i = 1; i < end; i++) {
      float d = distanciaPuntoLinea(pts.get(i), pts.get(0), pts.get(end));
      if (d > dmax) {
        index = i;
        dmax = d;
      }
    }

    ArrayList<PVector> res = new ArrayList<PVector>();
    if (dmax > epsilon) {
      ArrayList<PVector> rec1 = douglasPeucker(new ArrayList<PVector>(pts.subList(0, index + 1)), epsilon);
      ArrayList<PVector> rec2 = douglasPeucker(new ArrayList<PVector>(pts.subList(index, end + 1)), epsilon);

      res.addAll(rec1);
      res.remove(res.size() - 1);
      res.addAll(rec2);
    } else {
      res.add(pts.get(0));
      res.add(pts.get(end));
    }
    return res;
  }

  float distanciaPuntoLinea(PVector p, PVector a, PVector b) {
    float area = abs(0.5f * (a.x * b.y + b.x * p.y + p.x * a.y - b.x * a.y - p.x * b.y - a.x * p.y));
    float base = dist(a.x, a.y, b.x, b.y);
    if (base < 0.00001f) return dist(p.x, p.y, a.x, a.y);
    return (area * 2.0f) / base;
  }

  VectorStroke interpolar(VectorStroke objetivo, float t) {
    if (objetivo == null) return clonar();
    if (puntos.size() == 0) return objetivo.clonar();
    if (objetivo.puntos.size() == 0) return clonar();

    color cLerp = lerpColor(colorPincel, objetivo.colorPincel, t);
    float gLerp = lerp(grosor, objetivo.grosor, t);
    int modLerp = t < 0.5f ? moduloOrigen : objetivo.moduloOrigen;
    VectorStroke resultado = new VectorStroke(cLerp, gLerp, modLerp);

    int maxPuntos = max(puntos.size(), objetivo.puntos.size());
    if (maxPuntos <= 1) {
      PVector pBase = puntos.get(0);
      PVector pObjetivo = objetivo.puntos.get(0);
      resultado.puntos.add(new PVector(lerp(pBase.x, pObjetivo.x, t), lerp(pBase.y, pObjetivo.y, t)));
      resultado.asegurarPuntoVisible();
      return resultado;
    }

    float longitudBase = longitudTotal(puntos);
    float longitudObjetivo = longitudTotal(objetivo.puntos);

    for (int i = 0; i < maxPuntos; i++) {
      float u = i / (float)(maxPuntos - 1);
      PVector pBase = getPuntoPorLongitud(puntos, u, longitudBase);
      PVector pObjetivo = getPuntoPorLongitud(objetivo.puntos, u, longitudObjetivo);
      resultado.puntos.add(new PVector(lerp(pBase.x, pObjetivo.x, t), lerp(pBase.y, pObjetivo.y, t)));
    }
    resultado.asegurarPuntoVisible();
    return resultado;
  }

  PVector getPuntoPorLongitud(ArrayList<PVector> pts, float u, float total) {
    if (pts.size() == 0) return new PVector(0, 0);
    if (pts.size() == 1) return pts.get(0);

    if (total <= 0.0001f) return pts.get(0);

    float objetivo = constrain(u, 0, 1) * total;
    float acumulado = 0;
    for (int i = 1; i < pts.size(); i++) {
      PVector a = pts.get(i - 1);
      PVector b = pts.get(i);
      float tramo = dist(a.x, a.y, b.x, b.y);
      if (acumulado + tramo >= objetivo) {
        float localT = tramo <= 0.0001f ? 0 : (objetivo - acumulado) / tramo;
        return new PVector(lerp(a.x, b.x, localT), lerp(a.y, b.y, localT));
      }
      acumulado += tramo;
    }
    return pts.get(pts.size() - 1);
  }

  float longitudTotal(ArrayList<PVector> pts) {
    float total = 0;
    for (int i = 1; i < pts.size(); i++) {
      PVector a = pts.get(i - 1);
      PVector b = pts.get(i);
      total += dist(a.x, a.y, b.x, b.y);
    }
    return total;
  }

  VectorStroke conAlpha(float alpha) {
    VectorStroke copia = clonar();
    copia.colorPincel = color(red(colorPincel), green(colorPincel), blue(colorPincel), alpha);
    return copia;
  }

  VectorStroke clonar() {
    VectorStroke copia = new VectorStroke(colorPincel, grosor, moduloOrigen);
    for (PVector p : puntos) copia.puntos.add(new PVector(p.x, p.y));
    return copia;
  }
}
