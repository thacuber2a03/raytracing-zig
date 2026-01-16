psst, if you're in GitHub, this repository is [mirrored from Codeberg](https://codeberg.org/thacuber2a03/raytrazig)

---

# raytrazig

the Raytracing series of books implemented in Zig 0.15.2.

currently following Raytracing the Next Week, output is right after finishing checkered textures

![screenshot of output PPM file](./meta/book_demo.png)

### features

- CLI to check the demos out and mess with them; no load-from-config-file yet, might do that eventually
- multi-threaded tiled rendering, allows configuring number of cores used
- can output directly to a file; no need to redirect
