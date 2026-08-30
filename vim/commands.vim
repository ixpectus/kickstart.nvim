let lastTestCommand=""


function EmptyIfZero(arg)
  if a:arg ==# '0'
    return ""
  endif
  return a:arg
endfunction

function CmdGitFileTopContributors()
  let fileName = expand("%:p")
  let cmd = "git log " . fileName . " | grep Author | sd '.*<(.+)>' '$1' | sort | uniq -c | sort -gr"
  execute ":R ".cmd
endfunction
function CmdGitProjectTopContributors()
  let fileName = expand("%:p")
  let cmd = "git log | grep Author | sd '.*<(.+)>' '$1'  | sort | uniq -c | sort -gr"
  execute ":R ".cmd
endfunction
function CmdGitFileTopContributorsRecent()
  let fileName = expand("%:p")
  " let cmd = "git log " . fileName . " | grep Author | sed -E 's/.+<(.+)>/\\1/g' | sort | uniq -c | sort -gr"
  let cmd = "git log " . fileName . " | grep Author | sd '.*<(.+)>' '$1' | sort | uniq -c | sort -gr"
  execute ":R ".cmd
endfunction
function CmdGitProjectTopContributorsRecent()
  let fileName = expand("%:p")
  let cmd = "git log --since '6 month ago' | grep Author | sd '.*<(.+)>' '$1'  | sort | uniq -c | sort -gr"
  execute ":R ".cmd
endfunction



function! System(cmd)
  return substitute(system(a:cmd), '\n', '', 'g')
endfunction
function CmdGetProjectDir()
  let root = split(system('git rev-parse --show-toplevel'), '\n')[0]
  return v:shell_error ? '' : root
endfunction
function CmdGetProjectName()
  let projectDir = CmdGetProjectDir()
  if projectDir == ""
    let projectDir = expand("%:p")
  endif
  let projectPath = projectDir[:-1]
  let pp = split(projectPath, "/")
  let projectName = pp[-1]
  return projectName
endfunction
function CmdGetCurrentTestName() 
  let fileName = expand("%:p")
  let lineNumber = line(".")
  let cmd = "cat ".fileName." | head -n ".lineNumber." | grep 'func Test' | sed -E 's/func ([^\\(]+)\\(.+/\\1/g' | tail -n1"
  let testName = System(cmd)
  return testName
endfunction
function CmdGetTableTestName() 
  let fileName = expand("%:p")
  let lineNumber = line(".")
  let cmd = "cat ".fileName." | head -n ".lineNumber." | tail -n 1 | sed -E 's/.+\"(.+)\".+/\\1/'"
  let testName = System(cmd)
  return testName
endfunction
function CmdGetFirstTestName() 
  let fileName = expand("%:p")
  let lineNumber = line(".")
  let cmd = "cat ".fileName." | grep 'func Test' | head -n1 | sed -E 's/func ([^\\(]+)\\(.+/\\1/g'"
  let testName = System(cmd)
  return testName
endfunction
function CmdRunTest() 
  let testName = CmdGetCurrentTestName()
  let fileNameRelative = expand("%:p:h")
  if testName == ""
    let testCommand = "go test -v " . fileNameRelative . " -count=1 "
  else
    let testCommand = "go test -v " . fileNameRelative . " -count=1 -run ".testName
  endif
  let g:lastTestCommand = testCommand
  execute ':R '.testCommand
endfunction
function CmdRunTableTest() 
  let testName = CmdGetCurrentTestName()
  let fileNameRelative = expand("%:p:h")
  let tableTestName = CmdGetTableTestName()
  let testCommand = "go test -v " . fileNameRelative . " -count=1 -run ".testName."/".tableTestName."$"
  let g:lastTestCommand = testCommand
  execute ':R '.testCommand
endfunction
function CmdRunLastTest()
  execute ':R '.g:lastTestCommand
endfunction 
function CmdGoMoqGenerate()
  let fileName = expand("%:p")
  let cmd = "cat " . fileName . " | grep -E 'type.+interface' | sed -E 's/type ([^ ]+).+/\\1:\\u\\1Moq/g' | paste -sd ' '"
  let res = System(cmd)
  let cmd = "//go:generate moq -stub -out mock.go . " . res
  execute ":call system('xclip -selection clipboard', '" . cmd . "')"
endfunction

function CmdBlameTask()
 let cmd = 'git show $(git blame -L' . line(".") . ',' . line(".") . ' ' . expand("%") ." | awk '{print $1}') | grep -E '[A-Z]+\-[0-9]+' | head -n1 | sed -E 's/([A-Z]+\-[0-9]+).+/\\1/g' | sed 's/ //g'"
 let task = System(cmd)
 let url = $TASK_TRACKER . task
 :execute ':!firefox ' . url
endfunction


command! -nargs=? -complete=command CmdBlameTask call CmdBlameTask()
command! -nargs=? -complete=command CmdGitFileTopContributors call CmdGitFileTopContributors()
command! -nargs=? -complete=command CmdGitProjectTopContributors call CmdGitProjectTopContributors()
command! -nargs=? -complete=command CmdGitFileTopContributorsRecent call CmdGitFileTopContributorsRecent()
command! -nargs=? -complete=command CmdGitProjectTopContributorsRecent call CmdGitProjectTopContributorsRecent()
command! -nargs=* CmdRunTest call CmdRunTest(<f-args>)
command! -nargs=* CmdRunLastTest call CmdRunLastTest(<f-args>)
command! -nargs=* CmdRunTableTest call CmdRunTableTest(<f-args>)


nmap <Leader>ft :CmdRunTest<Cr>
nmap <Leader>rtt :CmdRunTableTest<Cr>
nmap <Leader>xx :Exec<Cr>
nmap <Leader>xq :ScratchClose<Cr>

augroup OpenAllFoldsOnFileOpen
    autocmd!
    autocmd BufRead * normal zR
augroup END
