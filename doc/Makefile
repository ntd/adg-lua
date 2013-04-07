all: adg-web.png

clean:
	rm -f adg-web.pdf adg-web.png


adg-web.pdf: adg-web.tex base.tex
	pdflatex adg-web.tex

adg-web.png: adg-web.pdf
	convert -antialias -density 600 $< -flatten -resize 800x $@
