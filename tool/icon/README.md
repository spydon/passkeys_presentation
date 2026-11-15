# App icon

`key.svg` is the source of `web/favicon.svg`, `web/favicon.png` and
`web/icons/Icon-*.png`; `key_maskable.svg` is the full bleed variant with the
key inside the maskable safe zone. Re-render after editing:

```sh
for s in 192 512; do
  inkscape tool/icon/key.svg -o web/icons/Icon-$s.png -w $s -h $s
  inkscape tool/icon/key_maskable.svg -o web/icons/Icon-maskable-$s.png -w $s -h $s
done
inkscape tool/icon/key.svg -o web/favicon.png -w 64 -h 64
cp tool/icon/key.svg web/favicon.svg
```
