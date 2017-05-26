#   _ __ _   _ ____________
#  | '__| | | |_  /_  /_  /
#  | |  | |_| |/ / / / / /
#  |_|   \__,_/___/___/___|
#

__author__    = "Ruslan Zaporojets"
__email__     = "ruzzzua@gmail.com"
__license__   = "MIT"
__version__   = "1.0.0"
# Date:       = "2016.10.28"

import os, sys
from difflib import SequenceMatcher
from Registry import Registry
from RegistryExport import RegistryExport

ADDED_NAME = 'added.reg'
CHANGED_NAME = 'changed.reg'
REMOVED_NAME = 'removed.reg'

def _key_fix_cameyo(path_parts):
    # Fix 'Cameyo.Repackage.VERSION\Registry\...'
    if len(path_parts) < 3:
        return []
    result = path_parts[2:]
    if result[0] == '%CurrentUser%':
        result[0] = 'HKEY_CURRENT_USER'
    elif result[0] == 'Machine':
        result[0] = 'HKEY_LOCAL_MACHINE'
    else:
        raise Exception # TODO
    return result

def _log_error(errorcode, data):
    s = RegistryExport.error_to_log(errorcode, data)
    if s: print(s)
    return RegistryExport.on_error(errorcode, data)

def keys_diff(key1, key2):
    assert isinstance(key1, Registry.RegistryKey)
    assert isinstance(key2, Registry.RegistryKey)
    
    reg_exp = RegistryExport(_key_fix_cameyo, _log_error)
    d1 = reg_exp.key_to_tuples(key1)
    d2 = reg_exp.key_to_tuples(key2)
    
    prev_key = ''
    def to_single_line(reg_tuple):
        global prev_key
        if reg_tuple[0]: # Key tuple
            k = reg_tuple[1].lower()
            prev_key = k
            n = ''
            v = ''
        else:
            k = prev_key
            n = reg_tuple[2].lower()
            v = reg_tuple[3]
        return k + n + v
    
    
    sm = SequenceMatcher(
        None,
        a=[to_single_line(c) for c in d1],
        b=[to_single_line(c) for c in d2],
    )
    opcodes = sm.get_opcodes()
    
    changed_list = []
    added_list = []
    deleted_list = []
    
    for tag, a1, a2, b1, b2 in opcodes:
        if tag == 'replace':
            changed_list.extend(range(b1, b2))
        elif tag == 'insert':
            added_list.extend(range(b1, b2))
        elif tag == 'delete':
            deleted_list.extend(range(a1, a2))
            
    
    print(changed_list)
    print(added_list)
    print(deleted_list)

def main(argv=None):
    if argv is None: argv = sys.argv
    argc = len(argv)
    if not ((argc == 2) and (os.path.isdir(sys.argv[1]))):
        sys.exit('Usage: %s cameyo_unpacked_dir'
            % (os.path.basename(sys.argv[0])))

    root_dir = sys.argv[1]
    reg_old = os.path.join(root_dir, 'CHANGES\\VirtReg.Base.dat')
    reg_new = os.path.join(root_dir, 'CHANGES\\VirtReg.dat')
    
    reg1 = Registry.Registry(reg_old)
    reg2 = Registry.Registry(reg_new)
    keys_diff(reg1.root(), reg2.root())
    

if __name__ == '__main__':
    main(argv=sys.argv)