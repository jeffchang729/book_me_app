@echo off
call flutter clean
call flutter pub get
call flutter run -d emulator-5554