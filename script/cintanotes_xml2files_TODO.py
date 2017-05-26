import argparse as ap
import os, os.path
import xml.dom.minidom as xml
import time

VERSION  = "1.0"
GREETING = "CintaNotes TXT folder exporter V%s.\n" % VERSION

def main():
   print(GREETING)
   argsParser = createArgsParser()
   args = argsParser.parse_args()
   print('Processing..')

   count = xmlToTxtFiles(args.inputXML, args.outputFolder, args.encoding)
   print('\n-> Written %d file(s).' % count)


def createArgsParser():
   parser = ap.ArgumentParser(description = "Converts CintaNotes XML file into a set of TXT files, one TXT for each note.")
   parser.add_argument("inputXML", help = 'Source XML file', type = str)
   parser.add_argument("outputFolder", help = 'Folder to write TXT files to', type = str)
   parser.add_argument("-e", "--encoding", dest="encoding",
                        help = 'Encoding of TXT files: utf-8 or utf-16 (default)', type = str, default = 'utf-16')
   return parser


def xmlToTxtFiles(inputXML, outputFolder, encoding):
   doc = xml.parse(inputXML)
   notes = doc.getElementsByTagName('note')
   count = 0
   for note in notes:
      xmlToTxtFile(note, outputFolder, encoding)
      count += 1
   return count


def xmlToTxtFile(note, outputFolder, encoding):
   filename = genFileName(note)
   plainText, contents = genFileContents(note)
   filename += '.txt' if plainText else '.html'
   with open(os.path.join(outputFolder, filename), "wb") as f:
            f.write(contents.encode(encoding, errors="replace"))


def genFileContents(note):
   title = note.attributes['title'].value
   text = note.firstChild.data if note.firstChild else ''
   plainText = True
   # plainText = ('plainText' in note.attributes) and (note.attributes['plainText'].value == '1')
   return plainText, title + '\n\n' + text


def genFileName(note):
   created = note.attributes['created'].value
   title = makeValidFilePath(note.attributes['title'].value[:50])
   return '%s - %s' % (created, title)

def makeValidFilePath(s):
   s = s.replace('/', '\u2044')
   return ''.join(x for x in s if x.isalnum() or x in ' -.{}#@$%^&!_()[]\u2044')

if __name__ == '__main__': main()