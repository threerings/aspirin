# Majority of the functionality of the aspirin plugin. It's out in its own module to namespace it
# from Vim's shared Python interpreter
import cPickle, os, re, sys, subprocess, time, vim, zipfile
from xml.etree import ElementTree

def jump(classname):
    found = lookup(classname)
    if found:
        if found[1].endswith('.html'):
            subprocess.check_call(['open', found[1]])
        else:
            vim.command("edit " + found[1])

def addimport(classname):
    found = lookup(classname)
    if found:
        vim.command("let ignored=cursor(0, 0)")# Search for package from the beginning
        vim.command("let packageline = search('^package ', 'c')")
        vim.command('let ignored=append(packageline, "import %s;")' % found[0])
        vim.command("let ignored=cursor(s:startpos[1] + 1, s:startpos[2])")

last_lookup_paths = []
classname_to_full = {}
def lookup(classname):
    global last_lookup_paths
    if not bool(int(vim.eval('exists("g:as_locations")'))):
        print "Set 'g:as_locations' to a list of as paths"
        return None
    locs = vim.eval("g:as_locations")
    if not classname in classname_to_full or last_lookup_paths != locs:
        scan(locs)
        last_lookup_paths = locs
    fulls = sorted(classname_to_full.get(classname, set()))
    if len(fulls) == 0:
        print "No classes found for '%s'" % classname
        return None

    if len(fulls) == 1:
        idx = "1"
    else:
        print "Multiple classes found for", classname
        for idx, full in enumerate(fulls):
            print idx + 1, full[0]
        vim.command('let idx=input("Class number or blank to abort: ")')
        idx = vim.eval("idx").strip()
        if not idx:
            return None
    return fulls[int(idx) - 1]

def scan(locs):
    begin = time.time()
    classname_to_full.clear()
    for path in locs:
        path = os.path.expanduser(path)
        if path.endswith('all-classes.html'):
            addclasses(scan_asdoc_allclasses(path))
        elif path.endswith('package-detail.html'):
            addclasses(scan_asdoc_package(path))
        elif path.endswith('.swc'):
            addclasses(scan_swc(path))
        elif os.path.isdir(path):
            addclasses(scan_dir(path))
        else:
            print "Don't know how to handle", path

def addclasses(classes):
    for fullname, path in classes:
        simplename = fullname.split('.')[-1]
        if simplename not in classname_to_full:
            classname_to_full[simplename] = set()
        classname_to_full[simplename].add((fullname, path))

pathtofull = lambda path: '.'.join(path.split('/'))

asclass = re.compile('<td><a href="(\./)?([\w/]+).html">')
def scan_asdoc_allclasses(fn):
    base = 'file://' + os.path.dirname(os.path.abspath(fn)) + "/"
    for line in open(fn).readlines():
        m = asclass.search(line)
        if m:
            yield pathtofull(m.group(2)), base + m.group(2) + ".html"

packagename = re.compile('<td align="left" id="subTitle" class="titleTableSubTitle">([\w.]+)')
funcname = re.compile('<td class="summaryTableSecondCol"><a href="package.html#(\w+)')
def scan_asdoc_package(fn):
    base = 'file://' + os.path.dirname(os.path.abspath(fn)) + "/package.html#"
    lines = open(fn).readlines()
    for line in lines:
        m = packagename.search(line)
        if m:
            package = m.group(1)
            break
    for line in lines:
        m = funcname.search(line)
        if m:
            yield package + "." + m.group(1), base + m.group(1) + "()"

def scan_swc(fn):
    zip = zipfile.ZipFile(fn)
    tree = ElementTree.parse(zip.open("catalog.xml"))
    for el in tree.findall('.//{http://www.adobe.com/flash/swccatalog/9}script'):
        yield pathtofull(el.get('name')), ""

def scan_dir(base):
    base = os.path.abspath(base)
    for d, dns, fns in os.walk(base):
        package = pathtofull(d[len(base) + 1:]) + "."
        for fn in fns:
            if not fn.endswith('.as'):
                continue
            yield package + fn[:-3], d + "/" + fn
