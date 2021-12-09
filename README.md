# flutter todoapp built with tlfs

## Download tlfs and tlfsc

To update tlfs or tlfsc run

```sh
dart run bin/download_tlfs.dart
```

## Build schema

Whenever the schema is changed in `assets/todoapp.tlfs`, it needs to be recompiled using
the `bin/build_schema.dart` script.

```sh
dart run bin/build_schema.dart
```

## Add compiled schema as an asset
```yaml
flutter:
  assets:
  - assets/todoapp.tlfs.rkyv
```

## Add tlfs to linux build

```
install(FILES "../build/tlfs/linux/libtlfs.so" DESTINATION "${INSTALL_BUNDLE_LIB_DIR}"
  COMPONENT Runtime)
```

## Add tlfs to android build

```sh
mkdir -p android/app/src/main/jniLibs/arm64-v8a
ln -s build/tlfs/android/libltfs.so android/app/src/main/jniLibs/arm64-v8a/libtlfs.so
```

## License
Apache-2.0 OR MIT
