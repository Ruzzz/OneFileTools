pandoc -f html -t markdown -s "%~1" -o "%~dpn1_%date%_%random%.md"