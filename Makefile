FILES:=$(shell find . -path ./_site -prune -o -name '*.ipynb' -print)

all: markdown

markdown:
	@$(foreach nb, $(FILES), ipynb2markdown $(nb);)
