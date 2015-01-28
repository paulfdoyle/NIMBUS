#!/bin/bash

for a in {0..1}
do
	for b in {0..9}
	do
		for c in {0..2}
		do
			for d in {0..9}
			do
				for e in {0..9}
				do
                               		for f in {0..9}
                                	do 
						wget -O thowawayordelete.file http://webnode3.nightsky.ie/data/compressed/$a$b-000$c$d$e$f.fits.fz
					done
				done
			done	
		done	
	done	
done

