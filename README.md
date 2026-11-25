# Factory Capital

Automation game prototype. Step 1: build 3D shapes (boxes, spheres, cylinders) in a free
3D workspace with a floating editor-style camera — no physical player character.

Built with Godot 4.7 (Forward Plus). Open the project folder in the Godot editor and press F5,
or run:

```sh
godot --path .
```

## Controls

| Input | Action |
| --- | --- |
| `1` / `2` / `3` | Select: Box / Sphere / Cylinder |
| Left click | Place selected shape at crosshair |
| `+` / `-` | Grow / shrink next shape |
| `R` | Rotate next shape 45° |
| `X` | Delete shape under crosshair |
| `W` `A` `S` `D` | Fly camera |
| `Q` / `E` | Move down / up |
| `Shift` | Fast camera |
| Right drag | Orbit camera |
| Mouse wheel | Zoom |

Shapes snap to the surface under the crosshair and align to its normal, with a translucent
ghost preview before placement.

## Development

Headless smoke test:

```sh
godot --headless --path . --import
godot --headless --path . -s res://tests/smoke.gd
```

Project layout:

- `scenes/main.tscn` — world: environment, sun, ground, camera rig, HUD
- `scripts/camera_rig.gd` — floating camera: fly, orbit, zoom (no player character)
- `scripts/spawner.gd` — shape selection, ghost preview, placement, deletion (on the camera)
- `scripts/main.gd` — HUD wiring
- `tests/smoke.gd` — headless smoke test
