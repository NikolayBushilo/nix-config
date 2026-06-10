# Template

This is a C23, C++ Template.

## Development cycle

Presets are used for the development cycle only and produce builds
in `/build/{preset}.

```sh
>> cmake --preset debug
```

```sh
>> cmake --preset debug --build
```

```sh
>> cmake --preset release
```

```sh
>> cmake --preset release --build
```

```sh
>> cmake --preset asan
```

## Packaging with nix

```sh
>> nix build
```
Generates a build artifact using a release flag.
