
# DEPENDENCIES
```ox_lib```
# EVENTS

```frmz-metaldetecting:startdetect``` to spawn the detector and start treasures spawn, you can add it in itemuse or whereever you want

```frmz-metaldetecting:startDig``` to dig the treasure, you need to be close enough to the treasure, you can change close distance in config

```frmz-metaldetecting:treasureFound``` do whatever you want when treasure is found, ex: create a mission for it, or give rewards

```frmz-metaldetecting:detectorOverheated``` this event trigger if metal detector overheated

### Edit ```notification()``` function in client/cl_main.lua to notification you want!

### Add `digtool` and `metaldetector` as items for your framework
