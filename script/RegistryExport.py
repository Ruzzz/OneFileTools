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
# Date:       = "2016-10-25"

from collections import deque
# from collections import OrderedDict # TODO
# Install last version: pip install git+https://github.com/williballenthin/python-registry.git
from Registry import Registry
from Registry import RegistryParse

assert hasattr(Registry.RegistryValue, 'raw_data')
if hasattr(RegistryParse, 'NotSupportedException'):
    NotSupportedException = RegistryParse.NotSupportedException
else:
    class NotSupportedException(Exception):
        def __init__(self, value):
            super(NotSupportedException, self).__init__()
            self._value = value

        def __str__(self):
            return "Not Supported Ecxeption (%s)" % (self._value)

def reg_through_keys(root_key, on_key=None, on_value=None):
    """
    on_key(Registry.RegistryKey), return walk_subkeys, walk_values
    on_value(Registry.RegistryKey, Registry.RegistryValue)

    """
    assert isinstance(root_key, Registry.RegistryKey)
    keys_queue = deque()
    keys_queue.append(root_key)
    try:
        while True: # len(keys_queue)
            cur_key = keys_queue.pop()
            walk_values = True
            walk_subkeys = True
            if on_key:
                walk_subkeys, walk_values = on_key(cur_key)
            if walk_values and on_value:
                for value in cur_key.values():
                    on_value(cur_key, value)
            if walk_subkeys:
                keys_queue.extend(reversed(cur_key.subkeys()))
    except IndexError:
        None

def format_hex_lines(pre_hex_len, value_raw,
        len_limit = 80,
        item_delim = ',',
        line_prefix = '  ',
        line_sufix = '\\'):
    raw_size = len(value_raw)
    if raw_size == 0:
        return [ '' ]
    line = '%02x' % (value_raw[0])
    if raw_size == 1:
        return [ line ]
    lines = []
    ext_chars_len = 2 + len(item_delim) + len(line_sufix)
    first_line = True
    i = 1    
    while i < raw_size:
        line = line + item_delim
        cur_len = len(line) + ext_chars_len
        if first_line:
            cur_len += pre_hex_len
        if cur_len > len_limit:
            lines.append(line + line_sufix)
            line = line_prefix
            first_line = False
        line = line + '%02x' % (value_raw[i])
        i += 1
    if line != line_prefix:
        lines.append(line)
    return lines

def _key_root_remover(path_parts):
    return path_parts[1:]

