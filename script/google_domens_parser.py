# Date:       = "2017-09-05"
__author__    = "Ruslan Zaporojets"
__email__     = "ruzzzua@gmail.com"

import re, requests, time, concurrent.futures, threading, colorama
from fake_useragent import UserAgent
from urllib.parse import urlparse
from urllib.parse import quote
from collections import deque

#
#  Helpers
#

_log_lock = threading.Lock()

def log(*args):
    _log_lock.acquire()
    print(colorama.Fore.RESET, end='')
    print(*args)
    _log_lock.release()

def trace(*args):
    _log_lock.acquire()
    print(colorama.Fore.GREEN, end='')
    print(*args)
    _log_lock.release()

def error(*args):
    _log_lock.acquire()
    print(colorama.Fore.RED, end='')
    print(*args)
    _log_lock.release()

#
#  Proxies
#

class ProxiesManager:
    '''
    ctor params:
    - filename (defaults: 'proxies.txt')
    '''

    DEF_FILENAME = 'proxies.txt'

    def __init__(self, **kwargs):
        self._lock = threading.Lock()
        self.filename = kwargs['filename'] if 'filename' in kwargs else self.DEF_FILENAME
        self.read()

    def _get(self):
        try:
            proxy = self.proxies.pop()
            self.proxies.appendleft(proxy)
            return proxy
        except:
            None
        return None

    def read(self, filename=None):
        if (filename is None):
            filename = self.filename
        with open(filename) as fp:
            proxies = fp.read().splitlines()
            proxies = set(proxies)
            self.proxies = deque(proxies)

    def get(self):
        self._lock.acquire()
        ret = self._get()
        self._lock.release()
        return ret

    def set_invalid(self, proxy):
        self._lock.acquire()
        try:
            self.proxies.remove(proxy)
            error('INVALID PROXY:', proxy)
        except:
            None
        self._lock.release()

#
#  GoogleDomensParser
#

class GoogleDomensParser:
    '''
    ctor params:
    - proxies_manager
    - pages
    - timeout
    '''
    DEF_PAGES = 5
    DEF_TIMEOUT = 1 # Seconds
    URL_FIRST = 'https://www.google.com/search?q={0}'
    URL_FROM = 'https://www.google.com/search?q={0}&start={1}'
    # REGEX_LINKS = '\.google\.[^\/]+\/url\?url=([^"]+)'
    # REGEX_LINKS_1 = '\/url\?url=([^"]+)'
    REGEX_LINKS_2 = '<cite class="_Rm">([^<]+)<\/cite>'
    LINKS_PER_PAGE = 10

    # Helpers

    def _escape_path(self, path):

        def uppercase_escaped(match):
            return "%%%s" % match.group(1).upper()

        HTTP_PATH_SAFE = "%/;:@&=+$,!~*'()"
        ESCAPED_CHAR_RE = re.compile(r'%([0-9a-fA-F][0-9a-fA-F])')
        path = quote(path.encode("utf-8"), HTTP_PATH_SAFE)
        path = ESCAPED_CHAR_RE.sub(uppercase_escaped, path)
        return path

    # Main

    def __init__(self, **kwargs):
        self.domains = set()
        self._pages = kwargs['pages'] if 'pages' in kwargs else self.DEF_PAGES
        self._step_timeout = kwargs['timeout'] if 'timeout' in kwargs else self.DEF_TIMEOUT
        self._rex = re.compile(self.REGEX_LINKS_2)
        self._proxy = None
        self._proxies_manager = ProxiesManager() if ('use_proxies' in kwargs) and (kwargs['use_proxies'] == True) else None # TODO:

    def _gen_paged_url(self, str, page_no = 0):
        escaped = self._escape_path(str)
        if (page_no > 0):
            return self.URL_FROM.format(escaped, page_no * self.LINKS_PER_PAGE)
        else:
            return self.URL_FIRST.format(escaped)

    def _init_conn(self):
        self._ua = UserAgent().firefox
        self._session = requests.Session()
        if (self._proxies_manager is not None):
            if (self._proxy is not None):
                self._proxies_manager.set_invalid(self._proxy)
            self._proxy = self._proxies_manager.get()
            if self._proxy is None:
                error('No valid proxy')
                return False
        return True

    def _parse_page(self, str, page_no):
        if (page_no > 0):
            ref = self._gen_paged_url(str, page_no - 1)
            url = self._gen_paged_url(str, page_no)
        else:
            ref = 'https://www.google.com'
            url = self._gen_paged_url(str)
        trace('URL:', url)
        headers = {
            'Referer' : ref,
            'Accept' : 'text/html, application/xml;q=0.9, application/xhtml+xml, image/png, image/webp, image/jpeg, image/gif, image/x-xbitmap, */*;q=0.1',
            'Accept-Encoding' : 'gzip',
            'Accept-Language' : 'en-US,ru-RU;q=0.8,en;q=0.6,ru;q=0.4'
        }
        while (True):
            try:
                headers['User-Agent'] = self._ua
                if (self._proxy is not None):
                    proxies = { 'http': 'http://' + self._proxy, 'https': 'http://' + self._proxy }
                    req = self._session.get(url, allow_redirects=True, headers=headers, proxies=proxies, timeout=3)
                else:
                    req = self._session.get(url, allow_redirects=True, headers=headers)
                if (req.status_code == requests.codes.ok):
                    domains = set()
                    for m in self._rex.finditer(req.text):
                        domain = m.group(1)
                        if (not domain.startswith('http')):
                            domain = 'http://' + domain;
                        domain = urlparse(domain)
                        domain = domain.hostname.lower()
                        if (not domain.endswith('googleusercontent.com')):
                            domains.add(domain)
                    if (len(domains) > 0):
                        self.domains.update(domains)
                        return True

            # except requests.exceptions.ProxyError as e:
            except Exception as e:
                None
            if (self._proxy is not None):
                if not self._init_conn():
                    return False
            else:
                break

        error('PAGE:', page_no, 'URL:', url)
        return False        

    def parse(self, str, pages = 0):
        trace('SCAN:', str)
        self.domains = set()
        if self._init_conn():
            if (pages == 0):
                pages = self._pages
            if (pages > 1):
                for page_no in range(0, pages):
                    self._parse_page(str, page_no)
                    if (page_no < (pages - 1)) and (self._step_timeout > 0):
                        time.sleep(self._step_timeout)
            else:
                self._parse_page(str, 0)
        return self.domains

#
#  Test
#

def test_parser(str, pages=2, timeout=3):    
    parser = GoogleDomensParser(timeout=timeout, use_proxies=False)
    domains = parser.parse(str, pages)
    count = len(domains)
    res = 'KEY: {0}\nDOMAINS: {1}\n'.format(str, count)
    if count > 0:
        res = res + '\n'.join(domains)
    log(res)

def main():
    colorama.init(autoreset=False)
    trace('Start.')
    keys = ['ruzzz'] #, 'python', 'New York', 'My name is']
    with concurrent.futures.ThreadPoolExecutor(max_workers=5) as e:
        for k in keys:
            e.submit(test_parser, k, 5)

if __name__ == '__main__':
    main()