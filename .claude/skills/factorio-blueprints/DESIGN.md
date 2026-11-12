# Design for the actual transfer limits

## Production

Nominal recipes per second = machine crafting speed / recipe time. Multiply by each ingredient and product amount. State an average for randomized yields. Check belts, inserters, pipes, mining, electricity, and destination capacity separately.

Two yellow loading inserters may be needed even when one looks sufficient. A shared output inserter can limit several otherwise balanced machines. Prefer direct output chests for a small starter if a common belt creates a transfer bottleneck. Measure actual collected output before promising a rate.

Keep construction inputs distinct from operating inputs. For example, glass builds a greenhouse; water and electricity run its basic wood recipe.

## Placement and orientation

- Derive footprint from the installed prototype. Odd-sized machines normally have half-integer centers; even-sized machines have integer centers.
- In Factorio 2.x, cardinal directions are north=0, east=4, south=8, west=12. Earlier blueprint versions differ.
- Standard inserters pick up in their facing direction and drop on the opposite side. Check runtime pickup/drop positions rather than guessing from the arm drawing.
- A splitter divides belts, not arbitrary percentages. Use output priority for fuel or another essential consumer when requested.
- Force intended side-loading junctions to stay straight. Test which lane contains each item.
- Serialize copper connections. For the tested 2.x format, top-level `wires` entries contain `[entity_number, connector_id, entity_number, connector_id]`; pole copper connector ID is 5. Verify this for other versions.
- Poles need both valid wire connections and coverage of every inserter and electric machine.
- Respect fluid ports and underground connection limits. Do not mix unlike fluids in one network.

## Expansion

Keep a stable anchor, input ports, output collection, and wire backbone. Let new machines extend into reserved empty ground.

`compare` checks that starter entities, settings, and normalized wire edges remain in the expansion. It reports additions and port coordinates. It does not prove fluid connection or throughput correctness.

Blueprint variants with different bounding boxes can have different cursor centers. Tell the user to align the machine anchor, not to click the same cursor location. Keep the same rotation. Include separate diagrams when ghost additions make the explanation unclear.

If the same row cannot extend without starving, document its maximum tested capacity and replicate the module after that point. Do not call it indefinitely tileable.

## Encoding and previews

Pack the wrapping `blueprint` or `blueprint_book` object as JSON, zlib-compress, base64-encode, and prepend `0`. Encode the version as `(major << 48) | (minor << 32) | (patch << 16) | build`.

Keep uncompressed JSON for edits. Decode the final string and compare the object before delivery. Summarize items from the final entities, not a handwritten bill of materials.

Draw diagrams from those same entities. A schematic should use true tile dimensions and clearly distinguish starter entities from additions. Do not present it as an in-game screenshot. Verify the rendered image is not cropped; Quick Look's SVG thumbnails can crop wide diagrams into a square.
