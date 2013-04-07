all: web.png

clean:
	rm -f web.pdf web.png


web.pdf: web.tex
	pdflatex $<

web.png: web.pdf
	convert -antialias -density 600 $< -flatten -resize 800x $@
