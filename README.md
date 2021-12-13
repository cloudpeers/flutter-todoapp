# flutter todoapp built with tlfs

[![Codemagic build status](https://api.codemagic.io/apps/61acd64d3f5cef2c891fe020/61acd64d3f5cef2c891fe01f/status_badge.svg)](https://codemagic.io/apps/61acd64d3f5cef2c891fe020/61acd64d3f5cef2c891fe01f/latest_build)

## Download tlfs and tlfsc

To update tlfs or tlfsc run

```sh
dart run tlfs:download_tlfs
```

## Build schema

Whenever the schema is changed in `assets/todoapp.tlfs`, it needs to be recompiled using
the `bin/build_schema.dart` script.

```sh
dart run tlfs:build_schema
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

## Add tlfs to ios build

Create a new plugin or copy `packages/tlfs_ios`. Symlink the static library

```sh
ln -s build/tlfs/ios/libtlfs.a packages/tlfs_ios/ios/libtlfs.a
```

and add it to the podspec file.

```
  s.static_framework = true
  s.vendored_libraries = '**/*.a'
```

and finally add the plugin to your dependencies

```yaml
dependencies:
  tlfs_ios:
    path: packages/tlfs_ios
```


## License
Apache-2.0 OR MIT
