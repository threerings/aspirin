#!/usr/bin/env python
'''Groups and sorts imports while removing duplicates from actionscript files in a directory tree'''
import collections, os, re, sys

# Group 1 is the entirety of the import including a semicolon if there was one. Group 2 is just the
# classname, or a wildcard import.
packandname = re.compile('import (.*\.([\w*$]+);?)')

# Order in which to group packages by prefix.  The longest prefix that matches an import determines
# the group the package belongs to.
ordering = ["flash",
        "java",
        "javax",
        "android",
        "scala",
        "",
        "com.samskivert",
        "com.samskivert.swing",
        "com.samskivert.servlet",
        "com.samskivert.velocity",
        "com.samskivert.jdbc",

        "com.samskivert.depot",

        "com.threerings.io",# Narya
        "com.threerings.no",
        "com.threerings.util",
        "com.threerings.presents",
        "com.threerings.crowd",
        "com.threerings.admin",
        "com.threerings.bureau",

        "com.threerings.display",# Aspirin
        "com.threerings.geom",
        "com.threerings.media",
        "com.threerings.text",
        "com.threerings.ui",

        "com.threerings.flashbang",

        "com.threerings.samsara",

        "com.threerings.cast", # Nenya
        "com.threerings.resource",
        "com.threerings.miso",
        "com.threerings.jme",
        "com.threerings.openal",
        "com.threerings.tools",

        "com.threerings.lembas",

        "com.threerings.parlor", # Vilya
        "com.threerings.puzzle",
        "com.threerings.whirled",
        "com.threerings.micasa",
        "com.threerings.stage",
        "com.threerings.stats",

        "com.threerings.orth",

        "com.threerings",
        "com.threerings.piracy",
        "com.threerings.ppa",
        "com.threerings.yohoho",
        "com.threerings.who"]

# Group static identically, but after regular imports
ordering.extend(["static %s" % o for o in ordering])

ordering = [(o, re.compile("^" + o + ".*")) for o in ordering]
byprecision = sorted(ordering, key=lambda x: -len(x[0]))

# Package prefixes to split apart within a group
splitprefix = re.compile('((com\.|net\.|org\.)?\w+)')

def order(imports):
    '''Returns import lines for each group in ordering in the proper order with newlines between the
    groups'''
    grouped = collections.defaultdict(set)
    for imp in imports:
        for group, matcher in byprecision:
            if matcher.match(imp):
                grouped[group].add(imp)
                break
        else:
            print "BAILING, No grouping for", imp
            sys.exit(1)
    lines = []
    for group, pattern in ordering:
        if grouped[group]:
            splits = collections.defaultdict(list)
            for imp in grouped[group]:
                splits[splitprefix.match(imp).groups(1)].append(imp)
            for split in sorted(splits.values()):
                for imp in sorted(split):
                    lines.append("import %s" % imp)
                lines.append("")
    if lines and lines[-1] == '':
        lines[-1] = '\n'
    return "\n".join(lines)

def organizeImports(fn):
    lines = open(fn).readlines()
    ordered, sections = findOrdering(lines)
    if not ordered:
        reorderImports(fn, lines, sections)

def findOrdering(lines):
    # Find all the imports by class section in the file and the usages within those classes
    matches = set()
    foundsections = []
    rawsections = []
    inimports = False
    for line in lines:
        m = packandname.match(line)
        if m:
            if not inimports:
                foundsections.append(set())
                rawsections.append([])
                matches = set()
            inimports = True
            rawsections[-1].append(line)
            if m.group(1) not in matches:
                matches.add(m)
                # Star imports are automatically considered to be used
                if m.group(2).endswith("*") or m.group(2).endswith("_"):
                    foundsections[-1].add(m.group(1))
            continue
        elif inimports:
            if ignoreInImports(line):
                rawsections[-1].append(line)
                continue
            inimports = False
        for m in matches:
            if m.group(2) in line:
                foundsections[-1].add(m.group(1))

    foundsections = [order(found) for found in foundsections]
    rawsections = ["".join(section) for section in rawsections]
    return foundsections == rawsections, foundsections

def ignoreInImports(line):
    # Blank lines and commented out imports don't exit an import section
    stripped = line.strip()
    return stripped == "" or (stripped.startswith('//') and 'import' in line)

def reorderImports(fn, lines, foundsections):
    print "Reorder imports:", fn
    # Write non-import lines as they're encountered, then import sections with their duplicates
    # removed as ordered by order
    out = open(fn, 'w')
    founditer = iter(foundsections)
    inimports = False
    for line in lines:
        if not inimports and line.startswith("import"):
            inimports = True
            continue
        elif inimports:
            if line.startswith("import") or ignoreInImports(line):
                continue
            out.write(founditer.next())
            inimports = False
        out.write(line)
    out.close()

def process(path):
    if os.path.isfile(path):
        organizeImports(path)
    else:
        for dirpath, dirnames, filenames in os.walk(path):
            for i, dn in enumerate(dirnames[:]):
                if dn == '.svn':
                    del dirnames[i]
            for fn in filenames:
                if fn.endswith('.as') or fn.endswith(".java") or fn.endswith('.scala'):
                    try:
                        organizeImports(dirpath + "/" + fn)
                    except:
                        print "Unable to organize", dirpath + "/" + fn
                        raise

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print "Usage: import_action <as paths>"
        sys.exit(1)
    for arg in sys.argv[1:]:
        process(arg)
