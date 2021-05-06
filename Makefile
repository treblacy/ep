ep : ep.hs
	ghc -O $<
	strip $@

.PHONY: clean
clean:
	rm -f ep ep.hi ep.o
