# The MIT License (MIT)
# Copyright (c) 2016 Ruslan Zaporojets
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

__author__    = "Ruslan Zaporojets"
__email__     = "ruzzzua@gmail.com"
__license__   = "MIT"
__version__   = "1.0.0"
# Date:       = "2016.10.25"

import os, sys
from RegistryExport import RegistryExport

#
#  cameyo_dat2reg2
#

CAMEYO_REG_FIX_REPLACES = {
    # Clean
    '[]\n'                        : '',
    '[Registry]\n'                : '',
    '[Registry\\%CurrentUser%]\n' : '',
    '[Registry\\Machine]\n'       : '',
    # Fix
    '[Registry\\%CurrentUser%' : '[HKEY_CURRENT_USER',
    '[Registry\\Machine' : '[HKEY_LOCAL_MACHINE'
}

def replace_all(s, replaces):
    result = s
    for old, new in replaces.items():
        result = result.replace(old, new)
    return result

def replace_in_file(path, replaces, encoding='utf-16'):
    with open(path, 'r', encoding=encoding) as f:
        content = f.read()
    content = replace_all(content, replaces)
    with open(path, 'w', encoding=encoding) as f:
        f.write(content)

def cameyo_dat2reg2(path_dat, path_reg):
    # http://www.nirsoft.net/utils/registry_file_offline_export.html
    os.system('regfileexport.exe "%s" "%s"' % (path_dat, path_reg))
    replace_in_file(path_reg, CAMEYO_REG_FIX_REPLACES)

#
#  Main
#

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

def main(argv=None):
    if argv is None: argv = sys.argv
    argc = len(argv)
    if not ((argc == 2) or (argc == 3)):
        sys.exit('Usage: %s reg.dat [out.reg]'
            % (os.path.basename(argv[0])))

    path_dat = argv[1]
    path_reg = argv[2] if argc == 3 else os.path.splitext(argv[1])[0] + '.reg'
    reg_export = RegistryExport(_key_fix_cameyo, _log_error)
    reg_export.dat_to_reg(path_dat, path_reg)
    # cameyo_dat2reg2(path_dat, path_reg)
    print ('Exported', path_dat, 'to', path_reg)

if __name__ == '__main__':
    main(argv=sys.argv)
