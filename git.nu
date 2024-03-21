export def gl [] {
  git log --pretty=%h»¦«%s»¦«%aN»¦«%aE»¦«%aD -n 25 | lines | split column "»¦«" commit subject name email date | upsert date {|d| $d.date | into datetime} | sort-by --reverse date
}

export def gs [
  --ignored
] {
  let lines = git status --short --ignored | lines | str trim | split column " " | rename status file
  let staged =  $lines | where status == "MM" | reject status | insert staged true | insert modified true | insert tracked true | insert ignored false | sort-by --reverse file | upsert file {|f| $'(ansi green)($f.file)'}
  let modified = $lines | where status == "M" | reject status | insert staged false | insert modified true | insert tracked true | insert ignored false | sort-by --reverse file | upsert file {|f| $'(ansi red)($f.file)'}
  let untracked = $lines | where status == "??" | reject status | insert staged false | insert modified false | insert tracked false | insert ignored false | sort-by --reverse file | upsert file {|f| $'(ansi red)($f.file)'} 
  let ignored_files = $lines | where status == "!!" | reject status | insert staged false | insert modified false | insert tracked false | insert ignored true | sort-by --reverse file | upsert file {|f| $'(ansi red)($f.file)'}
  
  let result = [
    ...$staged,
    ...$modified,
    ...$untracked,
  ]

  if $ignored {
    $result | append $ignored_files
  } else {
    $result | reject ignored
  }

}
