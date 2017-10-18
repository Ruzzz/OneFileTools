import requests

def main():

    URL = 'http://localhost:8081/path/file.exe'

    PARAMS = { 'speed': 512, 'size': 2000000 } 

    r = requests.get(URL, headers={ 'range': 'bytes=4-3' }, params=PARAMS)
    print(r.status_code == 416)
    print(len(r.content) == 0)

    r = requests.get(URL, params=PARAMS)
    print(r.status_code == 200)
    print(len(r.content) == PARAMS['size'])

    PARAMS = { 'speed': 10, 'size': 256 } 

    r = requests.get(URL, headers={ 'range': 'bytes=0-1000000' }, params=PARAMS)
    print(r.status_code == 206)
    print(len(r.content) == PARAMS['size'])

    r = requests.get(URL, headers={ 'range': 'bytes=1-1000000' }, params=PARAMS)
    print(r.status_code == 206)
    print(len(r.content) == PARAMS['size'] - 1)

    r = requests.get(URL, params=PARAMS)
    print(r.status_code == 200)
    print(len(r.content) == PARAMS['size'])

    r = requests.get(URL, headers={ 'range': 'bytes=1-2' }, params=PARAMS)
    print(r.status_code == 206)
    print(len(r.content) == 2)

    r = requests.get(URL, headers={ 'range': 'bytes=2-2' }, params=PARAMS)
    print(r.status_code == 206)
    print(len(r.content) == 1)

    r = requests.get(URL, headers={ 'range': 'bytes=-3' }, params=PARAMS)
    print(r.status_code == 206)
    print(len(r.content) == 3)

    r = requests.get(URL, headers={ 'range': 'bytes=1-' }, params=PARAMS)
    print(r.status_code == 206)
    print(len(r.content) == PARAMS['size'] - 1)

main()