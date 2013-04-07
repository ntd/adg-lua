all: adg-web.png adg-lua.png

clean:
	rm -f adg-web.pdf adg-web.png adg-lua.pdf adg-lua.png


adg-web.pdf: adg-web.tex base.tex
	pdflatex adg-web.tex

adg-web.png: adg-web.pdf
	convert -antialias -density 600 $< -flatten -resize 800x $@

adg-lua.pdf: adg-lua.tex base.tex
	pdflatex adg-lua.tex

adg-lua.png: adg-lua.pdf
	convert -antialias -density 600 $< -flatten -resize 800x $@
