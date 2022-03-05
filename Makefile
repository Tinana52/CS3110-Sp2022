.PHONY: test check

build:
	dune build

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

doc:
	dune build @doc
