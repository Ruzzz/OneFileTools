__author__  = "Ruslan Zaporojets <ruzzzua[]gmail.com>"
__date__    = "2016-04-07"
__version__ = "1.0"
__credits__ = "MIT"

import time
import urllib.parse
import posixpath
import os.path
import mimetypes
import sys

from http.server import BaseHTTPRequestHandler, HTTPServer
from urllib.parse import urlparse
from urllib.parse import parse_qs

# Docs:
# - http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.35
# - http://tools.ietf.org/html/rfc2616#section-14.35


class HeaderRangeState:

    _OK                   = 0
    IGNORE                = 1
    ERROR_NOT_SATISFIABLE = 2    

class HttpRanges:

    def __init__(self):
        self._state = HeaderRangeState._OK
        self._ranges = [] 

    def _update_state(self, state):
        self._state = state
        return state    

    def get(self):
        if self._state == HeaderRangeState._OK:
            return self._ranges
        else:
            return self._state

    def parse_header(self, value, file_size):
        """Parse header 'Range: bytes=START-END', return list of pair"""

        self._ranges = []
        if len(value) == 0:
            return self._update_state(HeaderRangeState.IGNORE)

        bytes_unit, byte_range_set_str = value.split('=', 1)
        if bytes_unit.strip().lower() != 'bytes':
            return self._update_state(HeaderRangeState.IGNORE)

        byte_range_sets = byte_range_set_str.split(',')
        if len(byte_range_sets) == 0:
            return self._update_state(HeaderRangeState.IGNORE)

        # ToDo: Now use first range only
        byte_range_set_first = byte_range_sets[0]
        start, end = byte_range_set_first.split('-', 1)
        range_start = 0
        range_end = file_size - 1
        start_len = len(start)
        end_len = len(end)
        if start_len > 0:
            range_start = int(start)
            if end_len > 0:
                range_end_ = int(end)
                if range_end_ < file_size:
                    range_end = range_end_
        elif end_len > 0:
            range_end_ = int(end)
            if range_end_ < file_size:
                range_start = file_size - range_end_
        if range_start > range_end:
            return self._update_state(HeaderRangeState.ERROR_NOT_SATISFIABLE)
        self._ranges.append((range_start, range_end))
        self._update_state(HeaderRangeState._OK)
        return self._ranges

