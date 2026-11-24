# Shape Builder

Automation game prototype. Step 1: the player can create 3D cylinders, spheres, and boxes
("rectangles") in a 3D world.

Built with Godot 4.7 (Forward Plus). Open the project folder in the Godot editor and press F5,
or run:

```sh
godot --path .
```

## Controls

| Input | Action |
| --- | --- |
| `W` `A` `S` `D` | Move |
| `Shift` | Sprint |
| `Space` | Jump |
| Mouse | Look |
| `Esc` | Release / capture cursor |
| `1` / `2` / `3` | Select: Box / Sphere / Cylinder |
| Left click | Place selected shape at crosshair |
| Mouse wheel | Grow / shrink next shape |
| `R` | Rotate next shape 45° |
| Right click | Delete shape under crosshair |

Shapes snap to the surface under the crosshair and align to its normal, with a translucent
ghost preview before placement.

## Development

Headless smoke test (used in CI-style validation, needs a headless-capable Godot binary):

```sh
godot --headless --path . --import
godot --headless --path . -s res://tests/smoke.gd
```

Project layout:

- `scenes/main.tscn` — world: environment, sun, ground, player, HUD
- `scenes/player.tscn` — character body, capsule collider, camera with spawner
- `scripts/player.gd` — first-person movement and mouse look
- `scripts/spawner.gd` — shape selection, ghost preview, placement, deletion
- `scripts/main.gd` — HUD wiring
