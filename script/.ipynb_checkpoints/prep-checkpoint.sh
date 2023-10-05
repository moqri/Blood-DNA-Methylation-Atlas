wget -nc -i ../ref/GSE239605.txt

for f in beta/*.beta; do fn=$(basename -- $f .hg38.beta); echo $fn; /oak/stanford/scg/lab_mpsnyder/moqri/soft/wgbs_tools/src/python/wgbs_tools.py beta2bed --genome hg38 $f --keep_na> bed/$fn.bed; done

for f in bed/*.bed; do fn=$(basename -- $f .bed); echo $f;  awk '{print $1,$2,"+","CpG",($5 ? $4/$5 : 0),$5}' $f > meth/$fn.meth; done

dnmtools merge meth/*_Blood-T-CD4*.meth -o merge/cd4.meth
dnmtools merge meth/*_Blood-T-CD8*.meth -o merge/cd8.meth
dnmtools merge meth/*_Blood-NK*.meth -o merge/nk.meth
dnmtools merge meth/*_Blood-Monocytes*.meth -o merge/mono.meth
dnmtools merge meth/*_Blood-Granulocytes*.meth -o merge/gran.meth
dnmtools merge meth/*_Blood-B*.meth -o merge/b.meth

for f in cd4 cd8 wbc nk mono gran b; 
do
 dnmtools hmr-rep merge/$f.meth -o hmr/$f.hmr
 awk '{print $1,$2,$2+1,$5}' merge/$f.meth | /oak/stanford/scg/lab_mpsnyder/moqri/soft/ucsc/wigToBigWig /dev/stdin ../ref/hg38.chrom.sizes bw/$f.bw; 
done

awk -v OFS="\t" '{print $1,$2,$3,"1"}' hmr/bw.sub > hmr/bed/bw.bed
/labs/mpsnyder/moqri/soft/ucsc/bedGraphToBigWig hmr/bed/bwc.bed ../../ref/hg38.chrom.sizes hmr/bw/bwc_hmr.bw

for f in cd4 cd8 nk mono gran b 
do
    awk -v OFS="\t" '{print $1,$2,$3,"1"}' hmr/$f.unq > hmr/bed/$f.bed
    /labs/mpsnyder/moqri/soft/ucsc/bedGraphToBigWig hmr/bed/$f.bed ../../ref/hg38.chrom.sizes hmr/bw/"$f"_hmr.bw
done


#LC_ALL=C sort -k 1,1 -k 2,2n merge/$f -o merge/$f
dnmtools roi hmr/$f.unq merge/$f -M | awk '{print $5"\t"$10"\t"$11"\t"$12}' > hmr/$f.m
dnmtools roi hmr/$f.unq merge/wbc -M | awk '{print $5"\t"$11"\t"$12}' > hmr/$f.w
paste hmr/$f.unq hmr/$f.m hmr/$f.w > hmr/$f.a
awk '{printf "%s\t%.0f\t%.0f\t%.0f\t%.0f\t%.0f\t%.0f\t%.2f\t%.2f\t%.2f\t%.0f\t%.0f\n", $1,$2,$3,$5,$8,$9,$12,$11,$7,$11-$7,$10,$13}' hmr/$f.a > hmr/$f.al
LC_ALL=C sort -k10,10rn hmr/$f.al -o hmr/$f.al
awk '$6>30 && $7>30 {print}' hmr/$f.al | head -n10