# TODO All strings is ANSI?    
class RegistryExport:
    ERROR_KEY_PATH_EMPTY           = 1
    ERROR_KEY_PATH_TRANSFROM_EMPTY = 2
    ERROR_KEY_PATH_BACKSLASH       = 3
    ERROR_VALUE_SZ_NEWLINE         = 1000

    def error_to_log(errorcode, data):
        '''
        Default log error
        '''
        if errorcode == RegistryExport.ERROR_VALUE_SZ_NEWLINE:
            return 'WARNING: <newline> character in value!\n%s\n"%s"="%s"' \
                % (data['path'], data['value'].name(), data['value'].value())
        return None
    
    def on_error(errorcode, data):
        '''
        Default on_error
        '''
        if (errorcode == RegistryExport.ERROR_KEY_PATH_EMPTY) \
                or (errorcode == RegistryExport.ERROR_KEY_PATH_TRANSFROM_EMPTY):
            return None
        ## elif errorcode == RegistryExport.ERROR_KEY_PATH_BACKSLASH: # TODO            
        elif errorcode == RegistryExport.ERROR_VALUE_SZ_NEWLINE:
            s = data['value'].value()
            s = s.rstrip('\r\n')
            s = s.replace('\r\n', '\n')
            s = s.replace('\n', ' ') # TODO
            return s
        raise Exception; # TODO

    def __init__(self, key_transform=_key_root_remover, on_error=on_error):
        """
        key_transform([key_path_parts...]), return [new_key_path_parts...]
        on_error(errorcode, data), return new_value (see errorcode)

        """
        # super(RegistryExport, self).__init__()
        self._key_transform = key_transform
        self._on_error = on_error
        self._on_log_curr_key = None # TODO Hack
        self._on_log_curr_key_path = None # TODO Hack

    def dat_to_reg(self, src_path, dest_path):
        reg = Registry.Registry(src_path)
        self.key_to_reg(reg.root(), dest_path)

    # TODO
    def key_to_tuples(self, root_key):
        assert isinstance(root_key, Registry.RegistryKey)
        result = []
        keys_queue = deque()
        keys_queue.append(root_key)
        try:
            while True: # len(keys_queue)
                cur_key = keys_queue.pop()
                self._on_log_curr_key = cur_key
                path = self.format_key(cur_key)
                if (path):
                    self._on_log_curr_key_path = path
                    result.append((True, path))
                    key_index = len(result) - 1
                    for value in cur_key.values():
                        vname = self.format_vname(value)
                        vvalue = self.format_vvalue(value, len(vname))
                        result.append((False, key_index, vname, vvalue))
                keys_queue.extend(reversed(cur_key.subkeys()))
        except IndexError:
            None
        self._on_log_curr_key = None
        self._on_log_curr_key_path = None
        return result

    def key_to_reg(self, root_key, dest_path):
        # Faster(?) version
        assert isinstance(root_key, Registry.RegistryKey)
        with open(dest_path, 'w', encoding='utf-16') as f:
            f.write('Windows Registry Editor Version 5.00')
            keys_queue = deque()
            keys_queue.append(root_key)
            try:
                while True: # len(keys_queue)
                    cur_key = keys_queue.pop()
                    self._on_log_curr_key = cur_key
                    path = self.format_key(cur_key)
                    if (path):
                        self._on_log_curr_key_path = path
                        f.write('\n\n' + path)
                        for value in cur_key.values():
                            f.write('\n' + self.format_value(value))
                    keys_queue.extend(reversed(cur_key.subkeys()))
            except IndexError:
                None
            self._on_log_curr_key = None
            self._on_log_curr_key_path = None

    def key_to_reg2(self, root_key, dest_path):
        '''
        Short alternative to key_to_reg, as example.
        '''
        assert isinstance(root_key, Registry.RegistryKey)
        with open(dest_path, 'w', encoding='utf-16') as f:
            f.write('Windows Registry Editor Version 5.00\n\n')
            f.write(self.format_keys(root_key))

    def key_to_reg3(self, root_key, dest_path):
        '''
        Short alternative to key_to_reg, as example.
        '''
        assert isinstance(root_key, Registry.RegistryKey)
        lines = []
        lines.append('Windows Registry Editor Version 5.00')
        self.format_keys(root_key, lines)
        with open(dest_path, 'w', encoding='utf-16') as f:
            f.write('\n'.join(lines))
            
    def format_keys(self, root_key, result_lines=None):
        # Faster(?) version
        assert isinstance(root_key, Registry.RegistryKey)
        return_str = result_lines is None
        if return_str:
            result_lines = []
        keys_queue = deque()
        keys_queue.append(root_key)
        try:
            while True: # len(keys_queue)
                cur_key = keys_queue.pop()

                self._on_log_curr_key = cur_key
                path = self.format_key(cur_key)
                if (path):
                    self._on_log_curr_key_path = path
                    if len(result_lines) > 0:
                        result_lines.append('')
                    result_lines.append(path)

                    for value in cur_key.values():
                        self.format_value(value, False, result_lines)

                keys_queue.extend(reversed(cur_key.subkeys()))
        except IndexError:
            None
        self._on_log_curr_key = None
        self._on_log_curr_key_path = None
        if return_str:
            return '\n'.join(result_lines)

    def format_keys2(self, root_key, result_lines=None):
        '''
        Alternative to format_keys, which use reg_through_keys, as example.
        '''
        assert isinstance(root_key, Registry.RegistryKey)
        return_str = result_lines is None
        if return_str:
            result_lines = []

        def on_key(key):
            self._on_log_curr_key = key
            path = self.format_key(key)
            if (path):
                self._on_log_curr_key_path = path
                if len(result_lines) > 0:
                    result_lines.append('')
                result_lines.append(path)
            return True, bool(path)

        def on_value(key, value):
            self.format_value(value, False, result_lines)

        reg_through_keys(root_key, on_key, on_value)
        self._on_log_curr_key = None
        self._on_log_curr_key_path = None
        if return_str:
            return '\n'.join(result_lines)
    
    def format_value(self, value, join_lines=True, result_lines=None):
        name = '@' if value.name() == '(default)' else '"' + value.name() + '"' # self.format_vname(value)
        result = []
        self.format_vvalue(value, len(name), False, result)
        if result:
            result[0] = name + '=' + result[0]
        else:
            result.append(name)
        if join_lines:
            result = '\n'.join(result)
        if result_lines is not None:
            if isinstance(result, list):
                result_lines.extend(result)
            else:
                result_lines.append(result)
        else:
            return result
    
    def format_vname(self, value):
        assert isinstance(value, Registry.RegistryValue)
        return '@' if value.name() == '(default)' else '"' + value.name() + '"'
            
    def format_vvalue(self, value, name_len, join_lines=True, result_lines=None):
        assert isinstance(value, Registry.RegistryValue)
        
        if value.value_type() == Registry.RegSZ:
            result = value.value()
            if ('\n' in result) and self._on_error:
                data = {
                    'key'   : self._on_log_curr_key,
                    'path'  : self._on_log_curr_key_path,
                    'value' : value
                }
                result = self._on_error(self.ERROR_VALUE_SZ_NEWLINE, data)
            result = result.replace('\\', '\\\\')
            result = result.replace('\"', '\\\"')
            result = '"' + result + '"'

        elif value.value_type() == Registry.RegDWord:
            result = 'dword:%08x' % (value.value())

        elif (value.value_type() == Registry.RegExpandSZ) \
                or (value.value_type() == Registry.RegMultiSZ):
            pre_str = 'hex(%d):' % (value.value_type())
            result = format_hex_lines(name_len + len(pre_str), value.raw_data())
            result[0] = pre_str + result[0]
            if join_lines:
                result = '\n'.join(result)

        elif value.value_type() == Registry.RegBin:
            pre_str = 'hex:'
            result = format_hex_lines(name_len + len(pre_str), value.raw_data())
            result[0] = pre_str + result[0]
            if join_lines:
                result = '\n'.join(result)

        else:
            raise NotSupportedException('Format Value Type %s' % value.value_type_str())

        if result_lines is not None:
            if isinstance(result, list):
                result_lines.extend(result)
            else:
                result_lines.append(result)
        else:
            return result

    def format_key(self, key):
        assert isinstance(key, Registry.RegistryKey)
        path = key.path()

        def try_fix_path(codeerror):
            if self._on_error is None:
                return False
            path = self._on_error(codeerror, { 'key' : key })
            return bool(path)

        if (len(path) == 0) and not try_fix_path(self.ERROR_KEY_PATH_EMPTY):
            return None
        if self._key_transform is not None:
            parts = path.split('\\')
            # TODO
            # if (len(path) > 0) and ('\\' in path[-1]) and not try_fix_path(self.ERROR_KEY_PATH_BACKSLASH):
            #    return None
            parts = self._key_transform(parts)
            if (len(parts) == 0) and not try_fix_path(self.ERROR_KEY_PATH_TRANSFROM_EMPTY):
                return None
            path = '\\'.join(parts)
        
        return '[' + path + ']'

def main(argv=None):
    import os

    if argv is None:
        import sys
        argv = sys.argv
    argc = len(argv)
    if not ((argc >= 2) and (argc <= 4)):
        usage ='''Usage: {0} reg.dat out.reg reg_key_path
       {0} reg.dat out.reg
       {0} reg.dat
        '''.format(os.path.basename(argv[0]))
        sys.exit(usage)

    path_dat = argv[1]
    path_reg = argv[2] if argc == 3 else os.path.splitext(argv[1])[0] + '.reg'
    if (argc < 4):
        reg_export = RegistryExport()
        reg_export.dat_to_reg(path_dat, path_reg)
        print ('Exported', path_dat, 'to', path_reg)
    else: # argc == 4
        reg = Registry.Registry(path_dat)
        key_path = argv[3]
        if (key_path.lower().startswith(reg.root().name().lower())):
            key_path = key_path.partition("\\")[2];
        try:
            key = reg.open(key_path)
        except Registry.RegistryKeyNotFoundException:
            sys.exit('Specified key not found: ' + key_path)
        reg_export = RegistryExport()
        reg_export.key_to_reg(key, path_reg)
        print ('Exported', key_path, 'from', path_dat, 'to', path_reg)

if __name__ == '__main__':
    main(None)
