'''Creates a pickled python dictionary from a short classname to its fully-qualified name

Takes the output pickle file first, then any number of .swc files or all-classes.html files from
asdocs to use to populate it eg
python ~/dev/tools/vim/extract_flash_classes.py ~/Documents/flex3_langref/all-classes.html  ~/dev/downtown/dist/lib/*swc
'''
import cPickle, re, sys, zipfile
from xml.etree import ElementTree

pathtofull = lambda path: '.'.join(path.split('/'))

asclass = re.compile('<td><a href="([\w/]+).html">')
def process_asdoc_allclasses(fn):
    for line in open(fn).readlines():
        m = asclass.search(line)
        if m:
            yield pathtofull(m.group(1))

def process_swc(fn):
    zip = zipfile.ZipFile(fn)
    tree = ElementTree.parse(zip.open("catalog.xml"))
    for el in tree.findall('.//{http://www.adobe.com/flash/swccatalog/9}script'):
        yield pathtofull(el.get('name'))

classname_to_full = {}
def addclasses(classes):
    for fullname in classes:
        simplename = fullname.split('.')[-1]
        if simplename not in classname_to_full:
            classname_to_full[simplename] = set()
        classname_to_full[simplename].add(fullname)

if __name__ == "__main__":
    outloc = sys.argv[1]
    for arg in sys.argv[2:]:
        if arg.endswith('all-classes.html'):
            addclasses(process_asdoc_allclasses(arg))
        elif arg.endswith('.swc'):
            addclasses(process_swc(arg))
        else:
            print "Don't know how to handle", arg
    cPickle.dump(classname_to_full, open(outloc, 'w'), -1)
