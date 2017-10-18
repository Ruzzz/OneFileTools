import os, re, sys

def tokenize(text, match=re.compile(b"([idel])|(\d+):|(-?\d+)").match):
    i = 0
    while i < len(text):
        m = match(text, i)
        s = m.group(m.lastindex)
        i = m.end()
        if m.lastindex == 2:
            yield b's'
            yield text[i:i+int(s)]
            i = i + int(s)
        else:
            yield s

def decode_item(tokens, token):
    if token == b'i':
        # integer: "i" value "e"
        data = int(next(tokens))
        if next(tokens) != b'e':
            raise ValueError
    elif token == b's':
        # string: "s" value (virtual tokens)
        t = next(tokens)
        try:
            data = t.decode("utf-8")
        except UnicodeDecodeError:
            data = t
    elif token == b'l' or token == b'd':
        # container: "l" (or "d") values "e"
        data = []
        tok = next(tokens)
        while tok != b'e':
            data.append(decode_item(tokens, tok))
            tok = next(tokens)
        if token == b'd':
            data = dict(zip(data[0::2], data[1::2]))
    else:
        raise ValueError
    return data

def decode(text):
    try:
        tokens = tokenize(text)
        data = decode_item(tokens, next(tokens))
        for token in tokens:
            raise SyntaxError("trailing junk")
    except (AttributeError, ValueError, StopIteration):
        raise SyntaxError("syntax error")
    return data

#
#  Main
#
    
i = 1 
while i < len(sys.argv):
    try:
        data = open(sys.argv[i], "rb").read()
        torrent = decode(data)
        os.system('start "" ' + torrent['comment'])
    except:
        None
    i += 1