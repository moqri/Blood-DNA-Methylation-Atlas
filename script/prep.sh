wget -nc -i ../ref/GSE239605.txt

for f in bed; do echo $f;  /oak/stanford/scg/lab_mpsnyder/moqri/soft/wgbs_tools/src/python/wgbs_tools.py beta2bed --genome hg38 $f --keep_na> ../../bed/${f%%.*}.bed; done

for f in *.bed; do  echo $f;  awk '{print $1,$2,"+","CpG",($5 ? $4/$5 : 0),$5}' $f > ../meth/${f%.*}.meth; done

dnmtools merge meth/*_Blood-T-CD8*.meth -o merge/cd8

dnmtools hmr-rep merge/$f -o hmr/$f

awk '{print $1,$2,$2+1,$5}' $f.meth | wigToBigWig /dev/stdin hg38.chrom.sizes $f.bw

