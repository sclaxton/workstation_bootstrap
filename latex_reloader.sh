#!/bin/bash
while [  0 -lt 10 ]; do
      tex="`ls *.tex | head -n1`"; diff $tex .last > /dev/null
      rs=$?
      if [ $rs != "0" ] 
      then
	  pdflatex *.tex &
	  pid=$!
	  sleep 2
	  kill $pid 2> /dev/null || cp $tex .last
	  
      fi
      sleep 1
