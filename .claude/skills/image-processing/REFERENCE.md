# Bun.Image — Full API Reference

Authoritative source: <https://bun.com/docs/runtime/image>. This file is the offline cheat sheet. Update when Bun ships changes.

---

## Construction

```ts
new Bun.Image(input, options?);
Bun.file(path).image();          // shorthand for new Bun.Image(Bun.file(path))
Bun.s3("bucket/key").image();    // S3File input
```

### Accepted inputs

- Path string (treated as a **filesystem path** — never pass user-controlled strings directly)
- `Buffer`, `ArrayBuffer`, `TypedArray` (don't mutate while a terminal is pending; decode runs off-thread and borrows the bytes)
- `Blob`, `BunFile`, `S3File`
- `Blob#image()` is shorthand for `new Bun.Image(blob)`

`SharedArrayBuffer` and resizable buffers are **refused** — use `buf.slice()` for a fixed view.

Format is sniffed from the bytes; file extension and `Content-Type` are ignored.

### Constructor options

```ts
new Bun.Image(input, {
  // Reject if width*height > this. Checked after reading the header,
  // before allocating the pixel buffer. Default ~268 MP (matches sharp).
  maxPixels: 4096 * 4096,
  // Apply JPEG EXIF Orientation before any other op. Default: true.
  autoOrient: true,
});
```

---

## Metadata (no pixel decode)

```ts
const { width, height, format } = await new Bun.Image(input).metadata();
// => { width: 1920, height: 1080, format: "jpeg" }
```

Reads only the header. Useful for validation before committing to a full decode.

---

## Resize

```ts
img.resize(800);                                  // width 800, keep aspect ratio
img.resize(800, 600);                             // exactly 800×600 (stretch)
img.resize(800, 600, { fit: "inside" });          // fit within 800×600
img.resize(800, 600, { withoutEnlargement: true }); // never upscale
img.resize(800, 600, { filter: "mitchell" });
```

### `fit`

| Value | Behavior |
|-------|----------|
| `"fill"` (default) | Stretch to exactly `width × height` |
| `"inside"` | Preserve aspect ratio; result fits *within* the box |

### `filter` (resampling kernel)

| Filter | Use when |
|--------|----------|
| `"lanczos3"` (default) | General-purpose, sharpest for photos |
| `"lanczos2"` | Slightly softer, fewer ringing artifacts |
| `"mitchell"` | Smooth gradients; classic bicubic compromise |
| `"cubic"` | Catmull-Rom — sharper than Mitchell, can ring |
| `"mks2013"` / `"mks2021"` | "Magic Kernel Sharp"; used by Facebook/Instagram |
| `"bilinear"` / `"linear"` | Fast, soft |
| `"box"` | Area-average; good for large integer downscales |
| `"nearest"` | Pixel art / hard edges |

### Performance fast path

When the source is JPEG and the target is **≤ half the source size**, decode skips straight to the nearest M/8 IDCT scale. Generating a thumbnail from a 24 MP photo never materializes the full-resolution buffer.

---

## Rotate / flip

```ts
img.rotate(90);  // multiples of 90 only (90, 180, 270, …)
img.flip();      // mirror vertically (about the x-axis)
img.flop();      // mirror horizontally (about the y-axis)
```

---

## Modulate

```ts
img.modulate({
  brightness: 1.2, // 1 = unchanged, >1 brighter, <1 darker
  saturation: 0,   // 0 = greyscale, 1 = unchanged, >1 = boost
});
```

---

## Output formats

Calling a format method sets the encode target. Without one, the source format is reused.

```ts
img.jpeg({ quality: 85 });                       // 1–100, default 80
img.jpeg({ progressive: true });                 // progressive JPEG (coarse-to-fine)
img.png({ compressionLevel: 6 });                // zlib level 0–9
img.png({ palette: true, colors: 64, dither: true }); // indexed PNG (color-type 3) + Floyd–Steinberg dither
img.webp({ quality: 80 });
img.webp({ lossless: true });
img.heic({ quality: 80 });                       // macOS / Windows only
img.avif({ quality: 60 });                       // macOS / Windows only; encode needs Apple Silicon M3+
```

### When to pick which format

| Goal | Format |
|------|--------|
| Photographs, broad browser support | `webp` (quality 70–85) |
| Maximum compression, modern clients | `avif` (smaller than webp, slower encode) |
| Screenshots, UI, line art, < 256 colors | `png({ palette: true, … })` |
| Apple ecosystem, large photos | `heic` |
| Legacy fallback | `jpeg` |

---

## Terminals (awaitable)

| Method | Returns |
|--------|---------|
| `await img.bytes()` | `Uint8Array` |
| `await img.buffer()` | `Buffer` |
| `await img.blob()` | `Blob` with `.type` set to the output MIME |
| `await img.toBase64()` | `string` |
| `await img.dataurl()` | `"data:image/png;base64,…"` |
| `await img.write(dest)` | `number` (bytes written) — accepts path string, `Bun.file()`, `Bun.s3()`, or an fd |
| `await img.metadata()` | `{ width, height, format }` (header-only, no full decode) |
| `await img.placeholder()` | LQIP `data:` URL (ThumbHash, ≤32px, ~400–700 bytes) |

After the first terminal resolves, `img.width` and `img.height` reflect the **output** dimensions (they're `-1` before).

When `.write(path)` is called **without a format method**, the path extension picks one (`.jpg` / `.png` / `.webp` / `.heic` / `.avif`).

---

## LQIP batch pattern

Generate placeholders for every image in a directory and emit a JSON map you can `import` from your app:

```ts
import { Glob } from "bun";
const placeholders: Record<string, string> = {};
for await (const path of new Glob("**/*.{jpg,jpeg,png,webp}").scan("./public/images")) {
  placeholders[path] = await Bun.file(`./public/images/${path}`).image().placeholder();
}
await Bun.write("./placeholders.json", JSON.stringify(placeholders, null, 2));
```

Then in your app: import the map and apply each entry as a `background-image: url(...)` while the real image loads. The placeholder is a base64 `data:` URL so no extra network request is needed.

For coarse-to-fine rendering of the **image itself** (not a separate placeholder), encode a progressive JPEG: `.jpeg({ progressive: true })`.

---

## `Bun.serve` integration

A `Bun.Image` pipeline is a valid `Response` body and sets `Content-Type` automatically. To keep the encode off the JS thread, **await a terminal first**:

```ts
Bun.serve({
  routes: {
    "/avatar/:id": async req => {
      // Validate user input before touching the filesystem.
      if (!/^[a-z0-9]+$/.test(req.params.id)) return new Response(null, { status: 400 });
      const out = await Bun.file(`avatars/${req.params.id}.png`).image().resize(128, 128).webp().blob();
      return new Response(out);
    },
  },
});
```

Passing the pipeline directly (`new Response(img)`) works but currently runs the encode **synchronously** during body init. Await a terminal for production handlers.

---

## Clipboard (macOS / Windows)

```ts
const img = Bun.Image.fromClipboard();
if (img) {
  const png = await img.resize(800, 800, { fit: "inside" }).png().bytes();
}
```

`fromClipboard()` reads PNG, TIFF, HEIC, JPEG, WebP, GIF, or BMP from the system pasteboard. Returns `null` if there's no image, and **always `null` on Linux** — shell out to `wl-paste` / `xclip` and pass the bytes to the constructor.

For a passive "image in clipboard, press ⌘V" hint, poll `clipboardChangeCount()` (a single integer read) and call `hasClipboardImage()` only when it moves. macOS has no clipboard-change notification, so this is the documented pattern.

---

## Platform backends

| | Linux | macOS | Windows |
|-|-------|-------|---------|
| JPEG / PNG / WebP | libjpeg-turbo · spng · libwebp | same | same |
| BMP / GIF (decode) | built-in | ImageIO | WIC |
| TIFF (decode) | ❌ | ImageIO | WIC |
| Resize / rotate / flip | Highway SIMD | Accelerate vImage | Highway SIMD |
| HEIC / AVIF | ❌ `ERR_IMAGE_FORMAT_UNSUPPORTED` | ImageIO ² | WIC ¹ |
| Clipboard | ❌ returns `null` | NSPasteboard | Win32 |

¹ Windows requires **HEIF Image Extensions** / **AV1 Video Extension** from the Microsoft Store.
² AVIF *encode* needs an OS AV1 encoder — Apple Silicon M3+ only. Intel Mac and M1/M2 reject with `ERR_IMAGE_FORMAT_UNSUPPORTED`. AVIF *decode* works everywhere ImageIO does (macOS 13+).

JPEG / PNG / WebP go through the same statically-linked codecs on every platform — **encoded output is byte-identical** across Linux, macOS, and Windows.

### Force the portable backend for golden-image tests

```ts
Bun.Image.backend = "bun"; // default is "system" on macOS/Windows
```

### Fallback when a format isn't supported

```ts
const out = await img
  .avif({ quality: 50 })
  .bytes()
  .catch(e => {
    if (e.code === "ERR_IMAGE_FORMAT_UNSUPPORTED") return img.webp({ quality: 80 }).bytes();
    throw e;
  });
```

---

## Security checklist

- Never pass user-controlled path strings directly to the constructor — that's an arbitrary-file-read primitive. Read untrusted input into a `Buffer` (via `fetch` / `Bun.file` with your own validation) and pass the bytes.
- Always set `maxPixels` to the largest legitimate input for your app. Bigger uploads should be rejected at the header-read stage before any pixel buffer is allocated.
- Validate route params and form fields with a regex before building filesystem paths.
- For uploads, call `.metadata()` first to verify dimensions and format before committing to a full decode.

---

## When NOT to use `Bun.Image`

- **Plain Node.js project**: stick with `sharp`. Don't switch runtimes just for image processing.
- **GIF / TIFF encoding**, animated WebP/AVIF, color-profile manipulation, vector formats (SVG): not supported. Use `sharp` or a dedicated tool.
- **EXIF data extraction beyond orientation**: not exposed. Use a metadata library (`exifr`, etc.).
- **Linux + HEIC/AVIF**: not supported. Use WebP, or shell out to `libheif`.

---

## Version pinning

`Bun.Image` shipped in **Bun 1.3.14**. Pipelines may gain options in later releases — when in doubt, fetch fresh docs via the `context7` skill (`/oven-sh/bun`) or visit <https://bun.com/docs/runtime/image>.