class TestServerRequestHandler(BaseHTTPRequestHandler):

    _TEMP_BUF_CHARS     = bytes(b"_0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz")
    _TEMP_BUF_SIZE      = 64 * 1024
    DEFAULT_FILE_SIZE   = 1000000
    MAX_FILE_SIZE       = 100000000
    DEFAULT_SPEED_LIMIT = 512        # KB/s
    MAX_SPEED_LIMIT     = 1024 * 100 # 100 MB/s

    emul_last_modified = time.time()
    emul_conn_speed = 0
    emul_file_size = 0

    filename  = "" # for headers and log
    file_last_modified = 0
    file_size = 0
    file_pos = 0
    
    if not mimetypes.inited:
        mimetypes.init()
    mime_map = mimetypes.types_map.copy()
    mime_map.update({ '': 'application/octet-stream' }) 

    def do_GET(self):
        url_parts = urlparse(self.path)
        self.init_emul_vars(url_parts.query)
        self.filename = os.path.basename(url_parts.path)
        file_path = self.try_get_real_file(self.path);
        if file_path is None: # Emul
            self.file_last_modified = self.emul_last_modified
            self.file_size = self.emul_file_size
            self.sendHeaders()
            print('--- Emulation')
            try:
                self.sendEmulFile(self.emul_conn_speed, self.file_size)
            except Exception as e:
                print('--- Send error:', e)
                return
        else:
            self.sendHeaders()
            print('--- Real file:', file_path)
            print('--- File offset:', self.file_pos, 'Size:', self.file_size)
            try:
                self.sendFile(self.emul_conn_speed, self.file_size, self.file_pos, file_path)
            except Exception as e:
                print('--- Send error:', e)
                return
            
        print(self.log_date_time_string(), 'Speed (KB/s):', self.emul_conn_speed, 'Filename:', self.filename)
        print('--- OK')
        print()

    def sendHeaders(self):
        '''
        Before:
            self.filename
            self.file_last_modified
            self.file_size
        After:
            self.file_pos
            self.file_size
        '''
        use_range = 'Range' in self.headers
        if use_range:
            http_ranges = HttpRanges()
            http_ranges_result = http_ranges.parse_header(self.headers['Range'], self.file_size)
            if http_ranges_result == HeaderRangeState.ERROR_NOT_SATISFIABLE:
                self.send_response(416, 'Range Not Satisfiable')
                self.end_headers()
                return
            elif isinstance(http_ranges_result, list):
                self.file_pos, file_range_end = http_ranges_result[0]
                self.send_response(206, 'Partial Content Response')
                self.send_header("Content-Range", 'bytes {0}-{1}/{2}'.format(self.file_pos, file_range_end, self.file_size))
                self.file_size = file_range_end - self.file_pos + 1
                self.send_header("Content-Length", self.file_size)
            else:
                use_range = False

        if not use_range:
            self.send_response(200)
            self.send_header('Content-Length', str(self.file_size)); # ToDo: without
    
        self.send_header('Cache-Control', 'private')    
        self.send_header('Content-Type', self.get_mime(self.filename))
        self.send_header('Content-Disposition', 'filename=' + self.filename);
        self.send_header('Accept-Ranges', 'bytes'); # ToDo: Accept-Ranges: none
        self.send_header('Last-Modified', self.date_time_string(self.file_last_modified))
        self.end_headers()

    def sendFile(self, conn_speed_inkbs, file_size, file_pos, file_path):
        file = open(file_path, 'rb')
        try:
            file.seek(file_pos, 0)
            speed_in_bytes = conn_speed_inkbs * 1024
            buf_size = min(self._TEMP_BUF_SIZE, speed_in_bytes)
            total = 0        
            while (total < file_size):
                chunk_size = min(buf_size, file_size - total)
                self.wfile.write(file.read(chunk_size))
                self.wfile.flush()
                total += chunk_size
                print(self.log_date_time_string(), 'Send bytes:', total, 'Chunk size:', chunk_size)  
                time.sleep(chunk_size / speed_in_bytes)
            file.close()
        except:
            file.close()
            raise
        return

    def sendEmulFile(self, conn_speed_inkbs, file_size):
        speed_in_bytes = conn_speed_inkbs * 1024
        buf = self.gen_buf(min(self._TEMP_BUF_SIZE, speed_in_bytes))
        total = 0        
        while (total < file_size):
            buf_size = len(buf) 
            chunk_size = min(buf_size, file_size - total)
            if chunk_size != buf_size:
                buf = self.gen_buf(chunk_size)    
            self.wfile.write(buf)
            self.wfile.flush()
            total += chunk_size
            print(self.log_date_time_string(), 'Send bytes:', total, 'Chunk size:', chunk_size)  
            time.sleep(chunk_size / speed_in_bytes)
        return

    def try_get_real_file(self, path):
        """ Return full path or None
        After:
            self.file_last_modified
            self.file_size
        """
        path = self.translate_path(path)
        if not os.path.exists(path):
            return None
        f = open(path, 'rb')
        try:
            fs = os.fstat(f.fileno())
            self.file_last_modified = fs.st_mtime
            self.file_size = fs[6]            
            f.close()
        except:
            f.close()
            raise
        return path

    def translate_path(self, path):
        # abandon query parameters
        path = path.split('?',1)[0]
        path = path.split('#',1)[0]
        # Don't forget explicit trailing slash when normalizing. Issue17324
        trailing_slash = path.rstrip().endswith('/')
        try:
            path = urllib.parse.unquote(path, errors='surrogatepass')
        except UnicodeDecodeError:
            path = urllib.parse.unquote(path)
        path = posixpath.normpath(path)
        words = path.split('/')
        words = filter(None, words)
        path = os.getcwd()
        for word in words:
            drive, word = os.path.splitdrive(word)
            head, word = os.path.split(word)
            if word in (os.curdir, os.pardir): continue
            path = os.path.join(path, word)
        if trailing_slash:
            path += '/'
        return path

    def gen_buf(self, size):
        chars_len = len(self._TEMP_BUF_CHARS)
        buf = bytearray(size)
        for i, b in enumerate(buf):
            buf[i] = self._TEMP_BUF_CHARS[i % chars_len]
        return buf

    def log_date_time_string(self):
        now = time.time()
        year, month, day, hh, mm, ss, x, y, z = time.localtime(now)
        s = "%04d-%02d-%02d %02d:%02d:%02d" % (year, month, day, hh, mm, ss)
        return s

    def init_emul_vars(self, query):
        query_params = parse_qs(query)
        try:
            size = int(query_params['size'][0])
            if (size <= 0) or (size > self.MAX_FILE_SIZE):
                size = self.DEFAULT_FILE_SIZE
        except:
            size = self.DEFAULT_FILE_SIZE
        self.emul_file_size = size
        try:
            speed = int(query_params['speed'][0])
            if (speed <= 0) or (speed > self.MAX_SPEED_LIMIT):
                speed = self.DEFAULT_SPEED_LIMIT
        except:
            speed = self.DEFAULT_SPEED_LIMIT 
        self.emul_conn_speed = speed      

    def get_mime(self, path):
        base, ext = os.path.splitext(path)
        if ext in self.mime_map:
            return self.mime_map[ext]
        ext = ext.lower()
        if ext in self.mime_map:
            return self.mime_map[ext]
        else:
            return self.mime_map['']

def run(port):
    httpd = HTTPServer(('127.0.0.1', port), TestServerRequestHandler)
    print('Start test server.')
    print('Defaults:')
    print('  SIZE(bytes)=' + str(TestServerRequestHandler.DEFAULT_FILE_SIZE))
    print('  SPEED(Kbytes/sec)=' + str(TestServerRequestHandler.DEFAULT_SPEED_LIMIT))
    print('Connect to:')
    print('  http://127.0.0.1:' + str(port) + '/any_path/any_file')
    print('  http://127.0.0.1:' + str(port) + '/any_path/any_file?size=SIZE&speed=SPEED')
    print('  http://127.0.0.1:' + str(port) + '/real_script_subdir/real_filename?speed=SPEED')
    print()
    httpd.serve_forever()
 
if __name__ == '__main__':
    if len(sys.argv) > 1:
        port = int(sys.argv[1])
    else:
        port = 8081
    run(port);