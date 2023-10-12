
# Workaround for Karabiner not loading (known problem)
# https://apple.stackexchange.com/questions/88897/how-do-you-make-the-fn-keyboard-button-work-like-a-ctrl-button
# https://www.nanoant.com/mac/macos-function-key-remapping-with-hidutil
# https://rakhesh.com/mac/using-hidutil-to-map-macos-keyboard-keys/
# https://dchakarov.com/blog/macbook-remap-keys/

# https://manytricks.com/keycodes/
# if you search for these HIDKeyboardModifierMappingSrc and
# 1095216660483 is for the left function key, 30064771300 is Ctrl
# 280379760050179 is for the right function key

# From Karabiner EventViewer: Right Option key => 0x07,0xe6
# From Karabiner EventViewer: Right GUI key => 0x07,0x65
# Consistent with https://developer.apple.com/library/archive/technotes/tn2450/_index.html
# Keyboard Delete Forward => 0x07,0x4c

remapInternalKeyboard(){
  # internal keyboard
  hidutil property --matching '{ "ProductID": 0x027c }' --set '{
    "UserKeyMapping": [
      {
        "HIDKeyboardModifierMappingSrc": 1095216660483,
        "HIDKeyboardModifierMappingDst": 30064771300
      },
      {
        "HIDKeyboardModifierMappingSrc":0x7000000e6,
        "HIDKeyboardModifierMappingDst":0x70000004c
      }
    ]
  }'
  # Microsoft USB keyboard
  hidutil property --matching '{ "ProductID": 0x7a5 }' --set '{
    "UserKeyMapping": [
      {
        "HIDKeyboardModifierMappingSrc":0x700000065,
        "HIDKeyboardModifierMappingDst":0x70000004c
      }
    ]
  }'
}

# List USB devices (includes ProductID)
# system_profiler SPUSBDataType

resetKeyboardMapping(){
  hidutil property --set '{ "UserKeyMapping": [] }'

  # hidutil property --matching '{ "ProductID": 0x027c }' --get "UserKeyMapping"
  # hidutil property --matching '{ "ProductID": 0x7a5 }' --get "UserKeyMapping"
}
if [ "$1" == "reset" ]; then
  resetKeyboardMapping
else
  remapInternalKeyboard
fi
