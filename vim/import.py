'''Vim script that pulls classes and packages out of the tags file, and checks for the word under
the cursor being a class there.  If it is and there's only one entry for it, that class is added as
an import at the top of the file.  If there are no entries, it prints a message to that effect.  If
there are multiple entries, it prints all of them if g:importIdx isn't set, or imports the entry at
that number if it is.

Link this into your .vim directory, and add something like the following to your .vimrc to activate
it:

function! Import(idx)
    let g:importIdx=a:idx
    pyfile ~/.vim/import.py
endfunction
command! -nargs=* Import call Import(<q-args>)

nmap ;i :pyfile ~/.vim/import.py<CR>

That snippet makes it try to import the current word if you type ";i" in normal mode, and imports a
given index with ":Import <idx>"

If your ctags doesn't produce package entries for actionscript by default, you can add the following
to your ~/.ctags file to get it to do so:
--langdef=actionscript
--langmap=actionscript:.as
--regex-actionscript=/^[ \t]*package[ \t]+([A-Za-z0-9_.]+)[ \t]*/\1/a,package,packages/
--regex-actionscript=/^[ \t]*[(override| )(private| public|static) ( \t)]*function[ \t]+([A-Za-z0-9_]+)[ \t]*\(/\1/f,function,functions/
--regex-actionscript=/^[ \t]*[(public) ]*function[ \t]+(set|get)[ \t]+([A-Za-z0-9_]+)[ \t]*\(/\1 \2/p,property,properties/
--regex-actionscript=/^[ \t]*(private|public|protected)[ \t]*(static)?[ \t]+(var|const)[ \t]+([A-Za-z0-9_]+)[ \t]*/\4/v,variable,variables/
--regex-actionscript=/.*\.prototype \.([A-Za-z0-9 ]+)=([ \t]?)function( [ \t]?)*\(/\1/f,function,functions/
--regex-actionscript=/^[ \t]*(private|public|protected) .*(class|interface)[ \t]+([A-Za-z0-9_]+)[ \t]*/\3/c,class,classes/

For classes in swc or asdocs that aren't in the tags file, you can use extract_flash_classes.py in
this directory to build an index for them.  Set g:importsPickle in your .vimrc to point the importer
to the index eg 'let g:importsPickle="/Users/groves/.vim/import.pickle"'  Read the docs in
extract_flash_classes.py to learn how to make pickles.

'''
import cPickle, os, re, sys, vim

# Handle set not being a builtin prior to 2.4
import __builtin__
if not hasattr(__builtin__, 'set'):
    import sets
    __builtin__.set = sets.Set

vim.command('let startpos = getpos(".")') # get where we were before we do anything
vim.command("normal wbyw") # pull the word under the cursor into the default register
classname = vim.eval("getreg()").strip()

# Makes groups for the package or class name, the filename and the type(c for class, a for package)
package_or_class = re.compile('^([\w\.]+)\s+(.+)\s/\^.*(c|a)$', re.MULTILINE)
fn_to_package = {}
class_to_fn = {}
for tagfile in [fn for fn in vim.eval("&tags").split(',') if os.path.exists(fn)]:
    for m in package_or_class.finditer(open(tagfile).read()):
        if m.group(3) == 'a':
            fn_to_package[m.group(2)] = m.group(1)
        else:
            if not m.group(1) in class_to_fn:
                class_to_fn[m.group(1)] = []
            class_to_fn[m.group(1)].append(m.group(2))


importstatement = lambda full: "import %s;" % (full)
def addimport(full):
    vim.command("let ignored=cursor(0, 0)")# Search for package from the beginning
    vim.command("let packageline = search('^package ', 'c')")
    vim.command('let ignored=append(packageline, "%s")' % importstatement(full))

# It's totally great how vim returns everything as a string and uses 0 to indicate false
varset = lambda var: bool(int(vim.eval('exists("%s")' % var)))

idxset = varset("g:importIdx")
if varset("g:importsPickle"):
    pickled = cPickle.load(open(vim.eval("g:importsPickle")))
else:
    pickled = {}
fulls = pickled.get(classname, set())
fulls.update(['%s.%s' % (fn_to_package[fn], classname) for fn in class_to_fn.get(classname, [])])
fulls = list(fulls)
fulls.sort()# Sort the names to keep them in the same order for selecting amongst multiple
if len(fulls) == 0:
    print "No classes found for", classname
elif len(fulls) == 1:
    addimport(fulls[0])
else:
    if not idxset:
        print "Multiple classes found for", classname
        for idx, full in enumerate(fulls):
            print idx + 1, importstatement(full)
    else:
        addimport(fulls[int(vim.eval("g:importIdx")) - 1])
if idxset:
    vim.command("unlet g:importIdx")
# always move the cursor back
vim.command("let ignored=cursor(startpos[1] + 1, startpos[2])")
