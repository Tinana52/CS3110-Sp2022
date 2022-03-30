.PHONY: test check

build:
	dune build src
	dune build bin

utop:
	OCAMLRUNPARAM=b dune utop src

test:
	OCAMLRUNPARAM=b dune exec test/main.exe

launch:
	OCAMLRUNPARAM=b dune exec bin/main.exe

zip:
	rm -f project.zip
	zip -r project.zip . -x@exclude.lst

clean:
	dune clean
	rm -f project.zip

remove: 
	rm -r data/output
	mkdir data/output

doc:
	dune build @doc

loc:
	make clean
	cloc --by-file --include-lang=OCaml .
	make build
