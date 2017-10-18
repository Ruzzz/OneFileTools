# Date:       = "2017-09-05"
__author__    = "Ruslan Zaporojets"
__email__     = "ruzzzua@gmail.com"

# TODO: http://spys.one/free-proxy-list

import os, re, requests, time
import threading
import concurrent.futures
from collections import deque
from fake_useragent import UserAgent

WORKERS = 500
FILENAME = 'free_proxies.txt'

def check_proxies(proxies_queue, valid_proxies_queue=None, save_path=None, lock=None):
    try:
        while (len(proxies_queue) > 0):
            try:
                with requests.Session() as s:
                    try:
                        proxy = proxies_queue.popleft()
                    except:
                        return
                    headers = {
                        'User-Agent' : UserAgent().firefox,
                        'Accept' : 'text/html, application/xml;q=0.9, application/xhtml+xml, image/png, image/webp, image/jpeg, image/gif, image/x-xbitmap, */*;q=0.1',
                        'Accept-Encoding' : 'gzip',
                        'Accept-Language' : 'en-US,ru-RU;q=0.8,en;q=0.6,ru;q=0.4'
                    }
                    req = s.get('https://google.com', allow_redirects=True, headers=headers, proxies={ 'https': 'http://' + proxy });
                    if (req.status_code == requests.codes.ok):
                        if (lock is not None):
                            lock.acquire()
                        try:
                            print('[ Remained:', len(proxies_queue), '] Valid:', proxy, '         ', '\r', end='')
                            if (valid_proxies_queue is not None):
                                valid_proxies_queue.append(proxy)
                            if (save_path is not None):
                                with open(save_path, 'a') as fp:
                                    fp.write(proxy + '\n')
                        finally:
                            if (lock is not None):
                                lock.release()
            except:
                None
    except:
        None

def parse_proxies(url, referer=None):
    proxies = set()
    with requests.Session() as s:
        headers = {
            'User-Agent' : UserAgent().firefox,
            'Accept' : 'text/html, application/xml;q=0.9, application/xhtml+xml, image/png, image/webp, image/jpeg, image/gif, image/x-xbitmap, */*;q=0.1',
            'Accept-Encoding' : 'gzip',
            'Accept-Language' : 'en-US,ru-RU;q=0.8,en;q=0.6,ru;q=0.4'
        }
        if (referer is not None):
            headers['Referer'] = referer
        try:
            req = s.get(url, allow_redirects=True, headers=headers);
            if (req.status_code == requests.codes.ok):
                for m in re.finditer('(\d+\.\d+\.\d+\.\d+\:\d+)', req.text):
                    proxies.add(m.group(1))
        except:
            None
    return proxies

def main():
    proxies = parse_proxies('http://fineproxy.org/freshproxyfull/#more-4', 'http://fineproxy.org/freshproxy')

    if (len(proxies) > 0):
        print('Total proxies:', len(proxies))
                
        try:
            os.remove(FILENAME)
        except:
            None
        file_lock = threading.Lock()
        print('Workers:', WORKERS)
        futures = []
        proxies_queue = deque(proxies)
        with concurrent.futures.ThreadPoolExecutor(max_workers=WORKERS) as e:
            for i in range(WORKERS):
                futures.append(e.submit(check_proxies, proxies_queue, None, FILENAME + '.new', file_lock))

        concurrent.futures.wait(futures, timeout=None, return_when=concurrent.futures.ALL_COMPLETED)
        os.rename(FILENAME + '.new', FILENAME)

        '''
        if (len(valid_proxies) > 0):
            with open('fineproxy_free_proxies.txt', 'w') as fp:
                fp.write('\n'.join(valid_proxies))
            print('Saved', len(valid_proxies), 'valid proxies')
        else:
            print('No valid proxies')
        '''

if __name__ == '__main__':
    main()