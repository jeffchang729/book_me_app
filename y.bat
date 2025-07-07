@echo off
call flutter clean
call flutter pub get
call call flutter run -d chrome
