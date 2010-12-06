'''Runs an mxmlc compile in a subprocess and sends errors back to vim as they're printed

Add background_mxmlc_compile.vim to ~/.vim/plugin and add the following to your .vimrc:

set errorformat=%f(%l):\ col:\ %c\ %m
function! BackgroundBuild()
    silent !python <path to background_mxmlc_compile.py> <compile command> &
    echo "Building!"
endfunction
command! -nargs=* BackgroundBuild call BackgroundBuild()
map <F5> :BackgroundBuild()<CR>

That runs the build whenever you press F5.  If there are any errors, they'll be in the location
list.

'''
import re, signal, subprocess, sys, time
start = time.time()
def log(msg):
    print "%s %s" % (time.strftime('%Y-%m-%d %H:%M:%S'), msg)
log("Starting")
def executeInVim(cmd):
    log("Running expr in vim : %s" % cmd)
    return subprocess.Popen(['mvim', '--remote-expr', cmd])
err = re.compile(".*: col: \d+ (?:Error|Warning):(.*)")
build = subprocess.Popen(sys.argv[1], stderr=subprocess.STDOUT, stdout=subprocess.PIPE)
sender = None
queue = []
first = None
def createQueueList():
    global queue
    list = '["%s"]' % '", "'.join(queue)
    queue = []
    return list

errors = 0
while build.poll() is None:
    line = build.stdout.readline()[:-1]
    m = err.match(line)
    if m:
        errors += 1
        if sender is None:
            first = line
            sender = executeInVim('BackgroundSetFirstError("%s")' % line)
        else:
            queue.append(line)
            if sender.poll() is not None:
                sender = executeInVim("BackgroundAddErrors(%s)" % createQueueList())

if build.returncode == 230:
    msg = "mxmlcserver isn't running"
elif errors > 0:
    msg = 'Compile had %s error' % errors
    if errors > 1:
        msg += "s"
    msg += ": %s" % first
else:
    msg = 'Compile succeeded and took %.2f seconds' % (time.time() - start)
executeInVim('BackgroundFinish("%s" , %s)' % (msg, createQueueList()))
