let lastTestCommand=""


function EmptyIfZero(arg)
  if a:arg ==# '0'
    return ""
  endif
  return a:arg
endfunction

function CmdGoGenerateCurDir()
  let dirName = expand("%:h")
  let cmd = "export BINPATH=$(pwd)/bin;export PATH=$BINPATH:$PATH; cd ./" . dirName. " && rm -f mock.go && go generate"
  :call system(cmd)
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
function! CmdMineRedir(cmd)
  execute(":set splitbelow")
  new
  let w:scratch = 1
  setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile
  execute ':0read ! ' .a:cmd
endfunction
function! CmdMineLua(cmd)
  execute(":set splitbelow")
  new
  let w:scratch = 1
  setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile
  execute ':0read lua ' .a:cmd
endfunction
function CmdYankHistory()
  execute ":R cat ~/.vim/yank_history.txt"
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
function GetStashPath()
  let path = split(system('git remote -v | grep fetch | sed -E "s/.+\/([^\/]+)\/([^\/]+)\.git.+/http:\/\/stash.msk.avito.ru\/projects\/\1\/repos\/\2\/browse\//g"'), '\n')[0]
  return v:shell_error ? '' : path
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
function CmdOpenStashRoot()
 :execute ':!firefox ' . GetStashPath()
endfunction

function CmdOpenStashFile()
 :execute ':!firefox ' . GetStashPath() . expand("%") . '\#' . line(".")
endfunction

function CmdBlameTask()
 let cmd = 'git show $(git blame -L' . line(".") . ',' . line(".") . ' ' . expand("%") ." | awk '{print $1}') | grep -E '[A-Z]+\-[0-9]+' | head -n1 | sed -E 's/([A-Z]+\-[0-9]+).+/\\1/g' | sed 's/ //g'"
 let task = System(cmd)
 let url = 'https://jr.avito.ru/browse/' . task
 :execute ':!firefox ' . url
endfunction

function CmdRunCurrentScript(...)
  let ftype = expand('%:e')
  let fileName = expand("%:p")
  if ftype == "go"
    execute ":R go run ".fileName
    return
  endif
  let tmpfile = tempname()
  let arg1 = EmptyIfZero(get(a:, 1))
  let arg2 = EmptyIfZero(get(a:, 2))
  let arg3 = EmptyIfZero(get(a:, 3))
  execute ':set splitright | :vsplit '.tmpfile
  execute ':0read ! sh '.fileName.' '.arg1.' '.arg2.' '.arg3
  execute ':w'
  execute ':set filetype=json'
endfunction
function CmdRunAnyScript(cmd)
  let tmpfile = tempname()
  let fileName = expand("%:p")
  execute ':set splitright | :vsplit '.tmpfile
  execute ':0read ! ' .a:cmd
  execute ':w'
endfunction
function CmdRunMarkmap(...)
  execute ':! markmap -w '.expand("%:p")
endfunction
function CmdFormatCurl()
  execute ':%s/curl /curl -Ssk /g' 
  execute ':%s/\v-H /\\\r    -H /g' 
  execute ':%s/\v-X /\\\r    -X /g' 
  execute ':%s/\v-d /\\\r    -d /g' 
  " execute ':%s/\v http/\\\r http/g' 
endfunction
function RevertCurl()
  execute ':%s/^[ ]*-/-/g'
  execute ':%s/\\\n/ /g'
endfunction
function CmdMvCurrentDir()
 " :help rename-files
 let tmpfile = tempname()
 execute ':set splitright | :vsplit '.tmpfile
 execute ':r !ls'
 execute ':g/^$/d'
 execute '%s/.*/mv & &/'
 " gl is a shortcut from https://github.com/tommcdo/vim-lion
 normal ggVGgl 
 execute ':w'
endfunction

function CmdMvFileDir()
 " :help rename-files
 let tmpfile = tempname()
 let currentPath = expand("%:h")
 execute ':set splitbelow | :split '.tmpfile
 execute ':r !find ./ -type f | grep -v .git | grep -v .idea | grep '.currentPath
 " execute ':r !find ./ -type f | grep -v .git | grep -v .idea | grep '.currentPath
 execute ':g/^$/d'
 execute '%s/.*/mv & &/'
 " gl is a shortcut from https://github.com/tommcdo/vim-lion
 normal ggVGgl 
 execute ':w'
endfunction

function CmdFormatBrief()
  :call system("brief rpc fmt -w " . expand("%:p"))
  :e
endfunction

function CmdFormatFennel()
  :call system("fnlfmt --fix " . expand("%:p"))
  :e
endfunction

function CmdFormatGci()
  :call system("brief rpc fmt -w " . expand("%:p"))
  :e
endfunction

function CmdShowLastProjectFiles()
 let historyFileName=v:lua.history.projectFileHistoryName()
 :execute ":call fzf#run(fzf#wrap({'source':'cat ".historyFileName."', 'sink':'e'}))"
endfunction

function CmdShowLastProjectFiles2()
 let historyFileName=v:lua.hello.projectFileHistoryName()
 :execute ":call fzf#run(fzf#wrap({'source':'cat ".historyFileName."', 'sink':'e'}))"
endfunction

command! -nargs=? -complete=command CmdOpenStashRoot call CmdOpenStashRoot()
command! -nargs=? -complete=command CmdGoRunInTerm call CmdGoRunInTerm()
command! -nargs=? -complete=command CmdOpenStashFile call CmdOpenStashFile()
command! -nargs=? -complete=command CmdBlameTask call CmdBlameTask()
command! -nargs=? -complete=command CmdGitFileTopContributors call CmdGitFileTopContributors()
command! -nargs=? -complete=command CmdGitProjectTopContributors call CmdGitProjectTopContributors()
command! -nargs=? -complete=command CmdGitFileTopContributorsRecent call CmdGitFileTopContributorsRecent()
command! -nargs=? -complete=command CmdGitProjectTopContributorsRecent call CmdGitProjectTopContributorsRecent()
command! -nargs=1 -complete=command R call CmdMineRedir(<q-args>)
command! -nargs=1 -complete=command L call CmdMineLua(<q-args>)
command! -nargs=1 -complete=command GetStashPath call GetStashPath()
command! -nargs=? -complete=command CmdYankHistory call CmdYankHistory()
command! -nargs=* Exec call CmdRunCurrentScript(<f-args>)
command! -nargs=* CmdRunTest call CmdRunTest(<f-args>)
command! -nargs=* CmdRunLastTest call CmdRunLastTest(<f-args>)
command! -nargs=* CmdRunTableTest call CmdRunTableTest(<f-args>)
command! -nargs=* Markmap call RunMarkmap(<f-args>)


nmap <Leader>ft :CmdRunTest<Cr>
nmap <Leader>rtt :CmdRunTableTest<Cr>
nmap <Leader>x :Exec

" nmap <Leader>mr :R make run<Cr>
" nmap <Leader>mt :R make test<Cr>


autocmd BufWritePost *.brief call CmdFormatBrief()
autocmd BufWritePost *.fennel call CmdFormatFennel()
autocmd BufWritePost *.fnl call CmdFormatFennel()

augroup OpenAllFoldsOnFileOpen
    autocmd!
    autocmd BufRead * normal zR
augroup END
