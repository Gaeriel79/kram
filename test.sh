#!/bin/sh


echo Variable 1
read var1
echo Variable 2
read var2

echo ${var1}
echo ${var2}

echo ${var1} | tee -a test.txt
echo ${var2} | tee -a test.txt
