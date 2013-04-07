all: adg-web.png adg-lua.png adg-demo.png

clean:
	rm -f adg-web.pdf adg-web.png adg-lua.pdf adg-lua.png adg-demo.pdf adg-demo.png


adg-web.pdf: adg-web.tex base.tex
	pdflatex adg-web.tex

adg-web.png: adg-web.pdf
	convert -antialias -density 600 $< -flatten -resize 800x $@

adg-lua.pdf: adg-lua.tex base.tex
	pdflatex adg-lua.tex

adg-lua.png: adg-lua.pdf
	convert -antialias -density 600 $< -flatten -resize 800x $@

adg-demo.pdf: adg-demo.tex base.tex
	pdflatex adg-demo.tex

adg-demo.png: adg-demo.pdf
	convert -antialias -density 600 $< -flatten -resize 800x $@
