# Modular Tessellation Studio

A Processing-based generative drawing and animation workspace built around radial tessellation, vector strokes, symmetry propagation, layers, animation states, and GIF export.

## Motivation

This project investigates how a drawing tool can behave like a modular animation system. A stroke drawn in one region can be transformed across a tessellated structure, allowing small gestures to generate complex visual compositions.

The project was developed through an AI-assisted software design workflow. Natural-language prompts and iterative development logs were used to define the interaction model, separate the architecture into modules, and refine the relationship between drawing, symmetry, layers, history, and timeline playback.

## Philosophy

The system treats drawing as a reusable event rather than a fixed bitmap mark. Strokes are stored as vector data, associated with a source module, and replayed through geometric transformation rules.

This creates a high-level superstructure: the user draws locally, while the system composes globally.

## Development Methodology

The implementation emerged through structured prompt engineering and conversational refactoring. The logbook-driven workflow helped convert exploratory creative requirements into stable engineering concepts:

- a radial grid as the spatial grammar;
- vector strokes as reusable primitives;
- symmetry rules as deterministic transformations;
- animation states as editable snapshots;
- a timeline engine as the orchestration layer;
- a UI manager as the interface boundary.

## Architecture Overview

The project separates drawing state, geometric structure, animation playback, UI controls, history, and export.

Main modules:

- `Main.pde` initializes the application, canvases, engines, UI, timeline, and input routing.
- `Config.pde` centralizes dimensions, layout constants, grid counts, colors, and playback modes.
- `GridSystem.pde` constructs the modular radial tessellation using Java2D shapes.
- `SymmetryEngine.pde` records strokes, applies radial/reflection transformations, renders layers, clips modules, and manages active states.
- `VectorStroke.pde` stores stroke points, color, thickness, source module, simplification, resampling, interpolation, and alpha variants.
- `AnimState.pde` stores frame-level stroke collections and interpolates between states.
- `AnimLayer.pde` groups animation states into visible layers.
- `TimelineEngine.pde` manages playback, loop modes, ping-pong motion, timing, and multi-layer interpolation.
- `HistoryManager.pde` stores undo/redo snapshots.
- `UIManager.pde` draws panels, controls, state indicators, and tool settings.
- `GifExporter.pde` serializes animated output.

## Technical Implementation

The workspace uses two canvases: one for editing and one for animation preview. Strokes are captured as vector point lists, simplified with Douglas-Peucker reduction, and stored inside animation states. The grid divides the canvas into central quadrants, rings, sectors, and outer modules.

When a stroke is rendered, `SymmetryEngine` determines its source module and applies transformation rules to every compatible destination module. Optional clipping constrains mirrored strokes to their module boundaries. The timeline interpolates between animation states by resampling stroke lengths, blending points, color, thickness, and alpha.

## How It Works

1. `GridSystem` builds a radial modular grid.
2. The user draws a stroke inside one module.
3. `VectorStroke` stores the gesture as editable vector data.
4. `SymmetryEngine` maps the stroke across related grid modules.
5. `AnimLayer` and `AnimState` preserve editable frames.
6. `TimelineEngine` interpolates frames during playback.
7. `GifExporter` captures the animated result.

## Installation

Install Processing 4 and open `Main/Main.pde`.

The sketch uses the Processing `gifAnimation` library. Install it from Processing's Contribution Manager before exporting GIFs.

## Usage

Run `Main.pde` from Processing.

Useful controls:

- Draw with the left mouse button inside the canvas.
- `Z`: undo
- `Y`: redo
- `C`: clear active state
- `N`: create a new animation state
- `Space`: play or pause
- `M`: change playback mode
- `E`: export GIF
- `L`: toggle module clipping
- `O`: toggle onion skin
- `G`: toggle grid
- Arrow keys: navigate states and layers
- `+`, `-`, `0`: zoom controls

## Project Structure

```text
modular-tessellation-studio/
  Main/
    Main.pde             # Application entry point
    Config.pde           # Global constants and layout
    AppState.pde         # Mutable UI and drawing state
    GridSystem.pde       # Radial tessellation geometry
    SymmetryEngine.pde   # Drawing, symmetry, clipping, and rendering engine
    VectorStroke.pde     # Vector stroke model and interpolation helpers
    AnimState.pde        # Frame-level stroke collection
    AnimLayer.pde        # Layer-level animation state
    TimelineEngine.pde   # Playback and interpolation
    HistoryManager.pde   # Undo/redo snapshots
    UIManager.pde        # Interface drawing and controls
    GifExporter.pde      # GIF export
    sketch.properties    # Processing metadata
```

## Future Work

- Add screenshots, sample animations, and exported examples.
- Add a short architectural diagram showing grid, stroke, layer, and timeline flow.
- Move generated GIFs into an ignored export folder.
- Add parameter presets for different tessellation grammars.
- Consider serializing projects to JSON for reloading sessions.

## License

Add a license before publication. MIT is recommended unless bundled dependencies or assets require a different license.

