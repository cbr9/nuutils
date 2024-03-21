#!/usr/bin/env nu

export def nupower [] {
  let devices = upower -e | lines 
  let device_information = $devices | each {|device| 
    let info = upower -i $device | lines | where (not ($it =~ updated)) | split column ":" | transpose | str trim | headers
    let dropped_columns = $info | columns | where ($it =~ column)
    $info | reject $dropped_columns | rename --block {str replace -a ' ' '-'}
  }

  $device_information | flatten | merge ($devices | wrap "path")
  
}

